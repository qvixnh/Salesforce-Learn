/**
 * クラス名：   VF_UpdateStudentCtrl.cls
 * クラス概要： Update Student Controller
 * @created： 2023/12/15 + Nguyen Vinh
 * @modified: 2023/12/17 + Nguyen Vinh
 */
public with sharing class VF_UpdateStudentCtrl {
    public Student__c student { get; set; }
    public List<SelectOption> classListCreate { get; set; }

    public VF_UpdateStudentCtrl() {
        String studentId = ApexPages.currentPage().getParameters().get('id');
        if(!String.isBlank(studentId)){
            this.student = [
                SELECT 
                    Id
                    , StudentCode__c
                    , Firstname__c
                    , Lastname__c
                    , Class_look__r.Name
                    , Gender__c
                    , Birthday__c
                    , Address__c 
                FROM Student__c
                WHERE Id = :studentId
            ];
        }
        else{
            this.student = null;
        }
        classListCreate = getClasses();
    }

    /**
     * updateStudent
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 2024/02/19 +  Nguyen Vinh
     */
    public PageReference updateStudent() {
        try {
            this.student.Name = student.Firstname__c.left(39) + ' ' + student.Lastname__c.left(39);
            update student;
            this.student=new Student__c();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student updated successfully.'));  
            return null;
        } catch (Exception e) {
            this.student= null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating student: ' + e.getMessage()));
            throw new CustomException('An error occurred when updating student: ' + e.getMessage());
        }
    }
     /**
     * getClasses
     * @param    : 
     * @return   :  
     * @created  : 2023/12/15 + Nguyen Vinh
     * @modified: 
     * **/
    public List<SelectOption> getClasses() {
        try {
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
        } catch (Exception e) {
            throw new CustomException('An error occurred when getting classes: ' + e.getMessage());

        }
        
    }
    public  class  CustomException extends Exception {
        
    }
}