// LWC_UpdateStudent.js
import { LightningElement, api ,wire} from 'lwc';
import getClassOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getClassOptions';

export default class LWC_CreateStudent extends LightningElement {
    @api genderOptions;
    classes;
    selectedClass;
    selectedGender;
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
}
