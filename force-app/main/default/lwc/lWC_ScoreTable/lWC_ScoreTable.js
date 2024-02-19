import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSemesterOptions from '@salesforce/apex/LWC_DetailStudentCtrl.getSemesterOptions';
import getResults from '@salesforce/apex/LWC_DetailStudentCtrl.getResults';
export default class LWC_ScoreTable extends LightningElement {
    ERRORTYPE = 'error';
    SUCCESSTYPE = 'success';
    @api student;
    @track semesterDTOList;
    @track semesterOptions;
    tinchiHK = 0;
    selectedSemester;
    notStudy = false;
    connectedCallback() {
        this.loadSemester();
    }
    /*
    Load semester select options
    */
    loadSemester() {
        getSemesterOptions()
            .then(result => {
                if (result) {
                    this.semesterOptions = result.map(option => ({
                        label:option.Name,
                        value: option.Id
                        
                    }));
                    this.selectedSemester = result[0].Id;
                    this.loadSubjectScores();
                    this.semesterOptions.unshift({ label: 'All semesterOptions', value: null });
                } else if (error) {
                    this.semesterOptions = undefined;
                }
            })
            .catch(error => {
                this.showSuccessToast('Error retrieving subject semester:',error);
            });        
    }
    /*
    Handle the semester value changes
    */
    handleSemesterChange(event) {
        this.selectedSemester = event.detail.value;
        this.loadSubjectScores();
    }
    /*
    Load subject score dto
    */
    loadSubjectScores() {
        getResults({
            studentId: this.student.Id,
            semesterId: this.selectedSemester,
        })
            .then(result => {
                this.semesterDTOList = result;
                if(result.length <1 ){
                    this.notStudy = true;
                }else{
                    this.notStudy = false;
                }
            })
            .catch(error => {
                var message = 'Error retrieving subject scores: '+ error;
                this.showToast(message,this.ERRORTYPE);
            });        
    }
    showToast(message, type) {
        const event = new ShowToastEvent({
            title:  type,
            message: message,
            variant: type,
        });
        this.dispatchEvent(event);
    }
}