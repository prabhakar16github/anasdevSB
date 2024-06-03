import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import opportunityRecords from '@salesforce/apex/AwsConsumerAPI_CTRL.parseJSON';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RepublishPayload extends LightningElement {
    @api recordId;
    recordData;

     // Wire service to get record data
   @wire(getRecord, { recordId: '$recordId', fields: ['Payload_Log__c.Payload__c'] })
   wiredRecord({ error, data }) {
       if (data) {
           this.recordData = data;
           // Handle record data as needed
           console.log('Record Data:', this.recordData);
           this.sendDataToAws();
       } else if (error) {
           // Handle error
           console.error('Error loading record data', error);
       }
   }
   sendDataToAws() {
       // Extract the 'Name' field value from the record data
       const payloadValue = this.recordData.fields.Payload__c.value;
       //this.dispatchEvent(new CloseActionScreenEvent());
       // Call Apex method with the field value
       opportunityRecords({ jsonRoot:payloadValue})
           .then(result => {
               // Handle Apex response
               console.log('Apex Response:', result);
               const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Payload Published',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CloseActionScreenEvent());
           })
           .catch(error => {
               // Handle errors
               const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Some unexpected error',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
               console.error('Error calling Apex method', error);
           });
   }
}