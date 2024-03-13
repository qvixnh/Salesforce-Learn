/**
 * クラス名：   B01_DeleteSubjectScoreBatchTest.cls
 * クラス概要： Delete Subject Score Batch Test
 * @created： 2024/02/22 + Nguyen Vinh
 * @modified: 2024/02/23 + Nguyen Vinh
 * @modified: 2024/03/13 + Nguyen Vinh
 */
@isTest
public with sharing  class B01_DeleteSubjectScoreBatchTest {
    private static final String PROGRESS = 'Progress';
    private static final String PRACTICAL = 'Practical';
    private static final String MIDTERM = 'Midterm Exam';
    private static final String FINALTERM = 'FinalTerm Exam';
     /**
     * setUp
     * @param    :
     * @return   :
     * @created  : 2024/02/23 + Nguyen Vinh
     * @modified :
     */
    private static void setUp(){
        Class__c testCls = new Class__c();
        insert testCls;
        Semester__c testSemester = new Semester__c();
        insert testSemester;
        List<Student__c> stu = createStudentList(testCls.Id, 150);
        //200 -> no more than 1 batch run in test.
        insert stu;
        List<Subject__c> subList = createSubjectList();
        insert subList;
        List<Semester__c> semesterList = createSemList();
        insert semesterList;
        SubjectScore__c subScore = new SubjectScore__c();
        insert subScore;
    }
    /**
     * testExecuteBatch
     * @param    :
     * @return   :
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 2024/02/23 + Nguyen Vinh
     */
    @isTest
    private static void testExecuteBatch(){
        User userTest = createUser();
        System.runAs(userTest){
            setUp();
            Integer oldSubScoreNumber  = [SELECT COUNT() FROM SubjectScore__c];
            Test.startTest();
            B01_DeleteSubjectScoreBatch batch = new B01_DeleteSubjectScoreBatch();
            Id batchId = Database.executeBatch(batch);
            Test.stopTest();
            Integer newSubScoreNumber  = [SELECT COUNT() FROM SubjectScore__c];
            Assert.areNotEqual(0, newSubScoreNumber);
            Assert.areNotEqual(oldSubScoreNumber, newSubScoreNumber);
        }
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
        stu.Gender__c = true;
        stu.Class_look__c = classId;
        stu.Birthday__c = Date.valueOf('2000-01-01');
        stu.Address__c = 'Test Address';
        return stu;
    }
    /**
     * createSubjectList
     * @param    :
     * @return   : List<Subject__c>
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    private static List<Subject__c> createSubjectList(){
        List<Subject__c> subList = new List<Subject__c>();
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(1));
        subList.add(createSubject(2));
        subList.add(createSubject(3));
        subList.add(createSubject(4));
        return subList;
    }
    /**
     * createSemList
     * @param    : createSemList
     * @return   : List<Semester__c>
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    private static List<Semester__c> createSemList(){
        List<Semester__c> semesterList = new List<Semester__c>();
        for(Integer i = 0; i< 3; i++){
            Semester__c s  = new Semester__c();
            semesterList.add(s);
        }
        return semesterList;
    }
    /**
     * createSubject
     * @param    : Integer credit
     * @return   : Subject__c
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified :
     */
    private static Subject__c createSubject(Integer credit){
        Subject__c sub = new Subject__c();
        sub.CourseCredit__c = credit;
        return sub;
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
