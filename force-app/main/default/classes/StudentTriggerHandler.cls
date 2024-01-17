public class StudentTriggerHandler {
	 public static void beforeInsert(List<Student__c> students) {
        // Your custom logic goes here
        for (Student__c student : students) {
            // Perform operations on each student
            student.Address__c = 'Address from student trigger handler, before inserting a student';
        }
    }
	 public static void afterInsert(List<Student__c> students) {
        // Your custom logic goes here
        for (Student__c student : students) {
            // Perform operations on each student
            
            student.Address__c = 'Address from student trigger handler, after inserting a student with this student code: ';
        	student.Address__c += student.Student_Code__c;
        }
    }

}