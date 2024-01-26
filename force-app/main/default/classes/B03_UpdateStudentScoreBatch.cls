public with sharing class B03_UpdateStudentScoreBatch  implements Database.Batchable<SObject>, Database.Stateful {
    private static final String ENROLLED = 'Enrolled';
    private static final String BATCHNAME = 'B03_学生得点更新バッチ';
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    private BatchLog__c batchLogObj = new BatchLog__c();
    private List<Semester__c> semestersList = new List<Semester__c>();
    private List<Subject__C> subjectsList = new List<Subject__C>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
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
            LIMIT 100
        ]);
    }
    private static BatchLog__c createBatchLog(){
        BatchLog__c batchLog = new BatchLog__c();
        batchLog.Name = BATCHNAME;
        batchLog.StartTime__c = DateTime.now();
        insert batchLog;
        return batchLog;
    }
    private static void updateBatchLog(Id id,String err, String result){
        BatchLog__c batchLog = new BatchLog__c();
        batchLog.Id = id; 
        batchLog.ErrorMessage__c = err;
        batchLog.EndTime__c = DateTime.now();
        update batchLog;
    }
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
            ORDER BY AverageScore__c DESC NULLS LAST 
        ];
        for(SubjectScore__c subjectScore: subjectScoreList){
            if(!subjectScoreByStudentsMap.containsKey(subjectScore.Student_look__c)){
                subjectScoreByStudentsMap.put(subjectScore.Student_look__c, new List<SubjectScore__c>{subjectScore});
            }
            else{
                subjectScoreByStudentsMap.get(subjectScore.Student_look__c).add(subjectScore);
            }
        }
        return subjectScoreByStudentsMap;
    }
    private static Student__c getStudentGPA_Credit(List<SubjectScore__c> subjectScoreList, Student__c student){
        subjectScoreList = filterSSList(subjectScoreList);
        Decimal totalCredits = 0;
        Decimal totalWeightedAverage = 0;
        for (SubjectScore__c subjectScore : subjectScoreList) {
            Decimal courseCredit = subjectScore.Subject_look__r.CourseCredit__c;
            totalCredits += courseCredit;
            totalWeightedAverage += subjectScore.AverageScore__c * courseCredit;
        }
        Decimal weightedAverageCredit = totalWeightedAverage / totalCredits;
        student.TotalCredit__c = totalCredits;
        student.GPAScore__c = weightedAverageCredit;
        return student;
    }
    private static List<SubjectScore__c>  filterSSList(List<SubjectScore__c> subjectScoreList){
        Map<String, SubjectScore__c> highestScoresMap = new Map<String, SubjectScore__c>();
        for (SubjectScore__c subjectScore : subjectScoreList) {
            String key = subjectScore.Student_look__c + '_' + subjectScore.Subject_look__c;
            if (!highestScoresMap.containsKey(key) || highestScoresMap.get(key).AverageScore__c < subjectScore.AverageScore__c) {
                highestScoresMap.put(key, subjectScore);
            }
        }
        return new List<SubjectScore__c>(highestScoresMap.values());
    }

    public void finish(Database.BatchableContext BC) {
        AsyncApexJob jobInfo = [
            SELECT Id
            , Status
            , NumberOfErrors
            , ExtendedStatus
            FROM AsyncApexJob 
            WHERE Id = :BC.getJobId()
        ];
        if (jobInfo.NumberOfErrors > 0) {
            updateBatchLog(this.batchLogObj.id, jobInfo.ExtendedStatus, ERROR);
        } else {
            updateBatchLog(this.batchLogObj.id, '', SUCCESS);

        }
    }
}
