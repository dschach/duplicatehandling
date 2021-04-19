/**
 * @File Name          : DuplicateRecordItemTrigger.trigger
 * @Description        :
 * @Author             : David Schach
 * @Group              :
 * @Last Modified By   : David Schach
 * @Last Modified On   : 04/19/2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    04/19/2021   David Schach     Initial Version
**/
trigger DuplicateRecordItemTrigger on DuplicateRecordItem (before insert, before update, after insert, after update, after delete) {
	System.debug('IN DUPLICATE RECORD ITEM TRIGGER');
	DuplicateRecordItemTriggerHandler.handleTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}