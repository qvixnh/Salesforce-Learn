/**
 * クラス名：   LWC_UpdateStudentCtrl.cls
 * クラス概要： Update Student Controller
 * @created： 2023/01/10 + Nguyen Vinh
 * @modified: 
 */
public with sharing class LWC_UpdateStudentCtrl {
    /**
     * updateStudentRec
     * @param    :  Student__c student
     *              String  sFirstName
     *              String sLastName
     *              String sClassId
     *              Boolean sGender
     *              String sAddress
     *              Date sBirthdate
     * @return   : String 
     * @created  : 2023/01/11 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static String updateStudentRec(Student__c student, String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
        try {
            student.Name = sFirstName + ' ' + sLastName;
            student.Firstname__c = sFirstName;
            student.Lastname__c = slastName;
            student.Class_look__c = sClassId ;
            student.Birthday__c= sBirthdate;
            student.Gender__c= sGender;
            student.Address__c = sAddress;
            update student;
            return student.Id;
        } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
        }
    }
}