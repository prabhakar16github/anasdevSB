import { LightningElement,wire, track ,api} from 'lwc';
import getMerchantRecordData from '@salesforce/apex/OfflineOnboardingForm_Controller.getMerchantRecordData';
import fetchBusinessEntity from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchBusinessEntity';
import fetchProduct from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchProduct';
import fetch_Partner from '@salesforce/apex/OfflineOnboardingForm_Controller.fetch_Partner';
import fetchPartner from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchPartner';
import fetchBusinessCategory from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchBusinessCategory';
import saveAddressData from '@salesforce/apex/OfflineOnboardingForm_Controller.saveAddressData';
import fetchSubCategory from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchSubCategory';
import fetchPicklistValue from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchPicklistValue';
import saveLeadData from '@salesforce/apex/OfflineOnboardingForm_Controller.saveLeadData';
import fetchPanNumber from '@salesforce/apex/OfflineOnboardingForm_Controller.fetchPanNumber';
import detalPageOfLead from '@salesforce/label/c.Offline_Onbording_Detail_page_Url';


import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Lead_OBJECT from '@salesforce/schema/Lead';
import ENTPayUProduct_FIELD from '@salesforce/schema/Lead.ENT_PayU_Product__c';

//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import Lead_OBJECT from '@salesforce/schema/Lead';
//import MerchantPlatform_FIELD from '@salesforce/schema/Lead.Merchant_Platform__c';
//import Type_FIELD from '@salesforce/schema/Account.Type';
export default class OfflineOnboardingFormLwc extends LightningElement {
    label = {
        detalPageOfLead,
    };
    

    //dynamically change the css of the toggle section.
    //@track toggleCss = 'toggleSectionCssWithoutData';
    @track boolOne = 2;
    @track boolTwo = 2;
    @api recordId;
    @track wrap ={};
    @api leadId = '';
    @track registeredAddress = {};
    @track operatingAddress = {};
    @track addressList = [];
    @api contactObjTwo = {};
    @api contactObjOne = {};
    @api bankAccountObj = {};
    @track businessEntity = '';
    @track partner = '';
    @track product = '';
    @track subCategory = '';
    @track businessCategory = '';
    /* toggle var is used to open and close the section*/
    @track toggleBasicSectionClass = true;  
    @track toggleBusinessDetailSectionClass = true;
    @api toggleBankDetailsSectionClass = false;
    @track toggleWebsiteDetailsSectionClass = true;
    @track toggleAddressDetailsSectionClass = true;
    @api toggleAuthSignatoryDetailsSectionClass = false;
    /* to show sections based on conditions*/
    @track isShowBasicSection = true;
    @track isShowBusinessDetail = false;
    @track isShowWebsiteDetailsSection = false;
    @api isShowBankDetailsSection = false;
    @track isShowAddressDetailsSection = false;
    @track isShowAuthSignatoryDetailsSection = false;

    @track mobileFieldError = '';//it will throw error msg if mobile no contains 0 in start
    @api currentStep = '1';//to manage the progress Train
    @track panNumberList = []; 
    @track legalNameList = []; 
    @track partnerNameList = [];
    @track businessCategoryValue = [];//contains all the value of business category field.
    @track eNTMerchantCategoryRangeValue = [];//contains all the value of ENT Merchant Category Range field.
    @track eNTPayUProductValue = [];//contains all the value of ENT Payu Product Range field.
    @track productId = '';//contains payUBiz product id for Product field.
    @track partnerValue = [];//contains all the value of Partner field.
    @track businessEntityValue = [];//contains all the value of business entity field.
    @track subCategoryValue = [];
    @track isShowPanNumberList = false;
    @track isShowLegalNameList = false;
    @track isShowPartnerNameList = false;
    @track isShowErrorMsg = false;//to show validation Msg for Basic Details Section.
    @track isShowErrorMsgForBusinessSection = false; //to show validation Msg for Business Details Section.
    @track isShowErrorMsgForWebsiteSection = false; //to show validation Msg for Business Details Section.
    @track isShowErrorMsgForAddressSection = false; //to show validation Msg for Business Details Section.
    //@track isShowErrorMsgForBankSection = false;
    //@track isShowErrorMsgForAuthorisedSignatorySection = false;
    @track BasicDetailsViewMode = false;
    @track BusinessDetailsViewMode = false;
    @track addressDetailsViewMode = false;
    @track websiteDetailsViewMode = false;
    @api bankDetailsViewMode = false;
    @api contactDetailsViewMode = false;
    @track isShowViewButton = false;
    @track isShowViewButtonForWebsiteSection = false;
    @track isShowViewButtonForBusinessDetailsSection = false;
    @track isShowViewButtonForAddressDetailsSection = false;
    //@track isShowViewButtonForBankDetailsSection = false;
    //@track isShowViewButtonForAuthorisedSignatorySection = false;
    @track isShowPartnerField = false;//show partner field only when sub source is banking or whitelabels 
    //@track isShowSubSourceField = false;//show subsource field only when lead source is partner 
    @track isShowsubSourceField = false;//show sub source field only when lead source partner 
    @track result;
    @api isShowSpinner = false;
    @track isShowSpinneratDetailsPage = false;
    @track subSource = '';
    @track errorMsg = '';
    @track errorMsgForBusinessSection = '';
    @track errorMsgForWebsiteSection = '';
    @track errorMsgForAddressSection = '';
    @track customClass = '';
    @track isBothAddressSame = false;
    @track isShowBusinessCateErrorMsg = false;
    @track isShowSubCateErrorMsg = false;
    @track dynamicCssForPanAndLegalName = '';
    @track selectePayuProduct = [];
    error;
    
    // assigning none if you are not seleted any values
    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    // Handling the change event
    handleChange(event) {
        this._selected = event.detail.value;
    }
    

    connectedCallback(){
        //this.template.querySelector('[data-id="toggleCss"]').classList.add('toggleSectionCssWithoutData');
        if(this.recordId){
            console.log('recordId'+this.recordId);
            this.fetchMerchantRecordData();
            this.dynamicCssForPanAndLegalName = 'panStyleOnDetailPage';
            //this.template.querySelector('[data-id="dynamicCssForPanAndLegalName"]').classList.add('panStyleOnDetailPage');
        }else{
            this.dynamicCssForPanAndLegalName = 'panStyle';
            //this.template.querySelector('[data-id="dynamicCssForPanAndLegalName"]').classList.add('panStyle');
        }
        this.wrap.LeadSource = 'Organic';
        this.toggleBankDetailsSectionClass = true;
        this.toggleAuthSignatoryDetailsSectionClass = true;
        this.fetchBusinessCategory();
        this.fetchSubCategory();
        this.fetchProduct();
        this.fetchBusinessEntity();
    }
    renderedCallback(){

    }
    //  invoke apex method with wire property and fetch picklist options.
    // pass 'object information' and 'picklist field API name' method params which we need to fetch from apex
    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'Status'}) statusValues;
    
    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'Merchant_Platform__c'}) merchantPlatformValue;
    
    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'Priority__c'}) priorityValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'LeadSource'}) LeadSourceValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'Sub_Source__c'}) subSourceValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'PCI_Merchant_Category__c'}) PCIMerchantCategoryValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'Website_Operating_System__c'}) WebsiteOperatingSystemValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'Sub_Status__c'}) subStatusValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'Product_holding__c'}) productHoldingValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'ENT_Merchant_Category_Range__c'}) eNTMerchantCategoryRangeValue;

    @wire(fetchPicklistValue, {objInfo: {'sobjectType' : 'Lead'},
    picklistFieldApi: 'ENT_PayU_Product__c'}) eNTPayUProductValue;

    /*// Getting Account Object info using wire service
    @wire(getObjectInfo, { objectApiName: Lead_OBJECT })
    objectInfo;

    // Getting Pickvalues based on default recordtype using wire service
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ENTPayUProduct_FIELD})
    IndustryValues;*/
    
    
    fetchMerchantRecordData(){
        var record_Id = this.recordId;
        console.log('record_Id>>>>'+record_Id);
        this.isShowSpinneratDetailsPage = true;
        getMerchantRecordData({record_Id})
        .then(result =>{
            console.log('result>>>>'+JSON.stringify(result));
            if(result.leadObj){
                if(result.leadObj.ENT_PayU_Product__c){
                    var selectePayu_Product = [];
                    var selectePayuProductTemp = result.leadObj.ENT_PayU_Product__c.split(";");
                    for(var i = 0; i < selectePayuProductTemp.length; i++){
                        selectePayu_Product.push(selectePayuProductTemp[i]);
                    }
                    this.selectePayuProduct = selectePayu_Product;
                    //result.leadObj.ENT_PayU_Product__c = selectePayuProduct;
                }
                JSON.parse(JSON.stringify(result));
                this.wrap = JSON.parse(JSON.stringify(result.leadObj));
            }
            if(result.product){
                this.product = result.product;
            }
            if(result.businessEntity){
                this.businessEntity = result.businessEntity;
            }
            if(result.partner){
                this.partner = result.partner;
            }
            if(result.businessCategory){
                this.businessCategory = result.businessCategory;
            }
            if(result.subCategory){
                this.subCategory = result.subCategory;
            }
            //this.wrap = this.oldWrap;
            if(result.bankAccountObj){
                this.bankAccountObj = JSON.parse(JSON.stringify(result.bankAccountObj));
            }
            if(result.addressDetailsObj){
                let registered_Address;
                let operating_Address;
                result.addressDetailsObj.forEach(function (item) { 
                    if(item.Type__c === 'Registered'){
                        if(item){
                            //console.log('this.registeredAddress'+JSON.stringify(this.registeredAddress));
                            registered_Address = JSON.parse(JSON.stringify(item));
                        }
                    }
                    if(item.Type__c === 'Operating'){
                        if(item){
                            operating_Address = JSON.parse(JSON.stringify(item));
                        }
                    }
                });
                if(registered_Address){
                    this.registeredAddress = JSON.parse(JSON.stringify(registered_Address));
                }if(operating_Address){
                    this.operatingAddress = JSON.parse(JSON.stringify(operating_Address));
                }
                
            }

            if(result.contactObj){
                if(result.contactObj[0]){
                    this.contactObjOne = JSON.parse(JSON.stringify(result.contactObj[0]));
                    
                }if(result.contactObj[1]){
                    this.contactObjTwo = JSON.parse(JSON.stringify(result.contactObj[1]));
                }
            }
            
            
            this.checkSectionToDisplay();
            this.isShowSpinneratDetailsPage = false;
            this.updateProgrssIndicator();
        })
        .catch(error =>{
            console.log(error);
        })
    }
    

    fetchBusinessEntity(){
        fetchBusinessEntity()
            .then(result => {
                if(result){
                    this.businessEntityValue = result;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
        });
    }

    fetchProduct(){
        fetchProduct()
            .then(result => {
                if(result){
                   this.productId = result;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
        });
    }
    fetchPartner(){
        console.log('fetchPartner'+this.subSource);
        let temp_subSource = this.subSource;
        fetchPartner({temp_subSource})
            .then(result => {
                if(result){
                   this.partnerValue = result;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
        });
    }

    fetchBusinessCategory(){
        fetchBusinessCategory()
            .then(result => {
                if(result){
                   this.businessCategoryValue = result;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
        });
    }
    fetchSubCategory(){
        fetchSubCategory()
            .then(result => {
                if(result){
                   this.subCategoryValue = result;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
        });
    }
    renderedCallback() {
        
    }
    handleChangePanNumber(event){
        var result;
        var fieldName = event.target.name;
        var data = event.target.value;
        if(!data && fieldName === 'PanNumber'){
            this.wrap.PAN_Number__c = data;
        }
        if(!data && fieldName === 'LegalName'){
            this.wrap.Legal_Name__c = data;
        }
        if(data.length >=3 && fieldName === 'PanNumber'){
            this.wrap.PAN_Number__c = data;
            fetchPanNumber({ data,fieldName })
            .then(result => {
                if(result){
                    this.isShowPanNumberList = true;
                    this.panNumberList = result;
                    
                }else{
                    this.isShowPanNumberList = false;
                    //this.wrap.PAN_Number__c = data;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
            });
        }else{
            this.isShowPanNumberList = false;
        }

        if(data.length >=3 && fieldName === 'LegalName'){
            this.wrap.Legal_Name__c = data;
            fetchPanNumber({ data,fieldName })
            .then(result => {
                if(result){
                    this.isShowLegalNameList = true;
                    this.legalNameList = result;
                }else{
                    this.isShowLegalNameList = false;
                    //this.wrap.Legal_Name__c = data;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
            });
        }
        
    }

    handleChange_Partner(event){
        console.log('handleChange_Partner');
        var result;
        var fieldName = event.target.name;
        var data = event.target.value;
        console.log('fieldName'+fieldName);
        console.log('data '+data);
        if(data.length >=2){
            console.log('data inside: '+data);
            this.wrap.Partner__c = data;
            fetch_Partner({ data })
            .then(result => {
                if(result){
                    console.log('result '+result);
                    this.isShowPartnerNameList = true;
                    this.partnerNameList = result;
                    
                }else{
                    this.isShowPartnerNameList = false;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
            });
        }else{
            this.isShowPartnerNameList = false;
        }
    }

    setPanNumber(event){
        var title = event.target.title;
        var id = event.target.id;
        console.log('label>>>>>>'+id);
        if(title){
            console.log('title>>>>>>'+title);
            this.wrap.Legal_Name__c = title;
            this.isShowLegalNameList = false;
        }
        if(id){
            var tempPan = '';
            if(id.length >10){
                var templength = id.length;
                var removeLength = templength-10;
                tempPan = id.slice(0, -removeLength);
            }
            this.wrap.PAN_Number__c = tempPan;
            
        }
        this.isShowPanNumberList = false;
    }
    setlegalName(event){
        console.log('setlegalName');
        var id = event.target.id;
        var title = event.target.title;
        if(title){
            this.wrap.Legal_Name__c = title;
            this.isShowLegalNameList = false;
        }
        if(id){
            var tempPan = '';
            if(id.length >10){
                var templength = id.length;
                var removeLength = templength-10;
                tempPan = id.slice(0, -removeLength);
            }
            this.wrap.PAN_Number__c = tempPan;
        }
        //console.log('this.wrap.PanNumber>>>>>>'+this.wrap.PanNumber);
    }

    setPartner(event){
        this.partner = '';
        var title = event.target.title;
        var id = event.target.id;
        console.log('label>>>>>>'+title);
        if(id){
            this.wrap.Partner__c = title;
            this.partner = id;
        }
        this.isShowPartnerNameList = false;
    }

    /*handleChangeProduct(event){
        var result;
        var fieldName = event.target.name;
        var data = event.target.value;
        fetchPanNumber({ data,fieldName })
        .then(result => {
            if(result){
                this.isShowPanNumberList = true;
                this.panNumberList = result;
            }else{
                this.isShowPanNumberList = false;
                this.wrap.PAN_Number__c = data;
            }
        })
        .catch(error => {
            console.log('error'+JSON.stringify(error.message));
        });
        
    }*/
    handleChangePartner(event){
        var result;
        var fieldName = event.target.name;
        var data = event.target.value;
        if(data.length >=3 && fieldName === 'PanNumber'){
            fetchPanNumber({ data,fieldName })
            .then(result => {
                if(result){
                    this.isShowPanNumberList = true;
                    this.panNumberList = result;
                }else{
                    this.isShowPanNumberList = false;
                    this.wrap.PAN_Number__c = data;
                }
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error.message));
            });
        }else{
            this.isShowPanNumberList = false;
        }
    }

    handleChangeLeadField(event) {
        try{
            if(event.target.type ==='checkbox'){
                this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.checked;
            }else{
                this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.value;
                this.value = event.target.value;
            }
            
            var leadObj = JSON.stringify(this.wrap);
            console.log('leadObj1'+leadObj);
            if(this.wrap.LeadSource === 'Partner'){
                this.isShowsubSourceField = true;
            }else{
                this.isShowsubSourceField = false;
            }
            if(this.wrap.Sub_Source__c === 'WhiteLabelPartner'){
                this.isShowPartnerField = true;
                this.subSource = 'WhiteLabelPartner';
                this.fetchPartner();
            }else if(this.wrap.Sub_Source__c === 'BankingPartner'){
                this.isShowPartnerField = true;
                this.subSource = 'BankingPartner';
                this.fetchPartner();
            }/*else if(this.wrap.Sub_Source__c === 'Reseller'){
                this.isShowPartnerField = true;
                this.subSource = 'Reseller';
                this.fetchPartner();
            }*/else{
                this.isShowPartnerField = false;
            }
            var mobilenumber = this.wrap.MobilePhone;
            if(mobilenumber){
                if(mobilenumber.startsWith('0')){
                    this.mobileFieldError = 'Please remove 0 from start of mobile number';
                }else if(mobilenumber.length >10){
                    this.mobileFieldError = 'Please enter a valid 10 digit number.';
                }else{
                    this.mobileFieldError = '';
                }
            }
            console.log('this.wrap.BusinessCategory__c'+this.wrap.BusinessCategory__c);
            console.log('this.wrap.Sub_Category__c'+this.wrap.Sub_Category__c);
            if(this.wrap.BusinessCategory__c == 'Others'){
                this.isShowBusinessCateErrorMsg = true;
            }else{
                this.isShowBusinessCateErrorMsg = false;
            }
            if(this.wrap.Sub_Category__c == 'Others'){
                this.isShowSubCateErrorMsg = true;
            }else{
                this.isShowSubCateErrorMsg = false;
            }
            console.log('this.isShowBusinessCateErrorMsg'+this.isShowBusinessCateErrorMsg);
            console.log('this.isShowBusinessCateErrorMsg'+this.isShowBusinessCateErrorMsg);
            console.log('leadObj'+JSON.stringify(this.wrap));
            
        }catch(error){
            console.log('error'+error);
        }
        
    }
    handleAddressFieldChange(event) {
        try{
            console.log('handleAddressFieldChange');
            if(event.target.type ==='checkbox'){
                this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.checked;
            }else{
                this[event.currentTarget.dataset.object][event.currentTarget.dataset.fieldapi] = event.target.value;
            }
            this.registeredAddress.Type__c = 'Registered';
            this.registeredAddress.Lead__c = this.leadId;
            this.operatingAddress.Lead__c = this.leadId;
            this.operatingAddress.Type__c = 'Operating';
        }catch(error){
            console.log('error::'+error);
        }
    }
    
    /*To Save the Lead record*/
    handale_SaveLead(){
        if(!this.wrap.Id){
            this.wrap.Status = 'New';
            this.wrap.Company = this.wrap.LastName;
            this.wrap.Business_Origin__c = 'ENT Offline';
            this.wrap.Merchant_Business_Type__c = 'Enterprise';
            this.wrap.Product__c = this.productId;
            this.wrap.PAN_Verification_Status__c = 'Success';
            this.wrap.Settlement_Status__c = 'Thirdparty Hold';
            if(this.wrap.Website__c){
                this.wrap.Integration_Type__c = 'ThirdParty';
            }else{
                this.wrap.Integration_Type__c = 'Tools';
            }
            
            this.Lead_Type__c = 'Merchant';
            this.Website_Status__c = 'Website Incomplete';
        }
        this.wrap.PAN_Holder_Name__c = this.wrap.Legal_Name__c;
        var leadObj = JSON.stringify(this.wrap);
        if(this.validate_Fields()){
            this.isShowSpinner = true;
            saveLeadData({leadObj})
            .then(result => {
                console.log('result'+JSON.stringify(result));
                if(!result.errorMsg){
                    this.errorMsg = '';
                    /*if(result.leadObj.MobilePhone && (!result.leadObj.MobilePhone && !result.leadObj.BusinessCategory__c) && !result.leadObj.Website__c){
                        
                    }*/
                    if(result.leadObj.MobilePhone){
                        //this.currentStep = '2';
                        this.BasicDetailsViewMode = true;
                        this.isShowErrorMsg = false;
                        this.toggleBasicSectionClass = false;
                        this.isShowBusinessDetail = true;
                        //this.template.querySelector('[data-id="toggleCss"]').classList.add('toggleSectionCssWithData');
                    }
                    if(result.leadObj.Id){
                        this.isShowSpinner = false;
                        this.leadId = result.leadObj.Id;
                    }
                    if(result.leadObj){
                        this.wrap = result.leadObj;
                        this.oldWrap = result.leadObj;
                    }
                    if(result.product){
                        this.product = result.product;
                    }
                    if(result.businessEntity){
                        this.businessEntity = result.businessEntity;
                    }
                    if(result.partner){
                        this.partner = result.partner;
                    }
                    this.updateProgrssIndicator();
                }else{
                    if(result.errorMsg){
                        var tempError = result.errorMsg.split("first error:");
                        this.errorMsg = tempError[1];
                        this.isShowSpinner = false;
                        this.updateProgrssIndicator();
                    }
                }
                
            })
            .catch(error =>{
                console.log('error::'+error);
            });
        }else{
            console.log('ELSE');
            this.isShowErrorMsg = true;
        }
    }  

    /*To Update the Lead record For Business Details Section*/
    handale_UpdateLeadForBusinessSection(){
        console.log('ENTPayuProduct1'+this.wrap.ENT_PayU_Product__c);
        var ENTPayuProduct = '';
        if(this.wrap.ENT_PayU_Product__c){
            var templist = this.wrap.ENT_PayU_Product__c;
            console.log('templist'+templist);
            console.log('templist size'+templist.length);
            
            if(templist.length >=1 && templist.length < 4){
                templist.forEach(function (item) {  
                    if(item){
                        ENTPayuProduct = ENTPayuProduct +item+';';
                    }
                });
                ENTPayuProduct = ENTPayuProduct.slice(0, -1);
                this.wrap.ENT_PayU_Product__c = ENTPayuProduct;
            }
        }
        console.log('ENTPayuProduct'+ENTPayuProduct);
        
        var leadObj = JSON.stringify(this.wrap);
        console.log('leadObj'+leadObj);
        //console.log('handale_SaveLead'+this.validate_Fields);
        if(this.validate_LeadForBusinessSection_Fields()){
            this.isShowSpinner = true;
            saveLeadData({leadObj})
            .then(result => {
                console.log('result'+JSON.stringify(result));
                if(!result.errorMsg){
                    this.errorMsgForBusinessSection = '';
                    if(result.leadObj.ENT_PayU_Product__c){
                        var selectePayu_Product = [];
                        var selectePayuProductTemp = result.leadObj.ENT_PayU_Product__c.split(";");
                        for(var i = 0; i < selectePayuProductTemp.length; i++){
                            selectePayu_Product.push(selectePayuProductTemp[i]);
                        }
                        this.selectePayuProduct = selectePayu_Product;
                        //result.leadObj.ENT_PayU_Product__c = selectePayuProduct;
                    }
                    JSON.parse(JSON.stringify(result));
                    this.wrap = JSON.parse(JSON.stringify(result.leadObj));
                    if(result.leadObj.MobilePhone && result.leadObj.BusinessCategory__c){
                        this.isShowSpinner = false;
                        //this.currentStep = '3';
                        this.BusinessDetailsViewMode = true;
                        this.isShowErrorMsgForBusinessSection = false;
                        this.toggleBusinessDetailSectionClass = false;
                        this.isShowAddressDetailsSection =true;
                    }
                    if(result.leadObj){
                        this.wrap = result.leadObj;
                    }
                    if(result.businessCategory){
                        this.businessCategory = result.businessCategory;
                    }
                    if(result.subCategory){
                        this.subCategory = result.subCategory;
                    }
                    this.updateProgrssIndicator();
                }else{
                    if(result.errorMsg){
                        var tempError = result.errorMsg.split("first error:");
                        this.errorMsgForBusinessSection = tempError[1];
                        this.isShowSpinner = false;
                        this.updateProgrssIndicator();
                    }
                }
                
            })
            .catch(error =>{
                console.log('error::'+error);
                this.isShowSpinner = false;
            });
        }else{
            console.log('ELSE');
            this.isShowErrorMsgForBusinessSection = true;
        }
    }

    /*To update the Lead record for website details section*/
    handale_UpdateLeadForWebsiteSection(){
        if(!this.wrap.Id){
            this.wrap.Status = 'New';
            this.wrap.Company = 'Test';
        }
        var leadObj = JSON.stringify(this.wrap);
        console.log('leadObj'+leadObj);
        //console.log('handale_SaveLead'+this.validate_Fields);
        if(this.validate_LeadForWebsiteSection_Fields()){
            this.isShowSpinner = true;
            saveLeadData({leadObj})
            .then(result => {
                console.log('result'+JSON.stringify(result));
                if(!result.errorMsg){
                    this.errorMsgForWebsiteSection = '';
                    if(result.leadObj.MobilePhone && result.leadObj.BusinessCategory__c && result.leadObj.Website__c){
                        this.isShowSpinner = false;
                        //this.currentStep = '5';
                        this.websiteDetailsViewMode = true;
                        this.isShowErrorMsgForWebsiteSection = false;
                        this.toggleWebsiteDetailsSectionClass = false;
                        this.isShowAuthSignatoryDetailsSection = true;
                    }
                    if(result.leadObj){
                        this.wrap = result.leadObj;
                    }
                    this.updateProgrssIndicator();
                }else{
                    if(result.errorMsg){
                        var tempError = result.errorMsg.split("first error:");
                        this.errorMsgForWebsiteSection = tempError[1];
                        this.isShowSpinner = false;
                        this.updateProgrssIndicator();
                    }
                }
            })
            .catch(error =>{
                this.isShowSpinner = false;
                console.log('error::'+error);
            });
        }else{
            console.log('ELSE');
            this.isShowErrorMsgForWebsiteSection = true;
        }
        console.log('isShowErrorMsg::'+this.isShowErrorMsg);
    }
    /*To Save the Address record*/
    handale_SaveAddress(){
        if(this.recordId){
            this.leadId = this.recordId;
        }
        this.registeredAddress.Lead__c=this.leadId ;
        this.operatingAddress.Lead__c=this.leadId ;
        var registeredAddress = this.registeredAddress;
        var operatingAddress = this.operatingAddress;
        var tempaddressList = [];
        tempaddressList.push(registeredAddress);
        tempaddressList.push(operatingAddress);
        var addressList = JSON.stringify(tempaddressList);
        console.log('addressList'+addressList);
        if(this.validate_Address_Fields()){
            this.isShowSpinner = true;
            saveAddressData({addressList})
            .then(result => {
                if(!result.errorMsg){
                    this.errorMsgForAddressSection = '';
                    console.log('address result'+JSON.stringify(result));
                    //this.currentStep = '4';
                    result.addressDetailsObj.forEach(function (item) { 
                        if(item.Type__c === 'Registered'){
                            if(item){
                                registeredAddress = item;
                            }
                        }
                        if(item.Type__c === 'Operating'){
                            if(item){
                                operatingAddress = item;
                            }
                        }
                    });
                    this.registeredAddress = registeredAddress;
                    this.operatingAddress = operatingAddress;
                    this.addressDetailsViewMode = true;
                    this.isShowErrorMsgForAddressSection = false;
                    this.toggleAddressDetailsSectionClass = false;
                    this.isShowWebsiteDetailsSection = true;
                    this.isShowSpinner = false;
                    this.updateProgrssIndicator();
                }else{
                    if(result.errorMsg){
                        var tempError = result.errorMsg.split("first error:");
                        this.errorMsgForAddressSection = tempError[1];
                        this.isShowSpinner = false;
                        this.updateProgrssIndicator();
                    }
                }
            })
            .catch(error =>{
                this.isShowSpinner = false;
                console.log('error::'+error);
            });
        }else{
            this.isShowErrorMsgForAddressSection = true;
        }
    }
    
    
    //validate lead fields for basic details
    validate_Fields(){
        var isAllFieldFilled = false;
        if(this.wrap.FirstName && this.wrap.LastName && this.wrap.Email && this.wrap.MobilePhone && this.wrap.Sub_Status__c && this.wrap.Business_Entity__c && this.wrap.LeadSource){
                isAllFieldFilled = true;
        }
        return isAllFieldFilled;
    }

    //validate lead fields for business details
    validate_LeadForBusinessSection_Fields(){
        var isAllFieldFilled = false;
        if(this.wrap.BusinessCategory__c && !this.isShowBusinessCateErrorMsg){
            isAllFieldFilled = true;
        }
        return isAllFieldFilled;
    }

    //validate lead fields for basic,business , website details
    validate_LeadForWebsiteSection_Fields(){
        var isAllFieldFilled = false;
        if(this.wrap.Website__c){
                isAllFieldFilled = true;
        }
        return isAllFieldFilled;
    }
    // validate address fields.
    validate_Address_Fields(){
        var isAllFieldFilled = false;
        if(this.registeredAddress.City__c && this.registeredAddress.State__c && this.registeredAddress.Country__c && this.registeredAddress.Pincode__c  
            && this.operatingAddress.City__c && this.operatingAddress.State__c && this.operatingAddress.Country__c && this.operatingAddress.Pincode__c){
                isAllFieldFilled = true;
        }
        return isAllFieldFilled;
    }
    
    editBasicDetailsSection(){
        this.isShowViewButton = true;
        this.isShowErrorMsg = false;
        this.BasicDetailsViewMode = false;
    }
    openViewMode(){
        this.isShowViewButton = false;
        this.BasicDetailsViewMode = true;
    }
    editBusinessDetailsSection(){
        this.isShowViewButtonForBusinessDetailsSection = true;
        this.isShowErrorMsgForBusinessSection = false;
        this.BusinessDetailsViewMode = false;
    }
    openViewModeForBusinessSection(){
        this.isShowViewButtonForBusinessDetailsSection = false;
        this.BusinessDetailsViewMode = true;
    }
    editWebsiteDetailsSection(){
        this.isShowViewButtonForWebsiteSection = true;
        this.isShowErrorMsgForWebsiteSection = false;
        this.websiteDetailsViewMode = false;
    }
    openViewModeForWebsiteSection(){
        this.isShowViewButtonForWebsiteSection = false;
        this.websiteDetailsViewMode = true;
    }
    editAddressDetailsSection(){
        this.isShowViewButtonForAddressDetailsSection = true;
        this.isShowErrorMsgForAddressSection = false;
        this.addressDetailsViewMode = false;
    }
    openViewModeForAddressSection(){
        this.isShowViewButtonForAddressDetailsSection = false;
        this.addressDetailsViewMode = true;
    }
    toggleBasicSection(){
        if(this.toggleBasicSectionClass == true){
            this.toggleBasicSectionClass = false;
        }else if(this.toggleBasicSectionClass == false){
            this.toggleBasicSectionClass = true;
        }
    }    

    toggleBusinessSection(){
        if(this.toggleBusinessDetailSectionClass == true){
            this.toggleBusinessDetailSectionClass = false;
        }else if(this.toggleBusinessDetailSectionClass == false){
            this.toggleBusinessDetailSectionClass = true;
        }
    }
    toggleBankSection(){
        if(this.toggleBankDetailsSectionClass == true){
            this.toggleBankDetailsSectionClass = false;
        }else if(this.toggleBankDetailsSectionClass == false){
            this.toggleBankDetailsSectionClass = true;
        }
    }
    toggleWebsiteSection(){
        if(this.toggleWebsiteDetailsSectionClass == true){
            this.toggleWebsiteDetailsSectionClass = false;
        }else if(this.toggleWebsiteDetailsSectionClass == false){
            this.toggleWebsiteDetailsSectionClass = true;
        }
    }
    toggleAddressSection(){
        if(this.toggleAddressDetailsSectionClass == true){
            this.toggleAddressDetailsSectionClass = false;
        }else if(this.toggleAddressDetailsSectionClass == false){
            this.toggleAddressDetailsSectionClass = true;
        }
    }
    //this method call from authrizeSignatory child component 
    handleCustomEvent(event) {
        const isShowBank = event.detail;
        this.isShowBankDetailsSection = isShowBank;
    }
    handleCurrentStepEvent(event){
        const current_step = event.detail;
        this.currentStep = current_step;
    }
    //this method will check which section is display and which is not based on object returned
    checkSectionToDisplay(){
        var leadObj = this.wrap;
        var banObj = this.bankAccountObj;
        var registeredAddress = this.registeredAddress;
        var operatingAddress = this.operatingAddress;
        var contactObjOne = this.contactObjOne;
        //var contactObjTwo = this.contactObjTwo;
        if(leadObj.MobilePhone && leadObj.Email){
            //this.currentStep = '2';
            this.toggleBasicSectionClass = false;
            this.isShowBusinessDetail = true;
            this.BasicDetailsViewMode = true;
        }
        console.log('MobilePhone'+leadObj.MobilePhone);
        console.log('BusinessCategory__c'+leadObj.BusinessCategory__c);
        if(leadObj.MobilePhone && leadObj.BusinessCategory__c && typeof leadObj.MobilePhone != "undefined" && typeof leadObj.BusinessCategory__c != "undefined"){
            //this.currentStep = '3';
            this.BusinessDetailsViewMode = true;
            this.toggleBusinessDetailSectionClass = false;
            this.isShowAddressDetailsSection =true;
        }
        console.log('Website__c'+leadObj.Website__c);
        if(leadObj.MobilePhone && leadObj.BusinessCategory__c && leadObj.Website__c && typeof leadObj.MobilePhone != "undefined" && typeof leadObj.BusinessCategory__c != "undefined" && typeof leadObj.Website__c != "undefined"){
            //this.currentStep = '5';
            this.websiteDetailsViewMode = true;
            this.toggleWebsiteDetailsSectionClass = false;
            this.isShowAuthSignatoryDetailsSection = true;
            this.toggleAuthSignatoryDetailsSectionClass = true;
        }
        console.log('registeredAddress'+JSON.stringify(this.registeredAddress));
        console.log('operatingAddress'+JSON.stringify(this.operatingAddress));
        if(Object.keys(registeredAddress).length > 0 && Object.keys(operatingAddress).length > 0){
            console.log('inside registeredAddress');
            //this.currentStep = '4';
            this.addressDetailsViewMode = true;
            this.toggleAddressDetailsSectionClass = false;
            this.isShowWebsiteDetailsSection = true;
        }
        console.log('contactObjOne'+JSON.stringify(this.contactObjOne));
        if(Object.keys(contactObjOne).length > 0 ){
            //this.currentStep = '6';
            this.contactDetailsViewMode = true;
            this.toggleAuthSignatoryDetailsSectionClass = false;
            this.isShowBankDetailsSection = true;
        }
        console.log('checkSectionToDisplay banObj'+JSON.stringify(banObj));
        console.log('checkSectionToDisplay length'+Object.keys(banObj).length);
        if(Object.keys(banObj).length > 0){
            this.bankDetailsViewMode = true;
            this.toggleBankDetailsSectionClass = false;
            this.isShowBankDetailsSection = true;
            console.log('toggleBankDetailSectionClass>>>3'+this.toggleBankDetailsSectionClass);
        }
        console.log('toggleBasicSectionClass'+this.toggleBasicSectionClass);
        console.log('checkSectionToDisplay'+this.isShowBusinessDetail);
    }
    applyCssOnPanAndLegalName(event){
        console.log('applyCssOnPanAndLegalName');
        //event.target.id.classList.add('custompicklistCss');
        this.customClass = 'demo';
    }
    removeCssOnPanAndLegalName(){
        this.customClass = 'demo1';
    }
    GoToDetailsPage(){
        const leadId = this.leadId;
        var tempUrl = this.label.detalPageOfLead;
        var final_Url = tempUrl+leadId+'/view';
        location.replace(final_Url);
    }
    applyPanCss(event){
        //this.customClass = 'demo';
        var fieldName = event.target.dataset.id;
        this.template.querySelector('[data-id='+fieldName+']').classList.add('demo');
    }
    removePanCss(){
        this.customClass = 'demo1';
    }
    handleUpdateOperatingAddSameAsRegister(event){
        var isAddressSame = event.target.checked;
        if(isAddressSame){
            this.operatingAddress.City__c = this.registeredAddress.City__c;
            this.operatingAddress.State__c = this.registeredAddress.State__c;
            this.operatingAddress.Country__c = this.registeredAddress.Country__c;
            this.operatingAddress.Pincode__c = this.registeredAddress.Pincode__c;
            this.operatingAddress.Address_Line__c = this.registeredAddress.Address_Line__c;
        }
    }
    updateProgrssIndicator(){
        console.log('applyCssOnPanAndLegalName');
        var leadObj = this.wrap;
        var banObj = this.bankAccountObj;
        var registeredAddress = this.registeredAddress;
        var operatingAddress = this.operatingAddress;
        var contactObjOne = this.contactObjOne;
        //var contactObjTwo = this.contactObjTwo;
        
        if(Object.keys(banObj).length > 0){
            this.currentStep = '7';
        }else if(Object.keys(contactObjOne).length > 0 ){
            this.currentStep = '6';
        }else if(leadObj.Website__c && typeof leadObj.Website__c != "undefined"){
            this.currentStep = '5';
        }else if(Object.keys(registeredAddress).length > 0 && Object.keys(operatingAddress).length > 0){
            this.currentStep = '4';
        }else if(leadObj.BusinessCategory__c){
            this.currentStep = '3';
        }else if(leadObj.MobilePhone && leadObj.Email){
            this.currentStep = '2';
        }
        console.log('currentStep'+this.currentStep);
    }
    
}