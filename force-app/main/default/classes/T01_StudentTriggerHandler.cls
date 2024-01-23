/**
 * クラス名：   T01_StudentTriggerHandler.cls
 * クラス概要： Create Student Controller
 * @created： 2023/01/22 + Nguyen Vinh
 * @modified: 
 */

public without sharing class T01_StudentTriggerHandler {
    /**
     * 
     * @param    : 
     *            
     * @return   : String 
     * @created  : 2023/12/26 + Nguyen Vinh
     * @modified : 
     */
    public static void  onBeforeInsert(List<Student__c> newStudents){
        try {
            validateFields(newStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onBeforeInsert : ' + e.getMessage());
        
        }
    }
    public static void  onAfterInsert(List<Student__c> newStudents){
        try {
            count(newStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onBeforeInsert : ' + e.getMessage());
        }
    }
    
    private static void count(List<Student__c> newStudents){
        Set<Id> classIds = new Set<Id>();
        //lấy danh sách lớp Id của student cần udpate 
        for (Student__c student : newStudents) {
            classIds.add(student.Class__c);
        }
        //lấy ra count cũ của student 
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        for (AggregateResult result : [SELECT Class__c, COUNT(Id) FROM Student__c WHERE Class__c IN :classIds GROUP BY Class__c]) {
            Id classId = (Id) result.get('Class__c');
            Integer count = (Integer) result.get('expr0');
            countMap.put(classId, count);
        }
        List<Class__c> classesToUpdate = [SELECT Id, NumberOfStudent__c FROM Class__c WHERE Id IN :classIds];
        List<Class__c> classesToUpdateList = new List<Class__c>();
        for(Class__c cls : classesToUpdate){
            Integer numberOfStudents = countMap.get(cls.Id);
            for (Student__c student : newStudents) {
                if (student.Class__c == cls.Id) {
                    numberOfStudents++;
                }
            }
            cls.NumberOfStudent__c = numberOfStudents;
            classesToUpdateList.add(cls);
        }
        if (!classesToUpdateList.isEmpty()) {
            update classesToUpdateList;
        }
        
    }
    private static void validateFields(List<Student__c> students) {
        for (Student__c student : students) {
            if (String.isBlank(student.Firstname__c)) {
                student.addError('First Name cannot be null.');
            }
            if (String.isBlank(student.Lastname__c)) {
                student.addError('Last Name cannot be null.');
            }
            if (student.Birthday__c == null) {
                student.addError('Birthday cannot be null.');
            }
            else if(student.Birthday__c!=null){
                Date birthday = student.Birthday__c;
                if (calculateAge(birthday) <= 17) {
                    student.addError('Age must be greater than 17.');
                }
        }
            if (String.isBlank(student.Address__c)) {
                student.addError('Address cannot be null.');
            }
            if (student.Class__c == null) {
                student.addError('Class cannot be null.');
            }
        }
    }
    private static Integer calculateAge(Date birthdate) {
        Date currentDate = Date.today();
        Integer birthYear = birthdate.year();
        Integer currentYear = currentDate.year();
        return currentYear - birthYear;
    }

    public  class  CustomException extends Exception {
        
    }
    
}
