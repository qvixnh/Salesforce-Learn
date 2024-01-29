/**
 * クラス名：   T02_ScoreTriggerHandler.cls
 * クラス概要： Score Trigger Handler
 * @created： 2023/01/24 + Nguyen Vinh
 * @modified:
 */
public without sharing class T02_ScoreTriggerHandler {
    private static final String PROGRESS = 'Progress';
    private static final String PRACTICAL = 'Practical';
    private static final String MIDTERM = 'Midterm Exam';
    private static final String FINALTERM = 'FinalTerm Exam';
    private static final String PASS = 'Passed';
    private static final String NOTPASS = 'Not Passed';
    private static final String ERROR_TEMPLATE = 'T02_ScoreTriggerHandler: An error occurred {0}: {1}';
    private static final List<String> EXAM_TYPE_LIST = new List<String> {PROGRESS, PRACTICAL,MIDTERM,FINALTERM};
    /**
     * onAfterInsert
     * @param    : List<Score__c> newScores
     * @return   :
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    public static void  onAfterInsert(List<Score__c> newScores){
        try {
            updateStatusAndGPA(newScores);
        } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onAfterInsert',e.getMessage()});
            throw new CustomException(formatted);
        }
    }
    /**
     * onAfterUpdate
     * @param    : List<Score__c> newScores
     * @return   :
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    public static void  onAfterUpdate(List<Score__c> newScores){
        try {
            updateStatusAndGPA(newScores);
        } catch (Exception e) {
            String formatted = String.format(ERROR_TEMPLATE , new List<String> {'onAfterUpdate',e.getMessage()});
            throw new CustomException(formatted);
        }
    }
    /**
     * updateStatusAndGPA
     * @param    : List<Score__c> newScores
     * @return   :
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    private static void updateStatusAndGPA(List<Score__c> newScores){
        Set<Id> subjectScoreIDs = new Set<Id>();
        for (Score__c score : newScores) {
            subjectScoreIDs.add(score.SubjectScore_look__c);
        }
        Map<Id, List<Score__c>> scoreMap = getScoreMap(subjectScoreIDs);
        List<SubjectScore__c> subjectScoresToUpdate = new List<SubjectScore__c>();
        for(Id subjectScoreId : subjectScoreIDs){
            Decimal gpa = getGPA(scoreMap.get(subjectScoreId));
            if(gpa != null){
                SubjectScore__c objectSubjectScore =  new SubjectScore__c();
                objectSubjectScore.AverageScore__c = gpa;
                objectSubjectScore.Id = subjectScoreId;
                if(gpa >= 5){
                    objectSubjectScore.Status__c = PASS;
                }
                else{
                    objectSubjectScore.Status__c = NOTPASS;
                }
                subjectScoresToUpdate.add(objectSubjectScore);
            }
        }
        update subjectScoresToUpdate;
    }

    /**
     * getScoreMap
     * @param    : Set<Id> subjectScoreIDs
     * @return   : Map<Id, List<Score__c>> getScoreMap
     * @created  : 2023/01/25 + Nguyen Vinh
     * @modified :
     */
    private static Map<Id, List<Score__c>> getScoreMap(Set<Id> subjectScoreIDs){
        Map<Id, List<Score__c>> scoreMap = new Map<Id, List<Score__c>>();
        List<Score__c> totalScores=  [
            SELECT Id
            , SubjectScore_look__c
            , ExamType__c
            , Score__c
            FROM Score__c
            WHERE SubjectScore_look__c IN :subjectScoreIDs
                AND Score__c <> NULL
                AND ExamType__c IN :EXAM_TYPE_LIST
            ORDER BY Score__c DESC NULLS LAST
        ];
        for(Score__c score: totalScores){
            if(!scoreMap.containsKey(score.SubjectScore_look__c)){
                scoreMap.put(score.SubjectScore_look__c, new List<Score__c>{score});
            }
            else{
                scoreMap.get(score.SubjectScore_look__c).add(score);
            }
        }
        return scoreMap;
    }

    /**
     * getGPA
     * @param    : List<Score__c > ScoresBySubject
     * @return   : Decimal
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    private static Decimal getGPA(List<Score__c> ScoresBySubject){
        Decimal GPA = 0;
        Set<String> typeSet = new Set<String>();
        Decimal[] gpaArray = new Decimal[]{0, 0, 0, 0};
        for(Score__c score:  ScoresBySubject){
            if(PROGRESS.equals(score.ExamType__c)){
                typeSet.add(PROGRESS);
                gpaArray[0] = score.Score__c * 0.1;
            }
            else if(PRACTICAL.equals(score.ExamType__c)){
                typeSet.add(PRACTICAL);
                gpaArray[1] = score.Score__c * 0.2;
            }
            else if(MIDTERM.equals(score.ExamType__c)){
                typeSet.add(MIDTERM);
                gpaArray[2] = score.Score__c * 0.2;
            }
            else if(FINALTERM.equals(score.ExamType__c)){
                typeSet.add(FINALTERM);
                gpaArray[3] = score.Score__c * 0.5;
            }
            if(typeSet.size() == 4){
                for (Decimal item : gpaArray) {
                    GPA += item;
                }
                GPA = Math.round(GPA * 100) / 100;
                return GPA;
            }
        }
        return null;
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