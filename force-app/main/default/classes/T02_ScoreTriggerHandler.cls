/**
 * クラス名：   T02_ScoreTriggerHandler.cls
 * クラス概要： Score Trigger Handler
 * @created： 2024/01/24 + Nguyen Vinh
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
     * @created  : 2024/01/24 + Nguyen Vinh
     * @modified : 2024/01/25 + Nguyen Vinh
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
     * @created  : 2024/01/24 + Nguyen Vinh
     * @modified : 2024/01/25 + Nguyen Vinh
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
     * @created  : 2024/01/24 + Nguyen Vinh
     * @modified : 2024/01/25 + Nguyen Vinh
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
     * @created  : 2024/01/25 + Nguyen Vinh
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
            ORDER BY Score__c DESC
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
     * @created  : 2024/01/24 + Nguyen Vinh
     * @modified : 2024/01/25 + Nguyen Vinh
     */
    private static Decimal getGPA(List<Score__c> ScoresBySubject) {
        Decimal GPA = 0;
        Map<String, Decimal> typeToWeightMap = new Map<String, Decimal>{
            PROGRESS => 0.1,
            PRACTICAL => 0.2,
            MIDTERM => 0.2,
            FINALTERM => 0.5
        };
        Set<String> typeSet = new Set<String>();
        for (Score__c score : ScoresBySubject) {
            Decimal weight = typeToWeightMap.get(score.ExamType__c);
            if (weight != null && !typeSet.contains(score.ExamType__c)) {
                typeSet.add(score.ExamType__c);
                GPA += score.Score__c * weight;
            }
           
        }
        
        if (typeSet.size() < 4) {
            return null;
        }
        return GPA.setScale(2, System.RoundingMode.HALF_UP);
    }
    
    /**
     * クラス名：   CustomException
     * クラス概要： Custom Exception
     * @created： 2024/01/24 + Nguyen Vinh
     * @modified:
     */
    public class CustomException extends Exception {

    }
}