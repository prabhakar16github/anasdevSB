import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import runBatchProcess  from '@salesforce/apex/COCalloutToGetMIDBatch.runBatchProcess';

export default class COCalloutLWCCmp extends LightningElement {

@api recordId;

handleButtonClick() {
    if(!this.recordId){
            return;
        }
    runBatchProcess({leadId : this.recordId})
            .then(() => {
                this.showToast('Success', 'Batch process started successfully.', 'success');
            })
            .catch((error) => {
                this.showToast('Error', 'Failed to start batch process.', 'error');
                console.error(error);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}