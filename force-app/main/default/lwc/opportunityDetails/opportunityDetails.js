import { LightningElement,api } from 'lwc';
import oppDetails from '@salesforce/apex/BankingOpsModuleController.OpportunityDetailsWithPricig'; 
export default class OpportunityDetails extends LightningElement {
    @api pricingRecTypeId;
    pricingListValues=[];
    connectedCallback(){
        oppDetails({recId :this.pricingRecTypeId})
        .then(result => {
            this.pricingListValues=result;  
        }) 
        .catch(error => {
            this.error = error;
        });
    }
   
}