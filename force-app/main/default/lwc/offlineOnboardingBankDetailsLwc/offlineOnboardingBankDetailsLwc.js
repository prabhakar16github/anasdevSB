import { LightningElement,wire, track,api } from 'lwc';
import fetchPicklistValue from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchPicklistValue';
import saveBankDetailsData from '@salesforce/apex/OfflineOnboardingForm_Controller.saveBankDetailsData';
export default class OfflineOnboardingBankDetailsLwc extends LightningElement {
    @api leadId = '';
    @api bankAccountObj = {};
    @api getIdFromParent;
    @api toggleBankDetailsSectionClass;
    @track isShowViewButtonForBankDetailsSection = false;
    @api bankDetailsViewMode;
    @track isShowErrorMsgForBankSection = false;
    @track errorMsg = '';
    @track isShowSpinner = false;
    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Bank_Account_Detail__c'},
    picklistFieldApi: 'Account_Type__c'}) accountTypeValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Bank_Account_Detail__c'},
    picklistFieldApi: 'Bank_Name__c'}) bankNameValue;

    handleChangeBankAccount(event){
        if(event.target.type ==='checkbox'){
            this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.checked;
        }else{
            this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.value;
        }
    }

    connectedCallback(){
        console.log('toggleBankDetailSectionClass>>>2'+this.toggleBankDetailsSectionClass);
        this.bankAccountObj = JSON.parse(JSON.stringify(this.bankAccountObj));
        if(this.getIdFromParent && Object.keys(this.bankAccountObj).length !== 0){
            console.log('INSIDE IF+++++++++++++++++++');
            this.toggleBankDetailsSectionClass = false;
        }
    }
    
    handale_SaveBankDetails(){
        console.log('handale_SaveBankDetails>>>>');
        let leadId = '';
        if(this.getIdFromParent){
            leadId = this.getIdFromParent;
        }else{
            leadId = this.leadId;
        }
        this.bankAccountObj.Lead__c= leadId;
        //this.bankAccountObj.Active__c= true;
        var bankAccount_Obj = JSON.stringify(this.bankAccountObj);
        console.log('bankAccountObj'+bankAccount_Obj);
        if(this.validate_BankAccount_Fields()){
            this.isShowSpinner = true;
            saveBankDetailsData({bankAccount_Obj})
            .then(result => {
                console.log('result'+result);
                if(!result.errorMsg){
                    this.bankDetailsViewMode = true;
                    this.isShowErrorMsgForBankSection = false;
                    this.toggleBankDetailsSectionClass = false;
                    this.isShowSpinner = false;
                }else{
                    if(result.errorMsg){
                        this.isShowSpinner = false;
                        var tempError = result.errorMsg.split("first error:");
                        this.errorMsg = tempError[1];
                    }
                }
                
                
            })
            .catch(error =>{
                this.isShowSpinner = false;
                console.log('error::'+error);
            });
        }else{
            this.isShowErrorMsgForBankSection = true;
        }
        //console.log('isShowErrorMsg::'+this.isShowErrorMsg);
    }
    validate_BankAccount_Fields(){
        console.log(' validate_BankAccount_Fields');
        var isAllFieldFilled = false;
        
        if(this.bankAccountObj.Account_Number__c && this.bankAccountObj.Account_Holder_Name__c && this.bankAccountObj.Account_Type__c && this.bankAccountObj.Bank_Name__c && this.bankAccountObj.Branch__c && this.bankAccountObj.IFSC_Code__c && this.bankAccountObj.Branch_Address__c){
                isAllFieldFilled = true;
        }
        console.log(' validate_Fields isAllFieldFilled'+isAllFieldFilled);
        return isAllFieldFilled;
    }
    toggleBankSection(){
        console.log('toggleBankDetailSectionClass>>>'+this.toggleBankDetailsSectionClass);
        if(this.toggleBankDetailsSectionClass == true){
            this.toggleBankDetailsSectionClass = false;
        }else if(this.toggleBankDetailsSectionClass == false){
            this.toggleBankDetailsSectionClass = true;
        }
    }
    editBankDetailsSection(){
        this.isShowViewButtonForBankDetailsSection = true;
        this.isShowErrorMsgForBankSection = false;
        this.bankDetailsViewMode = false;
    }
    openViewModeForBankDetails(){
        this.isShowViewButtonForBankDetailsSection = false;
        this.bankDetailsViewMode = true;
    }
    updateProgrssIndicator(){
        var banObj = this.bankAccountObj;
        if(Object.keys(banObj).length > 0){
            this.currentStep = '7';
        }
        const selectCurrentStepEvent = new CustomEvent('mycurrentstepevent', {
            detail: this.currentStep
        });
        this.dispatchEvent(selectCurrentStepEvent);
    }
}