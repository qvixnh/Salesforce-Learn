({
    getClasses: function (component) {
        var action = component.get("c.getClasses");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var classOptions = response.getReturnValue();
                component.set("v.classList", classOptions);
            } else {
                console.error("Error fetching class options: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    validation: function(component) {
        var isValid = true;
        var sFirstName = component.find("sFirstName").get("v.value");
        var firstNameError = document.getElementById("sFirstNameError");
        var lastNameError = document.getElementById("sLastNameError");
        var addressError = document.getElementById("sAddressError");
        var birthdateError = document.getElementById("sBirthdateError");

        if (!sFirstName || sFirstName.trim() === '') {
            isValid = false;
            firstNameError.innerHTML = "First name is Required";
        }
        else if(sFirstName || sFirstName.trim() != ''){
            firstNameError.innerHTML = "";
        }
        var sLastName = component.find("sLastName").get("v.value");
        if (!sLastName || sLastName.trim() === '') {
            lastNameError.innerHTML = "Last name is Required";
        }
        else if (sLastName || sLastName.trim() != '') {
            lastNameError.innerHTML = "";
        }
        var sAddress = component.find("sAddress").get("v.value");
        if (!sAddress || sAddress.trim() === '') {
            isValid = false;
            addressError.innerHTML = "Address is Required";
        }
        else if (sAddress || sAddress.trim() != '') {
            addressError.innerHTML = "";
        }
        var sBirthdate = component.find("sBirthdate").get("v.value");
        if (!sBirthdate || sBirthdate.trim() === '') {
            isValid = false;
            birthdateError.innerHTML = "Birthdate is Required";
        }else {
            var birthdate = new Date(sBirthdate);
            var today = new Date();
            var age = today.getFullYear() - birthdate.getFullYear();
            if (today.getMonth() < birthdate.getMonth() || (today.getMonth() === birthdate.getMonth() && today.getDate() < birthdate.getDate())) {
                age--;
            }
            if (age <= 17) {
                isValid = false;
                birthdateError.innerHTML = "Student must be atleast 17 years old";
            }
        }
        return isValid;
    },
    updateStudentHelper:function(component){
        var isValid = this.validation(component);
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
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     "title": "Success!",
                //     "message": "Student record updated successfully.",
                //     "type": "success"
                // });
                // toastEvent.fire();
                alert("Student record updated successfully...."+stuId);
                var reloadEvent = $A.get("e.c:CMP_ReloadEvent");
                reloadEvent.fire();
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
    }
})