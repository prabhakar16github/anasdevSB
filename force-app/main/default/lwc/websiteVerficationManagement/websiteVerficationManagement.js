import { LightningElement,api,track } from 'lwc';
import  websitePages from '@salesforce/apex/RiskManagementStatusController.websitePages';
import getPicklistValues from '@salesforce/apex/RiskManagementStatusController.getPicklistValues';
import saveWebpageRecords from '@salesforce/apex/RiskManagementStatusController.saveWebpageRecords';
import currentWebsitepage from '@salesforce/apex/RiskManagementStatusController.currentWebsitepage';
import { NavigationMixin } from 'lightning/navigation';
import createwebsitepage from '@salesforce/apex/RiskManagementStatusController.savewebsitepagerecord';
import { refreshApex } from '@salesforce/apex';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
export default class WebsiteVerficationManagement extends NavigationMixin(LightningElement) {
    @api recordId
    @track productData = []
    @track policiesData = [] 
    @track contactData = []
    @track modalFlag = true
    @track websitepagenameoptions=[];
    productInfoStatus       = false; 
    policiesStatus          = false;
    contactInfoStatus       = false;
    showProductInfo         = false;
    showContactInfo         = false;
    showPolicies            = false;
    showWebsitesdata        = false;
    showCreateWebPageModal  = false;
    spinner=false;
    webPageStatusPicklist;
    riskRemarksVal = []
    approvalTypesVal = []
    availableVal = []
    webPageData;
    productdatasize;
    policiessize;
    contactinfosize;
    approvaltype;
    avalabilitytype;
    websitepagename;
    websitepagetype;
   @track ProductStatus;
   @track PolicieStatus;
    @track ContactStatus;
    allProductInfoStatus;
    allPoliciesStatus;
    allContactInfoStatus;
    productapproved=0;
    productrejections=0;
    productpendings=0;
    policiesapproveds=0;
    policiesrejections=0;
    policiespendings=0;
    contactapproveds=0;
    contactrejections=0;
    contactpendings=0;
    @track websitepagesdetailrecord;
    riskRemarksForProductValue='';// added by rohit
    riskRemarksForPoliciesValue='';// added by rohit
    riskRemarksForContactValue = '';// added by rohit
    riskValues;
    showError = false;// added by rohit
    saveButton = false;
    allRecordHasRemakrs = false;
    // @wire(websitePages,{oppId:`$recordId`})
    // wiredData(value){
    //     console.log('record id '+this.recordId);
    //     console.log('value '+JSON.stringify(value.error));
    //     // if (data) {
    //     //     console.log('wired data ',data);

    //     // }
    //     // else if(error){
    //     //     console.log('error ',error);
    //     // }
    // };

    getData(){
    websitePages({ oppId: this.recordId }).then(res => {
        this.websitepagesdetailrecord=res;
        if(res[0].Website_Pages__r){ // added by rohit only if condition to check if there is a website page available on opp or not
            if (res[0].Website_Pages__r.length > 0) {
                console.log('response '+res[0].Website_Pages__r);
                res[0].Website_Pages__r.forEach((element, index) => {
                this.webPageData = res[0].Website_Pages__r;
                if (element.Group__c === 'Product') {
                    this.productData.push(element);
                    console.log('this.productData:::::'+JSON.stringify(this.productData));
                } else if (element.Group__c === 'Policies') {
                    this.policiesData.push(element);
                } else if (element.Group__c === 'Contact') {
                    this.contactData.push(element);
                }
                });
                this.showWebsitesdata = true;
            }
        }
       
        getPicklistValues().then(result => {
            let webPageStatusVal = JSON.parse(result.Availability__c);
            let approvalTypes = JSON.parse(result.Approval_Type__c);
            let riskRemarks = JSON.parse(result.Pick_Risk_Remark__c);

            this.availableVal = JSON.parse(result.Availability__c);
            this.approvalTypesVal = JSON.parse(result.Approval_Type__c);
            this.riskRemarksVal = JSON.parse(result.Pick_Risk_Remark__c);

            this.productData = JSON.parse(JSON.stringify(this.productData));
            this.productdatasize=this.productData.length;
        /*  this.policiesData = JSON.parse(JSON.stringify(this.productData));
            this.contactData = JSON.parse(JSON.stringify(this.productData));

            const dataSets = [this.productData, this.policiesData, this.contactData];
            dataSets.forEach((element,index) => {
                element.forEach(item => {
                        item.approvalDisabled = item.Availability__c === 'Not Applicable';
                        item.inputDisabled = item.Availability__c === 'Not Applicable';
                        item.remarksDisabled = item.Availability__c === 'Not Applicable';

                        if (item.Availability__c === 'Not Applicable') {
                        const emptyOption = { value: '', selected: true };
                        item.riskRemarks = [emptyOption];
                        item.approvalTypes = [emptyOption];
                        item.URL__c = null;
                        const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                        curravailableVal.forEach(item => {
                            item.selected = item.value === item.Availability__c;
                        });
                        item.webstatus = curravailableVal;

                        } else if (item.Availability__c === 'Found') {
                        const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                        curravailableVal.forEach(item => {
                            item.selected = item.value === item.Availability__c;
                        });
                        item.webstatus = curravailableVal;

                        const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                        currApprovalTypes.forEach(item => {
                            item.selected = item.value === 'Approved';
                        });
                        item.approvalTypes = currApprovalTypes;

                        const currRiskRemarks = JSON.parse(JSON.stringify(this.riskRemarksVal));
                        currRiskRemarks.forEach(item => {
                            item.selected = false;
                        });
                        item.riskRemarks = currRiskRemarks;

                        item.inputDisabled = true;
                        item.URL__c = '';
                        item.remarksDisabled = true;
                        item.approvalDisabled = true;
                        } else {
                        const curravailableVal = JSON.parse(JSON.stringify(webPageStatusVal));
                        curravailableVal.forEach(item => {
                            item.selected = item.value === item.Availability__c;
                        });
                        item.webstatus = curravailableVal;

                        const currApprovalTypes = JSON.parse(JSON.stringify(approvalTypes));
                        currApprovalTypes.forEach(item => {
                            item.selected = item.value === item.Approval_Type__c;
                        });
                        item.approvalTypes = currApprovalTypes;

                        const currRiskRemarks = JSON.parse(JSON.stringify(riskRemarks));
                        currRiskRemarks.forEach(item => {
                            item.selected =  item.value === item.Pick_Risk_Remark__c;
                        });
                        item.riskRemarks = currRiskRemarks;
                        }
                });
                dataSets[index] = JSON.parse(JSON.stringify(element));
                console.log('element ',element);
            });*/


            this.productData.forEach((element, index) => {
            element.approvalDisabled = element.Availability__c === 'Not Applicable';
            element.inputDisabled = element.Availability__c === 'Not Applicable';
            element.remarksDisabled = element.Availability__c === 'Not Applicable';
            element.inputDisabled=element.Availability__c === 'Not Found';
            element.approvalDisabled = element.Availability__c === 'Not Found';
            if(element.Approval_Type__c === 'Approved'){
                this.productapproved=this.productapproved+1;
            }else if(element.Approval_Type__c === 'Rejection'){
                this.productrejections=this.productrejections+1;
                console.log('this.productrejections::::::'+this.productrejections);
            }else{
                this.productpendings=this.productpendings+1;
            }
            if (element.Availability__c === 'Not Applicable') {
                const emptyOption = { value: '', selected: true };
                element.riskRemarks = [emptyOption];
                element.approvalTypes = [emptyOption];
                element.URL__c = null;
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;
                // Set the value in 'Approval Type' as 'Approved'
                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                console.log('currApprovalTypes',currApprovalTypes);
                currApprovalTypes.forEach(item => {
                    item.selected = item.value ===element.Approval_Type__c;
                });
                element.approvalTypes = currApprovalTypes;
                element.inputDisabled=true;
                element.approvalDisabled=true;

            } else if (element.Availability__c === 'Found') {
               // element.remarksDisabled = true;
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;

                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                currApprovalTypes.forEach(item => {
                item.selected = item.value === element.Approval_Type__c;
                if(element.Approval_Type__c === 'Rejected' || element.Approval_Type__c === 'Pending' ){
                    element.remarksDisabled = false;
                }
                });
                element.approvalTypes = currApprovalTypes;
                console.log('element',element);
                const currRiskRemarks = JSON.parse(JSON.stringify(this.riskRemarksVal));
                currRiskRemarks.forEach(item => {
                item.selected = item.value === element.Pick_Risk_Remark__c;//false;
                //this.riskRemarksForProductValue =  element.Pick_Risk_Remark__c;
               // console.log('element.Pick_Risk_Remark__c::::::'+element.Pick_Risk_Remark__c);
                });
                element.riskRemarks = currRiskRemarks;

                element.inputDisabled = false;
                // element.URL__c = '';
                // element.approvalDisabled = true;
            } else {
                const curravailableVal = JSON.parse(JSON.stringify(webPageStatusVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;

                const currApprovalTypes = JSON.parse(JSON.stringify(approvalTypes));
                currApprovalTypes.forEach(item => {
                item.selected = item.value === element.Approval_Type__c;
                //item.selected = item.value === 'Rejection';// in strating it was enabled but I commented this one to default value as select by rohit
                });
                element.approvalTypes = currApprovalTypes;
                element.approvalDisabled = true;// added by rohit
                console.log(' element.approvalTypes::::::238::::', element.approvalTypes);
                const currRiskRemarks = JSON.parse(JSON.stringify(riskRemarks));
                currRiskRemarks.forEach(item => {
                item.selected =  item.value === element.Pick_Risk_Remark__c;
                console.log('item.selected',item.selected);
                });
                element.riskRemarks = currRiskRemarks;
                element.remarksDisabled = false; //added by rohit
                element.inputDisabled=true;
                element.requiredRemarks=true;
                console.log('element.requiredRemarks:::::::'+ element.requiredRemarks);
            }
            });
            console.log('232::::::',this.productdatasize);
            console.log('233:::::',this.productapproved);
            console.log('234::::::',this.productrejections);
            if(this.productdatasize === this.productapproved){
                this.allProductInfoStatus='Success';
                this.ProductStatus='Success';
            }
            else if(this.productdatasize ===this.productrejections || ( this.productrejections >='1' )){//added by rohit || this.productrejections >='1'
                this.allProductInfoStatus='Rejected';
                this.ProductStatus='Rejected'; 
                console.log('this.ProductStatus:::275::'+this.ProductStatus);
            }
            else {
                this.allProductInfoStatus='Pendings';
                this.ProductStatus='Partial';
            }
            this.policiesData = JSON.parse(JSON.stringify(this.policiesData));
            console.log('sizepoliciesdata',this.policiesData.length);
            this.policiessize=this.policiesData.length;
            this.policiesData.forEach(element => {
            element.approvalDisabled = element.Availability__c === 'Not Applicable';
            element.inputDisabled = element.Availability__c === 'Not Applicable';
            element.remarksDisabled = element.Availability__c === 'Not Applicable';
            element.inputDisabled=element.Availability__c === 'Not Found';
            element.approvalDisabled = element.Availability__c === 'Not Found';
            if(element.Approval_Type__c === 'Approved'){
                this.policiesapproveds=this.policiesapproveds+1;
            }else if(element.Approval_Type__c === 'Rejection'){
                this.policiesrejections=this.policiesrejections+1;
            }else{
                this.policiespendings=this.policiespendings+1;
            }
            // if (element.Availability__c === 'Not Applicable') {
            //     const emptyOption = { value: '', selected: true };
            //     element.riskRemarks = [emptyOption];
            //     element.approvalTypes = [emptyOption];
            //     element.URL__c = null;
            //     element.inputDisabled=true;
            // }
            // else if (element.Availability__c === 'Found') {

            //      element.inputDisabled = false;
            //     // element.URL__c = '';
            //     // element.approvalDisabled = true;
            // } 
            // else{
            //     element.inputDisabled =true;
            // }
            // let currWebPageStatusVal = JSON.parse(JSON.stringify(webPageStatusVal));
            // currWebPageStatusVal.forEach(item => {
            //     if (item.value === element.Availability__c) {
            //     item.selected = true;
            //     }
            // });
            // element.webstatus = currWebPageStatusVal;

            // let currApprovalTypes = JSON.parse(JSON.stringify(approvalTypes));
            // currApprovalTypes.forEach(item => {
            //     if (item.value === element.Approval_Type__c) {
            //     item.selected = true;
            //     }
            // });
            // element.approvalTypes = currApprovalTypes;

            // let currRiskRemarks = JSON.parse(JSON.stringify(riskRemarks));
            // currRiskRemarks.forEach(item => {
            //     if (item.value === element.Pick_Risk_Remark__c) {
            //     item.selected = true;
            //     }
            // });
            // element.riskRemarks = currRiskRemarks;
            if (element.Availability__c === 'Not Applicable') {
                const emptyOption = { value: '', selected: true };
                element.riskRemarks = [emptyOption];
                element.approvalTypes = [emptyOption];
                element.URL__c = null;
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;
                // Set the value in 'Approval Type' as 'Approved'
                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                console.log('currApprovalTypes',currApprovalTypes);
                currApprovalTypes.forEach(item => {
                    item.selected = item.value ===element.Approval_Type__c;
                });
                element.approvalTypes = currApprovalTypes;
                element.inputDisabled=true;
                element.approvalDisabled=true;

            } else if (element.Availability__c === 'Found') {
                //element.remarksDisabled = true;
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;

                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                currApprovalTypes.forEach(item => {
                item.selected = item.value === element.Approval_Type__c;
                if(element.Approval_Type__c === 'Rejected' || element.Approval_Type__c === 'Pending' ){
                    element.remarksDisabled = false;
                }
                });
                element.approvalTypes = currApprovalTypes;
                console.log('element',element);
                const currRiskRemarks = JSON.parse(JSON.stringify(this.riskRemarksVal));
                currRiskRemarks.forEach(item => {
                        item.selected =  item.value === element.Pick_Risk_Remark__c;//false;
                       // this.riskRemarksForPoliciesValue  =  element.Pick_Risk_Remark__c;

                
                });
                element.riskRemarks = currRiskRemarks;

                 element.inputDisabled = false;
                // element.URL__c = '';
                // element.approvalDisabled = true;
            } else {
                const curravailableVal = JSON.parse(JSON.stringify(webPageStatusVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;

                const currApprovalTypes = JSON.parse(JSON.stringify(approvalTypes));
                currApprovalTypes.forEach(item => {
                item.selected = item.value === element.Approval_Type__c;
                //item.selected = item.value === 'Rejection';// in strating it was enabled but I commented this one to default value as select by rohit
                });
                element.approvalTypes = currApprovalTypes;
                element.approvalDisabled = true;// added by rohit
                console.log('element.approvalTypes:::377::',element.approvalTypes);
                const currRiskRemarks = JSON.parse(JSON.stringify(riskRemarks));
                currRiskRemarks.forEach(item => {
                item.selected =  item.value === element.Pick_Risk_Remark__c;
                console.log('item.selected',item.selected);
                });
                element.riskRemarks = currRiskRemarks;
                element.remarksDisabled = true; //added by rohit
                element.inputDisabled=true;
            }
            });

            if(this.policiessize === this.policiesapproveds){
                this.allPoliciesStatus='Success';
                this.PolicieStatus='Success';
            }
            else if(this.policiessize === this.policiesrejections || ( this.policiesrejections >='1' )){//added by rohit || this.productrejections >='1'
                this.allPoliciesStatus='Rejected';
                this.PolicieStatus='Rejected';
            }
            else {
                this.allPoliciesStatus='Pendings';
                this.PolicieStatus='Partial';
            }

            this.contactData = JSON.parse(JSON.stringify(this.contactData));
            this.contactinfosize=this.contactData.length;
            this.contactData.forEach(element => {
            element.approvalDisabled = element.Availability__c === 'Not Applicable';
            element.inputDisabled = element.Availability__c === 'Not Applicable';
            element.remarksDisabled = element.Availability__c === 'Not Applicable';
            element.inputDisabled = element.Availability__c === 'Not Found';
            element.approvalDisabled = element.Availability__c === 'Not Found';
            if(element.Approval_Type__c === 'Approved'){
                this.contactapproveds=this.contactapproveds+1;
            }else if(element.Approval_Type__c === 'Rejection'){
                this.contactrejections=this.contactrejections+1;
            }else{
                this.contactpendings=this.contactpendings+1;
            }
            // if (element.Availability__c === 'Not Applicable') {
            //     const emptyOption = { value: '', selected: true };
            //     element.riskRemarks = [emptyOption];
            //     element.approvalTypes = [emptyOption];
            //     element.URL__c = null;
            // }
            
            // let currWebPageStatusVal = JSON.parse(JSON.stringify(webPageStatusVal));
            // currWebPageStatusVal.forEach(item => {
            //     if (item.value === element.Availability__c) {
            //     item.selected = true;
            //     }
            // });
            // element.webstatus = currWebPageStatusVal;

            // let currApprovalTypes = JSON.parse(JSON.stringify(approvalTypes));
            // currApprovalTypes.forEach(item => {
            //     if (item.value === element.Approval_Type__c) {
            //     item.selected = true;
            //     }
            // });
            // element.approvalTypes = currApprovalTypes;

            // let currRiskRemarks = JSON.parse(JSON.stringify(riskRemarks));
            // currRiskRemarks.forEach(item => {
            //     if (item.value === element.Pick_Risk_Remark__c) {
            //     item.selected = true;
            //     }
            // });
            // element.riskRemarks = currRiskRemarks;
            if (element.Availability__c === 'Not Applicable') {
                const emptyOption = { value: '', selected: true };
                element.riskRemarks = [emptyOption];
                element.approvalTypes = [emptyOption];
                element.URL__c = null;
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;
                // Set the value in 'Approval Type' as 'Approved'
                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                console.log('currApprovalTypes',currApprovalTypes);
                currApprovalTypes.forEach(item => {
                    item.selected = item.value ===element.Approval_Type__c;
                });
                element.approvalTypes = currApprovalTypes;
                element.inputDisabled=true;
                element.approvalDisabled=true;

            } else if (element.Availability__c === 'Found') {
                //element.remarksDisabled = true; //commented by rohit
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;

                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                currApprovalTypes.forEach(item => {
                item.selected = item.value === element.Approval_Type__c;
                if(element.Approval_Type__c === 'Rejected' || element.Approval_Type__c === 'Pending' ){
                    element.remarksDisabled = false;
                }
                });
                element.approvalTypes = currApprovalTypes;
                console.log('element',element);
                const currRiskRemarks = JSON.parse(JSON.stringify(this.riskRemarksVal));
                currRiskRemarks.forEach(item => {
                        item.selected =  item.value === element.Pick_Risk_Remark__c;//false;
                       // this.riskRemarksForContactValue  =  element.Pick_Risk_Remark__c;

                });
                element.riskRemarks = currRiskRemarks;

                 element.inputDisabled = false;
                // element.URL__c = '';
                // element.approvalDisabled = true;
            } else {
                const curravailableVal = JSON.parse(JSON.stringify(webPageStatusVal));
                curravailableVal.forEach(item => {
                item.selected = item.value === element.Availability__c;
                });
                element.webstatus = curravailableVal;

                const currApprovalTypes = JSON.parse(JSON.stringify(approvalTypes));
                currApprovalTypes.forEach(item => {
                item.selected = item.value === element.Approval_Type__c;
               // item.selected = item.value === 'Rejection';// in strating it was enabled but I commented this one to default value as select by rohit
                });
                element.approvalTypes = currApprovalTypes;
                element.approvalDisabled = true;// added by rohit
                console.log('element',element);
                const currRiskRemarks = JSON.parse(JSON.stringify(riskRemarks));
                currRiskRemarks.forEach(item => {
                item.selected =  item.value === element.Pick_Risk_Remark__c;
                console.log('item.selected',item.selected);
                });
                element.riskRemarks = currRiskRemarks;
                element.remarksDisabled = true; //added by rohit
                element.inputDisabled=true;
            }
            });
            if(this.contactinfosize === this.contactapproveds){
                this.allContactInfoStatus='Success';
                this.ContactStatus='Success';
            }
            else if(this.contactinfosize === this.contactrejections || (this.contactrejections >='1' )){//added by rohit || this.productrejections >='1'
                this.allContactInfoStatus='Rejected';
                this.ContactStatus='Rejected';
            }
            else {
                this.allContactInfoStatus='Pendings';
                this.ContactStatus='Partial';
            }
        });
        });
    }


    handleAccordion(event) {
        let type = event.currentTarget.dataset.type;
        // if(type === 'icon') return
        // console.log('handle accordian ',type);
        if(type === 'ProductInfo') {
            this.showProductInfo = !this.showProductInfo
            this.showPolicies = false
            this.showContactInfo = false
        } else if(type === 'Policies') {
            this.showProductInfo = false
            this.showPolicies = !this.showPolicies
            this.showContactInfo = false
        } else if(type === 'ContactInfo') {
            this.showProductInfo = false
            this.showPolicies = false
            this.showContactInfo = !this.showContactInfo
        }

    }


    handleSelect(event) {
    
        const eventName = event.currentTarget.dataset.name;
        const index = event.currentTarget.dataset.index;
        const groupName = event.currentTarget.dataset.group;
        const id = event.currentTarget.dataset.id;
        currentWebsitepage({webPageId :id}) // this has been added by rohit
        .then(result => {
            this.riskValues = result;
            })
            .catch((error) => {
            this.error = error;
            });

        //this.riskV =  JSON.stringify(this.riskValues[0].Pick_Risk_Remark__c);
        let arr ;
        if (groupName === 'Product'){
            arr = this.productData;
        } else if (groupName === 'Policies') {
            arr = this.policiesData;
        } else if (groupName === 'Contact') {
            arr = this.contactData;
        }

        if (eventName === 'Availability__c') {
            const value = event.currentTarget.value;

            arr[index].approvalDisabled = value === 'Not Applicable';
            arr[index].inputDisabled = value === 'Not Applicable';
            arr[index].remarksDisabled = value === 'Not Applicable';
            arr[index].inputDisabled = value ==='Not Found';
            if (value === 'Not Applicable') {
                console.log('arr[index].inputDisabled',arr[index].inputDisabled);
                const emptyOption = { value: '', selected: true }; // Empty option with selected flag
                arr[index].riskRemarks = [emptyOption];
                arr[index].approvalTypes = [emptyOption];
                arr[index].URL__c = null;
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                    item.selected = item.value === value;
                });
                arr[index].webstatus = curravailableVal;
                // Set the value in 'Approval Type' as 'Approved'
                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                console.log('currApprovalTypes',currApprovalTypes);
                currApprovalTypes.forEach(item => {
                    item.selected = item.value === 'Approved';
                });
                arr[index].approvalTypes = currApprovalTypes;
                arr[index].inputDisabled=true;
                arr[index].approvalDisabled=true;
            }else if (value === 'Found') {
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                    item.selected = item.value === value;
                });
                arr[index].webstatus = curravailableVal;

                // Set the value in 'Approval Type' as 'Approved'
                const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                console.log('currApprovalTypes',currApprovalTypes);
                currApprovalTypes.forEach(item => {
                    item.selected = item.value === 'Pending';// Previously it was 'Approved' by i chnaged it to pending
                });
                arr[index].approvalTypes = currApprovalTypes;
                console.log('approvaltypes',arr[index].approvalTypes);
                // Set the value in 'Risk Remarks' as null
                const currRiskRemarks = JSON.parse(JSON.stringify(this.riskRemarksVal));
                 currRiskRemarks.forEach(item => {
                        if( this.riskValues   !=null){
                            item.selected = item.value==    this.riskValues;
                        }
                        else{
                            item.selected =false;
                        }
                    });
                arr[index].riskRemarks = currRiskRemarks;
                console.log('currRiskRemarks::::::'+arr[index].riskRemarks);
                // Disable the input field and set URL value as null
                arr[index].inputDisabled = false;
                arr[index].URL__c = '';

                // Disable the 'Risk Remarks' and 'Approval Type' fields
                arr[index].remarksDisabled = false;// added by rohit it was true
                // arr[index].approvalDisabled = true;
            } else {
                const curravailableVal = JSON.parse(JSON.stringify(this.availableVal));
                curravailableVal.forEach(item => {
                    item.selected = item.value === value;
                });
                arr[index].webstatus = curravailableVal;

                // Set the values in 'Approval Type' from 'approvalTypes' 
                /***********Below if else condition added by rohit to check if Availability 'Not Found' then update 'Approval type'
                 As 'Rejection but if it is select then update to select'* 
                */
                if (value === 'Not Found'){ 
                    const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                    currApprovalTypes.forEach(item => {
                        item.selected = item.value === 'Rejection';
                    });
                    arr[index].approvalTypes = currApprovalTypes;
                    arr[index].approvalDisabled=true;
                    arr[index].requiredRemarks=true;
                    //this.requiredRemarks = true;
                    console.log('this.requiredRemarks::::::'+ arr[index].requiredRemarks);
                }
                else{// added by rohit
                    const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
                    currApprovalTypes.forEach(item => {
                       // item.selected = item.value === 'Rejection';
                       item.selected = false;
                    });
                    arr[index].approvalTypes = currApprovalTypes;
                    arr[index].approvalDisabled=true;
                    arr[index].remarksDisabled = true;//added by rohit
                }
                // Set the values in 'Risk Remarks' from 'riskRemarks'
                const currRiskRemarks = JSON.parse(JSON.stringify(this.riskRemarksVal));
                currRiskRemarks.forEach(item => {
                    item.selected = false;
                });
                arr[index].inputDisabled = true;
                arr[index].riskRemarks = currRiskRemarks;
            }
        } else if (eventName === 'Approval_Type__c') {

            const value = event.currentTarget.value;
            if(value === 'Approved'){

                const currRiskRemarks = JSON.parse(JSON.stringify(this.riskRemarksVal));
                currRiskRemarks.forEach(item => {
                    item.selected = false;
                });
                arr[index].riskRemarks = currRiskRemarks;

                arr[index].inputDisabled = false;
                // arr[index].URL__c = '';
                // Disable the 'Risk Remarks' and 'Approval Type' fields
                arr[index].remarksDisabled = true;
            }else if(value === 'Rejection'){

                arr[index].inputDisabled = true; // added true by rohit
                arr[index].URL__c = '';
                // Disable the 'Risk Remarks' and 'Approval Type' fields
                arr[index].remarksDisabled = false;
                //this.showError=  true;
            }else if(value === 'Pending'){

                arr[index].inputDisabled = false;
                //arr[index].URL__c = '';// commented by rohit 
                // Disable the 'Risk Remarks' and 'Approval Type' fields
                arr[index].remarksDisabled = false;
            }

            const currApprovalTypes = JSON.parse(JSON.stringify(this.approvalTypesVal));
            currApprovalTypes.forEach(item => {
                item.selected = item.value === value;
            });
            arr[index].approvalTypes = currApprovalTypes;

        } else if (eventName === 'Pick_Risk_Remark__c') {
            const value = event.currentTarget.value;
            this.riskRemarksValue = value;// added by rohit
            console.log('value:::::'+value);
            const currRiskremarksVal = JSON.parse(JSON.stringify(this.riskRemarksVal));
            currRiskremarksVal.forEach(item => {
                item.selected = item.value === value;
            });
            arr[index].riskRemarks = currRiskremarksVal;
        }
    }

    renderedCallback(){
        if(this.modalFlag){
            this.modalFlag = false
            console.log('inside flaged If');
            this.getData();
        }
        console.log('renderd');
    }

    disconnectedCallback(){
        console.log('modal disconnected ');
       
        this.modalFlag = false;

    }

    @api
    handleSave(event) {
        const hasError = false;
        this.allRecordHasRemakrs = false;
        console.log('705');
        const dataSets = [this.productData, this.policiesData, this.contactData];
        const records = [];
        console.log(dataSets);
        try {
            dataSets.forEach(dataSet => {
                dataSet.forEach(element => {
                    const obj = {
                        URL__c: element.inputDisabled ? '' : element.URL__c,
                        Availability__c: '',
                        Approval_Type__c: '',
                        Pick_Risk_Remark__c: '',
                        Status__c:'',
                        Id: element.Id
                    };

                    element.webstatus.forEach(item => {
                        if (item.selected) {
                            obj.Availability__c = item.value;
                        }
                    });

                    element.approvalTypes.forEach(item => {
                        if (item.selected) {
                            obj.Approval_Type__c = item.value;
                        }
                    });
 
                    element.riskRemarks.forEach(item => {
                        if (item.selected) {
                            obj.Pick_Risk_Remark__c = item.value;
                            obj.Risk_Comment__c = item.value;// added by rohit
                        }
                    });
                    if(obj.Approval_Type__c==='Rejection'){
                        obj.Status__c='Rejected';
                        console.log('obj.Pick_Risk_Remark__c:::802::'+obj.Pick_Risk_Remark__c);
                        if(!obj.Pick_Risk_Remark__c){// added by rohit this if condition
                            this.allRecordHasRemakrs = true;
                            console.log('obj.Pick_Risk_Remark__c:::804::'+obj.Pick_Risk_Remark__c +'  showError:::::'+this.showError);
                        }
                    }
                    else if(obj.Approval_Type__c==='Approved'){
                        obj.Status__c='Approved';
                    }
                    else if(obj.Approval_Type__c=== 'Pending'){
                        console.log('this.showError:828:::::'+this.showError);
                        obj.Status__c='Pending';
                        /*if(obj.Pick_Risk_Remark__c){// added by rohit this if condition
                            this.allRecordHasRemakrs = false;
                            console.log('obj.Pick_Risk_Remark__c:::804::'+obj.Pick_Risk_Remark__c +'  showError:::::'+this.showError);
                        }*/
                        //this.showError = false;
                    }
                    records.push(obj);
                });
            });
        } catch (error) {
            console.log(error.message);
        }
        console.log('recordtest',records);
        console.log('this.showError:842::::'+this.showError +' this.allRecordHasRemakrs:::::'+this.allRecordHasRemakrs);
        if(this.allRecordHasRemakrs){
            this.showError = true;
        }
        else{
            this.showError =false;
        }
        if(this.showError){// this if  added by rohit
            console.log('inside if:::::841');
            this.spinner = false;
            const errorMsg = 'Please select the risk remarks in case of rejection';
            const errorEvent = new ShowToastEvent({
            title:'Error',
            message:errorMsg,
            variant : 'error'
         });
         this.dispatchEvent(errorEvent);
        }
        else if(!this.showError){
            console.log('this.showError:854::::'+this.showError);
            saveWebpageRecords({ records: JSON.stringify(records) })
            .then(result => {
                console.log('test:::::',JSON.stringify(result) );
                let eve=new CustomEvent('websiteverificationcall');
                this.dispatchEvent(eve);
            });
        }
          
    }


    handleUrl(event){
        //console.log(event.target.value);
        let targetName = event.target.dataset.name;
        let id = event.target.dataset.id;
        let arr ;
        try {

        } catch (error) {
            console.log(error.message);
        }
        if(targetName == 'Products'){
            arr =this.productData;
        }else if(targetName == 'Policies'){
            arr =this.policiesData;
        }else if(targetName == 'Contacts'){
            arr =this.contactData;
        }
        let currproductData = arr;
        currproductData.forEach(element => {
        if(element.Id == id){
            element.URL__c = event.target.value;
        }
        });
    }

     createNewWebPage(event){
    //     console.log('threedoticon ');
         this.showCreateWebPageModal = true;
         console.log('showCreateWebPageModal ::::::::'+this.showCreateWebPageModal );

    }

    handleMenuButton(event){
        // console.log('button of group  ',event.currentTarget.dataset.name);
        // console.log('button of group  ',event.currentTarget.classList);
        let type = event.currentTarget.dataset.type;
        if(type === 'ProductInfo') {
            this.showProductInfo = !this.showProductInfo
            this.showPolicies = false
            this.showContactInfo = false
        } else if(type === 'Policies') {
            this.showProductInfo = false
            this.showPolicies = !this.showPolicies
            this.showContactInfo = false
        } else if(type === 'ContactInfo') {
            this.showProductInfo = false
            this.showPolicies = false
            this.showContactInfo = !this.showContactInfo
        }
        event.currentTarget.classList.toggle('slds-is-open');

    }
    createNewWebpage(event){
        console.log('test');
        console.log(event.target.dataset.type);
        let defaultWebpageValue='';
        console.log('defaultwebpage',defaultWebpageValue);
        let type=event.target.dataset.type;
        console.log('type',type);
        this.websitepagetype=type;
        this.showCreateWebPageModal=true;
        if(type ==='ProductInfo'){
             this.websitepagetype='Product';
             this.websitepagenameoptions=[
                { label: 'Home Page', value: 'Home Page' },
                { label: 'About Us Page', value: 'About Us Page' },
                { label: 'Product and Service Page', value: 'Product and Service Page' }
            ];
        }
        else if(type === 'Policies'){
             this.websitepagetype='Policies';
             this.websitepagenameoptions=[
                { label: 'Terms and Condition', value: 'Terms and Condition' },
                { label: 'Privacy Policy', value: 'Privacy Policy' },
                { label: 'Refund Policy', value: 'Refund Policy'},
                {label :'Cancel and Return Policy',value :'Cancel and Return Policy'},
                {label :'Ship and Delivery Policy',value :'Ship and Delivery Policy'}
            ];
        }
        else if(type ==='ContactInfo'){
            this.websitepagetype='Contact';
            this.websitepagenameoptions=[
                { label: 'Login and Register Tab', value: 'Login and Register Tab' },
                { label: 'Contact Us Page', value: 'Contact Us Page' }
            ];
        }
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__objectPage',
        //     attributes: {
        //         objectApiName :'Website_Page__c',
        //         actionName: 'new'
        //     },
        //     state: {
        //         defaultFieldValues: defaultWebpageValue
        //     }
        // });

    }
    handlenamechange(event){
        this.websitepagename=event.detail.value;
        console.log('name',this.websitepagename);
        if(this.websitepagename==='Home Page' || this.websitepagename==='Product and Service Page' || this.websitepagename==='Terms and Condition' || this.websitepagename==='Privacy Policy' || this.websitepagename==='Refund Policy' || this.websitepagename==='Cancel and Return Policy' || this.websitepagename==='Ship and Delivery Policy' || this.websitepagename==='Contact Us Page'){
            this.approvaltype='Approved';
            this.avalabilitytype='Found';
        }
        if(this.websitepagename==='About Us Page' ||this.websitepagename==='Login and Register Tab' ){
            this.approvaltype='Approved';
            this.avalabilitytype='Not Applicable';
        }
        
    } 
    handleSaveWebsiteRecord(event){
        console.log(event);
        console.log('this.spinner::965:::'+this.showError);
        
        console.log('this.websitepagetyp:::::'+JSON.stringify(this.websitepagetyp));
        console.log('this.approvaltype::::'+this.approvaltype);
        createwebsitepage({oppId:this.recordId,webgroup:this.websitepagetype,webname :this.websitepagename,approvetype:this.approvaltype,avaltype:this.avalabilitytype}).then(res => {
            console.log('res',res);
            if(res=='success'){
                this.websitepagename='';
                this.spinner=false;
                this.showCreateWebPageModal=false;
                this.productData=[];
                this.policiesData=[];
                this.contactData=[];
                this.productapproved=0;
                this.productrejections=0;
                this.productpendings=0;
                this.policiesapproveds=0;
                this.policiesrejections=0;
                this.policiespendings=0;
                this.contactapproveds=0;
                this.contactrejections=0;
                this.contactpendings=0;
                this.getData();
                console.log('893');
                
                
            }
        })
    }
    handleModalClose(){
     this.showCreateWebPageModal=false;   
    }
}