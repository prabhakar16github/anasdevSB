import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { reduceErrors } from 'c/ldsUtils';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';

import SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import DESCRIPTION_FIELD from "@salesforce/schema/Case.Description";
import JIRA_NUMBER_FIELD from "@salesforce/schema/Case.Jira_Number__c";
import JIRA_URL_FIELD from "@salesforce/schema/Case.Jira_URL__c";

import getJIRASettings from '@salesforce/apex/JiraService.getJIRASettings';
import createJIRA from '@salesforce/apex/JiraService.createJIRA';
import getJIRAStatus from '@salesforce/apex/JiraService.getJIRAStatus';


const PRIORITY_DEFAULT = '2';

export default class JiraCreate extends LightningElement {

    @api recordId;
    jiraNumber;
    engTeam = '';
    priority = PRIORITY_DEFAULT;
    assigneeId;
    reporterId;

    isLoading = true;

    @track engTeamOptions = [{label:"--None--", value:""},
                            {label:"Treasury", value:"Treasury"},
                            {label:"Refunds", value:"Refunds"},
                            {label:"Chargeback", value:"Chargeback"}];

    @track prioOptions = [{label:"--None--", value:""},
                        {label:"Highest", value:"0"},
                        {label:"High", value:"1"},
                        {label:"Medium", value:"2"},
                        {label:"Low", value:"3"},
                        {label:"Lowest", value:"4"}];
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [SUBJECT_FIELD, DESCRIPTION_FIELD, JIRA_NUMBER_FIELD, JIRA_URL_FIELD]
        })
        caseRecord;

    @wire(getJIRASettings)
    jiraSettings;

    connectedCallback(){
        this.isLoading = !this.isLoading;
    }

    get isCreate(){
        let jiraNum = getFieldValue(this.caseRecord.data, JIRA_NUMBER_FIELD);
        this.jiraNumber = jiraNum;
        return jiraNum || this.jiraNumber ? false : true;
    }

    get subject(){
        return getFieldValue(this.caseRecord.data, SUBJECT_FIELD);
    }

    get description(){
        return getFieldValue(this.caseRecord.data, DESCRIPTION_FIELD);
    }

    get jiraURL(){
        return (this.jiraSettings.data) ? `${this.jiraSettings.data.JIRA_Base_URL__c}${this.jiraNumber}` : '';
    }

    handleTeamChange(event){
        this.engTeam = event.target.value;
    }

    handlePrioChange(event){
        this.priority = event.target.value;
    }

    handleAssigneeChange(event){
        this.assigneeId = event.target.value;
    }

    handleReporterChange(event){
        this.reporterId = event.target.value;
    }

    createJIRA(){
        this.isLoading = !this.isLoading; //enable loader

        this.template.querySelectorAll(".req").forEach(item => {
            let fieldValue = item.value;
            if(!fieldValue){
            }
			else{
                item.setCustomValidity("");
            }
            item.reportValidity();
		});

        if (this.engTeam && this.priority) {
            //the names should be equal to the JiraWrapper attributes
            let request = {summary: this.subject, description: this.description, assigneeTo: this.assigneeId, 
                          reporterTo: this.reporterId, priority: this.priority, engineeringTeam:this.engTeam};
            console.log(JSON.stringify(request));

            createJIRA({json: JSON.stringify(request), recordId: this.recordId})
            .then((result) =>{
                if(result){
                    this.jiraNumber = result;
                    refreshApex(this.caseRecord);
                    this.showToast(`JIRA Id ${result}`, 'JIRA ticket has been created successfully', 'success');
                }else{
                    this.showToast('Error', 'Unable to create JIRA ticket. Please get in touch with Admin', 'error');
                }
                this.isLoading = !this.isLoading; //disable loader
            })
            .catch((error) =>{
                this.isLoading = !this.isLoading; //disable loader
                console.error(error);
                this.showToast('Error', reduceErrors(error).join(', '), 'error');
            })
        }else{
            this.isLoading = !this.isLoading; //disable loader
            this.showToast('Error', 'Please enter all mandatory fields', 'error');
        }
    }

    getStatus(){ 
        this.isLoading = !this.isLoading; //enable loader
        getJIRAStatus({jiraNumber : this.jiraNumber, recordId: this.recordId})
            .then((result) =>{
                if(result){
                    this.jiraNumber = result;
                    refreshApex(this.caseRecord);
                    this.showToast(`JIRA Id ${result}`, 'Jira status has been updated successfully', 'success');
                }else{
                    this.showToast('Error', 'Unable to get JIRA ticket status. Please get in touch with Admin', 'error');
                }
                this.isLoading = !this.isLoading; //disable loader
            })
            .catch((error) =>{
                this.isLoading = !this.isLoading; //disable loader
                console.error(error);
                this.showToast('Error', reduceErrors(error).join(', '), 'error');
            })
    }

    resetForm(){
        this.engTeam = '';
        this.priority = PRIORITY_DEFAULT;
        this.assigneeId = undefined;
        this.reporterId = undefined;
    }

    showToast(_title, _message, _variant){
        const toast = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(toast);
    }
}