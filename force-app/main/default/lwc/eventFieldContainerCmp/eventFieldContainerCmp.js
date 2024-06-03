import { LightningElement, wire, api } from 'lwc';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import ACTIVITY_OBJECT from '@salesforce/schema/Activity';
import { getRecord } from 'lightning/uiRecordApi';

import getRelatedWebsiteDetails from '@salesforce/apex/EventFieldContainerController.getEventFields';

import EVENT_OBJECT from '@salesforce/schema/Event';
import SUB from '@salesforce/schema/Event.Sub__c';
import TOPIC from '@salesforce/schema/Event.Topic_of_Discussion__c';

export default class EventFieldContainerCmp extends LightningElement {

    @api recordId;
    //@api objectApiName;

    eventObjectExtract = EVENT_OBJECT;
    fieldList_1 = {
        sub : SUB
    }
    fieldList_2 = {
        topic : TOPIC
    }

    connectedCallback(){
        getRelatedWebsiteDetails({eventId:this.recordId})
        .then(data => {
            this.eventFieldList = data;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.eventFieldList = data;
        })
    }

    // @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    // objectInfo;

    // @wire(getRecord, { recordId: '$recordId', fields: ['Activity.Sub__c', 'Activity.Topic_of_Discussion__c'] })
    // activityRecord;

    // get isLoaded(){
    //     return this.objectInfo.data && this.activityRecord.data;
    // }

    // connectedCallback(){
    //     if(this.activityDetails.data){
    //         const fields = this.activityDetails.data.fields;
    //         const A = fields.Sub__c;
    //         const B = fields.Topic_of_Discussion__c;
    //     }
    // }
}