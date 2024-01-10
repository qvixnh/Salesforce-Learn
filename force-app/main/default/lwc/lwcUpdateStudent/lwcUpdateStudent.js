// LWC_UpdateStudent.js
import { LightningElement, api ,wire} from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';

export default class LWC_UpdateStudent extends LightningElement {
    @api studentId;
    @api student;
    @api genderOptions;
    classes;
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
    // handleUpdate() {
    //     // Emit an event to notify the parent component to open the modal
    //     const updateEvent = new CustomEvent('openmodal', {
    //         detail: {
    //             component: 'LWC_UpdateStudent',
    //             studentId: this.studentId,
    //         },
    //     });
    //     this.dispatchEvent(updateEvent);
    // }

}
