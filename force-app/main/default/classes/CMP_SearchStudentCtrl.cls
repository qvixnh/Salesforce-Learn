public with sharing class CMP_SearchStudentCtrl {
    public CMP_SearchStudentCtrl() {

    }
    @AuraEnabled
    public static List<Class__c> getClassOptions() {
        return  [SELECT 
                    Id
                    , Class_Code__c
                    , Class_Name__c
                    , Number_Of_Student__c
                FROM Class__c 
                ORDER BY Class_Code__c];
    }
    @AuraEnabled
    public static Student__c getStudentDetails(String studentId) {
        return [SELECT 
                    Id
                    , Student_Code__c
                    , First_Name__c
                    , Last_Name__c,selected__c
                    , Class__c
                    , Class__r.Class_Name__c,Gender__c
                    , Birthdate__c
                    , Address__c
                FROM Student__c 
                WHERE Id = :studentId 
                LIMIT 1];
    }
    @AuraEnabled
    public static PaginationResult getRecords(Integer pageSize, String classId,  Integer gender,String searchName, String searchCode, Integer day, Integer month, Integer year , String birthdate, String orderField, String orderType) {
        List<Student__c> records = getStudents(classId, gender, searchName, searchCode,day,month,year,birthdate,orderField, orderType);
        if(!records.isEmpty()){
            Integer totalRecords = records.size();
            Integer totalPage = calTotalPage(totalRecords, pageSize);
            return new PaginationResult(records, totalRecords,totalPage);
        }
        return new PaginationResult(new List<Student__c>(), 0,1 );
    }
    public static Integer calTotalPage(Integer  totalRecords, Integer pageSize){
        Decimal num1 = totalRecords;
        Decimal num2 =pageSize;
        Decimal totalPageDec = num1 /num2;
        Integer totalPage = Math.ceil(totalPageDec).intValue();
        return totalPage;
    }
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
    @AuraEnabled
    public static String deleteSelectedStudentsCtrl(List<String> studentIds) {
        try {
            System.debug('Message');
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

    
    @AuraEnabled
    public static String deleteStudentRecord(String studentId) {
        try {
            if(studentId==''){
                return 'student Id to delete can not be blank';
            }
            Student__c studentToDelete = 
            [SELECT Id
            , First_Name__c
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
    // Example method to fetch student data
    public static List<Student__c> getStudents(String classId, Integer gender, String searchName, String searchCode, Integer day, Integer month, Integer year, String birthdate, String orderField, String orderType) {
        String queryString = 'SELECT Id';
        queryString += ', Student_Code__c';
        queryString +=', First_Name__c';
        queryString +=', Last_Name__c';
        queryString +=', selected__c';
        queryString +=', Class__r.Class_Name__c';
        queryString +=', Gender__c';
        queryString +=', Birthdate__c';
        queryString +=', Address__c';
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
        if (gender == 1 || gender == 0 ) {
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
    
        if (!conditions.isEmpty()) {
            queryString += ' WHERE ' + String.join(conditions, ' AND ');
            if (queryString.endsWith(' AND ')) {
                queryString = queryString.substring(0, queryString.length() - 5);
            }
        }
    
        queryString += ' ORDER BY ' + orderField + ' ' + orderType;
        return Database.query(queryString);
    }

}