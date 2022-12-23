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
 * Ver       Date            Author          Modification
 * 1.0    11/13/2019   David Schach    Initial Version
 * 1.1    02/28/2022   David Schach    PMD-identified cleanup
 */
/**
 * Tests for DuplicateRecord trigger handlers
 * @author {@link [David Schach](https://github.com/dschach)}
 * @since 11/13/2019 Initial Version
 * @since 02/28/2022 PMD-identified cleanup
 * @group Duplicate Handlers
 * @see DuplicateRecordItemTriggerHandler
 * @see DuplicateRecordSetTriggerHandler
 */
@isTest
private class DuplicateRecordHandlersTest {
	@TestSetup
	static void makeData() {
		Account a = setupAccounts(1)[0];
		insert a;
		Contact c = setupContact(a.Id);
		insert c;
		Lead l = setupLead();
		insert l;
	}

	static List<Account> setupAccounts(Integer acctCount) {
		List<Account> accts = new List<Account>();
		for (Integer i = 0; i < acctCount; i++) {
			Account a = new Account();
			a.Name = 'TD';
			a.Website = 'www.salesforce.com';
			a.BillingCity = 'New York';
			a.BillingPostalCode = '10027';
			accts.add(a);
		}
		return accts;
	}

	static List<Contact> setupContacts(List<Account> accts) {
		List<Contact> cons = new List<Contact>();
		for (Account a : accts) {
			Contact c = new Contact();
			c.FirstName = 'John';
			c.LastName = 'Smith';
			c.Email = 'smith@td.com';
			c.AccountId = a.Id;
			cons.add(c);
		}
		return cons;
	}

	static Contact setupContact(Id acctId) {
		Contact c = new Contact();
		c.FirstName = 'John';
		c.LastName = 'Smith';
		c.Email = 'smith@td.com';
		c.AccountId = acctId;
		return c;
	}

	static Lead setupLead() {
		Lead l = new Lead();
		l.FirstName = 'James';
		l.LastName = 'Doe';
		l.Email = 'jdoe@td.com';
		l.Company = 'TD';
		return l;
	}

	@isTest
	private static void dupeAccountsCreate() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Account_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		Account a = setupAccounts(1)[0];

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(a, insertDML);
		System.assert(sr.isSuccess());
		//System.debug('Account count: ' + [SELECT COUNT() FROM Account]);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Account ac : [SELECT Id FROM Account]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		//System.debug('inserting this many duplicaterecorditems: ' + drisToInsert.size());
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Account', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Account__c FROM DuplicateRecordItem];
		for (DuplicateRecordItem dri : driList) {
			System.assertEquals('Account', dri.Object_Type__c);
		}

		System.assertEquals(1, [SELECT COUNT() FROM DuplicateRecordSet]);

		delete [SELECT Id FROM DuplicateRecordItem LIMIT 1];

		Test.stopTest();

		System.assertEquals(0, [SELECT COUNT() FROM DuplicateRecordSet]);
	}

	@isTest
	private static void dupeAccountsMerge() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Account_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		Account a = setupAccounts(1)[0];

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(a, insertDML);
		System.assert(sr.isSuccess());
		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Account ac : [SELECT Id FROM Account]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Account', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Account__c FROM DuplicateRecordItem];
		for (DuplicateRecordItem dri : driList) {
			System.assertEquals('Account', dri.Object_Type__c);
		}
		List<Account> primary = [SELECT Id FROM Account WHERE Id = :a.Id];
		List<Account> secondaries = [SELECT Id FROM Account WHERE Id != :a.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false); //NOPMD

		Test.stopTest();

		System.assertEquals(0, [SELECT COUNT() FROM DuplicateRecordSet], 'DuplicateRecordSet not deleted');
	}

	@isTest
	private static void dupeAccountsUpdate() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Account_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		List<Account> dupeAccts = setupAccounts(2);

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		List<Database.SaveResult> srList = Database.insert(dupeAccts, insertDML); //NOPMD

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Account ac : [SELECT Id FROM Account]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Account', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Account__c, Created_Date__c, Created_By_Name__c FROM DuplicateRecordItem];

		driList[0].Object_Type__c = null;
		update driList;

		Test.stopTest();

		for (DuplicateRecordItem dri : [SELECT Id, Object_Type__c, Account__c, Created_Date__c, Created_By_Name__c FROM DuplicateRecordItem]) {
			System.assertEquals('Account', dri.Object_Type__c);
			System.assertNotEquals(null, dri.Created_Date__c);
			System.assertNotEquals(null, dri.Created_By_Name__c);
		}

		System.assertEquals(1, [SELECT COUNT() FROM DuplicateRecordSet], 'DuplicateRecordSet deleted');
		System.assertEquals(3, [SELECT COUNT() FROM DuplicateRecordItem], 'Three dupes not caught');
	}

	/* CONTACTS **************************** */

	@isTest
	private static void dupeContactsCreate() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Contact_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		Account a = [SELECT Id FROM Account][0];
		Contact c = setupContact(a.Id);

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(c, insertDML);
		System.assert(sr.isSuccess());
		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Contact cc : [SELECT Id FROM Contact]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = cc.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Contact', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Contact__c FROM DuplicateRecordItem];
		for (DuplicateRecordItem dri : driList) {
			System.assertEquals('Contact', dri.Object_Type__c);
		}

		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM DuplicateRecordSet]);
	}

	@isTest
	private static void dupeContactsMerge() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Contact_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		Account a = [SELECT Id FROM Account][0];
		Contact c = setupContact(a.Id);

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(c, insertDML);
		System.assert(sr.isSuccess());
		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Contact cc : [SELECT Id FROM Contact]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = cc.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Contact', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Contact__c FROM DuplicateRecordItem];
		for (DuplicateRecordItem dri : driList) {
			System.assertEquals('Contact', dri.Object_Type__c);
		}
		List<Contact> primary = [SELECT Id FROM Contact WHERE Id = :c.Id];
		List<Contact> secondaries = [SELECT Id FROM Contact WHERE Id != :c.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false); //NOPMD
		Test.stopTest();

		System.assertEquals(0, [SELECT COUNT() FROM DuplicateRecordSet], 'DuplicateRecordSet not deleted');
	}

	/* LEADS **************************** */

	@isTest
	private static void dupeLeadsCreate() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Lead_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		Lead l = setupLead();

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(l, insertDML);
		System.assert(sr.isSuccess());
		//System.debug('Lead count: ' + [SELECT COUNT() FROM Lead]);

		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Lead ac : [SELECT Id FROM Lead]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		//System.debug('inserting this many duplicaterecorditems: ' + drisToInsert.size());
		insert drisToInsert;

		//System.debug('We now have ' + [SELECT COUNT() FROM DuplicateRecordItem] + ' duplicaterecorditems');
		//System.debug('We now have ' + [SELECT COUNT() FROM DuplicateRecordSet] + ' duplicaterecordsets');
		//System.debug('We now have ' + [SELECT RecordCount FROM DuplicateRecordSet] + ' records in our record set');

		Test.stopTest();

		List<DuplicateRecordSet> drsList = [SELECT Id, RecordCount, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Lead', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Lead__c FROM DuplicateRecordItem];
		for (DuplicateRecordItem dri : driList) {
			System.assertEquals('Lead', dri.Object_Type__c);
		}
	}

	@isTest
	private static void dupeLeadsMerge() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Lead_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		Lead l = setupLead();

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(l, insertDML);
		System.assert(sr.isSuccess());
		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Lead ac : [SELECT Id FROM Lead]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Lead', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Lead__c FROM DuplicateRecordItem];
		for (DuplicateRecordItem dri : driList) {
			System.assertEquals('Lead', dri.Object_Type__c);
		}
		List<Lead> primary = [SELECT Id FROM Lead WHERE Id = :l.Id];
		List<Lead> secondaries = [SELECT Id FROM Lead WHERE Id != :l.Id];
		Database.MergeResult[] results = Database.merge(primary[0], secondaries, false); //NOPMD

		Test.stopTest();

		System.assertEquals(0, [SELECT COUNT() FROM DuplicateRecordSet], 'DuplicateRecordSet not deleted');
	}

	@isTest
	private static void dupeLeadsMergeFuture() {
		DuplicateRule dR = [SELECT Id FROM DuplicateRule WHERE DeveloperName = 'Standard_Lead_Duplicate_Rule' LIMIT 1];
		DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
		insert dupRS;

		Test.startTest();
		Lead l = setupLead();

		Database.DMLOptions insertDML = new Database.DMLOptions();
		insertDML.DuplicateRuleHeader.AllowSave = true;
		Database.SaveResult sr = Database.insert(l, insertDML);
		System.assert(sr.isSuccess());
		List<DuplicateRecordItem> drisToInsert = new List<DuplicateRecordItem>();
		for (Lead ac : [SELECT Id FROM Lead]) {
			DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId = ac.id);
			drisToInsert.add(dup);
		}
		insert drisToInsert;

		List<DuplicateRecordSet> drsList = [SELECT Id, Object_Type__c FROM DuplicateRecordSet];
		System.assertEquals(1, drsList.size(), 'Should be one DuplicateRecordSet');
		System.assertEquals('Lead', drsList[0].Object_Type__c); // can't know this because we are creating it manually

		List<DuplicateRecordItem> driList = [SELECT Id, Object_Type__c, Lead__c FROM DuplicateRecordItem];
		for (DuplicateRecordItem dri : driList) {
			System.assertEquals('Lead', dri.Object_Type__c);
		}
		futureMergeLeads(l.Id);

		Test.stopTest();

		System.assertEquals(0, [SELECT COUNT() FROM DuplicateRecordSet], 'DuplicateRecordSet not deleted');
	}

	/**
	 * We have a future method to allow us to run our trigger handler in future context
	 *
	 * @param lId Lead Id to keep when merging leads in test class
	 */
	@future
	private static void futureMergeLeads(Id lId) {
		List<Lead> primary = [SELECT Id FROM Lead WHERE Id = :lId];
		List<Lead> secondaries = [SELECT Id FROM Lead WHERE Id != :lId];
		Database.merge(primary[0], secondaries, false);
	}
}