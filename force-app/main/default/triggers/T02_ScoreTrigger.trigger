trigger T02_ScoreTrigger on Score__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            T02_ScoreTriggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            T02_ScoreTriggerHandler.onAfterUpdate(Trigger.new,Trigger.old);
        }
    }
}