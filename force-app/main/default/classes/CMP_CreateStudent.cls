public with sharing class CMP_CreateStudent {
    public CMP_CreateStudent() {

    }
    
    @AuraEnabled
    public static void saveStudent(Student__c student) {
        insert student;
    }
}