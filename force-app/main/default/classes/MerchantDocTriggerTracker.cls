@isTest
public class MerchantDocTriggerTracker{
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Merchant_Document__c', true);
        insert triggerSwitchObj ;  
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        insert opportunityObj;
    }
    
    @isTest static void testMethodOne(){
		Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
		Document_Category_Master__c docCategoryPanObj =  CommonDataTracker.insertDocCategoryMaster('PAN Card of Signing Authority');
        Insert  docCategoryPanObj;
        
		Merchant_Document__c MerchantDocumentPanObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentPanObj.Document_Category__c = docCategoryPanObj.Id; 
        MerchantDocumentPanObj.Identifier__c = 'wqeqwd2343242wqda';
        MerchantDocumentPanObj.URL__c = '';
        insert MerchantDocumentPanObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentPanObj.id].Account__c);
        
        Merchant_Document__c MerchantDocumentObj1 = new Merchant_Document__c(Id=MerchantDocumentPanObj.Id); 
        update MerchantDocumentObj1;
        
        Merchant_Document__c MerchantDocumentPanObj2 = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj2.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj2.URL__c = '';
        MerchantDocumentPanObj2.Identifier__c = 'wqeqwd24564656242wqda';
        MerchantDocumentPanObj2.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentPanObj2.Document_Category__c = docCategoryPanObj.Id; 
        insert MerchantDocumentPanObj2;        
        
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo(){
		Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        
        Opportunity oppObj = [Select Id,AccountId from Opportunity LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
		Document_Category_Master__c docCategoryPanObj =  CommonDataTracker.insertDocCategoryMaster('Bank Account Proof');
        Insert  docCategoryPanObj;
        
		Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentObj.URL__c = 'www.google.vcoc';
        MerchantDocumentObj.Identifier__c = 'wqeqwd24787756242wqda';
        MerchantDocumentObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Document_Category__c = docCategoryPanObj.Id;
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
                
        Merchant_Document__c MerchantDocumentPanObj2 = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj2.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj2.URL__c = '';
        MerchantDocumentPanObj2.Active__c = true;
        MerchantDocumentPanObj2.Identifier__c = 'wqeqwd243434756242wqda';
        MerchantDocumentPanObj2.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentPanObj2.Document_Category__c = docCategoryPanObj.Id; 
        insert MerchantDocumentPanObj2;
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.Opportunity__c = oppObj.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Verification_Status__c ='Pending';
        bankDeatilObj.Penny_Deposit_Status__c = 'Failed ';
        insert bankDeatilObj;
        
        Merchant_Document__c MerchantDocumentBBankObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentBBankObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentBBankObj.URL__c = 'asdfasf.com';
        MerchantDocumentBBankObj.Opportunity__c = oppObj.Id;
        MerchantDocumentBBankObj.Active__c = true;
        MerchantDocumentBBankObj.Identifier__c = 'wqeqwd243434756242wqda';
        MerchantDocumentBBankObj.KYC_Documentable_Type__c = 'Merchant';
        MerchantDocumentBBankObj.Document_Category__c = docCategoryPanObj.Id; 
        insert MerchantDocumentBBankObj;
        
        MerchantDocumentBBankObj.Onboarding_Status__c = 'Approved';
        update MerchantDocumentBBankObj;
        
        Merchant_Document__c MerchantDocumentObj1 = new Merchant_Document__c(Id=MerchantDocumentObj.Id); 
        delete MerchantDocumentObj1;
        Test.stopTest();
    }
    
    @isTest static void testMethodThree(){
		Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        
        Opportunity oppObj = [Select Id,AccountId from Opportunity LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
		Document_Category_Master__c docCategoryPanObj =  CommonDataTracker.insertDocCategoryMaster('Bank Account Proof');
        Insert  docCategoryPanObj;
        
		Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentObj.URL__c = 'www.google.vcoc';
        MerchantDocumentObj.Identifier__c = 'wqeqwd24787756242wqda';
        MerchantDocumentObj.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Document_Category__c = docCategoryPanObj.Id;
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
                
        Merchant_Document__c MerchantDocumentPanObj2 = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj2.Account__c = null;
        MerchantDocumentPanObj2.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj2.URL__c = '';
        MerchantDocumentPanObj2.Active__c = true;
        MerchantDocumentPanObj2.Identifier__c = 'wqeqwd243434756242wqda';
        MerchantDocumentPanObj2.KYC_Documentable_Type__c = 'Account';
        MerchantDocumentPanObj2.Document_Category__c = docCategoryPanObj.Id; 
        MerchantDocumentPanObj2.Opportunity__c = oppObj.Id;
        insert MerchantDocumentPanObj2;
        
        Merchant_Document__c MerchantDocumentObj1 = new Merchant_Document__c(Id=MerchantDocumentObj.Id); 
        delete MerchantDocumentObj1;
        
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.Opportunity__c = oppObj.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Verification_Status__c ='Pending';
        bankDeatilObj.Penny_Deposit_Status__c = 'Failed ';
        insert bankDeatilObj;
        
        Merchant_Document__c MerchantDocumentBBankObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentBBankObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentBBankObj.URL__c = 'asdfasf.com';
        MerchantDocumentBBankObj.Opportunity__c = oppObj.Id;
        MerchantDocumentBBankObj.Active__c = true;
        MerchantDocumentBBankObj.Identifier__c = 'wqeqwd243434756242wqda';
        MerchantDocumentBBankObj.KYC_Documentable_Type__c = 'Merchant';
        MerchantDocumentBBankObj.Document_Category__c = docCategoryPanObj.Id; 
        insert MerchantDocumentBBankObj;
        
        MerchantDocumentBBankObj.Onboarding_Status__c = 'Declined';
        update MerchantDocumentBBankObj;
        
        Test.stopTest();
    }
    
    @isTest static void testMethod4(){
		Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        
        Opportunity oppObj = [Select Id,AccountId from Opportunity LIMIT 1];
        oppObj.Merchant_Business_Type__c='Enterprise';
        update oppObj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
		Document_Category_Master__c docCategoryPanObj =  CommonDataTracker.insertDocCategoryMaster('PAN Card of Signing Authority');
        Insert  docCategoryPanObj;
        
		Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentObj.Onboarding_Status__c = 'Pending';
        MerchantDocumentObj.URL__c = 'www.google.vcoc';
        MerchantDocumentObj.Identifier__c = 'wqeqwd24787756242wqda';
        MerchantDocumentObj.KYC_Documentable_Type__c = 'Merchant';
        MerchantDocumentObj.Active__c = true;
        MerchantDocumentObj.Document_Category__c = docCategoryPanObj.Id;
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
        
                
        Merchant_Document__c MerchantDocumentPanObj2 = CommonDataTracker.insertMerchantDoc(accountObj); 
        MerchantDocumentPanObj2.Onboarding_Status__c = 'Pending';
        MerchantDocumentPanObj2.URL__c = '';
        MerchantDocumentPanObj2.Active__c = true;
        MerchantDocumentPanObj2.Identifier__c = 'wqeqwd243434756242wqda';
        MerchantDocumentPanObj2.KYC_Documentable_Type__c = 'Merchant';
        MerchantDocumentPanObj2.Document_Category__c = docCategoryPanObj.Id; 
        MerchantDocumentPanObj2.Opportunity__c = oppObj.Id;
        insert MerchantDocumentPanObj2;
        
        MerchantDocumentPanObj2.Onboarding_Status__c = 'Received';
        update MerchantDocumentPanObj2;
        
        Merchant_Document__c MerchantDocumentObj1 = new Merchant_Document__c(Id=MerchantDocumentObj.Id); 
        delete MerchantDocumentObj1;
        Test.stopTest();
    }
}