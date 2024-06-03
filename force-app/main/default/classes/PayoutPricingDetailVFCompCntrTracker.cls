@isTest
public class PayoutPricingDetailVFCompCntrTracker {
    
    @testSetup static void setupCommonData(){
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        EStampMasterObj.Used__c = false; 
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        insert websitePageObj;
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Service Agreement');
        insert docCategoryMasterObj; 
        System.assertEquals('Service Agreement', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);    
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        Id PayOutRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Payout Activation').getRecordTypeId();
        
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
        // contractDraftObj.Contract_Type__c ='PayoutAgreement';
        insert contractDraftObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractDraftObj.Id].AccountId);
        
        /* Contract contractDraftObj1 = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
contractDraftObj1.E_Stamp__c = EStampMasterObj.Id;
contractDraftObj1.Type__c = 'Draft';
contractDraftObj1.Contract_Type__c ='PayoutAgreement';
insert contractDraftObj1;
System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractDraftObj.Id].AccountId);
*/
        Contract contractFinalObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractFinalObj.E_Stamp__c = EStampMasterObj.Id;
        contractFinalObj.Type__c = 'Final';
        contractFinalObj.Contract_Type__c = 'PayoutAgreement';
        contractFinalObj.Status='Pending';
        contractFinalObj.URL__c='agreement@payu.in';
        insert contractFinalObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractFinalObj.Id].AccountId);
        
        Contract contCounterSignedObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docMasterAgreementObj, 'Draft Sent');
        contractFinalObj.E_Stamp__c = EStampMasterObj.Id;
        contCounterSignedObj.Type__c = 'Final';
        contCounterSignedObj.Status = 'Counter Signed Received';
        insert contCounterSignedObj;
        System.assertEquals('Counter Signed Received', [SELECT ID, Status FROM Contract WHERE Id =: contCounterSignedObj.Id].Status);
        
        Document_Type_Master__c docType = CommonDataTracker.insertDcoTypeMaster('Partnership Deed');
        insert docType;
        Document_Type_Master__c docType2 = CommonDataTracker.insertDcoTypeMaster('Addendum');	
        insert docType2;
    }
    
    public static testMethod void testData1(){
        Opportunity opportunityObj = [SELECT id, AccountId, Merchant_Id__c, Account.Owner.Email, Product__c FROM Opportunity LIMIT 1];
        
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('Payout', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj;
        
        Cross_Sell__c cs = new Cross_Sell__c();
        cs.Care_Status__c = 'Interested';
        cs.Opportunity__c = opportunityObj.Id;
        cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
        cs.Custom_Product__c = prodObj.Id;
        insert cs;
        
        Fee_Master__c fm = New Fee_Master__c();
        fm.Active__c = true;
        fm.Mode__c = 'NEFT';
        fm.Pricing_Configurator__c = '{"0":{"fixed":0,"percent":1.5}}';
        fm.Cross_Sell__c = cs.Id;
        insert fm;
        
        PayoutPricingDetailVFCompController cntrl = New PayoutPricingDetailVFCompController();
        cntrl.assignedCSId = cs.Id;
        cntrl.detailCompInit();
    }
    
    public static testMethod void testData2(){
        Opportunity opportunityObj = [SELECT id, AccountId, Merchant_Id__c, Account.Owner.Email, Product__c FROM Opportunity LIMIT 1];
        
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('Payout', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj;
        
        Cross_Sell__c cs = new Cross_Sell__c();
        cs.Care_Status__c = 'Interested';
        cs.Opportunity__c = opportunityObj.Id;
        cs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId();
        cs.Custom_Product__c = prodObj.Id;
        insert cs;
        
        Fee_Master__c fm = New Fee_Master__c();
        fm.Active__c = true;
        fm.Mode__c = 'NEFT';
        fm.Pricing_Configurator__c = '{"0":{"fixed":0,"percent":1.5}}';
        fm.Cross_Sell__c = cs.Id;
        insert fm;
        
        PayoutPricingDetailVFCompController cntrl = New PayoutPricingDetailVFCompController();
        cntrl.assignedOppId = opportunityObj.Id;
        cntrl.init();
    }
}