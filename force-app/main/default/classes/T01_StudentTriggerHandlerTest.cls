/**
 * クラス名：   T01_StudentTriggerHandlerTest.cls
 * クラス概要： Student trigger handler Test
 * @created： 2024/02/20 + Nguyen Vinh
 * @modified: 2024/03/13 + Nguyen Vinh
 */
@isTest
private class T01_StudentTriggerHandlerTest {
    /**
     * testInsert
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnAfterInsert() {
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new Class__c();
            insert testClass;
            Integer oldClassNumber = [SELECT COUNT() FROM Student__c WHERE Class_look__c =:testClass.Id];
            List<Student__c> newStudents = new List<Student__c>();
            Integer insertionSize = 5;
            for(Integer i=1; i <= insertionSize; i++){
                Student__c stu = createStudent(testClass.Id);
                newStudents.add(stu);
            }
            Test.startTest();
                insert newStudents;
            Test.stopTest();
            Integer newClassNumber = [SELECT COUNT() FROM Student__c WHERE Class_look__c =:testClass.Id];
            List<Student__c> updatedStuList = [SELECT Id, Name FROM Student__c WHERE Id =: newStudents[0].Id ];
            Assert.areEqual(oldClassNumber+insertionSize, newClassNumber);
        }
    }
    /**
     * testOnBeforeInsertCatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnBeforeInsertCatch() {
        User userTest = createUser();
        System.runAs(userTest){
            Boolean errorFlag = false;
            Test.startTest();
            try {
                T01_StudentTriggerHandler.onBeforeInsert(null);
            } catch (Exception e) {
                errorFlag = true;
            }
            Test.stopTest();
            Assert.isTrue(errorFlag);
        }
    }
    /**
     * testOnAfterInsertCatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnAfterInsertCatch() {
        User userTest = createUser();
        System.runAs(userTest){
            Boolean errorFlag = false;
            Test.startTest();
            try {
                T01_StudentTriggerHandler.onAfterInsert(null);
            } catch (Exception e) {
                errorFlag = true;
            }
            Test.stopTest();
            Assert.isTrue(errorFlag);
        }
    }
    /**
     * testOnAfterUpdateCatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnAfterUpdateCatch() {
        Boolean errorFlag = false;
        Test.startTest();
        try {
            T01_StudentTriggerHandler.onAfterUpdate(null, null);
        } catch (Exception e) {
            errorFlag = true;
        }
        Test.stopTest();
        Assert.isTrue(errorFlag);
    }
    /**
     * testOnBeforeUpdateCatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnBeforeUpdateCatch() {
        User userTest = createUser();
        System.runAs(userTest){
            Boolean errorFlag = false;
            Test.startTest();
            try {
                T01_StudentTriggerHandler.onBeforeUpdate(null);
            } catch (Exception e) {
                errorFlag = true;
            }
            Test.stopTest();
            Assert.isTrue(errorFlag);
        }
    }
    /**
     * testOnBeforeDeleteCatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnBeforeDeleteCatch() {
        User userTest = createUser();
        System.runAs(userTest){
            Boolean errorFlag = false;
            Test.startTest();
            try {
                T01_StudentTriggerHandler.onBeforeDelete(null);
            } catch (Exception e) {
                errorFlag = true;
            }
            Test.stopTest();
            Assert.isTrue(errorFlag);
        }
    }
    /**
     * testOnBeforeDeleteCatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnAfterDeleteCatch() {
        User userTest = createUser();
        System.runAs(userTest){
            Boolean errorFlag = false;
            Test.startTest();
            try {
                T01_StudentTriggerHandler.onAfterDelete(null);
            } catch (Exception e) {
                errorFlag = true;
            }
            Test.stopTest();
            Assert.isTrue(errorFlag);
        }
    }
    /**
     * testDelete
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnAfterDelete() {
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new Class__c();
            insert testClass;
            Subject__c testSub = new Subject__c();
            insert testSub;
            Student__c stu = createStudent(testClass.Id);
            insert stu;
            Integer oldClassNumber = [SELECT COUNT() FROM Student__c WHERE Class_look__c =:testClass.Id];
            SubjectScore__c subScore = new SubjectScore__c();
            subScore.Student_look__c = stu.Id;
            subScore.Subject_look__c = testSub.Id;
            insert subScore;
            Test.startTest();
                delete stu;
            Test.stopTest();
            Integer newClassNumber = [SELECT COUNT() FROM Student__c WHERE Class_look__c =:testClass.Id];
            List<SubjectScore__c> subSccoreList = [SELECT Id FROM SubjectScore__c WHERE Id =: subScore.Id ];
            Assert.areEqual(0, subSccoreList.size());
            Assert.areEqual(0, newClassNumber);
        }
    }
    
    /**
     * testUpdate
     * @param    :
     * @return   :
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified :
     */
    @isTest
    private static void testOnAfterUpdate() {
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass1 = new Class__c();
            insert testClass1;
            Class__c testClass2 = new Class__c();
            insert testClass2;
            Subject__c testSub = new Subject__c();
            insert testSub;
            Student__c stu = createStudent(testClass1.Id);
            insert stu;
            SubjectScore__c subScore = new SubjectScore__c();
            subScore.Student_look__c = stu.Id;
            subScore.Subject_look__c = testSub.Id;
            insert subScore;
            stu.Class_look__c = testClass2.Id;
            Test.startTest();
            update stu;
            Test.stopTest();
            Integer class1Number = [SELECT COUNT() FROM Student__c WHERE Class_look__c =:testClass1.Id];
            Integer class2Number = [SELECT COUNT() FROM Student__c WHERE Class_look__c =:testClass2.Id];
            List<SubjectScore__c> subSccoreList = [SELECT Id FROM SubjectScore__c WHERE Id =: subScore.Id ];
            Assert.areEqual(0,class1Number);
            Assert.areEqual(1,class2Number);
        }
    }
    /**
     * createStudentList
     * @param    :
     * @return   :  List<Student__c>
     * @created  : 2024/02/20 + Nguyen Vinh
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
        stu.Gender__c = true;
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
