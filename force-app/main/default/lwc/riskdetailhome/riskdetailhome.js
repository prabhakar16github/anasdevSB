import { LightningElement ,track ,api} from 'lwc';
import getRecordIdOrCreateRecord from '@salesforce/apex/RiskManagementStatusController.getRecordTypeIdAndStatus';


export default class Riskdetailhome extends LightningElement {
    @api recordId;
    @track idlistrecord = [];
    homePage = true;
    @track postrecid;
    @track obredid;
    @track preredid;
    @track poststatus;
    @track obstatus;
    @track prestatus;
    showLoading = false;
    statusPage = false;

    connectedCallback(){
        this.showLoading = true;
    }
    
    renderedCallback(){
        this.showLoading = false;
    }
    
    
    handleRiskButton(event){
        getRecordIdOrCreateRecord({ oppId: this.recordId }).then((result) => {
            console.log('result', result);
            this.idlistrecord = [];
            for (var key in result) {
                this.idlistrecord.push({ key: key, value: result[key] });
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
                
            }
            
        }).catch((error) => {
            console.log(error);
        });
       
    this.statusPage = true;
          
    }

   
}