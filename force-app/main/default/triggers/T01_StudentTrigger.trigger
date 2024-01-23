trigger T01_StudentTrigger on Student__c (
    after insert
    ,before insert
    ,before update
    ,after update
    ,after delete
    ) {
    // if (Trigger.isAfter && Trigger.isInsert) {
    //     StudentTriggerHandler.afterInsert(Trigger.new);
    // }
    // if (Trigger.isAfter && Trigger.isUpdate) {
    //     StudentTriggerHandler.afterUpdate(Trigger.old,Trigger.new);
    // }
    // if (Trigger.isAfter && Trigger.isDelete) {
    //     StudentTriggerHandler.afterDelete(Trigger.old);
    // }
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            T01_StudentTriggerHandler.onBeforeInsert(Trigger.new);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            T01_StudentTriggerHandler.onAfterInsert(Trigger.new);
        }
    }
    //after insert, Tạo hàm count
    //không 
    // without  sharing
    // onAffterInsser@TestSetup
    // static void 
    // (){
        
    // }
    // priva@TestSetup
    // static void makeData(){
        
    // }
    // count() Student
    // hàm public thì thêm try catch
    //select () hàm ccount SOQL salseforce 
}