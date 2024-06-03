import { LightningElement,api,wire,track } from 'lwc';
import getDetailsOnApprovalPage from '@salesforce/apex/BulkTeamChangeApprovalController.getDetailsOnApprovalPage';
import actionOnSelectedOppsFromLWC from '@salesforce/apex/BulkTeamChangeApprovalController.actionOnSelectedOppsFromLWC';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';
export default class BulkTeamChangeApproval extends LightningElement {
  @track isLoading = false;
  handleIsLoading(isLoading) {
    this.isLoading = isLoading;
  }

  updateRecordView() {
    setTimeout(() => {
          eval("$A.get('e.force:refreshView').fire();");
    }, 1000); 
  }
  handleRefresh() {
    this.dispatchEvent(new RefreshEvent());
  }
  //@wire(getDetailsOnApprovalPage) wiredDetails;
  @track columns = [
    { label: 'MID', fieldName: 'Prod_Merchant_Id__c', type: 'text' },
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Team', fieldName: 'Team__c', type: 'text' },
    { label: 'Merchant Business Type', fieldName: 'Merchant_Business_Type__c', type: 'text'},
    { label: 'New Team Requested', fieldName: 'New_Team_Requested__c', type: 'text' },
    { label: 'New Merchant Business Type Requested', fieldName: 'New_Merchant_Business_Type_Requested__c', type: 'text'}
  ];
@track detailsList;
  @wire (getDetailsOnApprovalPage) wiredDetails({data,error}){
    if (data) {
      this.detailsList = data;
      if(data.length==0) this.detailsList = null;
      console.log(data); 
    } else if (error) {
      
    console.log(error);
    }
  }
  actionOnRequests(event) {
    var selectedResponse = event.target.dataset.id;
    var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            this.handleIsLoading(true);
            console.log('selectedRecords are ', selectedRecords);
    
            let ids = '';
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.response = selectedResponse;
            //alert(this.selectedIds);
            actionOnSelectedOppsFromLWC({recordIds:this.selectedIds,response:this.response})
            .then( accountDetails=> {
              console.log("accountdetails: "+ JSON.stringify(accountDetails));
              this.updateRecordView();
            })
            .catch( error=>{
              console.error("error: "+ JSON.stringify(error))
            })
            .finally(()=>{
              this.handleIsLoading(false);
              window.location.reload();
          });
            //refreshApex(this.detailsList);
            //this.handleRefresh();
            //window.location.reload();         
  }
  }
  /*approveRequests(event) {
    
    alert('Approve clicked'+event.target.dataset.id);
    this.actionOnRequests('Approve');
  }
  rejectRequests(event) {
    alert('Reject clicked'+event.target.dataset.id);
    this.actionOnRequests('Reject');
  }*/
}