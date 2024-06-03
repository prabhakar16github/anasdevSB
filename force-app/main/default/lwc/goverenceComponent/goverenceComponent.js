import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBelowRackRatesRecords from '@salesforce/apex/PricingModuleComponentController.getBelowRackRatesRecords';
import getSendToBHRecords from '@salesforce/apex/PricingModuleComponentController.getSendToBHRecords';
import getCommercialInformationBeforeValidatePricing from '@salesforce/apex/PricingModuleComponentController.getCommercialInformationBeforeValidatePricing';
import sendToBHEmail from '@salesforce/apex/PricingModuleComponentController.sendToBHEmail';
import updateBelowRackRatesRecords from '@salesforce/apex/PricingModuleComponentController.updateBelowRackRatesRecords';


export default class GoverenceComponent extends LightningElement {
    showSpinner = true;
    @api disabledBHButton;
    disabledUpdatePricingButton = false;
    disabledPublishPricingButton = false;
    @api belowRackRateMessage = '';
    @api selectedListPaymentData = [];
    @api commercialId = '';
    showBelowRackRateRecords = false;
    @track belowRackRatesRecords = [];
    belowRackRatesIds = [];
    openSendToBH = false;
    @track listBHAddress = [];
    bhAddress = '';
    subject = '';
    body = '';
    disabledSendRequestButton = false;
    @api listFixedPricing = [];
    openGovernanceModal = false;
    @api showBelowRackRateMessage = false;
    @api disabledCommercialName = false;
    @api listFixedPricingTemporary = [];

    @track SelectedPaymentOptionObject = {
        paymentModeId : '',
        paymentModeName : '',
        selectedPaymentOptionsList : [],
        styleClass : 'background:#F2F8FF'
    }

    @track SelectedPaymentOptionIndividualListObject = {
        key : '',
        selectedPaymentIndividualList : [],
        restrictTransactionTypeAndFeeModel : false
    }

    @track selectetPaymentIndividualObject = {
        key : '',
        selectedPaymentOptionName : '',
        selectedPaymentOptionId : '',
        selectedSpecification : '',
        selectedPaymentGatewayName : '',
        selectedOnusOffus : '',
        isChecked : false,
        listFeeModel : [],
        selectedFeeModel : '',
        listTransactionType : [],
        selectedTransactionType : '',
        showCheckbox : true,
        showTDR : true,
        showConvenience : false,
        tdrAmount : '0',
        tdrFee : '',
        tdrPercentage : '',
        convenienceAmount : '0',
        convenienceFee : '',
        conveniencePercentage : '',
        backgroundColor : 'background-color:white;',
        pricingId : '',
        restrictFlatFeeAndPercentageToBeEdited : false,
        restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited : false,
        ruleStatus : 'D'
    }

    connectedCallback() {
        this.listFixedPricing = JSON.parse(JSON.stringify(this.listFixedPricingTemporary));
        this.showSpinner = false;
    }

    //this method is used to open modal for update
    updatePricing(event) {
        this.disabledUpdatePricingButton = true;
        this.showSpinner = true;
        this.showBelowRackRateRecords = false;
        getBelowRackRatesRecords({commercialId : this.commercialId})
        .then(result =>{
            if(result.message.includes('SUCCESS')) {
                if(result.listBelowRackRateRecords.length > 0) {
                    this.showBelowRackRateRecords = true;
                }
                this.belowRackRatesRecords = result.listBelowRackRateRecords;
                this.belowRackRatesIds = result.listPricingIds;
                this.openGovernanceModal = true;
                this.disabledUpdatePricingButton = false;
                this.showSpinner = false;
            }
            else {
                this.showSpinner = false;
                this.disabledUpdatePricingButton = false;
                this.showToast('ERROR','error',result.message);    
            }
        }) 
        .catch(error => {
            this.showSpinner = false;
            this.disabledUpdatePricingButton = false;
            this.showToast('ERROR','error',error);
        })

    }

    //this method is called on the click of the Send to BH button
    sendToBH(event) {
        this.showSpinner = true;
        this.belowRackRatesRecords = [];
        this.belowRackRatesIds = [];
        this.showBelowRackRateRecords = false;
        getSendToBHRecords({commercialId : this.commercialId})
        .then(result =>{
            if(result.message.includes('SUCCESS')) {
                if(result.listBelowRackRatesRecords.length > 0) {
                    this.showBelowRackRateRecords = true;
                }
                this.belowRackRatesRecords = result.listBelowRackRatesRecords;
                this.belowRackRatesIds = result.listPricingIds;
                this.listBHAddress = result.listBHAddress;
                //this.bhAddress = result.bhAddress;
                this.subject = result.subject;
                this.body = result.body;
                this.openSendToBH = true;
                this.showSpinner = false;
            }
            else {
                this.showSpinner = false;
                this.showToast('ERROR','error',result.message);    
            }
        }) 
        .catch(error => {
            this.showSpinner = false;
            this.showToast('ERROR','error',error[0]);
        })
    }

    //this method is called on click of Publish Pricing from Screen 5
    @api publishPricing(event) {
        this.showSpinner = true;
        getCommercialInformationBeforeValidatePricing({commercialId : this.commercialId})
            .then(result => {
                if(result.message.includes('SUCCESS')) {
                    this.showSpinner = false;
                    if(result.allowValidation) {
                        this.selectedListPaymentData = JSON.parse(result.selectedListPaymentData);
                        if(this.listFixedPricing.length == 0) {
                            var newInnerRecord = {
                                key : 1,
                                amcFee : '1',
                                amcInterval : '1',
                                setupFee : '1',
                                securityDeposit : '1'
                            };
                            this.listFixedPricing.push(newInnerRecord);
                        }
                        //fire event
                        const selectEvent = new CustomEvent('selection', {
                            detail : { 
                                selectedListPaymentData : this.selectedListPaymentData,
                                listFixedPricing : this.listFixedPricing
                            }
                        });
                        this.dispatchEvent(selectEvent); 
                        //this.showScreen5 = false;
                        //this.showScreen6 = true;
                    }
                    else {
                        this.showToast('INFO','info','Either update all records to above rack rates or Send the below rack rate records for BH Approval before validating');        
                    }
                }
                else {
                    this.showSpinner = false;
                    this.showToast('ERROR','error',result.messsage);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR','error',error[0]);
            })
    }

    //Method to show Toast Message on the UI
    showToast(title,variant,message) {
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    }

    //this method is used to track changes in TDR Flat Fee from the update screen
    updateBelowRackRateTdrFlatFee(event) {
        if(event.detail.value != '') {
            let tempList = JSON.parse(JSON.stringify(this.belowRackRatesRecords));
            tempList[event.currentTarget.dataset.id].tdrFlatFee = event.detail.value; 
            this.belowRackRatesRecords = tempList;    
        }
    }

    //this method is used to track changes in TDR Percentage from the update screen
    updateBelowRackRateTdrPercentage(event) {
        if(event.detail.value != '') {
            let tempList = JSON.parse(JSON.stringify(this.belowRackRatesRecords));
            tempList[event.currentTarget.dataset.id].tdrPercentage = event.detail.value; 
            this.belowRackRatesRecords = tempList;
        }    
    }

    //this method is used to track changes in Convenience Flat Fee from the update screen
    updateBelowRackRateConvenienceFlatFee(event) {
        if(event.detail.value != '') {
            let tempList = JSON.parse(JSON.stringify(this.belowRackRatesRecords));
            tempList[event.currentTarget.dataset.id].convenienceFlatFee = event.detail.value; 
            this.belowRackRatesRecords = tempList;     
        }
    }
    //this method is used to track changes in Convenience Percentage from the update screen
    updateBelowRackRateConveniencePercentage(event) {
        if(event.detail.value != '') {
            let tempList = JSON.parse(JSON.stringify(this.belowRackRatesRecords));
            tempList[event.currentTarget.dataset.id].conveniencePercentage = event.detail.value; 
            this.belowRackRatesRecords = tempList; 
        }
    }

    //this method is used to close modal for update below rack rates records screen
    closeModal(event) {
        this.openGovernanceModal = false;
    }

    //this method is called to update the below rack rates pricing records 
    saveUpdatePricing(event) {
        this.openGovernanceModal = false;
        this.showSpinner = true;
        updateBelowRackRatesRecords({commercialId:this.commercialId,belowRackRatesRecords:JSON.stringify(this.belowRackRatesRecords),listPricingIds:JSON.stringify(this.belowRackRatesIds)})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.selectedListPaymentData = JSON.parse(result.selectedListPaymentData);
                this.showBelowRackRateMessage = result.showBelowRackRateMessage;
                this.showBelowRackRateRecords = result.showBelowRackRateMessage;
                this.belowRackRateMessage = result.belowRackRateMessage;
                this.disabledBHButton = result.disabledBHButton;
                this.showSpinner = false;    
                this.showToast('SUCCESS','success','Records updated successfully'); 
            }
            else {
                this.showSpinner = false;
                this.showToast('ERROR','error',result.message);     
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToast('ERROR','error',error);     
        })
    }

    //this method is called on the click of the Cancel button from Send to BH modal
    closeModalSendBH(event) {
        this.openSendToBH = false;    
        this.bhAddress = '';
    }

    //this method is used to track changes in body field
    updateBody(event) {
        this.body = event.detail.value;
    }

    //this method is called on the click of the Send Request button
    sendToBHEmail(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateNewLatest');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        }); 
        if(!validateData) {
            return;
        }
        else {
            this.disabledSendRequestButton = true;
            this.openSendToBH = false; 
            this.showSpinner = true;
            sendToBHEmail({commercialId : this.commercialId,body:this.body,subject:this.subject,listPricingIds:this.belowRackRatesIds,bhAddress : this.bhAddress})
            .then(result =>{
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.disabledSendRequestButton = false; 
                    this.bhAddress = '';
                    this.showToast('SUCCESS','success','An email has been sent to BH'); 
                }
                else {
                    this.showSpinner = false;
                    this.disabledSendRequestButton = false;
                    this.bhAddress = '';
                    this.showToast('ERROR','error',result);    
                }
            }) 
            .catch(error => {
                this.showSpinner = false;
                this.disabledSendRequestButton = false;
                this.bhAddress = '';
                this.showToast('ERROR','error',error[0]);
            })
        }
    }

    // Created by rohit to send the current commercial id to vf page
    generatePDF() {
        let vfPageUrl = `/apex/GeneratePdfForPricing?id=${this.commercialId}`;
        window.open(vfPageUrl,'_blank');
    }

    handleChangeBHAddress(event) {
        this.bhAddress = event.detail.value;
       
    }

}
