/**
 * クラス名：   CMP_CreateStudentCtrl.cls
 * クラス概要： create student
 * @created： 2023/12/26 + Nguyen Vinh
 * @modified: 
 */
public class CMP_CreateStudentCtrl {
    /**
     * createStudentRec
     * @param    : String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate
     * @return   : String 
     * @created  : 2023/12/26 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static String createStudentRec(String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
        try {
            Student__c student = new Student__c();
            student.Name = sFirstName + ' ' + sLastName;
            student.First_Name__c = sFirstName;
            student.Last_Name__c = slastName;
            student.Class__c = sClassId ;
            student.Birthdate__c= sBirthdate;
            student.Gender__c= sGender;
            student.Address__c = sAddress;
            insert student;
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
            return[SELECT 
                    Id
                    , Class_Code__c
                    , Class_Name__c
                    , Number_Of_Student__c 
                    FROM Class__c 
                    ORDER BY Class_Code__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
