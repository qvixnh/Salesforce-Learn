// LWC_UpdateStudent.js
import { LightningElement, api ,wire,track} from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';

export default class LWC_CreateStudent extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track selectedClass = '';
    @track address = '';
    @track birthdate = '';
    @track selectedGender = '';
    @track firstNameError = '';
    @track lastNameError = '';
    @track classError = '';
    @track addressError = '';
    @track birthdateError = '';
    @api genderOptions;
    classes;
    selectedClass;
    selectedGender;
    
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
    handleCreate(){
        console.log("Create ");
        this.validation();
    }
    handleInputChange(event) {
        const { dataId, value } = event.target.dataset;

        switch (dataId) {
            case 'sFirstName':
                this.firstName = value;
                break;
            case 'sLastName':
                this.lastName = value;
                break;
            case 'sClass':
                this.selectedClass = value;
                break;
            case 'sAddress':
                this.address = value;
                break;
            case 'sBirthdate':
                this.birthdate = value;
                break;
            case 'sGender':
                this.selectedGender = value;
                break;
            default:
                break;
        }
    }
    handleChangeClass(event) {
        this.selectedClass = event.target.value;
    }
    handleChangeGender(event) {
        this.selectedGender = event.target.value;
    }
    handleCreate() {
        // Perform validation before submitting the form
        this.clearErrors();
        try {
            this.firstName = this.template.querySelector('[data-id="sFirstName"]').value;
            this.lastName = this.template.querySelector('[data-id="sLastName"]').value;
            this.address = this.template.querySelector('[data-id="sAddress"]').value;
            this.birthdate = this.template.querySelector('[data-id="sBirthdate"]').value;
            console.log(this.firstName);
            console.log(this.lastName);
            console.log(this.selectedClass);
            console.log(this.address);
            console.log(this.birthdate);
            console.log(this.selectedGender);
            
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
            
            if (!this.birthdate) {
                this.birthdateError = 'Please enter Birthdate';
            }
            else if (this.birthdate) {
                this.birthdateError = '';
            }

            if (this.selectedGender==null) {
                this.genderError = 'Please select Gender';
            }
            else if (this.selectedGender) {
                this.genderError = '';
            }
            // Check if there are any validation errors
            if (
                this.firstNameError ||
                this.lastNameError ||
                this.classError ||
                this.addressError ||
                this.birthdateError ||
                this.genderError
            ) {
                // Validation failed, do not proceed with form submission
                return;
            }
            console.log("validation success");

        } catch (error) {
            console.log("error when validation student", error.message);
        }
        // Form submission logic goes here
    }

    clearErrors() {
        // Clear all error messages
        console.log("clear all error messages");
        this.firstNameError = '';
        this.lastNameError = '';
        this.classError = '';
        this.addressError = '';
        this.birthdateError = '';
        this.genderError = '';
    }
}
