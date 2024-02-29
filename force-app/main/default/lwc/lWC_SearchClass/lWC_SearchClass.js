import { LightningElement, track } from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';
const ITEMS_PER_PAGE = 5;
export default class LWC_SearchClass extends LightningElement {
    @track classes;
    @track displayedClasses;
    @track pageNumbers = [];
    currentPage = 1;
    totalPages = 1;
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
}

