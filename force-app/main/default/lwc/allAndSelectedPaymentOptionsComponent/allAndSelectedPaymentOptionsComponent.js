import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSpecificationDetails from '@salesforce/apex/PricingModuleComponentController.getSpecificationDetails';
import getPaymentGatewayData from '@salesforce/apex/PricingModuleComponentController.getPaymentGatewayData';
import { getDataConnectorSourceFields } from 'lightning/analyticsWaveApi';

export default class AllAndSelectedPaymentOptionsComponent extends LightningElement {
    showSpinner = true;
    @api listPaymentData = [];
    @track listPaymentDataTemporary = [];
    @api selectedListPaymentData = [];
    @api mapTDRConvenienceData = new Map();
    @api listFeeModel = [];
    @api listTransactionType = [];
    
    /*********Added by rohit */
      errorSelectPayOptions = false;
      showErrorMessage = false;
      showErrorMessageForSelectPayOptions;
      listForShowingAllSpecification=[];
      allOptionValues;
      isEventDispatched = false;
    /***************End */
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
        pricingId : '',
        restrictFlatFeeAndPercentageToBeEdited : false,
        restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited : false,
        ruleStatus : 'D'
    }

    connectedCallback() {
        this.showSpinner = false;
        this.listPaymentDataTemporary = JSON.parse(JSON.stringify(this.listPaymentData));
    }

     //this method is called on click of the close icon from the error message Screen 4 : added by rohit
     hideErrorMessage(event) {
        this.errorMessage = '';
        this.showErrorMessage = false;
        this.errorSelectPayOptions = false;
        this.showErrorMessageForSelectPayOptions='';
    }

    //Method called on load of the Screen 3 Part 2 - Selected Payment Option 
    handleDataToShowNewForCombination(event) {
        this.showSpinner = true;
        this.selectedListPaymentData = [];
        let addStyle = true;
        for (let index = 0; index < this.listPaymentDataTemporary.length; index++) {
            if (this.listPaymentDataTemporary[index].isChecked) {
                this.SelectedPaymentOptionObject.paymentModeId = this.listPaymentDataTemporary[index].key;
                this.SelectedPaymentOptionObject.paymentModeName = this.listPaymentDataTemporary[index].paymentMode;
                //add color 
                if (addStyle) {
                    this.listPaymentDataTemporary[index].styleClass = 'background:#C7E1FF;color: #222222;border-left: #599AEA solid 4px;';
                    this.SelectedPaymentOptionObject.styleClass = this.listPaymentDataTemporary[index].styleClass;
                    addStyle = false;
                }
                else {
                    this.listPaymentDataTemporary[index].styleClass = 'background:#F2F8FF;';
                    this.SelectedPaymentOptionObject.styleClass = this.listPaymentDataTemporary[index].styleClass;
                }
                //end 
                let setUniqueCombination = new Set();
                for (let indexInner = 0; indexInner < this.listPaymentDataTemporary[index].listPaymentDataInner.length; indexInner++) {
                    let selectedSpecifications = JSON.stringify(this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedSpecifications);
                    selectedSpecifications = selectedSpecifications.replaceAll('"', '');
                    selectedSpecifications = selectedSpecifications.replaceAll('[', '');
                    selectedSpecifications = selectedSpecifications.replaceAll(']', '');
                    selectedSpecifications.split(',').forEach(element => {
                        let selectedPaymentGateway = JSON.stringify(this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentGateway);
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll('"', '');
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll('[', '');
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll(']', '');
                        selectedPaymentGateway.split(',').forEach(element1 => {
                            let key = this.listPaymentDataTemporary[index].key + '#' + this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOptionId + '#' + element + '#' + element1 + '#' + this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                            if (!setUniqueCombination.has(key)) {
                                setUniqueCombination.add(key);
                                this.selectetPaymentIndividualObject.key = key;
                                this.selectetPaymentIndividualObject.pricingId = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].pricingId;
                                this.selectetPaymentIndividualObject.selectedPaymentOptionName = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOption.split('#')[0];
                                this.selectetPaymentIndividualObject.selectedPaymentOptionId = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOptionId;
                                this.selectetPaymentIndividualObject.selectedSpecification = element;
                                this.selectetPaymentIndividualObject.selectedPaymentGatewayName = element1;
                                this.selectetPaymentIndividualObject.selectedOnusOffus = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                                this.selectetPaymentIndividualObject.listFeeModel = JSON.parse(JSON.stringify(this.listFeeModel));
                                this.selectetPaymentIndividualObject.listTransactionType = JSON.parse(JSON.stringify(this.listTransactionType));
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
                                this.selectetPaymentIndividualObject.restrictFlatFeeAndPercentageToBeEdited = false;
                                this.selectetPaymentIndividualObject.restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = false;
                                this.selectetPaymentIndividualObject.ruleStatus = 'D';
                                this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList = [];
                                this.SelectedPaymentOptionIndividualListObject.restrictTransactionTypeAndFeeModel = false;
                                this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
                                this.SelectedPaymentOptionIndividualListObject.key = key;
                                this.SelectedPaymentOptionObject.selectedPaymentOptionsList.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionIndividualListObject)));
                                /************Added by Rohit */
                                if(!this.selectetPaymentIndividualObject.selectedPaymentOptionName || !element || !element1){
                                    this.errorSelectPayOptions = true;
                                    this.showErrorMessageForSelectPayOptions ='Please add values for Payment Options, Specification and Payment Gateway for each instrument';// added by rohit
                                }
                                else{
                                    this.errorSelectPayOptions = false;
                                }
                                /**********END */
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

    //Method called to fetch the Specifications corresponding to the Payment Options on change of Payment Options, Screen 3 Part 1 
    handleChangePaymentOptions(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        let paymentOptionDetails = event.detail.value.split('#');
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentOption = event.detail.value;
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentOptionId = paymentOptionDetails[1];
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disableSpecificationPicklist = true;
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listSpecificationToShow = [];
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedSpecifications = '';
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = true;
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listPaymentGatewayToShow = [];
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGateway = '';
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedSpecificationsList = [];
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGatewayList = [];
        this.showSpinner = true;
        getSpecificationDetails({ paymentModeId: paymentModeId, paymentOptionId: paymentOptionDetails[1] })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disableSpecificationPicklist = false;
                    this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listSpecificationToShow = result.listSpecifications;
                    this.listForShowingAllSpecification =  result.listSpecifications; // added by rohit
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

    //Method called on check of the checkbox on screen 3 part 1 
    handleChecked(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.key;
        if (this.listPaymentDataTemporary[indexRow].isChecked) {
            this.listPaymentDataTemporary[indexRow].isChecked = false;
            for (let index = 0; index < this.listPaymentDataTemporary[indexRow].listPaymentDataInner.length; index++) {
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disablePicklistValues = true;
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disableSpecificationPicklist = true;
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedOnusOffus = '';
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentOption = '';
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGateway = '';
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedSpecifications = '';
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = true;
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGateway = '';
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedSpecificationsList = [];
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGatewayList = [];
            }
        }
        else {
            this.listPaymentDataTemporary[indexRow].isChecked = true;
            for (let index = 0; index < this.listPaymentDataTemporary[indexRow].listPaymentDataInner.length; index++) {
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disablePicklistValues = false;
                this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedOnusOffus = 'OFFUS';
            }
        }
    }

    //Method to track changes around the column Specifications, Screen 3 Part 1 
    getSpecifications(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedSpecifications = event.detail;
        let paymentOptionId = this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentOptionId;
        let selectedSpecifications = this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedSpecifications;
         /****************** When choose "Select all" on specification then all other spacification values will be marked ::::Added by rohit start*/
         const isSelectAllOptionSelected = selectedSpecifications.includes("Select All");
         if (isSelectAllOptionSelected) {
             // If the "Select All" option is selected, get all other specifications
             selectedSpecifications = this.listForShowingAllSpecification.map(option => option.value).filter(value => value !==  "Select All");
         }
         else if(selectedSpecifications !='Select All'){
             selectedSpecifications =  this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedSpecifications;
         }
         else {
             // If the "Select All" option is unselected, clear the selected options
             selectedSpecifications = [];
         }
         /*************** End*/
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = true;
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listPaymentGatewayToShow = [];
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGateway = '';
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGatewayList = [];
        this.showSpinner = true;
        getPaymentGatewayData({ paymentModeId: paymentModeId, paymentOptionId: paymentOptionId, selectedSpecifications: selectedSpecifications })
            .then(result => {
                if (result.message.includes('SUCCESS')) {
                    this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disablePaymentGatewayPicklist = false;
                    this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listPaymentGatewayToShow = result.listPaymentGateway;
                    this.showSpinner = false;
                }
                else {
                    this.showSpinner = false;
                    //this.showToast('ERROR', 'error', result.message);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('ERROR', 'error', error);
            })
    }

    //Method to track changes around the column Payment Gateway, Screen 3 Part 1 
    getPaymentGateway(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedPaymentGateway = event.detail;
    }

    //Method to track changes around the column ONUS/OFFUS, Screen 3 Part 1 
    handleChangeOnusOffus(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].selectedOnusOffus = event.detail.value;
    }

    //Method called on click of the + Icon on the row, Screen 3 Part 1 
    addRow(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        let onus = '';
        if (this.listPaymentDataTemporary[indexRow].isChecked) {
            onus = 'OFFUS';
        }
        var newInnerRecord = {
            key: paymentModeId + '#' + (index + 1),
            listPaymentOptionsToShow: this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listPaymentOptionsToShow,
            listSpecificationToShow: [],
            listPaymentOptions: this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listPaymentOptions,
            listPaymentGatewayToShow: [],
            listOnusOffusToShow: this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listOnusOffusToShow,
            listPaymentModeToPaymentGateways: this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].listPaymentModeToPaymentGateways,
            disablePicklistValues: this.listPaymentDataTemporary[indexRow].listPaymentDataInner[index].disablePicklistValues,
            disablePaymentGatewayPicklist: true,
            disableSpecificationPicklist: true,
            selectedPaymentOption: '',
            selectedPaymentOptionId: '',
            selectedPaymentGateway: '',
            selectedOnusOffus: onus,
            selectedSpecifications: '',
            showDeleteButton: true,
            selectedSpecificationsList: [],
            selectedPaymentGatewayList: [],
            pricingId : ''

        };
        
        this.listPaymentDataTemporary[indexRow].listPaymentDataInner.push(newInnerRecord);
    }

    //Method called to remove row, Screen 3 Part 1 
    removeRow(event) {
        let paymentModeId = event.currentTarget.dataset.id;
        let indexRow = event.currentTarget.dataset.label;
        let index = event.currentTarget.dataset.key;
        if (this.listPaymentDataTemporary[indexRow].listPaymentDataInner.length > 1) {
            this.listPaymentDataTemporary[indexRow].listPaymentDataInner.splice(index, 1);
            index--;
        }
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

    //Send data to Parent Component
    @api screen3Step2Show(event) {
        var count = 0;
        //this.showScreen4 = false;
        for (let index = 0; index < this.listPaymentDataTemporary.length; index++) {
            if (this.listPaymentDataTemporary[index].isChecked) {
                count = 1;
                break;
            }
        }
        if (count == 1) {
            this.handleDataToShowNew();
             //firing event 
             if(this.errorSelectPayOptions ){
                this.showThirdScreen =  true;
                this.hideScreen3Step1 = 'display:block';
                this.hideScreen3Step2 = 'display:none';
                this.showErrorMessageForSelectPayOptions ='Please add values for Payment Options, Specification and Payment Gateway for each instrument.';// added by rohit
            }
            else{
                const selectEvent = new CustomEvent('selection', {
                    detail : { 
                        selectedListPaymentData : this.selectedListPaymentData,
			            listPaymentData : this.listPaymentDataTemporary
                    }
                });
                this.dispatchEvent(selectEvent);
            }
        }
        else {
            this.showToast('INFO', 'info', 'Please select Payment modes to proceed');
        }
    }

    //Method called on click of the Confirm Payment Options - Screen 2 
    handleDataToShowNew(event) {
        this.showSpinner = true;
        this.selectedListPaymentData = [];
        let mapTDRConvenience = new Map(Object.entries(this.mapTDRConvenienceData));
        let addStyle = true;
        for (let index = 0; index < this.listPaymentDataTemporary.length; index++) {
            if (this.listPaymentDataTemporary[index].isChecked) {
                this.SelectedPaymentOptionObject.paymentModeId = this.listPaymentDataTemporary[index].key;
                this.SelectedPaymentOptionObject.paymentModeName = this.listPaymentDataTemporary[index].paymentMode;
                //add color 
                if (addStyle) {
                    this.listPaymentDataTemporary[index].styleClass = 'background:#C7E1FF;color: #222222;border-left: #599AEA solid 4px;';
                    this.SelectedPaymentOptionObject.styleClass = this.listPaymentDataTemporary[index].styleClass;
                    addStyle = false;
                }
                else {
                    this.listPaymentDataTemporary[index].styleClass = 'background:#F2F8FF;';
                    this.SelectedPaymentOptionObject.styleClass = this.listPaymentDataTemporary[index].styleClass;
                }
                //end 
                let setUniqueCombination = new Set();
                for (let indexInner = 0; indexInner < this.listPaymentDataTemporary[index].listPaymentDataInner.length; indexInner++) {
                    let selectedSpecifications = JSON.stringify(this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedSpecifications);
                    selectedSpecifications = selectedSpecifications.replaceAll('"', '');
                    selectedSpecifications = selectedSpecifications.replaceAll('[', '');
                    selectedSpecifications = selectedSpecifications.replaceAll(']', '');
                    selectedSpecifications.split(',').forEach(element => {
                        let selectedPaymentGateway = JSON.stringify(this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentGateway);
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll('"', '');
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll('[', '');
                        selectedPaymentGateway = selectedPaymentGateway.replaceAll(']', '');
                        selectedPaymentGateway.split(',').forEach(element1 => {
                            let key = this.listPaymentDataTemporary[index].key + '#' + this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOptionId + '#' + element + '#' + element1 + '#' + this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                            if (!setUniqueCombination.has(key)) {
                                setUniqueCombination.add(key);
                                if (mapTDRConvenience.has(key)) {
                                    let innerMap = new Map(Object.entries(mapTDRConvenience.get(key)));
                                    innerMap.forEach((values, keys) => {
                                        let feeAndTransaction = keys.split('#');
                                        let keyNew = key + '#' + feeAndTransaction[0] + '#' + feeAndTransaction[1];
                                        this.SelectedPaymentOptionIndividualListObject.key = keyNew;
                                        this.SelectedPaymentOptionIndividualListObject.restrictTransactionTypeAndFeeModel = values.restrictTransactionTypeAndFeeModel;
                                        this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList = [];
                                        for (let indexNew = 0; indexNew < values.listTDRConvenienceData.length; indexNew++) {
                                            if (indexNew == 0) {
                                                this.selectetPaymentIndividualObject.key = keyNew;
                                            }
                                            else {
                                                this.selectetPaymentIndividualObject.key = keyNew + '#' + indexNew;
                                            }
                                            //this.selectetPaymentIndividualObject.key = key; 
                                            this.selectetPaymentIndividualObject.selectedPaymentOptionName = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOption.split('#')[0];
                                            this.selectetPaymentIndividualObject.selectedPaymentOptionId = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOptionId;
                                            this.selectetPaymentIndividualObject.selectedSpecification = element;
                                            this.selectetPaymentIndividualObject.selectedPaymentGatewayName = element1;
                                            this.selectetPaymentIndividualObject.selectedOnusOffus = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                                            this.selectetPaymentIndividualObject.listFeeModel = JSON.parse(JSON.stringify(this.listFeeModel));
                                            this.selectetPaymentIndividualObject.listTransactionType = JSON.parse(JSON.stringify(this.listTransactionType));
                                            this.selectetPaymentIndividualObject.selectedFeeModel = feeAndTransaction[0];
                                            this.selectetPaymentIndividualObject.selectedTransactionType = feeAndTransaction[1];
                                            this.selectetPaymentIndividualObject.isChecked = false;
                                            if (indexNew == 0) {
                                                this.selectetPaymentIndividualObject.showCheckbox = true;
                                            }
                                            else {
                                                this.selectetPaymentIndividualObject.showCheckbox = false;
                                            }
                                            if (feeAndTransaction[1] == 'TDR') {
                                                this.selectetPaymentIndividualObject.showTDR = true;
                                                this.selectetPaymentIndividualObject.showConvenience = false;
                                            }
                                            else if (feeAndTransaction[1] == 'Convenience') {
                                            this.selectetPaymentIndividualObject.showConvenience = true;
                                                this.selectetPaymentIndividualObject.showTDR = false;
                                            }
                                            else {
                                                this.selectetPaymentIndividualObject.showConvenience = true;
                                                this.selectetPaymentIndividualObject.showTDR = true;
                                            }
                                            this.selectetPaymentIndividualObject.pricingId = values.listTDRConvenienceData[indexNew].pricingId;
                                            
                                            this.selectetPaymentIndividualObject.tdrAmount = values.listTDRConvenienceData[indexNew].tdrAmount;
                                            this.selectetPaymentIndividualObject.tdrFee = values.listTDRConvenienceData[indexNew].tdrFlatFee;
                                            this.selectetPaymentIndividualObject.tdrPercentage = values.listTDRConvenienceData[indexNew].tdrPercentage;
                                            this.selectetPaymentIndividualObject.convenienceAmount = values.listTDRConvenienceData[indexNew].convenienceAmount;
                                            this.selectetPaymentIndividualObject.convenienceFee = values.listTDRConvenienceData[indexNew].convenienceFlatFee;
                                            this.selectetPaymentIndividualObject.conveniencePercentage = values.listTDRConvenienceData[indexNew].conveniencePercentage;
                                            this.selectetPaymentIndividualObject.restrictFlatFeeAndPercentageToBeEdited = values.listTDRConvenienceData[indexNew].restrictFlatFeeAndPercentageToBeEdited;
                                            this.selectetPaymentIndividualObject.restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = values.listTDRConvenienceData[indexNew].restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited;
                                            this.selectetPaymentIndividualObject.ruleStatus = values.listTDRConvenienceData[indexNew].ruleStatus;
                                            this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
                                        }
                                        this.SelectedPaymentOptionObject.selectedPaymentOptionsList.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionIndividualListObject)));
                                    })
                                }
                                else {
                                    this.selectetPaymentIndividualObject.key = key;
                                    this.selectetPaymentIndividualObject.selectedPaymentOptionName = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOption.split('#')[0];
                                    this.selectetPaymentIndividualObject.selectedPaymentOptionId = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedPaymentOptionId;
                                    this.selectetPaymentIndividualObject.selectedSpecification = element;
                                    this.selectetPaymentIndividualObject.selectedPaymentGatewayName = element1;
                                    this.selectetPaymentIndividualObject.selectedOnusOffus = this.listPaymentDataTemporary[index].listPaymentDataInner[indexInner].selectedOnusOffus;
                                    this.selectetPaymentIndividualObject.listFeeModel = JSON.parse(JSON.stringify(this.listFeeModel));
                                    this.selectetPaymentIndividualObject.listTransactionType = JSON.parse(JSON.stringify(this.listTransactionType));
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
                                    this.selectetPaymentIndividualObject.pricingId = '';
                                    this.selectetPaymentIndividualObject.restrictFlatFeeAndPercentageToBeEdited = false;
                                    this.selectetPaymentIndividualObject.restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = false;
                                    this.selectetPaymentIndividualObject.ruleStatus = 'D';
                                    this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList = [];
                                    this.SelectedPaymentOptionIndividualListObject.selectedPaymentIndividualList.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
                                    this.SelectedPaymentOptionIndividualListObject.key = key;
                                    this.SelectedPaymentOptionIndividualListObject.pricingId = '';
                                    this.SelectedPaymentOptionIndividualListObject.restrictTransactionTypeAndFeeModel = false;
                                    this.SelectedPaymentOptionObject.selectedPaymentOptionsList.push(JSON.parse(JSON.stringify(this.SelectedPaymentOptionIndividualListObject)));
                                    /**********Added by Rohit */
                                    if(!this.selectetPaymentIndividualObject.selectedPaymentOptionName || !element || !element1){
                                        this.errorSelectPayOptions = true;
                                    }
                                    else{
                                        this.errorSelectPayOptions = false;
                                    }
                                    /**********END */
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
}