/*
    * クラス名：CMP_CreateStudentHelper.js
    * クラス概要：CMP Create Student Helper
    * @created：2023/12/26 + Nguyen Vinh
    * @modified：
*/
({
    /*
    reset the create form went student record created
    */
    resetForm: function(component) {
        component.find("sFirstName").set("v.value", "");
        component.find("sLastName").set("v.value", "");
        component.set("v.selectedClass", ""); 
        component.set("v.selectedGender", ""); 
        component.find("sAddress").set("v.value", "");
        component.find("sBirthdate").set("v.value", "");
    },
    /*
    get class options to select when creating student 
    */
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
    /*
    validation student input
    */
    validation: function(component) {
        var isValid = true;
        var sFirstName = component.find("sFirstName").get("v.value");
        var firstNameError = document.getElementById("sFirstNameError");
        var lastNameError = document.getElementById("sLastNameError");
        var addressError = document.getElementById("sAddressError");
        var birthdateError = document.getElementById("sBirthdateError");
        var classError = document.getElementById("sClassError");

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
        var sClass = component.get("v.selectedClass");
        if (!sClass || sClass.trim() === '') {
            isValid = false;
            classError.innerHTML = "Please select one class";
        }
        else if (sClass || sClass.trim() != '') {
            classError.innerHTML = "";
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
    /*
    call action from apex controller to create student
    */
    createStudentHelper:function(component){
        var isValid = this.validation(component);
        if (!isValid) {
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Student record deleted successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                var reloadEvent = $A.get("e.c:CMP_ReloadEvent");
                reloadEvent.fire();
                this.resetForm(component);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "error occured when creating student",
                    "type": "error"
                });
                toastEvent.fire();
                this.resetForm(component);
            }
        });
        $A.enqueueAction(action);
    }
})