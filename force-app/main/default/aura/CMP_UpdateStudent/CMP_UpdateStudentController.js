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
        var isValid = helper.validation(component);
        if (!isValid) {
            return;
        }

        var  student  = component.get("v.student");
        var  sFirstName  = component.find("sFirstName").get("v.value");
        var sLastName = component.find("sLastName").get("v.value");
        var sClassId =  component.get('v.selectedClass');
        var sGender = component.find('sGender').get("v.value");
        var sAddress = component.find("sAddress").get("v.value");
        var sBirthdate = component.find("sBirthdate").get("v.value");
        var action = component.get("c.updateStudentRec");
        action.setParams({
            "student":student,
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
                    "message": "Student record updated successfully.",
                    "type": "success"
                });
                //helper.refreshTableData(component);
                toastEvent.fire();
                // alert("Student record updated successfully...."+stuId);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "error occured when updating student"+sFirstName,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})