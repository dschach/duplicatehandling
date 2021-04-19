trigger DuplicateRecordSetTrigger on DuplicateRecordSet (after update) {

    DuplicateRecordSetTriggerHandler.handleTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);

}