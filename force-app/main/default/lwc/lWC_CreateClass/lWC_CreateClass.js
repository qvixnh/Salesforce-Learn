import { LightningElement } from 'lwc';
import createClass from '@salesforce/apex/LWC_SearchClass.createClass';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LWC_CreateClass extends LightningElement {
    ERRORTYPE = 'error'
    SUCCESSTYPE = 'success'
    falcutyOptions=[
        {label:'Công nghệ thông tin', value:'CNTT'},
        {label:'Quản Trị Kinh Doanh', value:'QTKD'},                
        {label:'Kinh tế xã hội', value:'KTXH'}
    ];
    handleFalcutyChange(event) {
        this.falcuty = event.target.value;
    }
    createStudent(){
        createClass({
            falcuty:this.falcuty
        }).then(result => {
            this.showToast("class created successfully", this.SUCCESSTYPE);
        })
        .catch(error => {
            this.showToast('Error creating student record:'+ error, this.ERRORTYPE);
        });    
       
    }
    showToast(message,type) {
        const event = new ShowToastEvent({
            title: type,
            message: message,
            variant: type,
        });
        this.dispatchEvent(event);
    }
}