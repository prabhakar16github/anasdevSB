import { LightningElement , api, track } from 'lwc';
import userId from '@salesforce/user/Id';
import getRiskHoldContentData from '@salesforce/apex/UpdateDynamicStatusController.getRiskHoldContent';
import getPreHoldContent from '@salesforce/apex/UpdateDynamicStatusController.getPreRiskHoldEmailContent';
import Name from '@salesforce/schema/Account.Name';
export default class RiskRecordTypeNew extends LightningElement {
    @api postriskidchild;
    @api obriskidchild; 
    @api preriskidchild;

    @api templatetype; 
    currentDate;
    isClose = true;
    @track isLoading = false;
    pickListValueRisk;
    pickListValuePre;
    @api conValueRisk;
    @track conValuePre; 
    @api error;
    @api opprecordid;// added by rohit
    @api riskmanagementmodalclose;
    get postHold(){ return this.templatetype == 'Post Hold' ? true : false; }

    get postRelease(){ return this.templatetype == 'Post Release' ? true : false;}

    get obHold(){return this.templatetype == 'OB Hold' ? true : false;}

    get obRelease(){return this.templatetype == 'OB Release' ? true : false;}

    get preHold(){return this.templatetype == 'Pre Hold' ? true : false;}

    get preRelease(){return this.templatetype == 'Pre Release' ? true : false;}

    handlePicklistValChange(event){
        const eventName =  event.target.name;
        console.log('eventName::::::'+eventName);

        if(eventName == 'Post Reason' || eventName == 'OB Reason'){
            this.pickListValueRisk = event.target.value;
            console.log('this.pickListValueRisk:39::::::'+this.pickListValueRisk);
            getRiskHoldContentData({ riskHoldReason: this.pickListValueRisk })
        .then((result) => {
            this.conValueRisk = result;
            console.log('this.conValueRisk::::::'+this.conValueRisk);
        })
        .catch((error) => {
            this.error = error;
            this.conValueRisk = undefined;
        });

        } else if(eventName == 'Pre Hold') {
            console.log('this.pickListValueRisk::::512:::'+this.pickListValueRisk);
            this.pickListValuePre = event.target.value;
            getPreHoldContent({ preRiskHoldReason: this.pickListValuePre })
            .then((result) => {
                
                this.conValuePre = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.conValuePre = undefined;
            });

        } 
    }
    handleClose(){
        this.templatetype = null;
         
    }
    @api 
    handleSave(event){
        console.log('line no:::77::'+this.riskmanagementmodalclose);
        console.log(this.template);
        const btn = this.template.querySelector( ".hidden" );
        if( btn ){ 
            btn.click();
        }
    }
    
    changeHandlerOB(event){
        const fieldValue = event.detail.value;
        this.conValueRisk = fieldValue;
    }
    changeHandlerPost(event){
        const fieldValue = event.detail.value;
        this.conValueRisk = fieldValue;
    }
    changeHandlerPre(event){
        const fieldValue = event.detail.value;
        this.conValuePre = fieldValue;
    }

  handleSubmit(event){
        console.log('90');
         // stop the form from submitting
         //event.preventDefault(); // commented by rohit
         //get all the fields
         const fields = event.detail.fields;
         //get Current Date and Time
        // var dateVar = new Date();
         //Current Date 
         //this.currentDate = new Date(dateVar.getTime() + dateVar.getTimezoneOffset()*60000).toISOString();

        const eventName =  event.target.name;
        if(eventName == 'Post Hold'  || eventName == 'OB Hold' || eventName == 'Pre Hold'){
             //Map remainig fields to values here 
        fields.Current_Status__c = 'On Hold';     
        //fields.Enforced_By__c = userId;
       // fields.Enforced_Date__c = this.currentDate;
        

            //Alert Message for comments
       /* if( !fields.Comments_By_Enforcer__c){
            //this.alertMessage = 'your skipped the comment field';
            alert('skipped the comment field');
            return;
        }*/
        if(eventName == 'Post Hold'  || eventName == 'OB Hold'){
            fields.Risk_Hold_Reason_Email_Content__c = this.conValueRisk;
            }
            if(eventName == 'Pre Hold'){
                fields.Risk_Hold_Reason_Email_Content__c = this.conValuePre;
            }
        this.templatetype = null;
        }
        
        if(eventName == 'Post Release' || eventName == 'OB Release' || eventName == 'Pre Release'){
            
            fields.Current_Status__c = 'Not On Hold';
            //fields.Released_By__c = userId;
            //fields.Release_Date__c = this.currentDate;
            fields.Risk_Hold_Reason__c = null;
            fields.Risk_Hold_Reason_Email_Content__c = null; 
            if(!fields.Release_Comment__c){
                alert('skipped the comment field');
                return;
            }
            
            this.templatetype = null;
        }

         //submit the form
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        //this.isLoading =true; // commentted by rohit need to uncomment
        this.riskmanagementmodalclose = false;// added by rohit
        console.log('this.isClose:::::::'+this.isClose);
        this.isClose = false;// added by rohit
    }
    
    handleSuccess(){
        this.isLoading =false;
        // Creates the event with the data.
        console.log('eventName'+this.eventName);
    const selectedEvent = new CustomEvent("status");
  
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
}