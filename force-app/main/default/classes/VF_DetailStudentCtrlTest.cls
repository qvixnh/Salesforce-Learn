/**
 * クラス名：   VF_DetailStudentCtrlTest .cls
 * クラス概要： Detail Student Test Class
 * @created： 2024/02/20 + Nguyen Vinh
 * @modified:
 */
@isTest
public class VF_DetailStudentCtrlTest {
    @isTest
    private static void testConstructorSuccess() {
        Class__c testClass = new Class__c();
        insert testClass;
        Student__c testStudent = createStudent(testClass.Id);
        insert testStudent;
        ApexPages.currentPage().getParameters().put('id', testStudent.Id);
        Test.startTest();
        VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
        Test.stopTest();
        Assert.areNotEqual(null, controller);
        Assert.areNotEqual(null, controller.student);
        Assert.areEqual('Test FirstName', controller.student.Firstname__c);
        Assert.areEqual('Test LastName', controller.student.Lastname__c);
        Assert.areEqual(testStudent.Id, controller.student.Id);
    }
    /**
     * testConstructorFail
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    static void testConstructorFail() {
        ApexPages.currentPage().getParameters().put('id', '');
        Test.startTest();
        VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
        Test.stopTest();
        Assert.areEqual(null, controller.student);
    }
    /**
     * createStudent
     * @param    :
     * @return   :  Student__c
     * @created  : 2024/02/20 + Nguyen Vinh
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
}
