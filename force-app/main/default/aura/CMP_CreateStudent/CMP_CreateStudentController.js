// CMP_CreateStudentController.js
({
    doInit : function(component, event, helper) {
        // Define gender options
        component.set('v.genderOptions', [
            { label: 'Male', value: true },
            { label: 'Female', value: false }
        ]);
        helper.getClasses(component);

    },
    createValidate: function(component, event, helper) {
        createStudentHelper(component);
    },
    
})