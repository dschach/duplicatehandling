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
public inherited sharing class DuplicateRecordItemTriggerHandler {

	public static void handleTrigger(List<DuplicateRecordItem> newRecords, List<DuplicateRecordItem> oldRecords, Map<Id, DuplicateRecordItem> newRecordsMap, Map<Id, DuplicateRecordItem> oldRecordsMap, System.TriggerOperation triggerEvent) {
		System.debug('IN DUPLICATE RECORD ITEM TRIGGER HANDLER ' + triggerEvent.name());
		switch on triggerEvent {

			when BEFORE_INSERT {
				fillFields(newRecords);
			}
			when AFTER_INSERT {
				updateDuplicateRecordSet(newRecords);
			}
			when BEFORE_UPDATE {
				fillFields(newRecords);
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

	private static void fillFields(List<DuplicateRecordItem> newRecords){
		Set<Id> recIDs = new Set<Id>();
		for(DuplicateRecordItem dri : newRecords){
			recIDs.add(dri.RecordId);
		}
		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name, CreatedBy.Name, CreatedDate FROM Account WHERE Id IN :recIDs]);
		Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, Name, AccountId, CreatedBy.Name, CreatedDate FROM Contact WHERE Id IN :recIDs]);
		Map<Id, Lead> leads = new Map<Id, Lead>([SELECT Id, Name, CreatedBy.Name, CreatedDate FROM Lead WHERE Id IN :recIDs]);
		for(DuplicateRecordItem dri : newRecords){
			if(dri.RecordId.getSobjectType() == Schema.Account.SObjectType){
				System.debug('DUPLICATE ACCOUNT');
				dri.Object_Type__c = 'Account';
				if(accounts.containsKey(dri.RecordId)){
					Account a = accounts.get(dri.RecordId);
					dri.Account__c = a.Id;
					dri.Created_By__c = a.CreatedBy.Name;
					dri.Created_Date__c = a.CreatedDate;
				}
			}
			else if(dri.RecordId.getSobjectType() == Schema.Contact.SObjectType){
				dri.Object_Type__c = 'Contact';
				System.debug('DUPLICATE CONTACT');
				if(contacts.containsKey(dri.RecordId)){
					dri.Account__c = contacts.get(dri.RecordId).AccountId;
					Contact c = contacts.get(dri.RecordId);
					dri.Contact__c = c.Id;
					dri.Created_By__c = c.CreatedBy.Name;
					dri.Created_Date__c = c.CreatedDate;
				}
			}
			else if(dri.RecordId.getSobjectType() == Schema.Lead.SObjectType){
				dri.Object_Type__c = 'Lead';
				System.debug('DUPLICATE CONTACT');
				if(leads.containsKey(dri.RecordId)){
					Lead c = leads.get(dri.RecordId);
					dri.Lead__c = c.Id;
					dri.Created_By__c = c.CreatedBy.Name;
					dri.Created_Date__c = c.CreatedDate;
				}
			}
		}

		/* Fill Object Types in separate loop to minimize describes */
		/* TODO: Check if object has record types and fill that */
		Map<String, Schema.DescribeSObjectResult> prefixToObject = new Map<String, Schema.DescribeSObjectResult>();
		Set<String> recordIDs = new Set<String>();
		for(DuplicateRecordItem dri : newRecords){
			recordIDs.add(dri.RecordId);
			String prefix = ((String)dri.recordId).substring(0, 3);
			if(!prefixToObject.containsKey(prefix)){
				Schema.DescribeSObjectResult dsr = dri.RecordId.getSObjectType().getDescribe();
				prefixToObject.put(prefix, dsr);
			}
		}
		for(DuplicateRecordItem dri : newRecords){
			String prefix = ((String)dri.recordId).substring(0, 3);
			if(prefixToObject.containsKey(prefix)){
				Schema.DescribeSObjectResult dsr = prefixToObject.get(prefix);
				dri.Object_Type__c = dsr.getName();
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