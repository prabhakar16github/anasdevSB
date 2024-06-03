import { LightningElement,api,wire } from 'lwc';
import opportunityRecords from '@salesforce/apex/RiskManagementStatusController.websitePages';
import saveopportunityRecords from '@salesforce/apex/RiskManagementStatusController.saveOppRecords';
import getMccCodeMetaData from '@salesforce/apex/RiskManagementStatusController.getMccCodeMetaData';
import currentUserId from '@salesforce/apex/RiskManagementStatusController.currentUserId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import { CurrentPageReference } from 'lightning/navigation'; 
// Import the User object schema and field
export default class LineOfBusinessVerificationManagement extends LightningElement {
    @wire(CurrentPageReference) pageRef; // Define a variable to store the logged-in user's ID loggedInUserId; 
    @api recordId;
    websiteRecords;
    BaseMerchantId;
    mccCodeName;
    reasondiabled=false;
    lobStatusValue='';// added by rohit
    lobRejectionValueDisabled =false;// added by rohit
    requiredTrueInCaseOfRejection = false;// added by rohit
    recordsToSave = {};
    reasonValueCheck='';// by rohit
    lobReasonValue; // by rohit
    assignLobRejectionValue; // by rohit
    baseMerchantIdValue;// added by rohit
    lobRejectionValue;
    loggedInUserId;
    connectedCallback(){
        currentUserId()
            .then((result) => {
            this.loggedInUserId = result.Id;
            console.log('this.loggedInUserId ::::::'+this.loggedInUserId );
        })
        .catch((error) => {
            this.error = error;
        });

        opportunityRecords({oppId:this.recordId}).then(response=>{
            console.log('response',response);
            console.log((response[0].LOB_Status__c !=null));
            this.lobRejectionValue = response[0].LOB_Rejection_Reason__c ;
            if(response[0].LOB_Status_PreRisk__c !='LOB Rejected' || response[0].LOB_Status_PreRisk__c !='LOB Error'){// added by rohit // Previously it was Rejected
                this.lobRejectionValueDisabled=true;
                this.lobReasonValue='';
                this.assignLobRejectionValue = response[0].LOB_Rejection_Reason__c;
                this.requiredTrueInCaseOfRejection =true;
            }
            if(response[0].LOB_Status_PreRisk__c =='LOB Rejected' || response[0].LOB_Status_PreRisk__c =='LOB Error'){// added by rohit // Previously it was Rejected
                this.lobRejectionValueDisabled=false;
                this.lobReasonValue = response[0].LOB_Rejection_Reason__c;
                this.requiredTrueInCaseOfRejection =true
            }
            if(response[0].LOB_Rejection_Reason__c !=null){// added by rohit
                this.requiredTrueInCaseOfRejection =true
            }
            if(response[0].LOB_Rejection_Reason__c ==null && response[0].LOB_Status_PreRisk__c !=null){// added by rohit
                this.requiredTrueInCaseOfRejection =false;
            }
            if(response[0].LOB_Rejection_Reason__c ==null && response[0].LOB_Status_PreRisk__c ==null){// added by rohit
                this.requiredTrueInCaseOfRejection =true;
            }
            this.mccCodeName = response[0].MCC_Code__c;
            this.BaseMerchantId = response[0].Base_Merchant_Id__c;
        })
        
  
    }
    UpdatelobRejectionValueDisabled(){// added by rohit 
        if(this.lobStatusValue =='LOB Rejected'  || this.lobStatusValue =='LOB Error'){
            this.lobRejectionValueDisabled  = false;
            this.lobReasonValue = this.assignLobRejectionValue ;
            if(this.lobRejectionValue  ==null){// added by rohit
                this.requiredTrueInCaseOfRejection =false;
            }
            else{
                this.requiredTrueInCaseOfRejection = true;
            }
        }
        console.log('this.lobRejectionValueDisabled:::::'+this.lobRejectionValueDisabled);
        if(this.lobStatusValue =='LOB Approved'){
            this.lobRejectionValueDisabled  = true;
            this.requiredTrueInCaseOfRejection =true;
            this.lobReasonValue = '';
            console.log('this.requiredTrueInCaseOfRejection:::lineno52::'+this.requiredTrueInCaseOfRejection);
        }
       
    }
    handleLobStatus(event){// added by rohit
        this.lobStatusValue = event.target.value;
        this.UpdatelobRejectionValueDisabled();
        console.log('this.lobStatusValue ::::::::'+ this.lobStatusValue );
    }
    handleSubmit(event){
        console.log('records fields ',event.detail.fields);
    }
    lobReasonChange(event){// added by rohit
        this.reasonValueCheck = event.target.value;
        console.log('this.reasonValueCheck ::::'+this.reasonValueCheck );
        if(this.reasonValueCheck){
            this.requiredTrueInCaseOfRejection =true
        }
        else if(this.lobStatusValue=='LOB Approved' && this.reasonValueCheck==''){
            this.requiredTrueInCaseOfRejection =true;
        }
        else{
            this.requiredTrueInCaseOfRejection =false
        }
    }
    handleChange(event){
        this.recordsToSave[event.target.dataset.name] = event.target.value;
        const baseMerchantFieldName = event.target.value;
        console.log('baseMerchantFieldName:::::'+baseMerchantFieldName);
        getMccCodeMetaData({mccCode :event.target.value, partner:null})
        .then((result) => {
            this.baseMerchantIdValue = result;
            this.recordsToSave.Base_Merchant_Id__c= this.baseMerchantIdValue;
          })
          .catch((error) => {
            this.error = error;
          });

    }
    @api
    handleSave(event){
        
        this.recordsToSave.Id = this.recordId;
        const fields = this.template.querySelectorAll('.recordFields');
        console.log('fields ',fields);
        fields.forEach(element => {
            this.recordsToSave[element.fieldName] = element.value;
        });
        let arrRecords = [this.recordsToSave];
        console.log('JSON.stringify(arrRecords)::::'+JSON.stringify(arrRecords));
        console.log('this.requiredTrueInCaseOfRejection::::lineno ::86::'+this.requiredTrueInCaseOfRejection);
        if(!this.requiredTrueInCaseOfRejection){// this if  added by rohit
           // event.preventDefault();
            const errorMsg = 'LOB Rejection Reason is required when LOB status set to Rejected';
            const errorEvent = new ShowToastEvent({
            title:'Error',
            message:errorMsg,
            variant : 'error'
        });
        this.dispatchEvent(errorEvent);
        }
        else{// this else added by rohit
            saveopportunityRecords({records:JSON.stringify(arrRecords)}).then(res=>{
                console.log('res ',res);
                let obj = {}
                obj.BusinessEntity = res[0].BusinessEntityName__c;
                obj.BusinessCategory = res[0].Business_Category__c;
                obj.BusinessSubCatagory = res[0].SubCategory__c;
                obj.website = res[0].Website__c;
                console.log('obj::::::: ',obj);
                const evt = CustomEvent('save',{detail:{value:obj}});
                this.dispatchEvent(evt);
            })
            const event = new ShowToastEvent({ // added by rohit
                message: 'Line Of Business Verification has been saved',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event)
        }
       
        // console.log('this.recordTosave ',this.recordsToSave);
    }



}