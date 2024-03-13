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
    private static void testConstructorSuccess() {
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testConstructorFail
     * @param    : 
     * @return   :  
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testConstructorFail() {
        User userTest = createUser();
        System.runAs(userTest){
            Test.startTest();
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            Test.stopTest();
            Assert.areEqual(null, controller.student);
        }
    }
    /**
     * testUpdateStudent
     * @param    : 
     * @return   :  
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testUpdateStudent() {
        User userTest = createUser();
        System.runAs(userTest){
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
    }
     /**
     * testUpdateStudentCatch
     * @param    : 
     * @return   :  
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testUpdateStudentCatch() {
        User userTest = createUser();
        System.runAs(userTest){
            Boolean errorFlag = false;
            VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
            Test.startTest();
            try {
                PageReference pageRef = controller.updateStudent();
            } catch (Exception e) {
                errorFlag = true;
            }
            Test.stopTest();
            Assert.isTrue(errorFlag);
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
     /**
     * createUser
     * ユーザを作成する
     * @param    : なし
     * @return   : user　ユーザ
     * @created  : 2024/03/13 KSVC Nguyen Quoc VInh
     * @modified :
     */
    private static User createUser() {
        // プロフィール
        List<Profile> profile = [SELECT Id FROM Profile WHERE Name LIKE 'System Administrator'];
        // ユニーク名
        String uniqueName = UserInfo.getOrganizationId() +                  // 組織Id
               Datetime.now().format('yyyyMMddHHmmssSSS') +                 // 今日付/時間
               Integer.valueOf(math.rint(math.random() * (2000000 - 1)));   // ランダム
        // ユーザ
        User user = new User(
            FirstName = uniqueName.subString(29, 34)                        // 名
            , LastName = uniqueName.subString(30, 35)                       // 姓
            , Email = uniqueName + '@keizu.co.jp'                           // メール
            , UserName = uniqueName + '@ke1zu.co.jp'                        // ユーザ名
            , EmailEncodingKey = 'UTF-8'                                    // メールの文字コード
            , Alias = '別名'                                                // 別名
            , TimeZoneSidKey = 'Asia/Tokyo'                                 // タイムゾーン
            , LocaleSidKey = 'ja_JP'                                        // 地域
            , LanguageLocaleKey = 'ja'                                      // 言語
            , ProfileId =  profile[0].Id                                 // プロフィールId
            , PostalCode = '123455789'                                      // 郵便番号
            , Department = 'test'                                           // 部署
            , Phone = '123356789'                                           // 電話
            , Fax = '123446789'                                             // Fax
            , CompanyName  = 'keizu'                                        // 担当者(IS)のユーザ.会社名
        );

        insert user;
        return user;
    }
}