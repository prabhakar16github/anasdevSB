import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetailsOnLoad from '@salesforce/apex/OtherProductPricingComponentController.getDetailsOnLoad';
import getCommercialDetails from '@salesforce/apex/OtherProductPricingComponentController.getCommercialDetails';
import saveCommercialChanges from '@salesforce/apex/OtherProductPricingComponentController.saveCommercialChangesForCheckOut';
import publishCommercial from '@salesforce/apex/OtherProductPricingComponentController.publishCommercial';
import deleteCommercial from '@salesforce/apex/OtherProductPricingComponentController.deleteCommercial';

export default class CheckoutExpressComponent extends LightningElement {
    @api recordId = '';
    @api productName = '';
    showSpinner = false;
    showCheckoutExpressCommercials = false;
    showCreateCommercialScreen = false;
    disableAddCommercialButton = false;
    @track listCommercials = [];
    @track commercialObj = {
        message : '',
        recordId : '',
        listDebitModel : [],
        selectedDebitModel : '',
        amountSlab : '0',
        percentage : '',
        flatFee : ''
    }
    disabledSave = false;
    editNotAllowed = false;
    disabledPublishCommercial = true;
    showConfirmationModal = false;
    commercialId = '';
    
    connectedCallback() {
        this.onLoadFunction();      
    }

    onLoadFunction() {
        this.showSpinner = true;
        getDetailsOnLoad({opportunityId:this.recordId,productName :this.productName})
        .then(result => {
            if (result.message.includes('SUCCESS')) {
                this.showSpinner = false;
                if (result.listCommercials.length > 0) {
                    this.listCommercials = result.listCommercials;
                    this.disableAddCommercialButton = true;
                    this.showCheckoutExpressCommercials = true;
                    this.disabledPublishCommercial = result.disablePublishButton;
                }
                else {
                    this.listCommercials = []; 
                    this.disableAddCommercialButton = false;
                    this.cancelCreateNewCommercial();   
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

    //Method to show Toast Message on the UI
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    createNewCommercial(event) {
        this.getCommercialData('');         
    }

    getCommercialData(commercialIdLet) {
        this.showSpinner = true;
        getCommercialDetails({commercialId : commercialIdLet})
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.commercialObj = result;
                    this.showCreateCommercialScreen = true;
                    this.showCheckoutExpressCommercials = false;
                    this.showSpinner = false;
                    if(commercialIdLet != '') {
                        this.editNotAllowed = true;
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

    handleViewDetails(event) {
        let commercialId = event.currentTarget.dataset.id;
        this.getCommercialData(commercialId);   
    }

    handleDelete(event) {
        this.commercialId = event.currentTarget.dataset.id;
        this.showConfirmationModal = true;
        
    }

    cancelCreateNewCommercial(event) {
        this.showCreateCommercialScreen = false;
        this.editNotAllowed = false;
        this.showConfirmationModal = false;
        this.commercialId = '';
        this.commercialObj = {
            message : '',
            recordId : '',
            listDebitModel : [],
            selectedDebitModel : '',
            amountSlab : '0',
            percentage : '',
            flatFee : ''
        }

        if (this.listCommercials.length > 0) {
            this.showCheckoutExpressCommercials = true;
            this.disableAddCommercialButton = true;
        }   
        else {
            this.showCheckoutExpressCommercials = false; 
            this.disableAddCommercialButton = false;   
        } 
    }

    saveCommercial(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateNew');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            if(this.commercialObj.flatFee == '' && this.commercialObj.percentage == '') {
                this.showToast('INFO','info','Either fill Percentage or Flat fee');
                return;
            }
            this.disabledSave = true; 
            this.showSpinner = true;
            saveCommercialChanges({opportunityId : this.recordId,commercialObj : JSON.stringify(this.commercialObj)})
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

    handleChangeDebitModel(event) {
        this.commercialObj.selectedDebitModel = event.detail.value;
    }

    handleChangePercentage(event) {
        this.commercialObj.percentage = event.detail.value;    
    }

    handleChangeFlatFee(event) {
        this.commercialObj.flatFee = event.detail.value;    
    }

    editCommercial(event) {
        this.editNotAllowed = false;
    }

    publishCheckoutExpressCommercial(event) {
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

}