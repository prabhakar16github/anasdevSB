// import { LightningElement, api, wire } from 'lwc';
// import getProductInterests from '@salesforce/apex/ProductInterestController.getProductInterests';

// export default class ProductInterestLead_3 extends LightningElement {
//     @api recordId;
//     productInterests = [];
//     picklistOptions = [
//         { label: 'Option 1', value: 'Option 1' },
//         { label: 'Option 2', value: 'Option 2' }
//     ];

//     @wire(getProductInterests, { leadId: '$recordId' })
//     wiredProductInterests({ data, error }) {
//         if (data) {
//             this.productInterests = data;
//         } else if (error) {
//             console.error('Error retrieving product interests:', error);
//         }
//     }

//     handleCheckboxChange(event){
//         const recordId = event.target.dataset.recordId;
//         const isChecked = event.target.checked;

//         const prodInterest = this.productInterests.find((pi) => pi.Id === recordId);
//         if(prodInterest) {
//             prodInterest.Checkbox_1__c = isChecked;
//         }
//     }

//     handlePicklistChange(event){
//         const recordId = event.target.dataset.recordId;
//         const selectedValue = event.target.value;

//         const prodInterest = this.productInterests.find((pi) => pi.Id === recordId);
//         if(prodInterest) {
//             prodInterest.Picklist_1__c = selectedValue;
//         }
//     }

//     handleSave(){
//         const productInterestsToUpdate = JSON.parse(JSON.stringify(this.productInterests));

//         updateProductInterest_2({ productInterestsToUpdate })
//             .then(() => {
//                 console.log('Product Interest updated successfully');
//             })
//             .catch((error) => {
//                 console.error('Error updating product interest : ', error);
//             });
//     }

// }