import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import startCOCalloutToGetMIDBatch from '@salesforce/apex/COCalloutToGetMIDBatch.startCOCalloutToGetMIDBatch';
import ERROR_MESSAGE_FIELD from '@salesforce/schema/Lead.Error_Message__c';
import MID_FIELD from '@salesforce/schema/Lead.Prod_Merchant_Id__c';

//const fields = ['Lead.Error_Message__c'];


export default class ErrorHandlingComponent extends LightningElement {
    @api recordId;
    //errorMessage;

    @wire(getRecord, { recordId: '$recordId', fields: [ERROR_MESSAGE_FIELD, MID_FIELD] })
    lead;

    get errorMessage(){
        return getFieldValue(this.lead.data, ERROR_MESSAGE_FIELD);
    }

    get midField(){
        return getFieldValue(this.lead.data, MID_FIELD);
    }

}