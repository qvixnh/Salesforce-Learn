/**
 * クラス名：   LWC_CreateStudentCtrlTest.cls
 * クラス概要： Create Student Controller Test
 * @created： 2024/02/21 + Nguyen Vinh
 * @modified: 2024/02/21 + Nguyen Vinh
 */
@istest 
public with sharing class LWC_CreateStudentCtrlTest {
    /**
     * testCreateStudentRec
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testCreateStudentRec() {
        Class__c testClass = new Class__c();
        insert testClass;
        String firstName = 'TestFirstName';
        String lastName = 'TestLastName';
        String classId = testClass.Id;
        Boolean gender = true;
        String address = 'Test Address';
        Date birthdate = Date.valueOf('2000-01-01');
        Test.startTest();
        String studentId = LWC_CreateStudentCtrl.createStudentRec(firstName, lastName , classId, gender, address, birthdate);
        Test.stopTest();
        Assert.areNotEqual(null, studentId);
        Student__c createdStudent = [SELECT Id, Name FROM Student__c WHERE Id = :studentId];
        Assert.areEqual(firstName + ' ' + lastName, createdStudent.Name);
    }
    /**
     * testCreateStudentRecCatch
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testCreateStudentRecCatch() {
        Class__c testClass = new Class__c();
        insert testClass;
        String firstName = '';
        String lastName = 'T';
        String classId = testClass.Id;
        Boolean gender = true;
        String address = 'Test Address';
        Date birthdate = Date.valueOf('2000-01-01');
        Boolean errorFlag = false;
        Test.startTest();
        try {
            String studentId = LWC_CreateStudentCtrl.createStudentRec(firstName, lastName , classId, gender, address, birthdate);
        } catch (Exception e) {
            errorFlag = true;
        }
        Test.stopTest();
        Assert.isTrue(errorFlag);
    }
    /**
     * testGetClasses
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testGetClasses() {
        List<Class__c> testClassesList = new List<Class__c>();
        for(Integer i = 0; i< 10; i ++ ){
            Class__c c = new CLass__c();
            testClassesList.add(c);
        }
        insert testClassesList;
        Test.startTest();
        List<Class__c> classList = LWC_CreateStudentCtrl.getClassOptionsToCreate();
        Test.stopTest();
        Assert.areNotEqual(null, classList);
        Assert.areNotEqual(0, classList.size());
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
        stu.Gender__c = true;
        stu.Class_look__c = classId;
        stu.Birthday__c = Date.valueOf('2000-01-01');
        stu.Address__c = 'Test Address';
        return stu;
    }

}