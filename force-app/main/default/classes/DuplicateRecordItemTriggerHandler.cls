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
 * Ver       Date            Author        Modification
 * 1.0    04/19/2021   David Schach     Initial Version
 */
/**
 * Trigger Handler for `DuplicateRecordItem`
 * @author David Schach
 * @since 4/19/2021
 * @see DuplicateRecordHandlersTest
 * @group TriggerHandlers
 */
public without sharing class DuplicateRecordItemTriggerHandler {
	
	/**
	 * @description         Handle all trigger records
	 *
	 * @param newRecords    Trigger.new
	 * @param oldRecords    Trigger.old
	 * @param newRecordsMap Trigger.newMap
	 * @param oldRecordsMap Trigger.oldMap
	 * @param triggerEvent  Trigger context enum
	 */
	public static void handleTrigger(
		List<DuplicateRecordItem> newRecords,
		List<DuplicateRecordItem> oldRecords,
		Map<Id, DuplicateRecordItem> newRecordsMap,
		Map<Id, DuplicateRecordItem> oldRecordsMap,
		System.TriggerOperation triggerEvent
	) {
		System.debug('IN DUPLICATE RECORD ITEM TRIGGER HANDLER ' + triggerEvent.name());
		switch on triggerEvent {
			when BEFORE_INSERT {
				assortDuplicateItems(newRecords);
			}
			when AFTER_INSERT {
				updateDuplicateRecordSet(newRecords);
			}
			when BEFORE_UPDATE {
				assortDuplicateItems(newRecords);
			}
			// NOT listed in trigger. To use this, update trigger contexts.
			when AFTER_UPDATE {
				updateDuplicateRecordSet(newRecords);
			}
			//when BEFORE_DELETE {}
			when AFTER_DELETE {
				updateDuplicateRecordSet(oldRecords);
			}
			//when AFTER_UNDELETE {}
		}
	}

	private static void assortDuplicateItems(List<DuplicateRecordItem> newRecords) {
		Set<Id> recIDs = new Set<Id>();
		for (DuplicateRecordItem dri : newRecords) {
			recIDs.add(dri.RecordId);
			dri.Object_Type__c = dri.RecordId.getSObjectType().getDescribe().getName();
		}

		handleAccounts(newRecords, recIDs);
		handleContacts(newRecords, recIDs);
		handleLeads(newRecords, recIDs);
	}

	private static void handleAccounts(List<DuplicateRecordItem> newAccounts, Set<Id> recordIDs) {
		Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
		Boolean hasRecordType = rtMapById.size() > 1;

		String recordQuery = 'SELECT Id, CreatedDate, CreatedById, CreatedBy.Name';
		if (hasRecordType) {
			recordQuery += ', RecordTypeId, RecordType.Name';
		}
		recordQuery += ' FROM Account WHERE Id IN :recordIDs';

		Map<Id, Account> duplicateAccounts = new Map<Id, Account>((List<Account>) Database.query(recordQuery));

		for (DuplicateRecordItem dri : newAccounts) {
			if (duplicateAccounts.containsKey(dri.RecordId)) {
				Account a = duplicateAccounts.get(dri.RecordId);
				dri.Account__c = a.Id;
				dri.Created_By__c = a.CreatedById;
				dri.Created_By_Name__c = a.CreatedBy.Name;
				dri.Created_Date__c = a.CreatedDate;
				if (hasRecordType) {
					Schema.RecordTypeInfo sri = rtMapById.get((Id) a.get('RecordTypeId'));
					dri.Record_Type__c = sri.getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	private static void handleContacts(List<DuplicateRecordItem> newContacts, Set<Id> recordIDs) {
		Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Contact.getRecordTypeInfosById();
		Boolean hasRecordType = rtMapById.size() > 1;

		String recordQuery = 'SELECT Id, AccountId, CreatedDate, CreatedById, CreatedBy.Name';
		if (hasRecordType) {
			recordQuery += ', RecordTypeId, RecordType.Name';
		}
		recordQuery += ' FROM Contact WHERE Id IN :recordIDs';

		Map<Id, Contact> duplicateContacts = new Map<Id, Contact>((List<Contact>) Database.query(recordQuery));

		for (DuplicateRecordItem dri : newContacts) {
			if (duplicateContacts.containsKey(dri.RecordId)) {
				Contact c = duplicateContacts.get(dri.RecordId);
				dri.Contact__c = c.Id;
				dri.Account__c = c.AccountId;
				dri.Created_By__c = c.CreatedById;
				dri.Created_By_Name__c = c.CreatedBy.Name;
				dri.Created_Date__c = c.CreatedDate;
				if (hasRecordType) {
					Schema.RecordTypeInfo sri = rtMapById.get((Id) c.get('RecordTypeId'));
					dri.Record_Type__c = sri.getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	private static void handleLeads(List<DuplicateRecordItem> newLeads, Set<Id> recordIDs) {
		Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Lead.getRecordTypeInfosById();
		Boolean hasRecordType = rtMapById.size() > 1;

		String recordQuery = 'SELECT Id, CreatedDate, CreatedById, CreatedBy.Name';
		if (hasRecordType) {
			recordQuery += ', RecordTypeId, RecordType.Name';
		}
		recordQuery += ' FROM Lead WHERE Id IN :recordIDs';

		Map<Id, Lead> duplicateLeads = new Map<Id, Lead>((List<Lead>) Database.query(recordQuery));

		for (DuplicateRecordItem dri : newLeads) {
			if (duplicateLeads.containsKey(dri.RecordId)) {
				Lead a = duplicateLeads.get(dri.RecordId);
				dri.Lead__c = a.Id;
				dri.Created_By__c = a.CreatedById;
				dri.Created_By_Name__c = a.CreatedBy.Name;
				dri.Created_Date__c = a.CreatedDate;
				if (hasRecordType) {
					Schema.RecordTypeInfo sri = rtMapById.get((Id) a.get('RecordTypeId'));
					dri.Record_Type__c = sri.getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	private static void updateDuplicateRecordSet(List<DuplicateRecordItem> newRecords) {
		Map<Id, DuplicateRecordSet> toUpdate = new Map<Id, DuplicateRecordSet>();
		for (DuplicateRecordItem dri : newRecords) {
			//String sObjectName = dri.RecordId.getSObjectType().getDescribe().getName();
			DuplicateRecordSet drs = new DuplicateRecordSet(Id = dri.DuplicateRecordSetId);
			drs.Object_Type__c = dri.Object_Type__c;
			toUpdate.put(dri.DuplicateRecordSetId, drs);
		}
		update toUpdate.values();
	}
}
