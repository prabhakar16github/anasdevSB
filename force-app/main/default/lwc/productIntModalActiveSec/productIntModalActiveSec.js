import { LightningElement, api,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getActiveInstrumentBundle from '@salesforce/apex/ProductInterestController.getActiveInstrumentBundle';
import getInActiveInstrumentBundle from '@salesforce/apex/ProductInterestController.getInActiveInstrumentBundle';

import getInterestFields from '@salesforce/apex/ProductInterestController.getInterestFields';

export default class ProductIntModalActiveSec extends LightningModal {
    
    @api interestId;

    activeInstrumentList;
    inActiveInstrumentList;

    interestFieldList;

    numberOdInActive = 10;
    isButtonDisabled = true;

    handleOkay() {
        this.close('okay');
    }

    connectedCallback(){
        getActiveInstrumentBundle({prodIntId:this.interestId})
        .then(data => {
            this.activeInstrumentList = data;
            //this.activeInstrumentFirst = activeInstrumentList[0];
            
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.activeInstrumentList = undefined;
        });

        // Fetching the in-active instrument data.
        getInActiveInstrumentBundle({prodIntId:this.interestId})
        .then(data => {
            console.log('>>>>inactive data>>>>'+JSON.stringify(data));
            this.inActiveInstrumentList = data;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.inActiveInstrumentList = undefined;
        }); 

        // fetching the sales_bundle and sub_sales_bundle to put it at the heading level in modal
        getInterestFields({prodIntId:this.interestId})
        .then(data => {
            this.interestFieldList = data;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.interestFieldList = data;
        }); 

   } 
   
}