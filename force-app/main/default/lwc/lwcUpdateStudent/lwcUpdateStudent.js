// LWC_UpdateStudent.js
import { LightningElement, api ,wire,track} from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
import updateStudentRec from '@salesforce/apex/LWC_UpdateStudentCtrl.updateStudentRec';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LWC_UpdateStudent extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track selectedClass = '';
    @track address = '';
    @track birthdate = '';
    @track selectedGender = false;
    @track firstNameError = '';
    @track lastNameError = '';
    @track classError = '';
    @track addressError = '';
    @track birthdateError = '';
    @track genderError = '';
    genderOptions=[
        {label:'Male', value:true},
        {label:'Female', value:false}        
    ];
    get isTrue(){
        if(this.student.Gender__c == false){
            return false;
        }
        return true;
    }
    @api student;
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
    updateStudent(){
        try {
            console.log("this.firstName: ",this.firstName);
            console.log("this.lastName: ",this.lastName);
            console.log("this.selectedClass: ",this.selectedClass);
            console.log("this.selectedGender: ",this.selectedGender);
            console.log("this.address: ",this.address);
            console.log("this.birthdate: ",this.birthdate);
            updateStudentRec({
                //Student__C student, String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate
                student:this.student,
                sFirstName:this.firstName,
                sLastName:this.lastName,
                sClassId:this.selectedClass,
                sGender:this.selectedGender,
                sAddress:this.address,
                sBirthdate:this.birthdate
                
            }).then(newSCode => {
                this.showSuccessToast('Student updated successfully', newSCode);
            })
            .catch(error => {
                this.showSuccessToast('Error updating student record:', error);
            });    
        } catch (error) {
            console.log("error when updating student: ", error.message);
        }
            
       
    }
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
}
