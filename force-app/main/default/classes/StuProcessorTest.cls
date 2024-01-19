@isTest
public class StuProcessorTest {
	@isTest
    private static void testBatchClass(){
        List<Student__c> stuList = new List<Student__c>();
        for(integer i=0;i<200;i++){
            stuList.add(new Student__c(Name='Test', First_Name__c='Test', Last_Name__c='Test',Class__c='a035j00000WuersAAB', Gender__c=false,Birthdate__c=Date.valueOf('2001-01-01'),Address__c='Test' ));
        }
        insert stuList;
        Test.startTest();
        StuProcessor sp = new StuProcessor();
        Id batchId = Database.executeBatch(sp,200);
    	Test.stopTest();
        List<Student__c> updatedStus= [SELECT Id FROM Student__c WHERE Address__c='Address from batch'];
        System.assertEquals(200, updatedStus.size());
    }
}