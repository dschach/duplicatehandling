/**
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

/**
 * @File Name          : DuplicateRecordSetTriggerHandler.cls
 * @Description        :
 * @Author             : David Schach
 * @Group              :
 * @Last Modified By   : David Schach
 * @Last Modified On   : 04/19/2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    04/19/2021   David Schach     Initial Version
 * 1.1	  04/19/2021   David Schach     Moved deletion of sets to the Item trigger handler for more control and to delete 0 record count sets
**/
public without sharing class DuplicateRecordSetTriggerHandler {
    public static void handleTrigger(List<DuplicateRecordSet> newRecords, List<DuplicateRecordSet> oldRecords, Map<Id, DuplicateRecordSet> newRecordsMap, Map<Id, DuplicateRecordSet> oldRecordsMap, System.TriggerOperation triggerEvent) {
		System.debug('IN DUPLICATE RECORD SET TRIGGER HANDLER ' + triggerEvent.name());
		switch on triggerEvent {

			// NOT listed in trigger. To use these, update trigger contexts.
			//when BEFORE_INSERT {}
			//when AFTER_INSERT {}
			//when BEFORE_UPDATE {}
			//when BEFORE_DELETE {}
			//when AFTER_DELETE {}
			//when AFTER_UNDELETE {}

			when AFTER_UPDATE {
				findSingleRecordSets(newRecords);
			}
		}
	}

	 public static void findSingleRecordSets(List<DuplicateRecordSet> newRecords){

		Set<Id> toDelete = new Set<Id>();
		for(DuplicateRecordSet drs : newRecords){
			System.debug(drs.Name + ' has this many records: ' + drs.RecordCount);
			if(drs.RecordCount == 1){
				toDelete.add(drs.Id);
			}
		}

		if(!toDelete.isEmpty()){
			if(!System.isFuture() && !System.isBatch()){
				System.debug('Calling a FUTURE method to delete the DRS');
				deleteSingleRecordSets(toDelete);
			} else {
				System.debug('Synchronously DELETING ' + [SELECT Count() FROM DuplicateRecordSet WHERE Id IN :toDelete] + ' SETS');
				delete [SELECT Id FROM DuplicateRecordSet WHERE Id IN :toDelete];
			}
		}
	}

	@future
	public static void deleteSingleRecordSets(Set<Id> candidatesToDelete){
		System.debug('FUTURE DELETING ' + [SELECT Count() FROM DuplicateRecordSet WHERE Id IN :candidatesToDelete] + ' SETS');
		delete [SELECT Id FROM DuplicateRecordSet WHERE Id IN :candidatesToDelete];
	}
}