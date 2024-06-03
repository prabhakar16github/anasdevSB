import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRecordIdOrCreateRecord from '@salesforce/apex/RiskManagementStatusController.getRecordTypeIdAndStatus';
//import  riskRecordHistory from '@salesforce/apex/RiskManagementStatusController.riskRecordHistory';
import  postRiskHistory from '@salesforce/apex/RiskManagementStatusController.postRiskHistory';
import  obRiskHistory from '@salesforce/apex/RiskManagementStatusController.obRiskHistory';
import  preRiskHistory from '@salesforce/apex/RiskManagementStatusController.preRiskHistory';

// import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import postRiskLabel from '@salesforce/label/c.Hold_Users_For_Post_risk';
import obRiskLabel from '@salesforce/label/c.Hold_Users_For_OB';
import preRiskLabel from '@salesforce/label/c.Hold_Users_For_Pre_risk';
import postRiskReleaseLabel from '@salesforce/label/c.Hold_Users_From_Post_risk';
import preRiskReleaseLabel from '@salesforce/label/c.Hold_Users_From_Pre_risk';
import OBRiskReleaseLabel from '@salesforce/label/c.Hold_Users_From_OB';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils' // added by rohit
import { NavigationMixin } from 'lightning/navigation';// added by rohit
import updatePendingAmount from '@salesforce/apex/PendingSettlementAmount_Controller.updatePendingAmount';// added by rohit

import Id from '@salesforce/user/Id';
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

export default class RiskHistoryManagement extends NavigationMixin(LightningElement) {
    @api recordId;
    @track data1 = [];
    @track data2 = [];
    @track data3 = [];
    columns1 = columns1;
    columns2 = columns2;
    columns3 = columns3;
   @track isLoading=false;
    wiredPostRiskHistory;
    wiredObRiskHistory;
    wiredPreRiskHistory;

    showPostRiskHistory = false;
    showPreRiskHistory = false;
    showObRiskHistory = false;

    onHoldPostRisk = false; // by default it was true now i am changing to false by rohit
    notonholdPostRisk=false;
    onHoldOBRisk=false;
    notonholdOBRisk=false;
    onHoldPreRisk = false;
    notonholdPreRisk=false;
    postrecid;
    obredid;
    preredid;
    templatetypeparent;
    @track userId = Id;

    riskManagementModal = false;ß
    postRiskLabelTeam = [];
    obRiskLabelTeam = [];
    preRiskLabelTeam = [];

    postReleaseTeam = [];
    obReleaseTeam = [];
    preReleaseTeam = [];
    @track closeModalHeader// added by rohit
    modalHeaderPost = false;// added by rohit
    holdHeader;// added by rohit
    releaseHeader;// added by rohit
    modalHeaderRelease;// added by rohit
    spinner = false;
    pendingAmount // added by rohit

    connectedCallback(){
        this.getdata();
   }
   getdata(){
    getRecordIdOrCreateRecord({ oppId: this.recordId }).then((result) => {
        console.log('data change ',JSON.parse(JSON.stringify(result)));
        for (var key in result) {
            if(result[key].Hold_Type__c == 'Post Hold'){
               // this.onHoldPostRisk = result[key].Current_Status__c == 'On Hold' ? true : false;
               if(result[key].Current_Status__c == 'On Hold'){
                this.onHoldPostRisk=true;
                }
                else{
                    this.notonholdPostRisk=true;
                }
                this.postrecid = result[key].Id;
            }
            if(result[key].Hold_Type__c == 'OB Hold'){
             //   this.onHoldOBRisk = result[key].Current_Status__c == 'On Hold' ? true : false;
                if(result[key].Current_Status__c == 'On Hold'){
                    this.onHoldOBRisk=true;
                    //console.log('line::127::::'+ this.closeModalHeader);
                }
                else{
                    this.notonholdOBRisk=true;
                }
                this.obredid = result[key].Id;
                /*console.log('obredid::::::::::'+result[key].Current_Status__c);
                if(result[key].Current_Status__c !='On Hold'){
                    console.log('inside 135:::'+ this.closeModalHeader);
                    this.closeModalHeader = true;
                }*/
            }  
            if (result[key].Hold_Type__c == 'Pre Hold') {
                console.log('131',result[key].Current_Status__c);
              //  this.onHoldPreRisk = result[key].Current_Status__c == 'On Hold' ? true : false;
              if(result[key].Current_Status__c == 'On Hold'){
                this.onHoldPreRisk=true;
            }
            else{
                this.notonholdPreRisk=true;
            }
                this.preredid = result[key].Id;
            } 
            //this.isLoading=false; 
        }
        
    }).catch((error) => {
        console.log(error);
    });
   }
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
        console.log('166');
        this.wiredObRiskHistory = value;
        console.log('168');
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
       
    handleAccordion(event) {
        if(event.target.dataset.name != null) return;
        let type = event.currentTarget.dataset.type;
        if(type === 'post') {
            this.showPostRiskHistory = !this.showPostRiskHistory
        } else if(type === 'ob') {
            this.showObRiskHistory = !this.showObRiskHistory
        } else if(type === 'pre') {
            this.showPreRiskHistory = !this.showPreRiskHistory
        }
    }
    
    handleRisk(event){
        console.log('handle risk');
        let eventName = event.target.dataset.name;
        this.spinner = false;
        if (eventName == 'Post Hold' || eventName == 'Post Release') {
            this.postRiskLabelTeam = postRiskLabel;
            this.postReleaseTeam = postRiskReleaseLabel;
            if(eventName == 'Post Hold'){// added by rohit
                this.modalHeaderPost = true;// added by rohit
                this.holdHeader = eventName;// added by rohit
                this.modalHeaderRelease = false;// added by rohit
            }
            if(eventName == 'Post Release'){// added by rohit
                this.modalHeaderRelease = true;// added by rohit
                this.releaseHeader = eventName;// added by rohit
                this.modalHeaderPost = false;// added by rohit
            }
            if (!this.postRiskLabelTeam.includes(this.userId.substring(0,15)) && eventName == 'Post Hold'){
                alert('you do not  have access');
                // this.isLoading = false;
                return;
            }else if(!this.postReleaseTeam.includes(this.userId.substring(0,15))&& eventName == 'Post Release'){
                alert('you do not  have access');
                // this.isLoading = false;
                return;
            }else if(eventName == 'Post Release'){
                this.showNotification();
                // this.isLoading = false;
                return;
            }
            this.riskManagementModal = true;
            this.templatetypeparent = eventName;

        }
        if(eventName == 'OB Hold' || eventName == 'OB Release'){
            this.obRiskLabelTeam = obRiskLabel;
            this.obReleaseTeam = OBRiskReleaseLabel;
            if(eventName == 'OB Hold'){// added by rohit
                this.modalHeaderPost = true;// added by rohit
                this.holdHeader = eventName;// added by rohit
                this.modalHeaderRelease = false;// added by rohit
            }
            if(eventName == 'OB Release'){// added by rohit
                this.modalHeaderRelease = true;// added by rohit
                this.releaseHeader = eventName;// added by rohit
                this.modalHeaderPost = false;// added by rohit
            }
            if (!this.obRiskLabelTeam.includes(this.userId.substring(0,15)) && eventName == 'OB Hold'){
                alert('you do not  have access');
                return;
            }else if(!this.obReleaseTeam.includes(this.userId.substring(0,15))&& eventName == 'OB Release'){
                alert('you do not  have access');
                return;
            }
            this.templatetypeparent = eventName;
            this.riskManagementModal = true;

        }

        if(eventName == 'Pre Hold' || eventName == 'Pre Release'){
            this.preRiskLabelTeam = preRiskLabel;
            this.preReleaseTeam = preRiskReleaseLabel;
            if(eventName == 'Pre Hold'){// added by rohit
                this.modalHeaderPost = true;// added by rohit
                this.holdHeader = eventName;// added by rohit
                this.modalHeaderRelease = false;// added by rohit
            }
            if(eventName == 'Pre Release'){// added by rohit
                this.modalHeaderRelease = true;// added by rohit
                this.releaseHeader = eventName;// added by rohit
                this.modalHeaderPost = false;// added by rohit
            }
            if (!this.preRiskLabelTeam.includes(this.userId.substring(0,15)) && eventName == 'Pre Hold'){
                alert('you do not  have access');
               // this.isLoading = false;
                return;
            }else if(!this.preReleaseTeam.includes(this.userId.substring(0,15))&& eventName == 'Pre Release'){
                alert('you do not  have access');
                //this.isLoading = false;
                return;
            }
            //this.riskidparent = this.preredid;
            this.templatetypeparent = eventName;
            this.riskManagementModal = true;
        }
}


    handleStatus(event){
        console.log('event.detail:::::'+event.detail);
        this.onHoldPostRisk = false;
        this.notonholdPostRisk=false;
        this.onHoldOBRisk=false;
        this.notonholdOBRisk=false;
        this.onHoldPreRisk = false;
        this.notonholdPreRisk=false;
        this.getdata();
        // Promise.all([
        //     refreshApex(this.wiredObRiskHistory)
        // ]).then(()=> {
        //     console.log('test 307'); 
        // });
        this.handleDataChange();
        this.isLoading=false;
        /*if(this.closeModalHeader){
            this.riskManagementModal=true;
        }*/
        //else{
            this.riskManagementModal=false;
       // } 
       /***************Calling settlement api to get the Pending settlement amount by rohit gupta */
        updatePendingAmount({ oppId: this.recordId }).then((result) => {
        this.pendingAmount = result;
        const event = new ShowToastEvent({
            message:  this.pendingAmount,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        }).catch((error) => {
            console.log(error);
                this.isLoading = false;
        });
    /************END  */
    }
    showNotification(){
        const evt = new ShowToastEvent({
            title: 'Navigate to Release Note',
            message: 'Please create release note to release merchant on post risk hold via delegation matrix ',
            variant: 'warning',
        });
        this.dispatchEvent(evt);
    }

    handleSave(event){ 
        //this.spinner = true;
        if(event.target.dataset.name==='c-risk-record-type-new'){
            this.spinner=true;
        }
        console.log('records::::'+event.detail);
        //his.riskManagementModal = true;
        console.log('test311');
        //this.closeModalHeader = event.detail;
        //console.log('this.closeModalHeader::::::'+this.closeModalHeader);
        this.isLoading=true;
        console.log(this.template);
        console.log('309::::::::',this.template.querySelector(`${event.target.dataset.name}`));
        this.template.querySelector(`${event.target.dataset.name}`).handleSave();
    }
    handleModalClose(){
        console.log('modal close');
        this.riskManagementModal = false;


    }
    refreshdata(){
        // console.log('data change ',JSON.parse(JSON.stringify(this.data3)));
        // setTimeout(() => {
        //     console.log('calleed timeout');
        // }, 3000);
        console.log('test332');
        //this.spinner = false;
        // console.log('data change after ',JSON.parse(JSON.stringify(this.data3)));
        this.riskManagementModal=false;
       // refreshApex(this.getdata);
       // console.log('getdata',this.getdata);
        
        

    }
    createNewReleaseNote() {
        const defaultValues = encodeDefaultFieldValues({
            Opportunity__c: this.recordId
        })
        this[NavigationMixin.Navigate]({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "Release_Note__c",
                "actionName": "new"
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }
}