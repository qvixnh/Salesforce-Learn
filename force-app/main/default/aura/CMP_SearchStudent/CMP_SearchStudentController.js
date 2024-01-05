// CMP_SearchStudentController.js
({
    init: function(component, event, helper) {
        helper.getClasses(component);
        helper.loadData(component);
        helper.updatePageNumbers(component);
        helper.initializeOptions(component);
    },   
})