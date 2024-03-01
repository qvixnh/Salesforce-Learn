/**
 * クラス名：   VF_CreateStudentCtrlTest.cls
 * クラス概要： Create Student Controller Test
 * @created： 2024/02/20 + Nguyen Vinh
 * @modified: 2024/02/21 + Nguyen Vinh
 */
@isTest
public class VF_CreateStudentCtrlTest {
     /**
     * testConstructor
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testConstructor() {
        Class__c testClass = new Class__c();
        insert testClass;
        Test.startTest();
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        Test.stopTest();
        Assert.areNotEqual(null, controller.classListCreate);
        Assert.areNotEqual(0, controller.classListCreate.size());
        Assert.areNotEqual(null, controller.studentToCreate);
    }
     /**
     * testCreateStudent
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 2024/02/21 + Nguyen Vinh
     */
    @isTest
    private static void testCreateStudent() {
        Class__c testClass = new Class__c();
        insert testClass;
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        controller.studentToCreate = createStudent(testClass.Id);
        Test.startTest();
        controller.createStudent();
        Test.stopTest();
        List<Student__c> createdStudents = [
            SELECT 
                Id,
                Firstname__c,
                Lastname__c
            FROM Student__c 
            WHERE Class_Look__c = :testClass.Id
        ];
        Assert.areEqual(1, createdStudents.size());
        Assert.areEqual('Test FirstName', createdStudents[0].Firstname__c);
        Assert.areEqual('Test LastName', createdStudents[0].Lastname__c);
    }
    /**
     * testCreateStudentCatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 2024/03/01 + Nguyen Vinh
     */
    @isTest
    private static void testCreateStudentCatch() {
        Boolean errorFlag = false;
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();

        Test.startTest();
        try {
            controller.createStudent();
        } catch (Exception e) {
            errorFlag = true;
        }
        Test.stopTest();

        Assert.isTrue(errorFlag);
    }
     /**
     * createStudent
     * @param    :
     * @return   :  Student__c
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 2024/02/21 + Nguyen Vinh
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
