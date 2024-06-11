import { LightningElement, api,track} from 'lwc';
import getDataOnLoadDelete from '@salesforce/apex/Pricing_CheckerViewCompController.getDataOnLoadDelete';
import handleDeleteApprovePricing from '@salesforce/apex/Pricing_CheckerViewCompController.handleDeleteApprovePricing';
import handleDeleteRejectPricing from '@salesforce/apex/Pricing_CheckerViewCompController.handleDeleteRejectPricing';
import LightningConfirm from 'lightning/confirm';
import LightningPrompt from 'lightning/prompt';
import LightningAlert from 'lightning/alert';
export default class Pricing_CheckerRemoveRequestComp extends LightningElement {

    @api oppId;
    showSpinner = false;
    
    @track pricingDetail = {
        listPricing : [],
        showList : false
    }
    
    disableButton = true;
    editAllowed = true;
    selectedRecordIds = [];
    
    connectedCallback(){
        this.getInitData();
        
    }
    
    getInitData(){
        
        this.showSpinner = true;
        getDataOnLoadDelete({"oppId":this.oppId})
        .then(result => {
            if(result.listPricing.length > 0){
                this.pricingDetail.listPricing = result.listPricing;
                this.pricingDetail.showList = true;
            }
            
            this.editAllowed = result.editAllowed;
            this.showSpinner = false;
        })
        .catch(error =>{
            this.showSpinner = false;
            console.error(error);
        });
    }
    
    handleIsChecked(event){
        var isChecked = event.detail.checked;
        
        if(isChecked){
            this.selectedRecordIds.push(event.target.dataset.id);
            this.disableButton = false;
        }else{
            this.selectedRecordIds = this.selectedRecordIds.filter(item => {
                return item != event.target.dataset.id;
            });
            
            if(this.selectedRecordIds.length == 0){
                this.disableButton = true;
            }
        }
    }
    
    async handleApprove(event){
        const result = await LightningConfirm.open({
            label: "Are you sure?",
            theme : "info"
        });
        if(result){
            this.showSpinner = true;
            handleDeleteApprovePricing({"pricingIdList":this.selectedRecordIds})
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
                    handleDeleteRejectPricing({
                        "pricingIdList":this.selectedRecordIds,
                        "rejectionReason" : result
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