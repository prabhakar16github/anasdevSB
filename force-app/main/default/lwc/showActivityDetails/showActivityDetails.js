import { LightningElement,api } from 'lwc';
import activityDetails from '@salesforce/apex/BankingOpsModuleController.ActivityDetails';
export default class ShowActivityDetails extends LightningElement {
    @api oppRecordId;
    @api pricingRecTypeId;
    activityValues=[];
    connectedCallback(){
        activityDetails({oppRecId :this.oppRecordId,pricingId:this.pricingRecTypeId})
        .then(result => {
            this.activityValues=result;
            console.log('activityValues::>>>>'+JSON.stringify(this.activityValues));
            console.log('activity::>>>>'+this.activityValues);
        }) 
        .catch(error => {
            this.error = error;
        });
    }
}