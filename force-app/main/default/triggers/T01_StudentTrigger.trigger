trigger T01_StudentTrigger on Student__c (after insert,before insert,before update,after update,before delete,after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            T01_StudentTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            T01_StudentTriggerHandler.onBeforeUpdate(Trigger.new);
        }
        if (Trigger.isDelete) {
            T01_StudentTriggerHandler.onBeforeDelete(Trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            T01_StudentTriggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            T01_StudentTriggerHandler.onAfterUpdate(Trigger.new,Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            T01_StudentTriggerHandler.onAfterDelete(Trigger.old);
        }
    }
}