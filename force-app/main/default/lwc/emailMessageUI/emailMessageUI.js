import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmailMessageOnLoad from '@salesforce/apex/EmailMessageUIController.getEmailMessageOnLoad';
import getAttachmentAndFiles from '@salesforce/apex/EmailMessageUIController.getAttachmentAndFiles';
//import downloadDoc from '@salesforce/apex/EmailMessageUIController.downloadDoc';

export default class EmailMessageUI extends LightningElement {
@api recordId;
showSpinner = false;
columnsName = [];
allData = [];
showData = false;
showModal = false;
textBody = '';
listDoc = [];
showModalAttachment = false;
showAttachmentTable = false;

connectedCallback() {
    this.showSpinner = true;
    getEmailMessageOnLoad({parentId : this.recordId})
    .then(result => {
        if(result.message.includes('SUCCESS')) {
            this.columnNames = JSON.parse(result.columnNames);
            this.allData = result.listData;
            if(this.allData.length > 0) {
                this.showData = true;
            }
            this.showSpinner = false;
        }
        else {
            this.showSpinner = false;
            this.showToast('ERROR','error',result.message);
        }
    })
    .catch(error => {
        this.showSpinner = false;
        this.showToast('ERROR','error',error);
    })
}

showToast(title,variant,message) {
    const event = new ShowToastEvent({
        title : title,
        message : message,
        variant : variant
    });
    this.dispatchEvent(event);
}

viewRecord(event) {
    this.textBody = '';
    this.listDoc = [];
    this.showAttachmentTable = false;
    if(event.detail.action.name == 'view') {
        this.showModal = true;
        this.textBody = event.detail.row.TextBody__c;
    }
    else if(event.detail.action.name == 'viewDoc') {
        this.showSpinner = true;
        getAttachmentAndFiles({recordId : event.detail.row.RecordId__c})
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.listDoc = result.listDocuments;
                if(this.listDoc.length > 0) {
                    this.showAttachmentTable  = true;
                }
                this.showModalAttachment = true;
                this.showSpinner = false;
            }
            else {
                this.showSpinner = false;
                this.showToast('ERROR','error',result.message);
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToast('ERROR','error',error);
        })
    }
}

closeModal(event) {
    this.showModal = false;
    this.textBody = '';
}

closeModalAttachment(event) {
    this.showModalAttachment = false;
    this.listDoc = [];    
}

downloadDoc(event) {
    //this.showSpinner = true;
    let url = 'https://payuindia-my.sharepoint.com/personal/salesforce_backup_payu_in/Documents/'+event.currentTarget.dataset.id;
    window.open(url);
    /*downloadDoc({fileName : event.currentTarget.dataset.id})
        .then(result => {
            if(result.includes('SUCCESS')) {
                this.showSpinner = false;
                window.open(result.split('#')[1]);
            }
            else {
                this.showSpinner = false;
                this.showToast('ERROR','error',result);
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToast('ERROR','error',error);
        })*/
    }
}