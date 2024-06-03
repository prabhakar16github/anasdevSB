import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
// import getRecordIdOrCreateRecord from '@salesforce/apex/RiskManagementStatusController.getRecordTypeIdAndStatus';
//import  riskRecordHistory from '@salesforce/apex/RiskManagementStatusController.riskRecordHistory';
import  postRiskHistory from '@salesforce/apex/RiskManagementStatusController.postRiskHistory';
import  obRiskHistory from '@salesforce/apex/RiskManagementStatusController.obRiskHistory';
import  preRiskHistory from '@salesforce/apex/RiskManagementStatusController.preRiskHistory';
import  oppData from '@salesforce/apex/RiskManagementStatusController.websitePages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
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
    @api test=false;
    @api recordId;
    @track data1 = [];
    @track data2 = [];
    @track data3 = [];
    columns1 = columns1;
    columns2 = columns2;
    columns3 = columns3;
    isLoading;
    showedit=true;
    wiredPostRiskHistory;
    wiredObRiskHistory;
    wiredPreRiskHistory;

    showPostRiskHistory = false;
    showPreRiskHistory = false;
    showObRiskHistory = false;

    spinner=false;
    onHoldPostRisk = false;
    onHoldOBRisk = true;
    onHoldPreRisk = false;
    commentsection=false;
    lobspinner=false;
    postrecid;
    obredid;
    preredid;
    templatetypeparent;
    @track userId = Id;
    @track BusinessEntity;
    @track BusinessCategory;
    @track BusinessSubCatagory;
    @track website;
    websitepages;
    websitepagesize;
    approvednumber=0;
    rejectednumber=0;
    pendingnumber=0;
    websiteVerification = false;
    lineOfBusinessVerification = false;
    OtherProductsModal = false;
    postRiskLabelTeam = [];
    obRiskLabelTeam = [];
    preRiskLabelTeam = [];
    @track websitepagesize=0;
    postReleaseTeam = [];
    obReleaseTeam = [];
    preReleaseTeam = [];

    Progressstatus;
    lobprocessstatus;
    @track showRiskRemarksError = false;// added by rohit
    prodStatusValue;// added by rohit
    policieStatus;// added by rohit
    contactStatus;// added by rohit
    websiteStatusValue; //added by rohit
    isCallingWebsitePage = false;

    connectedCallback(){
        this.getData();
       

    }

    getData(){
        oppData({oppId:this.recordId}).then(res=>{
            console.log('getdata --',res);
        this.websiteStatusValue =  res[0].Website_Status__c; // added byb rohit risk revamp
        console.log('this.websiteStatusValue::::::'+this.websiteStatusValue);
        this.BusinessEntity = res[0].BusinessEntityName__c;
        this.BusinessCategory = res[0].Business_Category__c;
        this.BusinessSubCatagory = res[0].SubCategory__c;
        this.website = res[0].Website__c;
        this.websitepages=res[0].Website_Pages__r;
        console.log('websitepages',this.websitepages);
        console.log('res[0].LOB_Status_PreRisk__c:::::'+res[0].LOB_Status_PreRisk__c);
        //console.log(this.websitepages.length);
        if(res[0].LOB_Status_PreRisk__c==='LOB Approved'){//Approved
            this.lobprocessstatus='LOB Approved';//Approved // earlier it was Approved
            this.Progressstatus ='Website OK';
        }
        if(res[0].LOB_Status_PreRisk__c==='LOB Rejected'){//Rejected earlier it was rejected
            this.lobprocessstatus='LOB Rejected';//Rejected
            this.Progressstatus ='Website Error';//Rejected
        }
        if(res[0].LOB_Status_PreRisk__c==='LOB Error'){//Pending earlier it was pending
            this.lobprocessstatus='LOB Error';//Pending
            this.Progressstatus ='Website Error';//Pending
        }
        if(res[0].LOB_Status_PreRisk__c===undefined){
            this.Progressstatus = this.websiteStatusValue;
            console.log('this.Progressstatus:::::::'+this.Progressstatus);
        }
        if( this.websiteStatusValue =='Pending' ||  this.websiteStatusValue =='Verification in Process'){
            this.Progressstatus = 'Verification in Process';
        }
        if( this.websiteStatusValue =='Not Applicable'){
            this.Progressstatus = this.websiteStatusValue;
        }
        if( this.websitepages){// added by rohit only if condition : to check if there is a value in this.websitepages then only it'll come inside if
            this.websitepages.forEach(element => {
                /*if(element.Group__c !=null){
                    this.websitepagesize=this.websitepagesize+1;
                }
                if(element.Group__c!=null && element.Approval_Type__c==='Approved'){
                    this.approvednumber=this.approvednumber+1;
                }
                else if(element.Group__c!=null && element.Approval_Type__c==='Rejection'){
                    this.rejectednumber=this.rejectednumber+1;
                }
                else{
                    this.pendingnumber=this.pendingnumber+1;
                }*/
                if(element.Approval_Type__c !=null){
                    this.isCallingWebsitePage = true;
                }
            });
            if(this.isCallingWebsitePage){
                this.Progressstatus =  res[0].Website_Status__c;
            }
                //console.log('websitepagesize::::::'+this.websitepages.length);
            /*console.log('this.approvednumber::::::'+this.approvednumber);
            if(this.websitepagesize !=0 && this.websitepagesize===this.approvednumber){
                this.Progressstatus='Website OK';//'Success';// commented by rohit
            }
            else if(this.websitepagesize===this.approvednumber){
                this.Progressstatus='Not Applicable';//'Success';// commented by rohit
            }
            else if(this.rejectednumber){
                this.Progressstatus='Website Error';//'Rejected'; commented by rohit
            }
            else{
                this.Progressstatus='Verification in Process'//'In Progress'// commented by rohit
            }*/
        }
       
        /*updateWebsiteOnOppAndWebsiteDetails({oppId:this.recordId, progressStatus : this.Progressstatus})
        .then((result) => {
          })
          .catch((error) => {
          });*/
        /*if(res[0].LOB_Status_PreRisk__c==='LOB Rejected'){
            this.Progressstatus='Website Error';// added by rohit
        }
        if(res[0].LOB_Status_PreRisk__c==='LOB Error'){
            this.Progressstatus='Website Error';// added by rohit
        }
        if(res[0].LOB_Status_PreRisk__c==='LOB Approved'){
            this.Progressstatus='Website OK';// added by rohit
        }*/
          console.log('this.Progressstatus::123:::::'+this.Progressstatus);
        })
       
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

    handleEvaluate(event){
        let eventname = event.target.dataset.name;
        console.log('evaluationg the '+eventname);
        if (eventname === 'websiteEvaluation'){
            this.websiteVerification = true
        }else if(eventname === 'businessEvaluation'){
            this.lineOfBusinessVerification = true
        }else if(eventname === 'otherProductsEvaluation'){
            this.OtherProductsModal = true;
        }
    }
 
    handleComment(event){
        let eventname = event.target.dataset.name;
        console.log('comment the '+eventname);
        this.commentsection=true;

    }



    showNotification(){
        const evt = new ShowToastEvent({
            title: 'Navigate to Release Note',
            message: 'Please use Delegation matrix to Release Post Risk Hold ',
            variant: 'warning', 
        });
        this.dispatchEvent(evt);
    }
    handleWebsiteStatusValue(event){
        this.prodStatusValue = event.detail.prodStatus;
        this.policieStatus = event.detail.policieStatus;
        this.contactStatus = event.detail.contactStatus;
        console.log('event290::'+ this.prodStatusValue +'   PolicieStatus:::::'+this.policieStatus +'   ContactStatus::::'+this.contactStatus);
    }
     handleSave(event){ 
        //console.log('showRiskRemarksError :::::::'+ event.detail.hasError);
        /*if(event.target.dataset.name==='c-website-verfication-management'){
            console.log('inside if::::292');
            this.spinner=true;
        }*/
         if(event.target.dataset.name==='c-line-of-business-verification-management'){
            //this.lobspinner=true;// commented by rohit
        }
        console.log(this.spinner);
        // this.websiteVerification = false;
       // this.lineOfBusinessVerification = false
        this.OtherProductsModal = false;
        this.commentsection=false;
        console.log('aa ',event.target.dataset.name);
         this.template.querySelector(`${event.target.dataset.name}`).handleSave();
        console.log('264modal save');
        console.log('265'); 
    //     this.websitepagesize=0;
    //     this.approvednumber=0;
    //     this.rejectednumber=0;
    //    this.pendingnumber=0;
    //    this.websiteVerification = false;
    //     this.getData();

    }
    handleModalClose(){
        console.log('modal close');
        this.OtherProductsModal = false;
        this.lineOfBusinessVerification = false
        this.websiteVerification = false
        this.commentsection=false;
    }

    handlesave(event){
        console.log('line of business saved');
        this.getData();
        this.lobspinner=false;
        this.lineOfBusinessVerification=false;
        // console.log(event.detail.value,'val');
        // this.BusinessEntity = event.detail.value.BusinessEntity;
        // this.BusinessCategory = event.detail.value.BusinessCategory;
        // this.BusinessSubCatagory = event.detail.value.BusinessSubCatagory;
        // this.website = event.detail.value.website;

    }
    datarefresh(event){
        console.log(event);
        console.log('286'); 
        this.websitepagesize=0;
        this.approvednumber=0;
        this.rejectednumber=0;
       this.pendingnumber=0;
        this.getData();
        this.spinner=false;
        this.websiteVerification = false;

    }
    edittable(event){
        this.showedit=false;
        console.log(event);
        console.log(this.template.querySelector(`${event.target.dataset.name}`));
        this.template.querySelector(`${event.target.dataset.name}`).edittabledata();
    }
    cancletable(event){
        console.log('336');
        this.showedit=true;
        this.template.querySelector(`${event.target.dataset.name}`).cancletabledata();
    }
    savetable(event){
        this.showedit=true;
        this.template.querySelector(`${event.target.dataset.name}`).savetabledata();
    }
    showdocument(){
        console.log('345');
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "C__WebsiteDocument_preOnboardingCmp"
            },
            state: {
                recordId: this.recordId,
            }
        });
    }   
}