/**
 * クラス名：   T01_StudentTriggerHandler.cls
 * クラス概要： Student Trigger Handler
 * @created： 2023/01/22 + Nguyen Vinh
 * @modified:
 */
public without sharing class T01_StudentTriggerHandler {
    private static final String ERROR_TEMPLATE = 'T01_StudentTriggerHandler: An error occurred {0}: {1} ';
    private static final String ENROLLED = 'Enrolled';

    /**
     * onBeforeInsert
     * @param    : List<Student__c> newStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    public static void onBeforeInsert(List<Student__c> newStudents){
        try {
            validateFields(newStudents);
        } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onBeforeInsert',e.getMessage()});
            throw new CustomException(formatted);
        }
    }
    /**
     * onBeforeUpdate
     * @param    : List<Student__c> newStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    public static void onBeforeUpdate(List<Student__c> newStudents){
        try {
            validateFields(newStudents);
        } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onBeforeUpdate',e.getMessage()});
            throw new CustomException(formatted);
        }
    }
    /**
     * onAfterInsert
     * @param    : List<Student__c> newStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    public static void onAfterInsert(List<Student__c> newStudents){
        try {
            Set<Id> classIds = new Set<Id>();
            for (Student__c student : newStudents) {
                classIds.add(student.Class_look__c);
            }
            List<Class__c> classesToUpdateList = updateNumberOfStudentByClassIds(classIds);
            if (!classesToUpdateList.isEmpty()) {
                update classesToUpdateList;
            }
            } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onAfterInsert',e.getMessage()});
            throw new CustomException(formatted);
        }
    }

    /**
     * onBeforeDelete
     * @param    : List<Student__c> oldStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    public static void onBeforeDelete(Map<Id,Student__c> mapOldStudents){
        try {
            deleteSubjectScore(mapOldStudents.keySet());
        } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onBeforeDelete',e.getMessage()});
            throw new CustomException(formatted);
        }
    }
    /**
     * onAfterDelete
     * @param    : List<Student__c> newStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    public static void onAfterDelete(List<Student__c> oldStudents){
        try {
            Set<Id> classIds = new Set<Id>();
            for (Student__c student : oldStudents) {
                classIds.add(student.Class_look__c);
            }
            List<Class__c> classesToUpdateList = updateNumberOfStudentByClassIds(classIds);
            if (!classesToUpdateList.isEmpty()) {
                update classesToUpdateList;
            }
        } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onAfterDelete',e.getMessage()});
            throw new CustomException(formatted);
        }
    }
    /**
     * onAfterUpdate
     * @param    : List<Student__c> newStudents,List<Student__c> oldStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    public static void onAfterUpdate(Map<Id,Student__c> mapNewStudents,Map<Id,Student__c> mapOldStudents){
        try {
            if(isClassUpdated(mapNewStudents, mapOldStudents)){
                Set<Id> classIds = new Set<Id>();
                for (Student__c student : mapOldStudents.values()) {
                    classIds.add(student.Class_look__c);
                }
                for (Student__c student : mapNewStudents.values()) {
                    classIds.add(student.Class_look__c);
                }
                List<Class__c> classesToUpdateList = updateNumberOfStudentByClassIds(classIds);
                if (!classesToUpdateList.isEmpty()) {
                    update classesToUpdateList;
                }
            }
        } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onAfterUpdate',e.getMessage()});
            throw new CustomException(formatted);
        }
    }
    /**
     * isClassUpdated
     * @param    : Map<Id,Student__c> mapNewStudents,Map<Id,Student__c> mapOldStudents
     * @return   : Boolean
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified :
     */
    private static Boolean isClassUpdated(Map<Id,Student__c> mapNewStudents,Map<Id,Student__c> mapOldStudents){
        
        for (Id id : mapNewStudents.keySet()) {
            if(mapNewStudents.get(id).Class_look__c != mapOldStudents.get(id).Class_look__c){
                return true;
            }
        }
        return false;
    }
    /**
     * updateNumberOfStudentByClassIds
     * @param    : Set<Id> classIds
     * @return   : List<Class__c>
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    private static List<Class__c> updateNumberOfStudentByClassIds(Set<Id> classIds){
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        List<AggregateResult> results = [
            SELECT Class_look__c classLook
                , COUNT(Id) countId
            FROM Student__c
            WHERE Class_look__c IN :classIds
                AND LearningStatus__c = :ENROLLED
            GROUP BY Class_look__c
        ];
        for (AggregateResult result : results) {
            Id classId = (Id) result.get('classLook');
            Integer count = (Integer) result.get('countId');
            countMap.put(classId, count);
        }
        List<Class__c> classesToUpdateList = new List<Class__c>();
        for(Id classId : classIds){
            Class__c obClass = new Class__c();
            obClass.ID = classId;
            obClass.NumberOfStudent__c =  countMap.get(classId);
            classesToUpdateList.add(obClass);
        }
        return classesToUpdateList;
    }
    /**
     * validateFields
     * @param    : List<Student__c> newStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    private static void validateFields(List<Student__c> newStudents) {
        String messageTemplate = '値を入力してください:{0}.';
        List<String> fields = new List<String>();
        for (Student__c student : newStudents) {
            if (String.isBlank(student.Firstname__c)) {
                fields.add('Firstname__c');
            }
            if (String.isBlank(student.Lastname__c)) {
                fields.add('Lastname__c');
            }
            if (student.Birthday__c == null) {
                fields.add('Birthday__c');
            }
            else if(student.Birthday__c != null){
                Date birthday = student.Birthday__c;
                if (calculateAge(birthday) <= 17) {
                    student.addError('学生の年齢が無効です。有効な年齢は18歳以上です.');
                }
            }
            if (student.Gender__c == null) {
                fields.add('Gender__c');
            }
            if (String.isBlank(student.Address__c)) {
                fields.add('Address__c');
            }
            if (student.Class_look__c == null) {
                fields.add('Class__c');
            }
            if(!fields.isEmpty()){
                String fieldErrorMessage = String.join(fields,', ');
                String formatted = String.format(messageTemplate , new List<String> {fieldErrorMessage});
                student.addError(formatted);
            }
        }
    }
    /**
     * deleteSubjectScore
     * @param    : List<Student__c> oldStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    private static void deleteSubjectScore(Set<Id> studentIds) {
        List<SubjectScore__c> subjectScoresToDelete = [
            SELECT Id
            FROM SubjectScore__c
            WHERE Student_look__c IN :studentIds
        ];
        if (!subjectScoresToDelete.isEmpty()) {
            delete subjectScoresToDelete;
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
    /**
     * クラス名：   CustomException
     * クラス概要： Custom Exception
     * @created： 2023/01/24 + Nguyen Vinh
     * @modified:
     */
    public class CustomException extends Exception {
    }
}
