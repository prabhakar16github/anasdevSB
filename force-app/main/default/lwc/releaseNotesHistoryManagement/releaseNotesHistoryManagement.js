import { LightningElement, api, wire } from 'lwc';
import getReleaseNotes from "@salesforce/apex/RiskMatrixDelegationUtility.getReleaseNotes";
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils'
export default class ReleaseNotesList extends NavigationMixin(LightningElement) {
    @api recId;
    releaseNotes = [];

    @api
    get cardTitle() {
        return 'Release Notes (' + this.rnLength + ')';
    }

    rnLength = 0;

    @api
    get viewAllVisible() {
        return this.rnLength > 3;
    }



    connectedCallback() {
        console.log(this.recId);
    }

    @wire(
        getReleaseNotes, {'oppId': '$recId'}
    )
    wiredReleaseNotes({error, data}) {
        if(data) {
            console.log(data);
            console.log('data', data, JSON.parse(data[0]), JSON.parse(data[1]));
            this.releaseNotes = []
            let rnStatuses = JSON.parse(data[1]);
            let recs = JSON.parse(data[0]);
            console.log('releaseNotes::::', JSON.parse(JSON.stringify(recs)));
            recs.forEach((rn, index) => {
                let obj = JSON.parse(JSON.stringify(rn));
                obj.index = index + 1;
                obj.url = '/' + obj.Id;
                obj.submittedDate = obj.ProcessInstances && obj.ProcessInstances.records.length > 0 ? new Date(obj.ProcessInstances.records[0].CreatedDate).toLocaleDateString('en-GB') : '';
                obj.CreatedDate = new Date(obj.CreatedDate).toLocaleDateString('en-GB');
                obj.Status__c = obj.ProcessInstances && obj.ProcessInstances.records.length > 0 ? rnStatuses[obj.ProcessInstances.records[0].Id] : obj.Status__c;
                
                // rn = obj;
                this.releaseNotes.push(obj);
                console.log(obj);
            })
            // this.releaseNotes = [...data];
            this.rnLength = recs.length;
            
        }

        if(error) {
            throw error;
        }
    }

    createNewReleaseNote() {
        const defaultValues = encodeDefaultFieldValues({
            Opportunity__c: this.recId
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