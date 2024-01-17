public with sharing class CMP_DeleteStudentCtrl {

    public CMP_DeleteStudentCtrl() {
        // Constructor logic, if any
    }

    @AuraEnabled
    public static String deleteStudentRecord(String studentId) {
        try {
            // Fetch the student record by Id
            Student__c studentToDelete = [SELECT Id FROM Student__c WHERE Id = :studentId LIMIT 1];

            // Check if the record exists
            if (studentToDelete != null) {
                // Delete the student record
                delete studentToDelete;

                return 'Success';
            } else {
                return 'Student record not found';
            }
        } catch (Exception e) {
            // Handle exceptions and return an error message
            return 'Error: ' + e.getMessage();
        }
    }
}