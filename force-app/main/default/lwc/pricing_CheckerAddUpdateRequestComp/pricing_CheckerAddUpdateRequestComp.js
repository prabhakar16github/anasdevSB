import { LightningElement,api, track } from 'lwc';
import getDataOnLoad from '@salesforce/apex/Pricing_CheckerViewCompController.getDataOnLoad';
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


    connectedCallback(){
        this.showSpinner = true;
        getDataOnLoad({"oppId":this.oppId})
        .then(result => {
            if(result.listPricing.length > 0){
                this.pricingDetail.listPricing = result.listPricing;
                this.pricingDetail.showList = true;
            }
            if(result.listFixedPricing.length > 0){
                this.fixedPricingDetail.listFixedPricing = result.listFixedPricing;
                this.fixedPricingDetail.showList = true;
            }
            if(result.listPlatformPricing.length > 0){
                this.platformFeeDetail.listPlatformPricing = result.listPlatformPricing;
                this.platformFeeDetail.showList = true;
            }
            this.showSpinner = false;
        })
        .catch(error =>{
            this.showSpinner = false;
            console.error(error);
        });

    }
}