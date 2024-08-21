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
    selectedRecordIdsPlatform = [];

    selectAllData = false;
    selectAllDataFixed = false;
    selectAllDataPlatform = false;

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
            console.log('>>>>>>>'+JSON.stringify(result.listPlatformPricing));
            if(result.listPlatformPricing.length > 0){
                this.platformFeeDetail.listPlatformPricing = result.listPlatformPricing;
                this.platformFeeDetail.showList = true;
                this.showButtons = true;
            }
            this.editAllowed = result.editAllowed;
            this.showSpinner = false;
        })
        .catch(error =>{
            this.showSpinner = false;
            console.error(error);
        });
    }


    /** Function to store all TDR/Conv pricing in a set and check all the child checkboxes in UI 
    * Calling from master checkbox in TDR/Conv list.
    */
    handleSelectAllData(event){
        this.selectAllData = event.detail.checked;
        this.selectedRecordIds = [];
        
        var tempArr = [];
        
        this.pricingDetail.listPricing.forEach(item => {
            item.isChecked = this.selectAllData;
            
            if(this.selectAllData){
                this.selectedRecordIds.push(item.recordId);
            }else{
                this.selectedRecordIds = [];
            }
            tempArr.push(item);
        });

        this.pricingDetail.listPricing = tempArr;
        this.disableButton = (this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0 || this.selectedRecordIdsPlatform.length > 0) ? false : true;
    }/** END */
    
    /** Function to store all fixed pricing in a set and check all the child checkboxes in UI 
    * Calling from master checkbox in Fixed pricing list.
    */
    handleSelectAllDataFixed(event){
        this.selectAllDataFixed = event.detail.checked;
        this.selectedRecordIdsFixed = [];

        var tempArr = [];
        this.fixedPricingDetail.listFixedPricing.forEach(item => {
            item.isChecked = this.selectAllDataFixed;
            
            if(item.isChecked){
                this.selectedRecordIdsFixed.push(item.recordId);
            }else{
                this.selectedRecordIdsFixed = [];
            }
            tempArr.push(item);
        });

        this.fixedPricingDetail.listFixedPricing = tempArr;
        this.disableButton = (this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0 || this.selectedRecordIdsPlatform.length > 0 ) ? false : true;
    }
    /** END */

    /** Function to store all Platform Fee in a set and check all the child checkboxes in UI 
    * Calling from master checkbox in Platform Fee list.
    */
    handleSelectAllDataPlatform(event){
        this.selectAllDataPlatform = event.detail.checked;
        this.selectedRecordIdsPlatform = [];

        var tempArr = [];
        this.platformFeeDetail.listPlatformPricing.forEach(item => {
            item.isChecked = this.selectAllDataPlatform;
            
            if(item.isChecked){
                this.selectedRecordIdsPlatform.push(item.recordId);
            }else{
                this.selectedRecordIdsPlatform = [];
            }
            tempArr.push(item);
        });

        this.platformFeeDetail.listPlatformPricing = tempArr;
        this.disableButton = (this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0 || this.selectedRecordIdsPlatform.length > 0) ? false : true;
    }/** END */

    /** Function to store selected TDR/Conv pricing in a set
    * Calling from child checkboxes in TDR/Conv list.
    */
    handleIsChecked(event){
        var isChecked = event.detail.checked;
        var recordId = event.target.dataset.id;
        if(isChecked){
            this.selectedRecordIds.push(recordId);
        }else{
            this.selectedRecordIds = this.selectedRecordIds.filter(item => {
                return item != recordId;
            });
        }

        var tempArr = [];
        this.pricingDetail.listPricing.forEach(listItem => {
            if(listItem.recordId == recordId){
                listItem.isChecked = isChecked;
            }
            tempArr.push(listItem);
        });
        this.pricingDetail.listPricing = tempArr;

        this.selectAllData = (this.selectedRecordIds.length == this.pricingDetail.listPricing.length) ? true : false;
        this.disableButton = (this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0) ? false : true;
    }/** END */

    /** Function to store selected Fixed pricing in a set
    * Calling from child checkboxes inFixed pricing list.
    */
    handleIsCheckedFixed(event){
        var isChecked = event.detail.checked;
        var recordId = event.target.dataset.id;
        if(isChecked){
            this.selectedRecordIdsFixed.push(recordId);
        }else{
            this.selectedRecordIdsFixed = this.selectedRecordIdsFixed.filter(item => {
                return item != recordId;
            });
            
        }

        var tempArr = [];
        this.fixedPricingDetail.listFixedPricing.forEach(listItem => {
            if(listItem.recordId == recordId){
                listItem.isChecked = isChecked;
            }
            tempArr.push(listItem);
        });
        this.fixedPricingDetail.listFixedPricing = tempArr;
    
        this.selectAllDataFixed = (this.selectedRecordIdsFixed.length == this.fixedPricingDetail.listFixedPricing.length) ? true : false;
        
        this.disableButton = (this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0) ? false : true;
        
    }/** END */

    /** Function to store selected Platform Fee in a set
    * Calling from child checkboxes in Platform Fee list.
    */
    handleIsCheckedPlatform(event){
        var isChecked = event.detail.checked;
        var recordId = event.target.dataset.id;
        if(isChecked){
            this.selectedRecordIdsPlatform.push(recordId);
        }else{
            this.selectedRecordIdsPlatform = this.selectedRecordIdsPlatform.filter(item => {
                return item != recordId;
            });
            
        }

        var tempArr = [];
        this.platformFeeDetail.listPlatformPricing.forEach(listItem => {
            if(listItem.recordId == recordId){
                listItem.isChecked = isChecked;
            }
            tempArr.push(listItem);
        });
        this.platformFeeDetail.listPlatformPricing = tempArr;
    
        this.selectAllDataPlatform = (this.selectedRecordIdsPlatform.length == this.platformFeeDetail.listPlatformPricing.length) ? true : false;
        
        this.disableButton = (this.selectedRecordIds.length > 0 || this.selectedRecordIdsFixed.length > 0 || this.selectedRecordIdsPlatform.length > 0) ? false : true;
        
    }/** END */
    
    
    async handleApprove(event){
        const result = await LightningConfirm.open({
            label: "Are you sure?",
            theme : "info"
        });
        if(result){
            this.showSpinner = true;
            handleApprovePricing({
                "pricingIdList":this.selectedRecordIds ,
                "pricingIdListFixed":this.selectedRecordIdsFixed,
                "platformFeeIdList":this.selectedRecordIdsPlatform
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
                        theme: 'error',
                        label: 'Error!'
                    });
                }else if(result.length > 255){
                    LightningAlert.open({
                        message: 'Max 255 characters allowed.',
                        theme: 'error', 
                        label: 'Error!'
                    });
                }else{
                    this.showSpinner = true;
                    handleRejectPricing({
                        "pricingIdList":this.selectedRecordIds,
                        "rejectionReason" : result,
                        "pricingIdListFixed":this.selectedRecordIdsFixed,
                        "platformFeeIdList":this.selectedRecordIdsPlatform
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