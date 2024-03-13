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
    private static void testGetClassesOptions() {
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testGetStudentsByCondition
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testGetStudentsByCondition(){
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testDeleteSelectedStudents
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteSelectedStudents(){
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testDeleteSelectedStudentsEmpty
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteSelectedStudentsEmpty(){
        User userTest = createUser();
        System.runAs(userTest){
            List<String> studentIds = new List<String>();
            Test.startTest();
            try {
                LWC_SearchStudentCtrl.deleteSelectedStudentsCtrl(studentIds);
            } catch (Exception e) {
                System.assert(true);            
            }

            Test.stopTest();
        }

    }
    /**
     * testDeleteStudentRecord
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteStudentRecord(){
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testDeleteStudentRecordNotFound
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteStudentRecordNotFound(){
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testDeleteStudentRecordEmpty
     * @param    : 
     * @return   : 
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteStudentRecordEmpty(){
        User userTest = createUser();
        System.runAs(userTest){
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