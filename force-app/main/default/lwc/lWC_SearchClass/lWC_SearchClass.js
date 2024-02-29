import { LightningElement, track } from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
const ITEMS_PER_PAGE = 5;
export default class LWC_SearchClass extends LightningElement {
    @track classes;
    @track displayedClasses;
    @track pageNumbers = [];
    currentPage = 1;
    totalPages = 1;
    createStatus = false;
    detailStatus = false;
    selectedClassId;
    
    connectedCallback() {
        this.loadClasses();
    }
    loadClasses() {
        getClassOptions({})
            .then(result => {
                this.classes = result;
                this.updateDisplayedClasses();
            })
            .catch(error => {
                this.error = 'Error retrieving classes: ' + error;
                this.classes = undefined;
            });
    }
    updateDisplayedClasses(){
        if (this.classes) {
            try {
                this.totalPages = Math.ceil(this.classes.length / ITEMS_PER_PAGE);
                const startIndex = (this.currentPage - 1) * ITEMS_PER_PAGE;
                const endIndex = startIndex + ITEMS_PER_PAGE;
                this.displayedClasses = this.classes.slice(startIndex, endIndex);
                this.displayedClasses = this.displayedClasses.map((student, index) => ({ ...student, index: index + 1 }));
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
            } catch (error) {
                var message = "error when updating student" + error;
                console.log(message);
            }
        }
    }
    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateDisplayedClasses();
        }

    }
    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateDisplayedClasses();
        }
    }
    lastPage() {
        this.currentPage = this.totalPages;
        this.updateDisplayedClasses();

    }
    firstPage() {
        this.currentPage = 1;
        this.updateDisplayedClasses();

    }
    goToPage(event) {
        this.currentPage = event.target.value;
        this.updateDisplayedClasses();

    }
    sortByCode(event){
        const currentUtility= event.target.iconName;
        let sortedClasses = [...this.classes];
        try {
            if(currentUtility == 'utility:arrowdown'){
                sortedClasses.sort((a, b) => {
                    return b.Name.localeCompare(a.Name);
                });
                this.template.querySelector('.sortByCodeCls').iconName = 'utility:arrowup';
            }
            else if((currentUtility == 'utility:arrowup')){
                sortedClasses.sort((a, b) => {
                    return a.Name.localeCompare(b.Name);
                });
                this.template.querySelector('.sortByCodeCls').iconName =  'utility:arrowdown';
            }
        } catch (error) {
            console.log(error);
        }
       
        this.classes = sortedClasses;
        this.updateDisplayedClasses();
    }
    sortByStudentNumber(event){
        const currentUtility= event.target.iconName;
        let sortedClasses = [...this.classes];
        if(currentUtility == 'utility:arrowdown'){
            sortedClasses.sort((a, b) => {
                return b.NumberOfStudent__c - a.NumberOfStudent__c;
            });
            this.template.querySelector('.sortByStudentNumberCls').iconName = 'utility:arrowup';
        }
        else if((currentUtility == 'utility:arrowup')){
            sortedClasses.sort((a, b) => {
                return a.NumberOfStudent__c - b.NumberOfStudent__c;
            });
            this.template.querySelector('.sortByStudentNumberCls').iconName =  'utility:arrowdown';
        }
       
        this.classes = sortedClasses;
        this.updateDisplayedClasses();
    }
    openCreate() {
        this.createStatus = true;
    }
    closeCreate() {
        this.createStatus = false;
    }
    openDetail(event) {
        this.selectedClassId =  event.currentTarget.dataset.classId;
        this.detailStatus = true;
    }
    closeDetail() {
        this.detailStatus = false;
    }

}

