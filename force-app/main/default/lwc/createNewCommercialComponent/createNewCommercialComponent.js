import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPlanDetails from '@salesforce/apex/PricingModuleComponentController.getPlanDetailsOnLoad';
import getSubPlanDetails from '@salesforce/apex/PricingModuleComponentController.getSubPlanDetails';
import getTemplateDetails from '@salesforce/apex/PricingModuleComponentController.getTemplateDetails';
import getPaymentDetails from '@salesforce/apex/PricingModuleComponentController.getPaymentDetails';

export default class CreateNewCommercialComponent extends LightningElement {
    showSpinner = true;
    availablePlanMaster = [];
    listFeeModel = [];
    listTransactionType = [];
    disabledAddPaymentPlan = true;
    selectedPlan = '';
    availableSubPlanMaster = [];
    availableTemplateMaster = [];
    selectedSubPlan = '';
    selectedTemplate = '';
    @track listPaymentData = [];
    mapTDRConvenienceData = new Map();
    @track listFixedPricing = [];
    @track listFallbackCharges = [];
    @track listPlatformFee = [];
    @track listFixedPricing2 = [];
    @track selectedType = '';
    @track selectedInterval = '';
    @track selectedStartDate = '';
    @track selectedEndDate = '';
    @track selectedDebitModel = '';
    
    connectedCallback() {
        //Method to call Apex to fetch data that is required at screen 2    
        getPlanDetails()
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.availablePlanMaster = JSON.parse(result.jsonPlanMaster);
                    this.listFeeModel = result.listFeeModel;
                    this.listTransactionType = result.listTransactionType;
                    this.showSpinner = false;
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

    //this method is called on click of the home button from the screen
    redirectToHomeOpenModalChild(event) {
        let ev = new CustomEvent('childmethod', {});
        this.dispatchEvent(ev);
    }

    //Method to fetch all sub plans for a plan whenever plan is changed from the UI Screen 2
    handlePlanChange(event) {
        this.disabledAddPaymentPlan = true;
        this.selectedPlan = event.detail.value;
        this.showSpinner = true;
        this.availableSubPlanMaster = [];
        this.availableTemplateMaster = [];
        this.selectedSubPlan = '';
        this.selectedTemplate = '';

        getSubPlanDetails({ planId: this.selectedPlan })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.availableSubPlanMaster = JSON.parse(result.jsonPlanMaster);
                    this.showSpinner = false;
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

    //Method to store the value of the sub plan whenever sub plan is changed from the UI Screen 2
    handleSubPlanChange(event) {
        this.disabledAddPaymentPlan = true;
        this.selectedSubPlan = event.detail.value;
        this.showSpinner = true;
        this.selectedTemplate = '';
        this.availableTemplateMaster = [];
        getTemplateDetails({ planId: this.selectedPlan, subPlanId: this.selectedSubPlan })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.availableTemplateMaster = JSON.parse(result.jsonPlanMaster);
                    this.showSpinner = false;
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

    //update the value in the selectedTemplate
    handleTemplateChange(event) {
        this.selectedTemplate = event.detail.value;
        this.disabledAddPaymentPlan = false;
    }

    //this method is called on the click of the Add Payment Plan and Select Plan buttons from the UI
    handleThirdScreen(event) {
        this.showSpinner = true;
        if (event.currentTarget.dataset.id == 'Select payment options') {
            this.selectedTemplate = '';
        }
        getPaymentDetails({ templateId: this.selectedTemplate, commercialId: '' })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.listPaymentData = result.listPaymentData;
                    this.mapTDRConvenienceData = result.mapTDRConvenienceData;
                    if (result.listFixedPricingString.length > 0) {
                        this.listFixedPricing = JSON.parse(result.listFixedPricingString);
                    }

                    if (result.listFallbackChargesString.length > 0) {
                        this.listFallbackCharges = JSON.parse(result.listFallbackChargesString);
                    }

                    if (result.listPlatformFeeString.length > 0) {
                        this.listPlatformFee = JSON.parse(result.listPlatformFeeString);
                    }

                    if (result.listFixedPricing2String.length > 0) {
                        this.listFixedPricing2 = JSON.parse(result.listFixedPricing2String);
                    }

                    this.selectedType = result.selectedType;
                    this.selectedInterval = result.selectedInterval;
                    this.selectedStartDate = result.selectedStartDate;
                    this.selectedEndDate = result.selectedEndDate;
                    this.selectedDebitModel = result.selectedDebitModel;

                    //firing event 
                    const selectEvent = new CustomEvent('selection', {
                        detail : { 
                        listPaymentData : this.listPaymentData,
                        mapTDRConvenienceData : this.mapTDRConvenienceData,
                        listFixedPricing : this.listFixedPricing,
                        listFallbackCharges : this.listFallbackCharges,
                        listFixedPricing2 : this.listFixedPricing2,
                        listPlatformFee : this.listPlatformFee,
                        selectedType : this.selectedType,
                        selectedInterval : this.selectedInterval,
                        selectedStartDate : this.selectedStartDate,
                        selectedEndDate : this.selectedEndDate,
                        selectedDebitModel : this.selectedDebitModel,
                        listFeeModel : this.listFeeModel,
                        listTransactionType : this.listTransactionType,
                        selectedTemplate  : this.selectedTemplate
                        }
                    });
                    this.dispatchEvent(selectEvent);
                }
                else {
                    this.showSpinner = false;
                    this.showToast('ERROR', 'error', result.message);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            });
    }
}