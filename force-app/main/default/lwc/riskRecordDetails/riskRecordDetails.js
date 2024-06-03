import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
//import getRecordIdOrCreateRecord from '@salesforce/apex/RiskManagementStatusController.getRecordTypeIdAndStatus';
//import  riskRecordHistory from '@salesforce/apex/RiskManagementStatusController.riskRecordHistory';
import  postRiskHistory from '@salesforce/apex/RiskManagementStatusController.postRiskHistory';
import  obRiskHistory from '@salesforce/apex/RiskManagementStatusController.obRiskHistory';
import  preRiskHistory from '@salesforce/apex/RiskManagementStatusController.preRiskHistory';
const columns1 = [
    //{ label: 'Id', fieldName: 'Id' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', 
        typeAttributes: {
            year: 'numeric', 
            month: 'numeric', 
            day: 'numeric', 
            hour: 'numeric', 
            minute: 'numeric',
            hour12: true
        }
    },
    { label: 'Field', fieldName: 'Field', type: 'text' },
    { label: 'OldValue', fieldName: 'OldValue', type: 'text'},
    { label: 'NewValue', fieldName: 'NewValue', type: 'text'},
];
const columns2 = [
   // { label: 'Id', fieldName: 'Id' },
   { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', 
   typeAttributes: {
       year: 'numeric', 
       month: 'numeric', 
       day: 'numeric', 
       hour: 'numeric', 
       minute: 'numeric',
       hour12: true
   }
},
    { label: 'Field', fieldName: 'Field' },
    { label: 'OldValue', fieldName: 'OldValue'},
    { label: 'NewValue', fieldName: 'NewValue'},
];
const columns3 = [
   // { label: 'Id', fieldName: 'Id' },
   { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', 
   typeAttributes: {
       year: 'numeric', 
       month: 'numeric', 
       day: 'numeric', 
       hour: 'numeric', 
       minute: 'numeric',
       hour12: true
   }
},
    { label: 'Field', fieldName: 'Field' },
    { label: 'OldValue', fieldName: 'OldValue'},
    { label: 'NewValue', fieldName: 'NewValue'},
];
export default class RiskRecordDetails extends LightningElement {
    @api recordId;
    @track data1 = [];
    @track data2 = [];
    @track data3 = [];
    columns1 = columns1;
    columns2 = columns2;
    columns3 = columns3;
    isLoading;
    wiredPostRiskHistory;
    wiredObRiskHistory;
    wiredPreRiskHistory;

    @wire(postRiskHistory, { oppId: '$recordId' })
    postRiskHistoryData(value) {
        this.wiredPostRiskHistory = value;
        const { data, error } = value;

        if (data) {
            console.log('postrecords'+data);
            this.data1 = data;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(obRiskHistory, { oppId: '$recordId' })
    obRiskHistoryData(value) {
        this.wiredObRiskHistory = value;
        const { data, error } = value;

        if (data) {
            console.log('postrecords'+data);
            this.data2 = data;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(preRiskHistory, { oppId: '$recordId' })
    preRiskHistoryData(value) {
        this.wiredPreRiskHistory = value;
        const { data, error } = value;

        if (data) {
            console.log('postrecords'+data);
            this.data3 = data;
        } else if (error) {
            console.log(error);
        }
    }
    @api
    handleDataChange() {
        // Refresh the wired Apex methods
        Promise.all([
            refreshApex(this.wiredPostRiskHistory),
            refreshApex(this.wiredObRiskHistory),
            refreshApex(this.wiredPreRiskHistory)
        ]).then(() => {
            // Handle the refreshed data
            const { data: postRiskHistoryData, error: postRiskHistoryError } = this.wiredPostRiskHistory;
            const { data: obRiskHistoryData, error: obRiskHistoryError } = this.wiredObRiskHistory;
            const { data: preRiskHistoryData, error: preRiskHistoryError } = this.wiredPreRiskHistory;

            if (postRiskHistoryData) {
                console.log('postrecords'+postRiskHistoryData);
                this.data1 = postRiskHistoryData;
            } else if (postRiskHistoryError) {
                console.log(postRiskHistoryError);
            }

            if (obRiskHistoryData) {
                console.log('postrecords'+obRiskHistoryData);
                this.data2 = obRiskHistoryData;
            } else if (obRiskHistoryError) {
                console.log(obRiskHistoryError);
            }

            if (preRiskHistoryData) {
                console.log('postrecords'+preRiskHistoryData);
                this.data3 = preRiskHistoryData;
            } else if (preRiskHistoryError) {
                console.log(preRiskHistoryError);
            }
        });
    }
       
    
    

}