import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import SETTLEMENT_STATUS_FIELD from '@salesforce/schema/Opportunity.Settlement_Status__c';

export default class CopyMIDComponent extends LightningElement {
    @api recordId;
    settlementStatOpp;

    @wire(getRecord, {recordId: '$recordId', fields: [SETTLEMENT_STATUS_FIELD]})
    wiredRecord({data, error}){
        if(data){
            this.settlementStatOpp = data;
        }
        else if(error){
            console.error(error);
        }
    }

    get isButtonVisible(){
        return getFieldValue(this.settlementStatOpp, SETTLEMENT_STATUS_FIELD) === 'Active';
    }


    handleCopy(){

    }
}