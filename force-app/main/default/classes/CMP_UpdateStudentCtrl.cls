/**
 * クラス名：   CMP_UpdateStudentCtrl.cls
 * クラス概要： update student
 * @created： 2023/12/26 + Nguyen Vinh
 * @modified: 
 */
public with sharing class CMP_UpdateStudentCtrl {
    /**
    * updateStudentRec
    * @param    : Student__c student, String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate
    * @return   : String 
    * @created  : 2023/12/26 + Nguyen Vinh
    * @modified : 
    */
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
           return[SELECT Id, Class_Code__c, Class_Name__c, Number_Of_Student__c FROM Class__c ORDER BY Class_Code__c];

       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }
}