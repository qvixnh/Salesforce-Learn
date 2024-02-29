import { LightningElement, track, api} from 'lwc';
import getStudentListByClass from '@salesforce/apex/LWC_SearchClass.getStudentListByClass';

export default class LWC_DetailClass extends LightningElement {
    @track stuList;
    @api clsId;
    connectedCallback(){
        console.log(this.clsId);
        this.loadStudent();
    }
    loadStudent(){
        getStudentListByClass({
            clsId:this.clsId
        }).then(result => {
            this.stuList = result;
        })
        .catch(error => {
            console.log("error when loading student list by class id" + error);
        });    
       
    }
}