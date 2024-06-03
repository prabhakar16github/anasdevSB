import { LightningElement,track,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import CopyMIDHelper from '@salesforce/apex/CopyMIDController.CopyMIDHelper';
export default class CopyMID extends LightningElement {
      @api recordId;
      @track isLoading = false;
      closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }
      proceedFunction(){
        CopyMIDHelper({ oppId: this.recordId})
            .then(result => {
              console.log(result);
              if (result === 1){
                this.showToast("ERROR","error", "COPY MID already in process!");
                this.closeQuickAction();
              }
              else{
                this.showToast("SUCCESS", "success", "COPY MID request initiated!"); 
                this.closeQuickAction();
              }
            })
            .catch(error => {
              //this.showToast('ERROR', 'error', error);
            })
      }
      showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}