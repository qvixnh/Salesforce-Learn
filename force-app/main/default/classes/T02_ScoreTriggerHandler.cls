/**
 * クラス名：   T02_ScoreTriggerHandler.cls
 * クラス概要： Score Trigger Handler
 * @created： 2023/01/24 + Nguyen Vinh
 * @modified:
 */
public without sharing class T02_ScoreTriggerHandler {
    /**
     * onAfterInsert
     * @param    : List<Score__c> newScores
     * @return   :
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified :
     */
    public static void  onAfterInsert(List<Score__c> newScores){
        try {
            updateStatusAndGPA(newScores);
        } catch (Exception e) {
            throw new CustomException('T02_ScoreTriggerHandler: An error occurred onAfterInsert : ' + e.getMessage());
        }
    }
    /**
     * onAfterUpdate
     * @param    : List<Score__c> newScores
     * @return   :
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified :
     */
    public static void  onAfterUpdate(List<Score__c> newScores){
        try {
            updateStatusAndGPA(newScores);
        } catch (Exception e) {
            throw new CustomException('T02_ScoreTriggerHandler: An error occurred onAfterUpdate : ' + e.getMessage());
        }
    }
    /**
     * updateStatusAndGPA
     * @param    : List<Score__c> newScores
     * @return   :
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified :
     */
    private static void updateStatusAndGPA(List<Score__c> newScores){
        Set<Id> subjectScoreIDs = new Set<Id>();
        for (Score__c score : newScores) {
            subjectScoreIDs.add(score.SubjectScore_look__c);
        }
        List<Score__c> totalScores=  [
            SELECT Id
            , SubjectScore_look__c
            , ExamType__c
            , Score__c
            FROM Score__c
        ];
        Map<Id, List<Score__c>> scoreMap = new Map<Id, List<Score__c>>();
        for (Id id: subjectScoreIDs){
            List<Score__c> scoreList = new List<Score__c>();
            for(Score__c score: totalScores){
                if(score.SubjectScore_look__c == id){
                    scoreList.add(score);
                }
            }
            scoreMap.put(id, scoreList);
        }
        List<SubjectScore__c> subjectScores = [
            SELECT Id
            , Student_look__c
            , Semester_look__c
            , Subject_look__c
            , AverageScore__c
            , Status__c
            FROM SubjectScore__c
            WHERE Id IN :subjectScoreIDs
        ];
        for(SubjectScore__c subjectScore : subjectScores){
            Decimal gpa = getGPA(scoreMap.get(subjectScore.Id));
            if(gpa!=null){
                subjectScore.AverageScore__c = gpa;
                if(gpa >= 5){
                    subjectScore.Status__c = 'Passed';
                }
                else{
                    subjectScore.Status__c = 'Not Passed';
                }
            }
        }
        update subjectScores;
    }
    /**
     * getGPA
     * @param    : List<Score__c > ScoresBySubject
     * @return   : Decimal
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified :
     */
    private static Decimal getGPA(List<Score__c> ScoresBySubject){
        Decimal GPA = 0;
        Boolean isProgress = false;
        Boolean isPractical = false;
        Boolean isMidterm = false;
        Boolean isFinal = false;
        Decimal[] gpaArray = new Decimal[]{0, 0, 0, 0};
        for(Score__c score:  ScoresBySubject){
            if(score.ExamType__c.equals('Progress')){
                isProgress = true;
                gpaArray[0] = score.Score__c * 0.1;
            }
            if(score.ExamType__c.equals('Practical')){
                isPractical = true;
                gpaArray[1] = score.Score__c * 0.2;
            }
            if(score.ExamType__c.equals('Midterm Exam')){
                isMidterm = true;
                gpaArray[2] = score.Score__c * 0.2;
            }
            if(score.ExamType__c.equals('FinalTerm Exam')){
                isFinal = true;
                gpaArray[3] = score.Score__c * 0.5;
            }
        }
        if(isPractical && isPractical && isMidterm && isFinal){
            for (Decimal item : gpaArray) {
                GPA += item;
            }
            return GPA;
        }
        return null;
    }
    public  class  CustomException extends Exception {

    }
}