import { api, LightningElement } from 'lwc';
import getMcareRecords from '@salesforce/apex/McareDashboardBulkActionCtrl.getMcareRecords';
import getPickListWrapper from '@salesforce/apex/McareDashboardBulkActionCtrl.getPickListWrapper';
import updateMcareRecords from '@salesforce/apex/McareDashboardBulkActionCtrl.updateMcareRecords';
import deleteMcareRecords from '@salesforce/apex/McareDashboardBulkActionCtrl.deleteMcareRecords';
import LightningAlert from "lightning/alert";

export default class McareDashboardBulkAction extends LightningElement {
    loading = true; /** To show/hide the spinner */
    validUserForBulkAction = false; /** To validate the user to provide the bulk action access */
    selectedRecords = []; /** List of records selected from list view */
    picklistMap = {}; /** Map to store the picklist field values */
    selectedStatusValue = ''; /** to hold the value of status */
    selectedRiskHoldReason = '';/** to hold the value of risk hold reason */
    commentValue = ''; /** to hold the value of comments */
    errorMsg = '';
    showDataTable = false;
    disableButton = false;

    disableUpdate = false;
    disableDelete = false;
    @api listViewIds; /** record Ids selected from list view and passed from flow to lwc */
    
    /** columns to show in the datatable */
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Merchant Id', fieldName: 'Merchant_Id__c', type: 'String' },
        { label: 'Status', fieldName: 'Status__c', type: 'String' },
        { label: 'Risk Hold Reason', fieldName: 'Risk_Hold_Reason__c', type: 'String' }
    ];
    
    
    connectedCallback(){
        var picklistMap = this.getPicklistMap();
        this.getMcareRecords();
    }
    
    /** Function to get the details of the selected records from list view & render into a table */
    getMcareRecords(){
        if(this.listViewIds){
            var listViewIdStr = this.listViewIds.toString();
            getMcareRecords({ selectedIdStr: listViewIdStr })
            .then(result => {
                this.validUserForBulkAction = result.userWrap.isValidForBulkAction;
                if(this.validUserForBulkAction){
                    this.disableUpdate = !result.userWrap.isValidForBulkUpdate;
                    this.disableDelete = !result.userWrap.isValidForBulkDelete;
                    this.selectedRecords = result.mcareRecordList;
                    if(this.selectedRecords.length > 0){
                        this.showDataTable = true;
                    }else{
                        this.showDataTable = false;
                        this.disableUpdate = true;
                        this.disableDelete = true;
                    }
                }else{
                    this.errorMsg = 'You don\'t have enough permissions to perform Bulk Actions.';
                }
                //this.error = undefined;
            })
            .catch(error => {
                //this.error = error;
                this.selectedRecords = [];
            })

        }else{
            this.errorMsg = 'No record selected';
        }
        this.loading = false;
    }/** END */
    
    /** To get the picklist value map for all the drop down fields */
    getPicklistMap(){
        getPickListWrapper()
        .then(result => {
            this.picklistMap = result;
        })
        .catch(error => {
            console.log('error : '+error);
            this.picklistMap = {};
        });
    }/** END */
    
    handleStatusChange(event){
        this.selectedStatusValue = event.target.value;
    }
    handleRiskHoldReasonChange(event){
        this.selectedRiskHoldReason = event.target.value;
    }
    handleCommentChange(event){
        this.commentValue = event.target.value;
    }
    
    /** To get the picklist value for Status field */
    get statusValues(){
        var statusValues = this.picklistMap['Status__c'];
        var newArr = [];
        for(let key in statusValues){
            if(statusValues[key] != 'Risk Hold'){
                newArr.push({'label':key,'value':statusValues[key]});
            }
        }
        return newArr;
    }/** END */
    
    /** To get the picklist value for Risk Hold Reason field */
    get riskHoldReason(){
        var riskHoldReason = this.picklistMap['Risk_Hold_Reason__c'];
        var newArr = [];
        for(let key in riskHoldReason){
            newArr.push({'label':key,'value':riskHoldReason[key]});
        }
        return newArr;
    }/** END */
    
    /** Function to update the selected records */
    /** Calling from update All button */
    handlerUpdate(){
        /* if(this.selectedStatusValue == 'Risk Hold' && this.selectedRiskHoldReason == ''){
            this.handleAlert('Risk Hold reason is required if status is Risk Hold','error','Error!');
        }else{ */
        var confirmMsg = 'Do you want to update the records? Press OK to save, Cancel to abort!';
        if(window.confirm(confirmMsg)){

            updateMcareRecords({
                selectedIdStr : this.listViewIds.toString(),
                statusValue : this.selectedStatusValue,
                riskHoldReason : this.selectedRiskHoldReason,
                commentValue : this.commentValue
            })
            .then(result => {
                if(result){
                    if(result == 'Success'){
                        this.getMcareRecords();
                        this.handleAlert('Records updated successfully','success','Success!');
                        
                    }else if(result.includes('Error')){
                        this.handleAlert(result,'error','Error!');
                    }
                }
            })
            .catch(error => {
                console.log('error : '+error);
                this.selectedRecords = [];
            });
        }
        //}
        
    }/** END */

    /** Function to delete the selected records */
    /** Calling from Delete All button */
    handleDelete(){
        var confirmMsg = 'Do you want to delete the records? Press OK to save, Cancel to abort!\n\n Note - Records will be permanently removed from the system.';
        if(window.confirm(confirmMsg)){

            deleteMcareRecords({
                selectedIdStr : this.listViewIds.toString()
            })
            .then(result => {
                if(result){
                    if(result == 'Success'){
                        this.getMcareRecords();
                        this.handleAlert('Records deleted successfully','success','Success!');
                        
                    }else if(result.includes('Error')){
                        this.handleAlert(result,'error','Error!');
                    }
                }
            })
            .catch(error => {
                console.log('error : '+error);
                this.selectedRecords = [];
            });
        }
    }/** END */
    
    /** Function to show the alerts */
    async handleAlert(msg,themeType,labelType) {
        await LightningAlert.open({
            message: msg,
            theme: themeType,
            label: labelType
        }).then(() => {
            console.log("###Alert Closed");
        });
    }/** */
}