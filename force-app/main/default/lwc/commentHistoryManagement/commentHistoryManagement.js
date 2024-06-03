import { LightningElement, api } from 'lwc';
import websitepagegroup from "@salesforce/apex/RiskManagementStatusController.websitepagegroup";
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Sales Comment', fieldName: 'Sales_Remarks__c'},
    { label: 'Risk Comment', fieldName: 'Risk_Remarks__c'}
    ];
export default class CommentHistoryManagement extends LightningElement {
   @api
   recordId;
   columns=columns; 
    connectedCallback() {
       
        websitepagegroup({ oppId: this.recordId }).then((res) => {
          this.responsedata = res;
          console.log(this.responsedata);
        });
      }
}