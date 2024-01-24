public class Students {
    public List<Student__c> studentList { get; set; }

    public Students() {
        // Query the necessary fields, including the related Class_look__r field
        studentList = [SELECT StudentCode__c, Firstname__c, Lastname__c, 
                            Class__c, Class_look__r.Name, 
                            Gender__c, Birthday__c, Address__c
                       FROM Student__c];
    }
}