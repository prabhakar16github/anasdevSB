@isTest
public class ServiceAgreementControllerTracker {
    @testSetup static void setupCommonData(){
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        EStampMasterObj.Used__c = false; 
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        contactObj.Type__c = 'Secondary Contact';
        contactObj.Authorised_Signatory__c = true;
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.InsertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Product__c prodObj2 = CommonDataTracker.insertCustomProduct('Payout', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj2; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj2.Id].Platform__c);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
                
       Website_Page_Master__c wpm1 = New Website_Page_Master__c();
        wpm1.Active__c = true;
        wpm1.Name = 'Contact Us Details';
        wpm1.Page_Details__c = '[{"name":"Functional email ID","status":"Pending","is_present":false,"error":null,"remarks":null}]';
        
        insert wpm1;
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Terms & Conditions Details', true, opportunityObj);
        websitePageObj.Page_Details__c = wpm1.Page_Details__c;
        insert websitePageObj;
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);    
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.Entity__c = entityObj.Id;
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Product__c = prodObj.Id;
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAgreementObj.Id].Document_Category__c);
        
        Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj);
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
        
        Contract contractDraftObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractDraftObj.E_Stamp__c = EStampMasterObj.Id;
        contractDraftObj.Type__c = 'Draft';
        insert contractDraftObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractDraftObj.Id].AccountId);
        
        Contract contractFinalObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractFinalObj.E_Stamp__c = EStampMasterObj.Id;
        contractFinalObj.Type__c = 'Final';
        insert contractFinalObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractFinalObj.Id].AccountId);
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, null, 'Registered');
        insert  addDetailsRegObj;
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, null, 'Operating');
        insert  addDetailsOpeObj;
        
        Payment__c paymentAMCObj = CommonDataTracker.insertPayment();
        paymentAMCObj.Charges_Type__c = 'AMC';
        insert paymentAMCObj;
        
        Payment__c paymentSecurityDepositObj = CommonDataTracker.insertPayment();
        paymentSecurityDepositObj.Charges_Type__c = 'Security Deposit';
        insert paymentSecurityDepositObj;
        
        Payment__c paymentSetupFeeObj = CommonDataTracker.insertPayment();
        paymentSetupFeeObj.Charges_Type__c = 'Setup Fee';
        insert paymentSetupFeeObj;
        
        Cross_Sell__c cs = new Cross_Sell__c();
        cs.Care_Status__c = 'Not Interested';
        cs.Opportunity__c = opportunityObj.Id;
        cs.Custom_Product__c = prodObj2.Id;
        cs.Product_Name__c = 'Payout';
        cs.Source__c = 'Dashboard';
        cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
        insert cs;
        
        Fee_Master__c feeMastObj = new Fee_Master__c();
        feeMastObj.Active__c = true;
        feeMastObj.Mode__c = 'NEFT';
        feeMastObj.Cross_Sell__c = cs.Id;
        feeMastObj.RecordTypeId = Schema.SObjectType.Fee_Master__c.getRecordTypeInfosByName().get('Payout Agreement').getRecordTypeId();
        feeMastObj.Pricing_Configurator__c = '{"0":{"fixed":0,"percent":1.5}}';
        insert feeMastObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Fee_Master__c WHERE Id =: feeMastObj.Id].Active__c);    
        
    }
    
    @isTest static void testMethodOne(){ 
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id, AccountId, Name, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        PageReference pgeRef = Page.ServiceAgreementIndianTrustsActOf1882;
        pgeRef.getParameters().put('Id', opportunityObj.Id);
        pgeRef.getParameters().put('eStampNo', '546');
        pgeRef.getParameters().put('strIsFinal', 'true');
        Test.setCurrentPage(pgeRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunityObj);
        ServiceAgreementController clsServiceAgreementController = new ServiceAgreementController(stdController);
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo(){ 
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id, AccountId, Name, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        PageReference pgeRef = Page.ServiceAgreementIndianTrustsActOf1882;
        pgeRef.getParameters().put('Id', opportunityObj.Id);
        pgeRef.getParameters().put('eStampNo', '546');
        pgeRef.getParameters().put('strIsFinal', 'false');
        Test.setCurrentPage(pgeRef);
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunityObj);
        ServiceAgreementController clsServiceAgreementController = new ServiceAgreementController(stdController);
        Test.stopTest();
    }
    
    @isTest static void testMethodThree(){ 
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id, AccountId, Name, Merchant_Id__c FROM Opportunity WHERE AccountId =: accountObj.Id];
        opportunityObj.Merchant_Id__c = 345678;
        update opportunityObj;
        System.assertNotEquals(opportunityObj.id, null);
        
        Cross_Sell__c crossObj = [Select Id,Opportunity__c from Cross_Sell__c LIMIT 1];

        Fee_Master__c fmObj = [Select Id,Pricing_Configurator__c,Cross_Sell__c,Mode__c,Active__c,RecordTypeId from Fee_Master__c];
        
        Test.startTest();
        ServiceAgreementMoneyComponentController objForPage2 = new ServiceAgreementMoneyComponentController();
        objForPage2.strOppId = opportunityObj.Id;
        objForPage2.getstrOpportunity();
        getListOfMerchantDocController onjGetdata = new getListOfMerchantDocController();
        onjGetdata.strAccountId = accountObj.id;
        onjGetdata.getlstofMercDoc();
        Test.stopTest();
    }
}