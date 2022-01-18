export default [
    {
        "title": "Home",
        "fileName": "index.html",
        "text": "Home Project Home Use the apexdox.homePagePath  setting to point to an HTML file that contains details about your project. The body of the HTML will show up here instead of this default!"
    },
    {
        "title": "DuplicateRecordItemTriggerHandler",
        "fileName": "DuplicateRecordItemTriggerHandler.html",
        "text": "DuplicateRecordItemTriggerHandler Trigger Handler for DuplicateRecordItem Signature public without sharing class DuplicateRecordItemTriggerHandler extends TriggerHandler See DuplicateRecordHandlersTest David Schach4/19/2021 DuplicateRecordItemTriggerHandler Properties Name Signature newRecords private List<DuplicateRecordItem> newRecords newRecordsMap private Map<Id, DuplicateRecordItem> newRecordsMap oldRecords private List<DuplicateRecordItem> oldRecords oldRecordsMap private Map<Id, DuplicateRecordItem> oldRecordsMap DuplicateRecordItemTriggerHandler Constructors DuplicateRecordItemTriggerHandler() Constructor using super() method for faster performance We cast all four trigger collections DuplicateRecordItemTriggerHandler() Constructor using super() method for faster performance We cast all four trigger collections Signature public DuplicateRecordItemTriggerHandler() DuplicateRecordItemTriggerHandler Methods afterDelete() afterInsert() afterUpdate() assortDuplicateItems(newRecords) beforeInsert() beforeUpdate() handleAccounts(newAccounts, recordIDs) handleContacts(newContacts, recordIDs) Handle duplicate Contacts handleLeads(newLeads, recordIDs) Handle duplicate Leads updateDuplicateRecordSet(newRecords) When we update DRIs, update the parent DuplicateRecordSet records afterDelete() Signature public override void afterDelete() afterInsert() Signature public override void afterInsert() afterUpdate() Signature public override void afterUpdate() assortDuplicateItems(newRecords) Signature private static void assortDuplicateItems(List<DuplicateRecordItem> newRecords) beforeInsert() Signature public override void beforeInsert() beforeUpdate() Signature public override void beforeUpdate() handleAccounts(newAccounts, recordIDs) Signature private static void handleAccounts(List<DuplicateRecordItem> newAccounts, Set<Id> recordIDs) Parameters newAccounts Type: List<DuplicateRecordItem> DuplicateRecordItems - we will find Accounts from these recordIDs Type: Set<Id> The recordIDs for the DuplicateRecordItems handleContacts(newContacts, recordIDs) Handle duplicate Contacts Signature private static void handleContacts(List<DuplicateRecordItem> newContacts, Set<Id> recordIDs) Parameters newContacts Type: List<DuplicateRecordItem> DuplicateRecordItems - we will find Contacts from these recordIDs Type: Set<Id> the recordIDs for the DuplicateRecordItems handleLeads(newLeads, recordIDs) Handle duplicate Leads Signature private static void handleLeads(List<DuplicateRecordItem> newLeads, Set<Id> recordIDs) Parameters newContacts DuplicateRecordItems - we will find Leads from these recordIDs Type: Set<Id> the recordIDs for the DuplicateRecordItems updateDuplicateRecordSet(newRecords) When we update DRIs, update the parent DuplicateRecordSet records Signature private static void updateDuplicateRecordSet(List<DuplicateRecordItem> newRecords) Parameters newRecords Type: List<DuplicateRecordItem> Duplicate Record Items"
    },
    {
        "title": "DuplicateRecordSetTriggerHandler",
        "fileName": "DuplicateRecordSetTriggerHandler.html",
        "text": "DuplicateRecordSetTriggerHandler Trigger Handler for DuplicateRecordSet Signature public without sharing class DuplicateRecordSetTriggerHandler extends TriggerHandler See DuplicateRecordHandlersTest David Schach4/19/2021 DuplicateRecordSetTriggerHandler Properties Name Signature newRecords private List<DuplicateRecordSet> newRecords DuplicateRecordSetTriggerHandler Constructors DuplicateRecordSetTriggerHandler() Constructor using super() method for faster performance We cast all four trigger collections - but don't use most, so they are commented DuplicateRecordSetTriggerHandler() Constructor using super() method for faster performance We cast all four trigger collections - but don't use most, so they are commented Signature public DuplicateRecordSetTriggerHandler() DuplicateRecordSetTriggerHandler Methods afterUpdate() Override afterUpdate. We don't use any other contexts deleteSingleRecordSets(candidatesToDelete) Future delete all single-member record sets findSingleRecordSets(newRecords) We find all sets with 1 item, and then we pass those to the delete methods afterUpdate() Override afterUpdate. We don't use any other contexts Signature public override void afterUpdate() deleteSingleRecordSets(candidatesToDelete) Future delete all single-member record sets Signature @future public static void deleteSingleRecordSets(Set<Id> candidatesToDelete) Parameters candidatesToDelete Type: Set<Id> Ids of all record sets we want to delete(in future context, for performance) findSingleRecordSets(newRecords) We find all sets with 1 item, and then we pass those to the delete methods Signature public static void findSingleRecordSets(List<DuplicateRecordSet> newRecords) Parameters newRecords Type: List<DuplicateRecordSet> Trigger.new"
    },
    {
        "title": "TriggerHandler",
        "fileName": "TriggerHandler.html",
        "text": "TriggerHandler Trigger Handler virtual class as base for all trigger handlers Signature public virtual class TriggerHandler See License , GitHub Kevin O'Hara David Schach2013 TriggerHandler Properties Name Signature Description bypassedHandlers private static Set<String> bypassedHandlers All bypassed handlers errorOutsideTriggerContext private static String errorOutsideTriggerContext Error text - assumes English for debug logs globalBypass private static Boolean globalBypass true  if we bypass all triggers without checking the contents of bypassedHandlers handlerName private String handlerName The name of this handler. Set by getHandlerName() isTriggerExecuting private Boolean isTriggerExecuting Is this class executing in trigger context? loopCountMap private static Map<String, LoopCount> loopCountMap static map of handlerName , times run()  was invoked showDebug private static Boolean showDebug true  if we include a debug statement for trigger entry and exit showLimits private static Boolean showLimits true  if we include a debug statement for limits triggerEvent private System.TriggerOperation triggerEvent the current triggerEvent of the trigger, overridable in tests TriggerHandler Constructors TriggerHandler() Basic constructor TriggerHandler(handlerName) Constructor with handler name to improve performance TriggerHandler() Basic constructor Signature public TriggerHandler() TriggerHandler(handlerName) Constructor with handler name to improve performance Signature public TriggerHandler(String handlerName) Parameters handlerName Type: String The name of the handler Author David Schach TriggerHandler Methods addToLoopCount() increment the loop count afterDelete() Virtual method for the implementing class to override afterInsert() Virtual method for the implementing class to override afterUndelete() Virtual method for the implementing class to override afterUpdate() Virtual method for the implementing class to override beforeDelete() Virtual method for the implementing class to override beforeInsert() Virtual method for the implementing class to override beforeUpdate() Virtual method for the implementing class to override bypass(handlerName) bypass by string, e.g. TriggerHandler.bypass('AccountTriggerHandler') bypass(handlerNames) bypass by list, e.g. TriggerHandler.bypass(listOfHandlerStrings) bypassAll() bypass all handlers(clear bypassedHandlers to prevent confusion) bypassList() return a list of the bypassed handlers clearAllBypasses() clear all bypasses - by clearing the global bypass and by clearing the list of bypassed handlers clearBypass(handlerName) bypass a specific handler clearBypass(handlersNames) bypass a list of handlers clearBypassList() clear the entire bypass list, but keep the global bypass flag intact This is useful for resetting the list of handlers to bypass while maintaining global bypassing clearGlobalBypass() clear only the global bypass flag, leaving the list of bypassed handlers intact This is useful for keeping a base set of bypassed handlers intact for an entire operation clearMaxLoopCount() Removes the limit for the number of times we allow this class to run getHandlerName() Get the name of the current handler. This can be set by using the constructor with the string parameter to improve performance getLoopCount(handlerName) return the current loop count isBypassed(handlerName) a handler is considered bypassed if it was bypassed, or all handlers have been bypassed run() main method that will be called during execution  See the sample trigger for the best way to set up your handler setBypass(handlerName, desiredValue) Set bypass status to a specific value. Eliminates the need to know the current bypass status setMaxLoopCount(max) setMaxLoopCount description setTriggerContext() Base method called by constructor to set the current context setTriggerContext(opType, testMode) Set the current trigger context based on the System.TriggerOperation If we are not in a trigger context, then we set isTriggerExecuting to false showDebug() Called in the trigger to force the class to debug trigger entry and exit with context. This is only shown in Test context, to speed org performance showDebug(enabled) Called in the trigger to force the class to debug trigger entry and exit with context. Set to true to show entry and exit. This is only shown in Test context, to speed org performance showLimits() Called in the trigger to force the class to debug query limits when it runs showLimits(enabled) Called in the trigger to force the class to debug limits when it runs. Set to true to show limits. validateRun() Make sure this trigger should continue to run Returning false  causes trigger handler to exit addToLoopCount() increment the loop count Signature private void addToLoopCount() Exceptions TriggerHandlerException See TriggerHandler.TriggerHandlerException afterDelete() Virtual method for the implementing class to override Signature protected virtual void afterDelete() afterInsert() Virtual method for the implementing class to override Signature protected virtual void afterInsert() afterUndelete() Virtual method for the implementing class to override Signature protected virtual void afterUndelete() afterUpdate() Virtual method for the implementing class to override Signature protected virtual void afterUpdate() beforeDelete() Virtual method for the implementing class to override Signature protected virtual void beforeDelete() beforeInsert() Virtual method for the implementing class to override Signature protected virtual void beforeInsert() beforeUpdate() Virtual method for the implementing class to override Signature protected virtual void beforeUpdate() bypass(handlerName) bypass by string, e.g. TriggerHandler.bypass('AccountTriggerHandler') Signature public static void bypass(String handlerName) Parameters handlerName Type: String Name of the handler to be bypassed Example TriggerHandler.bypass('AccountSampleTriggerHandler') bypass(handlerNames) bypass by list, e.g. TriggerHandler.bypass(listOfHandlerStrings) Signature public static void bypass(List<String> handlerNames) Parameters handlerNames Type: List<String> List of handlernames bypassAll() bypass all handlers(clear bypassedHandlers to prevent confusion) Signature public static void bypassAll() bypassList() return a list of the bypassed handlers Signature public static List<String> bypassList() Returns List<String> Example List<String> bypassedHandlers = TriggerHandler.bypassList(); clearAllBypasses() clear all bypasses - by clearing the global bypass and by clearing the list of bypassed handlers Signature public static void clearAllBypasses() Example TriggerHandler.clearAllBypasses(); clearBypass(handlerName) bypass a specific handler Signature public static void clearBypass(String handlerName) Parameters handlerName Type: String The class name to be bypassed Example TriggerHandler.clearBypass('AccountSampleTriggerHandler') clearBypass(handlersNames) bypass a list of handlers Signature public static void clearBypass(List<String> handlersNames) Parameters handlersNames Type: List<String> Example List<String> classList = ['AccountTriggerHandler','ContactTriggerHandler']; TriggerHandler.clearBypass(classList); clearBypassList() clear the entire bypass list, but keep the global bypass flag intact This is useful for resetting the list of handlers to bypass while maintaining global bypassing Signature public static void clearBypassList() Example TriggerHandler.clearBypassList(); clearGlobalBypass() clear only the global bypass flag, leaving the list of bypassed handlers intact This is useful for keeping a base set of bypassed handlers intact for an entire operation Signature public static void clearGlobalBypass() Example TriggerHandler.clearGlobalBypass(); clearMaxLoopCount() Removes the limit for the number of times we allow this class to run Signature public void clearMaxLoopCount() getHandlerName() Get the name of the current handler. This can be set by using the constructor with the string parameter to improve performance Signature private String getHandlerName() Returns String  handlerName See TriggerHandler.handlerName getLoopCount(handlerName) return the current loop count Signature public static Integer getLoopCount(String handlerName) Parameters handlerName Type: String The handler class to check for the current loop count Returns Integer isBypassed(handlerName) a handler is considered bypassed if it was bypassed, or all handlers have been bypassed Signature public static Boolean isBypassed(String handlerName) Parameters handlerName Type: String The class name of the handler we are checking is bypassed Returns Boolean  Is this handler bypassed? Example TriggerHandler.isBypassed('AccountTriggerHandler'); run() main method that will be called during execution  See the sample trigger for the best way to set up your handler Signature public void run() Author Kevin O'Hara, David Schach Example new AccountSampleTriggerHandler().run(); setBypass(handlerName, desiredValue) Set bypass status to a specific value. Eliminates the need to know the current bypass status Signature public static void setBypass(String handlerName, Boolean desiredValue) Parameters handlerName Type: String The name of the TriggerHandler class desiredValue Type: Boolean true  to bypass, and false  to run the handler Example TriggerHandler.setBypass('AccountTriggerHandler', false); setMaxLoopCount(max) setMaxLoopCount description Signature public void setMaxLoopCount(Integer max) Parameters max Type: Integer max description Author David Schach Example TriggerHandler.setMaxLoopCount(5); setTriggerContext() Base method called by constructor to set the current context Signature private void setTriggerContext() setTriggerContext(opType, testMode) Set the current trigger context based on the System.TriggerOperation If we are not in a trigger context, then we set isTriggerExecuting to false Signature private void setTriggerContext(System.TriggerOperation opType, Boolean testMode) Parameters opType Type: System.TriggerOperation The operation type - set automatically by the system testMode Type: Boolean Only used in test methods to force certain contexts See TriggerHandler.isTriggerExecuting showDebug() Called in the trigger to force the class to debug trigger entry and exit with context. This is only shown in Test context, to speed org performance Signature public static void showDebug() Example new AccountSampleTriggerHandler.showDebug().showLimits().run(); showDebug(enabled) Called in the trigger to force the class to debug trigger entry and exit with context. Set to true to show entry and exit. This is only shown in Test context, to speed org performance Signature public static void showDebug(Boolean enabled) Parameters enabled Type: Boolean true to enable; false to disable See TriggerHandler.showDebug showLimits() Called in the trigger to force the class to debug query limits when it runs Signature public static void showLimits() Example new AccountSampleTriggerHandler.showLimits().run(); showLimits(enabled) Called in the trigger to force the class to debug limits when it runs. Set to true to show limits. Signature public static void showLimits(Boolean enabled) Parameters enabled Type: Boolean true to enable; false to disable See TriggerHandler.showLimits validateRun() Make sure this trigger should continue to run Returning false  causes trigger handler to exit Signature private Boolean validateRun() Returns Boolean  is the run valid? Exceptions TriggerHandlerException See TriggerHandler.TriggerHandlerException TriggerHandler.LoopCount inner class for managing the loop count per handler Signature @TestVisible private class LoopCount TriggerHandler.LoopCount Properties Name Signature count private Integer count max private Integer max TriggerHandler.LoopCount Constructors LoopCount() Default loop count to 5 LoopCount(max) Constructor with specified max loops LoopCount() Default loop count to 5 Signature public LoopCount() LoopCount(max) Constructor with specified max loops Signature public LoopCount(Integer max) Parameters max Type: Integer Max number of loops allowed TriggerHandler.LoopCount Methods exceeded() Determines if we're about to exceed the loop count. getCount() Returns the current loop count. getMax() Returns the max loop count. increment() Increment the internal counter returning the results of this.exceeded(). setMax(max) Sets the max loop size exceeded() Determines if we're about to exceed the loop count. Signature public Boolean exceeded() Returns Boolean  true if less than 0 or more than max. getCount() Returns the current loop count. Signature public Integer getCount() Returns Integer  current loop count. getMax() Returns the max loop count. Signature public Integer getMax() Returns Integer  max loop count. increment() Increment the internal counter returning the results of this.exceeded(). Signature public Boolean increment() Returns Boolean  true if count will exceed max count or is less than 0. setMax(max) Sets the max loop size Signature public void setMax(Integer max) Parameters max Type: Integer The integer to set max to. TriggerHandler.TriggerHandlerException Exception class Signature public class TriggerHandlerException extends Exception"
    },
    {
        "title": "DuplicateRecordHandlersTest",
        "fileName": "DuplicateRecordHandlersTest.html",
        "text": "DuplicateRecordHandlersTest Tests for DuplicateRecord trigger handlers Signature @isTest private class DuplicateRecordHandlersTest See DuplicateRecordItemTriggerHandler , DuplicateRecordSetTriggerHandler David Schach11/13/2019 DuplicateRecordHandlersTest Methods dupeAccountsCreate() dupeAccountsMerge() dupeAccountsUpdate() dupeContactsCreate() dupeContactsMerge() dupeLeadsCreate() dupeLeadsMerge() makeData() setupAccounts(acctCount) setupContact(acctId) setupContacts(accts) setupLead() dupeAccountsCreate() Signature @isTest private static void dupeAccountsCreate() dupeAccountsMerge() Signature @isTest private static void dupeAccountsMerge() dupeAccountsUpdate() Signature @isTest private static void dupeAccountsUpdate() dupeContactsCreate() Signature @isTest private static void dupeContactsCreate() dupeContactsMerge() Signature @isTest private static void dupeContactsMerge() dupeLeadsCreate() Signature @isTest private static void dupeLeadsCreate() dupeLeadsMerge() Signature @isTest private static void dupeLeadsMerge() makeData() Signature @TestSetup static void makeData() setupAccounts(acctCount) Signature static List<Account> setupAccounts(Integer acctCount) setupContact(acctId) Signature static Contact setupContact(Id acctId) setupContacts(accts) Signature static List<Contact> setupContacts(List<Account> accts) setupLead() Signature static Lead setupLead()"
    },
    {
        "title": "TriggerHandlerTest",
        "fileName": "TriggerHandlerTest.html",
        "text": "TriggerHandlerTest Test class for base TriggerHandler class Signature @isTest private class TriggerHandlerTest See GitHub Kevin O'Hara David Schach2013 TriggerHandlerTest Properties Name Signature handler private static TriggerHandlerTest.TestHandler handler lastMethodCalled private static String lastMethodCalled TriggerHandlerTest Methods afterDeleteMode() afterInsertMode() afterUndeleteMode() afterUpdateMode() assertTestHandlerName() ensure that the current handler name is as expected beforeDeleteMode() beforeInsertMode() beforeUpdateMode() resetTest() testAfterDelete() testAfterInsert() testAfterUndelete() testAfterUpdate() testBeforeDelete() testBeforeInsert() testBeforeInsertWithLimits() Test and show limits and debug testBeforeUpdate() testBypassAPI() test bypass api testConstructorWithParameter() testConstructorWithParametersAndBypass() testLoopCount() instance method tests testLoopCountClass() testNonTriggerContext() testOutsideTrigger() call from outside trigger testVirtualMethods() test virtual methods afterDeleteMode() Signature private static void afterDeleteMode() afterInsertMode() Signature private static void afterInsertMode() afterUndeleteMode() Signature private static void afterUndeleteMode() afterUpdateMode() Signature private static void afterUpdateMode() assertTestHandlerName() ensure that the current handler name is as expected Signature private static void assertTestHandlerName() beforeDeleteMode() Signature private static void beforeDeleteMode() beforeInsertMode() Signature private static void beforeInsertMode() beforeUpdateMode() Signature private static void beforeUpdateMode() resetTest() Signature private static void resetTest() testAfterDelete() Signature @isTest private static void testAfterDelete() testAfterInsert() Signature @isTest private static void testAfterInsert() testAfterUndelete() Signature @isTest private static void testAfterUndelete() testAfterUpdate() Signature @isTest private static void testAfterUpdate() testBeforeDelete() Signature @isTest private static void testBeforeDelete() testBeforeInsert() Signature @isTest private static void testBeforeInsert() testBeforeInsertWithLimits() Test and show limits and debug Signature @isTest private static void testBeforeInsertWithLimits() testBeforeUpdate() Signature @isTest private static void testBeforeUpdate() testBypassAPI() test bypass api Signature @isTest private static void testBypassAPI() testConstructorWithParameter() Signature @isTest private static void testConstructorWithParameter() testConstructorWithParametersAndBypass() Signature @isTest private static void testConstructorWithParametersAndBypass() testLoopCount() instance method tests Signature @isTest private static void testLoopCount() testLoopCountClass() Signature @isTest private static void testLoopCountClass() testNonTriggerContext() Signature @isTest private static void testNonTriggerContext() testOutsideTrigger() call from outside trigger Signature @isTest private static void testOutsideTrigger() testVirtualMethods() test virtual methods Signature @isTest private static void testVirtualMethods() TriggerHandlerTest.TestHandler test implementation of the TriggerHandler Signature private class TestHandler extends TriggerHandler TriggerHandlerTest.TestHandler Constructors TestHandler() Invoke constructor TestHandler(handlerName) Override the trigger handler constructor that takes the handler name as a parameter TestHandler() Invoke constructor Signature public TestHandler() TestHandler(handlerName) Override the trigger handler constructor that takes the handler name as a parameter Signature public TestHandler(String handlerName) Parameters handlerName Type: String The handler name to instantiate TriggerHandlerTest.TestHandler Methods afterDelete() afterInsert() afterUndelete() afterUpdate() beforeDelete() beforeInsert() beforeUpdate() afterDelete() Signature public override void afterDelete() afterInsert() Signature public override void afterInsert() afterUndelete() Signature public override void afterUndelete() afterUpdate() Signature public override void afterUpdate() beforeDelete() Signature public override void beforeDelete() beforeInsert() Signature public override void beforeInsert() beforeUpdate() Signature public override void beforeUpdate()"
    }
];
