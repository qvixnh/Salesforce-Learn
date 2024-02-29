/**
 * クラス名：   LWC_SearchClass.cls
 * クラス概要： SearchClass
 * @created： 2024/02/29 + Nguyen Vinh
 * @modified:
 */
public with sharing class LWC_SearchClass {
    @AuraEnabled
    public static void createClass(String falcuty) {
        try {
            Class__c cls = new Class__c();
            cls.Falcuty__c = falcuty;
            cls.NumberOfStudent__c = 0;
            insert cls;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Student__c> getStudentListByClass(Id clsId) {
        try {
            List<Student__c> stuList = new List<Student__c>();
            stuList = [SELECT
                    Id,
                    StudentCode__c,
                    Name,
                    TotalCredit__c,
                    GPAScore__c
                FROM Student__c
                WHERE Class_look__c =: clsId
                ORDER BY GPAScore__c ASC
            ];
            return stuList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}