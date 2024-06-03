import { LightningElement, api } from 'lwc';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Releasepostrisk extends LightningElement {
    @api postholdidchild;
    currentDate;
    closeReleasePostRisk = true;

    handleSubmit(event){
         // stop the form from submitting
         event.preventDefault();  
         //get all the fields
         const fields = event.detail.fields;
         //get Current Date and Time
         var dateVar = new Date();
         //Current Date 
         this.currentDate = new Date(dateVar.getTime() + dateVar.getTimezoneOffset()*60000).toISOString();

          //Map remainig fields to values here 
        fields.Released_By__c = userId;
        fields.Release_Date__c = this.currentDate;
        
        //submit the form
        this.template.querySelector('lightning-record-edit-form').submit(fields);

        this.closeReleasePostRisk = false;

    }

    handleSuccess(event) {
     
        const evt = new ShowToastEvent({
            title: 'Release Post Risk',
            message: 'Release Record ID: ' + event.detail.id,
            variant: 'success',

        });
        
        this.dispatchEvent(evt);
    }
    
    handleClose(event){
        this.closeReleasePostRisk = false;
    }
    
}