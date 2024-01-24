public without sharing class T02_ScoreTriggerHandler {
    /**
     * onAfterInsert
     * @param    : List<Score__c> newStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    public static void  onAfterInsert(List<Score__c> newScores){
        try {
            countGPA(newScores);
        } catch (Exception e) {
            throw new CustomException('T02_ScoreTriggerHandler: An error occurred onAfterInsert : ' + e.getMessage());
        }
    }
    /**
     * onAfterUpdate
     * @param    : List<Score__c> newStudents,List<Score__c> oldStudents
     * @return   :  
     * @created  : 2023/01/23 + Nguyen Vinh
     * @modified : 
     */
    public static void  onAfterUpdate(List<Score__c> newScores,List<Score__c> oldScore){
        try {
        } catch (Exception e) {
            throw new CustomException('T02_ScoreTriggerHandler: An error occurred onAfterUpdate : ' + e.getMessage());
        }
    }
    private static void countGPA(List<Score__c> newScores){
        Set<Id> subjectScoreIDs = new Set<Id>();
        for (Score__c score : newScores) {
            subjectScoreIDs.add(score.SubjectScore_look__c);
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
            //count gpa here
            Decimal gpa = getGPA();
            if(gpa>0){
                if(gpa>5){
                    subjectScore.Status__c = '' 
                }
            }
        }
    } 
    private static Boolean isCount(SubjectScore__c subjectScore){
        List<Score__c > ScoresBySubject = [
            SELECT Id
            , SubjectScore_look__c										
            , ExamType__c										
            , Score__c										
            FROM Score__c
            WHERE SubjectScore_look__c = :subjectScore.Id
        ];
        Boolean isProgress =false;
        Boolean isPractical = false;
        Boolean isMidterm =false;
        Boolean isFinal =false;
        for(Score__c score:  ScoresBySubject){
            /*
            "'進捗' - 'Progress'
            '実技' - 'Practical'
            '中間試験' - 'Midterm Exam'
            ' 期末試験' - 'FinalTerm Exam'"													
            */
            if(score.ExamType__c == 'Progress'){
                isProgress=true;
            }
            if(score.ExamType__c == 'Practical'){
                isPractical=true;
            }
            if(score.ExamType__c == 'Midterm Exam'){
                isMidterm=true;
            }
            if(score.ExamType__c == 'FinalTerm Exam'){
                isFinal=true;
            }
        }
        return isPractical && isPractical && isMidterm && isFinal;
    } 
    private static Decimal getGPA(SubjectScore__c subjectScore){
        Decimal GPA = 0;
        List<Score__c > ScoresBySubject = [
            SELECT Id
            , SubjectScore_look__c										
            , ExamType__c										
            , Score__c										
            FROM Score__c
            WHERE SubjectScore_look__c = :subjectScore.Id
        ];
        Boolean isProgress =false;
        Boolean isPractical = false;
        Boolean isMidterm =false;
        Boolean isFinal =false;
        Decimal[] gpaArray = new Decimal[]{0, 0, 0, 0};
        for(Score__c score:  ScoresBySubject){
            /*
            "'進捗' - 'Progress'
            '実技' - 'Practical'
            '中間試験' - 'Midterm Exam'
            ' 期末試験' - 'FinalTerm Exam'"													
            */
            if(score.ExamType__c == 'Progress'){
                isProgress=true;
                gpaArray[0] = score.Score__c * 0.1;
            }
            if(score.ExamType__c == 'Practical'){
                isPractical=true;
                gpaArray[1] = score.Score__c * 0.2;

            }
            if(score.ExamType__c == 'Midterm Exam'){
                isMidterm=true;
                gpaArray[2] = score.Score__c * 0.2;
            }
            if(score.ExamType__c == 'FinalTerm Exam'){
                isFinal=true;
                gpaArray[3] = score.Score__c * 0.5;
            }
            
        }
        if(isPractical && isPractical && isMidterm && isFinal){
            for (Decimal gpa : gpaArray) {
                GPA += gpa;
            }
            return GPA;
        }
        return -1;
    } 
    public  class  CustomException extends Exception {
        
    }
}