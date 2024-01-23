/**
 * クラス名：   T01_StudentTriggerHandler.cls
 * クラス概要： Create Student Controller
 * @created： 2023/01/22 + Nguyen Vinh
 * @modified: 
 */

public without sharing class T01_StudentTriggerHandler {
    /**
     * onBeforeInsert
     * @param    : List<Student__c> newStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    public static void  onBeforeInsert(List<Student__c> newStudents){
        try {
            validateFields(newStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onBeforeInsert : ' + e.getMessage());
        
        }
    }
    /**
     * onBeforeUpdate
     * @param    : List<Student__c> newStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    public static void  onBeforeUpdate(List<Student__c> newStudents){
        try {
            validateFields(newStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onBeforeUpdate : ' + e.getMessage());
        
        }
    }
    /**
     * onAfterInsert
     * @param    : List<Student__c> newStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    public static void  onAfterInsert(List<Student__c> newStudents){
        try {
            countNew(newStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onAfterInsert : ' + e.getMessage());
        }
    }
    /**
     * onAfterDelete
     * @param    : List<Student__c> newStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    public static void  onAfterDelete(List<Student__c> oldStudents){
        try {
            countNew(oldStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onAfterDelete : ' + e.getMessage());
        }
    }
    /**
     * onAfterUpdate
     * @param    : List<Student__c> newStudents,List<Student__c> oldStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    public static void  onAfterUpdate(List<Student__c> newStudents,List<Student__c> oldStudents){
        try {
            countNew(newStudents);
            countOld(oldStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onAfterUpdate : ' + e.getMessage());
        }
    }
    /**
     * countNew
     * @param    : List<Student__c> newStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    private static void countNew(List<Student__c> newStudents){
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : newStudents) {
            classIds.add(student.Class__c);
        }
        
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        for (AggregateResult result : [SELECT Class_look__c, COUNT(Id) FROM Student__c WHERE Class_look__c IN :classIds GROUP BY Class_look__c]) {
            Id classId = (Id) result.get('Class_look__c');
            Integer count = (Integer) result.get('expr0');
            countMap.put(classId, count);
        }
        List<Class__c> classesToUpdate = [SELECT Id, NumberOfStudent__c FROM Class__c WHERE Id IN :classIds];
        List<Class__c> classesToUpdateList = new List<Class__c>();
        for(Class__c cls : classesToUpdate){
            Integer numberOfStudents = countMap.get(cls.Id);
            cls.NumberOfStudent__c = numberOfStudents;
            classesToUpdateList.add(cls);
        }
        if (!classesToUpdateList.isEmpty()) {
            update classesToUpdateList;
        }
        
    }
    /**
     * countOld
     * @param    : List<Student__c> oldStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    private static void countOld(List<Student__c> oldStudents){
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : oldStudents) {
            classIds.add(student.Class__c);
        }
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        for (AggregateResult result : [SELECT Class_look__c, COUNT(Id) FROM Student__c WHERE Class_look__c IN :classIds GROUP BY Class_look__c]) {
            Id classId = (Id) result.get('Class_look__c');
            Integer count = (Integer) result.get('expr0');
            countMap.put(classId, count);
        }
        List<Class__c> classesToUpdate = [SELECT Id, NumberOfStudent__c FROM Class__c WHERE Id IN :classIds];
        List<Class__c> classesToUpdateList = new List<Class__c>();
        for(Class__c cls : classesToUpdate){
            Integer numberOfStudents = countMap.get(cls.Id);
            cls.NumberOfStudent__c = numberOfStudents;
            classesToUpdateList.add(cls);
        }
        if (!classesToUpdateList.isEmpty()) {
            update classesToUpdateList;
        }
    }
    /**
     * validateFields
     * @param    : List<Student__c> newStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    private static void validateFields(List<Student__c> newStudents) {
        for (Student__c student : newStudents) {
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
    /**
     * calculateAge
     * @param    : Date birthdate
     * @return   :  Integer
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    private static Integer calculateAge(Date birthdate) {
        Date currentDate = Date.today();
        Integer birthYear = birthdate.year();
        Integer currentYear = currentDate.year();
        return currentYear - birthYear;
    }

    public  class  CustomException extends Exception {
        
    }
    
}
