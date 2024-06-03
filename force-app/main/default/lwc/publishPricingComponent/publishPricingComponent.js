import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertFixedPricingAndPublishCommercial from '@salesforce/apex/PricingModuleComponentController.insertFixedPricingAndPublishCommercial';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRICING_OBJECT from '@salesforce/schema/Pricing__c';
import status from '@salesforce/schema/Pricing__c.Status__c';
import OwnerAssignment from '@salesforce/apex/BankingOpsModuleController.OwnerAssignmentLogic';
import getPrivateTemplateDetails from '@salesforce/apex/PricingModuleComponentController.getPrivateTemplateDetails';
import createTemplateForOrdinaryUser from '@salesforce/apex/PricingModuleComponentController.createTemplateForOrdinaryUser';
import getPublicCheckboxForTemplate from '@salesforce/apex/PricingModuleComponentController.getPublicCheckboxForTemplate';
import getPlanAndSubPlanDetails from '@salesforce/apex/PricingModuleComponentController.getPlanAndSubPlanDetails';
import createTemplateForSuperUser from '@salesforce/apex/PricingModuleComponentController.createTemplateForSuperUser';
import getSubPlanDetailsForSelectedPlan from '@salesforce/apex/PricingModuleComponentController.getSubPlanDetailsForSelectedPlan';
import getPrivateTemplateDetailsForPlanAndSubPlan from '@salesforce/apex/PricingModuleComponentController.getPrivateTemplateDetailsForPlanAndSubPlan';
import getModalInformation from '@salesforce/apex/PricingModuleComponentController.getModalInformation';
import getFixedPricing from '@salesforce/apex/PricingModuleComponentController.getFixedPricing';

export default class PublishPricingComponent extends LightningElement {
    @wire(getObjectInfo, { objectApiName: PRICING_OBJECT })
    pricingMetadata;
    showSpinner = true;
    @api hidePublishCommercialButton = false;
    disabledSaveAsTemplateButton = false;
    disabledPublishPricingButton = false;
    @api listFixedPricingTemporary = [];
    @track listFixedPricing = [];

    @api listFallbackChargesTemporary = [];
    @track listFallbackCharges = [];
    @api listFixedPricing2Temporary = [];
    @track listFixedPricing2 = [];
    @api listPlatformFeeTemporary = [];
    @track listPlatformFee = [];
    @api availableInterval = [];
    @api availableType = [];
    @api selectedType = '';
    @api selectedInterval = '';
    @api selectedStartDate;
    @api selectedEndDate;
    @api selectedDebitModel = '';
    @api availableDebitModel = [];
    @api availableIntervalFP = [];
    @api availableDebitModelFP = [];


    @api selectedListPaymentData = [];
    showSaveAsTemplateModal = false;
    @api planChoiceOptions = [];
    selectedPlanChoice = '';
    ordinaryUserCreateTemplate = false; 
    @api templateName = ''; 
    @api commercialId = '';
    disabledSaveCreateTemplateOrdinaryUser = false;
    ordinaryUserUpdateTemplate = false;
    availablePrivateTemplate = [];
    disabledSaveCreateTemplateOrdinaryUser = false;
    superUserUpdateTemplate = false;
    publicTemplateCheckbox = false;
    superUserChooseExistingPlanSunPlanCreateNewTemplate = false;
    selectedPlanName = '';
    availablePlanMaster = [];
    selectedSubPlanName = '';
    availableSubPlanMaster = [];
    superUserCreatePlanSunPlanUpdateTemplate = false;
    superUserCreatePlanSunPlanTemplate = false;
    superUserChooseExistingPlanCreateNewSubPlanAndTemplate = false;
    disabledOption1Save = false;
    disabledOption2Save = false;
    disabledOption3Save = false;
    disabledOption4Save = false;
    disabledOption5Save = false;
    @api isSuperUser = false;
    showFixedPricingModal = false;
    @api recordId = '';
    showPublishConfirmationModal = false;
    listFallback1 = [];
    listFallback2 = [];

    @track enableAddFixedPricingButton = true;

    showModalInformation = {
        message : '',
        showModal : false,
        newLiveCommercialName : '',
        oldLiveCommercialName : '',
    }
    
    connectedCallback() {
        this.listFixedPricing = JSON.parse(JSON.stringify(this.listFixedPricingTemporary));
        this.showSpinner = false;
        this.listFallbackCharges = JSON.parse(JSON.stringify(this.listFallbackChargesTemporary));
        let odd = this.listFallbackCharges.length % 2;
        let midIndex = Math.floor(this.listFallbackCharges.length / 2);
        if(odd != 0) {
            midIndex = midIndex+1;    
        }
        this.listFallback1 = this.listFallbackCharges.slice(0, midIndex);
        this.listFallback2 = this.listFallbackCharges.slice(midIndex);

        this.listPlatformFee = JSON.parse(JSON.stringify(this.listPlatformFeeTemporary));
        this.listFixedPricing2 = JSON.parse(JSON.stringify(this.listFixedPricing2Temporary));
        if(this.listFixedPricing2.length == 3){
            this.enableAddFixedPricingButton = false;
            
        }
    }

    getFixedPricingData(event){
        // alert('Calling getFixedPricingData');
        this.showSpinner = true;
        getFixedPricing({listFixedPricing2:JSON.stringify(this.listFixedPricing2)})
        .then(result => {
            // console.log('>>>>>>result>>>>'+result);
            if(result){
                // console.log('>>>>>>inside if result>>>>'+result);
                var res = JSON.parse(result);
                this.listFixedPricing2 = res;
                this.enableAddFixedPricingButton = false;
                this.showSpinner = false;
            }
        })
        .catch(error => {
            console.error(error);
        });
        
    }

    //method to get the value of the Status picklist from the Pricing Object
    @wire(getPicklistValues,
        {
            recordTypeId: '$pricingMetadata.data.defaultRecordTypeId', 
            fieldApiName: status
        }
    )
    statusPicklist;

    //Method to show Toast Message on the UI
    showToast(title,variant,message) {
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    }

    //this method is called on click of the Back button
    back(event) {
        this.listFallbackCharges = [...this.listFallback1, ...this.listFallback2];
        let ev = new CustomEvent('back',{ 
            detail : {
                listFixedPricing : this.listFixedPricing,
                listFallbackCharges : this.listFallbackCharges,
                listPlatformFee : this.listPlatformFee,
                listFixedPricing2 : this.listFixedPricing2,
                selectedType : this.selectedType,
                selectedInterval : this.selectedInterval,
                selectedStartDate : this.selectedStartDate,
                selectedEndDate : this.selectedEndDate,
                selectedDebitModel : this.selectedDebitModel
        }});
        this.dispatchEvent(ev);  
        //this.showScreen6 = false; 
        //this.showScreen5 = true;
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

    //this method is called on click on Publish Button
    publishCommercial(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateNew');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        }); 

        let validateData1 = false;
        for(let index=0;index<this.listPlatformFee.length;index++) {
            this.listPlatformFee[index].backgroundColor = 'background-color:white;';
        }

        if(validateData) {
            for(let index=0;index<this.listPlatformFee.length-1;index++) {
                let amount1 = parseInt(this.listPlatformFee[index+1].amount);
                let amount0 = parseInt(this.listPlatformFee[index].amount);
                if(amount1 <= amount0) {
                    validateData = false;
                    validateData1 = true;
                    this.listPlatformFee[index+1].backgroundColor = 'background-color:yellow;';
                }
            }
            if(validateData1) {
                this.showToast('INFO','info','Amount should be greater than the previous rows');
            }
        }

        if(validateData && !validateData1) {
            let validateData2 = false;
            for(let index=0;index<this.listPlatformFee.length;index++) {
                if(this.listPlatformFee[index].flatFee == '' && this.listPlatformFee[index].percentage == '') {
                    validateData = false;
                    validateData2 = true;
                    this.listPlatformFee[index].backgroundColor = 'background-color:yellow;';
                }
                else {
                    this.listPlatformFee[index].backgroundColor = 'background-color:white;';
                }
            }

            if(validateData2) {
                this.showToast('INFO','info','Either fill Flat Fee or Percentage');
            }
        }
        


        if(validateData) {
            this.showSpinner = true;
            getModalInformation({commercialId : this.commercialId})
                .then(result => {
                    if(result.message.includes('SUCCESS')) {
                        this.showSpinner = false;
                        this.showModalInformation = result;
                        if(!this.showModalInformation.showModal) {
                            this.publishCommercialPrivate();       
                        }
                    }
                    else {
                        this.showSpinner = false;
                        this.showToast('ERROR','error',result);
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.showToast('ERROR','error',error);
                })
        }
    }

    publishCommercialPrivate(event) {
            let listFallback = [...this.listFallback1, ...this.listFallback2];
            this.disabledPublishPricingButton = true;
            this.showSpinner = true;
            insertFixedPricingAndPublishCommercial({commercialId : this.commercialId,
                                                    listFixedPricingString : JSON.stringify(this.listFixedPricing),
                                                    listPlatformFee : JSON.stringify(this.listPlatformFee),
                                                    listFallbackCharges : JSON.stringify(listFallback),
                                                    selectedType : this.selectedType,
                                                    selectedInterval : this.selectedInterval,
                                                    selectedStartDate : this.selectedStartDate,
                                                    selectedEndDate : this.selectedEndDate,
                                                    selectedDebitModel : this.selectedDebitModel,
                                                    listFixedPricing2 : JSON.stringify(this.listFixedPricing2)
                                                    })
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.hidePublishCommercialButton = true;        
                    this.showToast('SUCCESS','success','Publish pricing records started successfully');
                    this.disabledPublishPricingButton = false;
                    this.showModalInformation = {
                        message : '',
                        showModal : false,
                        newLiveCommercialName : '',
                        oldLiveCommercialName : '',
                    }
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
            let ev = new CustomEvent('selection',{detail : paramData});
            this.dispatchEvent(ev);   
        })
       .catch(error=>{
            alert(JSON.stringify(error[0]));     
       })
    }

    //this method is called on change of the plan choice
    handleChangeSelectedPlanChoice(event) {
        this.selectedPlanChoice = event.detail.value;
    }

    //this method is called on click of the cancel button from Save As Template mnodal
    cancelShowTempalteModal(event) {
        this.showSaveAsTemplateModal = false;
        this.selectedPlanChoice = '';
        this.templateName = '';
    }

    //this method is called on click of the Next Button from Create a template modal
    nextTemplateModal(event) {
        let validateData = true;
        this.templateName = '';
        this.availableSubPlanMaster = [];
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
                    /*Commented to incorporate the template architecture changes
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
                    })*/

                    getPlanAndSubPlanDetails()
                    .then(result => {
                        if(result.message.includes('SUCCESS')) {
                            this.showSpinner = false;
                            this.availablePlanMaster = JSON.parse(result.jsonPlanMaster);
                            //this.availableSubPlanMaster = JSON.parse(result.jsonSubPlanMaster);
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
                            //this.availableSubPlanMaster = JSON.parse(result.jsonSubPlanMaster);
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
            //Added to incorporate architectural changes related to Plan,Sub Plan and templates
            else if(this.selectedPlanChoice == 'option5' && this.isSuperUser) {
                this.showSpinner = true;
                getPlanAndSubPlanDetails()
                    .then(result => {
                        if(result.message.includes('SUCCESS')) {
                            this.showSpinner = false;
                            this.availablePlanMaster = JSON.parse(result.jsonPlanMaster);
                            //this.availableSubPlanMaster = JSON.parse(result.jsonSubPlanMaster);
                            this.superUserChooseExistingPlanCreateNewSubPlanAndTemplate = true; 
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

    //this method is called on click of Back button from create new plan for oridnary user
    backButton(event) {
        this.ordinaryUserCreateTemplate = false;
        this.ordinaryUserUpdateTemplate = false;  
        this.showSaveAsTemplateModal = true;
    }

    //this method is called on click of the Cancel from the Cancel button from the create template for ordinary user
    cancelOrdinaryUserCreateTemplate(event) {
        this.ordinaryUserCreateTemplate = false; 
        this.ordinaryUserUpdateTemplate = false;    
        this.showSaveAsTemplateModal = false; 
        this.templateName = '';
        this.selectedPlanChoice = '';
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

    //this method is called on click of cancel from Added fixed pricing modal
    cancelMessageModal(event) {
        this.showFixedPricingModal = false;    
    }

    cancelMessageModalConfirmation(event) {
        this.showModalInformation = {
            message : '',
            showModal : false,
            newLiveCommercialName : '',
            oldLiveCommercialName : '',
        }
    }

    callPublishPricingFunction(event) {
        this.publishCommercialPrivate();    
    }

    //this method is called on click of the Proceed button from the added fixed pricing modal
    openSaveAsTemplateModal(event) {
        this.showSaveAsTemplateModal = true;
        this.showFixedPricingModal = false; 
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
        this.superUserChooseExistingPlanCreateNewSubPlanAndTemplate = false;
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
        this.superUserChooseExistingPlanCreateNewSubPlanAndTemplate = false;
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

    //this method is called on change of Plan Name
    handlePlanName(event) {
        this.selectedPlanName = event.detail.value;
        this.selectedSubPlanName = '';
        this.availableSubPlanMaster = [];
        this.showSpinner = true;
        getSubPlanDetailsForSelectedPlan({planId : this.selectedPlanName})
            .then(result => {
                if(result.message.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.availableSubPlanMaster = JSON.parse(result.jsonSubPlanMaster);
                }
                else {
                    this.showSpinner = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR','error',error);   
            })

    }

    //this method is called on change of Sub Plan Name
    handleSubPlanName(event) {
        this.selectedSubPlanName = event.detail.value;
        //Handle to incorporate template architecture changes
        if(this.isSuperUser && this.superUserUpdateTemplate) {
            this.showSpinner = true;
            this.availablePrivateTemplate = [];
            getPrivateTemplateDetailsForPlanAndSubPlan({planId : this.selectedPlanName,subPlanId : this.selectedSubPlanName})
            .then(result => {
                if(result.message.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.availablePrivateTemplate = JSON.parse(result.jsonPlanMaster);
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
        //End
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

    //this method is called on click of Save from option 5 Super User
    saveCreateNewTemplateOption5(event) {
        let validateData = true;
        let inputFields = this.template.querySelectorAll('.validateOption5');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        });
        if(validateData) {
            this.showSpinner = true;
            this.disabledOption5Save = true;
            createTemplateForSuperUser({templateName : this.templateName,selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),listFixedPricingString : JSON.stringify(this.listFixedPricing),commercialId : this.commercialId,publicTemplateCheckbox : this.publicTemplateCheckbox,planName : this.selectedPlanName,subPlanName : this.selectedSubPlanName,action : 'option5'})
            .then(result => {
                if(result.includes('SUCCESS')) {
                    this.showSpinner = false;
                    this.disabledOption5Save = false;
                    this.superUserChooseExistingPlanCreateNewSubPlanAndTemplate = false;
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
                    this.disabledOption5Save = false;
                    this.showToast('ERROR','error',result);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.disabledOption5Save = false;
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

    handleFallbackFlatFee1(event) {
        this.listFallback1[event.currentTarget.dataset.id].flatFee = event.detail.value;
    }

    handleFallbackPercentage1(event) {
        this.listFallback1[event.currentTarget.dataset.id].percentage = event.detail.value;
    }

    handleFallbackFlatFee2(event) {
        this.listFallback2[event.currentTarget.dataset.id].flatFee = event.detail.value;
    }

    handleFallbackPercentage2(event) {
        this.listFallback2[event.currentTarget.dataset.id].percentage = event.detail.value;
    }

    addPlatformFeeRow(event) {
        let length = this.listPlatformFee.length;
        if(length < 10) {
            let platformFeeObj = {
                Id : '',
                amount : '',
                flatFee : '',
                percentage : '',
                showRemoveButton : true,
                disabledAmount : false,
                backgroundColor : 'background-color:white;'
            }
            this.listPlatformFee.push(platformFeeObj);
        }
        else {
            this.showToast('Info','info','Maximum 10 Platform fee Allowed');
        }
    }

    deletePlatformFeeRow(event) {
        let index = event.currentTarget.dataset.id;
        this.listPlatformFee.splice(index,1);
    }

    handlePlatformFeeAmount(event) {
        this.listPlatformFee[event.currentTarget.dataset.id].amount = event.detail.value;
    }

    handlePlatformFeeFlatFee(event) {
        this.listPlatformFee[event.currentTarget.dataset.id].flatFee = event.detail.value;
    }

    handlePlatformFeePercentage(event) {
        this.listPlatformFee[event.currentTarget.dataset.id].percentage = event.detail.value;
    }

    handleChangeInterval(event) {
        this.selectedInterval = event.detail.value;
    }

    handleChangeType(event) {
        this.selectedType = event.detail.value;
    }

    handleChangeStartDate(event) {
        this.selectedStartDate = event.detail.value;
    }

    handleChangeEndDate(event) {
        this.selectedEndDate = event.detail.value;
    }

    handleChangeDebitModel(event) {
        this.selectedDebitModel = event.detail.value;
    }

    deleteFixedPricingRow(event) {
        let index = event.currentTarget.dataset.id;
        this.listFixedPricing2.splice(index,1);    
        if(this.listFixedPricing2.length < 3){
            this.enableAddFixedPricingButton = true;
        }
    }

    handleChangeDebitModelFP(event) {
        this.listFixedPricing2[event.currentTarget.dataset.id].debitModel = event.detail.value;
    }

    handleChangeStartDateFP(event) {
        this.listFixedPricing2[event.currentTarget.dataset.id].startDate = event.detail.value;
    }

    handleChangeEndDateFP(event) {
        this.listFixedPricing2[event.currentTarget.dataset.id].endDate = event.detail.value;
    }

    handleChangeIntervalFP(event) {
        this.listFixedPricing2[event.currentTarget.dataset.id].paymentFrequency = event.detail.value;
    }

    handleChangeAmountFP(event) {
        this.listFixedPricing2[event.currentTarget.dataset.id].amount = event.detail.value;
    }

    handleChangeFlatFeeFP(event) {
        this.listFixedPricing2[event.currentTarget.dataset.id].flatFee = event.detail.value;
    }

    handleChangePercentageFP(event) {
        this.listFixedPricing2[event.currentTarget.dataset.id].percentage = event.detail.value;
    }

}
