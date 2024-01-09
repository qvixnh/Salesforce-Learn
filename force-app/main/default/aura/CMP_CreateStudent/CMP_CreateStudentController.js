// CMP_CreateStudentController.js
({
    /*
    init gender and class options
    */
    doInit : function(component, event, helper) {
        component.set('v.genderOptions', [
            { label: 'Male', value: true },
            { label: 'Female', value: false }
        ]);
        helper.getClasses(component);

    },
    /*
    handle create button
    */
    createValidate: function(component, event, helper) {
        helper.createStudentHelper(component);
    },
    
})