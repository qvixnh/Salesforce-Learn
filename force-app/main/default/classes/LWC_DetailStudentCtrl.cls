public with sharing class LWC_DetailStudentCtrl {
    private static final String PROGRESS = 'Progress';
    private static final String PRACTICAL = 'Practical';
    private static final String MIDTERM = 'Midterm Exam';
    private static final String FINALTERM = 'FinalTerm Exam';
    @AuraEnabled(cacheable=true)
    public static List<Semester__c> getSemesterOptions() {
        List<Semester__c> semesterList = new List<Semester__c>();
        try {
            semesterList = [SELECT 
                            Id
                            , Name
                            , StartDate__c
                            , EndDate__c 
                        FROM Semester__c 
                        ORDER BY Name];
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting semesters: ' + e.getMessage());
        }
        return semesterList;
    }
    private static List<SubjectScore__c> getSubjectScores(Id studentId, Id semesterId) {
        List<SubjectScore__c> subjectScoreList = new List<SubjectScore__c>();
        try {
                subjectScoreList = [
                    SELECT 
                        Id
                        , (SELECT Score__c, ExamType__c FROM Scores__r )
                        , Status__c
                        , Semester_look__c 
                        , Student_look__c
                        , AverageScore__c
                        , Subject_look__r.Name
                        , Subject_look__r.SubjectCode__c
                        , Subject_look__r.CourseCredit__c
                    FROM SubjectScore__c    
                    WHERE Student_look__c = :studentId 
                        AND Semester_look__c = :semesterId
                ];
                return subjectScoreList;
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting semesters: ' + e.getMessage());

        }
    }
    @AuraEnabled
    public static List<ScoreTableDto> getScoreTableDtoList(Id studentId, Id semesterId){
        try {
            List<ScoreTableDto> ScoreTableDtoList = new  List<ScoreTableDto>();
            List<SubjectScore__c> subjectScoreList = getSubjectScores(studentId,semesterId );
            for(SubjectScore__c subjectScore: subjectScoreList ){
                ScoreTableDto obj = new ScoreTableDto();
                obj.SubjectScoreId = subjectScore.Id;
                obj.Status = subjectScore.Status__c;
                obj.AverageScore = subjectScore.AverageScore__c;
                obj.SubjectName = subjectScore.Subject_look__r.Name;
                obj.SubjectCode = subjectScore.Subject_look__r.SubjectCode__c;
                obj.CourseCredit = subjectScore.Subject_look__r.CourseCredit__c;
                for(Score__c score: subjectScore.Scores__r){
                    if(PROGRESS.equals(score.ExamType__c)){
                        obj.ProgressScore = score.Score__c;
                    }
                    else if(PRACTICAL.equals(score.ExamType__c)){
                        obj.PracticalScore = score.Score__c;
                    }
                    else if(MIDTERM.equals(score.ExamType__c)){
                        obj.MidtermScore = score.Score__c;
                    }
                    else if(FINALTERM.equals(score.ExamType__c)){
                        obj.FinalScore = score.Score__c;
                    }
                }
                ScoreTableDtoList.add(obj);
            }
            return ScoreTableDtoList;
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting semesters: ' + e.getMessage());
        }
    }
    
    public  class  ScoreTableDto {
        
        @AuraEnabled
        public Id SubjectScoreId;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public Decimal AverageScore;
        @AuraEnabled
        public String SubjectName;
        @AuraEnabled
        public String SubjectCode;
        @AuraEnabled
        public Decimal CourseCredit;
        @AuraEnabled
        public Decimal ProgressScore;
        @AuraEnabled
        public Decimal PracticalScore;
        @AuraEnabled
        public Decimal MidtermScore;
        @AuraEnabled
        public Decimal FinalScore;
    }
    public  class  SemesterResultDto {
        @AuraEnabled
        public List<ScoreTableDto> scoreTableDtoList;
        @AuraEnabled
        public Decimal trungbinhHK;
        @AuraEnabled
        public Decimal tinchiHK;
        
    }
    public  class  CustomException extends Exception {
        
    }
}