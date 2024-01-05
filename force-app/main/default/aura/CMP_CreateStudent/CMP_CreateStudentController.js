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
        var isValid = helper.validation(component);
        if (!isValid) {
            // Validation failed, do not proceed with creating student records
            return;
        }
        var  sFirstName  = component.find("sFirstName").get("v.value");
        var sLastName = component.find("sLastName").get("v.value");
        var sClassId =  component.get('v.selectedClass');
        var sGender = component.get('v.selectedGender');
        var sAddress = component.find("sAddress").get("v.value");
        var sBirthdate = component.find("sBirthdate").get("v.value");
        var action = component.get("c.createStudentRec");
        action.setParams({
            "sFirstName":sFirstName,
            "sLastName":sLastName,
            "sClassId":sClassId,
            "sGender":sGender,
            "sAddress":sAddress,
            "sBirthdate":sBirthdate
        })
        action.setCallback(this, function(stuRecds){
            var state= stuRecds.getState();
            if(state == "SUCCESS"){
                var stuId = stuRecds.getReturnValue();
                // Show a success toast message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Student record deleted successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                //helper.refreshTableData(component);
                helper.resetForm(component);
            }else{
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "error occured when creating student",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
})