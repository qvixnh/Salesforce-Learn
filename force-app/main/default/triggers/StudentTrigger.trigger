trigger StudentTrigger on Student__c (before insert,before update) {
	  if (Trigger.isBefore && Trigger.isInsert) {
        StudentTriggerHandler.beforeInsert(Trigger.new);
    }

}