@isTest
public with sharing class mockDataTest {
    @isTest
    private static void testGenStudent(){
        insert new Class__c();
        Test.startTest();
        mockData.genStudents();
        Test.stopTest();
    }
}