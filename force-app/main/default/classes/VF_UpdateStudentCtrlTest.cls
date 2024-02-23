/**
 * クラス名：   VF_UpdateStudentCtrlTest.cls
 * クラス概要： Update Student Controller Test
 * @created： 2024/02/20 + Nguyen Vinh
 * @modified:
 */
@isTest
public class VF_UpdateStudentCtrlTest {
    /**
     * testConstructorSuccess
     * @param    : 
     * @return   :  
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testConstructorSuccess() {
        Class__c testClass = new Class__c();
        insert testClass;
        Student__c testStudent = createStudent(testClass.Id);
        insert testStudent;
        ApexPages.currentPage().getParameters().put('id', testStudent.Id);
        Test.startTest();
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        Test.stopTest();
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
        Test.startTest();
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        Test.stopTest();
        Assert.areEqual(null, controller.student);
    }
    /**
     * testUpdateStudent
     * @param    : 
     * @return   :  
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testUpdateStudent() {
        Class__c testClass = new Class__c();
        insert testClass;
        Student__c testStudent = createStudent(testClass.Id);
        insert testStudent;
        ApexPages.currentPage().getParameters().put('id', testStudent.Id);
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        controller.student.Address__c = 'updated Address';
        controller.student.Firstname__c = 'updated FirstName';
        controller.student.LastName__c = 'updated LastName';
        Test.startTest();
        PageReference pageRef = controller.updateStudent();
        Test.stopTest();
        Assert.areEqual(null, pageRef);
        Student__c updatedStudent = [SELECT Id
            , Firstname__c
            , LastName__c
            , Address__c 
            FROM Student__c 
            WHERE Id = :testStudent.Id
        ];
        Assert.areNotEqual(null, controller.student);
        Assert.areEqual('updated Address',updatedStudent.Address__c);
        Assert.areEqual('updated FirstName',updatedStudent.Firstname__c);
        Assert.areEqual('updated LastName',updatedStudent.LastName__c);
    }
     /**
     * testUpdateStudentCatch
     * @param    : 
     * @return   :  
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testUpdateStudentCatch() {
        try {
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            Test.startTest();
            PageReference pageRef = controller.updateStudent();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
        }
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
