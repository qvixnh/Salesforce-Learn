/**
 * クラス名：   LWC_DetailStudentCtrlTest.cls
 * クラス概要： Detail Student controller Test
 * @created： 2024/02/22 + Nguyen Vinh
 * @modified: 
 */
@isTest
 public with sharing class LWC_DetailStudentCtrlTest {
    private static final String PROGRESS = 'Progress';
    private static final String PRACTICAL = 'Practical';
    private static final String MIDTERM = 'Midterm Exam';
    private static final String FINALTERM = 'FinalTerm Exam';
     /**
     * testGetSemesterOptions
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testGetSemesterOptions(){
        List<Semester__c> semesterList = new List<Semester__c>();
        for(Integer i = 0; i< 10; i++){
            Semester__c s  = new Semester__c();
            semesterList.add(s);
        }
        insert semesterList;
        Test.startTest();
        List<Semester__c> sl = LWC_DetailStudentCtrl.getSemesterOptions();
        Test.stopTest();
        Assert.areEqual(10, sl.size());
    }
    /**
     * testGetResults
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testGetResults(){
        Class__c testCls = new Class__c();
        insert testCls;
        Semester__c testSemester = new Semester__c();
        insert testSemester;
        Student__c stu = createStudent(testCls.Id);
        insert stu;
        List<Subject__c> subList = createSubjectList();
        insert subList;
        List<Semester__c> semesterList = createSemList();
        insert semesterList;
        List<SubjectScore__c> subScoreList = createSubScoreList(stu, semesterList, subList);
        insert subScoreList;
        List<Score__c> scoreList = createScoreList(subScoreList);
        insert scoreList;
        Test.startTest();
        List<LWC_DetailStudentCtrl.SemesterResultDto> semResult= LWC_DetailStudentCtrl.getResults(stu.Id, null);
        Test.stopTest();
        Assert.areNotEqual(0, semResult.size());
        Assert.areNotEqual(0, semResult[0].scoreTableDtoList.size());
        Assert.areNotEqual(0, semResult[0].semesterCredit);
        Assert.areNotEqual(null, semResult[0].semesterName);
    }
    /**
     * createStudentList
     * @param    : Id classId, Integer size
     * @return   : List<Student__c>
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static List<Student__c> createStudentList(Id classId, Integer size){
        List<Student__c> stuList = new List<Student__c>();
        for(Integer i = 1; i <= size; i++ ){
            Student__c s = createStudent(classId);
            stuList.add(s);
        }
        return stuList;
    }
    /**
     * createStudent
     * @param    : Id classId
     * @return   : Student__c
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static Student__c createStudent(Id classId){
        Student__c stu = new Student__c();
        stu.Name = 'Test';
        stu.Firstname__c = 'Test FirstName';
        stu.Lastname__c = 'Test LastName';
        stu.Gender__c = true;
        stu.Class_look__c = classId;
        stu.Birthday__c = Date.valueOf('2000-01-01');
        stu.Address__c = 'Test Address';
        return stu;
    }
    /**
     * createSubjectList
     * @param    : 
     * @return   : List<Subject__c>
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static List<Subject__c> createSubjectList(){
        List<Subject__c> subList = new List<Subject__c>();
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(2));
        subList.add(createSubject(3));
        subList.add(createSubject(4));
        return subList;
    }
    /**
     * createSemList
     * @param    : createSemList
     * @return   : List<Semester__c>
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static List<Semester__c> createSemList(){
        List<Semester__c> semesterList = new List<Semester__c>();
        for(Integer i = 0; i< 10; i++){
            Semester__c s  = new Semester__c();
            semesterList.add(s);
        }
        return semesterList;
    }
    /**
     * createSubject
     * @param    : Integer credit
     * @return   : Subject__c
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static Subject__c createSubject(Integer credit){
        Subject__c sub = new Subject__c();
        sub.CourseCredit__c = credit;
        return sub;
    }
     /**
     * createSubScoreList
     * @param    : Student__c student, List<Semester__c> semList, List<Subject__c> subList
     * @return   : List<SubjectScore__c>
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static List<SubjectScore__c> createSubScoreList(Student__c student, List<Semester__c> semList, List<Subject__c> subList){
        Integer semSize = semList.size();
        Integer subSize = subList.size();
        List<SubjectScore__c> subjectScoreObjList = new List<SubjectScore__c>();
        Set<Id> semesterSet = new Set<Id>();
        while (semesterSet.size() < 2) {
            Id currentSemester = semList[getRandomNumber(semSize)].Id;
            if (!semesterSet.contains(currentSemester)) {
                Set<Id> subjectSet = new Set<Id>();
                Decimal totalCredit = 0;
                while (subjectSet.size() < 5) {
                    Subject__c currentSubject = subList[getRandomNumber(subSize)];
                    if (!subjectSet.contains(currentSubject.Id)){
                        SubjectScore__c subjectScoreObj = createSubjectScore(currentSubject.Id, currentSemester, student.Id);
                        subjectScoreObjList.add(subjectScoreObj);
                        totalCredit+=currentSubject.CourseCredit__c;
                        subjectSet.add(currentSubject.Id);
                    }
                }
                semesterSet.add(currentSemester);
            }
        }
        return  subjectScoreObjList;
    }
    /**
     * createScoreList
     * @param    : List<SubjectScore__c> subjectScoreObjList
     * @return   : List<Score__c>
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static List<Score__c> createScoreList(List<SubjectScore__c> subjectScoreObjList){
        List<Score__c> scoreList = new List<Score__c>();
        for(SubjectScore__c subjectScoreObj: subjectScoreObjList){
            List<Score__c> scoreListBySubScoreId = getScoreListBySubId(subjectScoreObj.Id);
            if(!scoreListBySubScoreId.isEmpty()){
                scoreList.addAll(scoreListBySubScoreId);
            }
        }
        return scoreList;
    }
     /**
     * getRandomNumber
     * @param    : Integer listSize
     * @return   : Integer
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static Integer getRandomNumber(Integer listSize){
        Integer ranNumber = (Integer) Math.floor(Math.random() * listSize);
        return ranNumber;
    }
    /**
     * createSubjectScore
     * @param    : Id subId, Id semId, Id stuId
     * @return   : SubjectScore__c
     * @created  : 2024/02/22 + Nguyen Vinh
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
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    private static Score__c createScore(Id subScoreId, String type){
        Score__c score = new Score__c();
        score.SubjectScore_look__c = subScoreId;
        Integer randomNumber = Integer.valueOf(Math.floor(Math.random() * 10) + 1);
        score.Score__c = randomNumber;
        score.ExamType__c = type;
        return score;
    }
    /**
     * getScoreListBySubId
     * @param    : Id subScoreId
     * @return   : List<Score__c>
     * @created  : 2024/02/22 + Nguyen Vinh
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