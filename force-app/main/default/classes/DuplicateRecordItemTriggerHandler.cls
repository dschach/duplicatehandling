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
 * Ver       Date            Author        Modification
 * 1.0    04/19/2021   David Schach     Initial Version
 * 1.1    02/28/2022   David Schach     Static to instance trigger handler methods
 */
/**
 * Trigger Handler for `DuplicateRecordItem`
 * @author {@link [David Schach](https://github.com/dschach)}
 * @since 04/19/2021     Initial Version
 * @since 02/28/2022     Static to instance trigger handler methods
 * @see DuplicateRecordHandlersTest
 * @group Duplicate Handlers
 */
public inherited sharing class DuplicateRecordItemTriggerHandler {
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
		List<DuplicateRecordItem> newRecords,
		List<DuplicateRecordItem> oldRecords,
		Map<Id, DuplicateRecordItem> newRecordsMap,
		Map<Id, DuplicateRecordItem> oldRecordsMap,
		System.TriggerOperation triggerEvent
	) {
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
			when AFTER_UPDATE {
				updateDuplicateRecordSet(newRecords);
			}
			when AFTER_DELETE {
				updateDuplicateRecordSet(oldRecords);
			}
		}
	}

	/**
	 * Assign object type and then handle all records
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param  newRecords Trigger.new
	 */
	private void assortDuplicateItems(List<DuplicateRecordItem> newRecords) {
		Map<String, String> mapPrefixToObjectName = new Map<String, String>();
		Set<Id> recIDs = new Set<Id>();
		Boolean hasAccounts = false;
		Boolean hasContacts = false;
		Boolean hasLeads = false;

		for (DuplicateRecordItem dri : newRecords) {
			String recId = (String) dri.RecordId;
			String recPrefix = recId.left(3);
			switch on recPrefix {
				when '001' {
					hasAccounts = true;
				}
				when '003' {
					hasContacts = true;
				}
				when '00Q' {
					hasLeads = true;
				}
			}
			if (!mapPrefixToObjectName.containsKey(recPrefix)) {
				mapPrefixToObjectName.put(recPrefix, dri.RecordId.getSObjectType().getDescribe().getName()); //NOPMD
			}
			recIDs.add(dri.RecordId);
			dri.Object_Type__c = mapPrefixToObjectName.get(recPrefix);
		}

		if (hasAccounts) {
			handleAccounts(newRecords, recIDs);
		}
		if (hasContacts) {
			handleContacts(newRecords, recIDs);
		}
		if (hasLeads) {
			handleLeads(newRecords, recIDs);
		}
	}

	/**
	 * Handle Accounts (may be duplicated for any object)
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param  newAccounts Trigger.new
	 * @param  recordIDs   AccountIDs, which are technically in newAccounts, but included for simplicity
	 */
	private void handleAccounts(List<DuplicateRecordItem> newAccounts, Set<Id> recordIDs) {
		Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
		Boolean hasRecordType = rtMapById.size() > 1;

		// dynamic query in case the org does not use Account record types
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
				if (hasRecordType && a.get('RecordTypeId') != null) {
					dri.Record_Type__c = rtMapById.get((Id) a.get('RecordTypeId')).getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	/**
	 * Handle Contacts (may be duplicated for any object)
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param newContacts Trigger.new
	 * @param recordIDs ContactIDs, which are technically in newContacts, but included for simplicity
	 **/
	private void handleContacts(List<DuplicateRecordItem> newContacts, Set<Id> recordIDs) {
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
				if (hasRecordType && c.get('RecordTypeId') != null) {
					dri.Record_Type__c = rtMapById.get((Id) c.get('RecordTypeId')).getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	/**
	 * Handle Leads (may be duplicated for any object)
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param newLeads Trigger.new
	 * @param recordIDs LeadIDs, which are technically in newLeads, but included for simplicity
	 **/
	private void handleLeads(List<DuplicateRecordItem> newLeads, Set<Id> recordIDs) {
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
				if (hasRecordType && a.get('RecordTypeId') != null) {
					dri.Record_Type__c = rtMapById.get((Id) a.get('RecordTypeId')).getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	/**
	 * Update the parent `DuplicateRecordItem` records
	 * @author {@link [David Schach](https://github.com/dschach)}
	 * @param newRecords Trigger.new
	 */
	private void updateDuplicateRecordSet(List<DuplicateRecordItem> newRecords) {
		Map<Id, DuplicateRecordSet> toUpdate = new Map<Id, DuplicateRecordSet>();
		for (DuplicateRecordItem dri : newRecords) {
			DuplicateRecordSet drs = new DuplicateRecordSet(Id = dri.DuplicateRecordSetId);
			drs.Object_Type__c = dri.Object_Type__c;
			toUpdate.put(dri.DuplicateRecordSetId, drs);
		}
		update toUpdate.values();
	}
}