/**
 * クラス名：   LWC_SearchStudentCtrlTest.cls
 * クラス概要： Search Student Controller Test
 * @created： 2024/02/22 + Nguyen Vinh
 * @modified: 
 */
@isTest
public with sharing class LWC_SearchStudentCtrlTest {
    /**
     * testGetClassesOptions
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testGetClassesOptions() {
        List<Class__c> testClassesList = new List<Class__c>();
        for(Integer i = 0; i< 10; i ++ ){
            Class__c c = new CLass__c();
            testClassesList.add(c);
        }
        insert testClassesList;
        Test.startTest();
        List<Class__c> classList = LWC_SearchStudentCtrl.getClassOptions();
        Test.stopTest();
        Assert.areNotEqual(null, classList);
        Assert.areNotEqual(0, classList.size());
    }
    /**
     * testGetStudentsByCondition
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testGetStudentsByCondition(){
        Class__c testClass = new class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, 100);
        insert stuList;
        String classId = testClass.Id;
        Integer gender = 0;
        String searchName = 'Test';
        String searchCode= 'SV';
        String birthdate = '';
        String orderfield  = 'StudentCode__c';
        String orderType = 'ASC';
        Integer day = 1;
        Integer month = 1;
        Integer  year = 2000;
        // Test search condition JSON
        String searchConditionJSON = '{"searchName":"Test","searchCode":"SV","classId":"' + testClass.Id +
                                    '","gender":0,"birthdate":"2000-01-01","day":' + day +
                                    ',"month":' + month + ',"year":' + year +'}';
        Test.startTest();
        List<Student__c> result = LWC_SearchStudentCtrl.getStudentsByCondition(searchConditionJSON);
        Test.stopTest();
        Assert.areNotEqual(0, result.size());
    }
    /**
     * testDeleteSelectedStudents
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteSelectedStudents(){
        Class__c testClass = new class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, 100);
        insert stuList;
        List<String> studentIds = new List<String>();
        for (Student__c s: stuList) {
            studentIds.add(s.Id);
        }
        Test.startTest();
        LWC_SearchStudentCtrl.deleteSelectedStudentsCtrl(studentIds);
        Test.stopTest();
        List<Student__c>  sl = [SELECT Id FROM Student__c WHERE Class_look__c=: testClass.Id];
        Assert.areEqual(0, sl.size());
    }
    /**
     * testDeleteSelectedStudentsEmpty
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteSelectedStudentsEmpty(){
        List<String> studentIds = new List<String>();
        Boolean errorFlag = false;
        Test.startTest();
        try {
            LWC_SearchStudentCtrl.deleteSelectedStudentsCtrl(studentIds);
        } catch (Exception e) {
            errorFlag = true;
        }
        Test.stopTest();
        Assert.isTrue(errorFlag);

    }
    /**
     * testDeleteStudentRecord
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteStudentRecord(){
        Class__c testClass = new class__c();
        insert testClass;
        Student__c stu = createStudent(testClass.Id);
        insert stu;
        Test.startTest();
        LWC_SearchStudentCtrl.deleteStudentRecord(stu.Id);
        Test.stopTest();
        List<Student__c>  sl = [SELECT Id FROM Student__c WHERE Id =: stu.Id];
        Assert.areEqual(0, sl.size());
    }
    /**
     * testDeleteStudentRecordNotFound
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteStudentRecordNotFound(){
        Boolean errorFlag = false;
        Test.startTest();
        try {
            LWC_SearchStudentCtrl.deleteStudentRecord('123');
        } catch (Exception e) {
            errorFlag = true;
        }
        Test.stopTest();
        Assert.isTrue(errorFlag);
    }
    /**
     * testDeleteStudentRecordEmpty
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteStudentRecordEmpty(){
        Boolean errorFlag = false;
        Test.startTest();
        try {
            LWC_SearchStudentCtrl.deleteStudentRecord(null);
        } catch (Exception e) {
            errorFlag = true;
        }
        Test.stopTest();
        Assert.isTrue(errorFlag);
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
        stu.Class_look__c = classId;
        stu.Birthday__c = Date.valueOf('2000-01-01');
        stu.Address__c = 'Test Address';
        return stu;
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
}