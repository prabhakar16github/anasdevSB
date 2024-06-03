import { api, LightningElement, track, wire } from 'lwc';
import getComments from '@salesforce/apex/ConversationFlowController.getComments';

export default class ConversationFlowComp extends LightningElement {
    @api recordId;

    @track commentList = [];

    connectedCallback(){
        //getComments,{oppId: 'recordId'}
        

        getComments({oppId : this.recordId})
        .then(result => {
            this.commentList = result;
            console.log('>>>>>commentList>>>>>'+JSON.stringify(this.commentList));
            
        })
        .catch(error => {
            
        })
    }
    /* @wire(getComments,{oppId: '$recordId'}) 
    wiredRecords({error,data}){
        //alert('>>>>recordId>>>>'+this.recordId);
        if(data){
            alert(JSON.stringify(data));
            this.commentList = data;

        }else if(error){
            console.log(error);
        }

    } */
}