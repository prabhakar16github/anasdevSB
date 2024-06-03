import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import existingCommercial from '@salesforce/apex/PricingModuleComponentController.existingCommercial';
import getPricingRecordsForCommercial from '@salesforce/apex/PricingModuleComponentController.getPricingRecordsForCommercial';
import getAuditTrailRecordsForCommercial from '@salesforce/apex/PricingModuleComponentController.getAuditTrailRecordsForCommercial';
import getPricingData from '@salesforce/apex/PricingModuleComponentController.getPricingData';

export default class ExistingCommercialsComponent extends LightningElement {
    @api recordId = '';
    showSpinner = true;
    isSuperUser = false;
    planChoiceOptions = [];
    showCommercial = false;
    listExistingCommercial = [];
    commercialId = '';
    showAuditTrail = false;
    letCommercialName = '';
    @track listAuditTrail = [];
    pricingRecord = {};
    showPricingData = false;
    availableInterval = [];
    availableType = [];
    availableDebitModel = [];
    availableIntervalFP = [];
    availableDebitModelFP = [];
    disableCreateNewCommercial = false;
    
    connectedCallback() {
        this.onLoadFunction();    
    }

    onLoadFunction(event) {
        existingCommercial({ recordId: this.recordId })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.isSuperUser = result.isSuperUser;
                    if (this.isSuperUser) {
                        this.planChoiceOptions = [{ label: 'Update Existing Template', value: 'option1' }, { label: 'Choose existing Plan, existing Sub Plan and create new Template', value: 'option2' }, /*{ label: 'Create new Plan, new Sub Plan and update existing Template', value: 'option3' }*/{ label: 'Choose existing Plan, Create new Sub Plan and Create new Template', value: 'option5' }, { label: 'Create new Plan, new Sub Plan and new Template', value: 'option4' }];
                    }
                    else {
                        this.planChoiceOptions = [{ label: 'Update Existing Template', value: 'option1' }, { label: 'Create New Template', value: 'option2' }];
                    }
                    if (result.listExistingCommercial.length > 0) {
                        this.listExistingCommercial = result.listExistingCommercial;
                        this.showCommercial = true;
                        this.disableCreateNewCommercial = true;
                    }

                    this.availableInterval = result.listPlatformFeeInterval;
                    this.availableType = result.listPlatformFeeType;
                    this.availableDebitModel = result.listPlatformFeeDebitModel;
                    this.availableIntervalFP = result.listFixedPricingFeeInterval;
                    this.availableDebitModelFP = result.listFixedFeeDebitModel;

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

    getPlanDetailsChild(event) {
        //fire an event to notify the parent
        const newEvent = new CustomEvent('selection', {
            detail: {
                isSuperUser: this.isSuperUser,
                planChoiceOptions: this.planChoiceOptions,
                listExistingCommercial: this.listExistingCommercial,
                showCommercial: this.showCommercial,
                availableInterval : this.availableInterval,
                availableType : this.availableType,
                availableDebitModel : this.availableDebitModel,
                availableIntervalFP : this.availableIntervalFP,
                availableDebitModelFP : this.availableDebitModelFP
            }
        });
        this.dispatchEvent(newEvent);
    }

    //this method is called on the click of the Commercial Name to get the pricing records from Screen 1
    getPlanRecordsForCommercial(event) {
        this.showSpinner = true;
        this.commercialId = event.currentTarget.dataset.id;
        let commercialNameTemp = event.currentTarget.dataset.key;
        this.onLoadFunction();
        getPricingRecordsForCommercial({commercialId : event.currentTarget.dataset.id,commercialName : event.currentTarget.dataset.key})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.showSpinner = false;
                let listFixedPricing = [];
                let listFallbackCharges = [];
                let listPlatformFee = [];
                let listFixedPricing2 = [];

                if(result.listFixedPricingString.length > 0) {
                    listFixedPricing =  JSON.parse(result.listFixedPricingString); 
                }

                if(result.listFallbackChargesString.length > 0) {
                    listFallbackCharges =  JSON.parse(result.listFallbackChargesString); 
                }

                if(result.listPlatformFeeString.length > 0) {
                    listPlatformFee =  JSON.parse(result.listPlatformFeeString); 
                }

                if(result.listFixedPricing2String.length > 0) {
                    listFixedPricing2 =  JSON.parse(result.listFixedPricing2String); 
                }
                //fire an event to notify the parent
                const newEvent = new CustomEvent('selectionnew', {
                detail: {
                    selectedListPaymentData: JSON.parse(result.selectedListPaymentData),
                    showBelowRackRateMessage: result.showBelowRackRateMessage,
                    showBelowRackRateRecords: result.showBelowRackRateRecords,
                    belowRackRateMessage: result.belowRackRateMessage,
                    disabledBHButton : result.disabledBHButton,
                    disabledCommercialName : true,
                    commercialName : commercialNameTemp,
                    listFixedPricing : listFixedPricing,
                    listFixedPricing2 : listFixedPricing2,
                    listFallbackCharges : listFallbackCharges,
                    selectedType : result.selectedType,
                    selectedInterval : result.selectedInterval,
                    selectedStartDate : result.selectedStartDate,
                    selectedEndDate : result.selectedEndDate,
                    selectedDebitModel : result.selectedDebitModel,
                    listPlatformFee : listPlatformFee,
                    status : result.status,
                    respectiveScreen : result.respectiveScreen,
                    commercialId : this.commercialId,
                    isSuperUser: this.isSuperUser,
                    planChoiceOptions: this.planChoiceOptions,
                    listExistingCommercial: this.listExistingCommercial,
                    showCommercial: this.showCommercial,
                    availableInterval : this.availableInterval,
                    availableType : this.availableType,
                    availableDebitModel : this.availableDebitModel,
                    availableIntervalFP : this.availableIntervalFP,
                    availableDebitModelFP : this.availableDebitModelFP
                    }
                });
                this.dispatchEvent(newEvent);
            }
            else {
                this.showSpinner = false;
                this.commercialId = '';
                this.showToast('ERROR','error',result.message);
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.commercialId = '';
            this.showToast('ERROR','error',error);
        })
    }

    //this method is called on the click of the Edit Button of the existing commercial row
    handleEditCommercial(event) {
        //fire an event to notify the parent
        
        const newEvent = new CustomEvent('selectionedit', {
            detail: {
                commercialId : event.currentTarget.dataset.id,
                commercialName : event.currentTarget.dataset.key,
                disabledCommercialName : true,
                availableInterval : this.availableInterval,
                availableType : this.availableType,
                availableDebitModel : this.availableDebitModel,
                availableIntervalFP : this.availableIntervalFP,
                availableDebitModelFP : this.availableDebitModelFP,
                planChoiceOptions : this.planChoiceOptions
                }
            });
            this.dispatchEvent(newEvent);
    }

    //this method is called on the click of the Audit Trail Button of the existing commercial row
    handleAuditTrailCommercial(event) {
        this.showAuditTrail = false;
        this.listAuditTrail = [];
        this.letCommercialName = '';
        let letcommercialId = event.currentTarget.dataset.id;
        this.letCommercialName = event.currentTarget.dataset.key; 
        this.showSpinner = true;

        getAuditTrailRecordsForCommercial({ commercialId: letcommercialId })
            .then(result => {
                this.listAuditTrail =  result;  
                this.showAuditTrail = true;
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })
    }

    closeModalAuditTrail(event) {
        this.showAuditTrail = false;
    }

    getPricingRecordId(event) {
        let letPricingId = event.currentTarget.dataset.id;
        this.pricingRecord = {}; 
        this.showSpinner = true;
        this.showPricingData = false;
        getPricingData({pricingId: letPricingId})
                .then(result => {
                    this.pricingRecord = result; 
                    this.showSpinner = false;
                    this.showPricingData = true;
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.showToast('ERROR', 'error', error);
                })
    }

    closeModalPricing(event) {
        this.showPricingData = false;
    }

    
}