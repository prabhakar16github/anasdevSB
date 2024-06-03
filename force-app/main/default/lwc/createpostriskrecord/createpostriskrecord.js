import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Createpostriskrecord extends LightningElement {
   @api postholdid;
    currentDate;
    @api postchild;
    @api releasechild;
    
 handleSubmit(event){

        // stop the form from submitting
        event.preventDefault(); 
        alert('rahul');
        //get all the fields
        const fields = event.detail.fields;
        //get Current Date and Time
        var dateVar = new Date();
        //Current Date 
        this.currentDate = new Date(dateVar.getTime() + dateVar.getTimezoneOffset()*60000).toISOString();
        
        //Map remainig fields to values here 
        fields.Enforced_By__c = userId;
        fields.Enforced_Date__c = this.currentDate;
        
        //submit the form
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        
   
    }
    handleSuccess(event) {
     
        const evt = new ShowToastEvent({
            title: 'Post Risk Hold',
            message: 'Put On Hold Record ID: ' + event.detail.id,
            variant: 'success',

        });
        
        this.dispatchEvent(evt);

    }
    handleClose(event){
        this.postchild=false;
    }
}