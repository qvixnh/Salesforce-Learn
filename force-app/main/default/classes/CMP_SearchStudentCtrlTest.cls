/**
 * クラス名：   CMP_SearchStudentCtrlTest.cls
 * クラス概要： Search Student Controller Test
 * @created： 2024/02/21 + Nguyen Vinh
 * @modified: 2024/02/22 + Nguyen Vinh
 */
@isTest
public with sharing class CMP_SearchStudentCtrlTest {
    /**
     * testGetClassesOptions
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
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
        List<Class__c> classList = CMP_SearchStudentCtrl.getClassOptions();
        Test.stopTest();
        Assert.areNotEqual(null, classList);
        Assert.areNotEqual(0, classList.size());
    }
    /**
     * testGetStudentDetails
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testGetStudentDetails() {
        Class__c testClass = new CLass__c();
        insert testClass;
        Student__c  stu = createStudent(testClass.Id);
        insert stu;
        Test.startTest();
        Student__c getStu= CMP_SearchStudentCtrl.getStudentDetails(stu.Id);
        Test.stopTest();
        Assert.areNotEqual(stu, getStu);
    }
    /**
     * testGetStudentDetailsCatch
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testGetStudentDetailsCatch() {
        Boolean errorFlag = false;
        Test.startTest();
        try {
            Student__c getStu= CMP_SearchStudentCtrl.getStudentDetails('');
        } catch (Exception e) {
            errorFlag = true;
        }
        Test.stopTest();
        Assert.isTrue(errorFlag);
    }

    /**
     * testGetRecords
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testGetRecords(){
        Class__c testClass = new class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, 100);
        insert stuList;
        Integer pageSize = 10;
        String classId = testClass.Id;
        Integer gender = 0;
        String searchName = 'Test';
        String searchCode= 'SV';
        Integer day = 0;
        Integer year = 0;
        String birthdate = '2000-01-01';
        String orderfield  = 'StudentCode__c';
        String orderType = 'ASC';
        Test.startTest();
        CMP_SearchStudentCtrl.PaginationResult pageR = CMP_SearchStudentCtrl.getRecords(pageSize, classId, gender, searchName, searchCode, 1, 1, 2000, birthdate, orderField, orderType);
        Test.stopTest();
        Assert.areNotEqual(0, pageR.totalRecords);
        Assert.areNotEqual(0, pageR.totalPage);
    }
    /**
     * testGetStudents
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testGetStudents(){
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
        Test.startTest();
        List<Student__c> result = CMP_SearchStudentCtrl.getStudents(classId, gender, searchName, searchCode, 1, 1, 2000, birthdate, orderField, orderType);
        Test.stopTest();
        Assert.areNotEqual(0, result.size());
    }
    /**
     * testDeleteSelectedStudents
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
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
        String result = CMP_SearchStudentCtrl.deleteSelectedStudentsCtrl(studentIds);
        Test.stopTest();
        Assert.areEqual('Success', result);

    }
    /**
     * testDeleteStudent
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteStudent(){
        Class__c testClass = new class__c();
        insert testClass;
        Student__c stu = createStudent(testClass.Id);
        insert stu;
        Test.startTest();
        String result = CMP_SearchStudentCtrl.deleteStudentRecord(stu.Id);
        Test.stopTest();
        Integer sizeAfterDelete = [SELECT COUNT() FROM Student__c WHERE Class_look__c = :testClass.Id];
        Assert.areEqual('Success', result);
        Assert.areEqual(0, sizeAfterDelete);
    }
    /**
     * testDeleteStudentEmptyId
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteStudentEmptyId(){
        Class__c testClass = new class__c();
        insert testClass;
        Test.startTest();
        String result = CMP_SearchStudentCtrl.deleteStudentRecord('');
        Test.stopTest();
        Assert.areEqual('student Id to delete can not be blank', result);
    }
    /**
     * testDeleteStudentNotFound
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testDeleteStudentNotFound(){
        Class__c testClass = new class__c();
        insert testClass;
        Test.startTest();
        String result = CMP_SearchStudentCtrl.deleteStudentRecord('123');
        Test.stopTest();
        Assert.areNotEqual('Student record not found', result);
    }
    /**
     * createStudent
     * @param    : Id classId
     * @return   : Student__c
     * @created  : 2024/02/21 + Nguyen Vinh
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
     * @created  : 2024/02/21 + Nguyen Vinh
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