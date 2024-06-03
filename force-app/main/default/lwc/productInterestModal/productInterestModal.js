import { LightningElement, api,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getActiveInstrumentBundle from '@salesforce/apex/ProductInterestController.getActiveInstrumentBundle';
import getInActiveInstrumentBundle from '@salesforce/apex/ProductInterestController.getInActiveInstrumentBundle';

import getInterestFields from '@salesforce/apex/ProductInterestController.getInterestFields';

export default class ProductInterestModal extends LightningModal {

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

    // @wire(getInActiveInstrumentBundle,{prodIntId:'$interestId'})
    // inActiveInstrumentExtract({data, error}) {
        
    //     console.log('>>>>>>data Inactive>>>>'+JSON.stringify(data));
    //     if (data) {
    //         this.inActiveInstrumentList = data;
    //         //this.inActiveInstrumentFirst = inActiveInstrumentList[0];
    //         //console.log('>>>>>>>>'+data);
    //         //this.data1 = data;
    //     } else if (error) {
    //         console.log(error);
    //     }
    // }

    /* @wire(getActiveInstrumentBundle,{prodIntId:'$interestId'})
    activeInstrumentExtract({data, error}) {
        //this.wiredPostRiskHistory = value;
        //const { data, error } = value;
        console.log('>>>>>>data>>>>'+JSON.stringify(data));
        if (data) {
            this.activeInstrumentList = data;
            //console.log('postrecords'+data);
            //this.data1 = data;
        } else if (error) {
            console.log(error);
        }
    } */

    /*@wire(getInterestFields,{prodIntId:'$interestId'})
    getInterestField({data, error}) {
        
        console.log('>>>>>>data Inactive>>>>'+JSON.stringify(data));
        if (data) {
            this.interestFieldList = data;
            
        } else if (error) {
            console.log(error);
        }
    }*/

    
}