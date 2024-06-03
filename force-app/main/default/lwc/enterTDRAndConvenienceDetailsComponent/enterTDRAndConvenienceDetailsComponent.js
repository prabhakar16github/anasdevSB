import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import savePricingApex from '@salesforce/apex/PricingModuleComponentController.savePricingApex';

export default class EnterTDRAndConvenienceDetailsComponent extends LightningElement {
    showSpinner = true;
    disabledSavePricingButton = false;
    showErrorMessage = false;
    errorMessage = '';
    @api selectedListPaymentDataTemporary = [];
    @track selectedListPaymentData = [];
    @track listFirstRowForAddCommercials = [];
    showScreen4 = true;
    @track pushForPaymentMode = [];
    @track listDataForPaymentMode = [];
    paymentModeName = '';
    index = 0;
    @api listFeeModel = [];
    @api listTransactionType = [];
    @api recordId = '';
    @api commercialName = '';
    @api selectedTemplate = '';
    showBelowRackRateMessage = false;
    belowRackRateMessage = '';
    commercialId = '';
    disabledCommercialName = false;
   /*********Added by rohit */
   errorSelectPayOptions = false;
   allSelectedValue =[];
   showErrorMessageForSelectPayOptions;
   listForShowingAllSpecification=[];
   errorLineBreakShow='';
   @track errorMessageClass = '';
   /***************End */
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
        backgroundColor : 'background-color:white;',
        pricingId : '',
        restrictFlatFeeAndPercentageToBeEdited : false,
        restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited : false,
        ruleStatus : 'D'
    }
    paymentOptions=[]; // added by rohit
    //paymentOptionsArray = [];
    specificationOptions = [];// added by rohit
    paymentGatewayOptions = [];// added by rohit
    PaymentOptionPicklistValue;  //added by rohit
    specificationPicklistValue;//added by rohit
    noValueForPaymentsOptionAndSpecification;//added by rohit
    haveRecords = true;//added by rohit
    storePaymentOptionValue = '';
    filteredDataForSelected = [];
    filteredData = [];
    @api selectedFilterDataToChange=[];
    getSelectRow=[];
    @track originalSelectedData=[];
    @track saveData=[];
    @track getAllDataFOrSaving=[];
    @track allDataShow=[];
    isClickedOnAnotherTab  =false;
    @track allPickListDataForFirstRow =[]
    handleCheckedForCommercialsFirstRowFlag = false;
    connectedCallback() {
        this.filteredData = [];
        this.getSelectRow = [];
        this.PaymentOptionPicklistValue = '--NONE--';
        this.specificationPicklistValue = '--NONE--';
        this.selectedListPaymentData = JSON.parse(JSON.stringify(this.selectedListPaymentDataTemporary));
        this.originalSelectedData = JSON.parse(JSON.stringify(this.selectedListPaymentDataTemporary));
        this.allPickListDataForFirstRow =  this.originalSelectedData[0].selectedPaymentOptionsList;
        this.listDataForPaymentMode = this.selectedListPaymentData[0].selectedPaymentOptionsList;
       
        /******Added by rohit Part 2 story */ 
        this.paymentOptions.unshift({
            label: '--NONE--',
            value: '--NONE--',
        });
        for (const item of this.listDataForPaymentMode) {
            for (const paymentOption of item.selectedPaymentIndividualList) {
                if(!this.paymentOptions.find((option) => option.label === paymentOption.selectedPaymentOptionName)){
                    this.paymentOptions.push({
                        label: paymentOption.selectedPaymentOptionName,
                        value: paymentOption.selectedPaymentOptionName
                    });
                }
            }
           
          }
        /**********Get specification */
        this.specificationOptions.push({
            label: '--NONE--',
            value:'--NONE--',
        });
        for (const item of this.listDataForPaymentMode) {
            for (const paymentOption of item.selectedPaymentIndividualList) {
                if(!this.specificationOptions.find((option) => option.label === paymentOption.selectedSpecification)){
                    this.specificationOptions.push({
                    label: paymentOption.selectedSpecification,
                    value: paymentOption.selectedSpecification
                    });
                }
            }
        }
            /**********Get paymentGateway */
        /**********End*********** */
        this.paymentModeName = this.selectedListPaymentData[0].paymentModeName;
        this.index = 0;
        this.selectetPaymentIndividualObject.key = this.selectedListPaymentData[0].paymentModeName;
        this.selectetPaymentIndividualObject.selectedPaymentOptionName = '--NONE--';//'Set a default rate';//+this.selectedListPaymentData[0].paymentModeName +' rate';
        this.selectetPaymentIndividualObject.selectedPaymentOptionId = '';
        this.selectetPaymentIndividualObject.selectedSpecification = '--NONE--';
        this.selectetPaymentIndividualObject.selectedPaymentGatewayName = '';
        this.selectetPaymentIndividualObject.selectedOnusOffus = '';
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

        this.listFirstRowForAddCommercials.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject))); 
        this.showSpinner = false;
    }
 
    handleChangePaymentOption = (event) => {
       // Filter the data
        //let index = this.index;
        this.handleCheckedForCommercialsFirstRowFlag = true;
        this.listFirstRowForAddCommercials[0].isChecked = false;
        this.storePaymentOptionValue = event.target.value;
        this.filteredData = []; 
        this.allSelectedValue=[];

        /**************Start to get the picklist value */

            // Get the selected value of the first picklist
    const getPicklistValue = event.target.value;

    // Get the data-id attribute from the event to identify which picklist triggered the change
    const dataIndex =  event.target.dataset.id;//event.target.dataset.id ||
    // Depending on the data-id value, you can determine which picklist triggered the change
    if (dataIndex === 'index') {
        // This change is from the first picklist
        // Store the selected value of the first picklist
        this.PaymentOptionPicklistValue= getPicklistValue;
        
    } else if (dataIndex === 'index.key') {
        // This change is from the second picklist
        // Store the selected value of the second picklist
        this.specificationPicklistValue = getPicklistValue;
        
         
    }
    console.log('selectedPaymentOptionName::183:::::'+ this.PaymentOptionPicklistValue);
    console.log('selectedSpecification:::189::::'+this.specificationPicklistValue);
    // You can perform additional logic or actions here if needed

        /**************END************************* */
        for (let i = 0; i <this.selectedListPaymentData[this.index].selectedPaymentOptionsList.length; i++) {
            for (let j = 0; j < this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i].selectedPaymentIndividualList.length; j++) {
                this.allSelectedValue.push(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i]);
                if (this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i].selectedPaymentIndividualList[j].selectedPaymentOptionName === event.detail.value  && this.specificationPicklistValue =='--NONE--'  &&  event.detail.value !== "--NONE--") { 
                    this.filteredData.push( this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i]);
                    this.haveRecords = true;
                    console.log(' this.noRecords:::::204:::'+ this.haveRecords);
                 }
                 else if (this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i].selectedPaymentIndividualList[j].selectedSpecification === event.detail.value  && this.PaymentOptionPicklistValue =='--NONE--'  &&  event.detail.value !== "--NONE--") { 
                    this.filteredData.push( this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i]);
                    this.haveRecords = true;
                    console.log(' this.noRecords:::::209:::'+ this.haveRecords);
                 }
                else if ( this.PaymentOptionPicklistValue == this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i].selectedPaymentIndividualList[j].selectedPaymentOptionName && this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i].selectedPaymentIndividualList[j].selectedSpecification === event.detail.value && event.detail.value !== "--NONE--") {
                    console.log('inside else if::224:::');
                    this.filteredData.push(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i]);
                    this.haveRecords = true;
                }
                else if ( this.specificationPicklistValue == this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i].selectedPaymentIndividualList[j].selectedSpecification && this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i].selectedPaymentIndividualList[j].selectedPaymentOptionName == event.detail.value  && event.detail.value !== "--NONE--")  {
                    this.filteredData.push(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[i]);
                    this.haveRecords = true;
                    console.log('inside else if::231:::');
                    /*this.haveRecords = false;

                    this.showToast('ERROR','error','There are no records for selected combination');*/
                   // console.log(' this.noRecords:::::233:::'+ this.haveRecords);
                }
                break;
             }
        }
        if( event.detail.value=="--NONE--"){
            
            this.listDataForPaymentMode =    this.allSelectedValue// added by rohit to get all the selected values
            this.PaymentOptionPicklistValue = '--NONE--';
            this.specificationPicklistValue = '--NONE--';
            
        }
        else if(event.detail.value !=="--NONE--" && this.filteredData.length>0){
            this.listDataForPaymentMode = this.filteredData;
        }
        this.showScreen4 = true;
    }

    //this method is called from Screen 4 on click of checkbox from Set Default rate row
    handleCheckedForCommercialsFirstRow(event) {
        this.listFirstRowForAddCommercials[event.currentTarget.dataset.id].isChecked = event.detail.checked;
        let index = this.index;
        for(let index1=0; index1<this.selectedListPaymentData[index].selectedPaymentOptionsList.length; index1++) { 
            if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].restrictTransactionTypeAndFeeModel == false) {
                for(let index2=0; index2<this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; index2++) {
                    this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].isChecked = event.detail.checked;
                }
            }
        }
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

    //this method is called on click of plus icon from first row of default rates
    addrowInListFirstRowForAddCommercials(event) {
         /*************if first parent row or sub row has tdr value as zero then it should give an error :: added by rohit */
         const dataId = event.currentTarget.dataset.id;
         const row = this.listFirstRowForAddCommercials[dataId];
         let parentIndex = event.target.dataset.id;
         const subRowIndexForParent =this.listFirstRowForAddCommercials.length;// added buy rohit
            if (dataId > 0) {
                const NextvRow = this.listFirstRowForAddCommercials[subRowIndexForParent-1];
                const nextTDR = NextvRow.tdrAmount;

                const nextConvenince = NextvRow.convenienceAmount;

                const prevRow = this.listFirstRowForAddCommercials[dataId - 1];
                const prevTDR = prevRow.tdrAmount;
                const currTDR = row.tdrAmount;
                const preConvenience = prevRow.convenienceAmount;
                const Currentconvenience = row.convenienceAmount;
                if (( Number(prevTDR) == Number(currTDR) || (Number(nextTDR) < Number(currTDR) )  && row.selectedTransactionType === 'TDR') || ( (Number(preConvenience) == Number(Currentconvenience) || (Number(nextConvenince) < Number(Currentconvenience)) ) && row.selectedTransactionType === 'Convenience'
                    ) || (row.selectedTransactionType === 'TDR + Convenience' && (Number(prevTDR) == Number(currTDR) ||  (Number(nextTDR) < Number(currTDR) || Number(preConvenience) >= Number(Currentconvenience))) )) {
                this.errorSelectPayOptions = true;// added by rohit
                this.showErrorMessageForSelectPayOptions = 'Amount is 0, You may add new line if you want commercials based on amount. Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                return;
                }
                else if ((Number(prevTDR) > Number(currTDR) && row.selectedTransactionType === 'TDR') || (Number(preConvenience) > Number(Currentconvenience) && row.selectedTransactionType === 'Convenience'
                    ) || (row.selectedTransactionType === 'TDR + Convenience' && (Number(prevTDR) > Number(currTDR) ||  Number(preConvenience) >= Number(Currentconvenience))) ) {
                        this.errorSelectPayOptions = true;// added by rohit
                        this.showErrorMessageForSelectPayOptions = 'Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                return;
                }
           }
                else if(subRowIndexForParent > 1){// this else condition added by rohit
                const currentRow = this.listFirstRowForAddCommercials[subRowIndexForParent-1];//1
                const prevRow = this.listFirstRowForAddCommercials[subRowIndexForParent-2];//0
                const currTDR = currentRow.tdrAmount;
                const prevTDR = prevRow.tdrAmount;
                const preConvenience = prevRow.convenienceAmount;
                const Currentconvenience = currentRow.convenienceAmount;;
                if ((Number(prevTDR) == Number(currTDR) && row.selectedTransactionType === 'TDR') || (Number(preConvenience) == Number(Currentconvenience) && row.selectedTransactionType === 'Convenience'
                    ) || (row.selectedTransactionType === 'TDR + Convenience' && (Number(prevTDR) == Number(currTDR) ||  Number(preConvenience) >= Number(Currentconvenience))) ) {
                        this.errorSelectPayOptions = true;// added by rohit
                        this.showErrorMessageForSelectPayOptions = 'Amount is 0, You may add new line if you want commercials based on amount. Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                    return;
                }
                else if ((Number(prevTDR) > Number(currTDR) && row.selectedTransactionType === 'TDR') || (Number(preConvenience) > Number(Currentconvenience) && row.selectedTransactionType === 'Convenience'
                    ) || (row.selectedTransactionType === 'TDR + Convenience' && (Number(prevTDR) > Number(currTDR) ||  Number(preConvenience) >= Number(Currentconvenience))) ) {
                        this.errorSelectPayOptions = true;// added by rohit
                        this.showErrorMessageForSelectPayOptions = 'Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                    return;
                }
            }
           /************* */

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
            this.selectetPaymentIndividualObject.listFeeModel = JSON.parse(JSON.stringify(this.listFeeModel));
            this.selectetPaymentIndividualObject.listTransactionType = JSON.parse(JSON.stringify(this.listTransactionType));
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
            this.errorSelectPayOptions = false;// added by rohit
       
    }

    //this method is called when - icon clicked from screen 4 and first/highlighed row 
    removeRowInListFirstRowForAddCommercials(event) {
        let index = event.currentTarget.dataset.id;
        this.listFirstRowForAddCommercials.splice(index, 1);
    }

    //this method is called on click of Apply to all selected link from screen 4
    populateDataForAllSelected(event) {
        this.showScreen4 = false;
        /************Added by rohit : If earlier tdr value are for example 100, 200, 300 and if we want to change the previous value the written below code */
        var PaymentOptionLength = JSON.stringify(this.selectedListPaymentData[this.index].selectedPaymentOptionsList.length);
        const jsonArrayToCheckForFirst = JSON.stringify(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[0].selectedPaymentIndividualList.length);
       // if(jsonArrayToCheckForFirst > 1){
        for(var subIndexForEralierRow=0;subIndexForEralierRow <PaymentOptionLength; subIndexForEralierRow++){
            if(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[subIndexForEralierRow].selectedPaymentIndividualList[0].isChecked) {
                var jsonArray = JSON.stringify(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[subIndexForEralierRow].selectedPaymentIndividualList.length);
                if(jsonArray >1){
                    for(let indexForEarlier = jsonArray-1;indexForEarlier>0;indexForEarlier--){
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[subIndexForEralierRow].selectedPaymentIndividualList.splice(indexForEarlier,1);
                    }
                }
            }
        }
       // }
        /******************End */
        //this.allSelectedValue = [];
        console.log('selectedPaymentOptionsList::416::'+JSON.stringify(this.selectedListPaymentData[this.index].selectedPaymentOptionsList));
        for(let index1=0; index1<this.selectedListPaymentData[this.index].selectedPaymentOptionsList.length; index1++) {
            if(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].isChecked) {
                let lengthSelectedPaymentIndividualList = this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length;
                console.log('lengthSelectedPaymentIndividualList::::::::'+lengthSelectedPaymentIndividualList);
                for(let index2=0;index2<this.listFirstRowForAddCommercials.length;index2++) {
                    console.log('index2:::::::'+index2);
                   
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
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].restrictFlatFeeAndPercentageToBeEdited = this.listFirstRowForAddCommercials[index2].restrictFlatFeeAndPercentageToBeEdited; 
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited = this.listFirstRowForAddCommercials[index2].restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited; 
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].ruleStatus = this.listFirstRowForAddCommercials[index2].ruleStatus; 

                        if(this.listFirstRowForAddCommercials[index2].selectedTransactionType == 'TDR') {
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = true;
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = false;
                            this.getAllDataFOrSaving.push(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1]);
                        }   
                        else if(this.listFirstRowForAddCommercials[index2].selectedTransactionType == 'Convenience') {
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = true;
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = false;
                            this.getAllDataFOrSaving.push(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1]);
                        }   
                        else {
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showTDR = true;
                            this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showConvenience = true;
                            this.getAllDataFOrSaving.push(this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1]);
                        } 
                        console.log('UnselectedData:470:::'+JSON.stringify(this.getAllDataFOrSaving));   
                    }
                    else {
                        console.log('inside else:::425');
                       
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
                            listFeeModel : JSON.parse(JSON.stringify(this.listFeeModel)),
                            listTransactionType : JSON.parse(JSON.stringify(this.listTransactionType)),
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
                            conveniencePercentage : this.listFirstRowForAddCommercials[index2].conveniencePercentage,
                            pricingId : this.listFirstRowForAddCommercials[index2].pricingId,
                            restrictFlatFeeAndPercentageToBeEdited : this.listFirstRowForAddCommercials[index2].restrictFlatFeeAndPercentageToBeEdited,
                            restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited : this.listFirstRowForAddCommercials[index2].restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited,
                            ruleStatus : this.listFirstRowForAddCommercials[index2].ruleStatus
                        };
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[0].isChecked = false;
                        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.push(newInnerRecord); 
                        
                    }
                }
            }
            else{
                console.log('inside else:::::477');
            }
        }
        console.log('all selected Datas::389::::'+JSON.stringify( this.allSelectedValue));
        this.listFirstRowForAddCommercials = [];
        this.listDataForPaymentMode = [];
        this.selectetPaymentIndividualObject.key = this.selectedListPaymentData[this.index].paymentModeName;
        this.selectetPaymentIndividualObject.selectedPaymentOptionName ='--NONE--'// +this.selectedListPaymentData[this.index].paymentModeName +' rate';
        this.selectetPaymentIndividualObject.selectedPaymentOptionId = '';
        this.selectetPaymentIndividualObject.selectedSpecification = '--NONE--';
        this.selectetPaymentIndividualObject.selectedPaymentGatewayName = '';
        this.selectetPaymentIndividualObject.selectedOnusOffus = '';
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
        this.listFirstRowForAddCommercials.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
        this.showScreen4 = true;
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

    //this method is called on click of + icon from screen 4 other that first row
    addrowInListSecondRow(event) {
          /*************if secod parent row or sub row has tdr value as zero then it should give an error :: added by rohit */
          let parentIndex = event.target.dataset.id;
          let parentIndexKey = event.target.dataset.key;
          let subRowIndex =event.target.dataset.key;
          let subRowIndexForParent = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList.length; 
          let tdrAmount = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList[subRowIndex].tdrAmount;
          let selectedTransactionTypeForVali = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList[subRowIndex].selectedTransactionType;
          let convenienceAmountForVali = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList[subRowIndex].convenienceAmount;
          /*******This if condtion written if TDR,Convenience or TDR + Convenience value entered smaller then the previous values then it that case
           * It will give validation error ::: Added by rohit*/
          if (subRowIndex > 0) {
              const NextvRow = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList[subRowIndexForParent-1];
              const nextTDR = NextvRow.tdrAmount;

              const nextConvenince = NextvRow.convenienceAmount;

              const prevRow = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList[subRowIndex-1];
              const prevTDR = prevRow.tdrAmount;
              const currTDR = tdrAmount;
              const preConvenience = prevRow.convenienceAmount;
              const Currentconvenience = convenienceAmountForVali;
              if ( ( (Number(prevTDR) == Number(currTDR) || (Number(nextTDR) < Number(currTDR) ) ) && selectedTransactionTypeForVali === 'TDR') || ( (Number(preConvenience) == Number(Currentconvenience) || (Number(nextConvenince) < Number(Currentconvenience)) ) && selectedTransactionTypeForVali === 'Convenience'
                  ) || (selectedTransactionTypeForVali === 'TDR + Convenience' && (Number(prevTDR) == Number(currTDR) || ( Number(nextTDR) < Number(currTDR) || Number(preConvenience) >= Number(Currentconvenience))) )) {
                      this.errorSelectPayOptions = true;// added by rohit
                      this.showErrorMessageForSelectPayOptions = 'Amount is 0, You may add new line if you want commercials based on amount. Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                return;
              }
              else if ((Number(prevTDR) > Number(currTDR) && selectedTransactionTypeForVali === 'TDR') || (Number(preConvenience) > Number(Currentconvenience) && selectedTransactionTypeForVali === 'Convenience'
                  ) || (selectedTransactionTypeForVali === 'TDR + Convenience' && (Number(prevTDR) > Number(currTDR) ||  Number(preConvenience) >= Number(Currentconvenience))) ) {
                      this.errorSelectPayOptions = true;// added by rohit
                      this.showErrorMessageForSelectPayOptions = 'Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                return;
              }
              
            }
            else if(subRowIndexForParent>1){// This else if condtion added by rohit
                const currentRow = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList[subRowIndexForParent-1];
                const prevRow = this.listDataForPaymentMode[parentIndex].selectedPaymentIndividualList[subRowIndexForParent-2];
                const currTDR = currentRow.tdrAmount;
                const prevTDR = prevRow.tdrAmount;
                const preConvenience = prevRow.convenienceAmount;
                const Currentconvenience = currentRow.convenienceAmount;;
                if ((Number(prevTDR) == Number(currTDR) && selectedTransactionTypeForVali === 'TDR') || (Number(preConvenience) == Number(Currentconvenience) && selectedTransactionTypeForVali === 'Convenience'
                    ) || (selectedTransactionTypeForVali === 'TDR + Convenience' && (Number(prevTDR) == Number(currTDR) ||  Number(preConvenience) >= Number(Currentconvenience))) ) {
                        this.errorSelectPayOptions = true;// added by rohit
                        this.showErrorMessageForSelectPayOptions = 'Amount is 0, You may add new line if you want commercials based on amount. Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                  return;
                }
                else if ((Number(prevTDR) > Number(currTDR) && selectedTransactionTypeForVali === 'TDR') || (Number(preConvenience) > Number(Currentconvenience) && selectedTransactionTypeForVali === 'Convenience'
                    ) || (selectedTransactionTypeForVali === 'TDR + Convenience' && (Number(prevTDR) > Number(currTDR) ||  Number(preConvenience) >= Number(Currentconvenience))) ) {
                        this.errorSelectPayOptions = true;// added by rohit
                        this.showErrorMessageForSelectPayOptions = 'Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)';
                  return;
                }
                
            }
          /*********END */
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
                    listFeeModel : JSON.parse(JSON.stringify(this.listFeeModel)),
                    listTransactionType : JSON.parse(JSON.stringify(this.listTransactionType)),
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
                    conveniencePercentage : '',
                    restrictFlatFeeAndPercentageToBeEdited : false,
                    restrictOtherFieldsOthertThanFlatFeeAndPercentageToBeEdited : false,
                    ruleStatus : 'D'
                };
                /* Added to allow inbetween insertion of the records*/
                let index2Array = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList;
                let index2New = parseInt(index2);
                index2Array.splice(parseInt(index2New)+parseInt(1),0,newInnerRecord);
                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList = index2Array;
                //End | 
                this.listDataForPaymentMode = this.selectedListPaymentData[index].selectedPaymentOptionsList;
                this.errorSelectPayOptions = false;// added by rohit
                this.showScreen4 = true;
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
        this.errorSelectPayOptions = false; // added by rohit
        this.showErrorMessageForSelectPayOptions=''; // added by rohit
    }

    //this method is called on change on change of tdr amount from screen 4 other than first row
    handleTDRAmountForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].tdrAmount = event.detail.value;  
        this.showScreen4 = true;    
    }

    //this method is called on change on change of tdr fee from screen 4 other than first row
    handleTDRFeeForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].tdrFee = event.detail.value;  
        this.showScreen4 = true;     
    }

    //this method is called on change on change of tdr percentage from screen 4 other than first row
    handleTDRPercentageForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].tdrPercentage = event.detail.value;     
        this.showScreen4 = true;  
    }

    //this method is called on change on change of convenience amount from screen 4 other than first row
    handleConvenienceAmountForSecondRow(event) {
        this.showScreen4 = false; 
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].convenienceAmount = event.detail.value;
        this.showScreen4 = true;    
    }

    //this method is called on change on change of convenience fee from screen 4 other than first row
    handleConvenienceFeeForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].convenienceFee = event.detail.value; 
        this.showScreen4 = true;  
    }

    //this method is called on change on change of convenience percentage from screen 4 other than first row
    handleConveniencePercentageForSecondRow(event) {
        this.showScreen4 = false;
        this.selectedListPaymentData[this.index].selectedPaymentOptionsList[event.currentTarget.dataset.id].selectedPaymentIndividualList[event.currentTarget.dataset.key].conveniencePercentage = event.detail.value; 
        this.showScreen4 = true;    
    } 

    //this method is called on click of the Save Pricing button from Screen 4
    savePricing(event) {
        this.errorMessage = '';
        let bothErrorMessageShow = [];
        let showLightGodenForTdrColor = false;// added by rohit
        let showLightGodenForConvienColor = false;// added by rohit
        let showLightGodenForTdrConvColor = false;// added by rohit
        this.showErrorMessage = false;
        let validateData = true;
        let missingTdrAmount=[];
        let missingPaymentModes = [];
        let moreThanCeilingPaymentModes = [];
        let lastValueTDR = null;// added by rohit
        let lastValueCon = null;// added by rohit
        for(let index=0; index < this.selectedListPaymentData.length; index++) {
            for(let index1=0; index1 < this.selectedListPaymentData[index].selectedPaymentOptionsList.length; index1++) {
                let paymentOption = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1]; // added by rohit
                for(let index2=0; index2 < this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length; index2++) {
                    let paymentIndividual = paymentOption.selectedPaymentIndividualList[index2];// added by rohit
                    let currentTdrValue = parseFloat(paymentIndividual.tdrAmount); // added by rohit
                    let currentConvValue = parseFloat(paymentIndividual.convenienceAmount); // added by rohit
                    let selectedTransactionType = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType;//added by rohit
                    let rowLength = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList.length;// added by rohit
                    let isCheckboxForsubRow = this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].showCheckbox;// added by rohit
                   
                    if (selectedTransactionType=='TDR') {// added by rohit 
                       if((selectedTransactionType=='TDR' && currentTdrValue !=0 && lastValueTDR !== null && currentTdrValue <= lastValueTDR  && rowLength>2)  || (!isCheckboxForsubRow  && currentTdrValue==0 && selectedTransactionType=='TDR')) {
                            if(!missingTdrAmount.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingTdrAmount.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            showLightGodenForTdrColor = true;
                        }  
                        else {
                            showLightGodenForTdrColor = false;
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        }
                    }
                    if ( selectedTransactionType=='Convenience') {// added by rohit
                        if((currentConvValue !=0 && lastValueCon !== null && currentConvValue <= lastValueCon  && rowLength>2 )  || (!isCheckboxForsubRow  && currentConvValue==0 && selectedTransactionType=='Convenience')){
                            if(!missingTdrAmount.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingTdrAmount.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            showLightGodenForConvienColor = true;
                         }
                        else{
                            showLightGodenForConvienColor = false;
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                     
                        }
                    }
                    if (selectedTransactionType=='TDR + Convenience') {// added by rohit
                        if((( selectedTransactionType=='TDR + Convenience' && currentConvValue !=0 && currentConvValue <= lastValueCon || selectedTransactionType=='TDR + Convenience' && currentTdrValue !=0 && currentTdrValue <= lastValueTDR )  && rowLength>2)  || (!isCheckboxForsubRow  && currentConvValue==0 && selectedTransactionType=='TDR + Convenience')){
                            if(!missingTdrAmount.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingTdrAmount.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            showLightGodenForTdrConvColor = true;
                         }
                        else{
                            showLightGodenForTdrConvColor = false;
                            this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        }
                    }
                        lastValueTDR = currentTdrValue;// added by rohit
                        lastValueCon = currentConvValue;// added by rohit
                    if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'TDR') {
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee == '' && this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage == '') {
                            if(!missingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            if(showLightGodenForTdrColor){// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#FFD580;';
                            }
                            else{// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            }
                            //this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            //break;
                        }  
                        else {
                            if(showLightGodenForTdrColor){// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#FFD580;';
                            }
                            else{// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                            }
                           
                        }  
                    }
                    else if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].selectedTransactionType == 'Convenience') {
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].convenienceFee == '' && this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].conveniencePercentage == '') {
                            if(!missingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            if(showLightGodenForConvienColor){// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#FFD580;';
                            }
                            else{// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            }
                            //this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            //break;
                        } 
                        else {
                            if(showLightGodenForConvienColor){// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#FFD580;';
                            }
                            else{// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                            }
                            //this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        }
                    }
                    else {
                        if(this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrFee == '' && this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].tdrPercentage == '') {
                            if(!missingPaymentModes.includes(this.selectedListPaymentData[index].paymentModeName)) {
                                missingPaymentModes.push(this.selectedListPaymentData[index].paymentModeName);
                            }
                            validateData = false;
                            if(showLightGodenForTdrConvColor){ // this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#FFD580;';
                            }
                            else{// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            }
                            //this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#f4e8bd;';
                            //break;
                        }
                        else {
                            if(showLightGodenForConvienColor){// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:#FFD580;';
                            }
                            else{// this if else condition added by rohit
                                this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                            }
                            //this.selectedListPaymentData[index].selectedPaymentOptionsList[index1].selectedPaymentIndividualList[index2].backgroundColor = 'background-color:white;';
                        } 
                        /*Commented By rohit
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
                        }*/
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

        /*let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                validateData = false;
            }
        }); */

        if(this.commercialName === '') {
            validateData = false;
            //firing event 
            const selectEvent = new CustomEvent('selectionvalidate', {});
            this.dispatchEvent(selectEvent);
        }
        
        if(validateData) {
            this.disabledSavePricingButton = true;
            this.showSpinner = true;
            savePricingApex({selectedListPaymentData : JSON.stringify(this.selectedListPaymentData),recordId : this.recordId,commercialName : this.commercialName,selectedTemplate : this.selectedTemplate,commercialId : this.commercialId})
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
                    //this.hideScreen3Step2 = 'display:none';
                    //this.showScreen5 = true;
                    this.commercialId = result.message.split('#')[1];
                    //this.pathNumber = '3';
                    this.disabledCommercialName = true;
                    this.listFallbackCharges = JSON.parse(result.listFallbackChargesString);
                    this.listFixedPricing2 = JSON.parse(result.listFixedPricing2String);
                    this.listPlatformFee = JSON.parse(result.listPlatformFeeString);
                    this.availableInterval = result.listPlatformFeeInterval;
                    this.availableType = result.listPlatformFeeType;
                    this.availableDebitModel = result.listPlatformFeeDebitModel;
                    this.availableIntervalFP = result.listFixedPricingFeeInterval;
                    this.availableDebitModelFP = result.listFixedFeeDebitModel;
                    this.selectedInterval = result.selectedInterval;
                    this.selectedType = result.selectedType;
                    this.selectedStartDate = result.selectedStartDate;
                    this.selectedEndDate = result.selectedEndDate;
                    this.selectedDebitModel = result.selectedDebitModel; 

                    this.showToast('SUCCESS','success','Pricing Records Created Successfully');

                    //firing event 
                    const selectEvent = new CustomEvent('selection', {
                        detail : { 
                            selectedListPaymentData : this.selectedListPaymentData,
                            showBelowRackRateMessage : this.showBelowRackRateMessage,
                            belowRackRateMessage : this.belowRackRateMessage,
                            commercialId : this.commercialId,
                            disabledCommercialName : this.disabledCommercialName,
                            listFallbackCharges : this.listFallbackCharges,
                            listFixedPricing2 : this.listFixedPricing2,
                            listPlatformFee : this.listPlatformFee,
                            availableInterval : this.availableInterval,
                            availableType : this.availableType,
                            availableDebitModel : this.availableDebitModel,
                            availableIntervalFP : this.availableIntervalFP,
                            availableDebitModelFP : this.availableDebitModelFP,
                            selectedInterval : this.selectedInterval,
                            selectedType: this.selectedType,
                            selectedDebitModel : this.selectedDebitModel,
                            selectedStartDate : this.selectedStartDate,
                            selectedEndDate : this.selectedEndDate
                        }
                    });
                    this.dispatchEvent(selectEvent); 
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
            console.log('missingPaymentModes.length::::'+missingPaymentModes.length);
            console.log('missingTdrAmount.length::::'+missingTdrAmount.length);
            if(missingPaymentModes.length > 0) {
                this.showErrorMessage = true; // Commented by rohit
                this.errorMessage = 'Payment options missing price :  '+missingPaymentModes.toString()
                console.log(' this.errorMessage::::870');
                bothErrorMessageShow.push(this.errorMessage);
               
            }
            /*******Added by rohit */
            if(missingTdrAmount.length > 0) {
                this.showErrorMessage = true; // Commented by rohit
                this.errorMessage  += '<br/>'+ 'Please make sure amount is next line is greater than previous value. (Eg >0-- 1%, >1000 - 2%, >2000- 1.8%)'
                console.log(' this.errorMessage::::880');
                bothErrorMessageShow.push(this.errorMessage);
            }
            /*if(bothErrorMessageShow.length>0){
                this.showErrorMessage = true;
            }*/
            /*************END */
            if(moreThanCeilingPaymentModes.length > 0) {
                this.showErrorMessage = true;
                this.errorMessage = 'Payment options pricing more than cieling :  '+moreThanCeilingPaymentModes.toString();
            }
        }
    } 

  //Method called on click of Payment Mode to show its respective Data : Screen 4
  getListForPaymentMode(event) {
    this.PaymentOptionPicklistValue='--NONE--';
    this.specificationPicklistValue = '--NONE--';//added by rohit 19th april
    console.log('currentTarget1198::::'+JSON.stringify(this.selectedListPaymentData[event.currentTarget.dataset.id].selectedPaymentOptionsList));
    //this.isClickedOnAnotherTab = true;
    if(event.currentTarget.dataset.id !=='0'){
        this.allDataShow = [];
        this.allDataShow  = this.originalSelectedData[event.currentTarget.dataset.id].selectedPaymentOptionsList;
        this.isClickedOnAnotherTab = true;
    }
    else if(event.currentTarget.dataset.id=='0'){
        this.allPickListDataForFirstRow =  this.originalSelectedData[0].selectedPaymentOptionsList;
        this.allDataShow = this.allPickListDataForFirstRow;
   }
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

     /******Added by rohit Part 2 story */
    this.paymentOptions =[];
    this.specificationOptions =[];
      /******Added by rohit Part 2 story */
      this.paymentOptions.push({
        label: '--NONE--',
        value: '--NONE--',
    });
    for (const item of this.allDataShow) {
        for (const paymentOption of item.selectedPaymentIndividualList) {
            if(!this.paymentOptions.find((option) => option.label === paymentOption.selectedPaymentOptionName)){
                this.paymentOptions.push({
                    label: paymentOption.selectedPaymentOptionName,
                    value: paymentOption.selectedPaymentOptionName
                });
            }
        }
       
      }
       /**********Get specification */
       this.specificationOptions.push({
        label: '--NONE--',
        value: '--NONE--',
        });
       for (const item of this.allDataShow) {
        for (const paymentOption of item.selectedPaymentIndividualList) {
            if(!this.specificationOptions.find((option) => option.label === paymentOption.selectedSpecification)){
                this.specificationOptions.push({
                label: paymentOption.selectedSpecification,
                value: paymentOption.selectedSpecification
                });
            }
        }
    }
    /*******END************/
    
    /**********End*********** */
    this.selectetPaymentIndividualObject.key = this.selectedListPaymentData[0].paymentModeName;
    this.selectetPaymentIndividualObject.selectedPaymentOptionName ='--NONE--';// +this.selectedListPaymentData[event.currentTarget.dataset.id].paymentModeName +' rate';//'--NONE--';//'Set a default rate';//
    this.selectetPaymentIndividualObject.selectedPaymentOptionId = '';
    this.selectetPaymentIndividualObject.selectedSpecification = '--NONE--';
    this.selectetPaymentIndividualObject.selectedPaymentGatewayName = '';
    this.selectetPaymentIndividualObject.selectedOnusOffus = '';
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

    this.listFirstRowForAddCommercials.push(JSON.parse(JSON.stringify(this.selectetPaymentIndividualObject)));
    console.log('listFirstRowForAddCommercials:::::::1374:::'+JSON.stringify(this.listFirstRowForAddCommercials));
     this.showScreen4 = true; 
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
}