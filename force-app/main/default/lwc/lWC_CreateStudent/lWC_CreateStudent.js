// LWC_UpdateStudent.js
import { LightningElement, api ,wire,track} from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
import getClassOptionsToCreate from '@salesforce/apex/LWC_CreateStudentCtrl.getClassOptionsToCreate';
import createStudentRec from '@salesforce/apex/LWC_CreateStudentCtrl.createStudentRec';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_CreateStudent extends LightningElement {
    @track classes;
    firstName = '';
    lastName = '';
    selectedClass = '';
    address = '';
    birthdate = '';
    selectedGender = false;
    firstNameError = '';
    lastNameError = '';
    classError = '';
    addressError = '';
    birthdateError = '';
    genderError = '';
    genderOptions=[
        {label:'Male', value:true},
        {label:'Female', value:false}        
    ];
    @wire(getClassOptionsToCreate)
    wiredClasses({ error, data }) {
        if (data) {
            this.classes = data.map(option => ({
                label: option.Name,
                value: option.Id
            }));
            this.classes.unshift({ label: 'All Classes', value: null });
            this.error = undefined;
        } else if (error) {
            this.error = 'Error retrieving classes';
            this.classes = undefined;
        }
    }
    handleChangeClass(event) {
        this.selectedClass = event.target.value;
    }
    handleChangeGender(event) {
        this.selectedGender = event.target.value;
    }
    handleCreate() {
        if(!this.validation()) {
            return;
        }
        this.createStudent();
    }
    createStudent(){
        createStudentRec({
            sFirstName:this.firstName,
            sLastName:this.lastName,
            sClassId:this.selectedClass,
            sGender:this.selectedGender,
            sAddress:this.address,
            sBirthdate:this.birthdate
            
        }).then(newSCode => {
            this.resetForm();
            this.showSuccessToast('Student created successfully', newSCode);
            const successEvent = new CustomEvent('studentcreated', {
                detail: { studentCode: newSCode }
            });
            this.dispatchEvent(successEvent);
        })
        .catch(error => {
            this.showErrorToast('Error creating student record:', error);
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
            if(this.address.length>=255){
                this.addressError = 'Address is less than 255 characters';
                }
                else{
                    this.addressError = '';
                }
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
    resetForm() {
        // this.firstName = '';
        // this.lastName = '';
        // this.address = '';
        // this.birthdate = '';
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
    
    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(event);
    }
    
}
