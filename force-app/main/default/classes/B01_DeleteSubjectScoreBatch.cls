/**
 * クラス名：   B01_DeleteSubjectScoreBatch.cls
 * クラス概要： Delete SubjectScore Batch
 * @created： 2023/01/24 + Nguyen Vinh
 * @modified:
 */
public without sharing class B01_DeleteSubjectScoreBatch implements Database.Batchable<SObject>, Database.Stateful {
    private static final String BATCHNAME = 'B01_科目得点削除バッチ';
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    private BatchLog__c batchLogObj = new BatchLog__c();
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
            return Database.getQueryLocator([
                SELECT Id 
                FROM SubjectScore__c
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
    public void execute(Database.BatchableContext BC, List<SubjectScore__c> subjectScoresToDelete) {
        delete subjectScoresToDelete;
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
                Integer batchSize = 150;
                B02_CreateSubjectScoreBatch b02CreateSubjectScoreBatch = new B02_CreateSubjectScoreBatch();
                Database.executeBatch(b02CreateSubjectScoreBatch, batchSize);
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
}
