public with sharing class OfflineOnboardingForm_Controller {
    public OfflineOnboardingForm_Controller() {

    }
    @AuraEnabled(cacheable=true)
    public static fetchMerchantRecordDataWrapper getMerchantRecordData(String record_Id){
        fetchMerchantRecordDataWrapper wrap = new fetchMerchantRecordDataWrapper();
        List<Schema.FieldSetMember> lstOfFieldMember = SObjectType.Lead.FieldSets.OfflineOnboardingLeadFields.getFields();
        //ID recordId = '00Q0p000001Wsj3EAC';
        String query = 'SELECT ';
		for(Schema.FieldSetMember f : lstOfFieldMember) {
			query += f.getFieldPath() + ', ';
		}
        query += 'Business_Entity__r.Name,Product__r.Name,Partner__r.Name,BusinessCategory__r.Name,Sub_Category__r.Name, ';
		query += 'Id, Name FROM Lead WHERE Id =: record_Id LIMIT 1';
        List<Lead> leadList = Database.query(query);
        List<Contact> contactList = new List<Contact>();
        List<Address_Details__c> addressList = new List<Address_Details__c>();
        List<Bank_Account_Detail__c> bankDetailsList = new List<Bank_Account_Detail__c>();
        contactList = [SELECT Id,FirstName,LastName,MobilePhone,PAN__c,Birthdate,Lead__c,Authorised_Signatory__c,Email FROM Contact Where Lead__c =: record_Id AND Authorised_Signatory__c = true LIMIT 2];	
        addressList = [SELECT Id, City__c,State__c,Country__c,Pincode__c,Address_Line__c,Type__c,Lead__c,Opportunity__c FROM Address_Details__c Where Lead__c =:record_Id AND Opportunity__c = null  LIMIT 2];
        bankDetailsList = [SELECT id,Account_Number__c,Account_Holder_Name__c,Account_Type__c,Bank_Name__c,Branch__c,IFSC_Code__c,Branch_Address__c,Lead__c FROM Bank_Account_Detail__c Where Lead__c=: record_Id];
        if(leadList.size()>0){
            wrap.leadObj = leadList[0];
        }
        if(bankDetailsList.size()>0){
            wrap.bankAccountObj = bankDetailsList[0];
        }
        if(addressList.size()>0){
            wrap.addressDetailsObj = addressList;
        }
        if(contactList.size()>0){
            wrap.contactObj = contactList;
        }
        if(leadList[0].Business_Entity__r.Name != null){
            wrap.businessEntity = leadList[0].Business_Entity__r.Name;
        }
        if(leadList[0].Product__r.Name != null){
            wrap.product = leadList[0].Product__r.Name;
        }
        if(leadList[0].Partner__r.Name != null){
            wrap.partner = leadList[0].Partner__r.Name;
        }
        if(leadList[0].BusinessCategory__r.Name != null){
            wrap.businessCategory = leadList[0].BusinessCategory__r.Name;
        }
        if(leadList[0].Sub_Category__r.Name != null){
            wrap.subCategory = leadList[0].Sub_Category__r.Name;
        }
        return wrap;

    }
    @AuraEnabled(cacheable=true)
    public static List < merchantDetailWrapper > fetchPanNumber(String data, String fieldName){
        String searchData = data+'%';
        list < merchantDetailWrapper > objWrapper = new list < merchantDetailWrapper > ();
        List<Account> accountList = new List<Account>();
        Account accObj = new Account();
        String legalName = '';
        if(fieldName == 'PanNumber'){
            accountList = [SELECT Id,Name,PAN_Number__c,Legal_Name__c FROM Account Where PAN_Number__c Like: searchData LIMIT 100];
        }else if(fieldName == 'LegalName'){
            accountList = [SELECT Id,Name,PAN_Number__c,Legal_Name__c FROM Account Where Legal_Name__c Like: searchData LIMIT 100];
        }
        if(accountList.size()>0){
            for(Account ac: accountList){
                merchantDetailWrapper  wrap = new merchantDetailWrapper();
                if(String.isNotBlank(ac.Legal_Name__c)){
                    wrap.legalName = ac.Legal_Name__c ;
                }
                if(String.isNotBlank(ac.PAN_Number__c )){
                    wrap.PanNumber = ac.PAN_Number__c;
                }
                objWrapper.add(wrap);
            }
        }
        System.debug('wrap'+objWrapper);
        if(objWrapper.size()>0){
            return objWrapper;
        }else {
            return null;
        }
    }

    

    @AuraEnabled(cacheable = true)
    public static List < FatchValueWrapper > fetchPicklistValue(sObject objInfo, string picklistFieldApi) {
        System.debug('objInfo'+objInfo);
        System.debug('picklistFieldApi'+picklistFieldApi);
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
        // Create a list of wrapper to store picklist value/lable
        list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > ();
        for (Schema.PicklistEntry a: values) {
            if(picklistFieldApi == 'Sub_Status__c'){
                if(a.getLabel() == 'Engaged' || a.getLabel() == 'Proposal Shared' || a.getLabel() == 'Decision maker connected' || a.getLabel() == 'Commercial Discussion' || a.getLabel() == 'Commercial Accepted' || a.getLabel() == 'Document Pending' || a.getLabel() == 'Drop' || a.getLabel() == 'Ticket raise on Optimus'){
                    FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                    oFatchValueWrapper.label = a.getLabel();
                    oFatchValueWrapper.value = a.getValue();
                    objWrapper.add(oFatchValueWrapper);
                }
                
            }else{
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.label = a.getLabel();
                oFatchValueWrapper.value = a.getValue();
                objWrapper.add(oFatchValueWrapper);
            }
            
        }
        System.debug('objWrapper'+objWrapper);
        return objWrapper;
    }

    /*@AuraEnabled(cacheable = true)
    public static List < FatchValueWrapper > fetchPicklistValue(sObject objInfo, string picklistFieldApi) {
        System.debug('objInfo'+objInfo);
        System.debug('picklistFieldApi'+picklistFieldApi);
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
        // Create a list of wrapper to store picklist value/lable
        list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > ();
        for (Schema.PicklistEntry a: values) {
            if(picklistFieldApi == 'Sub_Status__c'){
                if(a.getLabel() == 'Engaged' || a.getLabel() == 'Proposal Shared' || a.getLabel() == 'Decision maker connected' || a.getLabel() == 'Commercial Discussion' || a.getLabel() == 'Commercial Accepted' || a.getLabel() == 'Document Pending' || a.getLabel() == 'Drop' || a.getLabel() == 'Ticket raise on Optimus'){
                    FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                    oFatchValueWrapper.label = a.getLabel();
                    oFatchValueWrapper.value = a.getValue();
                    objWrapper.add(oFatchValueWrapper);
                }
                
            }else{
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.label = a.getLabel();
                oFatchValueWrapper.value = a.getValue();
                objWrapper.add(oFatchValueWrapper);
            }
            
        }
        System.debug('objWrapper'+objWrapper);
        return objWrapper;
    }*/
    
    @AuraEnabled
    public static leadDatawrapper saveLeadData(String leadObj){
        leadDatawrapper wrap = new leadDatawrapper();
        try{
            Id offlineOnboardingrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Offline Onboarding').getRecordTypeId();
            Lead lead_obj = (Lead)JSON.deserialize(leadObj,Lead.class);
            System.debug('lead_obj'+lead_obj);
            if(lead_obj.id == null){
                lead_obj.Identifier__c = generateIdentifier();
            }
            if(lead_obj != null){
                lead_obj.recordTypeId = offlineOnboardingrecordTypeId;
                
                upsert lead_obj;
            }
            System.debug('lead_obj2'+lead_obj);
            if(lead_obj.Id != null){
                String leadId = lead_obj.Id;
                wrap.leadObj = lead_obj;
                
                List<Lead> leadList = [SELECT Id,Business_Entity__r.Name,Product__r.Name,Partner__r.Name,BusinessCategory__r.Name,Sub_Category__r.Name FROM Lead where Id =:leadId LIMIT 1];
                System.debug('leadList'+leadList);
                if(leadList[0].Business_Entity__r.Name != null){
                    wrap.businessEntity = leadList[0].Business_Entity__r.Name;
                }
                if(leadList[0].Product__r.Name != null){
                    wrap.product = leadList[0].Product__r.Name;
                }
                if(leadList[0].Partner__r.Name != null){
                    wrap.partner = leadList[0].Partner__r.Name;
                }
                if(leadList[0].BusinessCategory__r.Name != null){
                    wrap.businessCategory = leadList[0].BusinessCategory__r.Name;
                }
                if(leadList[0].Sub_Category__r.Name != null){
                    wrap.subCategory = leadList[0].Sub_Category__r.Name;
                }
                return wrap;
            }else{
                return null;
            }
        }catch(Exception ex){
            wrap.errorMsg = ex.getMessage();
            System.debug('ERROR: '+ex.getLineNumber());
            System.debug('Line No: '+ex.getMessage());
            return wrap;
        }
    }
    @AuraEnabled
    public static contactAndAddressDatawrapper saveAddressData(String addressList){
        contactAndAddressDatawrapper wrap = new contactAndAddressDatawrapper();
        try{
            List<Address_Details__c> address_List = new List<Address_Details__c>();
            address_List = (List<Address_Details__c>)JSON.deserialize(addressList,List<Address_Details__c>.class);
            System.debug('address_List'+address_List);
            System.debug('address_List'+address_List.size());
            if(address_List.size()>0){
                upsert address_List;
            }
            System.debug('address_List updated '+address_List);
            if(address_List[0].Id != null  && address_List[1].Id != null){
                wrap.addressDetailsObj = address_List;
                return wrap;
            }else{
                return null;
            }
        }catch(Exception ex){
            wrap.errorMsg = ex.getMessage();
            System.debug('ERROR: '+ex.getLineNumber());
            System.debug('Line No: '+ex.getMessage());
            return wrap;
        }
    }
    @AuraEnabled
    public static leadDatawrapper saveBankDetailsData(String bankAccount_Obj){
        leadDatawrapper wrap = new leadDatawrapper();
        try{
            Bank_Account_Detail__c bankObj= new Bank_Account_Detail__c();
            bankObj = (Bank_Account_Detail__c)JSON.deserialize(bankAccount_Obj,Bank_Account_Detail__c.class);
            bankObj.Active__c = true;
            upsert bankObj;
            System.debug('bankObj'+bankObj);
            if(bankObj.Id != null){
                wrap.bankdObj = bankObj;
                return wrap;
            }else{
                return null;
            }
        }catch(Exception ex){
            wrap.errorMsg = ex.getMessage();
            System.debug('ERROR: '+ex.getLineNumber());
            System.debug('Line No: '+ex.getMessage());
            return wrap;
        }
        
    }

    @AuraEnabled
    public static contactAndAddressDatawrapper saveContactDetailsData(String contactObj1,String contactObj2){
        contactAndAddressDatawrapper wrap = new contactAndAddressDatawrapper();
        try{
            Contact contact_Obj1= new Contact();
            Contact contact_Obj2= new Contact();
            contact_Obj1 = (Contact)JSON.deserialize(contactObj1,Contact.class);
            contact_Obj2 = (Contact)JSON.deserialize(contactObj2,Contact.class);
            System.debug('contact_Obj1: '+contact_Obj1);
            System.debug('contact_Obj2'+contact_Obj2);
            if(contact_Obj1.LastName != null){
                contact_Obj1.Authorised_Signatory__c = true;
                upsert contact_Obj1;
            }
            if(contact_Obj2.LastName != null){
                contact_Obj2.Authorised_Signatory__c= true;
                upsert contact_Obj2;
            }
            if(contact_Obj1.Id != null && contact_Obj2.Id != null){
                wrap.contactObj1 = contact_Obj1;
                wrap.contactObj2 = contact_Obj2;
                return wrap;
            }else if(contact_Obj1.Id != null){
                wrap.contactObj1 = contact_Obj1;
                return wrap;
            }else if(contact_Obj2.Id != null){
                wrap.contactObj2 = contact_Obj2;
                return wrap;
            }
            else{
                return null;
            }
        }catch(Exception ex){
            wrap.errorMsg = ex.getMessage();
            System.debug('ERROR: '+ex.getLineNumber());
            System.debug('Line No: '+ex.getMessage());
            return wrap;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FatchValueWrapper> fetchBusinessEntity(){
        List<FatchValueWrapper> objWrapper = new List<FatchValueWrapper>();
        List<Entity__c> entityList = new List<Entity__c>();
        entityList = [SELECT Id, Name,Active__c FROM Entity__c Where Active__c = true LIMIT 2000];
        if(entityList.size() >0){
            for(Entity__c entity: entityList){
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.value = entity.Id;
                oFatchValueWrapper.label = entity.Name;
                objWrapper.add(oFatchValueWrapper);
            }
        }
        if(objWrapper.size()>0){
            return objWrapper;
        }else{
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FatchValueWrapper> fetchPartner(String temp_subSource){
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId(); 
        List<FatchValueWrapper> objWrapper = new List<FatchValueWrapper>();
        List<Opportunity> partnerList = new List<Opportunity>();
        partnerList = [SELECT Id, Name,RecordTypeId,Lead_Type__c,Prod_Merchant_Id__c,LeadSource FROM Opportunity Where RecordTypeId =: recordTypeId AND Active__c = true AND Lead_Type__c = 'Partner' AND Prod_Merchant_Id__c = null AND LeadSource = 'Partner' AND Sub_Source__c =: temp_subSource LIMIT 10000];
        if(partnerList.size() >0){
            for(Opportunity opp: partnerList){
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.value = opp.Id;
                oFatchValueWrapper.label = opp.Name;
                objWrapper.add(oFatchValueWrapper);
            }
        }
        if(objWrapper.size()>0){
            return objWrapper;
        }else{
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List < FatchValueWrapper > fetch_Partner(String data){
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId(); 
        String searchData = data+'%';
        list < FatchValueWrapper > objWrapper = new list < FatchValueWrapper > ();
        List<Opportunity> partnerList = new List<Opportunity>();
        //Account accObj = new Account();
        String legalName = '';
        
        partnerList = [SELECT Id, Name,RecordTypeId,Lead_Type__c,Prod_Merchant_Id__c,LeadSource FROM Opportunity Where RecordTypeId =: recordTypeId AND Active__c = true AND Lead_Type__c = 'Partner' AND Prod_Merchant_Id__c = null AND LeadSource = 'Partner' AND Name Like: searchData LIMIT 10000];
        
        if(partnerList.size()>0){
            for(Opportunity op: partnerList){
                FatchValueWrapper  wrap = new FatchValueWrapper();
                wrap.label = op.Name;
                wrap.value = op.id;
                /*if(String.isNotBlank(ac.Legal_Name__c)){
                    wrap.legalName = ac.Legal_Name__c ;
                }
                if(String.isNotBlank(ac.PAN_Number__c )){
                    wrap.PanNumber = ac.PAN_Number__c;
                }*/
                objWrapper.add(wrap);
            }
        }
        System.debug('wrap'+objWrapper);
        if(objWrapper.size()>0){
            return objWrapper;
        }else {
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String fetchProduct(){
        String productId = '';
        //List <FatchValueWrapper> objWrapper = new List<FatchValueWrapper>();
        List<Product__c> productList = new List<Product__c>();
        productList = [SELECT Id, Name,Active__c FROM Product__c Where Active__c = true AND Name = 'PayU Biz'];
        if(productList.size() >0){
            for(Product__c prod: productList){
                if(prod.Name == 'PayU Biz'){
                    productId = prod.Id;
                }
            }
        }
        if(String.isNotBlank(productId)){
            return productId;
        }else{
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<FatchValueWrapper> fetchBusinessCategory(){
        List<FatchValueWrapper> objWrapper = new List<FatchValueWrapper>();
        List<Business_Category__c> businessCategoryList = new List<Business_Category__c>();
        businessCategoryList = [SELECT Id, Name,Active__c FROM Business_Category__c Where Active__c = true LIMIT 2000];
        if(businessCategoryList.size() >0){
            for(Business_Category__c bCategory: businessCategoryList){
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.value = bCategory.Id;
                oFatchValueWrapper.label = bCategory.Name;
                objWrapper.add(oFatchValueWrapper);
            }
        }
        if(objWrapper.size()>0){
            return objWrapper;
        }else{
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FatchValueWrapper> fetchSubCategory(){
        List<FatchValueWrapper> objWrapper = new List<FatchValueWrapper>();
        List<Sub_Category__c> subCategoryList = new List<Sub_Category__c>();
        subCategoryList = [SELECT Id, Name, Active__c FROM Sub_Category__c Where Active__c = true LIMIT 2000];
        if(subCategoryList.size() >0){
            for(Sub_Category__c subCategory: subCategoryList){
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.value = subCategory.Id;
                oFatchValueWrapper.label = subCategory.Name;
                objWrapper.add(oFatchValueWrapper);
            }
        }
        if(objWrapper.size()>0){
            return objWrapper;
        }else{
            return null;
        }
    }
    public static String generateIdentifier(){
        Blob blobObj = Crypto.GenerateAESKey(128);
        String strEncodingUtil = EncodingUtil.ConvertTohex(blobObj);
        String strUUID = strEncodingUtil.SubString(0,4)+ '-' + strEncodingUtil.SubString(4,8) + '-' + strEncodingUtil.SubString(8,16) + '-' + strEncodingUtil.SubString(16,20) + '-' + strEncodingUtil.substring(20);
        return strUUID;
    }
   // wrapper class 
    public with sharing class leadDatawrapper {
        @auraEnabled public Lead leadObj {get;set;}
        @auraEnabled public Bank_Account_Detail__c bankdObj {get;set;}
        @auraEnabled public string product {get;set;}
        @auraEnabled public string partner {get;set;}
        @auraEnabled public string businessEntity {get;set;}
        @auraEnabled public string businessCategory {get;set;}
        @auraEnabled public string subCategory {get;set;}
        @auraEnabled public string errorMsg {get;set;}
    }

    public with sharing class contactAndAddressDatawrapper {
        @auraEnabled public Contact contactObj1 {get;set;}
        @auraEnabled public Contact contactObj2 {get;set;}
        @auraEnabled public List<Address_Details__c> addressDetailsObj {get;set;}
        @auraEnabled public string errorMsg {get;set;}
    }

   // wrapper class for lwc combobox
    public with sharing class FatchValueWrapper {
        @auraEnabled public string label {get;set;}
        @auraEnabled public string value {get;set;}
    }

    public with sharing class merchantDetailWrapper{
        @AuraEnabled
        public String legalName {get;set;}
        @AuraEnabled
        public String PanNumber {get;set;}
        @AuraEnabled
        public String error {get;set;}
    }
    // it will hold already filled data when we open already created lead from search box.
    public with sharing class fetchMerchantRecordDataWrapper {
        @auraEnabled public Lead leadObj {get;set;}
        @auraEnabled public Bank_Account_Detail__c bankAccountObj {get;set;}
        @auraEnabled public List<Address_Details__c> addressDetailsObj {get;set;}
        @auraEnabled public List<Contact> contactObj {get;set;}
        @auraEnabled public string product {get;set;}
        @auraEnabled public string partner {get;set;}
        @auraEnabled public string businessEntity {get;set;}
        @auraEnabled public string businessCategory {get;set;}
        @auraEnabled public string subCategory {get;set;}
    }

    
    
}