import { LightningElement , api, track,wire } from 'lwc';
import userId from '@salesforce/user/Id';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRiskHoldContent from '@salesforce/apex/UpdateDynamicStatusController.getRiskHoldContent';
import getRiskStatusDetail from '@salesforce/apex/UpdateDynamicStatusController.getRiskStatusDetail';
import mcareCaseUpdate from '@salesforce/apex/UpdateDynamicStatusController.mcareCaseUpdate';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import OPP_FIELD from "@salesforce/schema/MCare_Dashboard_Case__c.Opportunity__c";
import { CloseActionScreenEvent } from 'lightning/actions';

const fields = [OPP_FIELD];

export default class mcareDashboard_MarkRiskHold extends LightningElement {
    @track postRiskId = '';
    @track opportunityId = '';
    @track mcareId ='';
    @track enforcedBy = '';
    @api recordId;
    
    isClose = true;
    @track isLoading = false;
    pickListValueRisk;
    
    @track conValueRisk;
    @track riskHoldReason;
    @track enforcerComment;
   
    
    
    
   
    connectedCallback(){
        setTimeout(() => {

            getRiskStatusDetail({ mcareCaseId: this.recordId})
            .then(result => {
              
                if (result.msg.includes('Success')) {
                    if (result.currStatus == 'On Hold'){
                         this.showToast("ERROR","error", " This Opportunity is already On Post Risk Hold");
                    this.closeQuickAction();
                 
                    }
                    this.postRiskId = result.postRiskId;
                    this.opportunityId = result.oppId;
                    this.mcareId =result.mcareCaseId;
                    this.enforcedBy =result.enforcedBy;

                }
                else {
                    
                    this.showToast('ERROR', 'error', result.message);
                }
         
         })
            .catch(error => {
                
                this.showToast('ERROR', 'error', error);
            })
        }, 5);
    }
    
   



    handlePicklistValChange(event){
        const eventName =  event.target.name;
        var Response = event.target.dataset.id;
        
        if(eventName == 'Post Reason'){
            this.pickListValueRisk = event.target.value;
            
            getRiskHoldContent({ riskHoldReason: this.pickListValueRisk })
            .then((result) => {
                this.conValueRisk = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.conValueRisk = undefined;
            });
            
        } 
        
    }
   
    
    
    changeHandlerPost(event){
        const fieldValue = event.detail.value;
        this.conValueRisk = fieldValue;
        
    }
    
    handleSubmit(event){
        const fields = event.detail.fields;
         
      
        
        fields.Current_Status__c = 'On Hold';     
            
        this.template.querySelector('lightning-record-edit-form').submit(fields);
      
        mcareCaseUpdate({mcareCaseId:this.recordId,reason:fields.Risk_Hold_Reason__c,comment:fields.Comments_By_Enforcer__c,investigation:fields.Investigation_findings__c});
       
      this.closeQuickAction();
      this.showToast("SUCCESS", "success", "This Opportunity is successfully Put On Hold");                
     

      
    }
    
   
    handleSuccess(){
        
        this.isLoading =false;
        window.location.reload();
        // Creates the event with the data.
        console.log('eventName'+this.eventName);
        const selectedEvent = new CustomEvent("status");
        
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

       
        
       
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
       
    }
    
   
}