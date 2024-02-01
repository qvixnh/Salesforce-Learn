import { LightningElement, api, track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getSemesterOptions from '@salesforce/apex/c/LWC_DetailStudentCtrl.getSemesterOptions';
import getSemesterOptions from '@salesforce/apex/LWC_DetailStudentCtrl.getSemesterOptions';
import getResults from '@salesforce/apex/LWC_DetailStudentCtrl.getResults';
export default class LWC_ScoreTable extends LightningElement {
    @api student;
    @track subjectScoreList;
    @track semesterOptions;
    trungbinhHK = 0;
    tinchiHK = 0;
    selectedSemester;
    selectedSemesterName;

    handleSemesterChange(event) {
        this.selectedSemester = event.detail.value;
        this.loadSubjectScores();
    }
    @wire(getSemesterOptions)
    wiredSemesters({ error, data }) {
        if (data) {
            this.semesterOptions = data.map(option => ({
                label:option.Name,
                value: option.Id
                
            }));
            this.semesterOptions.unshift({ label: 'All semesterOptions', value: null });
        } else if (error) {
            this.semesterOptions = undefined;
        }
    }
    
    loadSubjectScores() {
        getResults({
            studentId: this.student.Id,
            semesterId: this.selectedSemester,
        })
            .then(result => {
                this.subjectScoreList = result.scoreTableDtoList;
                this.tinchiHK = result.tinchiHK;                        
                this.trungbinhHK = result.trungbinhHK;
                this.selectedSemesterName = result.semesterName;

            })
            .catch(error => {
                this.showSuccessToast('Error retrieving subject scores:',error);
            });        
    }
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(event);
    }
}