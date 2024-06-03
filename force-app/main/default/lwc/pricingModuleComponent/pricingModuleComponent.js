import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRICING_OBJECT from '@salesforce/schema/Pricing__c';
import status from '@salesforce/schema/Pricing__c.Status__c';
import getPlanDetails from '@salesforce/apex/PricingModuleComponentController.getPlanDetailsOnLoad';
import getSubPlanDetails from '@salesforce/apex/PricingModuleComponentController.getSubPlanDetails';
import getTemplateDetails from '@salesforce/apex/PricingModuleComponentController.getTemplateDetails';
import getPaymentDetails from '@salesforce/apex/PricingModuleComponentController.getPaymentDetails';
import getSpecificationDetails from '@salesforce/apex/PricingModuleComponentController.getSpecificationDetails';
import savePricingApex from '@salesforce/apex/PricingModuleComponentController.savePricingApex';
import existingCommercial from '@salesforce/apex/PricingModuleComponentController.existingCommercial';
import getPricingRecordsForCommercial from '@salesforce/apex/PricingModuleComponentController.getPricingRecordsForCommercial';
import getPaymentGatewayData from '@salesforce/apex/PricingModuleComponentController.getPaymentGatewayData';
import getBelowRackRatesRecords from '@salesforce/apex/PricingModuleComponentController.getBelowRackRatesRecords';
import updateBelowRackRatesRecords from '@salesforce/apex/PricingModuleComponentController.updateBelowRackRatesRecords';
import getSendToBHRecords from '@salesforce/apex/PricingModuleComponentController.getSendToBHRecords';
import sendToBHEmail from '@salesforce/apex/PricingModuleComponentController.sendToBHEmail';
import insertFixedPricingAndPublishCommercial from '@salesforce/apex/PricingModuleComponentController.insertFixedPricingAndPublishCommercial';
import getCommercialInformationBeforeValidatePricing from '@salesforce/apex/PricingModuleComponentController.getCommercialInformationBeforeValidatePricing';
import OwnerAssignment from '@salesforce/apex/BankingOpsModuleController.OwnerAssignmentLogic';
import createTemplateForOrdinaryUser from '@salesforce/apex/PricingModuleComponentController.createTemplateForOrdinaryUser';
import getPrivateTemplateDetails from '@salesforce/apex/PricingModuleComponentController.getPrivateTemplateDetails';
import getPlanAndSubPlanDetails from '@salesforce/apex/PricingModuleComponentController.getPlanAndSubPlanDetails';
import createTemplateForSuperUser from '@salesforce/apex/PricingModuleComponentController.createTemplateForSuperUser';
import getPublicCheckboxForTemplate from '@salesforce/apex/PricingModuleComponentController.getPublicCheckboxForTemplate';
import getLiveDetailsFromTreasury from '@salesforce/apex/PricingModuleComponentController.getLiveDetailsFromTreasury';


export default class PricingModuleComponent extends LightningElement {
    showFirstScreen = true;
    showSpinner = false;
    availablePlanMaster = [];
    showSecondScreen = false;
    selectedPlan = '';
    selectedSubPlan = '';
    selectedTemplate = '';
    availableSubPlanMaster = [];
    availableTemplateMaster = [];
    disabledAddPaymentPlan = true;
    showThirdScreen = false;
    @track listPaymentData = [];
    selectedListPaymentData = [];
    currentStep = 1;
    hideScreen3Step1 = 'display:block';
    hideScreen3Step2 = 'display:none';
    @track listDataForPaymentMode = [];
    paymentModeName = '';
    listFeeModel = [];
    listTransactionType = [];
    index = 0;
    @track listFirstRowForAddCommercials = [];
    showScreen4 = false;
    disabledSavePricingButton = false;
    disabledSaveAsTemplateButton = false;
    showSaveAsTemplateModal = false;
    planChoiceOptions = [];
    selectedPlanChoice = '';
    @api recordId;
    showErrorMessage = false;
    errorMessage = '';
    commercialName = '';
    pathNumber = 1;
    showScreen5 = false;
    commercialId = '';
    disabledPublishPricingButton = false;
    listExistingCommercial = [];
    showCommercial = false;
    showBelowRackRateMessage = false;
    belowRackRateMessage = '';
    disabledUpdatePricingButton = false;
    openGovernanceModal = false;
    @track belowRackRatesRecords = [];
    belowRackRatesIds = [];
    showBelowRackRateRecords = false;
    disabledBHButton = true;
    openSendToBH = false;
    bhAddress = '';
    subject = '';
    body = '';
    disabledSendRequestButton = false;
    showScreen6 = false;
    @track listFixedPricing = [];
    hidePublishCommercialButton = false;
    disabledPublishPricingButton = false;
    @wire(getObjectInfo, { objectApiName: PRICING_OBJECT })
    pricingMetadata;
    mapTDRConvenienceData = new Map();
    showFixedPricingModal = false;
    isSuperUser = false;
    ordinaryUserCreateTemplate = false; 
    ordinaryUserUpdateTemplate = false;
    templateName = ''; 
    disabledSaveCreateTemplateOrdinaryUser = false;
    availablePrivateTemplate = [];
    superUserUpdateTemplate = false;
    publicTemplateCheckbox = false;
    availablePlanMaster = [];
    availableSubPlanMaster = [];
    superUserChooseExistingPlanSunPlanCreateNewTemplate = false;
    selectedSubPlanName = '';
    selectedPlanName = '';
    disabledOption1Save = false;
    disabledOption2Save = false;
    superUserCreatePlanSunPlanUpdateTemplate = false;
    disabledOption3Save = false;
    superUserCreatePlanSunPlanTemplate = false;
    disabledOption4Save = false;
    showRedirectToHomeModal = false;
    disabledCommercialName = false;
    selectedListPaymentDataLiveFromTreasury = [];

    @track SelectedPaymentOptionObject = {
        paymentModeId : '',
        paymentModeName : '',
        selectedPaymentOptionsList : [],
        styleClass : 'background:#F2F8FF'
    }

    @track SelectedPaymentOptionIndividualListObject = {
        key : '',
        selectedPaymentIndividualList : []
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
        backgroundColor : 'background-color:white;'
    }

    //method to get the value of the Status picklist from the Pricing Object
    @wire(getPicklistValues,
        {
            recordTypeId: '$pricingMetadata.data.defaultRecordTypeId', 
            fieldApiName: status
        }
    )
    statusPicklist;

    //this method is called on click of cancel from Added fixed pricing modal
    cancelMessageModal(event) {
        this.showFixedPricingModal = false;    
    }

    //this method is called on click of the Proceed button from the added fixed pricing modal
    openSaveAsTemplateModal(event) {
        this.showSaveAsTemplateModal = true;
        this.showFixedPricingModal = false; 
    }

    //this method is called when the component load
    connectedCallback() {
        this.onLoadFunction();    
    }

    //this method is called from the connected callback and redirect to home button
    onLoadFunction() {
        this.showSpinner = true;
        existingCommercial({recordId : this.recordId})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.showSpinner = false;
                this.isSuperUser = result.isSuperUser;
                if(this.isSuperUser) {
                    this.planChoiceOptions = [{label: 'Update Existing Template',value: 'option1'},{label: 'Choose existing Plan, existing Sub Plan and create new Template',value: 'option2'},{label: 'Create new Plan, new Sub Plan and update existing Template',value: 'option3'},{label: 'Create new Plan, new Sub Plan and new Template',value: 'option4'}];
                }
                else {
                    this.planChoiceOptions = [{label: 'Update Existing Template',value: 'option1'},{label: 'Create New Template',value: 'option2'}];
                }
                if(result.listExistingCommercial.length > 0) {
                    this.listExistingCommercial = result.listExistingCommercial;
                    this.showCommercial = true;
                }
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

    //Method to call Apex to fetch data that is required at screen 2
    getPlanDetails(event) {
        this.showSpinner = true;
        getPlanDetails()
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.showSecondScreen = true;
                this.showFirstScreen = false;
                this.availablePlanMaster = JSON.parse(result.jsonPlanMaster);
                this.listFeeModel = result.listFeeModel;
                this.listTransactionType = result.listTransactionType;
                this.showSpinner = false;
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

    //Method to show Toast Message on the UI
    showToast(title,variant,message) {
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
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
        getSubPlanDetails({planId : this.selectedPlan})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.availableSubPlanMaster = JSON.parse(result.jsonPlanMaster);
                this.showSpinner = false;
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

    //Method to store the value of the sub plan whenever sub plan is changed from the UI Screen 2
    handleSubPlanChange(event) {
        this.disabledAddPaymentPlan = true;
        this.selectedSubPlan = event.detail.value;
        this.showSpinner = true;
        this.selectedTemplate = '';
        this.availableTemplateMaster = [];
        getTemplateDetails({planId : this.selectedPlan,subPlanId : this.selectedSubPlan})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.availableTemplateMaster = JSON.parse(result.jsonPlanMaster);
                this.showSpinner = false;
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

    //update the value in the selectedTemplate
    handleTemplateChange(event) {
        this.selectedTemplate = event.detail.value;
        this.disabledAddPaymentPlan = false;
    }

    //Method to call Apex to fetch the data that is required for the screen 3 part 1
    handleThirdScreen(event) {
        this.showSpinner = true;
        if(event.currentTarget.dataset.id == 'Select payment options') {
            this.selectedTemplate = '';
        }
        
        getPaymentDetails({templateId : this.selectedTemplate,commercialId : ''})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.showFirstScreen = false;
                this.showSecondScreen = false;
                this.showThirdScreen = true;
                this.showSpinner = false;
                this.listPaymentData = result.listPaymentData;
                this.mapTDRConvenienceData = result.mapTDRConvenienceData;
                if(result.listFixedPricingString.length > 0) {
                    this.listFixedPricing =  JSON.parse(result.listFixedPricingString);
                }
            }
            else {
                this.showSpinner = false;
                this.showToast('ERROR','error',result.message);
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToast('ERROR','error',error);  
        });
        this.showFirstScreen = false;
        this.showSecondScreen = false;
        this.showThirdScreen = true;
    }

    //Method called on check of the checkbox on screen 3 part 1
    handleChecked(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.key;
        if(this.listPaymentData[indexRow].isChecked) {
            this.listPaymentData[indexRow].isChecked = false;  
            for (let index = 0; index < this.listPaymentData[indexRow].listPaymentDataInner.length; index++) {
                this.listPaymentData[indexRow].listPaymentDataInner[index].disablePicklistValues = true;  
                this.listPaymentData[indexRow].listPaymentDataInner[index].disableSpecificationPicklist = true;  
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedOnusOffus = '';  
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentOption = ''; 
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGateway = ''; 
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedSpecifications = ''; 
                this.listPaymentData[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = true;
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGateway = '';
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedSpecificationsList = [];
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGatewayList = [];
            }   
        }
        else {
            this.listPaymentData[indexRow].isChecked = true;
            for (let index = 0; index < this.listPaymentData[indexRow].listPaymentDataInner.length; index++) {
                this.listPaymentData[indexRow].listPaymentDataInner[index].disablePicklistValues = false;  
                this.listPaymentData[indexRow].listPaymentDataInner[index].selectedOnusOffus = 'ONUS';  
            }
        }
    }

    //Method called on click of the + Icon on the row, Screen 3 Part 1
    addRow(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        let onus = '';
        if(this.listPaymentData[indexRow].isChecked) {
            onus = 'ONUS';
        }
        var newInnerRecord = {
            key : paymentModeId+'#'+(index+1),
            listPaymentOptionsToShow : this.listPaymentData[indexRow].listPaymentDataInner[index].listPaymentOptionsToShow,
            listSpecificationToShow : [],
            listPaymentOptions : this.listPaymentData[indexRow].listPaymentDataInner[index].listPaymentOptions,
            listPaymentGatewayToShow : [],
            listOnusOffusToShow : this.listPaymentData[indexRow].listPaymentDataInner[index].listOnusOffusToShow,
            listPaymentModeToPaymentGateways : this.listPaymentData[indexRow].listPaymentDataInner[index].listPaymentModeToPaymentGateways,
            disablePicklistValues : this.listPaymentData[indexRow].listPaymentDataInner[index].disablePicklistValues,
            disablePaymentGatewayPicklist : true,
            disableSpecificationPicklist : true,
            selectedPaymentOption : '',
            selectedPaymentOptionId : '',
            selectedPaymentGateway : '',
            selectedOnusOffus : onus,
            selectedSpecifications : '',
            showDeleteButton : true,
            selectedSpecificationsList : [],
            selectedPaymentGatewayList : []

        };
        this.listPaymentData[indexRow].listPaymentDataInner.push(newInnerRecord);
    }

    //Method called to remove row, Screen 3 Part 1
    removeRow(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        if(this.listPaymentData[indexRow].listPaymentDataInner.length > 1){
            this.listPaymentData[indexRow].listPaymentDataInner.splice(index, 1);
            index--;
        }    
    }

    //Method called to fetch the Specifications corresponding to the Payment Options on change of Payment Options, Screen 3 Part 1
    handleChangePaymentOptions(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key; 
        let paymentOptionDetails = event.detail.value.split('#');
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentOption = event.detail.value;
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentOptionId = paymentOptionDetails[1];
        this.listPaymentData[indexRow].listPaymentDataInner[index].disableSpecificationPicklist = true;
        this.listPaymentData[indexRow].listPaymentDataInner[index].listSpecificationToShow = [];
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedSpecifications = '';
        this.listPaymentData[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = true;
        this.listPaymentData[indexRow].listPaymentDataInner[index].listPaymentGatewayToShow = [];
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGateway = '';
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedSpecificationsList = [];
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGatewayList = [];

        this.showSpinner = true;
        getSpecificationDetails({paymentModeId:paymentModeId,paymentOptionId:paymentOptionDetails[1]})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.listPaymentData[indexRow].listPaymentDataInner[index].disableSpecificationPicklist = false;
                this.listPaymentData[indexRow].listPaymentDataInner[index].listSpecificationToShow = result.listSpecifications;
                this.showSpinner = false; 
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

    //Method to track changes around the column ONUS/OFFUS, Screen 3 Part 1
    handleChangeOnusOffus(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;  
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedOnusOffus = event.detail.value;
    }

    //Method to track changes around the column Specifications, Screen 3 Part 1
    getSpecifications(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;  
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedSpecifications = event.detail;  
        let paymentOptionId = this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentOptionId;
        let selectedSpecifications = this.listPaymentData[indexRow].listPaymentDataInner[index].selectedSpecifications;
        this.listPaymentData[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = true;
        this.listPaymentData[indexRow].listPaymentDataInner[index].listPaymentGatewayToShow = [];
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGateway = '';
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGatewayList = [];
        this.showSpinner = true;
        getPaymentGatewayData({paymentModeId:paymentModeId,paymentOptionId:paymentOptionId,selectedSpecifications:selectedSpecifications})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.listPaymentData[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = false;
                this.listPaymentData[indexRow].listPaymentDataInner[index].listPaymentGatewayToShow = result.listPaymentGateway;
                this.showSpinner = false; 
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

    //Method to track changes around the column Payment Gateway, Screen 3 Part 1
    getPaymentGateway(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;  
        this.listPaymentData[indexRow].listPaymentDataInner[index].selectedPaymentGateway = event.detail; 
    }

    //Method called on load of the Screen 3 Part 2 - Selected Payment Option
    handleDataToShowNewForCombination(event) {
        this.showSpinner = true;
        this.selectedListPaymentData = [];
        let addStyle = true;
        for(let index=0; index<this.listPaymentData.length; index++) {
                if(this.listPaymentData[index].isChecked) {
                    this.SelectedPaymentOptionObject.paymentModeId = this.listPaymentData[index].key;
                    this.SelectedPaymentOptionObject.paymentModeName = this.listPaymentData[index].paymentMode;
                    //add color
                    if(addStyle) {
                        this.listPaymentData[index].styleClass =  'background:#C7E1FF;color: #222222;border-left: #599AEA solid 4px;';
                        this.SelectedPaymentOptionObject.styleClass = this.listPaymentData[index].styleClass;
                        addStyle = false;   
                    }
                    else {
                        this.listPaymentData[index].styleClass =  'background:#F2F8FF;';
                        this.SelectedPaymentOptionObject.styleClass = this.listPaymentData[index].styleClass;    
                    }
                    //end
                    let setUniqueCombination = new Set();
                    for(let indexInner=0; indexInner < this.listPaymentData[index].listPaymentDataInner.length; indexInner++) {
                        let selectedSpecifications = JSON.stringify(this.listPaymentData[index].listPaymentDataInner[indexInner].selectedSpecifications);
                        selectedSpecifications = selectedSpecifications.replaceAll('"','');
                        selectedSpecifications = selectedSpecifications.replaceAll('[','');
                        selectedSpecifications = selectedSpecifications.replaceAll(']','');
                        selectedSpecifications.split(',').forEach(element => {
                            let selectedPaymentGateway = JSON.stringify(this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentGateway);
                            selectedPaymentGateway = selectedPaymentGateway.replaceAll('"','');
                            selectedPaymentGateway = selectedPaymentGateway.replaceAll('[','');
                            selectedPaymentGateway = selectedPaymentGateway.replaceAll(']','');
                            selectedPaymentGateway.split(',').forEach(element1 => {
                                let key = this.listPaymentData[index].key+'#'+this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOptionId+'#'+element+'#'+element1+'#'+this.listPaymentData[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                                if(!setUniqueCombination.has(key)) {
                                    setUniqueCombination.add(key); 
                                    this.selectetPaymentIndividualObject.key = key;
                                    this.selectetPaymentIndividualObject.selectedPaymentOptionName = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOption.split('#')[0];
                                    this.selectetPaymentIndividualObject.selectedPaymentOptionId = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOptionId;
                                    this.selectetPaymentIndividualObject.selectedSpecification = element;
                                    this.selectetPaymentIndividualObject.selectedPaymentGatewayName = element1;
                                    this.selectetPaymentIndividualObject.selectedOnusOffus = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                                    this.selectetPaymentIndividualObject.listFeeModel = this.listFeeModel;
                                    this.selectetPaymentIndividualObject.listTransactionType = this.listTransactionType;
                                    this.selectetPaymentIndividualObject.selectedFeeModel = 'Net';
                                    this.selectetPaymentIndividualObject.selectedTransactionType = 'TDR';
                                    this.selectetPaymentIndividualObject.isChecked = false;
                                    this.selectetPaymentIndividualObject.showCheckbox = true;
                                    this.selectetPaymentIndividualObject.showTDR = true;
                                    this.selectetPaymentIndividualObject.showConvenience = false;
                                    this.selectetPaymentIndividualObject.tdrAmount = '0';
                                    this.selectetPaymentIndividualObject.tdrFee = '';
                                    this.selectetPaymentIndividualObject.tdrPercentage = '';
                                    this.selectetPaymentIndividualObject.convenienceAmount = '0';
                                    this.selectetPaymentIndividualObject.convenienceFee = '';
                                    this.selectetPaymentIndividualObject.conveniencePercentage = '';
                                    this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList = [];
                                    this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
                                    this.SelectedPaymentOptionIndividualListObject.key = key;
                                    this.SelectedPaymentOptionObject.selectedPaymentOptionsList.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionIndividualListObject)));
                                }
                            })         
                        });
                    } 
                    this.selectedListPaymentData.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionObject)));  
                    this.SelectedPaymentOptionObject.selectedPaymentOptionsList = [];
                }
            }
        this.showSpinner = false;
    }

    //Method called on click of the Confirm Payment Options - Screen 2
    handleDataToShowNew(event) {
        this.showSpinner = true;
        this.selectedListPaymentData = [];
        let mapTDRConvenience = new Map(Object.entries(this.mapTDRConvenienceData));
        let addStyle = true;
        for(let index=0; index<this.listPaymentData.length; index++){
            if(this.listPaymentData[index].isChecked){
                this.SelectedPaymentOptionObject.paymentModeId = this.listPaymentData[index].key;
                this.SelectedPaymentOptionObject.paymentModeName = this.listPaymentData[index].paymentMode; 
                //add color
                if(addStyle) {
                    this.listPaymentData[index].styleClass =  'background:#C7E1FF;color: #222222;border-left: #599AEA solid 4px;';
                    this.SelectedPaymentOptionObject.styleClass = this.listPaymentData[index].styleClass;
                    addStyle = false;   
                }
                else {
                    this.listPaymentData[index].styleClass =  'background:#F2F8FF;';
                    this.SelectedPaymentOptionObject.styleClass = this.listPaymentData[index].styleClass;    
                }
                //end
                let setUniqueCombination = new Set();
                for(let indexInner=0; indexInner < this.listPaymentData[index].listPaymentDataInner.length; indexInner++) {
                    let selectedSpecifications = JSON.stringify(this.listPaymentData[index].listPaymentDataInner[indexInner].selectedSpecifications);
                    selectedSpecifications = selectedSpecifications.replaceAll('"','');
                    selectedSpecifications = selectedSpecifications.replaceAll('[','');
                    selectedSpecifications = selectedSpecifications.replaceAll(']','');
                    selectedSpecifications.split(',').forEach(element => {
                        let selectedPaymentGateway = JSON.stringify(this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentGateway);
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll('"','');
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll('[','');
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll(']','');
                        selectedPaymentGateway.split(',').forEach(element1 => {
                            let key = this.listPaymentData[index].key+'#'+this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOptionId+'#'+element+'#'+element1+'#'+this.listPaymentData[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                            if(!setUniqueCombination.has(key)) {
                                setUniqueCombination.add(key); 
                                if(mapTDRConvenience.has(key)) {
                                    let innerMap = new Map(Object.entries(mapTDRConvenience.get(key)));
                                    innerMap.forEach((values,keys)=>{
                                        let feeAndTransaction = keys.split('#');
                                        let keyNew = key + '#'+feeAndTransaction[0]+'#'+feeAndTransaction[1];
                                        this.SelectedPaymentOptionIndividualListObject.key = keyNew;
                                        this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList = [];
                                        for(let indexNew=0;indexNew<values.length;indexNew++){
                                            if(indexNew == 0) {
                                                this.selectetPaymentIndividualObject.key = keyNew;    
                                            }
                                            else {
                                                this.selectetPaymentIndividualObject.key = keyNew+'#'+indexNew;
                                            }
                                            //this.selectetPaymentIndividualObject.key = key;
                                            this.selectetPaymentIndividualObject.selectedPaymentOptionName = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOption.split('#')[0];
                                            this.selectetPaymentIndividualObject.selectedPaymentOptionId = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOptionId;
                                            this.selectetPaymentIndividualObject.selectedSpecification = element;
                                            this.selectetPaymentIndividualObject.selectedPaymentGatewayName = element1;
                                            this.selectetPaymentIndividualObject.selectedOnusOffus = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                                            this.selectetPaymentIndividualObject.listFeeModel = this.listFeeModel;
                                            this.selectetPaymentIndividualObject.listTransactionType = this.listTransactionType;
                                            this.selectetPaymentIndividualObject.selectedFeeModel = feeAndTransaction[0];
                                            this.selectetPaymentIndividualObject.selectedTransactionType = feeAndTransaction[1];
                                            this.selectetPaymentIndividualObject.isChecked = false;
                                            if(indexNew == 0) {
                                                this.selectetPaymentIndividualObject.showCheckbox = true;
                                            }
                                            else {
                                                this.selectetPaymentIndividualObject.showCheckbox = false;
                                            }
                                            if(feeAndTransaction[1] == 'TDR') {
                                                this.selectetPaymentIndividualObject.showTDR = true;
                                                this.selectetPaymentIndividualObject.showConvenience = false;    
                                            }
                                            else if(feeAndTransaction[1] == 'Convenience') {
                                                this.selectetPaymentIndividualObject.showConvenience = true;
                                                this.selectetPaymentIndividualObject.showTDR = false;
                                            }
                                            else {
                                                this.selectetPaymentIndividualObject.showConvenience = true;
                                                this.selectetPaymentIndividualObject.showTDR = true;    
                                            }
                                            this.selectetPaymentIndividualObject.tdrAmount = values[indexNew].tdrAmount;
                                            this.selectetPaymentIndividualObject.tdrFee = values[indexNew].tdrFlatFee;
                                            this.selectetPaymentIndividualObject.tdrPercentage = values[indexNew].tdrPercentage;
                                            this.selectetPaymentIndividualObject.convenienceAmount = values[indexNew].convenienceAmount;
                                            this.selectetPaymentIndividualObject.convenienceFee = values[indexNew].convenienceFlatFee;
                                            this.selectetPaymentIndividualObject.conveniencePercentage = values[indexNew].conveniencePercentage;    
                                            this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
                                        }
                                        this.SelectedPaymentOptionObject.selectedPaymentOptionsList.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionIndividualListObject)));
                                    })
                                }
                                else {
                                    this.selectetPaymentIndividualObject.key = key;
                                    this.selectetPaymentIndividualObject.selectedPaymentOptionName = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOption.split('#')[0];
                                    this.selectetPaymentIndividualObject.selectedPaymentOptionId = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedPaymentOptionId;
                                    this.selectetPaymentIndividualObject.selectedSpecification = element;
                                    this.selectetPaymentIndividualObject.selectedPaymentGatewayName = element1;
                                    this.selectetPaymentIndividualObject.selectedOnusOffus = this.listPaymentData[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                                    this.selectetPaymentIndividualObject.listFeeModel = this.listFeeModel;
                                    this.selectetPaymentIndividualObject.listTransactionType = this.listTransactionType;
                                    this.selectetPaymentIndividualObject.selectedFeeModel = 'Net';
                                    this.selectetPaymentIndividualObject.selectedTransactionType = 'TDR';
                                    this.selectetPaymentIndividualObject.isChecked = false;
                                    this.selectetPaymentIndividualObject.showCheckbox = true;
                                    this.selectetPaymentIndividualObject.showTDR = true;
                                    this.selectetPaymentIndividualObject.showConvenience = false;
                                    this.selectetPaymentIndividualObject.tdrAmount = '0';
                                    this.selectetPaymentIndividualObject.tdrFee = '';
                                    this.selectetPaymentIndividualObject.tdrPercentage = '';
                                    this.selectetPaymentIndividualObject.convenienceAmount = '0';
                                    this.selectetPaymentIndividualObject.convenienceFee = '';
                                    this.selectetPaymentIndividualObject.conveniencePercentage = '';
                                    this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList = [];
                                    this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
                                    this.SelectedPaymentOptionIndividualListObject.key = key;
                                    this.SelectedPaymentOptionObject.selectedPaymentOptionsList.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionIndividualListObject)));    
                                }
                            }
                        })         
                    });
                }
                this.selectedListPaymentData.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionObject)));  
                this.SelectedPaymentOptionObject.selectedPaymentOptionsList = [];
            }    
        }    
        this.showSpinner = false; 
    }

    //Method called on click of the Custom Lightning Path
    showRespectiveScreen(event) {
       if(event.target.value != 3 && this.pathNumber == 3 && (this.showScreen5 || this.showScreen6)) {
        this.showToast('INFO','info','You can not go to previous steps');
        return; 
       }
       if(event.target.value == 1) {
            this.handleDataToShowNewForCombination();
            this.hideScreen3Step1 = 'display:block';
            this.hideScreen3Step2 = 'display:none';
       }
       else if(event.target.value == 2) {
        this.screen3Step2Show();
       }
       else if(event.target.value == 3) {
       
       }
       this.pathNumber = event.target.value; 
    }

    //Method called on click of Payment Mode to show its respective Data : Screen 4
    getListForPaymentMode(event) {
        this.showScreen4 = false;
        for(let index1=0; index1<this.selectedListPaymentData[this.index].selectedPaymentOptionsList.length; index1++) { 
            for(let index2=0; index2<this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; index2++) {
                this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].isChecked = false;
            }
        }
        this.listDataForPaymentMode = [];
        this.listFirstRowForAddCommercials = [];
        this.index = event.currentTarget.dataset.id;
        this.listDataForPaymentMode = this.selectedListPaymentData[event.currentTarget.dataset.id].selectedPaymentOptionsList;
        this.paymentModeName = this.selectedListPaymentData[event.currentTarget.dataset.id].paymentModeName;

        //Added to add color
        for(let index1=0; index1<this.selectedListPaymentData.length; index1++) { 
            this.selectedListPaymentData[index1].styleClass = 'background:#F2F8FF;border-left: #F2F8FF solid 4px;color: #222222;';   
        }
        this.selectedListPaymentData[event.currentTarget.dataset.id].styleClass = 'background:#C7E1FF;color: #222222;border-left: #599AEA solid 4px;';
        //end

        this.selectetPaymentIndividualObject.key = this.selectedListPaymentData[0].paymentModeName;
        this.selectetPaymentIndividualObject.selectedPaymentOptionName = 'Set a default rate';//+this.selectedListPaymentData[event.currentTarget.dataset.id].paymentModeName +' rate';
        this.selectetPaymentIndividualObject.selectedPaymentOptionId = '';
        this.selectetPaymentIndividualObject.selectedSpecification = '';
        this.selectetPaymentIndividualObject.selectedPaymentGatewayName = '';
        this.selectetPaymentIndividualObject.selectedOnusOffus = '';
        this.selectetPaymentIndividualObject.listFeeModel = this.listFeeModel;
        this.selectetPaymentIndividualObject.listTransactionType = this.listTransactionType;
        this.selectetPaymentIndividualObject.selectedFeeModel = 'Net';
        this.selectetPaymentIndividualObject.selectedTransactionType = 'TDR';
        this.selectetPaymentIndividualObject.isChecked = false;
        this.selectetPaymentIndividualObject.showCheckbox = true;
        this.selectetPaymentIndividualObject.showTDR = true;
        this.selectetPaymentIndividualObject.showConvenience = false;
        this.selectetPaymentIndividualObject.tdrAmount = '0';
        this.selectetPaymentIndividualObject.tdrFee = '';
        this.selectetPaymentIndividualObject.tdrPercentage = '';
        this.selectetPaymentIndividualObject.convenienceAmount = '0';
        this.selectetPaymentIndividualObject.convenienceFee = '';
        this.selectetPaymentIndividualObject.conveniencePercentage = '';

        this.listFirstRowForAddCommercials.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
        this.showScreen4 = true; 
    }

    //This method called on Click of Confirm Payment Options : Screen 3
    screen3Step2Show(event) {
        var count = 0;
        this.showScreen4 = false;
        for(let index=0; index<this.listPaymentData.length; index++) {
            if(this.listPaymentData[index].isChecked) {
                count = 1;
                break;
            }    
        }  
        if(count == 1) {
            //this.currentStep = 2;
            this.showScreen4 = true;
            this.handleDataToShowNew();
            this.listFirstRowForAddCommercials = [];
            this.listDataForPaymentMode = this.selectedListPaymentData[0].selectedPaymentOptionsList;
            this.paymentModeName = this.selectedListPaymentData[0].paymentModeName;
            this.index = 0;
            this.hideScreen3Step1 = 'display:none';
            this.hideScreen3Step2 = 'display:block'; 

            this.selectetPaymentIndividualObject.key = this.selectedListPaymentData[0].paymentModeName;
            this.selectetPaymentIndividualObject.selectedPaymentOptionName = 'Set a default rate';//+this.selectedListPaymentData[0].paymentModeName +' rate';
            this.selectetPaymentIndividualObject.selectedPaymentOptionId = '';
            this.selectetPaymentIndividualObject.selectedSpecification = '';
            this.selectetPaymentIndividualObject.selectedPaymentGatewayName = '';
            this.selectetPaymentIndividualObject.selectedOnusOffus = '';
            this.selectetPaymentIndividualObject.listFeeModel = this.listFeeModel;
            this.selectetPaymentIndividualObject.listTransactionType = this.listTransactionType;
            this.selectetPaymentIndividualObject.selectedFeeModel = 'Net';
            this.selectetPaymentIndividualObject.selectedTransactionType = 'TDR';
            this.selectetPaymentIndividualObject.isChecked = false;
            this.selectetPaymentIndividualObject.showCheckbox = true;
            this.selectetPaymentIndividualObject.showTDR = true;
            this.selectetPaymentIndividualObject.showConvenience = false;
            this.selectetPaymentIndividualObject.tdrAmount = '0';
            this.selectetPaymentIndividualObject.tdrFee = '';
            this.selectetPaymentIndividualObject.tdrPercentage = '';
            this.selectetPaymentIndividualObject.convenienceAmount = '0';
            this.selectetPaymentIndividualObject.convenienceFee = '';
            this.selectetPaymentIndividualObject.conveniencePercentage = '';

            this.listFirstRowForAddCommercials.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject))); 
        }
        else {
            this.showToast('INFO','info','Please select Payment modes to proceed');    
        }      
    }

    //this method is called from screen 4th on click of checkbox to add commercials
    handleCheckedForCommercials(event) {
        this.showScreen4 = false;
        let index = this.index;
        let index1 = event.currentTarget.dataset.id;
        let index2 = event.currentTarget.dataset.key;
        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].isChecked) {
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].isChecked = false;    
        }
        else {
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].isChecked = true;
        }
        this.listDataForPaymentMode = this.selectedListPaymentData[index].selectedPaymentOptionsList;  
        this.showScreen4 = true;  
    }

    //this method is called when fee model is changed from screen 4th
    handleChangeFeeModel(event) {
        this.showScreen4 = false;
        let index = this.index;
        let index1 = event.currentTarget.dataset.id;
        let index2 = event.currentTarget.dataset.key;
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedFeeModel = event.detail.value;

        for(let i=1; i < this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; i++) {
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].selectedFeeModel = event.detail.value;
        }

        this.listDataForPaymentMode = this.selectedListPaymentData[index].selectedPaymentOptionsList;
        this.showScreen4 = true; 
    }

    //this method is called on change of transaction type from screen 4
    handleChangeTransactionType(event) {
        this.showScreen4 = false;
        let index = this.index;
        let index1 = event.currentTarget.dataset.id;
        let index2 = event.currentTarget.dataset.key;
        
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType = event.detail.value;
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrAmount = '0';
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee = '';
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage = '';
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceAmount = '0';
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceFee = '';
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].conveniencePercentage = '';
        if(event.detail.value == 'TDR') {
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = true; 
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = false;   
        }
        else if(event.detail.value == 'Convenience') {
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = true; 
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = false;
        }
        else {
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = true; 
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = true;
        }
        for(let i=1; i < this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; i++) {
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].selectedTransactionType = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].selectedTransactionType;
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].tdrAmount = '0';
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].tdrFee = '';
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].tdrPercentage = '';
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].convenienceAmount = '0';
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].convenienceFee = '';
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].conveniencePercentage = ''; 
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].showConvenience = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].showConvenience; 
            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].showTDR = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].showTDR;  
        }
        this.listDataForPaymentMode = this.selectedListPaymentData[index].selectedPaymentOptionsList; 
        this.showScreen4 = true;
    }

    //this method is called from Screen 4 on click of checkbox from Set Default rate row
    handleCheckedForCommercialsFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].isChecked = event.detail.checked;
        let index = this.index;
        for(let index1=0; index1<this.selectedListPaymentData[index].selectedPaymentOptionsList.length; index1++) { 
            for(let index2=0; index2<this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; index2++) {
                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].isChecked = event.detail.checked;
            }
        }
        this.listDataForPaymentMode = this.selectedListPaymentData[index].selectedPaymentOptionsList;
    }

    //this method is called from Screen 4 on click of fee model from Set Default rate row
    handleChangeFeeModelFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].selectedFeeModel = event.detail.value; 
        for(let i=0;i<this.listFirstRowForAddCommercials.length;i++) {
            this.listFirstRowForAddCommercials[i].selectedFeeModel = event.detail.value;    
        }
    }

    //this method is called from Screen 4 on click of transaction type from Set Default rate row
    handleChangeTransactionTypeFirstRow(event) {
        for(let i=0;i<this.listFirstRowForAddCommercials.length;i++) {
            this.listFirstRowForAddCommercials[i].selectedTransactionType = event.detail.value; 
            if(event.detail.value == 'TDR') {
                this.listFirstRowForAddCommercials[i].showTDR = true; 
                this.listFirstRowForAddCommercials[i].showConvenience = false;   
            }
            else if(event.detail.value == 'Convenience') {
                this.listFirstRowForAddCommercials[i].showConvenience = true; 
                this.listFirstRowForAddCommercials[i].showTDR = false;
            }
            else {
                this.listFirstRowForAddCommercials[i].showTDR = true; 
                this.listFirstRowForAddCommercials[i].showConvenience = true;
            }
        }
    }

    //this method is called on click of plus icon from first row of default rates
    addrowInListFirstRowForAddCommercials(event) {
        let showTdr = false;
        let showCon = false;
        if(this.listFirstRowForAddCommercials[0].selectedTransactionType == 'TDR') {
            showTdr = true;
        }
        else if(this.listFirstRowForAddCommercials[0].selectedTransactionType  == 'Convenience') {
            showCon = true;    
        }
        else {
            showTdr = true;
            showCon = true;
        }

        this.selectetPaymentIndividualObject.key = this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].key;
        this.selectetPaymentIndividualObject.selectedPaymentOptionName = '';
        this.selectetPaymentIndividualObject.selectedPaymentOptionId = '';
        this.selectetPaymentIndividualObject.selectedSpecification = '';
        this.selectetPaymentIndividualObject.selectedPaymentGatewayName = '';
        this.selectetPaymentIndividualObject.selectedOnusOffus = '';
        this.selectetPaymentIndividualObject.listFeeModel = this.listFeeModel;
        this.selectetPaymentIndividualObject.listTransactionType = this.listTransactionType;
        this.selectetPaymentIndividualObject.selectedFeeModel = this.listFirstRowForAddCommercials[0].selectedFeeModel;
        this.selectetPaymentIndividualObject.selectedTransactionType = this.listFirstRowForAddCommercials[0].selectedTransactionType;
        this.selectetPaymentIndividualObject.isChecked = false;
        this.selectetPaymentIndividualObject.showCheckbox = false;
        this.selectetPaymentIndividualObject.showTDR = showTdr;
        this.selectetPaymentIndividualObject.showConvenience = showCon;
        this.selectetPaymentIndividualObject.tdrAmount = '0';
        this.selectetPaymentIndividualObject.tdrFee = '';
        this.selectetPaymentIndividualObject.tdrPercentage = '';
        this.selectetPaymentIndividualObject.convenienceAmount = '0';
        this.selectetPaymentIndividualObject.convenienceFee = '';
        this.selectetPaymentIndividualObject.conveniencePercentage = '';
        this.listFirstRowForAddCommercials.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
    }

    //this method is called to handle amount entered in TDR for first row Screen 4
    handleTDRAmountForFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].tdrAmount = event.detail.value;
    }

    //this method is called to handle fee entered in TDR for first row Screen 4
    handleTDRFeeForFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].tdrFee = event.detail.value;
    }

    //this method is called to handle percentage entered in TDR for first row Screen 4
    handleTDRPercentageForFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].tdrPercentage = event.detail.value;
    }

    //this method is called to handle amount entered in Convenience for first row Screen 4
    handleConvenienceAmountForFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].convenienceAmount = event.detail.value;   
    }

    //this method is called to handle fee entered in Convenience for first row Screen 4
    handleConvenienceFeeForFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].convenienceFee = event.detail.value;    
    }

    //this method is called to handle percentage entered in Convenience for first row Screen 4
    handleConveniencePercentageForFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].conveniencePercentage = event.detail.value;     
    }

    //this method is called on click of Apply to all selected link from screen 4
    populateDataForAllSelected(event) {
        this.showScreen4 = false;
        for(let index1=0; index1<this.selectedListPaymentData[this.index].selectedPaymentOptionsList.length; index1++) {
            if(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].isChecked) {
                let lengthSelectedPaymentIndividualList = this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length;
                for(let index2=0;index2<this.listFirstRowForAddCommercials.length;index2++) {
                    if(index2 == 0 && this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length == 1) {
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].isChecked = false;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedFeeModel = this.listFirstRowForAddCommercials[index2].selectedFeeModel;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType = this.listFirstRowForAddCommercials[index2].selectedTransactionType;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showCheckbox = true;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrAmount = this.listFirstRowForAddCommercials[index2].tdrAmount;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee = this.listFirstRowForAddCommercials[index2].tdrFee;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage = this.listFirstRowForAddCommercials[index2].tdrPercentage;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceAmount = this.listFirstRowForAddCommercials[index2].convenienceAmount;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceFee = this.listFirstRowForAddCommercials[index2].convenienceFee; 
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].conveniencePercentage = this.listFirstRowForAddCommercials[index2].conveniencePercentage;  
                        if(this.listFirstRowForAddCommercials[index2].selectedTransactionType == 'TDR') {
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = true;
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = false;
                        }   
                        else if(this.listFirstRowForAddCommercials[index2].selectedTransactionType == 'Convenience') {
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = true;
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = false;
                        }   
                        else {
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = true;
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = true;
                        }    
                    }
                    else {
                        let showTDR = false;
                        let showConvenience = false;
                        if(this.listFirstRowForAddCommercials[index2].selectedTransactionType == 'TDR') {
                            showTDR = true;
                            showConvenience = false;
                        }   
                        else if(this.listFirstRowForAddCommercials[index2].selectedTransactionType == 'Convenience') {
                            showTDR = false;
                            showConvenience = true;
                        }   
                        else {
                            showTDR = true;
                            showConvenience = true;
                        }
                        let keyNumber = '';
                        if(lengthSelectedPaymentIndividualList == 1) {
                            keyNumber =  lengthSelectedPaymentIndividualList + index2;   
                        }
                        else {
                            keyNumber =  lengthSelectedPaymentIndividualList + index2 + 1; 
                        }
                        var newInnerRecord = {
                            key : this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].key+'#'+keyNumber,
                            selectedPaymentOptionName : this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].selectedPaymentOptionName,
                            selectedPaymentOptionId : this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].selectedPaymentOptionId,
                            selectedSpecification : this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].selectedSpecification,
                            selectedPaymentGatewayName : this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].selectedPaymentGatewayName,
                            selectedOnusOffus : this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].selectedOnusOffus,
                            listFeeModel : this.listFeeModel,
                            listTransactionType : this.listTransactionType,
                            selectedFeeModel : this.listFirstRowForAddCommercials[index2].selectedFeeModel,
                            selectedTransactionType : this.listFirstRowForAddCommercials[index2].selectedTransactionType,
                            isChecked : false,
                            showCheckbox : false,
                            showTDR : showTDR,
                            showConvenience : showConvenience,
                            tdrAmount : this.listFirstRowForAddCommercials[index2].tdrAmount,
                            tdrFee : this.listFirstRowForAddCommercials[index2].tdrFee,
                            tdrPercentage : this.listFirstRowForAddCommercials[index2].tdrPercentage,
                            convenienceAmount : this.listFirstRowForAddCommercials[index2].convenienceAmount,
                            convenienceFee : this.listFirstRowForAddCommercials[index2].convenienceFee,
                            conveniencePercentage : this.listFirstRowForAddCommercials[index2].conveniencePercentage
                        };
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].isChecked = false;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.push(newInnerRecord); 
                    }
                }
            }
        }

        this.listFirstRowForAddCommercials = [];
        this.listDataForPaymentMode = [];
        this.selectetPaymentIndividualObject.key = this.selectedListPaymentData[this.index].paymentModeName;
        this.selectetPaymentIndividualObject.selectedPaymentOptionName = 'Set a default '+this.selectedListPaymentData[this.index].paymentModeName +' rate';
        this.selectetPaymentIndividualObject.selectedPaymentOptionId = '';
        this.selectetPaymentIndividualObject.selectedSpecification = '';
        this.selectetPaymentIndividualObject.selectedPaymentGatewayName = '';
        this.selectetPaymentIndividualObject.selectedOnusOffus = '';
        this.selectetPaymentIndividualObject.listFeeModel = this.listFeeModel;
        this.selectetPaymentIndividualObject.listTransactionType = this.listTransactionType;
        this.selectetPaymentIndividualObject.selectedFeeModel = 'Net';
        this.selectetPaymentIndividualObject.selectedTransactionType = 'TDR';
        this.selectetPaymentIndividualObject.isChecked = false;
        this.selectetPaymentIndividualObject.showCheckbox = true;
        this.selectetPaymentIndividualObject.showTDR = true;
        this.selectetPaymentIndividualObject.showConvenience = false;
        this.selectetPaymentIndividualObject.tdrAmount = '0';
        this.selectetPaymentIndividualObject.tdrFee = '';
        this.selectetPaymentIndividualObject.tdrPercentage = '';
        this.selectetPaymentIndividualObject.convenienceAmount = '0';
        this.selectetPaymentIndividualObject.convenienceFee = '';
        this.selectetPaymentIndividualObject.conveniencePercentage = '';
        this.listFirstRowForAddCommercials.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
        
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList;
        this.showScreen4 = true;
    }

    //this method is called on click of + icon from screen 4 other that first row
    addrowInListSecondRow(event) {
        this.showScreen4 = false;
        let index = this.index;
        let index1 = event.currentTarget.dataset.id;
        let index2 = event.currentTarget.dataset.key;
        let showTdr = false;
        let showCon = false;
        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'TDR') {
            showTdr = true;
        }
        else if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'Convenience') {
            showCon = true;    
        }
        else {
            showTdr = true;
            showCon = true;
        }
         
        var newInnerRecord = {
            key : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].key+'#'+(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length+1),
            selectedPaymentOptionName : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedPaymentOptionName,
            selectedPaymentOptionId : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedPaymentOptionId,
            selectedSpecification : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedSpecification,
            selectedPaymentGatewayName : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedPaymentGatewayName,
            selectedOnusOffus : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedOnusOffus,
            listFeeModel : this.listFeeModel,
            listTransactionType : this.listTransactionType,
            selectedFeeModel : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedFeeModel,
            selectedTransactionType : this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType,
            isChecked : false,
            showCheckbox : false,
            showTDR : showTdr,
            showConvenience : showCon,
            tdrAmount : '0',
            tdrFee : '',
            tdrPercentage : '',
            convenienceAmount : '0',
            convenienceFee : '',
            conveniencePercentage : ''
        };
        this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.push(newInnerRecord);
        this.listDataForPaymentMode = this.selectedListPaymentData[index].selectedPaymentOptionsList;
        this.showScreen4 = true;
    }

    //this method is called on change on change of tdr amount from screen 4 other than first row
    handleTDRAmountForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].tdrAmount = event.detail.value; 
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList;   
        this.showScreen4 = true;     
    }

    //this method is called on change on change of tdr fee from screen 4 other than first row
    handleTDRFeeForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].tdrFee = event.detail.value; 
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList; 
        this.showScreen4 = true;     
    }

    //this method is called on change on change of tdr percentage from screen 4 other than first row
    handleTDRPercentageForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].tdrPercentage = event.detail.value;   
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList;   
        this.showScreen4 = true;    
    }

    //this method is called on change on change of convenience amount from screen 4 other than first row
    handleConvenienceAmountForSecondRow(event) {
        this.showScreen4 = false; 
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].convenienceAmount = event.detail.value;
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList;  
        this.showScreen4 = true;        
    }

    //this method is called on change on change of convenience fee from screen 4 other than first row
    handleConvenienceFeeForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].convenienceFee = event.detail.value; 
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList; 
        this.showScreen4 = true;       
    }

    //this method is called on change on change of convenience percentage from screen 4 other than first row
    handleConveniencePercentageForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].conveniencePercentage = event.detail.value; 
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList; 
        this.showScreen4 = true;             
    }

    //this method is called on click of the Save Pricing button from Screen 4
    savePricing(event) {
        this.errorMessage = '';
        this.showErrorMessage = false;
        let validateData = true;
        let missingPaymentModes = [];
        let moreThanCeilingPaymentModes = [];
        for(let index=0; index < this.selectedListPaymentData.length; index++) {
            for(let index1=0; index1 < this.selectedListPaymentData[index].selectedPaymentOptionsList.length; index1++) {
                for(let index2=0; index2 < this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; index2++) {
                    if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'TDR') {
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee == '' && this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage == '') {
                            if(!missingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            //break;
                        }  
                        else {
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        }  
                    }
                    else if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'Convenience') {
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceFee == '' && this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].conveniencePercentage == '') {
                            if(!missingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            //break;
                        } 
                        else {
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        }
                    }
                    else {
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee == '' && this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage == '') {
                            if(!missingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            //break;
                        }
                        else {
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        } 
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceFee == '' && this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].conveniencePercentage == '') {
                            if(!missingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            //break;
                        } 
                        else {
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        }
                    }
                }    
            }
        }

        if(validateData) {
            for(let index=0; index < this.selectedListPaymentData.length; index++) {
                for(let index1=0; index1 < this.selectedListPaymentData[index].selectedPaymentOptionsList.length; index1++) {
                    for(let index2=0; index2 < this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; index2++) {
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'TDR') {
                            if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee > 150 || this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage > 6) {
                                if(!moreThanCeilingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                    moreThanCeilingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                                }
                                validateData = false;
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                                //break;
                            } 
                            else {
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                            }   
                        }
                        else if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'Convenience') {
                            if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceFee > 150 || this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].conveniencePercentage > 6) {
                                if(!moreThanCeilingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                    moreThanCeilingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                                }
                                validateData = false;
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                                //break;
                            } 
                            else {
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                            }
                        }
                        else {
                            if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee > 150 || this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage > 6) {
                                if(!moreThanCeilingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                    moreThanCeilingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                                }
                                validateData = false;
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                                //break;
                            } 
                            else {
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                            }
                            if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceFee > 150 || this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].conveniencePercentage > 6) {
                                if(!moreThanCeilingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                    moreThanCeilingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                                }
                                validateData = false;
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                                //break;
                            } 
                            else {
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                            }
                        }
                    }    
                }
            }
        }

        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        }); 
        
        if(validateData) {
            this.disabledSavePricingButton = true;
            this.showSpinner = true;
            console.log(JSON.stringify(this.selectedListPaymentData));
            savePricingApex({selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),recordId : this.recordId,commercialName : this.commercialName,selectedTemplate : this.selectedTemplate})
            .then(result => {
                if(result.message.includes('SUCCESS')) {
                    let message = result.message.split('#');
                    if(message.length == 3) {
                        this.showBelowRackRateMessage = true;
                        this.belowRackRateMessage = message[2];
                    }
                    //Added to show the data correctly after save
                    this.selectedListPaymentData = JSON.parse(result.selectedListPaymentData);
                    //End
                    this.showSpinner = false;
                    this.disabledSavePricingButton = false;
                    this.hideScreen3Step2 = 'display:none';
                    this.showScreen5 = true;
                    this.commercialId = result.message.split('#')[1];
                    this.pathNumber = '3';
                    this.disabledCommercialName = true;
                    this.showToast('SUCCESS','success','Pricing Records Created Successfully');
                }
                else {
                    this.showSpinner = false;
                    this.disabledSavePricingButton = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.disabledSavePricingButton = false;
                this.showToast('ERROR','error',error);   
            })
        }
        else {
            if(missingPaymentModes.length > 0) {
                this.showErrorMessage = true;
                this.errorMessage = 'Payment options missing price :  '+missingPaymentModes.toString();
            }

            if(moreThanCeilingPaymentModes.length > 0) {
                this.showErrorMessage = true;
                this.errorMessage = 'Payment options pricing more than cieling :  '+moreThanCeilingPaymentModes.toString();
            }
        }
    }

    //this method is called on click of the button - Save As Template
    saveAsTemplate(event) {
        let openModal = false;
        for(let i=0;i<this.listFixedPricing.length;i++) {
            if(this.listFixedPricing[i].amcFee == '') {
                openModal = true;    
            }
            if(this.listFixedPricing[i].amcInterval == '') {
                openModal = true;    
            }
            if(this.listFixedPricing[i].setupFee == '') {
                openModal = true;    
            }
            if(this.listFixedPricing[i].securityDeposit == '') {
                openModal = true;    
            }
        }
        if(openModal) {
            this.showFixedPricingModal = true;
        }
        else {
            this.showSaveAsTemplateModal = true;    
        }
        
    }

     //this method is called on click of the cancel button from Save As Template mnodal
    cancelShowTempalteModal(event) {
        this.showSaveAsTemplateModal = false;
        this.selectedPlanChoice = '';
        this.templateName = '';
    }

    //this method is called on change of the plan choice
    handleChangeSelectedPlanChoice(event) {
        this.selectedPlanChoice = event.detail.value;
    }

    //this method is called when - icon clicked from screen 4 and first/highlighed row 
    removeRowInListFirstRowForAddCommercials(event) {
        let index = event.currentTarget.dataset.id;
        this.listFirstRowForAddCommercials.splice(index, 1);
    }

    //this method is called when - icon clicked from screen 4 and other than highlighted rows
    removeRowInListSecondRow(event) {
        this.showScreen4 = false;
        let index1 = event.currentTarget.dataset.id;
        let index2 = event.currentTarget.dataset.key;
        let key = this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].key;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.splice(index2,1);
        for(let i = 1; i<this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; i++) {
            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[i].key = key + '#' +(i+1);    
        }
        this.listDataForPaymentMode = this.selectedListPaymentData[this.index].selectedPaymentOptionsList;
        this.showScreen4 = true;
    }

    //this method is called on click of the close icon from the error message Screen 4
    hideErrorMessage(event) {
        this.errorMessage = '';
        this.showErrorMessage = false;
    }

    //this method is called when Commercial name changes from the screen 4
    handleCommercialName(event) {
        this.commercialName = event.detail.value;
    }

    //this method is called on click of Publish Pricing from Screen 5
    publishPricing(event) {
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
                                amcFee : '',
                                amcInterval : '',
                                setupFee : '',
                                securityDeposit : ''
                            };
                            this.listFixedPricing.push(newInnerRecord);
                        }
                        this.showScreen5 = false;
                        this.showScreen6 = true;
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
                this.showToast('ERROR','error',error);
            })
    }

    //this method is called on click of the Back button
    back(event) {
        this.showScreen6 = false; 
        this.showScreen5 = true;
    }

    //this method is used to track changes in Setup Fee
    handleSetupFee(event) {
        this.listFixedPricing[event.currentTarget.dataset.id].setupFee = event.detail.value;   
    }

    //this method is used to track changes in Security Deposit
    handleSecurityDeposit(event) {
        this.listFixedPricing[event.currentTarget.dataset.id].securityDeposit = event.detail.value;   
    }

    //this method is used to track changes in Amc Fee
    handleAmcFee(event) {
        this.listFixedPricing[event.currentTarget.dataset.id].amcFee = event.detail.value;   
    }

    //this method is used to track changes in Amc Interval
    handleAmcInterval(event) {
        this.listFixedPricing[event.currentTarget.dataset.id].amcInterval = event.detail.value;   
    }

    //this method is called on click on Publish Button
    publishCommercial(event) {
        this.disabledPublishPricingButton = true;
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateNew');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        }); 
        if(validateData) {
            insertFixedPricingAndPublishCommercial({commercialId : this.commercialId,listFixedPricingString : JSON.stringify(this.listFixedPricing)})
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.hidePublishCommercialButton = true;        
                    this.showToast('SUCCESS','success','Publish pricing records started successfully');
                    this.disabledPublishPricingButton = false;
                }
                else {
                    this.showSpinner = false;
                    this.showToast('ERROR','error',result);
                    this.disabledPublishPricingButton = false;
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR','error',error);
                this.disabledPublishPricingButton = false;
            })      
        }
        else {
            this.disabledPublishPricingButton = false;
        }
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

    //this method is used to close modal for update below rack rates records screen
    closeModal(event) {
        this.openGovernanceModal = false;
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


    //this method is called on the click of the Commercial Name to get the pricing records from Screen 1
    getPlanRecordsForCommercial(event) {
        this.showSpinner = true;
        this.commercialId = event.currentTarget.dataset.id;
        let commercialNameTemp = event.currentTarget.dataset.key;
        getPricingRecordsForCommercial({commercialId : event.currentTarget.dataset.id,commercialName : event.currentTarget.dataset.key})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.showSpinner = false;
                this.selectedListPaymentData = JSON.parse(result.selectedListPaymentData);
                this.pathNumber = '3';
                //this.currentStep = '3';
                //this.showScreen5 = true;
                this.showThirdScreen = true;
                this.showFirstScreen = false;
                this.showSecondScreen = false;
                this.hideScreen3Step1 = 'display:none';
                this.hideScreen3Step2 = 'display:none';
                this.showBelowRackRateMessage = result.showBelowRackRateMessage;
                this.showBelowRackRateRecords = result.showBelowRackRateRecords;
                this.belowRackRateMessage = result.belowRackRateMessage;
                this.disabledBHButton = result.disabledBHButton;
                this.disabledCommercialName = true;
                this.commercialName = commercialNameTemp;
                if(result.status == 'Draft') {
                    this.showScreen5 = true;    
                }
                else if(result.status == 'Published') {
                    //To show data in new line
                    /*for(var i=0;i<this.selectedListPaymentData.length;i++) {
                        console.log('-->First Loop');
                        for(var j=0;j<this.selectedListPaymentData[i].selectedPaymentOptionsList.length;j++) {
                            console.log('-->Second Loop');
                            for(var k=0;k<this.selectedListPaymentData[i].selectedPaymentOptionsList[j].selectedPaymentIndividualList.length;k++) {
                                console.log('-->Third Loop');
                                console.log('Value-->'+this.selectedListPaymentData[i].selectedPaymentOptionsList[j].selectedPaymentIndividualList[k].status);
                                if(this.selectedListPaymentData[i].selectedPaymentOptionsList[j].selectedPaymentIndividualList[k].status.includes('(below rack rate)')) {
                                    console.log('--Includes Below Rack Rate');
                                    this.selectedListPaymentData[i].selectedPaymentOptionsList[j].selectedPaymentIndividualList[k].status = this.selectedListPaymentData[i].selectedPaymentOptionsList[j].selectedPaymentIndividualList[k].status.replace('(below rack rate)','\n(below rack rate)');
                                    console.log('value changes-->'+this.selectedListPaymentData[i].selectedPaymentOptionsList[j].selectedPaymentIndividualList[k].status);
                                }
                            }
                        } 
                    }*/
                    //end
                    this.showScreen6 = true;  
                    this.hidePublishCommercialButton = true;           
                }

                if(result.listFixedPricingString.length > 0) {
                    this.listFixedPricing =  JSON.parse(result.listFixedPricingString); 
                }
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
                this.bhAddress = result.bhAddress;
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

    //this method is called on the click of the Send Request button
    sendToBHEmail(event) {
        this.disabledSendRequestButton = true;
        this.openSendToBH = false; 
        this.showSpinner = true;
        sendToBHEmail({commercialId : this.commercialId,body:this.body,subject:this.subject,listPricingIds:this.belowRackRatesIds})
        .then(result =>{
            if(result.includes('SUCCESS')) {
                this.showSpinner = false;
                this.disabledSendRequestButton = false; 
                this.showToast('SUCCESS','success','An email has been sent to BH'); 
            }
            else {
                this.showSpinner = false;
                this.disabledSendRequestButton = false;
                this.showToast('ERROR','error',result);    
            }
        }) 
        .catch(error => {
            this.showSpinner = false;
            this.disabledSendRequestButton = false;
            this.showToast('ERROR','error',error[0]);
        })
    }

    //this method is called on the click of the Cancel button from Send to BH modal
    closeModalSendBH(event) {
        this.openSendToBH = false;    
    }

    //this method is used to track changes in body field
    updateBody(event) {
        this.body = event.detail.value;
    }

    //this method is called on click of Button chatter from Screen 7
    clickChatter(event) {
        let pricingId = event.currentTarget.dataset.id;
        let bankingOpsStatus = event.currentTarget.dataset.label;
        let bankName = event.currentTarget.dataset.info1;
        let porType =  event.currentTarget.dataset.info2;
        let currentUserProfileName = event.currentTarget.dataset.info3;
        OwnerAssignment({oppId :this.recordId,bankingOpsStatus:event.currentTarget.dataset.label,bankNameVal:event.currentTarget.dataset.info1})
        .then(result=>{
            var paramData = {pricingId :pricingId ,statusValues:this.statusPicklist.data.values,bankingOpsStatus:bankingOpsStatus,ownerAssignMent:result,bankNameVal:bankName,porType:porType,currUserProfileName:currentUserProfileName};
            let ev = new CustomEvent('childmethod',{detail : paramData});
            this.dispatchEvent(ev);   
        })
       .catch(error=>{
            alert(JSON.stringify(error[0]));     
       })
    }

    //this method is called on click of the Next Button from Create a template modal
    nextTemplateModal(event) {
        let validateData = true;
        this.templateName = '';
        let inputFields = this.template.querySelectorAll('.validateOption');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            if(this.selectedPlanChoice == 'option1') {
                if(this.isSuperUser) {
                    this.showSpinner = true;
                    getPrivateTemplateDetails()
                    .then(result => {
                        if(result.message.includes('SUCCESS')) {
                            this.showSpinner = false;
                            this.availablePrivateTemplate = JSON.parse(result.jsonPlanMaster);
                            this.superUserUpdateTemplate = true; 
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
                else {
                    this.showSpinner = true;
                    getPrivateTemplateDetails()
                    .then(result => {
                        if(result.message.includes('SUCCESS')) {
                            this.showSpinner = false;
                            this.availablePrivateTemplate = JSON.parse(result.jsonPlanMaster);
                            this.ordinaryUserUpdateTemplate = true; 
                            this.ordinaryUserCreateTemplate = false;
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
            }
            else if(this.selectedPlanChoice == 'option2') {
                if(this.isSuperUser) {
                    this.showSpinner = true;
                    getPlanAndSubPlanDetails()
                    .then(result => {
                        if(result.message.includes('SUCCESS')) {
                            this.showSpinner = false;
                            this.availablePlanMaster = JSON.parse(result.jsonPlanMaster);
                            this.availableSubPlanMaster = JSON.parse(result.jsonSubPlanMaster);
                            this.superUserChooseExistingPlanSunPlanCreateNewTemplate = true; 
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
                else {
                    this.ordinaryUserCreateTemplate = true; 
                    this.ordinaryUserUpdateTemplate = false;    
                }
            }
            else if(this.selectedPlanChoice == 'option3' && this.isSuperUser) {
                this.availablePrivateTemplate = [];
                this.templateName = '';
                this.showSpinner = true;
                getPrivateTemplateDetails()
                .then(result => {
                    if(result.message.includes('SUCCESS')) {
                        this.showSpinner = false;
                        this.availablePrivateTemplate = JSON.parse(result.jsonPlanMaster);
                        this.superUserCreatePlanSunPlanUpdateTemplate = true; 
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
            else if(this.selectedPlanChoice == 'option4' && this.isSuperUser) {
                this.superUserCreatePlanSunPlanTemplate = true;
            }
        }
    }

    //this method is called on change of the Template Name from Create template for Ordinary User
    handleTemplateName(event) {
        this.templateName = event.detail.value;
        if(this.isSuperUser && (this.superUserCreatePlanSunPlanUpdateTemplate || this.superUserUpdateTemplate)) {
            this.showSpinner = true;
            getPublicCheckboxForTemplate({templateId : this.templateName})
            .then(result => {
                this.showSpinner = false;
                this.publicTemplateCheckbox = result;
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR','error',error);
            })
        }
    }

    //this method is called on click of the Cancel from the Cancel button from the create template for ordinary user
    cancelOrdinaryUserCreateTemplate(event) {
        this.ordinaryUserCreateTemplate = false; 
        this.ordinaryUserUpdateTemplate = false;    
        this.showSaveAsTemplateModal = false; 
        this.templateName = '';
        this.selectedPlanChoice = '';
    }

    //this method is called on click of Back button from create new plan for oridnary user
    backButton(event) {
        this.ordinaryUserCreateTemplate = false;
        this.ordinaryUserUpdateTemplate = false;  
        this.showSaveAsTemplateModal = true;
    }

    //this method is called from the Save button from the create template for the ordinary user
    saveOrdinaryUserNewTemplate(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateNewPlanOUser');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            this.disabledSaveCreateTemplateOrdinaryUser = true;
            this.showSpinner = true;
            createTemplateForOrdinaryUser({templateName : this.templateName,selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),listFixedPricingString : JSON.stringify(this.listFixedPricing),commercialId : this.commercialId})
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.disabledSaveCreateTemplateOrdinaryUser = false;
                    this.ordinaryUserCreateTemplate = false;
                    this.ordinaryUserUpdateTemplate = false;
                    this.showSaveAsTemplateModal = false;
                    this.templateName = '';
                    this.showToast('SUCCESS','success','Data saved as Template successfully');
                }
                else {
                    this.showSpinner = false;
                    this.disabledSaveCreateTemplateOrdinaryUser = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.disabledSaveCreateTemplateOrdinaryUser = false;
                this.showToast('ERROR','error',error);   
            })
        }
    }

    //this button is called from the Back button from all modal for the Super users
    backButtonSuperUser(event) {
        this.superUserUpdateTemplate = false;
        this.showSaveAsTemplateModal = true;
        this.superUserChooseExistingPlanSunPlanCreateNewTemplate = false;
        this.templateName = '';
        this.selectedSubPlanName = '';
        this.selectedPlanName = '';
        this.publicTemplateCheckbox = false;
        this.superUserCreatePlanSunPlanUpdateTemplate = false;
        this.superUserCreatePlanSunPlanTemplate = false;
    }

    //this button is called from the Cancel button from all modal for the Super users
    cancelSuperUser(event) {
        this.superUserUpdateTemplate = false;
        this.showSaveAsTemplateModal = false;
        this.superUserChooseExistingPlanSunPlanCreateNewTemplate = false;
        this.templateName = '';
        this.selectedSubPlanName = '';
        this.selectedPlanName = '';
        this.publicTemplateCheckbox = false;
        this.superUserCreatePlanSunPlanUpdateTemplate = false;
        this.superUserCreatePlanSunPlanTemplate = false;
        this.selectedPlanChoice = '';
    }

    //this method is called from the Save from the super user modal for update exisiting template
    saveUpdateTemplateSuperUser(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateOption1');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            this.showSpinner = true;
            this.disabledOption1Save = true;
            createTemplateForSuperUser({templateName : this.templateName,selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),listFixedPricingString : JSON.stringify(this.listFixedPricing),commercialId : this.commercialId,publicTemplateCheckbox : this.publicTemplateCheckbox,planName : this.selectedPlanName,subPlanName : this.selectedSubPlanName,action : 'option1'})
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.disabledOption1Save = false;
                    this.superUserUpdateTemplate = false;
                    this.showSaveAsTemplateModal = false;
                    this.templateName = '';
                    this.publicTemplateCheckbox = false;
                    this.selectedPlanName = '';
                    this.selectedSubPlanName = '';
                    this.selectedPlanChoice = '';
                    this.showToast('SUCCESS','success','Data saved as Template successfully');
                }
                else {
                    this.showSpinner = false;
                    this.disabledOption1Save = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.disabledOption1Save = false;
                this.showToast('ERROR','error',error);   
            })
        }
    }

    //this method is called on save from Choose existing plan, sub plan and create new template
    saveCreateNewTemplateOption2(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateOption2');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            this.showSpinner = true;
            this.disabledOption2Save = true;
            createTemplateForSuperUser({templateName : this.templateName,selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),listFixedPricingString : JSON.stringify(this.listFixedPricing),commercialId : this.commercialId,publicTemplateCheckbox : this.publicTemplateCheckbox,planName : this.selectedPlanName,subPlanName : this.selectedSubPlanName,action : 'option2'})
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.disabledOption2Save = false;
                    this.superUserChooseExistingPlanSunPlanCreateNewTemplate = false;
                    this.showSaveAsTemplateModal = false;
                    this.templateName = '';
                    this.publicTemplateCheckbox = false;
                    this.selectedPlanName = '';
                    this.selectedSubPlanName = '';
                    this.selectedPlanChoice = ''; 
                    this.showToast('SUCCESS','success','Data saved as Template successfully');
                }
                else {
                    this.showSpinner = false;
                    this.disabledOption4Save = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.disabledOption4Save = false;
                this.showToast('ERROR','error',error);   
            })
        }
    }

    //this method is called on click of Save from option 3 Super User
    saveCreateNewTemplateOption3(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateOption3');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            this.showSpinner = true;
            this.disabledOption3Save = true;
            createTemplateForSuperUser({templateName : this.templateName,selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),listFixedPricingString : JSON.stringify(this.listFixedPricing),commercialId : this.commercialId,publicTemplateCheckbox : this.publicTemplateCheckbox,planName : this.selectedPlanName,subPlanName : this.selectedSubPlanName,action : 'option3'})
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.disabledOption3Save = false;
                    this.superUserCreatePlanSunPlanUpdateTemplate = false;
                    this.showSaveAsTemplateModal = false;
                    this.templateName = '';
                    this.publicTemplateCheckbox = false;
                    this.selectedPlanName = '';
                    this.selectedSubPlanName = '';
                    this.selectedPlanChoice = '';
                    this.showToast('SUCCESS','success','Data saved as Template successfully');
                }
                else {
                    this.showSpinner = false;
                    this.disabledOption3Save = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.disabledOption3Save = false;
                this.showToast('ERROR','error',error);   
            })
        }
    }

    //this method is called on click of Save option 4 Super user
    saveCreateNewTemplateOption4(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateOption4');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            this.showSpinner = true;
            this.disabledOption4Save = true;
            createTemplateForSuperUser({templateName : this.templateName,selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),listFixedPricingString : JSON.stringify(this.listFixedPricing),commercialId : this.commercialId,publicTemplateCheckbox : this.publicTemplateCheckbox,planName : this.selectedPlanName,subPlanName : this.selectedSubPlanName,action : 'option4'})
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.disabledOption4Save = false;
                    this.superUserCreatePlanSunPlanTemplate = false;
                    this.showSaveAsTemplateModal = false;
                    this.templateName = '';
                    this.publicTemplateCheckbox = false;
                    this.selectedPlanName = '';
                    this.selectedSubPlanName = '';
                    this.selectedPlanChoice = '';
                    this.showToast('SUCCESS','success','Data saved as Template successfully');
                }
                else {
                    this.showSpinner = false;
                    this.disabledOption4Save = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.disabledOption4Save = false;
                this.showToast('ERROR','error',error);   
            })
        }    
    }


    //this method is called on change of Plan Name
    handlePlanName(event) {
        this.selectedPlanName = event.detail.value;
    }

    //this method is called on change of Sub Plan Name
    handleSubPlanName(event) {
        this.selectedSubPlanName = event.detail.value;
    }

    //this method is called on change of the checkbox
    handlePublicTemplateCheckbox(event) {
        if(this.publicTemplateCheckbox) {
            this.publicTemplateCheckbox = false;
        }
        else {
            this.publicTemplateCheckbox = true;
        }
    }

    redirectToHome(event) {
        /*
        this.showRedirectToHomeModal = false;
        this.showSpinner = true;
        this.showFirstScreen = true;
        this.showSecondScreen = false;
        this.showThirdScreen = false;
        this.hideScreen3Step1 = 'display:none';
        this.hideScreen3Step2 = 'display:none';
        this.showScreen5 = false;
        this.showScreen6 = false;
        this.openGovernanceModal = false;
        this.openSendToBH = false;
        this.showSaveAsTemplateModal = false;
        this.ordinaryUserCreateTemplate = false;
        this.ordinaryUserUpdateTemplate = false;
        this.showFixedPricingModal = false;
        this.superUserUpdateTemplate = false;
        this.superUserChooseExistingPlanSunPlanCreateNewTemplate = false;
        this.superUserCreatePlanSunPlanUpdateTemplate = false;
        this.superUserCreatePlanSunPlanTemplate = false;
        this.showSpinner = false; 
        this.hideScreen3Step1 = 'display:block';
        this.commercialName = '';
        this.disabledCommercialName = false;
        this.hidePublishCommercialButton = false;
        this.listFixedPricing = [];
        this.showErrorMessage = false;
        this.errorMessage = '';
        this.selectedListPaymentData = [];
        this.listPaymentData = [];
        */

        this.showRedirectToHomeModal = false;
        this.showFirstScreen = true;
        this.showSpinner = false;
        this.availablePlanMaster = [];
        this.showSecondScreen = false;
        this.selectedPlan = '';
        this.selectedSubPlan = '';
        this.selectedTemplate = '';
        this.availableSubPlanMaster = [];
        this.availableTemplateMaster = [];
        this.disabledAddPaymentPlan = true;
        this.showThirdScreen = false;
        this.listPaymentData = [];
        this.selectedListPaymentData = [];
        this.currentStep = 1;
        this.hideScreen3Step1 = 'display:block';
        this.hideScreen3Step2 = 'display:none';
        this.listDataForPaymentMode = [];
        this.paymentModeName = '';
        this.listFeeModel = [];
        this.listTransactionType = [];
        this.index = 0;
        this.listFirstRowForAddCommercials = [];
        this.showScreen4 = false;
        this.disabledSavePricingButton = false;
        this.disabledSaveAsTemplateButton = false;
        this.showSaveAsTemplateModal = false;
        this.planChoiceOptions = [];
        this.selectedPlanChoice = '';
        this.showErrorMessage = false;
        this.errorMessage = '';
        this.commercialName = '';
        this.pathNumber = 1;
        this.showScreen5 = false;
        this.commercialId = '';
        this.disabledPublishPricingButton = false;
        this.listExistingCommercial = [];
        this.showCommercial = false;
        this.showBelowRackRateMessage = false;
        this.belowRackRateMessage = '';
        this.disabledUpdatePricingButton = false;
        this.openGovernanceModal = false;
        this.belowRackRatesRecords = [];
        this.belowRackRatesIds = [];
        this.showBelowRackRateRecords = false;
        this.disabledBHButton = true;
        this.openSendToBH = false;
        this.bhAddress = '';
        this.subject = '';
        this.body = '';
        this.disabledSendRequestButton = false;
        this.showScreen6 = false;
        this.listFixedPricing = [];
        this.hidePublishCommercialButton = false;
        this.disabledPublishPricingButton = false;
        this.mapTDRConvenienceData = new Map();
        this.showFixedPricingModal = false;
        this.isSuperUser = false;
        this.ordinaryUserCreateTemplate = false; 
        this.ordinaryUserUpdateTemplate = false;
        this.templateName = ''; 
        this.disabledSaveCreateTemplateOrdinaryUser = false;
        this.availablePrivateTemplate = [];
        this.superUserUpdateTemplate = false;
        this.publicTemplateCheckbox = false;
        this.availablePlanMaster = [];
        this.availableSubPlanMaster = [];
        this.superUserChooseExistingPlanSunPlanCreateNewTemplate = false;
        this.selectedSubPlanName = '';
        this.selectedPlanName = '';
        this.disabledOption1Save = false;
        this.disabledOption2Save = false;
        this.superUserCreatePlanSunPlanUpdateTemplate = false;
        this.disabledOption3Save = false;
        this.superUserCreatePlanSunPlanTemplate = false;
        this.disabledOption4Save = false;
        this.showRedirectToHomeModal = false;
        this.disabledCommercialName = false;
        this.onLoadFunction();

    }

    cancelRedirectToHomeModal(event) {
        this.showRedirectToHomeModal = false;
    }

    redirectToHomeOpenModal(event) {
        this.showRedirectToHomeModal = true;
    }


    //this method is called on click of Live Commercials
    handleLiveCommercialActive(event) {
        this.showSpinner = true;
        this.selectedListPaymentDataLiveFromTreasury = [];
        getLiveDetailsFromTreasury({recordId : this.recordId})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.selectedListPaymentDataLiveFromTreasury = JSON.parse(result.selectedListPaymentDataLiveFromTreasury);
                this.showSpinner = false;
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

    //this method is called on the click of the edit commercial from the Ist screem
    handleEditCommercial(event) {
        this.showSpinner = true;
        this.commercialId = event.currentTarget.dataset.id;
        this.commercialName = event.currentTarget.dataset.key;
    }
    
}