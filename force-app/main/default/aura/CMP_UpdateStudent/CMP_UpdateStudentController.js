({
    doInit : function(component, event, helper) {
        // Define gender options
        component.set('v.genderOptions', [
            { label: 'Male', value: true },
            { label: 'Female', value: false }
        ]);
        helper.getClasses(component);

    },
    updateStudentRecs: function(component, event, helper) {
        updateStudentHelper(component);
    },
})