/*
	Duplicate Handling helper code
    Copyright (C) 2021 David Schach

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
/*
 * Ver       Date            Author      		    Modification
 * 1.0    04/19/2021   David Schach     Initial Version
 * 1.1	  04/19/2021   David Schach     Moved deletion of sets to the Item trigger handler for more control and to delete 0 record count sets
 * 2.0    01/17/2022   David Schach     New Trigger Handler
 */
/**
 * Trigger Handler for `DuplicateRecordSet`
 * @author David Schach
 * @since 4/19/2021
 * @see DuplicateRecordHandlersTest
 * @group TriggerHandlers
 */
public without sharing class DuplicateRecordSetTriggerHandler extends TriggerHandler {
	private List<DuplicateRecordSet> newRecords;
	//private List<DuplicateRecordSet> oldRecords;
	//private Map<Id, DuplicateRecordSet> newRecordsMap;
	//private Map<Id, DuplicateRecordSet> oldRecordsMap;

	/**
	 * @description Constructor using super() method for faster performance
	 * <br>We cast all four trigger collections - but don't use most, so they are commented
	 */
	public DuplicateRecordSetTriggerHandler() {
		super('DuplicateRecordSetTriggerHandler');
		this.newRecords = (List<DuplicateRecordSet>) Trigger.new;
		//this.oldRecords = (List<DuplicateRecordSet>) Trigger.old;
		//this.newRecordsMap = (Map<Id, DuplicateRecordSet>) Trigger.newMap;
		//this.oldRecordsMap = (Map<Id, DuplicateRecordSet>) Trigger.oldMap;
	}

	/**
	 * @description Override afterUpdate. We don't use any other contexts
	 */
	public override void afterUpdate() {
		findSingleRecordSets(newRecords);
	}

	/**
	 * @description      We find all sets with 1 item, and then we pass those to the delete methods
	 *
	 * @param newRecords Trigger.new
	 */
	public static void findSingleRecordSets(List<DuplicateRecordSet> newRecords) {
		Set<Id> toDelete = new Set<Id>();
		for (DuplicateRecordSet drs : newRecords) {
			System.debug(drs.Name + ' has this many records: ' + drs.RecordCount);
			if (drs.RecordCount == 1) {
				toDelete.add(drs.Id);
			}
		}

		if (!toDelete.isEmpty()) {
			if (!System.isFuture() && !System.isBatch()) {
				System.debug('Calling a FUTURE method to delete the DRS');
				deleteSingleRecordSets(toDelete);
			} else {
				System.debug('Synchronously DELETING ' + [SELECT COUNT() FROM DuplicateRecordSet WHERE Id IN :toDelete] + ' SETS');
				delete [SELECT Id FROM DuplicateRecordSet WHERE Id IN :toDelete];
			}
		}
	}

	/**
	 * @description              Future delete all single-member record sets
	 *
	 * @param candidatesToDelete Ids of all record sets we want to delete (in future context, for performance)
	 */
	@future
	public static void deleteSingleRecordSets(Set<Id> candidatesToDelete) {
		System.debug('FUTURE DELETING ' + [SELECT COUNT() FROM DuplicateRecordSet WHERE Id IN :candidatesToDelete] + ' SETS');
		delete [SELECT Id FROM DuplicateRecordSet WHERE Id IN :candidatesToDelete];
	}
}
