import { LightningElement, wire, api, track } from 'lwc';
import getRelatedProductInterest from '@salesforce/apex/ProductInterestController.getRelatedProductInterest'
import getActiveProductInterest from '@salesforce/apex/ProductInterestController.getActiveProductInterest'
import getRelatedProductInterestForStack from '@salesforce/apex/ProductInterestController.getRelatedProductInterestForStack'
import getActiveProductInterestForStack from '@salesforce/apex/ProductInterestController.getActiveProductInterestForStack'
import updateProductInterest from '@salesforce/apex/ProductInterestController.updateProductInterest'
import getOppGMVFields from '@salesforce/apex/ProductInterestController.getOppGMVFields'
//import getUserInfo from '@salesforce/apex/ProductInterestController.getUserInfo'
import productInterestModal from 'c/productInterestModal'
import productIntModalActiveSec from 'c/productIntModalActiveSec'

//import { debounce } from 'lodash';
//import productInterestTest_2 from 'c/productInterestTest_2'

export default class ProductInterestTableCmp extends LightningElement {
    @api recordId
    //  likeState = false
     activeSectionsCorePayment = ['Recommended for Cross-Sell', 'GMV Trend for Active Instruments', 'Complete GMV Trends for Merchant'];
     activeSectionsPaymentStack = ['Recommended for Cross-Sell', 'GMV Trend for Active Instruments', 'Complete GMV Trends for Merchant'];
     //activeSectionGMV = ['GMV Fields of Merchant', 'GMV Fields of Merchant'];

    @track prodInterestData;
    @track activeProdInterestData;

    @track prodInterestDataStack;
    @track activeProdInterestDataStack;

    //isModalOpen = false;

    /**@track isButtonDisabled = false;

    selectedRowKey;
    selectedRowData;

    
    currentSection = 'Recommended';
    currentPageReference;*/

    /**Flag to control data rendering in tabs */
   // @track isCorePaymentTabActive = true;
   // @track isPaymentStackTabActive = true;
    // isOmniChannelTabActive = false;
   // @track activeTabValue;

    


    /** Added for pagination */
    visibleRecords
    visibleRecordsStack
    /** END --- Added for pagination */

   

     
    
    

    handleLikeButtonClick(event) {
        let currIndex;
        this.prodInterestData.forEach((item, index) => {
            if(item.Id == event.target.dataset.id) {
                currIndex = index;
            }
        })
        let currProdInterest = JSON.parse(JSON.stringify(this.prodInterestData[currIndex]));
        currProdInterest.Merchant_Interest_Flag__c = !currProdInterest.Merchant_Interest_Flag__c;
        this.prodInterestData[currIndex] = currProdInterest;
        this.prodInterestData = [...this.prodInterestData];
        let obj = {Id: currProdInterest.Id, Merchant_Interest_Flag__c: currProdInterest.Merchant_Interest_Flag__c};
        updateProductInterest({prodInterest: JSON.stringify(obj)})
        .then(() => {
            console.log('updated');
        })
        .catch(err => {
            throw err;
        })
        
    }

    

    

    /** Like button function for Payment Stack */

    handleLikeButtonClickStack(event) {
        let currIndex;
        this.prodInterestDataStack.forEach((item, index) => {
            if(item.Id == event.target.dataset.id) {
                currIndex = index;
            }
        })
        let currProdInterestStack = JSON.parse(JSON.stringify(this.prodInterestDataStack[currIndex]));
        currProdInterestStack.Merchant_Interest_Flag__c = !currProdInterestStack.Merchant_Interest_Flag__c;
        this.prodInterestDataStack[currIndex] = currProdInterestStack;
        this.prodInterestDataStack = [...this.prodInterestDataStack];
        let obj = {Id: currProdInterestStack.Id, Merchant_Interest_Flag__c: currProdInterestStack.Merchant_Interest_Flag__c};
        updateProductInterest({prodInterest: JSON.stringify(obj)})
        .then(() => {
            console.log('updated');
        })
        .catch(err => {
            throw err;
        })
        
    }
    /**END - Like button function for Payment Stack */

    
    @wire(getRelatedProductInterest, {oppId:'$recordId'})
    relatedProductInterest({data, error}){
        if(data){
            this.prodInterestData = [];
            //this.prodInterestData_3 = [];
            data.forEach(item => {
                if(item.Product_Bundle_Detail__r != undefined) {
                    
                    if(item.Product_Bundle_Detail__r.Sales_Bundle__r != undefined) {
                        let obj = JSON.parse(JSON.stringify(item));
                        obj.product = item.Product_Bundle_Detail__r.Sales_Bundle__r.Name
                        item = obj;
                    }

               

                if(item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r != undefined) {
                    let obj1 = JSON.parse(JSON.stringify(item));
                    obj1.sub_product = item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
                    item = obj1;
                }
                }
                
                

            this.prodInterestData.push(item);
            })
            
            console.log(data);
            
        }
        if(error){
            console.error(error);
        }
    }

    @wire(getActiveProductInterest, {oppId:'$recordId'})
    activeProductInterest({data, error}){
        if(data){
            this.activeProdInterestData = [];
            data.forEach(item => {
                if(item.Product_Bundle_Detail__r != undefined) {
                    if(item.Product_Bundle_Detail__r.Sales_Bundle__r != undefined) {
                        let obj = JSON.parse(JSON.stringify(item));
                        obj.product = item.Product_Bundle_Detail__r.Sales_Bundle__r.Name
                         /**********Added by Rohit to convert the GMV values in a proper format */
                        if(item.GMV_Lifetime__c){
                            obj.GMV_Lifetime__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Lifetime__c);
                        }
                        if(item.GMV_Last_month__c){
                            obj.GMV_Last_month__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_month__c);
                        }
                        if(item.GMV_Last_3_months__c){
                            obj.GMV_Last_3_months__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_3_months__c);
                        }
                        if(item.GMV_Last_6_months__c){
                            obj.GMV_Last_6_months__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_6_months__c); 
                        }
                        if(item.GMV_Last_12_months__c){
                            obj.GMV_Last_12_months__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_12_months__c);
                        }
                        item = obj;
                    }
                if(item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r != undefined) {
                    let obj1 = JSON.parse(JSON.stringify(item));
                    obj1.sub_product = item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
                    item = obj1;
                }
                }  
                this.activeProdInterestData.push(item);
            })
           
            console.log(data);
            
        }
        if(error){
            console.error(error);
        }
    }

    
    /** Following two functions are to fetch the Product Interest Data for Payment Stack Platform */

    @wire(getRelatedProductInterestForStack, {oppId:'$recordId'})
    relatedProductInterestStack({data, error}){
        if(data){
            this.prodInterestDataStack = [];
            //this.prodInterestData_3 = [];
            data.forEach(item => {
                if(item.Product_Bundle_Detail__r != undefined) {
                    if(item.Product_Bundle_Detail__r.Sales_Bundle__r != undefined) {
                        let obj = JSON.parse(JSON.stringify(item));
                        obj.product = item.Product_Bundle_Detail__r.Sales_Bundle__r.Name
                        item = obj;
                    }

                if(item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r != undefined) {
                    let obj1 = JSON.parse(JSON.stringify(item));
                    obj1.sub_product = item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
                    item = obj1;
                }
                }
                

            this.prodInterestDataStack.push(item);
            })
            
            console.log(data);
            //this.prodInterestDataStack = data;
            //this.isPaymentStackTabActive = false;
        }
        if(error){
            //this.isPaymentStackTabActive = false;
            console.error(error);
        }
    }

    @wire(getActiveProductInterestForStack, {oppId:'$recordId'})
    activeProductInterestStack({data, error}){
        if(data){
            this.activeProdInterestDataStack = [];
            data.forEach(item => {
                if(item.Product_Bundle_Detail__r != undefined) {
                    if(item.Product_Bundle_Detail__r.Sales_Bundle__r != undefined) {
                        let obj = JSON.parse(JSON.stringify(item));
                        obj.product = item.Product_Bundle_Detail__r.Sales_Bundle__r.Name
                        /**********Added by Rohit to convert the GMV values in a proper format */
                        if(item.GMV_Lifetime__c){
                            obj.GMV_Lifetime__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Lifetime__c);
                        }
                        if(item.GMV_Last_month__c){
                            obj.GMV_Last_month__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_month__c);
                        }
                        if(item.GMV_Last_3_months__c){
                            obj.GMV_Last_3_months__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_3_months__c);
                        }
                        if(item.GMV_Last_6_months__c){
                            obj.GMV_Last_6_months__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_6_months__c); 
                        }
                        if(item.GMV_Last_12_months__c){
                            obj.GMV_Last_12_months__c = new Intl.NumberFormat('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                             }).format(item.GMV_Last_12_months__c);
                        }
                         /*********END */
                        item = obj;
                    }
    
                
    
                if(item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r != undefined) {
                    let obj1 = JSON.parse(JSON.stringify(item));
                    obj1.sub_product = item.Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
                    item = obj1;
                }
                }

                
                this.activeProdInterestDataStack.push(item);
            })
           
            console.log(data);
            
        }
        if(error){
            console.error(error);
        }
    }

   /** END - Following two functions are to fetch the Product Interest Data for Payment Stack Platform */


//    @wire(getOppGMVFields, {oppId:'$recordId'})
//    OppGMVFieldsExtract({data, error}){
        
//         if(data && data.length > 0){
//             this.oppGMVFieldList = data;
//         }
//         if(error){
//             console.error(error);
//         }
//     }

    connectedCallback(){
        getOppGMVFields({oppId:this.recordId})
        .then(data => {
            this.oppGMVFieldList = data;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.oppGMVFieldList = data;
        })
    }

// @wire(getUserInfo, {}) 
    // userData({ error, data }) {
    //     if(data) {
    //         if(data.Profile.Name !== "System Administrator") {    
    //             this.isButtonDisabled = true;
    //         }
    //     } else if(error) {
    //         // error handling
    //         console.error(error.body.message); 
    //     }
    // }

    //Calling the Modal ("productInterestModal") n below method
    async handleLaunchModal(selectedRowId) {
        console.log('>>>>handleLaunchModal>>>>>'+selectedRowId);
        const result = await productInterestModal.open({
            size: 'My Modal',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
            interestId: selectedRowId
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
    }

    handleRowClick(event){
        let selectedRowId = event.currentTarget.dataset.name;
        this.handleLaunchModal(selectedRowId);
    }

    async handleLaunchModalActiveSec(selectedRowIdActiveSec){
        console.log('>>>>handleLaunchModalActiveSec>>>>>'+selectedRowIdActiveSec);
        const result2 = await productIntModalActiveSec.open({
            size: 'My Modal 2',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
            interestId: selectedRowIdActiveSec
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result2);
    }

    handleRowClickActiveSec(event){
        let selectedRowIdActiveSec = event.currentTarget.dataset.name;
        this.handleLaunchModalActiveSec(selectedRowIdActiveSec);
    }

    /** Added for pagination */
    updateContactHandler(event){
        this.visibleRecords = [...event.detail.records]
        console.log(event.detail.records)
    }

    updateContactHandlerStack(event){
        this.visibleRecordsStack = [...event.detail.records];
        console.log(event.detail.records);
    }

}