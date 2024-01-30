public with sharing class LWC_DetailStudentCtrl {
    public LWC_DetailStudentCtrl() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Semester__c> getSemesterOptions() {
        List<Semester__c> semesterList = new List<Semester__c>();
        try {
            semesterList = [SELECT 
                            Id
                            , Name
                            , StartDate__c
                            , EndDate__c 
                        FROM Semester__c 
                        ORDER BY Name];
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting semesters: ' + e.getMessage());
        }
        return semesterList;
    }
    public  class  CustomException extends Exception {
        
    }
}