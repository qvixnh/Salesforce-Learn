// LWC_UpdateStudent.js
import { LightningElement, api ,wire,track} from 'lwc';
import getClassOptions  from '@salesforce/apex/LWC_CreateStudentCtrl.getClassOptionsToCreate';
import updateStudentRec from '@salesforce/apex/LWC_UpdateStudentCtrl.updateStudentRec';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_UpdateStudent extends LightningElement {
    ERRORTYPE = 'error'
    SUCCESSTYPE = 'success'
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
    
    get genderOptions(){
        return [
            {label:'Male', value:true},
            {label:'Female', value:false}        
        ];
    }
    get isTrue(){
        if(this.student.Gender__c == false){
            return false;
        }
        return true;
    }
    //Method to get class options
    @api student;
    @wire(getClassOptions)
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
    handleUpdate() {
        if(!this.validation()) {
            return;
        }
        this.updateStudent();
    }
    //Method to call the controller to update student 
    updateStudent(){
        updateStudentRec({
            student:this.student,
            sFirstName:this.firstName,
            sLastName:this.lastName,
            sClassId:this.selectedClass,
            sGender:this.selectedGender,
            sAddress:this.address,
            sBirthdate:this.birthdate
            
        }).then(newSCode => {
            this.showToast('Student updated successfully' + newSCode, this.SUCCESSTYPE);
            const successEvent = new CustomEvent('studentupdated', {
                detail: { studentCode: newSCode }
            });
            this.dispatchEvent(successEvent);
        })
        .catch(error => {
            this.showToast('Error updating student record:' + error, this.ERRORTYPE);
            
        });    
    }
    //Method to validate updated input
    validation(){
        this.clearErrors();
        this.firstName = this.template.querySelector('[data-id="sFirstName"]').value;
        this.lastName = this.template.querySelector('[data-id="sLastName"]').value;
        this.address = this.template.querySelector('[data-id="sAddress"]').value;
        this.birthdate = this.template.querySelector('[data-id="sBirthdate"]').value;
        this.selectedGender = this.template.querySelector('[data-id="sGender"]').value;
        this.selectedClass = this.template.querySelector('[data-id="sClass"]').value;
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
    //method to clear error content in the validation handler
    clearErrors() {
        this.firstNameError = '';
        this.lastNameError = '';
        this.classError = '';
        this.addressError = '';
        this.birthdateError = '';
        this.genderError = '';
    }
   
    showToast(message,type) {
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
        });
        this.dispatchEvent(event);
    }
}
