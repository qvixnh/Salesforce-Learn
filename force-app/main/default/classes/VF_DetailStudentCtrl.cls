public with sharing class VF_DetailStudentCtrl {
    public String selectedStudentId { get; set; }
    public Student__c student { get; set; }

    public VF_DetailStudentCtrl(){
        String studentIdParam = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(studentIdParam)) {
            selectedStudentId = studentIdParam;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Student ID is blank'));
        }
    }

    public PageReference loadStudentDetails() {
            try {
                if(!isValidId(selectedStudentId)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Student ID'));
                    return new PageReference('/apex/error');
                }
                if(studentExists(selectedStudentId)){
                    student = [
                        SELECT
                            Student_Code__c
                            , Firstname__c
                            , Lastname__c
                            , Class__r.Name
                            , Gender__c
                            , Birthday__c
                            , Address__c 
                        FROM Student__c 
                        WHERE Id = :selectedStudentId 
                        LIMIT 1
                    ];
                    return null;
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Student does not exist.'));                        
                    return null;
                }
                
            } catch (QueryException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Student ID.'));
                return null;
            }
    }
    private Boolean studentExists(Id studentId) {
        Integer count = [
            SELECT COUNT()
            FROM Student__c 
            WHERE Id = :studentId 
            LIMIT 1
        ];
        return count > 0;
    }
    private Boolean isValidId(String id) {
        if (String.isBlank(id)) {
            return false;
        }
    
        // Check if it's a valid Salesforce record ID format
        String regex = '^[a-zA-Z0-9]{15}$|^[a-zA-Z0-9]{18}$';
        Pattern idPattern = Pattern.compile(regex);
        Matcher idMatcher = idPattern.matcher(id);
    
        return idMatcher.matches();
    }
    
}