import { LightningElement,wire,track,api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PRICING_OBJECT from '@salesforce/schema/Pricing__c';
import PRICING_FIELD from '@salesforce/schema/Pricing__c.Bank__c';
import PORTYPE from '@salesforce/schema/Pricing__c.POR_Type__c';
import Status from '@salesforce/schema/Pricing__c.Status__c';
import BANKINGOPS_FIELD from '@salesforce/schema/Pricing__c.Banking_Ops_Status__c';
import getOppList from '@salesforce/apex/BankingOpsModuleController.getBankingPickListValues';
import ChangeStatusValue from '@salesforce/apex/BankingOpsModuleController.getStatusValueUpdate';
import OwnerAssignment from '@salesforce/apex/BankingOpsModuleController.OwnerAssignmentLogic';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getDynamicTableDataList from '@salesforce/apex/BankingOpsModuleController.GetWrapperOfSObjectFieldColumnActionValues';
import getProfileName from '@salesforce/apex/BankingOpsModuleController.getProfileName';
import getBankAndPorType from '@salesforce/apex/BankingOpsModuleController.getBankAndPorType';//Need to Uncomment
import searchBank from '@salesforce/apex/BankingOpsModuleController.searchBank';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getApprovedOrRejectedData from '@salesforce/apex/BankingOpsModuleController.getApprovedOrRejectedData';
import Requestsassignedtome from '@salesforce/apex/BankingOpsModuleController.Requestsassignedtome';
const FIELD_NAME = 'Bank_Image__c';
export default class BankingOps extends NavigationMixin(LightningElement) {
    bankSelectValue
    openPoRTypePage = false; //When bank is selected then It will open as True
    checkForPORType;
    recdNotFoundFOrMerchant
    openChatterPopup= false;
    noRecordsForRequestForMerchant=false; //If bank and UPI both are selected and there will be no records for this then it will show no records
    NoneValue
    disableSection = false; // When Bank will be seleceted then accept POR type all section we'ill not be to see

    pricingStatusData=[];
    pricingCount=[];
    fieldNameFOrObject = [];
    filterApply=false;
    applyToShow = true; 
    disableStatus = true;
    pricingDataForUpdate
    finalSObjectDataListTOUpdateStatus
    lstSelectedRecords=[];
    statausVal
    value = 'All';
    valueForRequest = 'All Request';
    cols=[];
    columndata;
     headerValues=[];
    noRecordsForRequest
    noRecordsForPaymentGatway
    recdNotFound ;
    downloadOption =false;
    pymentGatRequest
    pymentGatPaymentMode
    @track DataTableResponseWrappper;
    @track finalSObjectDataList=[];
    @track oppListVar;
    Pricingvalue;
    bankingValue
    columnName;
    selectedRowsCollect;
    @track hrefdata;  
    @track isShowModal = false;
    @track isNext = true;
    openChatterPopupoForBanking = false;
    openChatterPopupoForPricing = true;
    saveDraftValues = [];
    @track pricingContrl;
    @track porTypeDependent;
    @track slaFieldData
    @api recordId 
    @api pName;
    
    @api showfirstScreen=false;
    banks = [];
    bankAndPorType=[]
    @api imageUrl;
    PORTypeName
    searchTerm
    openButtonForPendingWithBank = false;
    isModalOpenForApproved = false;
    openButtonForPendingWithBankOps = false;
    approveOrRejecvtedData;
    noAppOrReject;
    isAppOrRecj=false;
    RequestsassignedtomeList=[];
    /******END*************/
    @wire(getObjectInfo, { objectApiName: PRICING_OBJECT })
    pricingMetadata;

    callEmailMethod() {
        var pageRef = {
            type: "standard__quickAction",
            attributes: {
                apiName: "Global.SendEmail"
            },
            state: {
                recordId: '0060p00000D40mzAAB',
                defaultFieldValues:
                encodeDefaultFieldValues({
                    HtmlBody : "", 
                    Subject : "Pre-populated Subject of the Email"
                })
            }
        };

        this[NavigationMixin.Navigate](pageRef);
    }
    connectedCallback(){
        this.showfirstScreen = true;// Need to uncomment
        getProfileName()
        .then(result => {
            this.pName = result;
        })
        .catch(error => {
            this.error = error;
        });
        getBankAndPorType()
        .then(result => {
            this.bankAndPorType = result;
        })
        .catch(error => {
            this.error = error;
        });
    }
    
        //this is used to show all the POR type on UI to Select
 
   
      //this is used to show all the banks on UI to Select
      @wire(getPicklistValues,
        { 
            recordTypeId: '$pricingMetadata.data.defaultRecordTypeId', 
            fieldApiName: PRICING_FIELD
        }
    )
   pricingPicklist({ data }) {
    if (data) {
        this.banks = data.values.map(picklistValue => ({
            label: picklistValue.label,
            value: picklistValue.value,
            imageUrl: `/resource/${picklistValue.value}`,
           /* options: picklistValue.value.fields.POR_Type__c.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
              }))*/
      }));
    }
  }
    @wire(getPicklistValues,
        {
            recordTypeId: '$pricingMetadata.data.defaultRecordTypeId', 
            fieldApiName: PORTYPE
        }
    )
    PORPicklist;
  
    //this is used to change status on UI   
    @wire(getPicklistValues,
        {
            recordTypeId: '$pricingMetadata.data.defaultRecordTypeId', 
            fieldApiName: BANKINGOPS_FIELD
        }
    )
    bankingOpsPicklist;

    @wire(getPicklistValues,
        {
            recordTypeId: '$pricingMetadata.data.defaultRecordTypeId', 
            fieldApiName: Status
        }
    )
    statusPicklist;

    handleSave(event) { // this method is used for while editing the Remarks field and save .
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.ShowToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.saveDraftValues = [];
            return this.refresh();
        }).catch(error => {
            this.ShowToast('Error', 'An Error Occured!! Status is wrong, Please put the exact values', 'error', 'dismissable');
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }
    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(evt);
    }
 
    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.finalSObjectDataList);
    }

    hideModalBox() {  
        this.isShowModal = false;
    }
    handleSearchTermChange(event){
        this.searchTerm =  event.target.value;
        searchBank({searchTerm: this.searchTerm})
        .then(result => {
            this.bankAndPorType = result;
          })
          .catch(error => {
            console.error(error);
          });
    }
    bnakHandleChange(event){ // When bank will be selected then storing the values in this method
        let combobox = this.template.querySelector("[data-id='Controlling Bank Picklist Type']");
        this.bankSelectValue = combobox ? combobox.value : null;
        this.openPoRTypePage = true; //When bank is selected then It will open as True
        this.NoneValue = '--None--';
        this.disableSection = false; //When Bank will be seleceted then accept POR type all section we'll not be to see
        
        let comboboxforPor = this.template.querySelector("[data-id='Controlling Picklist Type']"); // getting the selected values based upon data-id
        let PORNamefromBankMethod = comboboxforPor ? comboboxforPor.value : null;
        this.handleChange(this.bankSelectValue,PORNamefromBankMethod) //When click of refresh button then this functionality get call.
    }
    porTypeHandleChange(){
        let combobox = this.template.querySelector("[data-id='Controlling Picklist Type']"); // getting the selected values based upon data-id
        let PORName = combobox ? combobox.value : null;
        this.handleChange(this.bankSelectValue,PORName)
    }
    scrollToBack() {
        //this.showfirstScreen = false;
      }
    redirectToSecondPage(event){
        this.showfirstScreen = true;// Need to uncomment to redirect the 2nd page
        const bank = event.target.dataset.bank;
        const porType = event.target.dataset.porType;
        [this.bankSelectValue, this.PORTypeName] = [bank, porType].map(str => str.split('-')[0]);

        this.disableSection = true;
        this.checkForPORType = true;
        this.selectedValue =true;
        //this.handleChange(this.bankSelectValue, this.PORTypeName);

    }
    handleChange(bankSelectValue,PORTypeName) { // THis method will be called when PaymentGateway&PaymentMode select then it will dispaly the records accordingly.
        this.noRecordsForPaymentGatway = true;
        this.noRecordsForRequestForMerchant = false;
        this.filterApply = true;
      
       getDynamicTableDataList({bankName : bankSelectValue,porNameVar : PORTypeName}) // sending bank value and POR type value to server when getting response deplaying that one
        .then(result => {
        if(result !=null) { //&& PORName.length !=0 // Need to comment this line
            this.disableSection = true; // When Bank will be seleceted and  POR type will be selected then all section we'll  be to see
            if(result.lstDataTableData.length !=0 ){
                let sObjectRelatedFieldListValues = [];
                this.checkForPORType = true;
                    for(let row of result.lstDataTableData) {
                        this.headerValues = result.headerValue.replace(',Banking Ops Status','');
                        this.pricingCount.push(row.Pricings__r);
                        const finalSobjectRow = {}
                        let rowIndexes = Object.keys(row); 
                        rowIndexes.forEach((rowIndex) => {
                        const relatedFieldValue = row[rowIndex];
                        if(relatedFieldValue.constructor === Object) { //This functionallity for displaying the Opp Data When Selected PaymentGateway&PaymentMode
                            this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)     
                        }
                        else {
                            finalSobjectRow[rowIndex] = relatedFieldValue;
                            if( finalSobjectRow[rowIndex] ){
                                //result.lstDataTableData.forEach(item => item['Prod_Merchant_Id__c'] = '/lightning/r/Account/' +item['Id'] +'/view');
                            }
                        }
                    });
                    if(row.Pricings__r !=undefined){
                        for(let rows of row.Pricings__r){ //This functionallity is used for displaying the Pricing Data When Selected PaymentGateway&PaymentMode
                                let rowIndexesForPricing = Object.keys(rows);
                                rowIndexesForPricing.forEach((rowIndexPr) => {
                                const relatedFieldValue = rows[rowIndexPr];
                                    if(relatedFieldValue.constructor === Object) {
                                        this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexPr)     
                                    }
                                    else {
                                        finalSobjectRow[rowIndexPr] = relatedFieldValue;
                                        //console.log('finalSobjectRow[rowIndexPr]:::'+JSON.stringify(finalSobjectRow[rowIndexPr]));
                                    }
                                 });
                        }
                    }
                    if(row.Address_Details__r !=undefined){ // This functionallity is used for displaying the Address Data When Selected PaymentGateway&PaymentMode
                        for(let rowsAdd of row.Address_Details__r){
                            let rowIndexesForAddress = Object.keys(rowsAdd);
                            rowIndexesForAddress.forEach((rowIndexAd) => {
                                const relatedFieldValue = rowsAdd[rowIndexAd];
                                if(relatedFieldValue.constructor === Object) {
                                    this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexAd)     
                                }
                                else {
                                    finalSobjectRow[rowIndexAd] = relatedFieldValue;
                                }
                            });
                        }
                    }
                    if(row.Website_Pages__r !=undefined){ // This functionallity is used for displaying the Address Data When Selected PaymentGateway&PaymentMode
                        for(let rowsWeb of row.Website_Pages__r){
                            let rowIndexesForWeb= Object.keys(rowsWeb);
                            rowIndexesForWeb.forEach((rowIndexAd) => {
                            const relatedFieldValue = rowsWeb[rowIndexAd];
                                if(relatedFieldValue.constructor === Object) {
                                    this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexAd)     
                                }
                                else {
                                        finalSobjectRow[rowIndexAd] = relatedFieldValue;
                                }
                            });
                        }
                    }
                    if(row.Bank_Account_Details__r !=undefined){ // This functionallity is used for displaying the Address Data When Selected PaymentGateway&PaymentMode
                        for(let rowsWeb of row.Bank_Account_Details__r){
                            let rowIndexesForWeb= Object.keys(rowsWeb);
                            rowIndexesForWeb.forEach((rowIndexAd) => {
                            const relatedFieldValue = rowsWeb[rowIndexAd];
                                if(relatedFieldValue.constructor === Object) {
                                    this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexAd)     
                                }
                                else {
                                        finalSobjectRow[rowIndexAd] = relatedFieldValue;
                                }
                            });
                        }
                    }
                    sObjectRelatedFieldListValues.push(finalSobjectRow);
                
            }
                this.DataTableResponseWrappper = result;
                this.cols =  this.DataTableResponseWrappper.lstDataTableColumns.map(col => {
                    return {
                        label: col.label,
                        fieldName: col.fieldName,
                        type: col.type,
                        initialWidth: 135 // store the initial width in the column definition
                    };
                  });
                this.fieldNameFOrObject.length = 0;
                
                for (let row of result.lstDataTableColumns) { // This for Loop is used for getting all the Field API name so that we can show field label on excel
                    if(row.fieldName=='Banking_Ops_Status__c'){
                    }
                    else{
                        this.fieldNameFOrObject.push(row.fieldName);
                    }
                }
                this.pricingStatusData = JSON.stringify(this.pricingCount);
                var countForPendingWithBankingOps = 0;
                var countForPendingWithKam = 0;
                for(var i = 0; i < this.pricingStatusData.length; i++){
                    if(this.pricingStatusData[i].Banking_Ops_Status__c == 'Pending with Banking ops'){
                        countForPendingWithBankingOps++;
                    }
                    if(this.pricingStatusData[i].Banking_Ops_Status__c == 'Pending with KAM'){
                        countForPendingWithKam++;
                    }
                }
                this.isNext  = false;
                this.finalSObjectDataList =  sObjectRelatedFieldListValues;
                //console.log('this.finalSObjectDataList::::'+JSON.stringify(this.finalSObjectDataList));
            }
        } 
        })
        .catch(error => {
            this.error = error;
            if(PORTypeName !=null){
                this.noRecordsForRequestForMerchant = true;
            }
            this.checkForPORType = false;
            this.disableSection = true; // When Bank will be seleceted and  POR type will be selected then all section we'll  be to see
            this.recdNotFoundFOrMerchant='No records has been found related to this request';
        });
        this.selectedValue =true;
    }
// New Code Start
    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {        
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => 
        {
            let finalKey = fieldName + '.'+ key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }

    getStatusChangeValue(event){
        this.statausVal = event.target.value;
        this.applyToShow = false;
    }

    handleRowAction(event) {
        this.openChatterPopup = true;
        const id = event.target.dataset.id;
        const row = this.finalSObjectDataList.find(record => record.Id === id);
        /*let comboboxBank = this.template.querySelector("[data-id='Controlling Bank Picklist Type']");
        let bankName = comboboxBank ? comboboxBank.value : null;

        let comboboxPor = this.template.querySelector("[data-id='Controlling Picklist Type']");
        let PORName = comboboxPor ? comboboxPor.value : null;*/
        var currUserProfileName = this.pName;
        OwnerAssignment({oppId :row.Pricings__r[0].Opportunity__c,bankingOpsStatus:row.Pricings__r[0].Banking_Ops_Status__c,bankNameVal:this.bankSelectValue,PORName:this.PORTypeName})
        .then(result=>{
            var paramData = {pricingId:row.Pricings__r[0].Id,statusValues:this.statusPicklist.data.values,bankingOpsStatus:row.Pricings__r[0].Banking_Ops_Status__c,ownerAssignMent:result,oppId :row.Pricings__r[0].Opportunity__c,bankNameVal:this.bankSelectValue,porType:this.PORTypeName,currUserProfileName:currUserProfileName};
            let ev = new CustomEvent('childmethod',{detail :paramData});
            this.dispatchEvent(ev);  
        })
       .catch(error=>{
           this.error = error;
       })
    } 

// New Code End
handleRowSelection = event => { // This method is used for selecting the checbox and get the row data.
    var selectedRows=event.detail.selectedRows;
    this.selectedRowsCollect = selectedRows;
    this.disableStatus = false;
    this.applyToShow = false;
    if( this.selectedRowsCollect == ''){
        this.disableStatus = true;
        this.applyToShow = true;;
    }
   
}
openPopupForApproved(){
    this.isModalOpenForApproved = true;
}
closeModal(){
    this.isModalOpenForApproved = false;
}
getSelectedRec(event) { // This method will be called when records will be selected for status update then It will fire and refresh the data 
    var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
    const changeStatusValue = event.target.dataset.defaultValue;
    if(selectedRecords.length > 0){
        let ids = '';
        selectedRecords.forEach(currentItem => {
            ids = ids + ',' + currentItem.Id;
        });
        this.selectedIds = ids.replace(/^,/, '');
        this.lstSelectedRecords = selectedRecords;
        let pricingDataForStore = [];
        for(let rowsAdd of this.lstSelectedRecords){
            for(let row of rowsAdd.Pricings__r){
                pricingDataForStore.push(row);
            }
        }
        this.pricingDataForUpdate =  pricingDataForStore;
        let comboboxBank = this.template.querySelector("[data-id='Controlling Bank Picklist Type']");
        let bankName = comboboxBank ? comboboxBank.value : null;
        let combobox = this.template.querySelector("[data-id='Controlling Picklist Type']");
        let PORName = combobox ? combobox.value : null;

        ChangeStatusValue({pricingList : this.pricingDataForUpdate, statusvalue : changeStatusValue,bankName:this.bankSelectValue,PORName:this.PORTypeName})
        .then(result=>{
            if(result){
                this.ShowToast('Success', 'Status Updated Successfully!', 'success', 'dismissable');
                if(this.filterApply){
                    this.handleChange();
                }
                if(this.filterApply==false){
                    this.AllRequesthandleChange();
                }
                return this.refresh();
            }
        })
       .catch(error=>{
           this.error = error;
       })
           
    }   
}
handleRecordClick(event) {
    const recordId = event.target.dataset.id;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        objectApiName: 'Pricing__c',
        actionName: 'view'
      }
    });
  }
    Requestsassignedtome(event){
        Requestsassignedtome()
        .then(result=>{
            if(result){
                this.RequestsassignedtomeList = result;
                console.log('RequestsassignedtomeList:::::'+JSON.stringify(this.RequestsassignedtomeList));
            }
        })
       .catch(error=>{
            this.error = error;

       })
    }
    getApprovedOrRejectedData(event){
        const labelValue = event.target.label;
        console.log('labelValue:::::'+labelValue);
        let data = getApprovedOrRejectedData({appOrReject : labelValue})
        .then(result=>{
            if(result){
              this.approveOrRejecvtedData = result;
              this.isAppOrRecj = true;
            }
            else{
                this.isAppOrRecj = false;
                this.noAppOrReject = 'There are no ' + labelValue +' record found';
            }
        })
       .catch(error=>{
            this.error = error;

       })
    }
    AllRequesthandleChange(event){// This method is used for filltering the records based on banking ops status
        const labelValue = event.target.label;
        this.filterApply = false;

        let combobox = this.template.querySelector("[data-id='Controlling Picklist Type']");
        this.noRecordsForPaymentGatway = true;
        let PORName = combobox ? combobox.value : null;

       // getOppList({req : typeOfCaseForRequest,bankName : this.bankSelectValue,porNameVar : PORName})
        getOppList({req : labelValue,bankName : this.bankSelectValue,porNameVar : this.PORTypeName})
        .then(result => {
            if(result) {
                if(result.lstDataTableData.length !=0 ){
                    this.noRecordsForPaymentGatway = true;
                    this.noRecordsForRequest = false;
                    let sObjectRelatedFieldListValues = [];
                
                    for (let row of result.lstDataTableData) {
                        const finalSobjectRow = {}
                      
                         let rowIndexes = Object.keys(row); 
                         rowIndexes.forEach((rowIndex) => {
                             const relatedFieldValue = row[rowIndex];
                             if(relatedFieldValue.constructor === Object) {
                                 this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                             }
                             else {
                                 finalSobjectRow[rowIndex] = relatedFieldValue;
                             }
                             
                         });
                         if(row.Pricings__r !=undefined){
                                for(let rows of row.Pricings__r){
                                    let rowIndexesForPricing = Object.keys(rows);
                                    rowIndexesForPricing.forEach((rowIndexPr) => {
                                    const relatedFieldValue = rows[rowIndexPr];
                                 
                                    if(relatedFieldValue.constructor === Object) {
                                        this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexPr)     
                                    }
                                    else {
                                        finalSobjectRow[rowIndexPr] = relatedFieldValue;
                                    }
                                    
                                });
                            
                            }
                         }
                       if(row.Address_Details__r !=undefined){ // This functionallity for displaying the Address Fields
                            for(let rowsAdd of row.Address_Details__r){
                                let rowIndexesForAddress = Object.keys(rowsAdd);
                                rowIndexesForAddress.forEach((rowIndexAd) => {
                                const relatedFieldValue = rowsAdd[rowIndexAd];
                                if(relatedFieldValue.constructor === Object) {
                                    this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexAd)     
                                }
                                else {
                                    finalSobjectRow[rowIndexAd] = relatedFieldValue;
                                }
                                
                            });
                        
                            }
                        }
                        if(row.Website_Pages__r !=undefined){ // This functionallity is used for displaying the Address Data When Selected PaymentGateway&PaymentMode
                            for(let rowsWeb of row.Website_Pages__r){
                                let rowIndexesForWeb= Object.keys(rowsWeb);
                                rowIndexesForWeb.forEach((rowIndexAd) => {
                                const relatedFieldValue = rowsWeb[rowIndexAd];
                                if(relatedFieldValue.constructor === Object) {
                                    this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexAd)     
                                }
                                else {
                                    finalSobjectRow[rowIndexAd] = relatedFieldValue;
                                }
                            });
                            }
                        }
                        if(row.Bank_Account_Details__r !=undefined){ // This functionallity is used for displaying the Address Data When Selected PaymentGateway&PaymentMode
                            for(let rowsWeb of row.Bank_Account_Details__r){
                                let rowIndexesForWeb= Object.keys(rowsWeb);
                                rowIndexesForWeb.forEach((rowIndexAd) => {
                                const relatedFieldValue = rowsWeb[rowIndexAd];
                                if(relatedFieldValue.constructor === Object) {
                                    this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndexAd)     
                                }
                                else {
                                        finalSobjectRow[rowIndexAd] = relatedFieldValue;
                                }
                            });
                            
                            }
                        }
                         sObjectRelatedFieldListValues.push(finalSobjectRow);
                     }
                     this.DataTableResponseWrappper = result;


                     this.cols =  this.DataTableResponseWrappper.lstDataTableColumns.map(col => {
                        return {
                            label: col.label,
                            fieldName: col.fieldName,
                            type: col.type,
                            initialWidth: 135 // store the initial width in the column definition
                        };
                      });
                    this.fieldNameFOrObject.length = 0;
                    
                    for (let row of result.lstDataTableColumns) { // This for Loop is used for getting all the Field API name so that we can show field label on excel
                        if(row.fieldName=='Banking_Ops_Status__c'){
                        }
                        else{
                            this.fieldNameFOrObject.push(row.fieldName);
                        }
                    }


                     this.finalSObjectDataList = sObjectRelatedFieldListValues;
                     //console.log('fielterALl:::'+JSON.stringify(this.finalSObjectDataList));
                     
                     this.columnName = JSON.stringify(this.DataTableResponseWrappper.label) ;
                    if(labelValue==='New Requests'){
                        this.downloadOption = true; 
                        this.openButtonForPendingWithBank = false;
                        this.openButtonForPendingWithBankOps = false;
                       
                    }
                    else if(labelValue==='Pending With Bank'){
                        this.openButtonForPendingWithBank = true; 
                        this.openButtonForPendingWithBankOps = false;
                        this.downloadOption = false;
                       
                    }
                    else if(labelValue==='Pending With Banking Ops'){
                        this.openButtonForPendingWithBankOps = true;
                        this.openButtonForPendingWithBank = false; 
                        this.downloadOption = false;
                     }
                    
                     else if(labelValue==='Closed'){
                        this.openButtonForPendingWithBankOps = false;
                        this.openButtonForPendingWithBank = false; 
                        this.downloadOption = false; 
                     }
                  
                }
                else{
                    this.noRecordsForRequest = true;
                    this.noRecordsForPaymentGatway = false;
                    this.recdNotFound='No records has been found related to this request';
                    this.downloadOption = false;
                    if(labelValue==='New Requests'){
                        this.openButtonForPendingWithBank = false;
                        this.openButtonForPendingWithBankOps = false;
                       
                    }
                    else if(labelValue==='Pending With Bank'){
                        this.openButtonForPendingWithBankOps = false;
                        this.downloadOption = false;
                       
                    }
                    else if(labelValue==='Pending With Banking Ops'){
                        this.openButtonForPendingWithBank = false; 
                        this.downloadOption = false;
                    }
                    else if(labelValue==='Pending With KAM'){
                        this.openButtonForPendingWithBankOps = false;
                        this.openButtonForPendingWithBank = false; 
                        this.downloadOption = false; 
                     }
                    else if(labelValue==='Closed'){
                        this.openButtonForPendingWithBankOps = false;
                        this.openButtonForPendingWithBank = false; 
                        this.downloadOption = false; 
                     }
                } 
            }
            
            })
            .catch(error => {
                this.error = error;
            });
        
    }
    exportContactData(event) { // This method is used for download the records into the csv formate.
        let comboboxBank = this.template.querySelector("[data-id='Controlling Bank Picklist Type']");
        let bankName = comboboxBank ? comboboxBank.value : null;

        let combobox = this.template.querySelector("[data-id='Controlling Picklist Type']");
        let typeOfCase = combobox ? combobox.value : null;
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        // getting keys from data
        this.finalSObjectDataList.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                if(key !== 'Pricings__r' && key !=='Opportunity__c' && key !=='Id' && key !=='Banking_Ops_Status__c'){
                    rowData.add(key);
                }
              
            });
        });
         // Array.from() method returns an Array object from any object with a length property or an iterable object.
       
         rowData = Array.from(rowData);
         // splitting using ','
        //csvString +=rowData.join(',');
        csvString += this.headerValues;
        csvString += rowEnd;
         // main for loop to get the data based on key value
            for(let i=0; i < this.finalSObjectDataList.length; i++){
                let colValue = 0;
                // validating keys in data
                for(let key in  this.fieldNameFOrObject) {
                        let rowKey =  this.fieldNameFOrObject[key];
                        // add , after every value except the first.
                        if(colValue > 0){
                            csvString += ',';
                        }
                        // If the column is undefined, it as blank in the CSV file.
                        let value = this.finalSObjectDataList[i][rowKey] === undefined ? ' ' : this.finalSObjectDataList[i][rowKey];
                        csvString += '"'+ value +'"';
                        colValue++;
                  //  }
                }
                csvString += rowEnd;
            }
                    // Creating anchor element to download
                let downloadElement = document.createElement('a');

                // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
                downloadElement.target = '_self';
                // CSV File Name
                downloadElement.download = bankName+typeOfCase+'.csv';
                // below statement is required if you are using firefox browser
                document.body.appendChild(downloadElement);
                // click() Javascript function to download CSV file
                downloadElement.click(); 

      } 
}