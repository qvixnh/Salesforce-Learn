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
            List<Class__c> classList = CMP_SearchStudentCtrl.getClassOptions();
            Test.stopTest();
            Assert.areNotEqual(null, classList);
            Assert.areNotEqual(0, classList.size());
        }
    }
    /**
     * testGetStudentDetails
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testGetStudentDetails() {
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new CLass__c();
            insert testClass;
            Student__c  stu = createStudent(testClass.Id);
            insert stu;
            Test.startTest();
            Student__c getStu= CMP_SearchStudentCtrl.getStudentDetails(stu.Id);
            Test.stopTest();
            Assert.areNotEqual(stu, getStu);
        }
    }
    /**
     * testGetStudentDetailsCatch
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testGetStudentDetailsCatch() {
        User userTest = createUser();
        System.runAs(userTest){
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
    }

    /**
     * testGetRecords
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testGetRecords(){
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testGetStudents
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testGetStudents(){
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
            Test.startTest();
            List<Student__c> result = CMP_SearchStudentCtrl.getStudents(classId, gender, searchName, searchCode, 1, 1, 2000, birthdate, orderField, orderType);
            Test.stopTest();
            Assert.areNotEqual(0, result.size());
        }
    }
    /**
     * testDeleteSelectedStudents
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
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
            String result = CMP_SearchStudentCtrl.deleteSelectedStudentsCtrl(studentIds);
            Test.stopTest();
            Assert.areEqual('Success', result);
        }

    }
    /**
     * testDeleteStudent
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteStudent(){
        User userTest = createUser();
        System.runAs(userTest){
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
    }
    /**
     * testDeleteStudentEmptyId
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteStudentEmptyId(){
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new class__c();
            insert testClass;
            Test.startTest();
            String result = CMP_SearchStudentCtrl.deleteStudentRecord('');
            Test.stopTest();
            Assert.areEqual('student Id to delete can not be blank', result);
        }
    }
    /**
     * testDeleteStudentNotFound
     * @param    : 
     * @return   : 
     * @created  : 2024/02/21 + Nguyen Vinh
     * @modified : 
     */
    @isTest
    private static void testDeleteStudentNotFound(){
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new class__c();
            insert testClass;
            Test.startTest();
            String result = CMP_SearchStudentCtrl.deleteStudentRecord('123');
            Test.stopTest();
            Assert.areNotEqual('Student record not found', result);
        }
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