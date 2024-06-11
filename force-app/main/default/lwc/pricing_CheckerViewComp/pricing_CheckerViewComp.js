import { LightningElement, api } from 'lwc';

export default class Pricing_CheckerViewComp extends LightningElement {
    showAddUpdateRequests = true;
    showRemoveRequests = false;
    //showSpinner = false;
    @api recordId;
    
    handleAddUpdateRequests(){
        this.showAddUpdateRequests = true;
        this.showRemoveRequests = false;
    }

    handleRemoveRequests(){
        this.showAddUpdateRequests = false;
        this.showRemoveRequests = true;
    }
}