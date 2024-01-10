// LWC_SearchStudent.js
import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
import getStudents from '@salesforce/apex/LWC_SearchStudentCtrl.getStudents';
import deleteSelectedStudentsCtrl from '@salesforce/apex/LWC_SearchStudentCtrl.deleteSelectedStudentsCtrl';
import deleteStudentRecord from '@salesforce/apex/LWC_SearchStudentCtrl.deleteStudentRecord';

const ITEMS_PER_PAGE = 4;

export default class LWC_SearchStudent extends LightningElement {
    classes;
    students;
    displayedStudents;
    error;
    selectedClass = null;
    searchCode = '';
    searchName = '';
    birthdate = '';
    dayOfBirth = null;
    monthOfBirth = null;
    yearOfBirth = null;
    currentPage = 1;
    totalPages = 1;
    // Variables for modal
    showModal = false;
    isUpdateModalOpen=false;
    selectedStudent;
    // Variables for selecting students
    selectedStudentIds = [];
    isSelectAllChecked = false;
    // Define select options for day and month
    dayOptions = Array.from({ length: 31 }, (_, i) => ({ label: `${i + 1}`, value: `${i + 1}` }));
    monthOptions = [
        { label: 'January', value: '1' },
        { label: 'February', value: '2' },
        { label: 'March', value: '3' },
        { label: 'April', value: '4' },
        { label: 'May', value: '5' },
        { label: 'June', value: '6' },
        { label: 'July', value: '7' },
        { label: 'August', value: '8' },
        { label: 'September', value: '9' },
        { label: 'October', value: '10' },
        { label: 'November', value: '11' },
        { label: 'December', value: '12' },
    ];
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

    @wire(getStudents, { classId: '$selectedClass', gender: null, searchName: '$searchName', searchCode: '$searchCode', day: '$dayOfBirth', month: '$monthOfBirth', year: '$yearOfBirth', birthdate: '$birthdate', orderField: 'Student_Code__c', orderType: 'ASC' })
    wiredStudents({ error, data }) {
        if (data) {
            this.students = data;
            this.updateDisplayedStudents();
            this.error = undefined;
        } else if (error) {
            this.error = 'Error retrieving students';
            this.students = undefined;
        }
    }

    handleClassChange(event) {
        this.selectedClass = event.detail.value;
        this.currentPage = 1;
        this.updateDisplayedStudents();
    }

    handleSearchCodeChange(event) {
        this.searchCode = event.detail.value;
    }

    handleSearchNameChange(event) {
        this.searchName = event.detail.value;
    }

    handleBirthdateChange(event) {
        this.birthdate = event.detail.value;
    }

    handleDayOfBirthChange(event) {
        this.dayOfBirth = event.detail.value;
    }

    handleMonthOfBirthChange(event) {
        this.monthOfBirth = event.detail.value;
    }

    handleYearOfBirthChange(event) {
        this.yearOfBirth = event.detail.value;
    }

    handleSearch() {
        this.currentPage = 1;
        this.updateDisplayedStudents();
    }
    handleClearFilters() {
        this.selectedClass = null;
        this.searchCode = '';
        this.searchName = '';
        this.birthdate='';
        this.dayOfBirth = null;
        this.monthOfBirth = null;
        this.yearOfBirth = null;
        this.currentPage = 1;
        this.updateDisplayedStudents();
    }
    updateDisplayedStudents() {
        
        if (this.students) {
            this.totalPages = Math.ceil(this.students.length / ITEMS_PER_PAGE);
            const startIndex = (this.currentPage - 1) * ITEMS_PER_PAGE;
            const endIndex = startIndex + ITEMS_PER_PAGE;
            this.displayedStudents = this.students.slice(startIndex, endIndex);
            this.displayedStudents = this.displayedStudents.map(student => ({
                ...student,
                selected__c:false
            }));
            this.isSelectAllChecked = false;
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }
    get isDeleteSelectedStudentsDisabled() {
        return this.selectedStudentIds.length==0;
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateDisplayedStudents();
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateDisplayedStudents();
        }
    }
    openModalDelete(event) {
        const studentId = event.currentTarget.dataset.studentId;
        this.selectedStudent = this.students.find(student => student.Id === studentId);
        this.showModal = true;
    }
    openModalUpdate(event) {
        const studentId = event.currentTarget.dataset.studentId;
        this.selectedStudent = this.students.find(student => student.Id === studentId);
        this.isUpdateModalOpen = true;
    }
    closeModalUpdate() {
        this.isUpdateModalOpen = false;
        this.selectedStudent = null;

    }
    
    // Method to close modal
    closeModalDelete() {
        this.showModal = false;
        this.selectedStudent = null;
    }
    handleSelectAll(event) {
        this.isSelectAllChecked = event.target.checked;
        if (this.isSelectAllChecked) {
            this.selectedStudentIds = this.displayedStudents.map(student => student.Id);
        } else {
            this.selectedStudentIds = [];
        }
        this.displayedStudents = this.displayedStudents.map(student => ({
            ...student,
            selected__c: this.isSelectAllChecked
        }));
        
    }
    handleSelect(event) {
        const studentCode = event.target.value;
        try {
            for(let i = 0; i<this.displayedStudents.length;i++ ){
                if(this.displayedStudents[i].Student_Code__c == studentCode){
                    this.displayedStudents[i].selected__c =event.target.checked;
                    if(event.target.checked == true){
                        this.selectedStudentIds.push(this.displayedStudents[i].Student_Code__c);
                    }
                }
            }
        } catch (error) {
            console.log("error message", error.message);
        }
        this.updateSelectAll();
    }
    updateSelectAll(){
        this.selectedStudentIds=[];
        try {
            for(let i = 0; i<this.displayedStudents.length;i++ ){
                if( this.displayedStudents[i].selected__c== true){
                    this.selectedStudentIds.push(this.displayedStudents[i].Student_Code__c);
                }
            }
            if(this.selectedStudentIds.length == ITEMS_PER_PAGE){
                this.isSelectAllChecked=true;
            }else{
                this.isSelectAllChecked=false;
            }    
        } catch (error) {
            console.log("error message when updateSelectAll", error.message);
        }
        
    }
    deleteSelectedStudents() {
        this.selectedStudentIds=[];
        for(let i = 0; i<this.displayedStudents.length;i++ ){
            if( this.displayedStudents[i].selected__c== true){
                this.selectedStudentIds.push(this.displayedStudents[i].Id);
            }
        }
        alert(`are you sure  to delete ${this.selectedStudentIds.length} students`);
        deleteSelectedStudentsCtrl({ studentIds: this.selectedStudentIds })
            .then(result => {
                this.selectedStudentIds = [];
                this.isSelectAllChecked = false;
                this.showSuccessToast('Multiples Student deleted successfully');
                this.refreshStudents();
            })
            .catch(error => {
                console.error('Error deleting students: ', error);
            });
        alert("delete selected student successfully");
    }
    deleteStudentHandler(event) {
        const studentId = event.currentTarget.dataset.studentId;
        this.deleteStudent(studentId);
        this.showModal = false;
        this.selectedStudent = null;
    }

    deleteStudent(studentId) {
        deleteStudentRecord({ studentId })
            .then(result => {
                // Handle success
                this.showSuccessToast('Student deleted successfully');
                this.refreshStudents();
            })
            .catch(error => {
                // Handle error
                console.error('Error deleting student: ', error);
            });
    }
    refreshStudents() {
        refreshApex(this.wiredStudents);
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
