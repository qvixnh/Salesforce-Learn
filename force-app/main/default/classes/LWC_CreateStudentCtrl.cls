public with sharing class LWC_CreateStudentCtrl {
    @AuraEnabled
    public static String createStudentRec(String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
        try {
            Student__c student = new Student__c();
            student.Name = sFirstName + ' ' + sLastName;
            student.First_Name__c = sFirstName;
            student.Last_Name__c = sLastName;
            student.Class__c = sClassId ;
            student.Birthdate__c= sBirthdate;
            student.Gender__c= sGender;
            student.Address__c = sAddress;
            insert student;
            return student.Student_Code__c;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}