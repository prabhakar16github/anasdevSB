import { LightningElement, api,wire } from 'lwc';
import platformApi from '@salesforce/apex/PublishPlatformFeeToTreasury_CTRL.PricingToTreasury';
import fallBackAPi from '@salesforce/apex/PublishFallbackToTreasury_CTRL.FallBackToTreasury';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions'
export default class PlatformAndFallBack extends NavigationMixin(LightningElement){
    @api recordId;
    @api platformRecordResponse; 
    @api fallBackResponse; 
    @api isCallingApi = false;
    @wire(platformApi, {commId:'$recordId'})
        wiredApexResult({error,data}){
            this.isCallingApi = true;
            console.log('recordId::::'+this.recordId);
            if(data){
                this.platformRecordResponse=data;
                const successToastForPlatform = new ShowToastEvent({
                    title:'Success',
                    message:'Platform Api has been published',
                    variant:'Success'
                })
                this.dispatchEvent(successToastForPlatform);
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                       recordId: this.recordId,
                       objectApiName: "Commercial2__c",
                       actionName: "view"
                    }
                 });
                 this.closeAction();
            }
            else{
                this.closeAction();
            }
        }
        closeAction(){
             this.dispatchEvent(new CloseActionScreenEvent());
        }
    @wire(fallBackAPi, {commId:'$recordId'})
         wiredApexResult({error,data}){
            console.log('recordId::::'+this.recordId);
            if(data){
                this.platformRecordResponse=data;
                const successToastForPlatform = new ShowToastEvent({
                    title:'Success',
                    message:'Fallback Api has been published',
                    variant:'Success'
                })
                this.dispatchEvent(successToastForPlatform);
                this.closeAction();
            }
            else{
                this.closeAction();
            }
        }
}