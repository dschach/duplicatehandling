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
* @File Name          : DuplicateRecordItemTriggerHandler.cls
* @Description        :
* @Author             : David Schach
* @Group              :
* @Last Modified By   : David Schach
* @Last Modified On   : 04/19/2021
* @Modification Log   :
* Ver       Date            Author        Modification
* 1.0    04/19/2021   David Schach     Initial Version
**/
public without sharing class DuplicateRecordItemTriggerHandler {

	public static void handleTrigger(List<DuplicateRecordItem> newRecords, List<DuplicateRecordItem> oldRecords, Map<Id, DuplicateRecordItem> newRecordsMap, Map<Id, DuplicateRecordItem> oldRecordsMap, System.TriggerOperation triggerEvent) {
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

	private static void assortDuplicateItems(List<DuplicateRecordItem> newRecords){

		Set<Id> recIDs = new Set<Id>();
		for(DuplicateRecordItem dri : newRecords){
			recIDs.add(dri.RecordId);
			dri.Object_Type__c = dri.RecordId.getSObjectType().getDescribe().getName();
		}

		handleAccounts(newRecords, recIDs);
		handleContacts(newRecords, recIDs);
		handleLeads(newRecords, recIDs);

	}

	/* private static void fillFields(List<DuplicateRecordItem> newRecords){

		// Start by populating a lot of describe information. This is probably more code than your org needs
		// because we are writing this to be extensible so it can handle any object with or without record types

		Set<Id> recIDs = new Set<Id>();
		//List<String> objectNames = new List<String>();


		Map<String, Schema.DescribeSObjectResult> prefixToObject = new Map<String, Schema.DescribeSObjectResult>();
		Map<String, Boolean> prefixToHasRecordType = new Map<String, Boolean>();
		Map<Id, String> recordTypeIDsToNames = new Map<Id, String>();

		for(DuplicateRecordItem dri : newRecords){
			recIDs.add(dri.RecordId);
			String prefix = ((String)dri.recordId).substring(0, 3);
			System.debug('PREFIX: ' + prefix);
			//prefixes.add(prefix);
			if(!prefixToObject.containsKey(prefix)){
				Schema.DescribeSObjectResult dsr = dri.RecordId.getSObjectType().getDescribe();
				prefixToObject.put(prefix, dsr);

				//objectNames.add(dsr.getName());
				//System.debug('ObjectName: ' + dsr.getName());

				Boolean hasRecordType = dri.RecordId.getSObjectType().getDescribe().fields.getMap().containsKey('recordtypeid');
				prefixToHasRecordType.put(prefix, hasRecordType);
				if(hasRecordType){
					for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()){
						recordTypeIDsToNames.put(rti.getRecordTypeId(), rti.getName());
					}
				}
			}
		}

		// We are putting a SOQL query in a loop, but it's not a loop on the trigger records;
		// it is a loop on the object types, so we will not hit any governor limits.
		// In fact, it's a better practice than hard-coding loops for each possible object.

		Map<Id, SObject> allDuplicateRecords = new Map<Id, SObject>();
		for(String prefix : prefixToObject.keyset() ){

			String objectName = prefixToObject.get(prefix).getName();
			Boolean hasRT = prefixToHasRecordType.get(prefix);

			String recordQuery = 'SELECT Id, CreatedDate, CreatedById, CreatedBy.Name';
			if(objectName.equalsIgnoreCase('Contact')){
				recordQuery += ', AccountId';
			}
			if(hasRT){
				recordQuery += ', RecordTypeId';
			}
			recordQuery += ' FROM ' + objectName + ' WHERE Id IN :recIDs';
			System.debug('Dupe record query ' + recordQuery);
			for(SObject so : Database.query(recordQuery)){
				allDuplicateRecords.put((Id)so.get('Id'), so);
			}
		}

		for(DuplicateRecordItem dri : newRecords){

			SObject dupeRecord = allDuplicateRecords.get(dri.RecordId);
			String prefix = ((String)dri.RecordId).substring(0, 3);

			dri.Object_Type__c = prefixToObject.get(prefix).getName();
			String cbString = JSON.serializePretty(dupeRecord);
			System.debug(JSON.serializePretty(dupeRecord));
			Map<String, Object> cb = (Map<String, Object>)JSON.deserializeUntyped(cbString);
			Map<String, Object> createdBy = (Map<String, Object>)cb.get('CreatedBy');
			System.debug('createdBy ' + createdBy);
			dri.Created_By__c = (Id)createdBy.get('Id');
			dri.Created_By_Name__c = (String)createdBy.get('Name');
			dri.Created_Date__c = (DateTime)(dupeRecord.get('CreatedDate'));

			// Handle RecordType objects
			if( prefixToHasRecordType.containsKey(prefix) && prefixToHasRecordType.get(prefix) == true ){
				dri.Record_Type__c = recordTypeIDsToNames.get((Id)dupeRecord.get('RecordTypeId'));
			} else {
				dri.Record_Type__c = null;
			}

			// Handle Account, Contact, Lead differently

			if(dri.Object_Type__c.equalsIgnoreCase('Account')){
				dri.Account__c = dri.RecordId;
			} else if(dri.Object_Type__c.equalsIgnoreCase('Contact')){
				dri.Contact__c = dri.RecordId;
				dri.Account__c = (Id)(dupeRecord.get('AccountId'));
			} else if(dri.Object_Type__c.equalsIgnoreCase('Lead')){
				dri.Lead__c = dri.RecordId;
			}
		}
	} */

	private static void handleAccounts(List<DuplicateRecordItem> newAccounts, Set<Id> recordIDs){

		Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
		Boolean hasRecordType = rtMapById.size() > 1;

		String recordQuery = 'SELECT Id, CreatedDate, CreatedById, CreatedBy.Name';
		if(hasRecordType){
			recordQuery += ', RecordTypeId, RecordType.Name';
		}
		recordQuery += ' FROM Account WHERE Id IN :recordIDs';

		Map<Id, Account> duplicateAccounts = new Map<Id, Account>((List<Account>)Database.query(recordQuery));

		for(DuplicateRecordItem dri : newAccounts){
			if(duplicateAccounts.containsKey(dri.RecordId)){
				Account a = duplicateAccounts.get(dri.RecordId);
				dri.Account__c = a.Id;
				dri.Created_By__c = a.CreatedById;
				dri.Created_By_Name__c = a.CreatedBy.Name;
				dri.Created_Date__c = a.CreatedDate;
				if(hasRecordType){
					Schema.RecordTypeInfo sri = rtMapById.get((Id)a.get('RecordTypeId'));
					dri.Record_Type__c = sri.getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	private static void handleContacts(List<DuplicateRecordItem> newContacts, Set<Id> recordIDs){

		Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Contact.getRecordTypeInfosById();
		Boolean hasRecordType = rtMapById.size() > 1;

		String recordQuery = 'SELECT Id, AccountId, CreatedDate, CreatedById, CreatedBy.Name';
		if(hasRecordType){
			recordQuery += ', RecordTypeId, RecordType.Name';
		}
		recordQuery += ' FROM Contact WHERE Id IN :recordIDs';

		Map<Id, Contact> duplicateContacts = new Map<Id, Contact>((List<Contact>)Database.query(recordQuery));

		for(DuplicateRecordItem dri : newContacts){
			if(duplicateContacts.containsKey(dri.RecordId)){
				Contact c = duplicateContacts.get(dri.RecordId);
				dri.Contact__c = c.Id;
				dri.Account__c = c.AccountId;
				dri.Created_By__c = c.CreatedById;
				dri.Created_By_Name__c = c.CreatedBy.Name;
				dri.Created_Date__c = c.CreatedDate;
				if(hasRecordType){
					Schema.RecordTypeInfo sri = rtMapById.get((Id)c.get('RecordTypeId'));
					dri.Record_Type__c = sri.getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	private static void handleLeads(List<DuplicateRecordItem> newLeads, Set<Id> recordIDs){

		Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Lead.getRecordTypeInfosById();
		Boolean hasRecordType = rtMapById.size() > 1;

		String recordQuery = 'SELECT Id, CreatedDate, CreatedById, CreatedBy.Name';
		if(hasRecordType){
			recordQuery += ', RecordTypeId, RecordType.Name';
		}
		recordQuery += ' FROM Lead WHERE Id IN :recordIDs';

		Map<Id, Lead> duplicateLeads = new Map<Id, Lead>((List<Lead>)Database.query(recordQuery));

		for(DuplicateRecordItem dri : newLeads){
			if(duplicateLeads.containsKey(dri.RecordId)){
				Lead a = duplicateLeads.get(dri.RecordId);
				dri.Lead__c = a.Id;
				dri.Created_By__c = a.CreatedById;
				dri.Created_By_Name__c = a.CreatedBy.Name;
				dri.Created_Date__c = a.CreatedDate;
				if(hasRecordType){
					Schema.RecordTypeInfo sri = rtMapById.get((Id)a.get('RecordTypeId'));
					dri.Record_Type__c = sri.getName();
				} else {
					dri.Record_Type__c = null;
				}
			}
		}
	}

	private static void updateDuplicateRecordSet(List<DuplicateRecordItem> newRecords){
		Map<Id, DuplicateRecordSet> toUpdate = new Map<Id, DuplicateRecordSet>();
		for(DuplicateRecordItem dri : newRecords){
			//String sObjectName = dri.RecordId.getSObjectType().getDescribe().getName();
			DuplicateRecordSet drs = new DuplicateRecordSet(Id = dri.DuplicateRecordSetId);
			drs.Object_Type__c = dri.Object_Type__c;
			toUpdate.put(dri.DuplicateRecordSetId, drs);
		}
		update toUpdate.values();
	}
}