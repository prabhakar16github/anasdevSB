import { LightningElement, api } from "lwc";
import getRNCheck from "@salesforce/apex/RiskMatrixDelegationUtility.getRNCheck";
import getProcessInstances from "@salesforce/apex/RiskMatrixDelegationUtility.getProcessInstances";
const columns = [
  { label: "Comments", fieldName: "name" },
  { label: "Date", fieldName: "date"},
  { label: "Status", fieldName: "status" },
  { label: "Assigned To", fieldName: "assigned" }
];

export default class ReleaseNotesApprovalLog extends LightningElement {
  data;
  columns = columns;
  @api recordId;

  connectedCallback() {
    window.addEventListener('lwc://refreshView', () => {
        console.log('test');
    })
    getRNCheck({ recId: this.recordId }).then((result) => {
      this.rncheck = result.Analyst_L1_Status__c;
      this.processInfo =
        result.Analyst_process_info__c == undefined ||
        result.Analyst_process_info__c.length == 0
          ? []
          : JSON.parse(result.Analyst_process_info__c);
      getProcessInstances({ recId: this.recordId }).then((pis) => {
        this.data = [];
        this.processInfo.forEach(pi => {
            let data = pi.split('|||');
            let value = data[0];
            let date = data[1];
            let comment = data[2];
            this.data.push({name: comment == undefined ? '' : comment, assigned: value == 'true' ? 'L1 Initiators' : 'Analysts', date: date, status: value == 'true' ? 'Approved' : 'Reverted'})
        })
        
        pis.forEach(pi => {
            pi.StepsAndWorkitems.forEach(step => {
                let d = new Date(step.CreatedDate);

                this.data.push({name: step.Comments, assigned: step.OriginalActor.Name, date: d.toLocaleString('en-GB', {hour12: true}), status: step.StepStatus == 'Started' ? 'Approved' : step.StepStatus})
            })
        })

        console.log(this.data);
        for(let i = 0; i < this.data.length; i++) {
            for(let j = 0; j < this.data.length - i - 1; j++) {
                let datestr1 = this.data[j].date.split(', ');
                let d1 = new Date(Date.parse(datestr1[0].replaceAll('/','-').split('-').reverse().join('-') + ' ' + datestr1[1]));
                let datestr2 = this.data[j + 1].date.split(', ');
                let d2 = new Date(Date.parse(datestr2[0].replaceAll('/','-').split('-').reverse().join('-') + ' ' + datestr2[1]));

                console.log(d1, d2)

                if(d1 < d2) {
                    let temp = this.data[j];
                    this.data[j] = this.data[j + 1];
                    this.data[j + 1] = temp;
                }
            }
        }
        console.log(JSON.stringify(pis));
      });
    });
  }
}