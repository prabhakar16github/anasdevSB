import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetailsOnLoad from '@salesforce/apex/OtherProductPricingComponentController.getDetailsOnLoad';
import getExistingOfferEngineCommercial from '@salesforce/apex/OtherProductPricingComponentController.getExistingOfferEngineCommercial';
import getCommercialDetails from '@salesforce/apex/OtherProductPricingComponentController.getCommercialDetails';
import saveCommercialChangesOfferEngine from '@salesforce/apex/OtherProductPricingComponentController.saveCommercialChangesOfferEngine';
import deleteCommercial from '@salesforce/apex/OtherProductPricingComponentController.deleteCommercial';
import getPublishedInformation from '@salesforce/apex/OtherProductPricingComponentController.getPublishedInformation';
import publishCommercial from '@salesforce/apex/OtherProductPricingComponentController.publishCommercial';
import getPublishedInfoDelete from '@salesforce/apex/OtherProductPricingComponentController.getPublishedInfoDelete';


export default class OfferEngineComponent extends LightningElement {
    @api recordId = '';
    @api productName = '';
    showSpinner = false;
    showOfferEngineCommercials = false;
    showCreateCommercialScreen = false;
    @track listCommercials = [];
    availableRevenueModel = [{ label: 'Offer TDR', value: 'offerTDR' }, { label: 'Offer Activation Fee', value: 'offerActivationFee' }, { label: 'Offer Minimum Billing', value: 'MIN_BILL_OFFER_TDR' }];
    selectedRevenueModel = '';
    showOfferTDR = false;
    showOfferActivationFee = false;
    showOfferMinimumBilling = false;
    @track commercialObj = {
        message : '',
        recordId : '',
        listDebitModel : [],
        selectedDebitModel : '',
        amountSlab : '',
        percentage : '',
        flatFee : '',
        validFrom : '',
        validFromTime : '',
        validTill : '',
        validTillTime : '',
        fromTime : '',
        tillTime : '',
        listDaysOfTheWeek : [],
        selectedDayOfTheWeek : ''
    }

    validFromNotPopulated = true;
    validTillNotPopulated = true;
    commercialId = '';
    editNotAllowed = false;
    disabledSave = false;
    disabledPublishCommercial = true;
    showConfirmationModal = false;
    todaysDate = '';
    
    connectedCallback() {
        this.onLoadFunction();
    }

    onLoadFunction() {
        this.showSpinner = true;
        getDetailsOnLoad({ opportunityId: this.recordId, productName: this.productName })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.showSpinner = false;
                    if (result.listCommercials.length > 0) {
                        this.listCommercials = result.listCommercials;
                        this.showOfferEngineCommercials = true;
                        this.disabledPublishCommercial = result.disablePublishButton;
                    }
                    else {
                        this.listCommercials = [];
                        this.cancelCreateNewCommercial();   
                    }
                    this.todaysDate = result.todaysDate;
                }
                else {
                    this.showSpinner = false;
                    this.showToast('ERROR', 'error', result.message);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })
    }

    //Method to show Toast Message on the UI
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    addCommercialForOfferEngine(event) {
        this.selectedRevenueModel = '';
        this.showCreateCommercialScreen = true;
    }

    cancelCreateNewCommercialOfferEngine(event) {
        this.selectedRevenueModel = '';
        this.showCreateCommercialScreen = false;
        if (this.listCommercials.length > 0) {
            this.showOfferEngineCommercials = true;
        }
        else {
            this.showOfferEngineCommercials = false;
        }
    }

    getSelectedRevenueModel(event) {
        this.selectedRevenueModel = event.detail.value;
    }

    proceedCreateNewCommercialOfferEngine(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateClassOfferEngine');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if (validateData) {
            this.showSpinner = true;
            getExistingOfferEngineCommercial({ opportunityId: this.recordId, productName: this.productName, revenueModel: this.selectedRevenueModel })
            .then(result => {
                if (result) {
                    if(this.selectedRevenueModel == 'offerTDR') {
                        this.showOfferActivationFee = false;
                        this.showOfferMinimumBilling = false;
                        this.showOfferTDR = true;
                        this.getCommercialData('','');
                    }
                    else if(this.selectedRevenueModel == 'offerActivationFee') {
                        this.showOfferMinimumBilling = false;
                        this.showOfferTDR = false;  
                        this.showOfferActivationFee = true; 
                        this.getCommercialData('','');  
                    }
                    else if(this.selectedRevenueModel == 'MIN_BILL_OFFER_TDR') {
                        this.showOfferTDR = false;  
                        this.showOfferActivationFee = false;
                        this.showOfferMinimumBilling = true;  
                        this.getCommercialData('','');
                    }
                    this.showSpinner = false;
                }
                else {
                    this.showSpinner = false;
                    this.showToast('Info', 'info', 'Commercial already exist for the selected revenue model. Kindly update it if any modification is required.');
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })
        }
    }

    getCommercialData(commercialIdLet,revenueModelLet) {
        this.showSpinner = true;
        getCommercialDetails({commercialId : commercialIdLet})
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.commercialObj = result;
                    this.showSpinner = false;
                    if(commercialIdLet != '') {
                        this.editNotAllowed = true;
                        this.showCreateCommercialScreen = true;
                        if(this.commercialObj.validFrom == '') {
                            this.validFromNotPopulated = true;
                            this.commercialObj.validFromTime = '';
                        }
                        else {
                            this.validFromNotPopulated = false;    
                        }
                        if(this.commercialObj.validTill == '') {
                            this.validTillNotPopulated = true;
                            this.commercialObj.validTillTime = '';
                        }
                        else {
                            this.validTillNotPopulated = false;    
                        }

                        if(revenueModelLet=='offerTDR') {
                            this.showOfferTDR = true;
                        }
                        else if(revenueModelLet=='offerActivationFee') {
                            this.showOfferActivationFee = true;
                        }
                        else if((revenueModelLet=='MIN_BILL_OFFER_TDR')) {
                            this.showOfferMinimumBilling = true;
                        }
                    }
                }
                else {
                    this.showSpinner = false;
                    this.showToast('ERROR', 'error', result.message);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            }) 
    }

    handleChangeDebitModel(event) {
        this.commercialObj.selectedDebitModel = event.detail.value;
    }

    handleChangePercentage(event) {
        this.commercialObj.percentage = event.detail.value;  
    }

    handleChangeFlatFee(event) {
        this.commercialObj.flatFee = event.detail.value; 
    }

    handleValidFromChange(event) {
        this.commercialObj.validFrom = event.detail.value;
        if(this.showOfferTDR || this.showOfferMinimumBilling) {
            this.commercialObj.validTill = ''; 
            this.validTillNotPopulated = true;
            this.commercialObj.validTillTime = '';
        }
        if(this.commercialObj.validFrom == null || this.commercialObj.validFrom == '') {
            this.validFromNotPopulated = true;
            this.commercialObj.validFromTime = '';
        }
        else {
            this.validFromNotPopulated = false;    
        }
    }

    handleValidTillChange(event) {
        this.commercialObj.validTill = event.detail.value;
        if(this.showOfferTDR || this.showOfferMinimumBilling) {
            if(this.commercialObj.validTill != '' && this.commercialObj.validFrom != ''  && Date.parse(this.commercialObj.validTill) < Date.parse(this.commercialObj.validFrom)) {
                setTimeout(() => {
                    this.commercialObj.validTill = '';
                    this.validTillNotPopulated = true;
                    this.commercialObj.validTillTime = '';
                    this.showToast('INFO', 'info', 'Valid Till should be greater than Valid From');
                }, "100");
                return;
            }
        }
        if(this.commercialObj.validTill == null || this.commercialObj.validTill == '') {
            this.validTillNotPopulated = true;
            this.commercialObj.validTillTime = '';
        }
        else {
            this.validTillNotPopulated = false;    
        }
    }

    handleFromTimeChange(event) {
        this.commercialObj.fromTime = event.detail.value;
    }

    handleTillTimeChange(event){
        this.commercialObj.tillTime = event.detail.value;
    }

    handleDayChange(event) {
        this.commercialObj.selectedDayOfTheWeek = event.detail.value;  
    }

    handleValidFromTimeChange(event) {
        this.commercialObj.validFromTime = event.detail.value;  
    }

    handleValidTillTimeChange(event) {
        this.commercialObj.validTillTime = event.detail.value;
    }

    saveCommercial(event) {
        let validateData = true;
        let revenueModelLet = event.target.dataset.id;
        let inputFields = this.template.querySelectorAll('.validateNew');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            if(revenueModelLet == 'offerTDR') {
                if(this.commercialObj.flatFee == '' && this.commercialObj.percentage == '') {
                    this.showToast('INFO','info','Either fill Percentage or Flat fee');
                    return;
                }
            }
            this.disabledSave = true; 
            this.showSpinner = true;
            saveCommercialChangesOfferEngine({opportunityId : this.recordId,commercialObj : JSON.stringify(this.commercialObj),revenueModel : revenueModelLet})
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.showCreateCommercialScreen = false;
                    this.disabledSave = false;
                    this.showSpinner = false;
                    this.disabledPublishCommercial = result.disablePublishButton;
                    this.cancelCreateNewCommercial();
                    this.onLoadFunction();
                }
                else {
                    this.disabledSave = false;
                    this.showSpinner = false;
                    this.showToast('ERROR', 'error', result.message);
                }
            })
            .catch(error => {
                this.disabledSave = false;
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            }) 
        }
        


    }

    cancelCreateNewCommercial(event) {
        this.showSpinner = false;
        //showOfferEngineCommercials = false;
        this.showCreateCommercialScreen = false;
        this.selectedRevenueModel = '';
        this.showOfferTDR = false;
        this.showOfferActivationFee = false;
        this.showOfferMinimumBilling = false;
        this.disabledSave = false;
        this.commercialObj = {
            message : '',
            recordId : '',
            listDebitModel : [],
            selectedDebitModel : '',
            amountSlab : '',
            percentage : '',
            flatFee : '',
            validFrom : '',
            validFromTime : '',
            validTill : '',
            validTillTime : '',
            fromTime : '',
            tillTime : '',
            listDaysOfTheWeek : [],
            selectedDayOfTheWeek : ''
        }

        this.validFromNotPopulated = true;
        this.validTillNotPopulated = true;
        this.commercialId = '';
        this.editNotAllowed = false;  
        this.showConfirmationModal = false;
        if (this.listCommercials.length > 0) {
            this.showOfferEngineCommercials = true;
        }
        else {
            this.showOfferEngineCommercials = false;
        }  
    }

    handleViewDetails(event) {
        let commercialId = event.currentTarget.dataset.id;
        let revenueModel = event.currentTarget.dataset.key;
        this.getCommercialData(commercialId,revenueModel);   
    }

    editCommercial(event) {
        let revenueModel = event.target.dataset.id;
        if(revenueModel == 'offerActivationFee') {
            this.showSpinner = true;
            getPublishedInformation({ opportunityId: this.recordId, productName: this.productName, revenueModel: 'offerActivationFee' })
            .then(result => {
                if (result) {
                    this.editNotAllowed = false;
                    this.showSpinner = false;
                }
                else {
                    this.editNotAllowed = true;
                    this.showSpinner = false;
                    this.showToast('Info', 'info', 'Commercial already published. You can not modify it.');
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })
        }
        else {
            this.editNotAllowed = false;
        }
        
    }

    handleDelete(event) {
        this.commercialId = event.currentTarget.dataset.id;
        let revenueModel = event.target.dataset.key;
        if(revenueModel == 'offerActivationFee') {
            this.showSpinner = true;
            getPublishedInfoDelete({commercialId : this.commercialId})
            .then(result => {
                if (result) {
                    this.showSpinner = false;
                    this.showConfirmationModal = true;
                }
                else {
                    this.showSpinner = false;
                    this.showToast('Info', 'info', 'You can not delete published commercial if Current Date >= Valid From');
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })    
        }
        else {
            this.showConfirmationModal = true;
        }
    }

    cancelMessageModalConfirmation(event) {
        this.showConfirmationModal = false;
        this.commercialId = '';
    }

    callDeleteFunction(event) {
        this.showSpinner = true;
        deleteCommercial({commercialId : this.commercialId})
            .then(result => {
                if (result.includes('SUCCESS')) {
                    this.onLoadFunction(); 
                    this.showSpinner = false;
                    this.commercialId = '';
                    this.showConfirmationModal = false;
                    this.showToast('SUCCESS', 'success','Data deletion started successfully');
                }
                else {
                    this.showSpinner = false;
                    this.showToast('ERROR', 'error', result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            }) 
    }

    publishOfferEngineCommercial(event) {
        this.disabledPublishCommercial = true;
        this.showSpinner = true;
        publishCommercial({opportunityId:this.recordId,productName :this.productName})
        .then(result => {
            if (result.message.includes('SUCCESS')) {
                this.showSpinner = false;
                this.disabledPublishCommercial = result.disablePublishButton;
                this.showToast('SUCCESS', 'success','Data started publishing successfully');
            }
            else {
                this.showSpinner = false;
                this.disabledPublishCommercial = false;
                this.showToast('ERROR', 'error', result.message);
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.disabledPublishCommercial = false;
            this.showToast('ERROR', 'error', error);
        })  
    }

    

}