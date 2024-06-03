import { LightningElement,wire,api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Risk_Classification_Status__c from '@salesforce/schema/Opportunity.Risk_Classification_Status__c';
import Risk_Score__c from '@salesforce/schema/Opportunity.Risk_Score_1__c';
import Settlement_Status__c from '@salesforce/schema/Opportunity.Settlement_Status__c';
const fields = [Risk_Classification_Status__c,Risk_Score__c,Settlement_Status__c]

export default class RiskManagementTab extends LightningElement {
    @api recordId; 
    riskScore;
    settlementStatus;
    riskClassificationStatus;
    showEval = true;
    showStatus = false;
    @track tabs=[
        {
            id: 'eval',
            class: 'active',
            title: 'Evaluation'
        },
        {
            id: 'status',
            class: '',
            title: 'Status'
        }
    ]
    @wire(getRecord,{recordId:'$recordId',fields:fields})
    oppData({data,error}){
        if(data){
            console.log('30');
            console.log('dataa '+JSON.stringify(data));
            this.riskScore = data.fields.Risk_Score_1__c.value;
            this.riskClassificationStatus = data.fields.Risk_Classification_Status__c.displayValue;
            this.settlementStatus = data.fields.Settlement_Status__c.displayValue;
        }else if(error){
            console.log('error '+error);

        }
    }

    handleTabs(event) {
        event.preventDefault();
        let tab = event.currentTarget.dataset.id;
        this.tabs.forEach(tabItem => {
            if(tabItem.id === tab) {
                tabItem.class = 'active'
            } else {
                tabItem.class = '';
            }
        })
        if(tab === 'eval') {
            this.showEval = true;
            this.showStatus = false;
        } else if(tab === 'status') {
            this.showEval = false;
            this.showStatus = true;
        }
        console.log(event.currentTarget.dataset.id);
    }
}