import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, updateRecord, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_PRODUCT_INTEREST_OBJECT from '@salesforce/schema/Lead_Product_Interest__c';
//import LEAD_PRODUCT_INTEREST_FIELD from '@salesforce/schema/Lead_Product_Interest__c.Lead__c';
//import LEAD_PRODUCT_INTEREST_FIELD from '@salesforce/schema/Lead.Lead_Product_Interest__c';
import { getFieldValue  } from 'lightning/uiRecordApi';


export default class ProductInterestTest_2 extends LightningElement {
    @track products = [
        {
            id: 1,
            productName: 'Wallets',
            subProductName: 'All Wallets',
            checked: false,
            interestReason: '',
            leadProductId: ''
        },
        {
            id: 2,
            productName: 'Visa Checkout',
            subProductName: 'VISA CHECKOUT - VIES',
            checked: false,
            interestReason: '',
            leadProductId: ''
        },
        {
            id: 3,
            productName: 'UPI',
            subProductName: 'Third Party Verification UPI',
            checked: false,
            interestReason: '',
            leadProductId: ''
        },
        // Add more product rows here
    ];

    interestReasonOptions = [
        { label: 'Option 1', value: 'Option 1' },
        { label: 'Option 2', value: 'Option 2' },
        // Add more options here
    ];

    @api recordId;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [LEAD_OBJECT.Lead_Product_Interest__r]
    })
    leadRecord;

    connectedCallback(){
        if(!this.recordId) {
            this.recordId = '';
        }
    }

    // get recordId() {
    //     return this.recordId;
    // }



    // connectedCallback() {
    //     // Populate initial data from the LeadProductInterest record
    //     const productInterest = getFieldValue(this.leadRecord.data, PRODUCT_INTEREST_FIELD);
    //     if (productInterest) {
    //         this.products.forEach((product) => {
    //             product.checked = productInterest[product.id].checked;
    //             product.interestReason = productInterest[product.id].interestReason;
    //             product.leadProductId = productInterest[product.id].leadProductId;
    //         });
    //     }
    // }

    handleCheckboxChange(event) {
        const productId = event.target.dataset.productId;
        const checked = event.target.checked;
        const product = this.products.find((p) => p.id === productId);
        if(product){
            product.checked = checked;
            this.updateLeadProductInterest(productId, checked, product.interestReason);
        }
        

        // Update the LeadProductInterest record with the new checkbox value
        //this.updateLeadProductInterest(productId, checked, product.interestReason);
    }

    handlePicklistChange(event) {
        const productId = event.target.dataset.productId;
        const interestReason = event.target.value;
        const product = this.products.find((p) => p.id === productId);
        if(product){
            product.interestReason = interestReason;

        // Update the LeadProductInterest record with the new picklist value
        this.updateLeadProductInterest(productId, product.checked, interestReason);
        }
        
    }

    updateLeadProductInterest(productId, checked, interestReason) {
        const product = this.products.find((p) => p.id === productId);
        if (product) {
            if (this.leadProductInterest) {
                const fields = {};
                //fields[LEAD_PRODUCT_INTEREST_FIELD.fieldApiName] = {
                    fields['Id'] = product.leadProductId;
                    fields['Checkbox_1__c'] = checked;
                    fields['Checkbox_2__c'] = checked;
                    fields['Checkbox_3__c'] = checked;
                    fields['Picklist_1__c'] = interestReason;
                    fields['Picklist_2__c'] = interestReason;
                    fields['Picklist_3__c'] = interestReason;
                //};

                // const recordInput = {
                //     fields: fields
                // };
                const recordInput = { fields };

                updateRecord(recordInput)
                    .then((result) => {
                        // Handle success
                        this.showToast('Success', 'Lead Product Interest Updated', 'success');
                    })
                    .catch((error) => {
                        // Handle error
                        this.showToast('Error', 'Failed to Update Lead Product Interest', 'error');
                    });
            } else {
                const fields = {};
                fields['Lead__c'] = this.recordId;
                fields['Checkbox_1__c'] = checked;
                fields['Checkbox_2__c'] = checked;
                fields['Checkbox_3__c'] = checked;
                fields['Picklist_1__c'] = interestReason;
                fields['Picklist_2__c'] = interestReason;
                fields['Picklist_3__c'] = interestReason;

                const recordInput = {
                    apiName: LEAD_PRODUCT_INTEREST_OBJECT.objectApiName,
                    fields: fields
                };

                createRecord(recordInput)
                    .then((result) => {
                        // Handle success
                        product.leadProductId = result.id;
                        this.showToast('Success', 'Lead Product Interest Created', 'success');
                    })
                    .catch((error) => {
                        // Handle error
                        this.showToast('Error', 'Failed to Create Lead Product Interest', 'error');
                    });
            }
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get leadProductInterest() {
        return getFieldValue(this.leadRecord.data, LEAD_OBJECT.Lead_Product_Interest__r);
    }



}