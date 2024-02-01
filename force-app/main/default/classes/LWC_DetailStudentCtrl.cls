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
        List<String> selectedFields = new List<String>{
                'Id'
                , '(SELECT Score__c, ExamType__c FROM Scores__r )'
                , 'Status__c'
                , 'Semester_look__c' 
                , 'Student_look__c'
                , 'AverageScore__c'
                , 'Semester_look__r.Name'
                , 'Subject_look__r.Name'
                , 'Subject_look__r.SubjectCode__c'
                , 'Subject_look__r.CourseCredit__c'
        };
        String queryString = 'SELECT ' + String.join(selectedFields, ', ') + ' FROM SubjectScore__c';
        
        List<String> conditions = new List<String>();
        if (studentId != null) {
            conditions.add('Student_look__c = \'' + studentId + '\'');
        }
        if (semesterId != null) {
            conditions.add('Semester_look__c = \'' + semesterId + '\'');
        }
        queryString += !conditions.isEmpty() ? ' WHERE ' + String.join(conditions, ' AND ')  : '';
        return Database.query(queryString);
    }
    private static List<SemesterResultDto> getSemesterResultDtoMap(Id studentId) {
        List<SubjectScore__c> subjectScoreList = getSubjectScores(studentId, null);
        Map<String, List<SubjectScore__c>> subjectScoreBySemesterMap = new Map<String, List<SubjectScore__c>>();
        Set<String> semKeySet = new Set<String>();
        for(SubjectScore__c subjectScore: subjectScoreList){
            String semKey = subjectScore.Semester_look__r.Name; 
            if(!semKeySet.contains(semKey)){
                semKeySet.add(semKey);
            }
            else{
                subjectScoreBySemesterMap.get(subjectScore.Semester_look__r.Name).add(subjectScore);
            }
        }
        List<SemesterResultDto> semesterResultByIdMap = new List<SemesterResultDto>();
        for(String currentKey: subjectScoreBySemesterMap.keySet()){
            SemesterResultDto temp = getSemesterResultDto(subjectScoreBySemesterMap.get(currentKey));
            semesterResultByIdMap.add(temp);
        }
        return semesterResultByIdMap;
    }
    private static SemesterResultDto getSemesterResultDto(List<SubjectScore__c> subjectScoreList){
        try {
            List<ScoreTableDto> ScoreTableDtoList = new  List<ScoreTableDto>();
            Decimal tongdiemTinChi = 0;
            Decimal tinchiHK = 0;
            String semesterName = '';
            for(SubjectScore__c subjectScore: subjectScoreList ){
                ScoreTableDto obj = new ScoreTableDto();
                obj.SubjectScoreId = subjectScore.Id;
                obj.Status = subjectScore.Status__c;
                obj.AverageScore = subjectScore.AverageScore__c;
                obj.SubjectName = subjectScore.Subject_look__r.Name;
                obj.SubjectCode = subjectScore.Subject_look__r.SubjectCode__c;
                obj.CourseCredit = subjectScore.Subject_look__r.CourseCredit__c;
                semesterName = subjectScore.Semester_look__r.Name;
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
                tinchiHK += subjectScore.Subject_look__r.CourseCredit__c;
                tongdiemTinChi += obj.AverageScore*obj.CourseCredit;
                ScoreTableDtoList.add(obj);
            }
            Decimal trungbinhHK =0;
            if(tinchiHK > 0){
                trungbinhHK = (tongdiemTinChi/tinchiHK).setScale(2,System.RoundingMode.HALF_UP);
            }
            SemesterResultDto result  = new SemesterResultDto();
            result.scoreTableDtoList = ScoreTableDtoList;
            result.trungbinhHK = trungbinhHK;
            result.tinchiHK = tinchiHK;
            result.semesterName = semesterName;
            return result;
            
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting semesters: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static SemesterResultDto getResults(Id studentId, Id semesterId){
        try {
            List<SubjectScore__c> subjectScoreList = getSubjectScores(studentId,semesterId);
            SemesterResultDto semesterResult = getSemesterResultDto(subjectScoreList);
            return semesterResult;
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting semesters: ' + e.getMessage());
        }
    }
    
    public class ScoreTableDto {
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
    public class SemesterResultDto {
        @AuraEnabled
        public List<ScoreTableDto> scoreTableDtoList;
        @AuraEnabled
        public Decimal trungbinhHK;
        @AuraEnabled
        public Decimal tinchiHK;
        @AuraEnabled
        public String semesterName;
        
    }
    
    public class CustomException extends Exception {
        
    }
}