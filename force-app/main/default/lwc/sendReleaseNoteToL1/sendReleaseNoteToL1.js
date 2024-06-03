import { LightningElement , wire ,  api} from 'lwc';
import getRNCheck from "@salesforce/apex/RiskMatrixDelegationUtility.getRNCheck";
import getAnalystAccess from "@salesforce/apex/RiskMatrixDelegationUtility.getAnalystAccess";
import updateRNAnalystL1Status from "@salesforce/apex/RiskMatrixDelegationUtility.updateRNAnalystL1Status";
import { CloseActionScreenEvent } from 'lightning/actions';


export default class SendReleaseNoteToL1 extends LightningElement {
    callcheck = false;
    rncheck;
    accesscheck = false;
    processInfo;
    comment;
    @api recordId;

    // @wire(getRNCheck, {'recId': '$recordId'})
    // wiredRNCheck({data, error}) {
    //     if(data) {
    //         console.log(data, 'data============');
    //         this.rncheck = data.Analyst_L1_Status__c;
    //     } else if(error){
    //         console.log(error, 'error========');
    //     }
    // }

    renderedCallback() {
        setTimeout(() => {
            console.log(this.recordId);
            if(!this.callcheck) {
                getRNCheck({recId: this.recordId})
                .then(result => {
                    this.rncheck = result.Analyst_L1_Status__c;
                    this.processInfo = result.Analyst_process_info__c == undefined || result.Analyst_process_info__c.length == 0 ? [] : JSON.parse(result.Analyst_process_info__c);
                    this.callcheck = true;
                    getAnalystAccess({recId: this.recordId})
                    .then(res => {
                        this.accesscheck = res;
                    })
                })
                .catch(err => {
                    throw err;
                })
            }
        }, 0)
    }

    commentChange(event) {
        this.comment = event.target.value;
    }

    handleSave() {
        let d = new Date();
        this.processInfo.push('true|||' + d.toLocaleString('en-GB', { hour12 : true}) + '|||' + (this.comment == undefined ? '' : this.comment));
        updateRNAnalystL1Status({'val': true, 'recId': this.recordId, 'comment': JSON.stringify(this.processInfo)})
        .then(() => {
            eval('$A.get("e.force:refreshView").fire()');
            this.dispatchEvent(new CloseActionScreenEvent());
        })
    }
}