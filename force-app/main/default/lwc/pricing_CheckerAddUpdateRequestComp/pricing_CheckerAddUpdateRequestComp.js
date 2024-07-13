import { LightningElement,api, track } from 'lwc';
import getDataOnLoad from '@salesforce/apex/Pricing_CheckerViewCompController.getDataOnLoad';
import handleApprovePricing from '@salesforce/apex/Pricing_CheckerViewCompController.handleApprovePricing';
import handleRejectPricing from '@salesforce/apex/Pricing_CheckerViewCompController.handleRejectPricing';
import LightningConfirm from 'lightning/confirm';
import LightningPrompt from 'lightning/prompt';
import LightningAlert from 'lightning/alert';

export default class Pricing_CheckerAddUpdateRequestComp extends LightningElement {
    @api oppId;
    showSpinner = false;
    
    @track pricingDetail = {
        listPricing : [],
        showList : false
    }
    @track fixedPricingDetail = {
        listFixedPricing : [],
        showList : false
    }
    @track platformFeeDetail = {
        listPlatformPricing : [],
        showList : false
    }
    disableButton = true;
    editAllowed = true;
    selectedRecordIds = [];
    selectedRecordIdsFixed = [];

    selectAllData = false;
    selectAllDataFixed = false;

    showButtons = false;

    
    connectedCallback(){
        this.getInitData();
    }

    getInitData(){
        
        this.showSpinner = true;
        getDataOnLoad({"oppId":this.oppId})
        .then(result => {
            if(result.listPricing.length > 0){
                this.pricingDetail.listPricing = result.listPricing;
                this.pricingDetail.showList = true;
                this.showButtons = true;
            }
            if(result.listFixedPricing.length > 0){
                this.fixedPricingDetail.listFixedPricing = result.listFixedPricing;
                this.fixedPricingDetail.showList = true;
                this.showButtons = true;
            }
            if(result.listPlatformPricing.length > 0){
                this.platformFeeDetail.listPlatformPricing = result.listPlatformPricing;
                this.platformFeeDetail.showList = true;

            }
            this.editAllowed = result.editAllowed;
            this.showSpinner = false;
        })
        .catch(error =>{
            this.showSpinner = false;
            console.error(error);
        });
    }


    handleSelectAllData(event){
        this.selectAllData = event.detail.checked;
        this.selectedRecordIds = [];

        
        var tempArr = [];
        this.pricingDetail.listPricing.forEach(item => {
            item.isChecked = this.selectAllData;
            
            if(item.isChecked){
                this.selectedRecordIds.push(item.recordId);
            }else{
                this.selectedRecordIds = [...this.selectedRecordIds].filter(recordId => {
                    return recordId != item.recordId;
                });
            }
            tempArr.push(item);
        });

        this.pricingDetail.listPricing = tempArr;
        if(this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0){
            this.disableButton = false;
        }else{
            this.disableButton = true;
        }
    }
    
    /** Added for fixed pricing maker checker and versioning */
    handleSelectAllDataFixed(event){
        this.selectAllDataFixed = event.detail.checked;
        this.selectedRecordIdsFixed = [];

        
        var tempArr = [];
        this.fixedPricingDetail.listFixedPricing.forEach(item => {
            item.isChecked = this.selectAllDataFixed;
            
            if(item.isChecked){
                this.selectedRecordIdsFixed.push(item.recordId);
            }else{
                this.selectedRecordIdsFixed = [...this.selectedRecordIdsFixed].filter(recordId => {
                    return recordId != item.recordId;
                });
            }
            tempArr.push(item);
        });

        this.fixedPricingDetail.listFixedPricing = tempArr;
        if(this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0){
            this.disableButton = false;
        }else{
            this.disableButton = true;
        }
    }
    /** */

    handleIsChecked(event){
        var isChecked = event.detail.checked;
        var recordId = event.target.dataset.id;
        if(isChecked){
            this.selectedRecordIds.push(recordId);
            //this.disableButton = false;
        }else{
            this.selectedRecordIds = this.selectedRecordIds.filter(item => {
                return item != recordId;
            });
            var tempArr = [];
            this.pricingDetail.listPricing.forEach(listItem => {
                if(listItem.recordId == recordId){
                    listItem.isChecked = false;
                }
                tempArr.push(listItem);
            });
            this.pricingDetail.listPricing = tempArr;
        }
        
        if(this.selectedRecordIds.length == this.pricingDetail.listPricing.length){
            this.selectAllData = true;
        }else{
            this.selectAllData = false;
        }

        if(this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0){
            this.disableButton = false;
        }else{
            this.disableButton = true;
        }
    }

    /** Added for fixed pricing maker checker and versioning */
    handleIsCheckedFixed(event){
        var isChecked = event.detail.checked;
        var recordId = event.target.dataset.id;
        if(isChecked){
            this.selectedRecordIdsFixed.push(recordId);
            //this.disableButton = false;
        }else{
            this.selectedRecordIdsFixed = this.selectedRecordIdsFixed.filter(item => {
                return item != recordId;
            });
            var tempArr = [];
            this.fixedPricingDetail.listFixedPricing.forEach(listItem => {
                if(listItem.recordId == recordId){
                    listItem.isChecked = false;
                }
                tempArr.push(listItem);
            });
            this.fixedPricingDetail.listFixedPricing = tempArr;
        }
        
        if(this.selectedRecordIdsFixed.length == this.fixedPricingDetail.listFixedPricing.length){
            this.selectAllDataFixed = true;
        }else{
            this.selectAllDataFixed = false;
        }

        if(this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0){
            this.disableButton = false;
        }else{
            this.disableButton = true;
        }
    }/** */
    
    async handleApprove(event){
        const result = await LightningConfirm.open({
            label: "Are you sure?",
            theme : "info"
        });
        if(result){
            this.showSpinner = true;
            handleApprovePricing({"pricingIdList":this.selectedRecordIds , "pricingIdListFixed":this.selectedRecordIdsFixed})
            .then(result => {
                if(result.includes('success')){
                    this.editAllowed = false
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                console.error(error);
            });
        }
    }
    
    handleReject() {
        LightningPrompt.open({
            message: "Rejection Reason [Max 255 characters]",
            theme : "info",
            label: "Are you sure?"
        }).then((result) => {
            if(result != null){
                if(result == ''){
                    
                    LightningAlert.open({
                        message: 'Please provide the reason',
                        theme: 'error', // a red theme intended for error states
                        label: 'Error!', // this is the header text
                    });
                }else if(result.length > 255){
                    LightningAlert.open({
                        message: 'Max 255 characters allowed.',
                        theme: 'error', // a red theme intended for error states
                        label: 'Error!', // this is the header text
                    });
                }else{
                    this.showSpinner = true;
                    handleRejectPricing({
                        "pricingIdList":this.selectedRecordIds,
                        "rejectionReason" : result,
                        "pricingIdListFixed":this.selectedRecordIdsFixed
                    })
                    .then(result => {
                        if(result.includes('success')){
                            this.editAllowed = false
                        }
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        this.showSpinner = false;
                        console.error(error);
                    });
                }
                
            }
        });
    }
    
    
}