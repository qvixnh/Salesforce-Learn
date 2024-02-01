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
    private static final String BATCH_SUCCESS = 'Batch run successfully';

    /**
     * start
     * @param    : Database.BatchableContext BC
     * @return   : Database.QueryLocator
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 2023/01/30 + Nguyen Vinh
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        try {
            this.batchLogObj= createBatchLog();
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
            System.abortJob(BC.getJobId());
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
                Student__c stu = getStudentGPA_Credit(subjectScoreList, student.Id);
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
                updateBatchLog(this.batchLogObj.id, BATCH_SUCCESS, SUCCESS);
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
     * @return   : Map<String, List<SubjectScore__c>>
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    private static Map<Id, List<SubjectScore__c>> getSubjectScoreByStudentsMap(List<Student__c> studentList){
        Set<String> subStuKeySet =new Set<String>();
        Map<Id, List<SubjectScore__c>> subjectScoreByStudentsMapById = new Map<Id, List<SubjectScore__c>>();
        List<Id> studentIds = new List<Id>();
        for(Student__c s : studentList){
            studentIds.add(s.Id);
        }
        List<SubjectScore__c> subjectScoreList = [
            SELECT Id
                , Student_look__c
                , Subject_look__c
                , AverageScore__c
                , Subject_look__r.CourseCredit__c
            FROM SubjectScore__c
            WHERE Student_look__c IN :studentIds
            ORDER BY Student_look__c, Subject_look__c, AverageScore__c DESC NULLS LAST
        ];
        for(SubjectScore__c subjectScore: subjectScoreList){
            String subStuKey = subjectScore.Student_look__c + '_' + subjectScore.Subject_look__c; 
            if(!subStuKeySet.contains(subStuKey)){
                subStuKeySet.add(subStuKey);
                if(!subjectScoreByStudentsMapById.containsKey(subjectScore.Student_look__c)){
                    subjectScoreByStudentsMapById.put(subjectScore.Student_look__c, new List<SubjectScore__c>{subjectScore});
                }
                else{
                    subjectScoreByStudentsMapById.get(subjectScore.Student_look__c).add(subjectScore);
                }
            }
        }
        return subjectScoreByStudentsMapById;
    }
     /**
     * getStudentGPA_Credit
     * @param    : List<SubjectScore__c> subjectScoreList, Student__c student
     * @return   : Student__c
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    private static Student__c getStudentGPA_Credit(List<SubjectScore__c> subjectScoreList, Id studentId) {
        Decimal totalCredits = 0;
        Decimal totalWeightedAverage = 0;
        Student__c newStudent = new Student__c();
        newStudent.Id = studentId;
        for (SubjectScore__c subjectScore : subjectScoreList) {
            if (subjectScore.Subject_look__c != null && subjectScore.Subject_look__r.CourseCredit__c != null && subjectScore.AverageScore__c != null) {
                Decimal courseCredit = subjectScore.Subject_look__r.CourseCredit__c;
                totalCredits += courseCredit;
                totalWeightedAverage += subjectScore.AverageScore__c * courseCredit;
            }
        }
        Decimal weightedAverageCredit = 0 ;
        if(totalCredits != 0 ){
            weightedAverageCredit = (totalWeightedAverage / totalCredits).setScale(2, System.RoundingMode.HALF_UP);
        }
        newStudent.TotalCredit__c = totalCredits;
        newStudent.GPAScore__c = weightedAverageCredit;
        
        return newStudent;
    }
}
