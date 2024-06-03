import { LightningElement, api, track } from "lwc";
import websitepagegroup from "@salesforce/apex/RiskManagementStatusController.websitepagegroup";
import savetabledata from "@salesforce/apex/RiskManagementStatusController.savewebsitepagedata";
import updateWebsitePage from "@salesforce/apex/RiskManagementStatusController.updatewebsitepage";
import { updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

export default class CommentManagement extends LightningElement {
  @api recordId;
  //columns = columns;
  draftValues = []; 
  edittable=true;
  storecommentvalue=[];
   commentvalues;
   commentJson = [];
  @track responsedata;
  connectedCallback() {
    websitepagegroup({ oppId: this.recordId }).then((res) => {
      this.responsedata = res;
    });
  }

  @api
  edittabledata(){
    console.log('81');
    this.edittable=false;
  }
  @api
  savetabledata(){
    console.log('86::::::::'+JSON.stringify( this.commentJson));
    this.edittable=true;
    savetabledata({objrecord:this.commentJson});


  }
  @api
  cancletabledata(){
    console.log('40');
    this.edittable=true;
  }
 
  /*handlecommentchange(event){
    console.log('event',event.target.value);
    console.log('89',event.target.dataset.id);
    console.log('28',event.target.dataset.name);
    if(event.target.dataset.name==='salescomment'){
      console.log('this.commentJson.length::::::'+this.commentJson.length);
      if(this.commentJson.length===0){
        console.log('line:::51');
        this.commentJson=[{'Id':event.target.dataset.id,'':event.target.value,'Risk_Comment__c':''}];
      }
      else{
        console.log('inside else:::54::');
      let index = this.commentJson.findIndex(element => {
        return element.Id === event.target.dataset.id;
      });
      if(index === -1){
      this.commentJson = [...this.commentJson,{'Id':event.target.dataset.id,'Sales_Comment__c':event.target.value,'Risk_Comment__c':''}]
      }else{
        this.commentJson[index] = {...this.commentJson[index],'Sales_Comment__c':event.target.value};
      }
      
    }

    }
    else{
      console.log('Inside else:::'+this.commentJson.length);
      if(this.commentJson.length===0){
        console.log('line:::69');
        //this.commentJson=[{'Id':event.target.dataset.id,'Sales_Comment__c':'','Risk_Comment__c':event.target.value}];
        this.commentJson=[{'Id':event.target.dataset.id,'':event.target.value,'Sales_Comment__c':''}];
      }
      else{
        console.log('inside else:::75::');
      let index = this.commentJson.findIndex(element => {
        return element.Id === event.target.dataset.id;
      });
      if(index === -1){
        this.commentJson = [...this.commentJson,{'Id':event.target.dataset.id,'Sales_Comment__c':'','Risk_Comment__c':event.target.value}]
        }else{
          this.commentJson[index] = {...this.commentJson[index],'Risk_Comment__c':event.target.value};
        }
    }
    // console.log('this.comment',this.commentvalues);
  }
}*/

handlecommentchange(event) { 
  console.log('event', event.target.value);
   console.log('Id', event.target.dataset.id); 
   console.log('Name', event.target.dataset.name);
    // Find the index of the element in commentJson array with the matching Id
     const index = this.commentJson.findIndex(element => element.Id === event.target.dataset.id);
      // Create a new comment object
       const newComment = {
         Id: event.target.dataset.id, Sales_Comment__c: event.target.dataset.name === 'salescomment' ? event.target.value : '',
         };
        if (index === -1) {
           // If the element with the given Id is not found, add the new comment object to the array
          this.commentJson = [...this.commentJson, newComment];
        } else { 
           // If the element with the given Id is found, update it with the new comment object
            this.commentJson[index] = newComment;
          }
}

}