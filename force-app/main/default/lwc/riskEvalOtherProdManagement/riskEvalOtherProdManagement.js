import { LightningElement,api,track } from 'lwc';
import getPicklistValuesOpp from '@salesforce/apex/RiskManagementStatusController.getPicklistValuesOpp';
import opportunityRecords from '@salesforce/apex/RiskManagementStatusController.websitePages';
import saveopportunityRecords from '@salesforce/apex/RiskManagementStatusController.saveOppRecords';

export default class RiskEvalOtherProdManagement extends LightningElement {
    MCPoptions;
    EMIoptions;
    @api recordId;
    @track preApprovedForPrioritySettlement;
    @track preApprovedForEMI;
    @track preApprovedForMCP;
    @track maxSameDaySettlementAmount;
    recordTosave = {};

    connectedCallback(){
        opportunityRecords({oppId:this.recordId}).then(response=>{
            this.preApprovedForPrioritySettlement = response[0].Pre_Approved_for_priority_settlement__c;
            this.preApprovedForEMI = response[0].Pre_approved_for_EMI__c;
            this.preApprovedForMCP = response[0].Pre_approved_for_MCP__c;
            this.maxSameDaySettlementAmount = response[0].Max_Same_Day_Settlement_Amount__c;
            //this.recordTosave = {"preApprovedForPrioritySettlement":this.preApprovedForPrioritySettlement,"preApprovedForEMI":this.preApprovedForEMI,"preApprovedForMCP":this.preApprovedForMCP}
            getPicklistValuesOpp().then(result=>{
                console.log('riskevalotherproduct ',result);
                this.MCPoptions = JSON.parse(result.Pre_approved_for_EMI__c);
                this.EMIoptions = JSON.parse(result.Pre_approved_for_MCP__c);
            })
        })

    }



    handleChange(event){
        console.log(event.target.value);
        this.recordTosave[event.target.dataset.name] = event.target.dataset.name === 'Pre_Approved_for_priority_settlement__c' ? event.target.checked : event.target.value
    }


    @api
    handleSave(){
        this.recordTosave.Id = this.recordId;
        let arrRecords = [this.recordTosave];
        // arrRecords.push(this.recordTosave);

        saveopportunityRecords({records:JSON.stringify(arrRecords)})
        console.log('handle save prodmanagement ',this.recordTosave);
        console.log('other product');
    }

}