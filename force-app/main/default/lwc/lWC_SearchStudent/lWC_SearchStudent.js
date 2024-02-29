// LWC_SearchStudent.js
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
import getStudentsByCondition from '@salesforce/apex/LWC_SearchStudentCtrl.getStudentsByCondition';
import deleteSelectedStudentsCtrl from '@salesforce/apex/LWC_SearchStudentCtrl.deleteSelectedStudentsCtrl';
import deleteStudentRecord from '@salesforce/apex/LWC_SearchStudentCtrl.deleteStudentRecord';

const ITEMS_PER_PAGE = 10;

export default class LWC_SearchStudent extends LightningElement {
    ERRORTYPE = 'error'
    SUCCESSTYPE = 'success'
    //track variable
    @track classes;
    @track students;
    @track displayedStudents;
    @track pageNumbers = [];
    @track selectedStudentIds = [];
    @track genderOptions=[
        {label:'All', value: '2'},
        {label:'Male', value: '1'},
        {label:'Female', value:'0'}        
    ];
    pageSize =10;
    error;
    //search condition
    selectedClass = null;
    selectedGender  = null;
    searchCode = 'SV_';
    searchName = '';
    birthdate = '';
    dayOfBirth = null;
    monthOfBirth = null;
    yearOfBirth = null;
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
    selectionNumber = 0;
    // Variables for selecting students
    isSelectAllChecked = false;
    
    get pageSizeOptions() {
        return [
            { label: '5', value: 5 },
            { label: '10', value: 10 },
            { label: '20', value: 20 },
        ];
    }
    get fieldOrderByOptions() {
        return [
            { label: 'Student Code', value: 'StudentCode__c' },
            { label: 'Student Name', value: 'Firstname__c' },
            { label: 'Student Birthdate', value: 'Birthday__c' },
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
    
    
    connectedCallback() {
        this.loadStudents(true);
        this.template.addEventListener('studentcreated', this.handleStudentCreated.bind(this));
    }
    handleStudentCreated() {
        this.loadStudents(true);
    }
    @wire(getClassOptions)
    wiredClasses({ error, data }) {
        if (data) {
            this.classes = data.map(option => ({
                label:option.Name,
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
        };
        var searchJson = JSON.stringify(searchCondition);
        getStudentsByCondition({
            searchConditionJSON: searchJson
        })
            .then(result => {
                this.students = result;
                if(flagMessage){
                    this.showToast("Student list loaded successfully", this.SUCCESSTYPE);

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
        this.searchCode = event.detail.value.trim();
    }
    handleSearchNameChange(event) {
        this.searchName = event.detail.value.trim();
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
        this.currentPage = 1;
        this.loadStudents(true);
        this.updateDisplayedStudents();
    }
    //clear search filter
    handleClearFilters() {
        this.selectedClass = null;
        this.searchCode = 'SV_';
        this.searchName = '';
        this.birthdate='';
        this.dayOfBirth = null;
        this.monthOfBirth = null;
        this.yearOfBirth = 0;
        this.currentPage = 1;
        this.selectedGender = 2;
    }
    //Method to update the displayed students(per page) in pagination
    updateDisplayedStudents() {
        if (this.students) {
            try {
                this.totalPages = Math.ceil(this.students.length / ITEMS_PER_PAGE);
                const startIndex = (this.currentPage - 1) * ITEMS_PER_PAGE;
                const endIndex = startIndex + ITEMS_PER_PAGE;
                this.displayedStudents = this.students.slice(startIndex, endIndex);
                this.displayedStudents = this.displayedStudents.map((student, index) => ({ ...student, index: index + 1 }));
                this.isSelectAllChecked = false;
                var startPage = Math.max( 1, this.currentPage - 1);
                var endPage = Math.min(this.totalPages, startPage + 2);
                this.pageNumbers=[]
                if(this.currentPage == this.totalPages && (startPage-1) >= 1){
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
                var message = "error when updating student" + error.message;
                this.showToast(message, this.ERRORTYPE);
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
        return this.selectionNumber==0;
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
                this.checkStuden(stu.StudentCode__c,true);
            }
        } else {
            this.selectedStudentIds = [];
        }
        this.displayedStudents = this.displayedStudents.map(student => ({
            ...student,
            selected__c: this.isSelectAllChecked
        }));
        for(var stu of this.displayedStudents){
            this.checkStuden(stu.StudentCode__c,this.isSelectAllChecked);
        }
        
    }
    //Handle set the student selected checkbox to new status 
    checkStuden(code,check=true){
        for(var stu of this.students){
            if(stu.StudentCode__c == code){
                stu.selected__c=check;
            }
        }
        this.updateSelectNumber();
    }
    //Method to update the number of selected students 
    updateSelectNumber(){
        var count =0;
        for(var stu of this.students){
            if(stu.selected__c == true){
                count++;
            }
        }
        this.selectionNumber=count;
    }
    //Method to select student when click on the student checkbox
    handleSelect(event) {
        const studentCode = event.target.value;
        const newcheck=event.target.checked;
        this.checkStuden(studentCode,newcheck);
        for(let i = 0; i<this.displayedStudents.length;i++ ){
            if(this.displayedStudents[i].StudentCode__c == studentCode){
                this.displayedStudents[i].selected__c = newcheck;
            }
    }
    this.updateSelectAll();
    }
    // HTML handle: Methods for opening and closing modals delete multiples students
    handleDeleteSelectedStudent(){
        this.deleteSelectedStudents();
        this.selectionNumber=0;
    }
    // HTML handle: Methods for opening and closing modals delete one student
    deleteStudentHandler(event) {
        const studentId = event.currentTarget.dataset.studentId;
        this.deleteStudent(studentId);
        this.showModal = false;
        this.selectedStudent = null;
    }
    // Methods to update the "is select all checkbox" when check or uncheck other checkboxes
    updateSelectAll(){
        this.selectedStudentIds=[];
        for(let i = 0; i<this.displayedStudents.length;i++ ){
            if( this.displayedStudents[i].selected__c== true){
                this.selectedStudentIds.push(this.displayedStudents[i].StudentCode__c);

            }
        }
        if(this.selectedStudentIds.length == ITEMS_PER_PAGE){
            this.isSelectAllChecked=true;
        }else{
            this.isSelectAllChecked=false;
        }    
    }
    // Methods to delete selected students
    deleteSelectedStudents() {
        this.selectedStudentIds=[];
        for(let i = 0; i<this.students.length;i++ ){
            if( this.students[i].selected__c== true){
                this.selectedStudentIds.push(this.students[i].Id);
            }
        }
        deleteSelectedStudentsCtrl({ studentIds: this.selectedStudentIds })
            .then(result => {
                this.selectedStudentIds = [];
                this.isSelectAllChecked = false;
                this.showToast('Multiples Student deleted successfully', this.SUCCESSTYPE);
                this.closeModalDelSelStu();
            })
            .catch(error => {
                console.error('Error deleting students: ', error);
            });
    }
    //Methods for selecting and deleting students
    deleteStudent(studentId) {
        deleteStudentRecord({ studentId })
            .then(result => {
                this.showToast('Student deleted successfully', this.SUCCESSTYPE);
                this.loadStudents();
            })
            .catch(error => {
                console.error('Error deleting student: ', error);
            });
    }
    
    // Method to clear selection
    clearSelection(){
        for(var stu of this.displayedStudents){
            stu.selected__c=false;
        }
        for(var stu of this.students){
            stu.selected__c=false;
        }
        this.selectedStudentIds=[];
        this.selectionNumber=0;
        this.isSelectAllChecked=false;
    }
    // Method to sort students by code
    sortStudentsByCode(event) {
        const currentUtility= event.target.iconName;
        let sortedStudents = [...this.students];
        if(currentUtility == 'utility:arrowdown'){
            sortedStudents.sort((a, b) => {
                return a.StudentCode__c.localeCompare(b.StudentCode__c);
            });
            this.template.querySelector('.studentCodeSort').iconName = 'utility:arrowup';
        }
        else if((currentUtility == 'utility:arrowup')){
            sortedStudents.sort((a, b) => {
                return b.StudentCode__c.localeCompare(a.StudentCode__c);
            });
            this.template.querySelector('.studentCodeSort').iconName =  'utility:arrowdown';
        }
        this.students = sortedStudents;
        this.updateDisplayedStudents();
    }
    // Method to sort students by code
    sortStudentsByClass(event) {
        const currentUtility= event.target.iconName;
        let sortedStudents = [...this.students];
        try {
            if(currentUtility == 'utility:arrowdown'){
                sortedStudents.sort((a, b) => {
                    return a.Class_look__c.localeCompare(b.Class_look__c);
                });
                this.template.querySelector('.studentClassSort').iconName = 'utility:arrowup';
            }
            else if((currentUtility == 'utility:arrowup')){
                sortedStudents.sort((a, b) => {
                    return b.Class_look__c.localeCompare(a.Class_look__c);
                });
                this.template.querySelector('.studentClassSort').iconName =  'utility:arrowdown';
            }
        } catch (error) {
            console.log(error);
        }
       
        this.students = sortedStudents;
        this.updateDisplayedStudents();
    }
    // Method to sort students by First Name
    sortByFirstName(event) {
        const currentUtility= event.target.iconName;
        let sortedStudents = [...this.students];
        try {
            if(currentUtility == 'utility:arrowdown'){
                sortedStudents.sort((a, b) => {
                    return ('' + a.Firstname__c).localeCompare(b.Firstname__c);
                });
                this.template.querySelector('.sortByFirstNameCls').iconName = 'utility:arrowup';
            }
            else if((currentUtility == 'utility:arrowup')){
                sortedStudents.sort((a, b) => {
                    return ('' + b.Firstname__c).localeCompare(a.Firstname__c);
                });
                this.template.querySelector('.sortByFirstNameCls').iconName =  'utility:arrowdown';
            }
        } catch (error) {
            console.log(error);
        }
       
        this.students = sortedStudents;
        this.updateDisplayedStudents();
    }
    // Method to sort students by First Name
    sortByGender(event) {
        const currentUtility= event.target.iconName;
        let sortedStudents = [...this.students];
        try {
            if(currentUtility == 'utility:arrowdown'){
                sortedStudents.sort((a, b) => {
                    return Number(a.Gender__c) - Number(b.Gender__c);
                });
                this.template.querySelector('.sortByGendercls').iconName = 'utility:arrowup';
            }
            else if((currentUtility == 'utility:arrowup')){
                sortedStudents.sort((a, b) => {
                    return Number(b.Gender__c) - Number(a.Gender__c);
                });
                this.template.querySelector('.sortByGendercls').iconName =  'utility:arrowdown';
            }
        } catch (error) {
            console.log(error);
        }
       
        this.students = sortedStudents;
        this.updateDisplayedStudents();
    }
    //HTML Handle: Method to display toast messages
    showToast(message,type) {
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
        });
        this.dispatchEvent(event);
    }
}
