// LWC_SearchStudent.js
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
import getStudents from '@salesforce/apex/LWC_SearchStudentCtrl.getStudents';
import deleteSelectedStudentsCtrl from '@salesforce/apex/LWC_SearchStudentCtrl.deleteSelectedStudentsCtrl';
import deleteStudentRecord from '@salesforce/apex/LWC_SearchStudentCtrl.deleteStudentRecord';

const ITEMS_PER_PAGE = 2;

export default class LWC_SearchStudent extends LightningElement {
    classes;
    @track students;
    @track displayedStudents;
    error;
    //search condition
    @track selectedClass = null;
    @track selectedGender  = null;
    @track searchCode = '';
    @track  searchName = '';
    @track birthdate = '';
    @track dayOfBirth = null;
    @track monthOfBirth = null;
    @track yearOfBirth = null;

    //pagination
    @track currentPage = 1;
    @track totalPages = 1;
    @track pageNumbers;
    // Add this property to your component
    pageNumbers = [];
    // Variables for modal
    @track showModal = false;
    @track isUpdateModalOpen=false;
    @track isCreateModalOpen=false;
    @track isDetailModalOpen=false;
    @track isDelSelStuModalOpen=false;
    @track selectedStudent;

    // Variables for selecting students
    @track selectedStudentIds = [];
    @track isSelectAllChecked = false;
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
    @track genderOptions=[
        {label:'All', value: 2},
        {label:'Male', value: 1},
        {label:'Female', value:0}        
    ];
    connectedCallback() {
        console.log('lWC_SearchStudent Component connected to the DOM');
        this.loadStudents();
    }
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
    loadStudents() {
        console.log("selected")
        getStudents({
            classId: this.selectedClass,
            gender: this.selectedGender,
            searchName: this.searchName,
            searchCode: this.searchCode,
            day: this.dayOfBirth,
            month: this.monthOfBirth,
            year: this.yearOfBirth,
            birthdate: this.birthdate,
            orderField: 'Student_Code__c',
            orderType: 'ASC'
        })
            .then(result => {
                this.students = result;
                this.showSuccessToast("Student list loaded successfully");
                this.updateDisplayedStudents();
                this.error = undefined;
            })
            .catch(error => {
                this.handleClearFilters();
                this.loadStudents();
                this.error = 'Error retrieving students: ' + error.body.message;
                this.students = undefined;
            });
    }
    //search condition
    handleClassChange(event) {
        this.selectedClass = event.detail.value;
    }
    handleGenderChange(event) {
        this.selectedGender = event.detail.value;
        console.log("this.selectedGender ", this.selectedGender);
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
        this.loadStudents();
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
            try {
                this.totalPages = Math.ceil(this.students.length / ITEMS_PER_PAGE);
                const startIndex = (this.currentPage - 1) * ITEMS_PER_PAGE;
                const endIndex = startIndex + ITEMS_PER_PAGE;
                this.displayedStudents = this.students.slice(startIndex, endIndex);
                this.displayedStudents = this.displayedStudents.map(student => ({
                    ...student,
                    selected__c:false
                }));
                this.isSelectAllChecked = false;

                var startPage = Math.max(1, this.currentPage - 2);
                var endPage = Math.min(this.totalPages, startPage + 4);
                this.pageNumbers=[]
                for (var i = startPage; i <= endPage; i++) {
                    this.pageNumbers.push(i);
                }
                // this.pageNumbers = Array.from({ length: this.totalPages }, (_, i) => i + 1);
            } catch (error) {
                console.log("error when updating student", error.message);
            }
            
        }
    }

    get pageOptions() {
        return this.pageNumbers.map(page => ({ label: String(page), value: page }));
    }
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }
    get isCurrentPage(){
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
    goToPage(event) {
        this.currentPage = event.target.value;
        this.updateDisplayedStudents();
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
        this.loadStudents();
    }
    openModalCreate(event) {
        const studentId = event.currentTarget.dataset.studentId;
        this.selectedStudent = this.students.find(student => student.Id === studentId);
        this.isCreateModalOpen = true;
    }
    closeModalCreate() {
        this.isCreateModalOpen = false;
        this.selectedStudent = null;
        this.loadStudents();

    }
    openModalDetail(event) {
        const studentId = event.currentTarget.dataset.studentId;
        this.selectedStudent = this.students.find(student => student.Id === studentId);
        this.isDetailModalOpen = true;
    }
    closeModalDetail() {
        this.isDetailModalOpen = false;
        this.selectedStudent = null;
    }
    openModalDelSelStu() {
        this.isDelSelStuModalOpen = true;
    }
    closeModalDelSelStu() {
        this.isDelSelStuModalOpen = false;
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
    handleDeleteSelectedStudent(){
        this.deleteSelectedStudents();
    }
    deleteSelectedStudents() {
        this.selectedStudentIds=[];
        for(let i = 0; i<this.displayedStudents.length;i++ ){
            if( this.displayedStudents[i].selected__c== true){
                this.selectedStudentIds.push(this.displayedStudents[i].Id);
            }
        }
        deleteSelectedStudentsCtrl({ studentIds: this.selectedStudentIds })
            .then(result => {
                this.selectedStudentIds = [];
                this.isSelectAllChecked = false;
                this.showSuccessToast('Multiples Student deleted successfully');
                this.loadStudents();
            })
            .catch(error => {
                console.error('Error deleting students: ', error);
            });
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
                this.showSuccessToast('Student deleted successfully');
                this.loadStudents();
            })
            .catch(error => {
                // Handle error
                console.error('Error deleting student: ', error);
            });
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
