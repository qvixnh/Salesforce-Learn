/**
 * クラス名：   LWC_SearchStudentCtrl.cls
 * クラス概要： Search Student Controller
 * @created： 2023/01/10 + Nguyen Vinh
 * @modified: 
 */
public with sharing class LWC_SearchStudentCtrl {
    //1101
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
                            , Class_Code__c
                            , Name
                            , Number_Of_Student__c
                        FROM Class__c 
                        ORDER BY Class_Code__c];
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
                'Id', 'Student_Code__c', 'First_Name__c', 'Last_Name__c', 'selected__c',
                'Class__r.Name', 'Gender__c', 'Birthdate__c', 'Address__c'
            };
            String queryString = 'SELECT ' + String.join(selectedFields, ', ') + ' FROM Student__c';

            if (!String.isBlank(searchCondition.searchName)) {
                conditions.add('First_Name__c LIKE \'%' + searchCondition.searchName + '%\'');
            }
            if (!String.isBlank(searchCondition.searchCode)) {
                conditions.add('Student_Code__c LIKE \'%' + searchCondition.searchCode + '%\'');
            }
            if (searchCondition.classId != null && searchCondition.classId != 'null' && !String.isBlank(searchCondition.classId)) {
                conditions.add('Class__c = \'' + searchCondition.classId + '\'');
            }
            if (searchCondition.gender == 1 || searchCondition.gender == 0) {
                conditions.add('Gender__c = ' + (searchCondition.gender == 1 ? 'True' : 'False'));
            }
            if (!String.isBlank(searchCondition.birthdate)) {
                conditions.add('Birthdate__c = ' + searchCondition.birthdate);
            }
            if (searchCondition.day > 0) {
                conditions.add('DAY_IN_MONTH(Birthdate__c) = ' + searchCondition.day);
            }
            if (searchCondition.month > 0) {
                conditions.add('CALENDAR_MONTH(Birthdate__c) = ' + searchCondition.month);
            }
            if (searchCondition.year > 0) {
                conditions.add('CALENDAR_YEAR(Birthdate__c) = ' + searchCondition.year);
            }
            queryString += !conditions.isEmpty() ? ' WHERE ' + String.join(conditions, ' AND ')  : '';
            if(searchCondition.orderField =='Student_Code__c'){
                queryString +=' ORDER BY Student_Code__c';
            }
            else if(searchCondition.orderField=='First_Name__c'){
                queryString +=' ORDER BY First_Name__c';

            }
            else if(searchCondition.orderField=='Class__r.Name'){
                queryString +=' ORDER BY Class__r.Name';
                
            }
            else if(searchCondition.orderField=='Gender__c'){
                queryString +=' ORDER BY Gender__c';
            }
            else if(searchCondition.orderField=='Birthdate__c'){
                queryString +=' ORDER BY Birthdate__c';
            }
            if(searchCondition.orderType=='ASC'){
                queryString+= ' ASC'; 
            }else{
                queryString+= ' DESC';
            }
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
            // Check if the student record exists
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
}