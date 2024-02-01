/**
 * クラス名：   B01_DeleteSubjectScoreScheduler.cls
 * クラス概要： Delete SubjectScore Batch (Scheduled to run on the 1st day of every month)
 * @created： 2023/01/24 + Nguyen Vinh
 * @modified:
 */
public class B01_DeleteSubjectScoreScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        B01_DeleteSubjectScoreBatch batchInstance = new B01_DeleteSubjectScoreBatch();
        Database.executeBatch(batchInstance); 
    }
}