// LWC_UpdateStudent.js
import { LightningElement, api ,wire} from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';

export default class LWC_UpdateStudent extends LightningElement {
    @api studentId;
    @api student;
    @api genderOptions;
    classes;
    @wire(getClassOptions)
    wiredClasses({ error, data }) {
        if (data) {
            this.classes = data.map(option => ({
                label: option.Class_Name__c,
                value: option.Id
            }));
            this.classes.unshift({ label: 'All Classes', value: null });
            this.error = undefined;
        } else if (error) {
            this.error = 'Error retrieving classes';
            this.classes = undefined;
        }
    }
    handleUpdate() {
        // Perform validation before submitting the form
        if(!this.validation()) {
            return;
        }
        this.updateStudent();
    }
    updateStudent(){
        console.log("this.firstName: ",this.firstName);
        console.log("this.lastName: ",this.lastName);
        console.log("this.selectedClass: ",this.selectedClass);
        console.log("this.selectedGender: ",this.selectedGender);
        console.log("this.address: ",this.address);
        console.log("this.birthdate: ",this.birthdate);
        updateStudentRec({
            //String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate
            sFirstName:this.firstName,
            sLastName:this.lastName,
            sClassId:this.selectedClass,
            sGender:this.selectedGender,
            sAddress:this.address,
            sBirthdate:this.birthdate
            
        }).then(newSCode => {
            this.showSuccessToast('Multiples Student deleted successfully', newSCode);
        })
        .catch(error => {
            this.showSuccessToast('Error creating student record:', error);
        });    
       
    }
    validation(){
        this.clearErrors();
        this.firstName = this.template.querySelector('[data-id="sFirstName"]').value;
        this.lastName = this.template.querySelector('[data-id="sLastName"]').value;
        this.address = this.template.querySelector('[data-id="sAddress"]').value;
        this.birthdate = this.template.querySelector('[data-id="sBirthdate"]').value;
        if (!this.firstName) {
            this.firstNameError = 'Please enter First Name';
        }
        if(this.firstName){
            this.firstNameError = '';

        }
        if (!this.lastName) {
            this.lastNameError = 'Please enter Last Name';
        }
        else if (this.lastName) {
            this.lastNameError = '';
        }

        if (!this.selectedClass) {
            this.classError = 'Please select a Class';
        }
        else if (!this.selectedClass) {
            this.classError = '';
        }

        if (!this.address) {
            this.addressError = 'Please enter Address';
        }
        else if (this.address) {
            this.addressError = '';
        }
        if (this.selectedGender==null) {
            this.genderError = 'Please select Gender';
        }
        else if (this.selectedGender) {
            this.genderError = '';
        }
        if (!this.birthdate) {
            this.birthdateError = 'Please enter Birthdate';
        }
        else if (this.birthdate) {
            var bd = new Date(this.birthdate);
            var today = new Date();
            var age = today.getFullYear() - bd.getFullYear();
            if (today.getMonth() < bd.getMonth() || (today.getMonth() === bd.getMonth() && today.getDate() < bd.getDate())) {
                age--;
            }
            if (age <= 17) {
                this.birthdateError  = "Student must be atleast 17 years old";
            }else{
                this.birthdateError = '';

            }
        }
        if (
            this.firstNameError ||
            this.lastNameError ||
            this.classError ||
            this.addressError ||
            this.birthdateError ||
            this.genderError
        ) {
            return false;
        }
        return true;
    }
    clearErrors() {
        this.firstNameError = '';
        this.lastNameError = '';
        this.classError = '';
        this.addressError = '';
        this.birthdateError = '';
        this.genderError = '';
    }
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
        });
        this.dispatchEvent(event);
    }
    // handleUpdate() {
    //     // Emit an event to notify the parent component to open the modal
    //     const updateEvent = new CustomEvent('openmodal', {
    //         detail: {
    //             component: 'LWC_UpdateStudent',
    //             studentId: this.studentId,
    //         },
    //     });
    //     this.dispatchEvent(updateEvent);
    // }

}
