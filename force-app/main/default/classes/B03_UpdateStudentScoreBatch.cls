/**
 * クラス名：   B03_UpdateStudentScoreBatch.cls
 * クラス概要： Update StudentScore Batch
 * @created： 2023/01/25 + Nguyen Vinh
 * @modified:
 */
public with sharing class B03_UpdateStudentScoreBatch  implements Database.Batchable<SObject>, Database.Stateful {
    private static final String ENROLLED = 'Enrolled';
    private static final String BATCHNAME = 'B03_学生得点更新バッチ';
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    private BatchLog__c batchLogObj = new BatchLog__c();
    private List<Semester__c> semestersList = new List<Semester__c>();
    private List<Subject__C> subjectsList = new List<Subject__C>();

    /**
     * start
     * @param    : Database.BatchableContext BC
     * @return   : Database.QueryLocator
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 2023/01/30 + Nguyen Vinh
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        AsyncApexJob jobInfo = [
                SELECT Id
                , Status
                , NumberOfErrors
                , ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :BC.getJobId()
            ];
        try {
            this.batchLogObj= createBatchLog();
            this.semestersList = [
                SELECT Id
                , Name
                FROM Semester__c
            ];
            this.subjectsList = [
                SELECT Id
                , Name
                , CourseCredit__c
                FROM Subject__c
            ];
            return Database.getQueryLocator([
                SELECT Id
                , TotalCredit__c
                , GPAScore__c
                , LearningStatus__c
                FROM Student__c
                WHERE LearningStatus__c = :ENROLLED
            ]);
        } catch (Exception e) {
            updateBatchLog(this.batchLogObj.id, e.getMessage(), ERROR);
            System.abortJob(jobInfo.Id);
            return null;
        }
    }
    /**
     * execute
     * @param    : Database.BatchableContext BC, List<Student__c> studentsList
     * @return   :
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    public void execute(Database.BatchableContext BC, List<Student__c> studentsList) {
        List<Student__c> studentsListUpdate = new List<Student__c>();
        Map<Id, List<SubjectScore__c>> subjectScoreByStudentsMap = getSubjectScoreByStudentsMap( studentsList);
        for(Student__c student: studentsList){
            List<SubjectScore__c> subjectScoreList = subjectScoreByStudentsMap.get(student.Id);
            if (!subjectScoreList.isEmpty()) {
                Student__c stu = getStudentGPA_Credit(subjectScoreList, student);
                studentsListUpdate.add(stu);
            }
        }
        update studentsListUpdate;
    }

     /**
     * finish
     * @param    : Database.BatchableContext BC
     * @return   :
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified :
     */
    public void finish(Database.BatchableContext BC) {
        AsyncApexJob jobInfo = [
                SELECT Id
                , Status
                , NumberOfErrors
                , ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :BC.getJobId()
            ];
        try {
            if (jobInfo.NumberOfErrors > 0) {
                updateBatchLog(this.batchLogObj.id, jobInfo.ExtendedStatus, ERROR);
            } else {
                updateBatchLog(this.batchLogObj.id, '', SUCCESS);
            }
        } catch (Exception e) {
            updateBatchLog(this.batchLogObj.id, e.getMessage(), ERROR);
            System.abortJob(jobInfo.Id);
        }
    }
    /**
     * createBatchLog
     * @param    : BatchLog__c
     * @return   : BatchLog__c
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 
     */
    private static BatchLog__c createBatchLog(){
        BatchLog__c batchLog = new BatchLog__c();
        batchLog.Name = BATCHNAME;
        batchLog.StartTime__c = DateTime.now();
        insert batchLog;
        return batchLog;
    }
    /**
     * updateBatchLog
     * @param    : Id id,String err, String result
     * @return   :
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified :
     */
    private static void updateBatchLog(Id id,String err, String result){
        BatchLog__c batchLog = new BatchLog__c();
        batchLog.Id = id;
        batchLog.ErrorMessage__c = err;
        batchLog.EndTime__c = DateTime.now();
        update batchLog;
    }
    /**
     * getSubjectScoreByStudentsMap
     * @param    : List<Student__c> studentList
     * @return   : Map<Id, List<SubjectScore__c>>
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    private static Map<Id, List<SubjectScore__c>> getSubjectScoreByStudentsMap(List<Student__c> studentList){
        Map<Id, List<SubjectScore__c>> subjectScoreByStudentsMap = new Map<Id, List<SubjectScore__c>>();
        List<SubjectScore__c> subjectScoreList = [
            SELECT Id
                , Semester_look__c
                , Student_look__c
                , Subject_look__c
                , AverageScore__c
                , Subject_look__r.CourseCredit__c
            FROM SubjectScore__c
            ORDER BY Student_look__r.Name, Subject_look__r.Name, AverageScore__c DESC NULLS LAST
        ];
        for(SubjectScore__c subjectScore: subjectScoreList){
            if(!subjectScoreByStudentsMap.containsKey(subjectScore.Student_look__c)){
                subjectScoreByStudentsMap.put(subjectScore.Student_look__c, new List<SubjectScore__c>{subjectScore});
            }
        }
        return subjectScoreByStudentsMap;
    }
     /**
     * getStudentGPA_Credit
     * @param    : List<SubjectScore__c> subjectScoreList, Student__c student
     * @return   : Student__c
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    private static Student__c getStudentGPA_Credit(List<SubjectScore__c> subjectScoreList, Student__c student) {
        Decimal totalCredits = 0;
        Decimal totalWeightedAverage = 0;
    
        for (SubjectScore__c subjectScore : subjectScoreList) {
            if (subjectScore.Subject_look__r != null && subjectScore.Subject_look__r.CourseCredit__c != null) {
                Decimal courseCredit = subjectScore.Subject_look__r.CourseCredit__c;
                totalCredits += courseCredit;
                if (subjectScore.AverageScore__c != null) {
                    totalWeightedAverage += subjectScore.AverageScore__c * courseCredit;
                }
            }
        }
    
        Decimal weightedAverageCredit = totalCredits != 0 ? totalWeightedAverage / totalCredits : 0;
        
        student.TotalCredit__c = totalCredits;
        student.GPAScore__c = weightedAverageCredit.setScale(2, System.RoundingMode.HALF_UP);
        
        return student;
    }
}
