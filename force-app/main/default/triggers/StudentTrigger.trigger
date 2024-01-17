trigger StudentTrigger on Student__c (after insert,before insert,before update,after update,after delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        StudentTriggerHandler.afterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        StudentTriggerHandler.afterUpdate(Trigger.old,Trigger.new);
    }
    // if (Trigger.isAfter && Trigger.isDelete) {
    //     StudentTriggerHandler.afterDelete(Trigger.new);
    // }

}