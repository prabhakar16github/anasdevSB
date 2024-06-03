import { LightningElement,api } from 'lwc';
import postHold from "./postHold.html";
import postRelease from "./postRelease.html";


export default class MultiTemplateChild extends LightningElement {
    @api riskrecordid;
    @api templatetype;
    close;


    render() {
        if (this.templatetype == 'Post Hold') {
            this.close = true;
            return postHold;
        }
        
        else if (this.templatetype == 'Post Release') {
            this.close = true;
            return postRelease;
        }    

      }

    handlePostHold(event){
         // stop the form from submitting
         event.preventDefault();  
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
         this.handleClose();
         
    }

    handleRelease(event){
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
 
         handleClose();
    }

    handleClose(event){
        this.close=false;
    }
}