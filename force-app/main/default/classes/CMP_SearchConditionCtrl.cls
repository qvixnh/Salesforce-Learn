public with sharing class CMP_SearchConditionCtrl {
    public CMP_SearchConditionCtrl() {

    }
    // Example method to fetch student data
    public static List<Student__c> getStudents(String classId,  Integer gender,String searchName, String searchCode, Integer day, Integer month, Integer year, String birthdate) {
        String andString = ' AND ';
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
        queryString += ' WHERE First_Name__c LIKE \'%' + searchName + '%\'';//khi no blank thi cho no khoi like 
        queryString += ' AND Student_Code__c LIKE \'%' + searchCode + '%\'';

        if (classId != null && classId != 'null') {

            queryString += ' AND Class__c = \'' + classId + '\'';//String joinedString = String.join(listToJoin, delimiter);
            //queryString = String.join(queryString,' AND ');
        }
        if(gender==1){
            queryString += ' AND Gender__c = True';
        }
        else if(gender==0){
            queryString += ' AND Gender__c = False';
        }
        if (birthdate != '') {
            // String formattedDate = birthdate.year() + '-' + pad(birthdate.month()) + '-' + pad(birthdate.day());
            // queryString += ' AND Birthdate__c = ' + formattedDate;
            queryString += ' AND Birthdate__c = ' + birthdate;
        }
        queryString = searchByDayMonthYear(queryString,day,month,year);
        queryString += ' ORDER BY Student_Code__c ';
        System.debug(queryString);
        return Database.query(queryString);
    }
    private static String  searchByDayMonthYear(String queryString,  Integer day, Integer month, Integer year){
        if (day > 0) {
            queryString += ' AND DAY_IN_MONTH(Birthdate__c) = :day';
        }
        if (month > 0) {
            queryString += ' AND CALENDAR_MONTH(Birthdate__c) = :month';
        }
        if (year >0) {
            queryString += ' AND CALENDAR_YEAR(Birthdate__c) = :year';
        }
        return queryString;
    }
    @AuraEnabled
    public static PaginationResult getRecords(Integer currentPage, Integer pageSize, String classId,  Integer gender,String searchName, String searchCode, Integer day, Integer month, Integer year , String birthdate) {
        List<Student__c> records = getStudents(classId, gender, searchName, searchCode,day,month,year,birthdate);
        if(records != null){
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
    
}