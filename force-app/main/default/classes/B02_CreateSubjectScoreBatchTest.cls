/**
 * クラス名：   B02_CreateSubjectScoreBatchTest.cls
 * クラス概要： B02 Create Subject Score Batch Test
 * @created： 2024/02/22 + Nguyen Vinh
 * @modified: 2024/02/23 + Nguyen Vinh
 */
@isTest
public with sharing class B02_CreateSubjectScoreBatchTest {
    /**
     * setUp
     * @param    :
     * @return   :
     * @created  : 2024/02/23 + Nguyen Vinh
     * @modified :
     */
    private static void setUp(){
        Class__c testCls = new Class__c();
        insert testCls;
        Semester__c testSemester = new Semester__c();
        insert testSemester;
        List<Student__c> stu = createStudentList(testCls.Id, 150);
        insert stu;
        List<Subject__c> subList = createSubjectList();
        insert subList;
        List<Semester__c> semesterList = createSemList();
        insert semesterList;
    }
    /**
     * testExecuteBatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 2024/02/23 + Nguyen Vinh
     */
    @isTest
    private static void testExecuteBatch(){
        setUp();
        Test.startTest();
        B02_CreateSubjectScoreBatch batch = new B02_CreateSubjectScoreBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        Integer newSubScoreSize = [SELECT COUNT() FROM SubjectScore__c];
        Assert.areNotEqual(0, newSubScoreSize);
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
        for(Integer i = 0; i< 3; i++){
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
}