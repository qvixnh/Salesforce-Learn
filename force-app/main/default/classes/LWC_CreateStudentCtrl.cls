/**
 * クラス名：   LWC_CreateStudentCtrl.cls
 * クラス概要： Create Student Controller
 * @created： 2023/01/11 + Nguyen Vinh
 * @modified: 
 */
public with sharing class LWC_CreateStudentCtrl {
     /**
     * createStudentRec
     * @param    :  
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
    public static String createStudentRec(String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
        try {
            Student__c student = new Student__c();
            student.Name = sFirstName + ' ' + sLastName;
            student.Firstname__c = sFirstName;
            student.Lastname__c = sLastName;
            student.Class_look__c = sClassId ;
            student.Birthday__c= sBirthdate;
            student.Gender__c= sGender;
            student.Address__c = sAddress;
            insert student;
            return student.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * getClassOptions
     * @param    : 
     * @return   : List<Class__c> 
     * @created  : 2023/01/10 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled(cacheable=true)
    public static List<Class__c> getClassOptionsToCreate() {
        List<Class__c> classList = new List<Class__c>();
        try {
            classList = [SELECT 
                            Id
                            , Name
                        FROM Class__c 
                        ORDER BY Name
                        ];
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred when getting classes: ' + e.getMessage());

    }
        return classList;
    }
}