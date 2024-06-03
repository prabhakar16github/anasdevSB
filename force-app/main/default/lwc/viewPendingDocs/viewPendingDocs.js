import { LightningElement, api, track } from 'lwc';
import fetchDataFromApi from '@salesforce/apex/ViewPendingDocs.fetchDataFromApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class ViewPendingDocsLWC extends LightningElement {
    @track rekycJourney;
    @track panStatus;
    @track bankStatus;
    @track websiteStatus;
    @track agreementStatus;
    @track documentstatus;
    @track docsStatus;
   // @track oppId
    @api recordId;
    renderedCallback(){
        var cells = this.template.querySelectorAll('.changeColor');
        cells.forEach((cell)=>{
        if(cell){
            if(cell.textContent.trim() == 'PENDING' || cell.textContent.trim() == 'Pending'){
                cell.style.color = 'red';
            }
            else if(cell.textContent.trim() == 'COMPLETED' || cell.textContent.trim() == 'Approved'){
                cell.style.color = 'green';
            }
            else if(cell.textContent.trim() == 'IN_PROGRESS' || cell.textContent.trim() == 'DOCUMENT_SUBMITTED'){
                cell.style.color = 'blue';
            }
            else if(cell.textContent.trim() == 'FAILURE' || cell.textContent.trim() == 'Declined'){
                cell.style.color = 'orange';
            }
            else if(cell.textContent.trim() == 'LOCKED'){
                cell.style.color = 'grey';
                
            }
        }
    });
    }
    connectedCallback(){
        setTimeout(() => {
      

            fetchDataFromApi({ oppId: this.recordId})

            .then(result => {
                console.log('>>>>>>>>'+result);

           
                    
                    this.rekycJourney = result.is_rekyc;
                    this.panStatus = result.pan_status;
                    this.bankStatus = result.bank_status;
                    this.websiteStatus = result.website_status;
                    this.agreementStatus = result.agreement_status;
                    this.documentstatus = result.document_status;
                    this.docsStatus = result.all_doc_status;
                    var cell = document.getElementById('changeColor');
                    this.renderedCallback();

            
         
         })
            .catch(error => {
                
                //this.showToast('ERROR', 'error', error);
            })
        }, 5);
    }

   
        
}