/* 
    * クラス名：CMP_UpdateStudentController
    * クラス概要：CMP Update Student Controller
    * @created：2023/12/26 + Nguyen Vinh
    * @modified：
*/
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
        helper.updateStudentHelper(component);
    },
})