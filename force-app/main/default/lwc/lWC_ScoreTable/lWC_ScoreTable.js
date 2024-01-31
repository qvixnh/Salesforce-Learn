import { LightningElement, api, track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getSemesterOptions from '@salesforce/apex/c/LWC_DetailStudentCtrl.getSemesterOptions';
import getSemesterOptions from '@salesforce/apex/LWC_DetailStudentCtrl.getSemesterOptions';
import getScoreTableDtoList from '@salesforce/apex/LWC_DetailStudentCtrl.getScoreTableDtoList';
export default class LWC_ScoreTable extends LightningElement {
    @api student;
    @track subjectScoreList;
    @track semesterOptions;
    trungbinhHK;
    tinchiHK;
    selectedSemester;

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
        getScoreTableDtoList({
            studentId: this.student.Id,
            semesterId: this.selectedSemester,
        })
            .then(result => {
                this.subjectScoreList = result;
                // this.subjectScoreList = result.scoreTableDtoList;
                // console.log(JSON.stringify(subjectScoreList));
                // this.tinchiHK = result.tinchiHK;
                // this.trungbinhHK = result.trungbinhHK;
            })
            .catch(error => {
                let errorMessage = '';
                if(error?.body?.message){
                    errorMessage = error.body.message;
                }
                else if(error?.message){
                    errorMessage = error.message;
                }
                else{
                    errorMessage = error;
                }
                this.showSuccessToast('Error retrieving subject scores:',errorMessage);
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