import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';

import getRelatedWebsiteDetails from '@salesforce/apex/OfflineOnboardingOpportunityController.getRelatedWebsiteDetails';
import getOperatingAddressDetails from '@salesforce/apex/OfflineOnboardingOpportunityController.getOperatingAddressDetails';
import getRegisteredAddressDetails from '@salesforce/apex/OfflineOnboardingOpportunityController.getRegisteredAddressDetails';
import getBankAccountDetails from '@salesforce/apex/OfflineOnboardingOpportunityController.getBankAccountDetails';
import getContactDetails from '@salesforce/apex/OfflineOnboardingOpportunityController.getContactDetails';
import getUBODetails from '@salesforce/apex/OfflineOnboardingOpportunityController.getUBODetails';
import getOpportunityStatuses from '@salesforce/apex/OfflineOnboardingOpportunityController.getOpportunityStatuses';
import getWrapperData from '@salesforce/apex/OfflineOnboardingOpportunityController.getWrapperData';
import getSeniorManagement from '@salesforce/apex/OfflineOnboardingOpportunityController.getSeniorManagement';

//import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import OPP_ACCOUNT_FIELD from '@salesforce/schema/Opportunity.AccountId';
import MERCHANT_PLATFORM_FIELD from '@salesforce/schema/Opportunity.Merchant_Platform__c';

import WEBSITE_DETAIL_OBJECT from '@salesforce/schema/Website_Details__c';
import WEBSITE_OPP_FIELD from '@salesforce/schema/Website_Details__c.Opportunity__c';
import WEBSITE_STATUS_FIELD from '@salesforce/schema/Website_Details__c.Website_Status__c';
import WEBSITE_ACTIVE_FIELD from '@salesforce/schema/Website_Details__c.Active__c';
import WEBSITE_WBURL_FIELD from '@salesforce/schema/Website_Details__c.Website_URL__c';
import WEBSITE_IOSURL_FIELD from '@salesforce/schema/Website_Details__c.IOS_URL__c';
import WEBSITE_ANDURL_FIELD from '@salesforce/schema/Website_Details__c.Android_URL__c';
import WEBSITE_MERCHANT_PLATFORM from '@salesforce/schema/Website_Details__c.Merchant_Platform__c';

import ADDRESS_DETAIL_OBJECT from '@salesforce/schema/Address_Details__c';
import ADDRESS_OPP_FIELD from '@salesforce/schema/Address_Details__c.Opportunity__c';
import ADDRESS_ACCOUNT_FIELD from '@salesforce/schema/Address_Details__c.Account__c';
import ADDRESS_ADDLINE_FIELD from '@salesforce/schema/Address_Details__c.Address_Line__c';
import ADDRESS_CITY_FIELD from '@salesforce/schema/Address_Details__c.City__c';
import ADDRESS_PINCODE_FIELD from '@salesforce/schema/Address_Details__c.Pincode__c';
import ADDRESS_STATE_FIELD from '@salesforce/schema/Address_Details__c.State__c';
import ADDRESS_COUNTRY_FIELD from '@salesforce/schema/Address_Details__c.Country__c';
import ADDRESS_ACTIVE_FIELD from '@salesforce/schema/Address_Details__c.Active__c';
import ADDRESS_TYPE_FIELD from '@salesforce/schema/Address_Details__c.Type__c';

import BANK_DETAIL_OBJECT from '@salesforce/schema/Bank_Account_Detail__c';
import BANK_DETAIL_ACC_TYPE_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Account_Type__c';
import BANK_DETAIL_ACC_HOLDER_NAME_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Account_Holder_Name__c';
import BANK_DETAIL_ACC_NUMBER_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Account_Number__c';
import BANK_DETAIL_IFSC_FIELD from '@salesforce/schema/Bank_Account_Detail__c.IFSC_Code__c';
import BANK_DETAIL_BANK_NAME_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Bank_Name__c';
import BANK_DETAIL_BRANCH_ADD_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Branch_Address__c';
import BANK_DETAIL_OPP_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Opportunity__c';
import BANK_DETAIL_ACTIVE_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Active__c';
import BANK_DETAIL_STATUS_FIELD from '@salesforce/schema/Bank_Account_Detail__c.Verification_Status__c';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTACT_NAME_FIELD from '@salesforce/schema/Contact.Name';
import CONTACT_ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
import CONTACT_OPP_FIELD from '@salesforce/schema/Contact.Opportunity__c';
import CONTACT_MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import CONTACT_PAN_FIELD from '@salesforce/schema/Contact.PAN__c';
import CONTACT_AUTH_SIGN_FIELD from '@salesforce/schema/Contact.Authorised_Signatory__c';
import CONTACT_ACTIVE_FIELD from '@salesforce/schema/Contact.Active__c';
import CONTACT_CIN_FIELD from '@salesforce/schema/Contact.CIN_Number__c';

import UBO_OBJECT from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c';
import UBO_NAME_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.UBO_Name__c';
import UBO_OWNERSHIP_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.Ownership_num__c';
import UBO_NATIONALITY_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.Nationality__c';
import UBO_OPP_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.Merchant_UUID__c';
import UBO_ACTIVE_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.Active__c';
import UBO_PAN_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.PAN__c';
import UBO_DOB_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.DOB__c';
import UBO_ADDRESS_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.Address_Line__c';
import UBO_PINCODE_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.Pincode__c';
import UBO_STATE_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.State__c';
import UBO_CITY_FIELD from '@salesforce/schema/Ultimate_Beneficiary_Owner_UBO__c.City__c';


import OPP_OBJECT from '@salesforce/schema/Opportunity';
import LEAD_BUSINESS_NAME from '@salesforce/schema/Opportunity.Lead_Business_Name__c';
import BUSINESS_CATEGORY from '@salesforce/schema/Opportunity.BusinessCategory__c';
import SUB_CATEGORY from '@salesforce/schema/Opportunity.Sub_Category__c';
import GST_NUMBER from '@salesforce/schema/Opportunity.GST_Number__c';
import MONTHLY_EXP_SALE from '@salesforce/schema/Opportunity.Monthly_Expected_Sale__c';
import CUST_DEC_PEP from '@salesforce/schema/Opportunity.Customer_Declaration_PEP__c';
import JOCARTA_SYS_ALERT from '@salesforce/schema/Opportunity.Jocata_System_Alerts__c';
import PEP_STATUS from '@salesforce/schema/Opportunity.PEP_Status__c';
import COMMENT from '@salesforce/schema/Opportunity.Comment__c';
import WEBSITE from '@salesforce/schema/Opportunity.Website__c';
import IOS from '@salesforce/schema/Opportunity.iOS_URL__c';
import ANDROID from '@salesforce/schema/Opportunity.Android_URL__c';

import SENIOR_MANAGEMENT_OBJECT from '@salesforce/schema/Senior_Management_Detail__c';
import SNR_MAN_NAME from '@salesforce/schema/Senior_Management_Detail__c.Name';
import SNR_MAN_OPP from '@salesforce/schema/Senior_Management_Detail__c.Opportunity__c';
import SNR_MAN_DESIGNATION from '@salesforce/schema/Senior_Management_Detail__c.Designation__c';
import SNR_MAN_DOB from '@salesforce/schema/Senior_Management_Detail__c.DOB__c';
import SNR_MAN_ACTIVE from '@salesforce/schema/Senior_Management_Detail__c.Active__c';





export default class OfflineOnboardingOpportunityCmp extends NavigationMixin(LightningElement) {
    @api recordId;
    activeWebsite = true;
    activeBank = true;
    activeContact = true;
    authSignatory = true;
    activeUBO = true;
    websiteStatus = 'Verification in Process';
    activeSeniorManagement = true;

    isEditMode = true;

    isFormSubmitted =false;

    isLoading = false;

    //accountId;
    
    websiteList;
    oppAddressList;
    regAddressList;
    bankAccountList;
    contactList;
    uboList;
    oppStatusList;
    websiteId;
    oppAddressId;
    regAddressId;
    bankAccountId;
    contactId;
    uboId;
    oppStatusId;
    seniorMngList;
    seniorMngId;

    selectedMerchantPlatform;
    platformOptions = [];

    isPlatform_AppOnly = false;
    isPlatform_WebOnly = false;
    isPlatform_Both = false;

    isNationalityIndian = true;
    isNationalityNotIndian = false;
    selectedNationality = 'IN';

    ownershipPercentage = '';
    selectedOwnership = 'No';
    ownershipOptions = [{label : 'Yes', value : 'Yes'}, {label : 'No', value : 'No'}]

    objectLabelMap = {
        Website_Details__c : 'Website Detail',
        Address_Details__c : 'Address Detail',
        Bank_Account_Detail__c : 'Bank Account',
        Contact : 'Contact',
        Ultimate_Beneficiary_Owner_UBO__c : 'UBO Detail'
    }

    objectName_1 = WEBSITE_DETAIL_OBJECT;
    //fieldList_1 = [WEBSITE_OPP_FIELD, WEBSITE_STATUS_FIELD, WEBSITE_WBURL_FIELD, WEBSITE_IOSURL_FIELD, WEBSITE_ANDURL_FIELD];
    fieldList_1 = [WEBSITE_STATUS_FIELD, WEBSITE_WBURL_FIELD, WEBSITE_IOSURL_FIELD, WEBSITE_ANDURL_FIELD];
    fieldList_1_v2 = {
        oppField : WEBSITE_OPP_FIELD,
        statusField : WEBSITE_STATUS_FIELD,
        activeField: WEBSITE_ACTIVE_FIELD,
        wbUrlField  : WEBSITE_WBURL_FIELD,
        iosUrlField   : WEBSITE_IOSURL_FIELD,
        andUrlField    : WEBSITE_ANDURL_FIELD,
        merchantPlatField : WEBSITE_MERCHANT_PLATFORM
    }

    objectName_2 = ADDRESS_DETAIL_OBJECT;
    //fieldList_2 = [ADDRESS_OPP_FIELD, ADDRESS_ACCOUNT_FIELD, ADDRESS_ADDLINE_FIELD, ADDRESS_CITY_FIELD, ADDRESS_PINCODE_FIELD, ADDRESS_STATE_FIELD, ADDRESS_COUNTRY_FIELD, ADDRESS_ACTIVE_FIELD, ADDRESS_TYPE_FIELD];
    fieldList_2 = [ADDRESS_ADDLINE_FIELD, ADDRESS_CITY_FIELD, ADDRESS_PINCODE_FIELD, ADDRESS_STATE_FIELD, ADDRESS_COUNTRY_FIELD];
    fieldList_2_v2 = {
        oppField : ADDRESS_OPP_FIELD,
        accountField : ADDRESS_ACCOUNT_FIELD,
        addLineField: ADDRESS_ADDLINE_FIELD,
        cityField  : ADDRESS_CITY_FIELD,
        pincodeField   : ADDRESS_PINCODE_FIELD,
        stateField    : ADDRESS_STATE_FIELD,
        countryField : ADDRESS_COUNTRY_FIELD,
        activeField : ADDRESS_ACTIVE_FIELD,
        addTypeField : ADDRESS_TYPE_FIELD
    }

    //objectName_3 = BANK_DETAIL_OBJECT;
    bankAcc_obj = BANK_DETAIL_OBJECT;
    //fieldList_3 = [BANK_DETAIL_ACC_TYPE_FIELD, BANK_DETAIL_ACC_HOLDER_NAME_FIELD, BANK_DETAIL_ACC_NUMBER_FIELD, BANK_DETAIL_IFSC_FIELD, BANK_DETAIL_BANK_NAME_FIELD, BANK_DETAIL_BRANCH_ADD_FIELD, BANK_DETAIL_OPP_FIELD, BANK_DETAIL_ACTIVE_FIELD];
    fieldList_bank = [BANK_DETAIL_ACC_TYPE_FIELD, BANK_DETAIL_ACC_HOLDER_NAME_FIELD, BANK_DETAIL_ACC_NUMBER_FIELD, BANK_DETAIL_IFSC_FIELD, BANK_DETAIL_BANK_NAME_FIELD, BANK_DETAIL_BRANCH_ADD_FIELD, BANK_DETAIL_STATUS_FIELD];
    fieldList_3_v2 = {
        accType : BANK_DETAIL_ACC_TYPE_FIELD,
        accHolderName : BANK_DETAIL_ACC_HOLDER_NAME_FIELD,
        accNumber : BANK_DETAIL_ACC_NUMBER_FIELD,
        ifscCode : BANK_DETAIL_IFSC_FIELD,
        bankName : BANK_DETAIL_BANK_NAME_FIELD,
        branchAdd : BANK_DETAIL_BRANCH_ADD_FIELD,
        oppField : BANK_DETAIL_OPP_FIELD,
        activeField : BANK_DETAIL_ACTIVE_FIELD
    }

    objectName_4 = CONTACT_OBJECT;
    //fieldList_4 = [CONTACT_NAME_FIELD, CONTACT_ACCOUNT_FIELD, CONTACT_OPP_FIELD, CONTACT_MOBILE_FIELD, CONTACT_EMAIL_FIELD, CONTACT_PAN_FIELD, CONTACT_AUTH_SIGN_FIELD, CONTACT_ACTIVE_FIELD];
    fieldList_4 = [CONTACT_NAME_FIELD, CONTACT_MOBILE_FIELD, CONTACT_EMAIL_FIELD, CONTACT_PAN_FIELD, CONTACT_CIN_FIELD];
    fieldList_4_v2 = {
        nameField : CONTACT_NAME_FIELD,
        accountField : CONTACT_ACCOUNT_FIELD,
        oppField : CONTACT_OPP_FIELD,
        mobileField : CONTACT_MOBILE_FIELD,
        emailField : CONTACT_EMAIL_FIELD,
        panField : CONTACT_PAN_FIELD,
        authSign : CONTACT_AUTH_SIGN_FIELD,
        activeField : CONTACT_ACTIVE_FIELD,
        cinField : CONTACT_CIN_FIELD
    }

    objectName_5 = UBO_OBJECT;
    fieldList_5 = [UBO_NAME_FIELD, UBO_OWNERSHIP_FIELD, UBO_NATIONALITY_FIELD, UBO_OPP_FIELD, UBO_ACTIVE_FIELD];
    fieldList_5_v2 = {
        uboName     : UBO_NAME_FIELD,
        ownership   : UBO_OWNERSHIP_FIELD,
        nationality : UBO_NATIONALITY_FIELD,
        oppField : UBO_OPP_FIELD,
        activeField : UBO_ACTIVE_FIELD,
        panField : UBO_PAN_FIELD,
        dobField : UBO_DOB_FIELD,
        addressField : UBO_ADDRESS_FIELD,
        pincodeField : UBO_PINCODE_FIELD,
        stateField : UBO_STATE_FIELD,
        cityField : UBO_CITY_FIELD
    }

    objectName_6 = OPP_OBJECT;
    fieldList_6 = [LEAD_BUSINESS_NAME, BUSINESS_CATEGORY, SUB_CATEGORY, GST_NUMBER, MONTHLY_EXP_SALE];
    fieldList_6_PEP = [CUST_DEC_PEP, PEP_STATUS, COMMENT];
    fieldList_6_Website = [WEBSITE, IOS, ANDROID];

    
    objectName_7 = SENIOR_MANAGEMENT_OBJECT;
    fieldList_7 = [SNR_MAN_NAME, SNR_MAN_OPP, SNR_MAN_DESIGNATION, SNR_MAN_DOB, SNR_MAN_ACTIVE];
    fieldList_7_v2 = {
        snrName : SNR_MAN_NAME,
        snrOpp : SNR_MAN_OPP,
        snrDesignation : SNR_MAN_DESIGNATION,
        snrDob : SNR_MAN_DOB,
        snrActive : SNR_MAN_ACTIVE
    }

    
    // connectedCallback(){
    //     getRelatedWebsiteDetails({oppId:this.recordId})
    //     .then(data => {
    //         this.websiteList = data;
    //         this.websiteId = this.websiteList[0].Id;
    //         this.error = undefined;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //         this.websiteList = undefined;
    //         this.websiteId = this.websiteList[0].Id;
    //     });

    //     getOperatingAddressDetails({oppId:this.recordId})
    //     .then(data => {
    //         this.oppAddressList = data;
    //         this.oppAddressId = this.oppAddressList[0].Id;
    //         this.error = undefined;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //         this.oppAddressList = data;
    //         this.oppAddressId = this.oppAddressList[0].Id;
    //     });


    // }
    wiredDataWebsite;
    wiredDataOppAdress;
    wiredDataRegAdress;
    wiredDataBank;
    wiredDataContact;
    wiredDataUBO;
    wiredDataSnrMng;

    /************Testing */

    /*connectedCallback() {
        this.loadAllData();
    }

    loadAllData() {
        // Use a single wire adapter for each data load
        Promise.all([
            this.loadWebsiteData(),
            this.loadOperatingAddressData(),
            this.loadRegisteredAddressData(),
            this.loadBankAccountData(),
            this.loadContactData(),
            this.loadUBOData(),
            this.loadOpportunityStatuses(),
            // Add more data loads as needed...
        ])
        .then(() => {
            // All data loads are complete
            this.isLoading = false;
        })
        .catch(error => {
            console.error(error);
            this.isLoading = false; // Handle errors gracefully
        });
    }

    loadWebsiteData() {
        return getRelatedWebsiteDetails({ oppId: this.recordId })
            .then(data => {
                this.websiteList = data;
                this.websiteId = this.websiteList[0].Id;
            });
    }
*/

    /********************* */
    @wire(getRelatedWebsiteDetails, {oppId:'$recordId'})
    //websiteDetailExtract({data, error}){
    websiteDetailExtract(result){   
        this.wiredDataWebsite = result;
        const { data, error } = result;

        if(data && data.length > 0){
            
            this.websiteList = data;
            this.websiteId = this.websiteList[0].Id;
            console.log(`result here >>>>>>>>`+JSON.stringify(this.websiteList));
        }
        if(error){
            console.error(error);
        }
    }

    @wire(getOperatingAddressDetails, {oppId:'$recordId'})
    // operatingAddressExtract({data, error}){ //---> Earlier this and the below commented line was present, which was followed by this.oppAddressList = data;
    //     if(data && data.length > 0){
        operatingAddressExtract(result){   
            this.wiredDataOppAdress = result;
            const { data, error } = result;

            if(data && data.length > 0){
            this.oppAddressList = data;
            this.oppAddressId = this.oppAddressList[0].Id;
            console.log(`result here >>>>>>>>`+JSON.stringify(this.oppAddressList));
        }
        if(error){
            console.error(error);
        }
    }

    @wire(getRegisteredAddressDetails, {oppId:'$recordId'})
    //registeredAddressExtract({data, error}){
        registeredAddressExtract(result){   
            this.wiredDataRegAdress = result;
            const { data, error } = result;
        if(data && data.length > 0){
            
            this.regAddressList = data;
            this.regAddressId = this.regAddressList[0].Id;
            console.log(`result here >>>>>>>>`+JSON.stringify(this.regAddressList));
        }
        if(error){
            console.error(error);
        }
    }

    @wire(getBankAccountDetails, {oppId:'$recordId'})
    //bankDetailExtract({data, error}){
        bankDetailExtract(result){   
            this.wiredDataBank = result;
            const { data, error } = result;
        if(data && data.length > 0){
            
            this.bankAccountList = data;
            this.bankAccountId = this.bankAccountList[0].Id;
            console.log(`result here >>>>>>>>`+JSON.stringify(this.bankAccountList));
        }
        if(error){
            console.error(error);
        }
    }

    
    @wire(getContactDetails, {oppId:'$recordId'})
    //contactExtract({data, error}){
        contactExtract(result){   
            this.wiredDataContact = result;
            const { data, error } = result;
        if(data && data.length > 0){
            
            this.contactList = data;
            this.contactId = this.contactList[0].Id;
            console.log(`result here >>>>>>>>`+JSON.stringify(this.contactList));
        }
        if(error){
            console.error(error);
        }
    }

    // @wire(getWrapperData, {oppId: '$recordId'})
    // wiredData({data, error}){
    //     //const {data, error} = result;
    //     if(data){
    //         console.log('data::::',data);
    //         // const {contact} = conData;
    //         // const {bank} = bankData;
    //         if(data && data.length > 0){
    //             this.contactListNew = { ...data.Contact };
    //             this.contactId = this.contactListNew[0].Id;

    //             this.bankAccountListNew = { ...data.Bank_Account_Detail__c };
    //             this.bankAccountId = this.bankAccountListNew[0].Id;

    //             console.log('contactListNew::'+contactListNew);
    //             console.log('bankAccountListNew::'+bankAccountListNew);
    //         }
    //         // if(bankData && bankData.length > 0){
    //         //     this.bankAccountListNew = data;
    //         //     this.bankAccountId = this.bankAccountListNew[0].Id;
    //         // }

    //     }
    //     if(error){
    //         console.error(error);
    //     }
    // }
        

    


    @wire(getUBODetails, {oppId:'$recordId'})
    //uboExtract({data, error}){
        uboExtract(result){   
            this.wiredDataUBO = result;
            const { data, error } = result;
        if(data && data.length > 0){
            
            this.uboList = data;
            this.uboId = this.uboList[0].Id;
            console.log(`result here >>>>>>>>`+JSON.stringify(this.uboList));
        }
        if(error){
            console.error(error);
        }
    }

    

    @wire(getOpportunityStatuses, {oppId:'$recordId'})
    oppStatusesExtract({data, error}){
        // bankDetailExtract(result){   
        //     this.wiredData = result;
        //     const { data, error } = result;
        if(data && data.length > 0){
            
            this.oppStatusList = data;
            this.oppStatusId = this.oppStatusList[0].Id;
            this.oppEntity = this.oppStatusList[0].Business_Entity_Formula__c;
            this.setOwnershipPecent();
            console.log(`result here >>>>>>>>`+JSON.stringify(this.oppStatusList));
        }
        if(error){
            console.error(error);
        }
    }

    @wire(getSeniorManagement, {oppId:'$recordId'})
    seniorManagementExtract(result){   
        this.wiredDataSnrMng = result;
        const { data, error } = result;
    if(data && data.length > 0){
        
        this.seniorMngList = data;
        this.seniorMngId = this.seniorMngList[0].Id;
        //console.log(`result here >>>>>>>>`+JSON.stringify(this.seniorMngList));
    }
    if(error){
        console.error(error);
    }
}


    get isUBOEntity(){
        return (this.oppEntity === 'Partnership' || this.oppEntity === 'Private Limited' || this.oppEntity === 'Public Limited' || this.oppEntity === 'LLP' || this.oppEntity === 'Society' || this.oppEntity === 'Trust') ;
    }

    setOwnershipPecent(){
        this.ownershipPercentage = this.oppEntity === 'Partnership' ? '15' : this.oppEntity === 'Private Limited' ? '10' : this.oppEntity === 'Public Limited' ? '10' : this.oppEntity === 'LLP' ? '15' : this.oppEntity === 'Society' ? '10' : '10';
    }

    // get isCINRequired(){
    //     return (this.oppEntity === 'Private Limited' || this.oppEntity === 'Public Limited' || this.oppEntity === 'One Person Company' || this.oppEntity === 'LLP');
    // }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [OPP_ACCOUNT_FIELD]
    })
    oppAccountData;

    get accountId(){
        return getFieldValue(this.oppAccountData.data, OPP_ACCOUNT_FIELD);
    }

    // refreshRecordPage() {
    //     location.reload();
    // }

    handleSuccess(event){
        //this.isLoading = false;
        const objectApiName = event.detail.apiName;
        console.log(event.detail.id);

        let objLabel = this.objectLabelMap[objectApiName] || 'Record';

        let toastTitle = 'Success';
        //let toastMessage = `The ${objectApiName} has been created`;
        let toastMessage = `The ${objLabel} has been created`;

        const toastEvent = new ShowToastEvent({
            title : toastTitle,
            message : toastMessage,
            variant : "success"
        })
        this.dispatchEvent(toastEvent);
        
        //this.refreshRecordPage();
        refreshApex(this.wiredDataWebsite);
        refreshApex(this.wiredDataOppAdress);
        refreshApex(this.wiredDataRegAdress);
        refreshApex(this.wiredDataBank);
        refreshApex(this.wiredDataContact);
        refreshApex(this.wiredDataUBO);
        refreshApex(this.wiredDataSnrMng);
            
        
        
    }

    handlePlatformChange(event){
        const selectedPlatform = event.detail.value;
        this.updatePlatform(selectedPlatform);
    }

    updatePlatform(selectedPlatform){
        this.isPlatform_AppOnly = selectedPlatform === 'App Only';
        this.isPlatform_WebOnly = selectedPlatform === 'Web Only';
        this.isPlatform_Both = selectedPlatform === 'Both';
    }

    handleNationalityChangeUBO(event){
        this.selectedNationality = event.detail.value;
       //const selectedNationality  = event.detail.value;
        //c/agreementTabComponentthis.updateNationality(selectedNationality);
        this.updateNationality();
    }

    updateNationality(){
        this.isNationalityIndian = this.selectedNationality === 'IN';
        this.isNationalityNotIndian = this.selectedNationality !== 'IN';
    }
    
    // updateNationality(selectedNationality){
    //     this.isNationalityIndian = selectedNationality === 'IN';
    //     this.isNationalityNotIndian = selectedNationality !== 'IN';
    // }

    connectedCallback(){
        this.updateNationality();
    }

    handleOwnerhipChange(event){
        this.selectedOwnership = event.detail.value;
    }
    get selectedOwnershipYes(){
        return this.selectedOwnership === 'Yes';
    }

    globalNavigator(event){
        const dataLabel = event.target.dataset.label;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            //type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                relationshipApiName: dataLabel,
                actionName: 'view'
            }
        });
    }

    // globalNavigator(relatedListApiName){
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordRelationshipPage',
    //         //type: 'standard__recordPage',
    //         attributes: {
    //             recordId: this.recordId,
    //             objectApiName: 'Opportunity',
    //             relationshipApiName: relatedListApiName,
    //             actionName: 'view'
    //         }
    //     });
    // }

   
    // navigateToUBORecords(){
    //     this.globalNavigator('Ultimate_Beneficiary_Owners_UBO__r');
    // }
    
    
    // navigateToMerchantStatusDetail() {
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordRelationshipPage',
    //         //type: 'standard__recordPage',
    //         attributes: {
    //             recordId: this.recordId,
    //             objectApiName: 'Opportunity',
    //             relationshipApiName: 'Merchant_Status_Details__r',
    //             actionName: 'view'
    //         }
    //     });
    // }

    

    



    


    // handleSubmit(event){
    //     this.isLoading = true;
    // }

    // handleEdit(){
    //     this.isEditMode = true;
    // }

    // handleCancel() {
    //     this.isEditMode = false;
    // }
}