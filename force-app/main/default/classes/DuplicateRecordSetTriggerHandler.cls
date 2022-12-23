/*
 * Duplicate Handling helper code
 * Copyright (C) 2021 David Schach

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
/*
 * Ver       Date            Author           Modification
 * 1.0    04/19/2021   David Schach     Initial Version
 * 1.1    04/19/2021   David Schach     Moved deletion of sets to the Item trigger handler for more control and to delete 0 record count sets
 * 1.2    02/28/2022   David Schach     Static to instance trigger handler methods
 * 1.3    09/14/2022   David Schach     Salesforce may be auto-deleting single-record sets, so setting allOrNothing to false
 */
/**
 * Trigger Handler for `DuplicateRecordSet`
 * @author {@link [David Schach](https://github.com/dschach)}
 * @since 04/19/2021 Initial Version
 * @since 04/19/2021 Moved deletion of sets to the Item trigger handler for more control and to delete 0 record count sets
 * @since 02/28/2022 Static to instance trigger handler methods
 * @since 09/14/2022 Salesforce may be auto-deleting single-record sets, so setting allOrNothing to false
 * @see DuplicateRecordHandlersTest
 * @group Duplicate Handlers
 */
public inherited sharing class DuplicateRecordSetTriggerHandler {
	/**
	 * Handle all trigger records
	 *
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param newRecords    Trigger.new
	 * @param oldRecords    Trigger.old
	 * @param newRecordsMap Trigger.newMap
	 * @param oldRecordsMap Trigger.oldMap
	 * @param triggerEvent  Trigger context enum
	 */
	public void handleTrigger(
		List<DuplicateRecordSet> newRecords,
		List<DuplicateRecordSet> oldRecords,
		Map<Id, DuplicateRecordSet> newRecordsMap,
		Map<Id, DuplicateRecordSet> oldRecordsMap,
		System.TriggerOperation triggerEvent
	) {
		//System.debug('IN DRS TRIGGER HANDLER');
		switch on triggerEvent {
			when AFTER_UPDATE {
				findSingleRecordSets(newRecords, oldRecordsMap);
			}
		}
	}

	/**
	 * Query for all single-item `DuplicateRecordSet` records
	 * <br>First we exclude DRS records where the DRI count was and is zero. This allows us to instantiate the record. We don't know why DRS records are also updated when they are created, but that's the situation.
	 * <br>Then we delete DRS records where RecordCount < 2 (0 or 1) and can do so because we allowed the creation of the DRS.
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param  newRecords Trigger.new
	 * @param  oldRecordsMap Trigger.oldMap
	 */
	public void findSingleRecordSets(List<DuplicateRecordSet> newRecords, Map<Id, DuplicateRecordSet> oldRecordsMap) {
		Set<Id> toDelete = new Set<Id>();
		for (DuplicateRecordSet drs : newRecords) {
			// Prevent deleting DRS when it is instantiated. (No idea why it's updated before DRS are added.)
			if (drs.RecordCount == 0 && oldRecordsMap.get(drs.Id).RecordCount == 0) {
				continue;
			}
			if (drs.RecordCount < 2) {
				toDelete.add(drs.Id);
			}
		}

		if (!toDelete.isEmpty()) {
			if (!System.isFuture() && !System.isBatch()) {
				deleteSingleRecordSetsFuture(toDelete);
			} else {
				deleteUnnecessaryRecordSets(toDelete);
			}
		}
	}

	/**
	 * Future delete `DuplicateRecordSet` records with only 1 `DuplicateRecordItem`
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param  candidatesToDelete Queried `DuplicateRecordSet` records with 1 `DuplicateRecordItem`
	 */
	@future
	public static void deleteSingleRecordSetsFuture(Set<Id> candidatesToDelete) {
		deleteUnnecessaryRecordSets(candidatesToDelete);
	}

	/**
	 * Declare deletion in a synchronous method so it can be called from either the main handler class or an asychronous method. (DRY)
	 *
	 * @param candidatesToDelete  `DuplicateRecordSet` IDs to delete
	 */
	private static void deleteUnnecessaryRecordSets(Set<Id> candidatesToDelete) {
		Database.delete([SELECT Id FROM DuplicateRecordSet WHERE Id IN :candidatesToDelete AND IsDeleted = FALSE], false);
	}
}