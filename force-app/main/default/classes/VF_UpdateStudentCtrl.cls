public with sharing class VF_UpdateStudentCtrl {
    public Student__c student { get; set; }
    public List<SelectOption> classList { get; set; }

    public VF_UpdateStudentCtrl() {
        String studentId = ApexPages.currentPage().getParameters().get('id');
        this.student = [
            SELECT 
                Id
                , First_Name__c
                , Last_Name__c
                , Class__c
                , Gender__c
                , Birthdate__c
                , Address__c 
            FROM Student__c
            WHERE Id = :studentId 
            LIMIT 1
        ];
        classList = getClassOptions();
    }

    public PageReference updateStudent() {
        try {
            
            //isBlank check validation
            if (String.isBlank(this.student.First_Name__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'First Name cannot be blank.'));
                return null;
            }
            if (String.isBlank(this.student.Last_Name__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Last Name cannot be blank.'));
                return null;
            }
            if (String.isBlank(this.student.Address__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Address cannot be blank.'));
                return null;
            }
            if(this.student.Birthdate__c ==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Birthdate cannot be blank.'));
                return null;
            }
            Integer age =getAge(this.student.Birthdate__c);

            if (age < 17) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Student must be at least 17 years old.'));
                return null;
            }
            update student;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student updated successfully.'));
            
            return new PageReference('/apex/VF_SearchStudent');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating student: ' + e.getMessage()));
            System.debug('Exception Details: ' + e);
            return null;
        }
    }

    //helper
    private Integer getAge(Date birthdate){
        Date today = Date.today();
        return today.year() - birthdate.year() - (today.month() < birthdate.month() || (today.month() == birthdate.month() && today.day() < birthdate.day()) ? 1 : 0);
    }
    public List<SelectOption> getClassOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<Class__c> classes = [
            SELECT 
                Id
                , Class_Name__c 
            FROM Class__c
        ];
        for (Class__c cls : classes) {
            options.add(new SelectOption(cls.Id, cls.Class_Name__c));
        }
        return options;
    }
}