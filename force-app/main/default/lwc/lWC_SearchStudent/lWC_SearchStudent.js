// LWC_SearchStudent.js
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
import getStudentsByCondition from '@salesforce/apex/LWC_SearchStudentCtrl.getStudentsByCondition';
import deleteSelectedStudentsCtrl from '@salesforce/apex/LWC_SearchStudentCtrl.deleteSelectedStudentsCtrl';
import deleteStudentRecord from '@salesforce/apex/LWC_SearchStudentCtrl.deleteStudentRecord';

const ITEMS_PER_PAGE = 10;

export default class LWC_SearchStudent extends LightningElement {
    //track variable
    @track classes;
    @track students;
    @track displayedStudents;
    @track pageNumbers = [];
    @track selectedStudentIds = [];
    error;
    //search condition
    selectedClass = null;
    selectedGender  = null;
    searchCode = 'ST-';
    searchName = '';
    birthdate = '';
    dayOfBirth = null;
    monthOfBirth = null;
    yearOfBirth = null;
    // Define select options for day and month
    fieldOrderBy = 'Student_Code__c';
    orderType = 'ASC';
    //pagination
    currentPage = 1;
    totalPages = 1;
    // Add this property to your component
    // Variables for modal
    showModal = false;
    isUpdateModalOpen=false;
    isCreateModalOpen=false;
    isDetailModalOpen=false;
    isDelSelStuModalOpen=false;
    selectedStudent;
    // Variables for selecting students
    isSelectAllChecked = false;
    get fieldOrderByOptions() {
        return [
            { label: 'Student Code', value: 'Student_Code__c' },
            { label: 'Student Name', value: 'First_Name__c' },
            { label: 'Class', value: 'Class__r.Class_Name__c' },
            { label: 'Student Birthdate', value: 'Birthdate__c' },
            { label: 'Student Gender', value: 'Gender__c' },
        ];
    }

    get orderTypeOptions() {
        return [
            { label: 'Ascendant', value: 'ASC' },
            { label: 'Descendant', value: 'DESC' },
        ];
    }
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
        {label:'All', value: '2'},
        {label:'Male', value: '1'},
        {label:'Female', value:'0'}        
    ];
    connectedCallback() {
        this.loadStudents(true);
        this.template.addEventListener('studentcreated', this.handleStudentCreated.bind(this));
    }
    handleStudentCreated() {
        console.log("student list load by event ");
        this.loadStudents(true);
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
    loadStudents(flagMessage=false) {
        const searchCondition = {
            classId: this.selectedClass,
            gender: this.selectedGender,
            searchName: this.searchName,
            searchCode: this.searchCode,
            day: this.dayOfBirth,
            month: this.monthOfBirth,
            year: this.yearOfBirth,
            birthdate: this.birthdate,
            orderField: this.fieldOrderBy,
            orderType: this.orderType
        };
        var searchJson = JSON.stringify(searchCondition);
        getStudentsByCondition({
            searchConditionJSON: searchJson
        })
            .then(result => {
                this.students = result;
                if(flagMessage){
                    this.showSuccessToast("Student list loaded successfully");
                }
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
    handleFieldChange(event) {
        this.fieldOrderBy = event.detail.value;
    }
    handleTypeChange(event) {
        this.orderType = event.detail.value;
    }
    handleGenderChange(event) {
        this.selectedGender = event.detail.value;
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
        if(this.monthOfBirth==2 && this.dayOfBirth>28){
            this.dayOfBirth=0;
        }
    }
    handleMonthOfBirthChange(event) {
        this.monthOfBirth = event.detail.value;
        var daysInMonth = new Date(this.yearOfBirth,this.monthOfBirth,0).getDate();
        this.dayOptions=[];
        for (var i = 1; i <= daysInMonth; i++) {
            this.dayOptions.push({ label: i.toString(), value: i.toString() });
        }
    }
    handleYearOfBirthChange(event) {
        this.yearOfBirth = event.detail.value;
        if(this.yearOfBirth==''){
            this.yearOfBirth = null;
        }
    }


    handleSearch() {
        console.log("Student year: ", this.yearOfBirth);
        this.currentPage = 1;
        this.loadStudents(true);
        this.updateDisplayedStudents();
    }
    handleClearFilters() {
        this.selectedClass = null;
        this.searchCode = 'ST-';
        this.searchName = '';
        this.birthdate='';
        this.dayOfBirth = null;
        this.monthOfBirth = null;
        this.yearOfBirth = null;
        this.currentPage = 1;
        this.selectedGender = 2;
    }
    updateDisplayedStudents() {
        
        if (this.students) {
            try {
                this.totalPages = Math.ceil(this.students.length / ITEMS_PER_PAGE);
                const startIndex = (this.currentPage - 1) * ITEMS_PER_PAGE;
                const endIndex = startIndex + ITEMS_PER_PAGE;
                this.displayedStudents = this.students.slice(startIndex, endIndex);
                this.displayedStudents = this.displayedStudents.map((student, index) => ({ ...student, index: index + 1 }));
                this.isSelectAllChecked = false;
                var startPage = Math.max(1, this.currentPage - 1);
                var endPage = Math.min(this.totalPages, startPage + 2);
                this.pageNumbers=[]
                if(this.currentPage==this.totalPages && (startPage-1)>=1){
                    this.pageNumbers.push({ pageNumber: startPage - 1, status: false });
                }
                for (var i = startPage; i <= endPage; i++) {
                    if(i==this.currentPage){
                        this.pageNumbers.push({ pageNumber: i, status:true });
                    }
                    else{
                        this.pageNumbers.push({ pageNumber: i, status: false });
                    }
                }
                this.updateSelectAll();
            } catch (error) {
                console.log("error when updating student", error.message);
            }
            
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
    lastPage() {
        this.currentPage = this.totalPages;
        this.updateDisplayedStudents();

    }
    firstPage() {
        this.currentPage = 1;
        this.updateDisplayedStudents();

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
        this.template.addEventListener('studentcreated', this.handleStudentCreated.bind(this));
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
        this.loadStudents();
    }        
    closeModalDelete() {
        this.showModal = false;
        this.selectedStudent = null;
    }
    handleSelectAll(event) {
        this.isSelectAllChecked = event.target.checked;
        if (this.isSelectAllChecked) {
            this.selectedStudentIds = this.displayedStudents.map(student => student.Id);
            for(var stu of this.displayedStudents){
                this.checkStuden(stu.Student_Code__c,true);
            }
        } else {
            this.selectedStudentIds = [];
        }
        this.displayedStudents = this.displayedStudents.map(student => ({
            ...student,
            selected__c: this.isSelectAllChecked
        }));
        for(var stu of this.displayedStudents){
            this.checkStuden(stu.Student_Code__c,this.isSelectAllChecked);
        }
        
    }
    checkStuden(code,check=true){
        for(var stu of this.students){
            if(stu.Student_Code__c == code){
                stu.selected__c=check;
            }
        }
        
    }
    handleSelect(event) {
        const studentCode = event.target.value;
        const newcheck=event.target.checked;
        this.checkStuden(studentCode,newcheck);
        try {
            for(let i = 0; i<this.displayedStudents.length;i++ ){
                if(this.displayedStudents[i].Student_Code__c == studentCode){
                    this.displayedStudents[i].selected__c = newcheck;
                    // if(newcheck){
                    //     this.selectedStudentIds.push(this.displayedStudents[i].Student_Code__c);
                    // }
                }
            }
        } catch (error) {
            console.log("error message", error.message);
        }
        console.log(JSON.stringify(this.students));
        this.updateSelectAll();
    }
    
    updateSelectAll(){
        this.selectedStudentIds=[];
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
                this.closeModalDelSelStu();
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
