/*
    * クラス名：CMP_CreateStudentController.js
    * クラス概要：CMP Create Student Controller
    * @created：2023/12/26 + Nguyen Vinh
    * @modified：
*/
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