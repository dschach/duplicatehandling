/**
 * @File Name          : DuplicateRecordHandlersTest.cls
 * @Description        :
 * @Author             : David Schach
 * @Group              :
 * @Last Modified By   : David Schach
 * @Last Modified On   : 11/13/2019, 12:42:09 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    11/13/2019   David Schach     Initial Version
**/
@isTest
public class DuplicateRecordHandlersTest {

	@TestSetup
	static void makeData(){
		Account a = setupAccounts(1)[0];
		insert a;
		Contact c = setupContact(a.Id);
		insert c;
		Lead l = setupLead();
		insert l;
	}

	static List<Account> setupAccounts(Integer acctCount){
		List<Account> accts = new List<Account>();
		for(Integer i = 0; i < acctCount; i++){
		Account a = new Account();
		a.Name = 'TD';
		a.Website = 'www.salesforce.com';
		a.BillingCity = 'New York';
		a.BillingPostalCode = '10027';
		accts.add(a);
		}
		//insert accts;
		return accts;
	}

	static List<Contact> setupContacts(List<Account> accts){
		List<Contact> cons = new List<Contact>();
		for(Account a : accts){
			Contact c = new Contact();
			c.FirstName = 'John';
			c.LastName = 'Smith';
			c.Email = 'smith@td.com';
			c.AccountId = a.Id;
			cons.add(c);
		}
		//insert cons;
		return cons;
	}

	static Contact setupContact(Id acctId){
		Contact c = new Contact();
		c.FirstName = 'John';
		c.LastName = 'Smith';
		c.Email = 'smith@td.com';
		c.AccountId = acctId;
		return c;
	}

	static Lead setupLead(){
		Lead l = new Lead();
		l.FirstName = 'James';
		l.LastName = 'Doe';
		l.Email = 'jdoe@td.com';
		l.Company = 'TD';
		return l;

	}

	@isTest
	private static void dupeAccountsCreate(){
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Account_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		test.startTest();
		Account a = setupAccounts(1)[0];

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(a, insertDML);

		System.debug('Account count: ' + [SELECT Count() FROM Account]);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for(Account ac : [SELECT Id FROM Account]){
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		System.debug('inserting this many duplicaterecorditems: ' + drisToInsert.size());
		insert drisToInsert;

		System.debug('We now have ' + [SELECT Count() FROM DuplicateRecordItem] + ' duplicaterecoritems');
		test.stopTest();

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Account', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Account__c FROM DuplicateRecordItem];
		for(DuplicateRecordItem dri : driList){
			System.assertEquals('Account', dri.Object_Type__c);
		}
		List<Account> primary = [SELECT Id FROM Account WHERE Id = :a.Id];
		List<Account> secondaries = [SELECT Id FROM Account WHERE Id != :a.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false);
		//System.assertEquals(0, [SELECT Count() FROM DuplicateRecordSet]);
	}

	@isTest
	private static void dupeAccountsMerge(){
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Account_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		test.startTest();
		Account a = setupAccounts(1)[0];

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(a, insertDML);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for(Account ac : [SELECT Id FROM Account]){
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Account', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Account__c FROM DuplicateRecordItem];
		for(DuplicateRecordItem dri : driList){
			System.assertEquals('Account', dri.Object_Type__c);
		}
		List<Account> primary = [SELECT Id FROM Account WHERE Id = :a.Id];
		List<Account> secondaries = [SELECT Id FROM Account WHERE Id != :a.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false);
		test.stopTest();

		System.assertEquals(0, [SELECT Count() FROM DuplicateRecordSet], 'DuplicateRecordSet not deleted');
	}


	/* CONTACTS **************************** */

	@isTest
	private static void dupeContactsCreate(){
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Contact_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		test.startTest();
		Account a = [SELECT Id FROM Account][0];
		Contact c = setupContact(a.Id);

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(c, insertDML);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for(Contact cc : [SELECT Id FROM Contact]){
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = cc.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;
		test.stopTest();

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Contact', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Contact__c FROM DuplicateRecordItem];
		for(DuplicateRecordItem dri : driList){
			System.assertEquals('Contact', dri.Object_Type__c);
		}
		List<Contact> primary = [SELECT Id FROM Contact WHERE Id = :c.Id];
		List<Contact> secondaries = [SELECT Id FROM Contact WHERE Id != :c.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false);
		//System.assertEquals(0, [SELECT Count() FROM DuplicateRecordSet]);
	}

	@isTest
	private static void dupeContactsMerge(){
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Contact_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		test.startTest();
		Account a = [SELECT Id FROM Account][0];
		Contact c = setupContact(a.Id);

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(c, insertDML);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for(Contact cc : [SELECT Id FROM Contact]){
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = cc.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Contact', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Contact__c FROM DuplicateRecordItem];
		for(DuplicateRecordItem dri : driList){
			System.assertEquals('Contact', dri.Object_Type__c);
		}
		List<Contact> primary = [SELECT Id FROM Contact WHERE Id = :c.Id];
		List<Contact> secondaries = [SELECT Id FROM Contact WHERE Id != :c.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false);
		test.stopTest();

		System.assertEquals(0, [SELECT Count() FROM DuplicateRecordSet], 'DuplicateRecordSet not deleted');
	}

	/* LEADS **************************** */

	@isTest
	private static void dupeLeadsCreate(){
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Lead_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		test.startTest();
		Lead l = setupLead();

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(l, insertDML);

		System.debug('Lead count: ' + [SELECT Count() FROM Lead]);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for(Lead ac : [SELECT Id FROM Lead]){
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		System.debug('inserting this many duplicaterecorditems: ' + drisToInsert.size());
		insert drisToInsert;

		System.debug('We now have ' + [SELECT Count() FROM DuplicateRecordItem] + ' duplicaterecoritems');
		test.stopTest();

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Lead', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Lead__c FROM DuplicateRecordItem];
		for(DuplicateRecordItem dri : driList){
			System.assertEquals('Lead', dri.Object_Type__c);
		}
		List<Lead> primary = [SELECT Id FROM Lead WHERE Id = :l.Id];
		List<Lead> secondaries = [SELECT Id FROM Lead WHERE Id != :l.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false);
		//System.assertEquals(0, [SELECT Count() FROM DuplicateRecordSet]);
	}

	@isTest
	private static void dupeLeadsMerge(){
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Lead_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		test.startTest();
		Lead l = setupLead();

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(l, insertDML);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for(Lead ac : [SELECT Id FROM Lead]){
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Lead', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Lead__c FROM DuplicateRecordItem];
		for(DuplicateRecordItem dri : driList){
			System.assertEquals('Lead', dri.Object_Type__c);
		}
		List<Lead> primary = [SELECT Id FROM Lead WHERE Id = :l.Id];
		List<Lead> secondaries = [SELECT Id FROM Lead WHERE Id != :l.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false);
		test.stopTest();

		System.assertEquals(0, [SELECT Count() FROM DuplicateRecordSet], 'DuplicateRecordSet not deleted');
	}
}