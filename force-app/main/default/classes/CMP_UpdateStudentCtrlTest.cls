/**
 * クラス名：   CMP_UpdateStudentCtrlTest.cls
 * クラス概要： Update Student Controller Test
 * @created： 2024/02/21 + Nguyen Vinh
 * @modified: 2024/02/21 + Nguyen Vinh
 */
@isTest
public class CMP_UpdateStudentCtrlTest {
    /**
     * testUpdateStudentRec
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testUpdateStudentRec() {
        Class__c testClass = new Class__c();
        insert testClass;
        Student__c  stu = createStudent(testClass.Id);
        insert stu;
        String firstName = 'Updated';
        String lastName = 'Updated';
        String classId = testClass.Id;
        Boolean gender = true;
        String address = 'Test Address';
        Date birthdate = Date.valueOf('2000-01-01');
        Test.startTest();
        String studentId = CMP_UpdateStudentCtrl.updateStudentRec(stu, firstName, lastName , classId, gender, address, birthdate);
        Test.stopTest();
        Assert.areNotEqual(null, studentId);
        Student__c updatedStu = [SELECT Id, Name FROM Student__c WHERE Id = :studentId];
        Assert.areEqual(firstName + ' ' + lastName, updatedStu.Name);
    }
    /**
     * testUpdateStudentRecCatch
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    static void testUpdateStudentRecCatch() {
        Class__c testClass = new Class__c();
        insert testClass;
        Student__c  stu = createStudent(testClass.Id);
        insert stu;
        String firstName = '';
        String lastName = '';
        String classId = testClass.Id;
        Boolean gender = true;
        String address = '';
        Date birthdate = Date.today();
        Boolean errorFlag = false;
        Test.startTest();
        try {
            String studentId = CMP_UpdateStudentCtrl.updateStudentRec(stu, firstName, lastName , classId, gender, address, birthdate);
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
        List<Class__c> classList = CMP_UpdateStudentCtrl.getClasses();
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
