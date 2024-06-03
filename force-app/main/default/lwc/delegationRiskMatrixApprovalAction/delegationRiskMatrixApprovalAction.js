import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import revertApprovalProcess from "@salesforce/apex/RiskMatrixDelegationUtility.revertApprovalProcess";
import { RecordFieldDataType } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class DelegationRiskMatrixApprovalAction extends LightningElement {
    @api recordId;
    comment;

    commentChange(event) {
        this.comment = event.target.value;
    }
    
    handleSave() {
        revertApprovalProcess({recordId: this.recordId, comment: this.comment})
        .then(() => {
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(err => {
            const evt = new ShowToastEvent({title: "Error", message: err.message, variant: "error"});
            this.dispatchEvent(evt);
            this.dispatchEvent(new CloseActionScreenEvent());
            throw err;
        })
    }
}