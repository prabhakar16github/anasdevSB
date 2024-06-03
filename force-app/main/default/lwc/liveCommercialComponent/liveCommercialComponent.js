import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getLiveDetailsFromTreasury from '@salesforce/apex/PricingModuleComponentController.getLiveDetailsFromTreasury';
import getNewAPILiveDetailsFromTreasury from '@salesforce/apex/PricingModuleComponentController.getNewAPILiveDetailsFromTreasury';

export default class LiveCommercialComponent extends LightningElement {
    showSpinner = true;
    @api recordId = '';
    selectedListPaymentDataLiveFromTreasury = [];
    listUntransformedData = [];

    connectedCallback() {
        //getLiveDetailsFromTreasury({recordId : this.recordId})
        getNewAPILiveDetailsFromTreasury({recordId : this.recordId})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.selectedListPaymentDataLiveFromTreasury = JSON.parse(result.selectedListPaymentDataLiveFromTreasury);
                this.listUntransformedData = result.listUntransformedData;
                this.showSpinner = false;
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