/**
 * クラス名：   VF_SearchStudentCtrl.cls
 * クラス概要： Search Student Controller
 * @created： 2023/12/15 + Nguyen Vinh
 * @modified: 2024/02/19 +  Nguyen Vinh
 */
public with sharing class VF_CreateStudentCtrl {
    public List<SelectOption> classListCreate { get; set; }
    public Student__c studentToCreate {get;set;}

    public VF_CreateStudentCtrl() {
        this.studentToCreate = new Student__c();
        this.classListCreate = getClasses();
    }
    /**
     * createStudent
     * @param    : 
     * @return   :  
     * @created  : 2023/12/15 + Nguyen Vinh
     * @modified: 2024/02/19 +  Nguyen Vinh
     * **/
    public void createStudent() {
        try {
            if(String.isNotBlank(studentToCreate.Firstname__c) && String.isNotBlank(studentToCreate.Lastname__c)){
                this.studentToCreate.Name = studentToCreate.Firstname__c + ' ' + studentToCreate.Lastname__c;
            }
            insert studentToCreate;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student created successfully.'));
            this.studentToCreate = new Student__c();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating student: ' + e.getMessage()));
            throw new CustomException('An error occurred when creating student: ' + e.getMessage());
        }
    }
    /**
     * getClasses
     * @param    : 
     * @return   :  
     * @created  : 2023/12/15 + Nguyen Vinh
     * @modified: 
     * **/
    private List<SelectOption> getClasses() {
        List<SelectOption> options = new List<SelectOption>();
        List<Class__c> classes = [
            SELECT 
                Id
                , Name 
            FROM Class__c
        ];
        for (Class__c cls : classes) {
            options.add(new SelectOption(cls.Id, cls.Name));
        }
        return options;
    }
    public  class  CustomException extends Exception {
        
    }
}