import { LightningElement ,   api} from 'lwc';
import getRNCheck from "@salesforce/apex/RiskMatrixDelegationUtility.getRNCheck";
import updateRNAnalystL1Status from "@salesforce/apex/RiskMatrixDelegationUtility.updateRNAnalystL1Status";
import { CloseActionScreenEvent } from 'lightning/actions';


export default class SendReleaseNoteToAnalyst extends LightningElement {
    callcheck = false;
    rncheck;
    comment;
    processInfo;
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
        this.processInfo.push('false|||' + d.toLocaleString('en-GB', { hour12 : true}) + '|||' + (this.comment == undefined ? '' : this.comment));
        updateRNAnalystL1Status({'val': false, 'recId': this.recordId, 'comment': JSON.stringify(this.processInfo)})
        .then(() => {
            eval('$A.get("e.force:refreshView").fire()');
            this.dispatchEvent(new CloseActionScreenEvent());
        })
    }
}