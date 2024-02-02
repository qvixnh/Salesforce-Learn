/**
 * クラス名：   LWC_DetailStudentCtrl.cls
 * クラス概要： Detail Student controller
 * @created： 2023/01/31 + Nguyen Vinh
 * @modified: 2023/02/01 + Nguyen Vinh
 */
public with sharing class LWC_DetailStudentCtrl {
    private static final String PROGRESS = 'Progress';
    private static final String PRACTICAL = 'Practical';
    private static final String MIDTERM = 'Midterm Exam';
    private static final String FINALTERM = 'FinalTerm Exam';
    private static final String PASS = 'Passed';
    /**
     * getSemesterOptions
     * @param    : 
     * @return   : List<Semester__c>
     * @created  : 2023/01/31 + Nguyen Vinh
     * @modified : 
     */
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
    /**
     * getResults
     * @param    : Id studentId, Id semesterId
     * @return   : List<SemesterResultDto>
     * @created  : 2023/01/31 + Nguyen Vinh
     * @modified : 2023/02/01 + Nguyen Vinh
     */
    @AuraEnabled
    public static List<SemesterResultDto> getResults(Id studentId, Id semesterId){
        try {
            List<SubjectScore__c> subjectScoreList = getSubjectScores(studentId, semesterId);
            List<SemesterResultDto> resultDtoList = getSemesterResultDtoList(subjectScoreList);
            return resultDtoList;
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting semesters results dto list: ' + e.getMessage());
        }
    }
    /**
     * getResults
     * @param    : Id studentId, Id semesterId
     * @return   : List<SubjectScore__c>
     * @created  : 2023/01/31 + Nguyen Vinh
     * @modified : 2023/02/01 + Nguyen Vinh
     */
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
        List<SubjectScore__c> subjectScoreList = Database.query(queryString);
        return subjectScoreList;
    }
    /**
     * getSemesterResultDtoList
     * @param    : List<SubjectScore__c> subjectScoreList
     * @return   : List<SemesterResultDto>
     * @created  : 2023/01/31 + Nguyen Vinh
     * @modified : 2023/02/01 + Nguyen Vinh
     */
    private static List<SemesterResultDto> getSemesterResultDtoList(List<SubjectScore__c> subjectScoreList) {
        Map<String, List<SubjectScore__c>> subjectScoreBySemesterMap = getSubjectScoreBySemesterMap(subjectScoreList);
        List<SemesterResultDto> returnedMap = new List<SemesterResultDto>();
        for(String currentKey: subjectScoreBySemesterMap.keySet()){
            SemesterResultDto temp = getSemesterResultDto(currentKey,subjectScoreBySemesterMap.get(currentKey));
            returnedMap.add(temp);
        }
        return returnedMap;

    }
    /**
     * getSubjectScoreBySemesterMap
     * @param    : List<SubjectScore__c> subjectScoreList
     * @return   : Map<String, List<SubjectScore__c>>
     * @created  : 2023/01/31 + Nguyen Vinh
     * @modified : 2023/02/01 + Nguyen Vinh
     */
    private static Map<String, List<SubjectScore__c>> getSubjectScoreBySemesterMap(List<SubjectScore__c> subjectScoreList){
        Map<String, List<SubjectScore__c>> subjectScoreBySemesterMap = new Map<String, List<SubjectScore__c>>();
        for(SubjectScore__c subjectScore: subjectScoreList){
            String semesterKey = subjectScore.Semester_look__r.Name;
            if(!subjectScoreBySemesterMap.containsKey(semesterKey)){
                subjectScoreBySemesterMap.put(semesterKey, new List<SubjectScore__c>{subjectScore});
            }else{
                subjectScoreBySemesterMap.get(semesterKey).add(subjectScore);
            }
        }

        return subjectScoreBySemesterMap;
    }
    /**
     * getSemesterResultDto
     * @param    : String semesterName,List<SubjectScore__c> subjectScoreList
     * @return   : SemesterResultDto
     * @created  : 2023/01/31 + Nguyen Vinh
     * @modified : 2023/02/01 + Nguyen Vinh
     */
    private static SemesterResultDto getSemesterResultDto(String semesterName,List<SubjectScore__c> subjectScoreList){
        List<ScoreTableDto> ScoreTableDtoList = new  List<ScoreTableDto>();
        Decimal tongdiemTinChi = 0;
        Decimal semesterCredit = 0;
        Decimal semesterScore = 0;
        for(SubjectScore__c subjectScore: subjectScoreList ){
            ScoreTableDto obj = createScoreTableDto(subjectScore);
            semesterCredit += subjectScore.Subject_look__r.CourseCredit__c;
            tongdiemTinChi += obj.AverageScore*obj.CourseCredit;
            ScoreTableDtoList.add(obj);
        }
        if(semesterCredit > 0){
            semesterScore = (tongdiemTinChi / semesterCredit).setScale(2,System.RoundingMode.HALF_UP);
        }
        SemesterResultDto result  = new SemesterResultDto(ScoreTableDtoList, semesterScore, semesterCredit, semesterName);
        return result;
    }
    /**
     * createScoreTableDto
     * @param    : SubjectScore__c subjectScore
     * @return   : ScoreTableDto
     * @created  : 2023/01/31 + Nguyen Vinh
     * @modified : 2023/02/01 + Nguyen Vinh
     */
    private static ScoreTableDto createScoreTableDto(SubjectScore__c subjectScore){
        ScoreTableDto obj = new ScoreTableDto(
                                        subjectScore.Id,subjectScore.Subject_look__r.SubjectCode__c
                                        , subjectScore.Subject_look__r.Name
                                        ,  subjectScore.Subject_look__r.CourseCredit__c
                                        , subjectScore.AverageScore__c 
                                    );
        obj.isPassed = PASS.equals(subjectScore.Status__c) ? true : false;
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
        return obj;
    }
    /**
     * クラス名：   ScoreTableDto
     * クラス概要： Score Table Dto
     * @created： 2023/01/31 + Nguyen Vinh
     * @modified:
     */
    public class ScoreTableDto {
        @AuraEnabled
        public Id SubjectScoreId;
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
        @AuraEnabled
        public Boolean isPassed;
        public ScoreTableDto(){}
        public ScoreTableDto(Id subjectScoreId,String subjectName ,String subjectCode, Decimal courseCredit, Decimal averageScore){
            this.SubjectScoreId = subjectScoreId;
            this.SubjectName = subjectName;
            this.SubjectCode = subjectCode;
            this.CourseCredit = courseCredit;
            this.AverageScore = averageScore;
        }
    }
    /**
     * クラス名：   SemesterResultDto
     * クラス概要： Semester Result Dto
     * @created： 2023/02/01 + Nguyen Vinh
     * @modified:
     */
    public class SemesterResultDto {
        @AuraEnabled
        public List<ScoreTableDto> scoreTableDtoList;
        @AuraEnabled
        public Decimal semesterScore;
        @AuraEnabled
        public Decimal semesterCredit;
        @AuraEnabled
        public String semesterName;
        public SemesterResultDto(){}
        public SemesterResultDto(List<ScoreTableDto> scoreTableDtoList, Decimal semesterScore, Decimal semesterCredit, String semesterName){
            this.scoreTableDtoList = scoreTableDtoList;
            this.semesterScore = semesterScore;
            this.semesterCredit = semesterCredit;
            this.semesterName = semesterName;
        }
    }

    public class CustomException extends Exception {

    }
}