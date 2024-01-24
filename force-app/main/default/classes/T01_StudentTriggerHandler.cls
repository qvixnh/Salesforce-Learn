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
            getNumberOfStudent(newStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onAfterInsert : ' + e.getMessage());
        }
    }

    /**
     * onBeforeDelete
     * @param    : List<Student__c> oldStudents
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    public static void  onBeforeDelete(Map<Id,Student__c> mapOldStudents){
        try {
            deleteSubjectScore(mapOldStudents.keySet());
        } catch (Exception e) {
            throw new CustomException('An error occurred onAfterDelete : ' + e.getMessage());
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
            getNumberOfStudent(oldStudents);
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
            getNumberOfStudentAfterUpdate(newStudents,oldStudents);
        } catch (Exception e) {
            throw new CustomException('An error occurred onAfterUpdate : ' + e.getMessage());
        }
    }

    /**
     * count
     * @param    : List<Student__c> students
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    private static void getNumberOfStudentAfterUpdate(List<Student__c> newStudents,List<Student__c> oldStudents){
        Set<Id> oldClassIds = new Set<Id>();
        for (Student__c student : oldStudents) {
            oldClassIds.add(student.Class_look__c);
        }
        Set<Id> newClassIds = new Set<Id>();
        for (Student__c student : newStudents) {
            newClassIds.add(student.Class_look__c);
        }
        newClassIds.addAll(oldClassIds);
        // uniqueClassIds giờ chứa các ID duy nhất từ cả newClassIds và oldClassIds
        Set<Id> uniqueClassIds = new Set<Id>(newClassIds);
        updateNumberOfStudentByClassIds(uniqueClassIds);
    }
    /**
     * count
     * @param    : List<Student__c> students
     * @return   :
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified :
     */
    private static void getNumberOfStudent(List<Student__c> students){
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : students) {
            classIds.add(student.Class_look__c);
        }
        updateNumberOfStudentByClassIds(classIds);
    }
    private static void updateNumberOfStudentByClassIds(Set<Id> classIds){
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        List<AggregateResult> results = [
            SELECT Class_look__c classLook
                , COUNT(Id) countId
            FROM Student__c
            WHERE Class_look__c IN :classIds
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
        String messageTemplate = '値を入力してください:{0}';
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
            if (student.Gender__c == null) {
                fields.add('Gender__c');
            }
            else if(student.Birthday__c != null){
                Date birthday = student.Birthday__c;
                if (calculateAge(birthday) <= 17) {
                    student.addError('学生の年齢が無効です。有効な年齢は18歳以上です (Age must be greater than 17)');
                }
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
                System.debug(formatted);
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

    public class CustomException extends Exception {
    }
}
