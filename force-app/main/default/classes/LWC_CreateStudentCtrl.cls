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
    //1101
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
                            , Class_Code__c
                            , Class_Name__c
                            , Number_Of_Student__c
                            , MaxNumber__c
                        FROM Class__c 
                        WHERE Number_Of_Student__c < 100
                        ORDER BY Class_Code__c
                        ];
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred when getting classes: ' + e.getMessage());

    }
        return classList;
    }
}