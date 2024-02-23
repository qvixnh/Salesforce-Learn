/**
 * クラス名：   VF_DetailStudentCtrl.cls
 * クラス概要： Detail Student Controller
 * @created： 2023/12/15 + Nguyen Vinh
 * @modified: 2023/12/17 + Nguyen Vinh
 */
public with sharing class VF_DetailStudentCtrl {
    public Student__c student { get; set; }

    public VF_DetailStudentCtrl(){
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
        
    }
    public  class  CustomException extends Exception {
        
    }
    
}