/**
 * クラス名：   B02_CreateSubjectScoreBatch.cls
 * クラス概要： Create SubjectScore Batch
 * @created： 2023/01/24 + Nguyen Vinh
 * @modified:
 */
public class B02_CreateSubjectScoreBatch implements Database.Batchable<SObject>, Database.Stateful {
    private static final String ENROLLED = 'Enrolled';
    private static final String BATCHNAME = 'B02_科目得点作成バッチ';
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    private static final String PROGRESS = 'Progress';
    private static final String PRACTICAL = 'Practical';
    private static final String MIDTERM = 'Midterm Exam';
    private static final String FINALTERM = 'FinalTerm Exam';
    private BatchLog__c batchLogObj = new BatchLog__c();
    private List<Semester__c> semestersList = new List<Semester__c>();
    private List<Subject__C> subjectsList = new List<Subject__C>();
    
    /**
     * start
     * @param    : Database.BatchableContext BC
     * @return   : Database.QueryLocator
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
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
     * @param    : Database.BatchableContext BC, List<SubjectScore__c> subjectScoresToDelete
     * @return   : 
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    public void execute(Database.BatchableContext BC, List<Student__c> studentsList) {
        List<SubjectScore__c> subjectScoreObjList = new List<SubjectScore__c>();
        for (Student__c student : studentsList) {
            Set<Semester__c> semesterSet = new Set<Semester__c>();
            while (semesterSet.size() < 2) {
                Semester__c currentSemester = semestersList[getRandomNumber(this.semestersList.size())];
                if (!semesterSet.contains(currentSemester)) {
                    Set<Subject__c> subjectSet = new Set<Subject__c>();
                    Decimal totalCredit = 0;
                    while (subjectSet.size() < 5) {
                        Subject__c currentSubject = subjectsList[getRandomNumber(this.subjectsList.size())];
                        if (!subjectSet.contains(currentSubject)){
                            // if((totalCredit + currentSubject.CourseCredit__c) <= 25){
                                SubjectScore__c subjectScoreObj = createSubjectScore(currentSubject.Id, currentSemester.Id, student.Id);
                                subjectScoreObjList.add(subjectScoreObj);
                                totalCredit+=currentSubject.CourseCredit__c;
                                subjectSet.add(currentSubject);
                            // }
                        }
                    }
                    semesterSet.add(currentSemester);
                }
            }
        }
        insert subjectScoreObjList;
        List<Score__c> scoreList = new List<Score__c>();
        for(SubjectScore__c subjectScoreObj: subjectScoreObjList){
            List<Score__c> scoreListBySubScoreId = getScoreListBySubId(subjectScoreObj.Id);
            if(!scoreListBySubScoreId.isEmpty()){
                scoreList.addAll(scoreListBySubScoreId);
            }
        }
        insert scoreList;
    }
    /**
     * finish
     * @param    : Database.BatchableContext BC
     * @return   : 
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    public void finish(Database.BatchableContext BC) {
        AsyncApexJob jobInfo = [
                SELECT Id
                , NumberOfErrors
                , ExtendedStatus
                FROM AsyncApexJob 
                WHERE Id = :BC.getJobId()
            ];
        try {
            if (jobInfo.NumberOfErrors > 0) {
                updateBatchLog(this.batchLogObj.id, jobInfo.ExtendedStatus, ERROR);
            } else {
                B03_UpdateStudentScoreBatch b03UpdateStudentScoreBatch = new B03_UpdateStudentScoreBatch();
                Database.executeBatch(b03UpdateStudentScoreBatch);
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
     * getRandomNumber
     * @param    : Integer listSize
     * @return   : Integer
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified : 
     */
    private static Integer getRandomNumber(Integer listSize){
        Integer ranNumber = (Integer) Math.floor(Math.random() * listSize);
        return ranNumber;
    } 
    /**
     * createSubjectScore
     * @param    :  Id subId
     *              , Id semId
     *              , Id stuId
     * @return   : SubjectScore__c
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified :
     */
    private static SubjectScore__c createSubjectScore(Id subId, Id semId, Id stuId ){
        SubjectScore__c subjectScoreObj = new SubjectScore__c();
        subjectScoreObj.Subject_look__c = subId;
        subjectScoreObj.Semester_look__c = semId;
        subjectScoreObj.Student_look__c = stuId;
        return subjectScoreObj;
    }
    /**
     * createScore
     * @param    : Id subScoreId, String type
     * @return   : Score__c
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified :
     */
    private static Score__c createScore(Id subScoreId, String type){
        Score__c score = new Score__c();
        score.SubjectScore_look__c = subScoreId;
        score.Score__c = 1 + (Math.random() *9);
        score.ExamType__c = type;
        return score;
    }
    /**
     * getScoreListBySubId
     * @param    : Id subScoreId
     * @return   : List<Score__c>
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified :
     */
    private static List<Score__c> getScoreListBySubId(Id subScoreId){
        List<Score__c> scoreList = new list<Score__c>();
        Score__c progressScore = createScore(subScoreId, PROGRESS);
        Score__c practicalScore = createScore(subScoreId, PRACTICAL);
        Score__c midtermScore = createScore(subScoreId, MIDTERM);
        Score__c finalTermScore = createScore(subScoreId, FINALTERM);
        scoreList.add(progressScore);
        scoreList.add(practicalScore);
        scoreList.add(midtermScore);
        scoreList.add(finalTermScore);
        return scoreList;
    }
    
    
}