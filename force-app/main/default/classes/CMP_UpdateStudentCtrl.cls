/**
 * クラス名：   CMP_UpdateStudentCtrl.cls
 * クラス概要： Update Student Controller
 * @created： 2023/12/26 + Nguyen Vinh
 * @modified: 
 */
public with sharing class CMP_UpdateStudentCtrl {
    /**
    * updateStudentRec
    * @param    :   Student__c student
                    String  sFirstName
                    String sLastName
                    String sClassId
                    Boolean sGender
                    String sAddress
                    Date sBirthdate
    * @return   : String 
    * @created  : 2023/12/26 + Nguyen Vinh
    * @modified : 
    */
   @AuraEnabled
   public static String updateStudentRec(Student__c student, String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
       try {
           student.Name = sFirstName + ' ' + sLastName;
           student.Firstname__c = sFirstName;
           student.Lastname__c = slastName;
           student.Class__c = sClassId ;
           student.Class_look__c = sClassId ;
           student.Birthday__c= sBirthdate;
           student.Gender__c= sGender;
           student.Address__c = sAddress;
           update student;
           return student.id;
           
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
   /**
    * getClasses
    * @param    : 
    * @return   : List<Class__c> 
    * @created  : 2023/12/26 + Nguyen Vinh
    * @modified : 
    */
   @AuraEnabled
   public static List<Class__c>  getClasses(){
       try { 
           return[SELECT Id, Name, NumberOfStudent__c FROM Class__c ORDER BY Name];

       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
}