/**
 * クラス名：   CMP_CreateStudentCtrl.cls
 * クラス概要： Create Student Controller
 * @created： 2023/12/26 + Nguyen Vinh
 * @modified: 
 */
public class CMP_CreateStudentCtrl {
    /**
     * createStudentRec
     * @param    : 
     *            String  sFirstName
     *            String sLastName
     *            String sClassId
     *            Boolean sGender
     *            String sAddress
     *            Date sBirthdate
     * @return   : String 
     * @created  : 2023/12/26 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static String createStudentRec(String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
        try {
            Student__c student = new Student__c();
            student.Name = sFirstName + ' ' + sLastName;
            student.Firstname__c = sFirstName;
            student.Lastname__c = slastName;
            student.Class_look__c = sClassId ;
            student.Birthday__c= sBirthdate;
            student.Gender__c= sGender;
            student.Address__c = sAddress;
            System.debug(student);
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
                    , Name
                    , NumberOfStudent__c 
                    FROM Class__c 
                    ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}