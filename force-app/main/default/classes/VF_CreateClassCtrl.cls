public with sharing class VF_CreateClassCtrl {
    public Class__c newClass { get; set; }
    public VF_CreateClassCtrl() {
        newClass = new Class__c();
    }

    public PageReference saveClass() {
        try {
            insert newClass;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Class created successfully.'));
            newClass = new Class__c(); // Reset the form after successful creation
            return new PageReference('/apex/VF_SearchStudent');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating class: ' + e.getMessage()));
        }
        return null;
    }
}