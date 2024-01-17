public class Students {
    public List<Student__c> studentList { get; set; }

    public Students() {
        // Query the necessary fields, including the related Class__r field
        studentList = [SELECT Student_Code__c, First_Name__c, Last_Name__c, 
                            Class__c, Class__r.Class_Name__c, 
                            Gender__c, Birthdate__c, Address__c
                       FROM Student__c];
    }
}