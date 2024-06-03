import { LightningElement, api, wire, track } from 'lwc';

import ATTACHMENT_ICON from '@salesforce/resourceUrl/AttachmentIcon';
import RECAPTCHA_URL from '@salesforce/resourceUrl/reCAPTCHA';

import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import BOT_OBJECT from '@salesforce/schema/Bot__c';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import EXPECTED_MONTHLY_SALES_FIELD from '@salesforce/schema/Bot__c.Expected_Monthly_Sales__c';
import ISSUE_FIELD from '@salesforce/schema/Bot__c.Issue__c';
import SUB_ISSUE_FIELD from '@salesforce/schema/Bot__c.Sub_Issue__c';

import getRecordTypeId from '@salesforce/apex/CreateCaseFormController.getRecordTypeId';
import getMerchantDetails from '@salesforce/apex/CreateCaseFormController.getMerchantDetails';
import getAccessToken from '@salesforce/apex/CreateCaseFormController.getAccessToken';
import createCase from '@salesforce/apex/CreateCaseFormController.createCase'; 

export default class CreateCaseForm extends LightningElement {

    attachmentIcon = ATTACHMENT_ICON;
    reCaptchaURL = RECAPTCHA_URL;
    @api messageContentType;
    @api isformSubmitted;

    @track issueOptions;
    @track subIssueOptions;
    @track monthlySalesOptions;

    merchantId;
    product;
    routableId;
    picklistRecordTypeId;

    @track inputObj = {};

    issueCategory;
    issueSubCategory;
    description;
    merchantName = '';
    email = '';
    mobileNo = '';
    expectedMonthlySales;
    website;
    mid;
    fileNames = '';
    @track fileNameList = [];
    @track filesUploaded = [];
    recaptchaKey;

    errorIssue = '';
    errorSubIssue = '';
    errorDescription = '';
    errorName = '';
    errorEmail = '';
    errorMobile = '';
    errorMonthlySales = '';
    errorWebsite = '';
    errorMId = '';    
    errorAttachment = '';
    errorSubmit = '';
    showSelectedMaxFiles = false;

    result = '';
    ticketId = '';
    isSubmitted = false;
    showSpinner = false;
    isCaseCreated = false;

    get isLoggedInUser() {
        return (this.merchantId != null) ? true : false;
    }

    get showFileNames() {
        return this.filesUploaded.length > 0 ? true : false;
    }

    get showMaxFilesError() {
        return this.filesUploaded.length >= 5 ? true : false;
    }

    get showExpectedMonthlySalesAndWebsite() {
        return (this.issueCategory === 'Pricing Inquiry' || this.issueCategory === 'New Product Inquiry');
    }

    get showMerchantId() {
        return (this.issueCategory === 'Technical Integration Help');
    }

    get disableSubmit() {
        this.errorSubmit = 'please complete all input fields to submit';

        if(!this.issueCategory || !this.issueSubCategory || !this.description || !this.merchantName || !this.email || !this.mobileNo) {
            return true;
        }

        if(!this.isLoggedInUser) {            
            if(this.issueCategory === 'Technical Integration Help' && !this.mid) {
                return true;
            }
            if((this.issueCategory === 'Pricing Inquiry' || this.issueCategory === 'New Product Inquiry') && (!this.expectedMonthlySales || !this.website)) {
                return true;
            }
            if(!this.recaptchaKey) {
                this.errorSubmit = 'please verify reCAPTCHA to submit';
                return true;
            }
        }

        return false;
    }

    @wire(getObjectInfo, {objectApiName: BOT_OBJECT})
    botObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$picklistRecordTypeId', fieldApiName: EXPECTED_MONTHLY_SALES_FIELD })
    setPicklistOptions({data}) {
        if (data) {
            this.monthlySalesOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$picklistRecordTypeId', fieldApiName: ISSUE_FIELD })
    issueFieldInfo({data, error}) {
        if (data) {
            this.issueOptions = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$picklistRecordTypeId', fieldApiName: SUB_ISSUE_FIELD })
    subIssueFieldInfo({data}) {
        if (data) {
            this.subIssueFieldData = data;
        }
    }

    connectedCallback() {
        this.init();
        window.addEventListener("message", this.listenForMessage);
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.listenForMessage);
    }

    init(){
        var str = this.messageContentType.value.split(':')[1];
        let inputVariables = str.split(';');
        this.merchantId = inputVariables[0] != '{!MID}' ? inputVariables[0] : null;        
        this.product = inputVariables[1] != '{!Product}' ? inputVariables[1] : null;
        this.routableId = inputVariables[2];

        getRecordTypeId({ isLoggedInMerchant: this.isLoggedInUser })
        .then(result => {
            this.picklistRecordTypeId = result;
        })

        if(this.isLoggedInUser) {
            getMerchantDetails({ merchantId: this.merchantId })
            .then(result => {
                if(result.success) {
                    this.merchantName = result.data.MerchantName__c;
                    this.email = result.data.Email__c;
                    this.mobileNo = result.data.Mobile__c;

                    this.inputObj.merchantName = this.merchantName;
                    this.inputObj.email = this.email;
                    this.inputObj.mobileNo = this.mobileNo;
                } else {
                    //console.log('ERROR: ', result.errorMessage);
                }
            })
        }
    }
    
    listenForMessage = (event) => {
        if (event.data.action == 'CAPTCHA_VERIFIED') {
            if (event.data.token) {
                this.recaptchaKey = event.data.token;
                this.inputObj.recaptchaKey = this.recaptchaKey;
            } else {
                this.recaptchaKey = null;
            }

        } else if (event.data.action == 'CAPTCHA_EXPIRED') {
            this.recaptchaKey = null;

        } else if (event.data.action == 'CAPTCHA_VISIBLE') {
            if(event.data.captchaVisible === 'visible'){
                this.template.querySelector('iframe').height = 700;
            } else {
                this.template.querySelector('iframe').height = 100;
            }
        }
    }

    handleIssueChange(event) {
        this.issueCategory = event.target.value;
        this.inputObj.issueCategory = this.issueCategory;       
        this.errorIssue = this.issueCategory ? '' : 'Please select Issue Category';

        this.issueSubCategory = null;
        this.errorSubIssue = 'Please select Issue Sub Category';

        let key = this.subIssueFieldData.controllerValues[event.target.value];
        this.subIssueOptions = this.subIssueFieldData.values.filter(opt => opt.validFor.includes(key));
    }

    handleSubIssueChange(event) {
        this.issueSubCategory = event.target.value;
        this.inputObj.issueSubCategory = this.issueSubCategory; 
        this.errorSubIssue = this.issueSubCategory ? '' : 'Please select Issue Sub-Category';
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
        this.inputObj.description = this.description; 
        this.errorDescription = this.description ? '' : 'Please enter comments';
    }

    handleNameChange(event) {
        this.merchantName = event.target.value;
        this.inputObj.merchantName = this.merchantName; 
        this.errorName = this.merchantName ? '' : 'Name is required';
    }

    handleEmailChange(event) {
        let input = event.target.value;
        this.email = ''; 
        if(input){
            input = input.trim();
            var mailformat = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
            if(input.match(mailformat)) {
                this.email = input;
                this.inputObj.email = input;
                this.errorEmail = '';
            } else{
                this.errorEmail = 'Invalid Email';
            }
        } else{
            this.errorEmail = 'Email is required';
        }
        
    }

    handleMobileChange(event) {
        let input = event.target.value;
        this.mobileNo = '';
        if(input){
            var mobileFormat = /^[6-9][0-9]{9}$/;
            if(input.match(mobileFormat)){
                this.mobileNo = input;
                this.inputObj.mobileNo = input;
                this.errorMobile = '';
            } else {
                this.errorMobile = 'enter a valid 10-digit mobile number';
            }           
        } else {
            this.errorMobile = 'Mobile number is required';
        }     
    }
    
    handleMonthlySalesChange(event) {
        this.expectedMonthlySales =  event.target.value;
        this.inputObj.expectedMonthlySales = this.expectedMonthlySales;
        this.errorMonthlySales = this.expectedMonthlySales ? '' : 'Please select expected monthly sales';

    }

    handleWebsiteChange(event) {
        let input = event.target.value;
        this.website = '';
        if(input){
            var websiteFormat = /^(https?:\/\/)((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$/i;
            if(input.match(websiteFormat)){
                this.website = input;
                this.inputObj.website = input;
                this.errorWebsite = '';
            } else {
                this.errorWebsite = 'Please enter valid URL using http:// or https://';
            }           
        } else {
            this.errorWebsite = 'Website is required';
        }
    }

    handleMerchantIdChange(event) {
        let input = event.target.value;
        this.mid = '';
        if(input){
            var merchantIdFormat = /^[0-9]*$/;
            if(input.match(merchantIdFormat)){
                this.mid = input;
                this.inputObj.mid = input;
                this.errorMId = '';
            } else {
                this.errorMId = 'Merchant ID should only contain digits';
            }           
        } else {
            this.errorMId = 'merchant ID is required';
        }
    }

    handleFilesChange(event) {
        let files = event.target.files;
        for (let i = 0; i < files.length; i++) {
            if(this.filesUploaded.length >= 5) {
                break;      
            }

            let file = files[i];
            this.fileNameList.push(file.name);

            let freader = new FileReader();
            freader.readAsDataURL(file); 
            //freader.readAsBinaryString(file);
            freader.onload = f => {
                let base64 = 'base64,'
                let content = freader.result.indexOf(base64) + base64.length;
                let fileContents = freader.result.substring(content);
                let fileData = freader.result.split(':')[1];
                let fileType = fileData.split(';')[0];
                //console.log('fileType=='+fileType);
                //this.filesUploaded.push(freader.result);
                this.filesUploaded.push({
                    fileName: file.name,
                    fileBlob: fileContents,
                    fileType: fileType
                });
            };
            
        }

        this.fileNames = this.fileNameList.join(", ");

        // const file = files[i];
        //     this.fileNameList.push(file.name);
        //     formData.append('files', file); // Append the file to the formData object

        //     this.filesUploaded.push({
        //     fileName: file.name,
        //     fileType: file.type,
        //     fileBlob: file, // Save the actual file object
        //     });
        // }

        // try {
        //     const response = await fetch('https://api.example.com/upload', {
        //     method: 'POST',
        //     body: formData,
        //     });
    }

    handleSubmit(event) {
        this.showSpinner = true;
        if(this.merchantId) {
            this.inputObj.merchantId = this.merchantId;
            this.inputObj.platform = this.product;
        } else {
            this.inputObj.merchantBucket = 'Not Logged In';
        }
        const inputJSON = JSON.stringify(this.inputObj);
        const filesJSON = JSON.stringify([...this.filesUploaded]);
        //this.makeHttpRequest();
        console.table(inputJSON);
        console.table(filesJSON);
        createCase({inputJSON: inputJSON, filesJSON: filesJSON})
        .then(result => {
            console.log('RESULT: ',result);
            this.isSubmitted = true;
            this.result = result.message;
            this.ticketId = this.result;
            this.isCaseCreated = result.isCaseCreated;
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('Error: ',error);
            this.isSubmitted = true;
            this.result = 'An error has occured. Please try again later';
            this.isCaseCreated = false;
            this.showSpinner = false;
        });

    }

    async makeHttpRequest() {
        const url = 'https://test-help.payu.in/api/v1/tickets';
        const formData = new FormData();
        var accessToken = '';
        
        //need to set accessToken in header for logged-in users. For logged out users, recaptcha key is required.
        try {
            accessToken = await getAccessToken();
            console.log('accessToken ',accessToken);
        } catch (error) {
            console.error('Error:', error);
        }

        for (let key in this.inputObj) {
            if (this.inputObj.hasOwnProperty(key)) {
                formData.append(key, this.inputObj[key]);
            }
        }
        console.log(this.inputObj);
        console.log(formData);
        fetch(url, {
            method: 'POST',
            body: formData,
            headers:{ 
                //"mode": "no-cors",
                "Authorization": "Bearer " + accessToken,
                //"Access-Control-Allow-Origin": '*',
                //"Accept":"application/json"
            }
        })
        .then(response => {
            console.log('RESPONSE: ',response);
            if (response.ok) {
                return response.json();
            } else {
                throw new Error('Error occurred while making the HTTP request');
            }
        })
        .then(data => {
            // Process the response data
            this.isSubmitted = true;
            this.ticketId = data.id;
            this.isCaseCreated = true;
            this.showSpinner = false;
        })
        .catch(error => {
            // Handle any errors that occurred during the request
            console.error('HTTP Request Error:', error);
            this.isSubmitted = true;
            this.result = 'An error has occured. Please try again later';
            this.isCaseCreated = false;
            this.showSpinner = false;
        });
    }

    handleFormSubmissionEvent(evt){
        const selected = evt;
        if(selected){
            console.log('enter form submitted website create case');
            this.isformSubmitted = selected;
            const formsubmittedEvent = new CustomEvent(
                "formsubmission",
                {
                    isformSubmitted : this.isformSubmitted
                }
            );
            this.dispatchEvent(formsubmittedEvent);
        }else{
            //this.isSubIssueEmpty =true;
            //this.errorSubIssue = 'this field cannot be blank';
        }
    }

}