@isTest
public class CommonDataTracker{
    public static User insertUser(string profileId){
        user userObj = new user();
        userObj.profileId = profileId;
        userObj.username = 'newUser@yah.com';
        userObj.email = 'pb@ff.com';
        userObj.emailencodingkey = 'UTF-8';
        userObj.localesidkey = 'en_US';
        userObj.languagelocalekey = 'en_US';
        userObj.timezonesidkey = 'America/Los_Angeles';
        userObj.alias='nuser';
        userObj.lastname = 'User Last Name';        
        return userObj;
    }
    
    public static User insertPartnerUser(string profileId, contact conObj){
        user userObj = new user();
        userObj.profileId = profileId;
        userObj.username = 'newUser+9912749@yahoo.com';
        userObj.email = 'pbbabww@ffas.com';
        userObj.emailencodingkey = 'UTF-8';
        userObj.localesidkey = 'en_US';
        userObj.languagelocalekey = 'en_US';
        userObj.timezonesidkey = 'America/Los_Angeles';
        userObj.alias='nuser';
        userObj.lastname = 'Partner User';
        userObj.ContactId = conObj.id;
        return userObj;
    }

    public static Lead insertLead(){
        Lead objLead = new Lead();
        objLead.LastName = 'Test Lead';
        objLead.Company = 'saasfocus';
        objLead.Email = 'uma.shankar@saasforce.com';
        return objLead;                                      
    }
    
    public static Lead insertLead(Product__c prodObj, Business_Category__c businessCateObj, Sub_Category__c subCateObj, Entity__c entityObj){
        Lead leadObj = new Lead();
        leadObj.Legal_Name__c = 'Leajhgjljal8ysu';
        leadObj.MobilePhone = '9986453612';
        leadObj.PAN_Number__c = 'FTHES9863E';
        leadObj.PAN_Holder_Name__c = 'Saasforcee';
        leadObj.Monthly_Expected_Sale__c = 9;
        leadObj.Delivery_Duration__c = 5;
        leadObj.Transaction_Facility_Required__c = 'Domestic';
        leadObj.FirstName = 'SFT';
        leadObj.LastName = 'TSF';
        leadObj.Company = 'Manav Associates';
        leadObj.Status = 'New'; 
        leadObj.Sub_Status__c = 'Not Contacted';        
        leadObj.Website__c = 'www.google.com';
        leadObj.GST_Number__c = '19AAKCS3053N1ZT';
        leadObj.Lead_Type__c = 'Merchant';
        leadObj.Merchant_Id__c = 8172371;
        leadObj.Business_Entity__c = (entityObj != null && entityObj.Id != null ) ? entityObj.Id : null;
        leadObj.BusinessCategory__c = (businessCateObj != null && businessCateObj.Id != null ) ? businessCateObj.Id : null;
        leadObj.Product__c = prodObj.Id;
        leadObj.Sub_Category__c = (subCateObj != null && subCateObj.Id != null ) ? subCateObj.Id : null;
        return leadObj;
    }
    
    @TestVisible virtual PayloadActMap__mdt[] getPayLoadActMetadata() {
        return [SELECT JsonMap__c FROM PayloadActMap__mdt WHERE developername = 'KYC_For_Case'];
    }
    
    public static Account insertAccount(String strName, String strLegalName, String strPanNum) {
        Account AccountObj = new Account();
        AccountObj.Name = strName;
        AccountObj.PAN_Number__c = strPanNum;
        AccountObj.Legal_Name__c = strLegalName;
        AccountObj.PAN_Holder_Name__c = 'Pan Holder';
        return AccountObj;
    }
    
    public static Contact insertContact(Account AccObj){
        Contact contactObj = new Contact();        
        contactObj.LastName = 'Test Lead';
        contactObj.AccountId = AccObj.id;
        return contactObj;                                      
    } 
    
    public static campaign insertCampaign(){
        campaign campaignObj = new campaign();        
        campaignObj.Name = 'Test campaign';
        return campaignObj;                                      
    } 
    
    public static campaignMember insertCampaignMember(Campaign campObj, Lead leadObj, Contact conObj){
        campaignMember objCampaignMember = new campaignMember();        
        objCampaignMember.campaignID = campObj.id;
        objCampaignMember.leadID = leadObj.id;
        objCampaignMember.contactID = conObj.id;
        objCampaignMember.status = 'sent';
        return objCampaignMember;                                      
    } 
    
    public static Opportunity insertOpportunity(Account AccObj){
        Opportunity OpportunityObj = new Opportunity();        
        OpportunityObj.Name = 'test opportunity';
        OpportunityObj.AccountId = AccObj.Id;
        OpportunityObj.StageName = 'Qualified';
        OpportunityObj.CloseDate = date.today().addDays(20); 
        OpportunityObj.Sub_Source__c = 'Chat';
        OpportunityObj.Risk_Level__c = 'Medium';
        OpportunityObj.Maintenance_Status__c = 'OLD MID';
        OpportunityObj.Risk_Type_Multi_Select__c= '	Website URL';	
        OpportunityObj.Risk_Comment__c= 'Test';
        return OpportunityObj;                                      
    } 
    
    public static Product2 insertProduct(){
        Product2 productObj = new Product2();        
        productObj.Name = 'Equipment-Type C';
        productObj.Family = 'Equipment';
        return productObj;                                      
    } 
    
    public static PricebookEntry insertStandardPricebookEntry(product2 prodObj, Id pricebookId){
        PricebookEntry PricebookEntryObj = new PricebookEntry();        
        PricebookEntryObj.Pricebook2Id = pricebookId;
        PricebookEntryObj.Product2Id = prodObj.Id;
        PricebookEntryObj.UnitPrice = 10000;
        PricebookEntryObj.IsActive = true;
        return PricebookEntryObj;
    }
    
    public static PricebookEntry insertCustomPricebookEntry(product2 prodObj, Id pricebookId){
        PricebookEntry PricebookEntryObj = new PricebookEntry();        
        PricebookEntryObj.Pricebook2Id = pricebookId;
        PricebookEntryObj.Product2Id = prodObj.Id;
        PricebookEntryObj.UnitPrice = 10000;
        PricebookEntryObj.IsActive = true;
        return PricebookEntryObj;
    }
    
    public static OpportunityLineItem insertOpportunityLineItem(Opportunity oppObj, PricebookEntry standardPricebook) {
        OpportunityLineItem OpportunityLineItemObj = new OpportunityLineItem();        
        OpportunityLineItemObj.OpportunityId = oppObj.Id;
        OpportunityLineItemObj.PricebookEntryId = standardPricebook.id;
        OpportunityLineItemObj.Discount = 0;
        OpportunityLineItemObj.UnitPrice = 500;
        OpportunityLineItemObj.Quantity = 1;
        return OpportunityLineItemObj;
    }
    
    public static Pricebook2 insertPricebook2(){
        Pricebook2 Pricebook2Obj = new Pricebook2();
        Pricebook2Obj.Name='Custom Pricebook';
        Pricebook2Obj.isActive=true;
        return Pricebook2Obj;
    }
    
    public static Quote insertQuote(Opportunity OppObj){
        Quote quoteObj = new Quote();
        quoteObj.OpportunityId = OppObj.id;
        QuoteObj.Name = 'Quote-' + OppObj.name;
        QuoteObj.Status = 'Draft';
        QuoteObj.pricebook2Id = OppObj.pricebook2Id;
        QuoteObj.Email = 'uma.shankar@saasfocus.com';
        return quoteObj;
    }
    
    public static Business_Category__c insertBusinessCategory(String strName, boolean bolBanned)
    {
        Business_Category__c businessCategoryObj = new Business_Category__c();
        businessCategoryObj.Name = strName;
        businessCategoryObj.Banned__c = bolBanned;
        businessCategoryObj.Active__c = true;
        return businessCategoryObj ;
    }
    
    public static Sub_Category__c insertSubCategory(String strName, boolean bolBanned)
    {
        Sub_Category__c subCategoryObj = new Sub_Category__c();
        subCategoryObj.Name = strName; 
        subCategoryObj.Banned__c = bolBanned;
        return subCategoryObj ;
    }
    
    public static Trigger_Switch__c insertTriggerSwitch(String strTriggerName, boolean bolSwitch)
    {
        Trigger_Switch__c triggerSwitchObj = new Trigger_Switch__c();
        triggerSwitchObj.Name = strTriggerName; 
        triggerSwitchObj.Active__c = bolSwitch;
        return triggerSwitchObj ;
    }   
        
    public static Website_Page__c insertWebsitePage(string strName, boolean isApproved, opportunity OppObj)
    {
        string pageDetails = '[{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}]';
        Website_Page__c websitePageObj = new Website_Page__c();
        websitePageObj.Name = strName;
        //websitePageObj.Approved__c = isApproved;
        websitePageObj.Opportunity__c = OppObj.id;
        websitePageObj.Risk_Remarks__c = '';
        websitePageObj.Sales_Remarks__c = '';
        websitePageObj.Status__c = '';
        websitePageObj.Page_Details__c = pageDetails;
        return websitePageObj ;
    }   
        
    public static Merchant_Document__c insertMerchantDoc(Account accObj)
    {
        Merchant_Document__c MerchantDocumentObj = new Merchant_Document__c();
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Account__c= accObj.Id;
        MerchantDocumentObj.URL__c = 'www.google.com';
        return MerchantDocumentObj;
        
        
        //MerchantDocumentObj.Required__c = true;
        //MerchantDocumentObj.Name = 'PAN';
        //MerchantDocumentObj.URL__c = 'www.google.com; www.faceboob.com';
        //MerchantDocumentObj.Category__c = 'Photo ID Proof';
        //MerchantDocumentObj.Document_Master_Id__c =         
        //MerchantDocumentObj.Error__c = 
        //MerchantDocumentObj.Expiry_Date__c = 
        //MerchantDocumentObj.Identifier__c = 
        //MerchantDocumentObj.Onboarding_Remarks__c = 
        //MerchantDocumentObj.Onboarding_Status__c =
        //MerchantDocumentObj.Received_Status__c = 
        //MerchantDocumentObj.Sales_Remarks__c = 
        //MerchantDocumentObj.Solution__c = 
        //MerchantDocumentObj.Third_Party_Verification_Remarks__c = 
        //MerchantDocumentObj.Third_Party_Verification_Status__c = 
        //MerchantDocumentObj.Upload_Date__c = 
    }
    
    public static Error_Solution_Mapping__c insertErrorSolutionMapping(Entity__c entityObj, Document_Category_Master__c docCateMasterObj){
        Error_Solution_Mapping__c errorSolutionObj = new Error_Solution_Mapping__c();
        errorSolutionObj.Error__c = 'Error';
        errorSolutionObj.Solution__c = 'Solution';
        errorSolutionObj.Entity__c = entityObj.Id; 
        errorSolutionObj.Document_Category__c = docCateMasterObj.Id;
        return errorSolutionObj;
    }
    
    public static Document_Master__c insertDocumentMaster(String documentName, Document_Category_Master__c docCategoryMasterObj, Id recordTypeId, String strPageAssociation){
        Document_Master__c documentMasterObj = new Document_Master__c();
        documentMasterObj.Document_Category__c = (docCategoryMasterObj != null && docCategoryMasterObj.Id != null ) ? docCategoryMasterObj.id : null;
        documentMasterObj.Active__c = true;   
        documentMasterObj.RecordTypeId = recordTypeId;
        documentMasterObj.Page_Association__c = strPageAssociation;
        return documentMasterObj;
    }
    
    public static Case CreateCase(Account AccObj, Contact ContObj, String caseStatus){
        Case caseObj = new Case();
        caseObj.ContactId = ContObj.ID;
        caseObj.AccountId = AccObj.Id;
        //caseObj.Status = 'Working';
        caseObj.Origin = 'Phone';
        caseObj.Status = caseStatus;
        
        return caseObj;     
    }
    
    public static E_Stamp_Master__c insertEStampMaster(String EStAmpNum){
        E_Stamp_Master__c EStampMasterObj = new E_Stamp_Master__c();
        EStampMasterObj.Active__c = true;
        EStampMasterObj.EStamp_Number__c = EStAmpNum;
        return EStampMasterObj;
    }
    
    public static Document_Category_Master__c insertDocCategoryMaster(String strName){
        Document_Category_Master__c DocCateMasterObj = new Document_Category_Master__c();
        DocCateMasterObj.Name = strName;
        DocCateMasterObj.Active__c = true;
        return DocCateMasterObj;
    }
    
    public static Contract insertContract(Account accObj, Contact contObj, Opportunity oppObj, Document_Master__c docMasterObj, String strStatus){
        Contract contrObj = New Contract();
        contrObj.AccountId = accObj.Id;
        contrObj.CustomerSignedId = contObj.Id;
        //contrObj.Opportunity__c = oppObj.Id;
        contrObj.Document_Master__c = docMasterObj.id;
        contrObj.Status = strStatus;
        contrObj.StartDate = Date.today();
        contrObj.ContractTerm = 12;
        contrObj.Active__c = true;
        return contrObj;
    }
    
    public static Document_Type_Master__c insertDcoTypeMaster(String strName){
        Document_Type_Master__c DocTypeMasterObj = new Document_Type_Master__c();
        DocTypeMasterObj.Name = strName;
        DocTypeMasterObj.Active__c = true;
        return DocTypeMasterObj;
    }
        
    public static Plan__c insertPlan(String strName){
        Plan__c planObj = new Plan__c();
        planObj.Name = strName;
        planObj.Active__c = true;
        return planObj ;
    }
    
    /*public static Payment_Mode__c insertPaymentMode(String strName, Payment_Mode_Master__c paymentModeMasterObj, Plan__c planObj){
        Payment_Mode__c paymentModeObj = new Payment_Mode__c();
        paymentModeObj.Name = strName;
        paymentModeObj.Active__c = true;
        paymentModeObj.Payment_Mode_Master__c = paymentModeMasterObj.Id;
        paymentModeObj.Plan__c = planObj.Id;
        return paymentModeObj ;
    }*/
    
    public static Entity__c insertEntity(String strName){
        Entity__c entityObj = new Entity__c();
        entityObj.Name = strName;
        entityObj.Active__c = true;
        return entityObj ;
    }
    
    public static Payment_Gateway__c insertPaymentGateway(){
        Payment_Gateway__c paymentGatewayObj = new Payment_Gateway__c();
        return paymentGatewayObj ;
    }
    
    public static Attachment insertAttachment(String strAttachmentName, String strParentId){
        Attachment attach = new Attachment();       
        attach.Name = strAttachmentName;
        attach.parentId = strParentId;
        attach.body = Blob.valueOf('Test Attachment Body');
        attach.ContentType = 'application/msword'; 
        return attach;
    }
    
    public static ContentVersion insertContentVersion(String strTitle){
        ContentVersion contentVersionObj = new ContentVersion();
        contentVersionObj.title = strTitle;
        contentVersionObj.VersionData = Blob.valueOf('Test Attachment Body');
        contentVersionObj.PathOnClient = 'PathOnClient';
        return contentVersionObj;
    }
    
    public static Address_Details__c insertAddressDetails(Id leadId, Id acntId, Id oppId, String strType){
        Address_Details__c addressDetailsObj = new Address_Details__c();
        addressDetailsObj.Account__c = String.isNotBlank(acntId) ? acntId : null;
        addressDetailsObj.Lead__c = String.isNotBlank(leadId) ? leadId : null;
        addressDetailsObj.Opportunity__c = String.isNotBlank(oppId) ? oppId : null;
        addressDetailsObj.Type__c = strType;
        addressDetailsObj.Active__c = true;
        addressDetailsObj.Pincode__c = '201302';
        addressDetailsObj.City__c = 'Noida';
        addressDetailsObj.Country__c = 'India';
        addressDetailsObj.Address_Line__c = 'Gautam nagar';
        addressDetailsObj.State__c = 'Uttar Pradesh';
        return addressDetailsObj;
    }
    
    public static Payment__c insertPayment(){
        Payment__c paymentObj = new Payment__c();
        paymentObj.Active__c = true;
        return paymentObj;
    }
    
    public static Platform__c insertPlatform(String strPlatformName){
        Platform__c platformObj = new Platform__c();
        platformObj.Name = strPlatformName;
        platformObj.Active__c = true;
        return platformObj ;
    }
    
    public static Product__c insertCustomProduct(String strProductName, Platform__c platformObj, Boolean isMAFEnable, String strTempName, user leadConversionUser){
        Product__c productObj = new Product__c();
        productObj.Name = strProductName;
        productObj.Active__c = true;
        productObj.MAF_Enable__c = isMAFEnable;
        productObj.MAF_Template_Name__c = strTempName;
        productObj.Platform__c = (platformObj != null && platformObj.Id != null ) ? platformObj.Id : null;
        productObj.Enable_Draft_Agreement__c = true;
        //productObj.Lead_Conversion_User__c = leadConversionUser.Id;
        return productObj ;
    }
        
    public static Bank_Account_Detail__c insertBankAccDetails(Id leadId, Id optyId){
        Bank_Account_Detail__c bankAccObj = new Bank_Account_Detail__c();
        bankAccObj.Lead__c = String.isNotBlank(leadId) ? leadId : null;
        bankAccObj.Opportunity__c = String.isNotBlank(optyId) ? optyId : null;
        bankAccObj.Account_Number__c = '1287109897981723';
        bankAccObj.Bank_Name__c = 'HDFC Bank';
        bankAccObj.IFSC_Code__c = 'ICICI635GXN';
        bankAccObj.Active__c = true;
        bankAccObj.Account_Holder_Name__c = 'Saasfocus';
        
        return bankAccObj;
    }
    
    public static Commercial__c insertCommercial(Opportunity optyObj, Plan__c planObj){
        Commercial__c commercialObj = new Commercial__c();
        commercialObj.Active__c = true;
        commercialObj.Opportunity__c = optyObj.Id;
        commercialObj.Plan__c = planObj.Id;
        return commercialObj;
    }
    
    public static Category_Type_Mapping__c insertCategoryTypeMapping(Document_Category_Master__c docCatMasObj, Document_Type_Master__c docTypeMasObj){
        Category_Type_Mapping__c CatTypeMapObj = new Category_Type_Mapping__c();
        CatTypeMapObj.Document_Category__c = docCatMasObj.Id;
        CatTypeMapObj.Document_Type__c = docTypeMasObj.Id;
        return CatTypeMapObj;
    }
    
    public static Enable_UUID_Objects__c insertEnableUUIDRec(String strObjName, boolean isEnable){
        Enable_UUID_Objects__c enableUUIDObjObj = new Enable_UUID_Objects__c();
        enableUUIDObjObj.Name = strObjName; 
        enableUUIDObjObj.Enable__c = isEnable;
        return enableUUIDObjObj ;
    } 
    
    public static Plan_Pricing__c insertPlanPricing(Payment_Gateway__c payGateObj){
        Plan_Pricing__c planPricingObj = new Plan_Pricing__c();
        planPricingObj.Payment_Gateway__c = payGateObj.Id;
        planPricingObj.Active__c = true;
        return planPricingObj;
    }
    
    public static PricingPaymentOption__c insertPricingPayOption(){
        PricingPaymentOption__c PricingPayOptionObj = new PricingPaymentOption__c();
        PricingPayOptionObj.Active__c = true;
        return PricingPayOptionObj;
    }
    
    public static Credentials__c insertCredentials(){
        Credentials__c credObj = new Credentials__c();
        credObj.OnboardingClientIdProd__c = 'E44ccf6225320e6e5887f3f1d471cfec9b11152c7a18f38327344368ad3f02ec   ';
        credObj.OnboardingClientIdSB__c = 'E44ccf6225320e6e5887f3f1d471cfec9b11152c7a18f38327344368ad3f02ec ';
        credObj.OnboardingClientSecProd__c = 'f611fa0063b447ec135ed8ed80d0cef8e6badf33cf98ae8c15db55bcc25a7fd0';
        credObj.OnboardingClientSecSB__c = 'f611fa0063b447ec135ed8ed80d0cef8e6badf33cf98ae8c15db55bcc25a7fd0';
        return credObj;
    }
    
    public static Website_Page_Master__c insertWPM(string pageName,string pageDetails){
        Website_Page_Master__c wpm = new Website_Page_Master__c();
        wpm.Name = pageName;
        wpm.Page_Details__c = pageDetails;
        wpm.Active__c = true;
        return wpm;
    }
    
    public static void insertCase(Account AccObj, Contact ContObj, String caseStatus){
        Case caseObj = new Case();
        caseObj.ContactId = ContObj.ID;
        caseObj.AccountId = AccObj.Id;
        //caseObj.Status = 'Working';
        caseObj.Origin = 'Phone';
        caseObj.Status = caseStatus;
        insert caseObj;     
    }
    
    public static Website_Details__c insertwebsiteDetails(Opportunity oppObj,Boolean active, string addendumStatus, string androidURL, string iosURL, Boolean isAndroidInvalid, Boolean isIOSInvalid, string isWebsiteLive, Boolean isWebsiteInvalid, string websiteStatus, string websiteURL){
        Website_Details__c wdObj = New Website_Details__c();
        wdObj.Opportunity__c = oppObj.Id;
        wdObj.Active__c = active;
        wdObj.Addendum_Status__c = addendumStatus;
        wdObj.Android_URL__c = androidURL;
        wdObj.IOS_URL__c = iosURL;
        wdObj.Is_Android_URL_Invalid__c = isAndroidInvalid;
        wdObj.Is_IOS_URL_Invalid__c = isIOSInvalid;
        wdObj.Is_Website_Live__c = isWebsiteLive;
        wdObj.Is_Website_URL_Invalid__c = isWebsiteInvalid;
        wdObj.Website_Status__c = websiteStatus;
        wdObj.Website_URL__c = websiteURL;
        return wdObj;
    }
    
    public static Email_Status_Tracking__c insertEmailStatusTrack(string templateDevName, Id oppId, string toAddress, Id accObjId, Id bankObjId, Id addressObjId){
        Email_Status_Tracking__c emailStatusObj = New Email_Status_Tracking__c();
        emailStatusObj.Template_Name__c = String.isNotBlank(templateDevName) ? templateDevName : null;
        emailStatusObj.Opportunity__c = String.isNotBlank(oppId) ? oppId : null;
        emailStatusObj.Bank_Account_Detail__c = String.isNotBlank(bankObjId) ? bankObjId : null;
        emailStatusObj.Account__c = String.isNotBlank(accObjId) ? accObjId : null;
        emailStatusObj.Address_Details__c = String.isNotBlank(addressObjId) ? addressObjId : null;
        emailStatusObj.To_Addresses__c = String.isNotBlank(toAddress) ? toAddress : null;
        return emailStatusObj;
    }
    
    public static Attached_Configuration__c insertAttachConfig(string attachName,Opportunity oppObj){	
        	
        Attached_Configuration__c eachAttach = New Attached_Configuration__c();	
        eachAttach.Active__c = true; 	
        eachAttach.Bank_Updatable__c = oppObj.Escrow_Lock__c;	
        eachAttach.Configurable_Identifier__c = oppObj.Identifier__c;	
        eachAttach.Opportunity__c = oppObj.Id;	
        eachAttach.Name = attachName;	
        eachAttach.Configurable_Type__c = 'Merchant';	
        eachAttach.Configuration_Identifier__c = '345678dfhgj65789';	
        eachAttach.Identifier__c = 'ewrtyu34567890ghjk';	
        eachAttach.Attached_Config_Identifier__c = eachAttach.Identifier__c;	
        return eachAttach;
    }
    
    public static Comments__c insertComment(string commentBody,Opportunity oppObj,Website_Details__c websiteObj ){	
        	
        Comments__c eachComment = New Comments__c();
        eachComment.Active__c = true;
        eachComment.Comment__c = commentBody;
        eachComment.Comment_By__c = 'Salesforce';
        eachComment.Website_Details__c = websiteObj != null ? websiteObj.Id : '';
        eachComment.Opportunity__c = oppObj != null ? oppObj.Id : '';
        return eachComment;
    }
    
    public static Merchant_Plan__c insertMerchantPlan(Lead leadObj, Opportunity opportunityObj){
        Merchant_Plan__c merchantPlanObj = new Merchant_Plan__c();
        merchantPlanObj.Name = 'business_plus';
        merchantPlanObj.Status__c = 'payment_failed';
        merchantPlanObj.Price__c = 950;
        if(leadObj != null) merchantPlanObj.Lead__c = leadObj.id;
        if(opportunityObj != null) merchantPlanObj.Opportunity__c = opportunityObj.id;
        return merchantPlanObj;
    }
    
    public static Merchant_Auto_Approval_Details__c insertMerchantAutoApproval(Lead leadObj, Opportunity opportunityObj){
        Merchant_Auto_Approval_Details__c merchantAutoObj = New Merchant_Auto_Approval_Details__c();
        merchantAutoObj.Approvable_Type__c = 'Merchant';
        merchantAutoObj.Approval_Type__c = 'ckyc';
        merchantAutoObj.Opportunity__c = opportunityObj.Id;
        merchantAutoObj.Status__c = 'success';
        return merchantAutoObj;
    }
}