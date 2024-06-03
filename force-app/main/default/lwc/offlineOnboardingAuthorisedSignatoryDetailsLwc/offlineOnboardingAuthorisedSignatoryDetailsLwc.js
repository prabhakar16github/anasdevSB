import { LightningElement,track,api } from 'lwc';
import saveContactDetailsData from '@salesforce/apex/OfflineOnboardingForm_Controller.saveContactDetailsData';
export default class OfflineOnboardingAuthorisedSignatoryDetailsLwc extends LightningElement {
    @api leadId;
    @api getIdFromParent;
    @api isShowBankDetailsSection = false;
    @api toggleAuthSignatoryDetailsSectionClass;
    @track isShowSpinner = false;     
    @track isShowErrorMsgForAuthorisedSignatorySection = false;
    @track isShowViewButtonForAuthorisedSignatorySection = false;
    @api contactDetailsViewMode = false;
    @api contactObjTwo = {};
    @api contactObjOne = {};
    @track errorMsg = '';
    connectedCallback(){
        this.contactObjOne = JSON.parse(JSON.stringify(this.contactObjOne));
        this.contactObjTwo = JSON.parse(JSON.stringify(this.contactObjTwo));
        if(this.getIdFromParent && this.contactObjOne && this.contactObjTwo ){
            this.toggleAuthSignatoryDetailsSectionClass = false;
        }
    }

    handleChangeContactField(event) {
        try{
            console.log('handleChangeContactField');
            if(event.target.type ==='checkbox'){
                this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.checked;
            }else{
                this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.value;
            }
            
        }catch(error){
            console.log('error::'+error);
        }
    }

    /*To Save the contact record*/
    handale_SaveContact(event){
        let leadId = '';
        if(this.getIdFromParent){
            leadId = this.getIdFromParent;
        }else{
            leadId = this.leadId;
        }
        this.contactObjOne.Lead__c = leadId;
        this.contactObjTwo.Lead__c = leadId;
        var contactObj1 = JSON.stringify(this.contactObjOne);
        var contactObj2 = JSON.stringify(this.contactObjTwo);
        if(this.validate_Contact_Fields()){
            this.isShowSpinner = true;
            saveContactDetailsData({contactObj1,contactObj2})
            .then(result => {
                console.log('result'+JSON.stringify(result));
                if(!result.errorMsg){
                    this.errorMsg = '';
                    this.contactObjOne = result.contactObj1;
                    this.contactObjTwo = result.contactObj2;
                    console.log('contactObjOne'+JSON.stringify(this.contactObjOne));
                    console.log('contactObjTwo'+JSON.stringify(this.contactObjTwo));
                    this.contactDetailsViewMode = true;
                    this.isShowErrorMsgForAuthorisedSignatorySection = false;
                    this.toggleAuthSignatoryDetailsSectionClass = false;
                    this.isShowBankDetailsSection = true;
                    //event.preventDefault();
                    const selectEvent = new CustomEvent('mycustomevent', {
                        detail: this.isShowBankDetailsSection
                    });
                    this.dispatchEvent(selectEvent);
                    this.updateProgrssIndicator();
                    this.isShowSpinner = false;
                    
                }else{
                    if(result.errorMsg){
                        var tempError = result.errorMsg.split("first error:");
                        this.errorMsg = tempError[1];
                        this.isShowSpinner = false;
                        this.updateProgrssIndicator();
                    }
                }
                
            })
            .catch(error =>{
                this.isShowSpinner = false;
                console.log('error::'+error);
            });
        }else{
            this.isShowErrorMsgForAuthorisedSignatorySection = true;
        }
    }

    // validate Authrize signatory fields.
    validate_Contact_Fields(){
        try{
            console.log(' validate_Contact_Fields');
            var isAllFieldFilled = false;
            console.log(' validate_Contact_Fields contactObj1'+JSON.stringify(this.contactObjOne));
            console.log(' validate_Contact_Fields contactObj2'+JSON.stringify(this.contactObjTwo));
            if(this.contactObjOne.LastName && this.contactObjOne.Email && this.contactObjOne.MobilePhone ){
                    isAllFieldFilled = true;
            }
            console.log(' validate_Contact_Fields isAllFieldFilled'+isAllFieldFilled);
            return isAllFieldFilled;
        }catch(e){
            console.log(e);
            return false;
        }
        
    }

    selectHandler(event) {
        console.log('selectHandler::');
        // Prevents the anchor element from navigating to a URL.
        //event.preventDefault();

        // Creates the event with the contact ID data.
        

        // Dispatches the event.
        
    }

    editContactDetailsSection(){
        this.isShowViewButtonForAuthorisedSignatorySection = true;
        this.isShowErrorMsgForAuthorisedSignatorySection = false;
        this.contactDetailsViewMode = false;
    }
    openViewModeForContactSection(){
        this.isShowViewButtonForAuthorisedSignatorySection = false;
        this.contactDetailsViewMode = true;
    }
    toggleAuthSignatorySection(){
        console.log('toggleAuthSignatoryDetailsSectionClass>>>'+this.toggleAuthSignatoryDetailsSectionClass);
        if(this.toggleAuthSignatoryDetailsSectionClass == true){
            this.toggleAuthSignatoryDetailsSectionClass = false;
        }else if(this.toggleAuthSignatoryDetailsSectionClass == false){
            this.toggleAuthSignatoryDetailsSectionClass = true;
        }
    }

    updateProgrssIndicator(){
        var contactObjOne = this.contactObjOne;
        var contactObjTwo = this.contactObjTwo;
        if(Object.keys(contactObjOne).length > 0 && Object.keys(contactObjTwo).length > 0){
            this.currentStep = '6';
        }
        const selectCurrentStepEvent = new CustomEvent('mycurrentstepevent', {
            detail: this.currentStep
        });
        this.dispatchEvent(selectCurrentStepEvent);
        console.log('currentStep'+this.currentStep);
    }

}