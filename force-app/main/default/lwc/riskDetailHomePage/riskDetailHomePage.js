import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import postRiskLabel from '@salesforce/label/c.Hold_Users_For_Post_risk';
import obRiskLabel from '@salesforce/label/c.Hold_Users_For_OB';
import preRiskLabel from '@salesforce/label/c.Hold_Users_For_Pre_risk';
import postRiskReleaseLabel from '@salesforce/label/c.Hold_Users_From_Post_risk';
import preRiskReleaseLabel from '@salesforce/label/c.Hold_Users_From_Pre_risk'; 
import OBRiskReleaseLabel from '@salesforce/label/c.Hold_Users_From_OB';

import getRecordIdOrCreateRecord from '@salesforce/apex/RiskManagementStatusController.getRecordTypeIdAndStatus';
import statusOfHoldType from '@salesforce/apex/RiskManagementStatusController.statusOfHoldType';
import updatePendingAmount from '@salesforce/apex/PendingSettlementAmount_Controller.updatePendingAmount';
import Id from '@salesforce/user/Id';

export default class RiskDetailHomePage extends NavigationMixin(LightningElement) {
   
    @api recordId;
    postrecid;
    obredid;
    preredid;
    poststatus;
    obstatus;
    prestatus;
     
    //@track riskidparent;

    @track templatetypeparent;
    @track showRiskRecord;
    @track isLoading = true;
    postRiskLabelTeam = [];
    obRiskLabelTeam = [];
    preRiskLabelTeam = [];
    postReleaseTeam = [];
    preReleaseTeam = [];
    obReleaseTeam = [];
    pendingAmount // added by rohit
   
    @track userId = Id;

   connectedCallback(){
        getRecordIdOrCreateRecord({ oppId: this.recordId }).then((result) => {
            this.isLoading = true;
            for (var key in result) {
                
                if(result[key].Hold_Type__c == 'Post Hold'){
                    this.poststatus = result[key].Current_Status__c;
                    this.postrecid = result[key].Id;
                }
                if(result[key].Hold_Type__c == 'OB Hold'){
                    this.obstatus = result[key].Current_Status__c;
                    this.obredid = result[key].Id;
                }  
                if (result[key].Hold_Type__c == 'Pre Hold') {
                    this.prestatus = result[key].Current_Status__c;
                    this.preredid = result[key].Id;
                } 
                this.isLoading=false; 
            }
            
        }).catch((error) => {
            console.log(error);
            this.isLoading = false;
        });
   }
    
   
    
    

    get textColorPost(){ return this.poststatus  == 'Not On Hold' ? "slds-text-color_success" : "slds-text-color_destructive";}

    get textColorOB(){return this.obstatus  == 'Not On Hold' ? "slds-text-color_success" : "slds-text-color_destructive";}

    get textColorPre(){return this.prestatus  == 'Not On Hold' ? "slds-text-color_success" : "slds-text-color_destructive";}

    get disablePostHold(){return (this.poststatus == 'On Hold') ? true : false;}

    get disablePostRelease(){return (this.poststatus == 'Not On Hold') ? true : false; }

    get disableOBHold(){return (this.obstatus == 'On Hold') ? true : false;}

    get disableOBRelease(){return (this.obstatus == 'Not On Hold') ? true : false;}

    get disablePreHold(){return (this.prestatus == 'On Hold') ? true : false;}

    get disablePreRelease(){ return (this.prestatus == 'Not On Hold') ? true : false;}
    

    handleClick(event){
       this.isLoading = true;
        const eventName = event.target.name;
       
        /*this.postLabelTeam = postRiskLabel;
        console.log(this.postLabelTeam+''+this.userId.substring(0,15) +""+this.postLabelTeam.includes(this.userId.substring(0,15)));
        if (!this.postLabelTeam.includes(this.userId.substring(0,15))|| !obRiskLabel.includes(this.userId.substring(0,15)) || preRiskLabel.includes(this.userId.substring(0,15))) {
            alert('you do not  have access');
           
            return;
           }*/
        if (eventName == 'Post Hold' || eventName == 'Post Release') {
            this.postRiskLabelTeam = postRiskLabel;
            this.postReleaseTeam = postRiskReleaseLabel;
            if (!this.postRiskLabelTeam.includes(this.userId.substring(0,15)) && eventName == 'Post Hold'){
                alert('you do not  have access');
                this.isLoading = false;
                return;
            }else if(!this.postReleaseTeam.includes(this.userId.substring(0,15))&& eventName == 'Post Release'){
                alert('you do not  have access');
                this.isLoading = false;
                return;
            }else if(eventName == 'Post Release'){
                this.showNotification();
                this.isLoading = false;
                return;
            }
            //this.riskidparent = this.postrecid;
            this.templatetypeparent = eventName;
            this.showRiskRecord = true;
            this.isLoading = false;

        }
        if(eventName == 'OB Hold' || eventName == 'OB Release'){
            this.obRiskLabelTeam = obRiskLabel;
            this.obReleaseTeam = OBRiskReleaseLabel;
            if (!this.obRiskLabelTeam.includes(this.userId.substring(0,15)) && eventName == 'OB Hold'){
                alert('you do not  have access');
                this.isLoading = false;
                return;
            }else if(!this.obReleaseTeam.includes(this.userId.substring(0,15))&& eventName == 'OB Release'){
                alert('you do not  have access');
                this.isLoading = false;
                return;
            }
            //this.riskidparent = this.obredid;
            console.log('125'+this.obredid);
            this.templatetypeparent = eventName;
            console.log('127'+this.templatetypeparent);
            this.showRiskRecord = true;
            this.isLoading = false;
        }

        if(eventName == 'Pre Hold' || eventName == 'Pre Release'){
            this.preRiskLabelTeam = preRiskLabel;
            this.preReleaseTeam = preRiskReleaseLabel;
            if (!this.preRiskLabelTeam.includes(this.userId.substring(0,15)) && eventName == 'Pre Hold'){
                alert('you do not  have access');
                this.isLoading = false;
                return;
            }else if(!this.preReleaseTeam.includes(this.userId.substring(0,15))&& eventName == 'Pre Release'){
                alert('you do not  have access');
                this.isLoading = false;
                return;
            }
            //this.riskidparent = this.preredid;
            this.templatetypeparent = eventName;
            this.showRiskRecord = true;
            this.isLoading = false;
        }
        
    }
    
    
    handleStatus(event){
        this.isLoading = true;
       
        statusOfHoldType({ oppId: this.recordId }).then((result) => {
           
            this.poststatus= result['Post Hold'];
            console.log('this.poststatus'+this.poststatus);
            this.obstatus = result['OB Hold'];
            console.log('this.obstatus'+this.obstatus);
            this.prestatus = result['Pre Hold'];
            console.log('this.prestatus'+this.prestatus);
            this.isLoading = false;

    }).catch((error) => {
        console.log(error);
        this.isLoading = false;
    });
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
    
    showNotification() {
        const evt = new ShowToastEvent({
            title: 'Navigate to Release Note',
            message: 'Please use Delegation matrix to Release Post Risk Hold ',
            variant: 'warning',
        });
        this.dispatchEvent(evt);
    }
   


}