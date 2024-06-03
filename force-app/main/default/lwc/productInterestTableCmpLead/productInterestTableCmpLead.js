import { LightningElement, wire, api, track  } from 'lwc';
import getLeadProductInterest from '@salesforce/apex/ProductInterestController.getLeadProductInterest'
import MID_FIELD from '@salesforce/schema/Lead.Prod_MID__c';
//const midField = [MID_FIELD];


export default class ProductInterestTableCmpLead extends LightningElement {
    // activeSections = ['Recommended', 'Active']
    // @api recordId

    // @track prodInterestData;
    // @track visibleRecords;

    // @wire(getLeadProductInterest, {leadId:'$recordId', fields: midField })
    // relatedProductInterest({data, error}){
    //     if(data){
    //         this.prodInterestData = [];
            
    //         data.forEach(item => {
    //             if(item.Product_Bundle_Detail__r != undefined) {
    //                 if(item.Product_Bundle_Detail__r.Sales_Bundle__r != undefined) {
    //                     let obj = JSON.parse(JSON.stringify(item));
    //                     obj.product = item.Product_Bundle_Detail__r.Sales_Bundle__r.Name
    //                     item = obj;
    //                 }
    //             if(item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r != undefined) {
    //                 let obj1 = JSON.parse(JSON.stringify(item));
    //                 obj1.sub_product = item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
    //                 item = obj1;
    //             }
    //             }
    //         this.prodInterestData.push(item);
    //         })
            
    //         console.log(data);
    //     }
    //     if(error){
    //         console.error(error);
    //     }
    // }

    // currentPage = 1;
    // rowsPerPage = 4;

    // handlePrevious(){
    //     if(this.currentPage > 1){
    //         this.currentPage--;
    //     }
    // }
    // handleNext(){
    //     const totalPages = Math.ceil(this.table)
    // }

    get options() {
        return [
            { label: 'Reason 1', value: 'Reason 1' },
            { label: 'Reason 2', value: 'Reason 2' },
            { label: 'Reason 3', value: 'Reason 3' },
        ];
       
        }

    /** Added for pagination */
    updateContactHandler(event){
        this.visibleRecords = [...event.detail.records]
        console.log(event.detail.records)
    }

}