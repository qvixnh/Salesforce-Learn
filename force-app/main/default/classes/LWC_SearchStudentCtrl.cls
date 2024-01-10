public with sharing class LWC_SearchStudentCtrl {
    public LWC_SearchStudentCtrl() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Class__c> getClassOptions() {
        List<Class__c> classList = new List<Class__c>();
        try {
            classList = [SELECT 
                            Id
                            , Class_Code__c
                            , Class_Name__c
                            , Number_Of_Student__c
                        FROM Class__c 
                        ORDER BY Class_Code__c];
        } catch (Exception e) {
            System.debug('An error occurred when getting classes: ' + e.getMessage());
        }
        return classList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents(String classId, Integer gender, String searchName, String searchCode, Integer day, Integer month, Integer year, String birthdate, String orderField, String orderType) {
        try {
            String queryString = 'SELECT Id';
            queryString += ', Student_Code__c';
            queryString += ', First_Name__c';
            queryString += ', Last_Name__c';
            queryString += ', selected__c';
            queryString += ', Class__r.Class_Name__c';
            queryString += ', Gender__c';
            queryString += ', Birthdate__c';
            queryString += ', Address__c';
            queryString += ' FROM Student__c';

            List<String> conditions = new List<String>();

            if (!String.isBlank(searchName)) {
                conditions.add('First_Name__c LIKE \'%' + searchName + '%\'');
            }
            if (!String.isBlank(searchCode)) {
                conditions.add('Student_Code__c LIKE \'%' + searchCode + '%\'');
            }
            if (classId != null && classId != 'null') {
                conditions.add('Class__c = \'' + classId + '\'');
            }
            if (gender == 1 || gender == 0) {
                conditions.add('Gender__c = ' + (gender == 1 ? 'True' : 'False'));
            }
            if (!String.isBlank(birthdate)) {
                conditions.add('Birthdate__c = ' + birthdate);
            }
            if (day > 0) {
                conditions.add('DAY_IN_MONTH(Birthdate__c) = ' + day);
            }
            if (month > 0) {
                conditions.add('CALENDAR_MONTH(Birthdate__c) = ' + month);
            }
            if (year > 0) {
                conditions.add('CALENDAR_YEAR(Birthdate__c) = ' + year);
            }
            queryString += !conditions.isEmpty() ? ' WHERE ' + String.join(conditions, ' AND ') + ' ORDER BY ' + orderField + ' ' + orderType : ' ORDER BY ' + orderField + ' ' + orderType;
            return Database.query(queryString);
        } catch (Exception e) {
            System.debug('An error occurred in getStudents: ' + e.getMessage());
            return new List<Student__c>();
        }
    }
    @AuraEnabled
    public static void deleteSelectedStudentsCtrl(List<Id> studentIds) {
        try {
            List<Student__c> studentsToDelete = [SELECT Id FROM Student__c WHERE Id IN :studentIds];
            delete studentsToDelete;
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting selected students: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteStudentRecord(Id studentId) {
        try {
            Student__c studentToDelete = [SELECT Id FROM Student__c WHERE Id = :studentId LIMIT 1];
            
            // Check if the student record exists
            if (studentToDelete != null) {
                delete studentToDelete;
            } else {
                throw new AuraHandledException('Student record not found for deletion.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting student record: ' + e.getMessage());
        }
    }
}