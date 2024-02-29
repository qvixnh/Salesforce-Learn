/**
 * クラス名：   VF_SearchStudentCtrlTest.cls
 * クラス概要： Search Student Controller Test
 * @created： 2024/02/20 + Nguyen Vinh
 * @modified:
 */
@isTest
public with sharing class VF_SearchStudentCtrlTest {
    private static final Integer LISTSIZE = 100;
    private static void setUp(){
        Class__c testClass = new Class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, LISTSIZE );
        insert stuList;
    }
    /**
     * testConstructor
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testConstructor() {
        setUp();
        Test.startTest();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Test.stopTest();
        Assert.areNotEqual(0, controller.classList.size());
        Assert.areNotEqual(0, controller.monthOptions.size());
        Assert.areNotEqual(0, controller.dayOptions.size());
        Assert.areNotEqual(null, controller.selectedIds);
        Assert.areNotEqual(0, controller.searchResults.size(), 'expected search result size');
        //test pagination in constructor
        Assert.areEqual(LISTSIZE, controller.totalRecords, 'expected total records size');
        Assert.areEqual(10, controller.totalPages, 'expected total pages');
        Assert.areNotEqual(0, controller.pageNumbers.size());

    }
    /**
     * testPerformSearchAll
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testPerformSearchAll() {
        setUp();
        Test.startTest();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.performSearch();
        Test.stopTest();
        Assert.areEqual(LISTSIZE, controller.totalRecords, 'expected total records size');
    }
    /**
     * testPerformSearchByCondition
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testPerformSearchByCondition() {
        Class__c testClass = new Class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, LISTSIZE );
        insert stuList;
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.gender = 1;
        controller.birthdate = Date.valueOf('2000-01-01');
        controller.searchCode = 'SV_';
        controller.searchSelectedClass = testClass.Id;
        Test.startTest();
        controller.performSearch();
        Test.stopTest();
        Assert.areEqual(LISTSIZE, controller.totalRecords, 'expected total records size');
    }
    /**
     * testPerformSearchByDayMonthYear
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testPerformSearchByDayMonthYear() {
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.day = 1;
        controller.month = 1;
        controller.year = 2000;
        Test.startTest();
        controller.performSearch();
        Test.stopTest();
        Assert.areEqual(LISTSIZE, controller.totalRecords, 'expected total records size');
    }
     /**
     * testClearFilters
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testClearFilters() {
        Class__c testClass = new Class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, LISTSIZE );
        insert stuList;
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.gender = 1;
        controller.birthdate = Date.valueOf('2000-01-01');
        controller.searchCode = 'SV_';
        controller.searchSelectedClass = testClass.Id;
        Test.startTest();
        PageReference pr =  controller.clearFilters();
        Test.stopTest();
        Assert.areEqual(null, pr);
    }
     /**
     * testPerformSearchByFirstName
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testPerformSearchByFirstName() {
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchName= 'Test FirstName';
        Test.startTest();
        controller.performSearch();
        Test.stopTest();
        Assert.areEqual(LISTSIZE, controller.totalRecords, 'expected total records size');
    }
    /**
     * testDeleteSelectedRecords
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testDeleteSelectedRecords() {
        Class__c testClass = new Class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, 10);
        insert stuList;
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        for(Integer i = 0; i <stuList.size() ; i++) {
            controller.selectedIds.put(stuList[i].Id, true);
        }
        Test.startTest();
        controller.deleteSelectedRecords();
        Test.stopTest();
        List<Student__c> remainingStudents = [SELECT Id FROM Student__c];
        Assert.areEqual(0, remainingStudents.size(), 'No student should remain after deletion');
        List<ApexPages.Message> messages = ApexPages.getMessages();
        Assert.areEqual(1, messages.size(), 'Expected one message');
        Assert.areEqual(ApexPages.Severity.INFO, messages[0].getSeverity(), 'Message severity should be INFO');
        Assert.areEqual('Selected records deleted successfully.', messages[0].getSummary(), 'Message summary should match');
    }
    
    /**
     * testCreateStudent
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testCreateStudent() {
        Class__c testClass = new Class__c();
        insert testClass;
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Student__c stu = createStudent(testClass.Id);
        controller.studentToCreate = stu;
        Test.startTest();
        controller.createStudent();
        Test.stopTest();
        List<Student__c> createdStudents = [SELECT Id FROM Student__c WHERE Class_Look__c = :testClass.Id];
        Assert.areEqual(1, createdStudents.size());
        Student__c obj = new Student__c();
        Assert.areEqual(obj, controller.studentToCreate);
    }
    /**
     * testCreateStudent
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testSetStudent() {
        Class__c testClass = new Class__c();
        insert testClass;
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Student__c stu = createStudent(testClass.Id);
        insert stu;
        controller.selectedId = stu.Id;
        Test.startTest();
        controller.setStudent();
        Test.stopTest();
        Assert.areEqual(stu.Id, controller.student.Id);
    }
    /**
     * testDeleteStudent
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testDeleteStudent() {
        Class__c testClass = new Class__c();
        insert testClass;
        List<Student__c> stuList = createStudentList(testClass.Id, LISTSIZE );
        insert stuList;
        Student__c stuToDelete = createStudent(testClass.Id);
        insert stuToDelete;
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.selectedId = stuToDelete.Id;
        Id oldStudentId = stuToDelete.Id;
        Test.startTest();
        controller.deleteStudent();
        Test.stopTest();
        List<Student__c> deletedStudent = [SELECT Id FROM Student__c WHERE Id = :oldStudentId];
        Assert.areEqual(0, deletedStudent.size());
    }
    /**
     * testCreateStudent
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testUpdateStudent() {
        Class__c testClass = new Class__c();
        insert testClass;
        Student__c stuToUpdate = createStudent(testClass.Id);
        insert stuToUpdate;
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.selectedId = stuToUpdate.Id;
        controller.setStudent();
        controller.student.Firstname__c = 'Updated';
        controller.student.LastName__c = 'Updated';
        Id oldStudentId = stuToUpdate.Id;
        Test.startTest();
        controller.updateStudent();
        Test.stopTest();
        Student__c updatedStudent = [SELECT Id,FirstName__c FROM Student__c WHERE Id = :oldStudentId];
        Assert.areEqual('Updated', updatedStudent.Firstname__c);
    }
    /**
     * testFirst
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testFirst(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Test.startTest();
        PageReference pr = controller.first();
        Test.stopTest();
        Assert.areEqual(null, pr);
        Assert.areEqual(0, controller.startIndex);
        Assert.areEqual(1, controller.currentPage);
        Assert.areEqual(false, controller.allSelected);
    }
    /**
     * testPrevious
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testPrevious(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.currentPage = 2;
        controller.gotoPage();
        Test.startTest();
        PageReference pr = controller.previous();
        Test.stopTest();
        Assert.areEqual(null, pr);
        Assert.areEqual(0, controller.startIndex);
        Assert.areEqual(1, controller.currentPage);
        Assert.areEqual(false, controller.allSelected);
    }
    /**
     * testNext
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testNext(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.currentPage = 2;
        controller.gotoPage();
        Test.startTest();
        PageReference pr = controller.next();
        Test.stopTest();
        Assert.areEqual(null, pr);
        Assert.areEqual(20, controller.startIndex);
        Assert.areEqual(3, controller.currentPage);
        Assert.areEqual(false, controller.allSelected);
    }
    /**
     * testLast
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testLast(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Test.startTest();
        PageReference pr = controller.last();
        Test.stopTest();
        Assert.areEqual(null, pr);
        Assert.areEqual(90, controller.startIndex);
        Assert.areEqual(10, controller.currentPage);
        Assert.areEqual(false, controller.allSelected);
    }
    /**
     * testGoToPage
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testGoToPage(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.currentPage  = 2;
        Test.startTest();
        PageReference pr = controller.gotoPage();
        Test.stopTest();
        Assert.areEqual(null, pr);
        Assert.areEqual(10, controller.startIndex);
        Assert.areEqual(false, controller.allSelected);
    }
    /**
     * testClearRecords
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testClearRecords(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Test.startTest();
        controller.clearRecords();
        Test.stopTest();
        Assert.areEqual(0, controller.selectedRecordsNumber);
        Assert.areEqual(false, controller.allSelected);
    }
    /**
     * testGetHasPrevious
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testGetHasPrevious(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.currentPage = 2;
        controller.gotoPage();
        Test.startTest();
        Boolean hasPre = controller.getHasPrevious();
        Boolean hasNext = controller.getHasNext();
        Test.stopTest();
        Assert.areEqual(true, hasPre);
        Assert.areEqual(true, hasNext);
    }
    /**
     * testSelectAllCheckBoxes
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testSelectAllCheckBoxes(){
        setUp();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.currentPage = 2;
        controller.gotoPage();
        Test.startTest();
        controller.selectAllCheckboxesTable();
        Test.stopTest();
        Assert.areNotEqual(0, controller.selectedIds.size());
    }
    /**
     * testSelectAllCheckBoxes
     * @param    :
     * @return   :
     * @created  : 2024/02/21 + Nguyen Vinh
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