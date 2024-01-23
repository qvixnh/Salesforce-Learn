/**
 * クラス名：   CMP_SearchStudentCtrl.cls
 * クラス概要： Search Student Controller
 * @created： 2023/12/26 + Nguyen Vinh
 * @modified: 
 */
public with sharing class CMP_SearchStudentCtrl {
    /**
     * getClassOptions
     * @param    : 
     * @return   : List<Class__c> 
     * @created  : 2023/12/26 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static List<Class__c> getClassOptions() {
        List<Class__c> classList = new List<Class__c>();
        try {
            classList = [SELECT 
                            Id
                            , Name
                            , NumberOfStudent__c
                        FROM Class__c 
                        ORDER BY Name];
            return classList;
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting classes: ' + e.getMessage());
        }
    }
    /**
     * getStudentDetails
     * @param    : String studentId
     * @return   : Student__c 
     * @created  : 2023/12/26 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static Student__c getStudentDetails(String studentId) {
        Student__c studentDetails = new Student__c();
        try {
            studentDetails = [SELECT 
                                Id
                                , Student_Code__c
                                , Firstname__c
                                , Lastname__c
                                , selected__c
                                , Class__c
                                , Class_look__c

                                , Class__r.Name
                                , Gender__c
                                , Birthday__c
                                , Address__c
                            FROM Student__c 
                            WHERE Id = :studentId];
            return studentDetails;
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting student details: ' + e.getMessage());
        }
    }
    /**
     * getRecords
     * @param    :  Integer pageSize
     *              String classId
     *              Integer gender
     *              String searchName
     *              String searchCode
     *              Integer day
     *              Integer month
     *              Integer year , String birthdate, String orderField, String orderType
     * @return   : PaginationResult 
     * @created  : 2023/12/28 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static PaginationResult getRecords(Integer pageSize, String classId,  Integer gender,String searchName, String searchCode, Integer day, Integer month, Integer year , String birthdate, String orderField, String orderType) {
        try {
            List<Student__c> records = getStudents(classId, gender, searchName, searchCode, day, month, year, birthdate, orderField, orderType);
        
            if (!records.isEmpty()) {
                Integer totalRecords = records.size();
                Integer totalPage = calTotalPage(totalRecords, pageSize);
                return new PaginationResult(records, totalRecords, totalPage);
            }
            return new PaginationResult(new List<Student__c>(), 0, 1);
        } catch (Exception e) { 
            throw new CustomException('An error occurred: ' + e.getMessage());
        }
        
    }
    /**
     * calTotalPage
     * @param    :  Integer  totalRecords
     *              Integer pageSize
     * @return   : Integer 
     * @created  : 2023/12/28 + Nguyen Vinh
     * @modified : 
     */
    private static Integer calTotalPage(Integer  totalRecords, Integer pageSize){
        Decimal num1 = totalRecords != null && totalRecords > 0 ? totalRecords : 0;
        Decimal num2 = pageSize != null && pageSize > 0 ? pageSize : 1;
        return Math.ceil(num1/num2).intValue();
    }
    
    /**
     * deleteSelectedStudentsCtrl
     * @param    : List<String> studentIds
     * @return   : String 
     * @created  : 2023/12/29 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static String deleteSelectedStudentsCtrl(List<String> studentIds) {
        try {
            List<Student__c> studentsToDelete = [SELECT Id FROM Student__c WHERE Id IN :studentIds];
            if (!studentsToDelete.isEmpty()) {
                delete studentsToDelete;
                return 'Success';
            } else {
                return 'No records found for deletion';
            }
        } catch (Exception e) {
            return 'Error';
        }
    }

    
    /**
     * deleteStudentRecord
     * @param    : String studentId
     * @return   : String 
     * @created  : 2023/12/29 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static String deleteStudentRecord(String studentId) {
        try {
            if(studentId==''){
                return 'student Id to delete can not be blank';
            }
            Student__c studentToDelete = 
            [SELECT Id
            , Firstname__c
            , Student_Code__c
            FROM Student__c 
            WHERE Id = :studentId ];
            
            if (studentToDelete != null) {
                delete studentToDelete;
                return 'Success';
            } else {
                return 'Student record not found';
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    /**
     * getStudents
     * @param    :  String classId
     *              Integer gender
     *              String searchName
     *              String searchCode
     *              Integer day
     *              Integer month
     *              Integer year
     *              String birthdate
     *              String orderField
     *              String orderType
     * @return   : List<Student__c> 
     * @created  : 2023/12/29 + Nguyen Vinh
     * @modified : 
     */
    public static List<Student__c> getStudents(String classId, Integer gender, String searchName, String searchCode, Integer day, Integer month, Integer year, String birthdate, String orderField, String orderType) {
        try {
            List<String> selectedFields = new List<String>{
                'Id', 'Student_Code__c', 'Firstname__c', 'Lastname__c', 'selected__c',
                'Class__r.Name', 'Gender__c', 'Birthday__c', 'Address__c'
            };
            String queryString = 'SELECT ' + String.join(selectedFields, ', ') + ' FROM Student__c';
            List<String> conditions = new List<String>();
        
            if (!String.isBlank(searchName)) {
                conditions.add('Firstname__c LIKE \'%' + searchName + '%\'');
            }
            if (!String.isBlank(searchCode)) {
                conditions.add('Student_Code__c LIKE \'%' + searchCode + '%\'');
            }
            if (classId != null && classId != 'null') {
                conditions.add('Class__c = \'' + classId + '\'');
            }
            if (gender == 1 || gender == 0 ) {
                conditions.add('Gender__c = ' + (gender == 1 ? 'True' : 'False'));
            }
            if (!String.isBlank(birthdate)) {
                conditions.add('Birthday__c = ' + birthdate);
            }
            if (day > 0) {
                conditions.add('DAY_IN_MONTH(Birthday__c) = ' + day);
            }
            if (month > 0) {
                conditions.add('CALENDAR_MONTH(Birthday__c) = ' + month);
            }
            if (year > 0) {
                conditions.add('CALENDAR_YEAR(Birthday__c) = ' + year);
            }
            queryString += !conditions.isEmpty() ? ' WHERE ' + String.join(conditions, ' AND ') + ' ORDER BY ' + orderField + ' ' + orderType :' ORDER BY ' + orderField + ' ' + orderType;
            return Database.query(queryString);
        } catch (Exception e) {
            throw new CustomException('An error occurred in getStudents: ' + e.getMessage());
        }
    }
    /**
     * クラス名：   PaginationResult
     * クラス概要： pagination result Dto
     * @created： 2023/12/28 + Nguyen Vinh
     * @modified: 
     */
    public class PaginationResult {
        @AuraEnabled
        public List<Student__c> records;
        @AuraEnabled
        public Integer totalRecords;
        @AuraEnabled
        public Integer totalPage;
        public PaginationResult(List<Student__c> records, Integer totalRecords,Integer totalPage) {
            this.records = records;
            this.totalRecords = totalRecords;
            this.totalPage = totalPage;
        }
    }
    public  class  CustomException extends Exception {
        
    }
}