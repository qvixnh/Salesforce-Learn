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
        User userTest = createUser();
        System.runAs(userTest){
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
            ApexPages.currentPage().getParameters().put('id', '');
            Test.startTest();
            VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
            Test.stopTest();
            Assert.areEqual(null, controller.student);
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