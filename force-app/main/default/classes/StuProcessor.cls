/**
 * StuProcessor - Batch Apex class for processing Student__c records.
 * Implements Database.Batchable interface and Database.stateful.
 */
public class StuProcessor implements Database.Batchable<sObject>, Database.stateful {
    
    // Counter to keep track of processed records
    public Integer recordCount = 0;
    
    /**
     * start - Method to provide the query locator for the batch.
     * @param bc - Database.BatchableContext parameter
     * @return Database.QueryLocator - Query locator for the batch
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name FROM Student__c]);
    }
    
    /**
     * execute - Method to process each batch of Student__c records.
     * Updates the Address__c field for each record and updates the records.
     * @param bc - Database.BatchableContext parameter
     * @param students - List<Student__c> parameter representing the batch of records
     */
    public void execute(Database.BatchableContext bc, List<Student__c> students) {
        // Update Address__c field for each student in the batch
        for (Student__c s : students) {
            s.Address__c = 'Address from batch';
        }
        
        // Update the batch of students
        update students;
        
        // Increment the record count
        recordCount = recordCount + students.size();
    }
    
    /**
     * finish - Method to be executed after all batches are processed.
     * Outputs the total number of records processed.
     * @param bc - Database.BatchableContext parameter
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Total records Processed: ' + recordCount);
    }
}