/**
 * クラス名：   LWC_SearchStudentCtrl.cls
 * クラス概要： Search Student Controller
 * @created： 2023/01/10 + Nguyen Vinh
 * @modified: 
 */
public with sharing class LWC_SearchStudentCtrl {
    /**
     * getClassOptions
     * @param    : 
     * @return   : List<Class__c> 
     * @created  : 2023/01/10 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled(cacheable=true)
    public static List<Class__c> getClassOptions() {
        List<Class__c> classList = new List<Class__c>();
        try {
            classList = [SELECT 
                            Id
                            , Name
                            , NumberOfStudent__c
                            , Falcuty__c
                        FROM Class__c 
                        ORDER BY Name];
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting classes: ' + e.getMessage());

    }
        return classList;
    }
    

    /**
     * getStudentsByCondition
     * @param    : String searchConditionJSON
     * @return   : List<Student__c> 
     * @created  : 2023/01/10 + Nguyen Vinh
     * @modified : 2023/01/12 + Nguyen Vinh
     */
    @AuraEnabled
    public static List<Student__c> getStudentsByCondition(String searchConditionJSON) {
        try {
            SearchConditionDTO searchCondition = (SearchConditionDTO) JSON.deserialize(searchConditionJSON, SearchConditionDTO.class);
            List<String> conditions = new List<String>();
            List<String> selectedFields = new List<String>{
                'Id', 'StudentCode__c', 'Name' ,'Firstname__c', 'Lastname__c', 'selected__c','TotalCredit__c','GPAScore__c',
                'Class_look__r.Name', 'Gender__c', 'Birthday__c', 'Address__c'
            };
            String queryString = 'SELECT ' + String.join(selectedFields, ', ') + ' FROM Student__c';

            if (!String.isBlank(searchCondition.searchName)) {
                conditions.add('Name LIKE \'%' + searchCondition.searchName + '%\'');
            }
            if (!String.isBlank(searchCondition.searchCode)) {
                conditions.add('StudentCode__c LIKE \'%' + searchCondition.searchCode + '%\'');
            }
            if (searchCondition.classId != null && searchCondition.classId != 'null' && !String.isBlank(searchCondition.classId)) {
                conditions.add('Class_look__c = \'' + searchCondition.classId + '\'');
            }
            if (searchCondition.gender == 1 || searchCondition.gender == 0) {
                conditions.add('Gender__c = ' + (searchCondition.gender == 1 ? 'True' : 'False'));
            }
            if (!String.isBlank(searchCondition.birthdate)) {
                conditions.add('Birthday__c = ' + searchCondition.birthdate);
            }
            if (searchCondition.day > 0) {
                conditions.add('DAY_IN_MONTH(Birthday__c) = ' + searchCondition.day);
            }
            if (searchCondition.month > 0) {
                conditions.add('CALENDAR_MONTH(Birthday__c) = ' + searchCondition.month);
            }
            if (searchCondition.year > 0) {
                conditions.add('CALENDAR_YEAR(Birthday__c) = ' + searchCondition.year);
            }
            queryString += !conditions.isEmpty() ? ' WHERE ' + String.join(conditions, ' AND ')  : '';
            queryString +=  ' ORDER BY StudentCode__c DESC';
            return Database.query(queryString);
        } catch (Exception e) {
            throw new CustomException('An error occurred in getStudents: ' + e.getMessage());
        }
    }
    /**
     * deleteSelectedStudentsCtrl
     * @param    : 
     * @return   : void 
     * @created  : 2023/01/11 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static void deleteSelectedStudentsCtrl(List<Id> studentIds) {
        try {
            List<Student__c> studentsToDelete = [SELECT Id FROM Student__c WHERE Id IN :studentIds];
            delete studentsToDelete;
        } catch (Exception e) {
            throw new CustomException('Error deleting selected students: ' + e.getMessage());
        }
    }
    /**
     * deleteStudentRecord
     * @param    : Id studentId
     * @return   : void 
     * @created  : 2023/01/11 + Nguyen Vinh
     * @modified : 
     */
    @AuraEnabled
    public static void deleteStudentRecord(Id studentId) {
        try {
            Student__c studentToDelete = [SELECT Id FROM Student__c WHERE Id = :studentId];
            if (studentToDelete != null) {
                delete studentToDelete;
            } else {
                throw new CustomException('Student record not found for deletion.');
            }
        } catch (Exception e) {
            throw new CustomException('Error deleting student record: ' + e.getMessage());
        }
    }
    
    public  class  CustomException extends Exception {
        
    }

   
    /**
     * クラス名：   SearchConditionDTO
     * クラス概要： Search COndition Dto Class
     * @created： 2023/01/10 + Nguyen Vinh
     * @modified: 
     */
    public class SearchConditionDTO {
        @AuraEnabled
        public String classId;

        @AuraEnabled
        public Integer gender;
        
        @AuraEnabled
        public String searchName;
        
        @AuraEnabled
        public String searchCode;
        
        @AuraEnabled
        public Integer day;
        
        @AuraEnabled
        public Integer month;
        
        @AuraEnabled
        public Integer year;
        
        @AuraEnabled
        public String birthdate;
    }

    
}