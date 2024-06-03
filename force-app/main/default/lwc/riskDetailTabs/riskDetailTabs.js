import { LightningElement, api } from 'lwc';

export default class RiskDetailTabs extends LightningElement {
@api recordId;
handleTabChange(event) {
    const tabLabel = event.target.label;
    if (tabLabel === 'Risk Status Details') {
        const riskRecordDetails = this.template.querySelector('c-risk-record-details');
        if (riskRecordDetails) {
            riskRecordDetails.handleDataChange();
        }
    }
}

}