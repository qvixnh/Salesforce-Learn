import { LightningElement, api, track,wire} from 'lwc';
// import getSemesterOptions from '@salesforce/apex/c/LWC_DetailStudentCtrl.getSemesterOptions';
import getSemesterOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getSemesterOptions';

export default class LWC_ScoreTable extends LightningElement {
    @api student;
    @track semesterOptions;
    selectedSemester;
    @wire(getSemesterOptions)
    wiredSemesters({ error, data }) {
        if (data) {
            this.semesterOptions = data.map(option => ({
                label:option.Name,
                value: option.Id
                
            }));
            this.semesterOptions.unshift({ label: 'All semesterOptions', value: null });
            this.error = undefined;
        } else if (error) {
            this.error = 'Error retrieving semesterOptions';
            this.semesterOptions = undefined;
        }
    }
}