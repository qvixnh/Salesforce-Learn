/**
 * クラス名：   T02_ScoreTriggerHandlerTest.cls
 * クラス概要： Score trigger handler Test
 * @created： 2024/02/22 + Nguyen Vinh
 * @modified:
 */
@isTest
public with sharing class T02_ScoreTriggerHandlerTest {
    private static final String PROGRESS = 'Progress';
    private static final String PRACTICAL = 'Practical';
    private static final String MIDTERM = 'Midterm Exam';
    private static final String FINALTERM = 'FinalTerm Exam';
    private static final String PASS = 'Passed';
    private static final String NOTPASS = 'Not Passed';
    /**
     * testInsert
     * @param    : 
     * @return   :  
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 
     */
    @isTest 
    private static void testOnAfterInsert(){
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new Class__c();
            insert testClass;
            Subject__c testSub = new Subject__c();
            insert testSub;
            Student__c stu = createStudent(testClass.Id);
            insert stu;
            SubjectScore__c subScore = new SubjectScore__c();
            subScore.Student_look__c = stu.Id;
            subScore.Subject_look__c = testSub.Id;
            insert subScore;
            List<Score__c> scoreList = new List<Score__c>();
            Score__c score1 = createScore(subScore.Id,PROGRESS, 10 );
            Score__c score2 = createScore(subScore.Id,PRACTICAL, 6 );
            Score__c score3 = createScore(subScore.Id,MIDTERM, 7 );
            Score__c score4 = createScore(subScore.Id,FINALTERM, 5 );
            scoreList.add(score1);
            scoreList.add(score2);
            scoreList.add(score3);
            scoreList.add(score4);
            Test.startTest();
            insert scoreList;
            Test.stopTest();
            Assert.areNotEqual(PASS,subScore.Status__c);
        }
    }

    /**
     * testUpdate
     * @param    : 
     * @return   :  
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest 
    private static void testOnAfterUpdate(){
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new Class__c();
            insert testClass;
            Subject__c testSub = new Subject__c();
            insert testSub;
            Student__c stu = createStudent(testClass.Id);
            insert stu;
            SubjectScore__c subScore = new SubjectScore__c();
            subScore.Student_look__c = stu.Id;
            subScore.Subject_look__c = testSub.Id;
            insert subScore;
            List<Score__c> scoreList = new List<Score__c>();
            Score__c score1 = createScore(subScore.Id,PROGRESS, 10 );
            Score__c score2 = createScore(subScore.Id,PRACTICAL, 6 );
            Score__c score3 = createScore(subScore.Id,MIDTERM, 7 );
            Score__c score4 = createScore(subScore.Id,FINALTERM, 5 );
            scoreList.add(score1);
            scoreList.add(score2);
            scoreList.add(score3);
            scoreList.add(score4);
            insert scoreList;
            List<Score__c> scoreToUpdate = new List<Score__c>();
            for(Score__c s : scoreList){
                s.Score__c = 4;
                scoreToUpdate.add(s);
            }
            Test.startTest();
            update scoreToUpdate;
            Test.stopTest();
            Assert.areNotEqual(PASS,subScore.Status__c);
        }
    }
    
    /**
     * testGPA_Null
     * @param    : 
     * @return   :  
     * @created  : 2024/02/22 + Nguyen Vinh
     * @modified : 
     */
    @isTest 
    private static void testOnAfterInsertGPA_Null(){
        User userTest = createUser();
        System.runAs(userTest){
            Class__c testClass = new Class__c();
            insert testClass;
            Subject__c testSub = new Subject__c();
            insert testSub;
            Student__c stu = createStudent(testClass.Id);
            insert stu;
            SubjectScore__c subScore = new SubjectScore__c();
            subScore.Student_look__c = stu.Id;
            subScore.Subject_look__c = testSub.Id;
            insert subScore;
            List<Score__c> scoreList = new List<Score__c>();
            Score__c score1 = createScore(subScore.Id,PROGRESS, 10 );
            Score__c score2 = createScore(subScore.Id,PRACTICAL, 6 );
            Score__c score3 = createScore(subScore.Id,MIDTERM, 7 );
            scoreList.add(score1);
            scoreList.add(score2);
            scoreList.add(score3);
            Test.startTest();
            insert scoreList;
            Test.stopTest();
            Assert.areNotEqual(PASS,subScore.Status__c);
        }
    }
     /**
     * createScore
     * @param    : 
     * @return   :  Score__c
     * @created  : 2024/02/20 + Nguyen Vinh
     * @modified : 
     */
    private static Score__c createScore(Id subScoreId, String examType, Integer scoreGrade){
        Score__c score = new Score__c();
        score.SubjectScore_look__c  = subScoreId;
        score.ExamType__c = examType;
        score.Score__c = scoreGrade;
        return score;
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

