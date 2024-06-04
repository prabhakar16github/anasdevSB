import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPaymentDetails from '@salesforce/apex/PricingModuleComponentController.getPaymentDetails';
import getPlanDetails from '@salesforce/apex/PricingModuleComponentController.getPlanDetailsOnLoad';
import getOverallAuditTrail from '@salesforce/apex/PricingModuleComponentController.getOverallAuditTrail';
import getOverallOtherAuditTrail from '@salesforce/apex/PricingModuleComponentController.getOverallAuditForStackTrail';
import getExistingRecords from '@salesforce/apex/TreasuryApiForPaasController.getExistingRecords';
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
    @track currentStep = 1;
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
    showLiveCommercial = false;
    showScreen3Step1 = false;
    showScreen3Step2 = false;
    showScreen3Step1Block = 'display:none';
    showScreen3Step2Block = 'display:none';

    @track listFallbackCharges = [];
    @track listPlatformFee = [];
    @track listFixedPricing2 = [];
    availableInterval = [];
    availableType = [];
    selectedType = '';
    selectedInterval = '';
    selectedStartDate;
    selectedEndDate;
    selectedDebitModel = '';
    availableDebitModel = [];
    availableDebitModelFP = [];
    availableIntervalFP = [];

    showInstantSettlement = false;
    showOfferEngine = false;
    showCheckOut = false;
    @track SelectedPaymentOptionObject = {
        paymentModeId: '',
        paymentModeName: '',
        selectedPaymentOptionsList: [],
        styleClass: 'background:#F2F8FF'
    }

    @track SelectedPaymentOptionIndividualListObject = {
        key: '',
        selectedPaymentIndividualList: [],
        restrictTransactionTypeAndFeeModel : false
    }

    @track selectetPaymentIndividualObject = {
        key: '',
        selectedPaymentOptionName: '',
        selectedPaymentOptionId: '',
        selectedSpecification: '',
        selectedPaymentGatewayName: '',
        selectedOnusOffus: '',
        isChecked: false,
        listFeeModel: [],
        selectedFeeModel: '',
        listTransactionType: [],
        selectedTransactionType: '',
        showCheckbox: true,
        showTDR: true,
        showConvenience: false,
        tdrAmount: '0',
        tdrFee: '',
        tdrPercentage: '',
        convenienceAmount: '0',
        convenienceFee: '',
        conveniencePercentage: '',
        backgroundColor: 'background-color:white;',
        pricingId: '',
        restrictFlatFeeAndPercentageToBeEdited : false,
        restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited : false,
        ruleStatus : 'D'
    }

    listAuditTrailOverall = [];
    listOtherAuditTrailOverall = [];
    //this method is called when the component load
    connectedCallback() {
        this.onLoadFunction();
    }

    //this method is called from the connected callback and redirect to home button
    onLoadFunction() {
        alert('calling onload');
        this.showFirstScreen = true;
    }

    getPlanDetailsParent(event) {
        this.isSuperUser = event.detail.isSuperUser;
        this.planChoiceOptions = event.detail.planChoiceOptions;
        this.listExistingCommercial = event.detail.listExistingCommercial;
        this.showCommercial = event.showCommercial;
        this.showSecondScreen = true;
        this.showFirstScreen = false;
        this.availableInterval = event.detail.availableInterval;
        this.availableType = event.detail.availableType;
        this.availableDebitModel = event.detail.availableDebitModel;
        this.availableIntervalFP = event.detail.availableIntervalFP;
        this.availableDebitModelFP = event.detail.availableDebitModelFP;
    }

    handleThirdScreenParent(event) {
        this.listFixedPricing = event.detail.listFixedPricing;
        this.mapTDRConvenienceData = event.detail.mapTDRConvenienceData;
        this.selectedTemplate = event.detail.selectedTemplate;
        this.listPaymentData = event.detail.listPaymentData;
        this.listFeeModel = event.detail.listFeeModel;
        this.listTransactionType = event.detail.listTransactionType;
        this.showThirdScreen = true;
        this.showScreen3Step1 = true;
        this.showScreen3Step1Block = 'display:block';
        this.showSecondScreen = false;
        this.showFirstScreen = false;

        this.listFallbackCharges = event.detail.listFallbackCharges;
        this.listPlatformFee = event.detail.listPlatformFee;
        this.listFixedPricing2 = event.detail.listFixedPricing2;
        this.selectedInterval = event.detail.selectedInterval;
        this.selectedType = event.detail.selectedType;
        this.selectedStartDate = event.detail.selectedStartDate;
        this.selectedEndDate = event.detail.selectedEndDate;
        this.selectedDebitModel = event.detail.selectedDebitModel;

    }

    handleThirdScreenParentStep2(event) {
        this.selectedListPaymentData = event.detail.selectedListPaymentData;
        this.listPaymentData = event.detail.listPaymentData;
        //1 = false;
        this.showScreen3Step1Block = 'display:none';
        this.showScreen3Step2 = true;
        this.showScreen3Step2Block = 'display:block';

    }

    handleFifthScreenParent(event) {
        this.selectedListPaymentData = event.detail.selectedListPaymentData;
        this.showBelowRackRateMessage = event.detail.showBelowRackRateMessage;
        this.belowRackRateMessage = event.detail.belowRackRateMessage;
        this.commercialId = event.detail.commercialId;
        this.disabledCommercialName = event.detail.disabledCommercialName;
        this.showScreen3Step2 = false;
        this.showScreen3Step2Block = 'display:none';
        this.showScreen5 = true;
        this.showThirdScreen = false;
        this.listFallbackCharges = event.detail.listFallbackCharges;
        this.listFixedPricing2 = event.detail.listFixedPricing2;
        this.listPlatformFee = event.detail.listPlatformFee;
        this.availableInterval = event.detail.availableInterval;
        this.availableType = event.detail.availableType;
        this.selectedInterval = event.detail.selectedInterval;
        this.selectedType = event.detail.selectedType;
        this.selectedDebitModel = event.detail.selectedDebitModel;
        this.selectedStartDate = event.detail.selectedStartDate;
        this.selectedEndDate = event.detail.selectedEndDate;
        this.availableDebitModel = event.detail.availableDebitModel;
        this.availableIntervalFP = event.detail.availableIntervalFP;
        this.availableDebitModelFP = event.detail.availableDebitModelFP;
    }

    handleSixthScreenParent(event) {
        this.selectedListPaymentData = event.detail.selectedListPaymentData;
        this.listFixedPricing = event.detail.listFixedPricing;
        this.showScreen6 = true;
        this.showScreen5 = false;
    }

    editCommercialParent(event) {
        this.commercialId = event.detail.commercialId;
        this.commercialName = event.detail.commercialName;
        this.disabledCommercialName = event.detail.disabledCommercialName;
        this.availableInterval = event.detail.availableInterval;
        this.availableType = event.detail.availableType;
        this.availableDebitModel = event.detail.availableDebitModel;
        this.availableIntervalFP = event.detail.availableIntervalFP;
        this.availableDebitModelFP = event.detail.availableDebitModelFP;
        this.planChoiceOptions = event.detail.planChoiceOptions;
        this.showSpinner = true;
        getPaymentDetails({ templateId: '', commercialId: this.commercialId })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    if(!result.editAllowed) {
                        this.showSpinner = false;
                        this.showToast('INFO', 'info', 'Commercial can not be edit at this time. Some request are still processing.');
                        return;
                    }
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

                    getPlanDetails()
                        .then(result => {
                            if (result.message.includes('SUCCESS')) {
                                this.availablePlanMaster = JSON.parse(result.jsonPlanMaster);
                                this.listFeeModel = result.listFeeModel;
                                this.listTransactionType = result.listTransactionType;
                                this.showThirdScreen = true;
                                this.showFirstScreen = false;
                                this.showSecondScreen = false;
                                this.showScreen3Step1 = true;
                                this.showScreen3Step1Block = 'display:block';
                                this.availableType = result.listPlatformFeeType;
                                this.availableInterval = result.listPlatformFeeInterval;
                                this.availableDebitModel = result.listPlatformFeeDebitModel;
                                this.availableIntervalFP = result.listFixedPricingFeeInterval;
                                this.availableDebitModelFP = result.listFixedFeeDebitModel;
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

    //Method to show Toast Message on the UI
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleChatterParent(event) {
        let ev = new CustomEvent('childmethod', { detail: event.detail });
        this.dispatchEvent(ev);

    }

    validateCommercialName(event) {
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
            }
        });
    }

    redirectToRespectiveScreen(event) {
        this.selectedListPaymentData = event.detail.selectedListPaymentData;
        this.showBelowRackRateMessage = event.detail.showBelowRackRateMessage;
        this.showBelowRackRateRecords = event.detail.showBelowRackRateRecords;
        this.belowRackRateMessage = event.detail.belowRackRateMessage;
        this.disabledBHButton = event.detail.disabledBHButton;
        this.disabledCommercialName = true;
        this.commercialName = event.detail.commercialName;
        this.listFixedPricing = event.detail.listFixedPricing;
        this.listFallbackCharges = event.detail.listFallbackCharges;
        this.listFixedPricing2 = event.detail.listFixedPricing2;
        this.listPlatformFee = event.detail.listPlatformFee;
        this.selectedInterval = event.detail.selectedInterval;
        this.selectedType = event.detail.selectedType;
        this.selectedStartDate = event.detail.selectedStartDate;
        this.selectedEndDate = event.detail.selectedEndDate;
        this.selectedDebitModel = event.detail.selectedDebitModel;
        this.commercialId = event.detail.commercialId;
        this.isSuperUser = event.detail.isSuperUser;
        this.planChoiceOptions = event.detail.planChoiceOptions;
        this.listExistingCommercial = event.detail.listExistingCommercial;
        this.availableInterval = event.detail.availableInterval;
        this.availableType = event.detail.availableType;
        this.availableDebitModel = event.detail.availableDebitModel;
        this.availableIntervalFP = event.detail.availableIntervalFP;
        this.availableDebitModelFP = event.detail.availableDebitModelFP;
        this.showCommercial = event.detail.showCommercial;
        if (event.detail.respectiveScreen == 'Draft') {
            this.showScreen5 = true;
            this.showFirstScreen = false;
            this.currentStep = 2;
        }
        else {
            this.hidePublishCommercialButton = true;
            this.showScreen6 = true;
            this.showFirstScreen = false;
            this.currentStep = 3;
        }
    }

    //Method called on click of the Custom Lightning Path
    showRespectiveScreen(event) {
        if (this.showScreen3Step1 && this.showScreen3Step1Block == 'display:block') {
            if (event.target.value == 2) {
                this.template.querySelector("c-All-And-Selected-Payment-Options-Component").screen3Step2Show();
                return;
            }

            if (event.target.value == 3) {
                this.showToast('INFO', 'info', 'Please add Commercials first');
                return;
            }
        }
        else if (this.showScreen3Step2 && this.showScreen3Step2Block == 'display:block') {
            if (event.target.value == 1) {
                //this.showScreen3Step1 = true;
                this.showScreen3Step1Block = 'display:block';
                this.showScreen3Step2 = false;
                this.showScreen3Step2Block = 'display:none';
            }

            if (event.target.value == 3) {
                this.showToast('INFO', 'info', 'Please add Commercials first');
                return;
            }
        }
        else if (this.showScreen5) {
            if (event.target.value == 1 || event.target.value == 2) {
                this.showToast('INFO', 'info', 'You can not go to previous steps');
                return;
            }

            if (event.target.value == 3) {
                this.template.querySelector("c-goverence-component").publishPricing();
                return;
            }
        }
        else if (this.showScreen6) {
            if (event.target.value == 1 || event.target.value == 2) {
                this.showToast('INFO', 'info', 'You can not go to previous steps');
                return;
            }
        }
        this.currentStep = event.target.value;
    }

    handleBackParent(event) {
        this.listFixedPricing = event.detail.listFixedPricing;
        this.listFallbackCharges = event.detail.listFallbackCharges;
        this.listFixedPricing2 = event.detail.listFixedPricing2;
        this.listPlatformFee = event.detail.listPlatformFee;
        this.selectedInterval = event.detail.selectedInterval;
        this.selectedType = event.detail.selectedType;
        this.selectedStartDate = event.detail.selectedStartDate;
        this.selectedEndDate = event.detail.selectedEndDate;
        this.selectedDebitModel = event.detail.selectedDebitModel;
        this.showScreen6 = false;
        this.showScreen5 = true;
    }

    //this method is called when Commercial name changes from the screen 4
    handleCommercialName(event) {
        this.commercialName = event.detail.value;
    }

    redirectToHome(event) {
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
        this.showScreen3Step1Block = 'display:none';
        this.showScreen3Step2Block = 'display:none';
        this.showScreen3Step1 = false;
        this.showScreen3Step2 = false;
        this.listFallbackCharges = [];
        this.listFixedPricing2 = [];
        this.listPlatformFee = [];
        this.availableInterval = [];
        this.availableIntervalFP = [];
        this.availableType = [];
        this.availableDebitModel = [];
        this.availableDebitModelFP = [];
        this.selectedStartDate;
        this.selectedEndDate;
        this.selectedDebitModel = '';
        this.selectedInterval = '';
        this.selectedType = '';
        this.listAuditTrailOverall = [];
        this.listOtherAuditTrailOverall = [];
        this.onLoadFunction();

    }

    cancelRedirectToHomeModal(event) {
        this.showRedirectToHomeModal = false;
    }

    redirectToHomeOpenModal(event) {
        this.showRedirectToHomeModal = true;
    }


    handleLiveCommercialActive(event) {
        this.showLiveCommercial = true;
        this.showInstantSettlement = false;
        this.showOfferEngine = false;
        this.showCheckOut = false;
    }

    handleAllCommercialsActive(event) { 
        this.showLiveCommercial = false;
        this.showInstantSettlement = false;
        this.showOfferEngine = false;
        this.showCheckOut = false;
    }

    handleAuditTrailActive(event) {
        this.showLiveCommercial = false;
        this.showInstantSettlement = false;
        this.showOfferEngine = false;
        this.showCheckOut = false;
        this.listAuditTrailOverall = [];
        this.showSpinner = true;
        getOverallAuditTrail({opportunityId : this.recordId})
            .then(result => {
                if (result.length > 0) {
                    this.listAuditTrailOverall = result;
                    this.showSpinner = false;
                }
                else {
                    this.showSpinner = false;
                    this.showToast('Info', 'info', 'No Commercial found for this merchant');    
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })

    }
    // added by rohit
    handleOtherAuditTrailActive(event) {
        this.showLiveCommercial = false;
        this.showInstantSettlement = false;
        this.showOfferEngine = false;
        this.showCheckOut = false;
        this.listOtherAuditTrailOverall = [];
        this.showSpinner = true;
        getOverallOtherAuditTrail({opportunityId : this.recordId})
            .then(result => {
                if (result.length > 0) {
                    this.listOtherAuditTrailOverall = result;
                    this.showSpinner = false;
                }
                else {
                    this.showSpinner = false;
                    this.showToast('Info', 'info', 'No Commercial found for this merchant');    
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })

    }

    handleOtherProductsCommercial(event) {
        this.showInstantSettlement = true;
        this.showOfferEngine = false;
        this.showCheckOut = false;
        getExistingRecords({recordId : this.recordId})
    }

    handleInstantSettlementProduct(event) {
        this.showInstantSettlement = true; 
        this.showOfferEngine = false;
        this.showCheckOut = false;
    }

    handleOfferEngineProduct(event) {
        this.showInstantSettlement = false; 
        this.showOfferEngine = true;
        this.showCheckOut = false;
    }

    handleCheckoutExpressProduct(event) {
        this.showCheckOut = true;    
        this.showInstantSettlement = false; 
        this.showOfferEngine = false;
    }
    

    /*handleSDKProduct(event) {
        alert('handleSDKProduct');
        this.showInstantSettlement = false; 
    }*/

    handleTokenProduct(event) {
        alert('handleTokenProduct');
        this.showInstantSettlement = false; 
    }

    handleUPIProduct(event) {
        alert('handleUPIProduct');
        this.showInstantSettlement = false; 
    }

    handleEMIProduct(event) {
        alert('handleEMIProduct');
        this.showInstantSettlement = false; 
    }

    handleWalletsProduct(event) {
        alert('handleWalletsProduct');
        this.showInstantSettlement = false; 
    }

}