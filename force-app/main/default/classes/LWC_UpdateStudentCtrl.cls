public with sharing class LWC_UpdateStudentCtrl {
    //1101
    @AuraEnabled
    public static String updateStudentRec(Student__c student, String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
        try {
            student.Name = sFirstName + ' ' + sLastName;
            student.First_Name__c = sFirstName;
            student.Last_Name__c = slastName;
            student.Class__c = sClassId ;
            student.Birthdate__c= sBirthdate;
            student.Gender__c= sGender;
            student.Address__c = sAddress;
            update student;
            return student.Student_Code__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}