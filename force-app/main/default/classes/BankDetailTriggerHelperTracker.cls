@isTest
public class BankDetailTriggerHelperTracker {
    
    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Lead', true);
        insert triggerSwitchObj ;
        
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;        
        
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
        System.assertEquals(accountObj.Id, [SELECT Id, AccountId FROM Contact WHERE Id =: contactObj.Id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.Id, [SELECT Id, AccountId FROM Opportunity WHERE Id =: opportunityObj.Id].AccountId);
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategoryOthers ;
        System.assertEquals('Others', [SELECT Id, name FROM Business_Category__c WHERE Id =: businessCategoryOthers.id].Name);
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE Id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        insert subCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
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
        
        Plan__c planObj = CommonDataTracker.insertPlan('Pay Citrus');
        insert planObj;
        System.assertEquals('Pay Citrus', [SELECT id, Name FROM Plan__c WHERE Id =: planObj.Id].Name);
        
        Payment_Gateway__c payGateObj = CommonDataTracker.insertPaymentGateway();
        payGateObj.Active__c = true;
        payGateObj.Route__c = 'Text';
        payGateObj.Provider__c = 'Text';
        insert payGateObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment_Gateway__c WHERE Id =: payGateObj.Id].Active__c);
        
        Plan_Pricing__c planPricingObj = CommonDataTracker.insertPlanPricing(payGateObj);
        insert planPricingObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Plan_Pricing__c WHERE Id =: planPricingObj.Id].Active__c);
        
        PricingPaymentOption__c PricingPayOptionObj = CommonDataTracker.insertPricingPayOption();
        insert PricingPayOptionObj;
        System.assertNotEquals(null, PricingPayOptionObj.Id);
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, 'Registered');
        insert  addDetailsRegObj;
        System.assertEquals(accountObj.Id, [SELECT id, Lead__c, Account__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Account__c);
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, 'Operating');
        insert  addDetailsOpeObj;
        System.assertEquals(accountObj.Id, [SELECT id, Lead__c, Account__c FROM Address_Details__c WHERE id =: addDetailsOpeObj.Id].Account__c);
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(null, opportunityObj.Id);
        insert bankAccObj; 
        System.assertEquals(opportunityObj.Id, [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE id =: bankAccObj.Id].Opportunity__c );
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        leadObj.Merchant_Id__c = null;
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Bank_Account_Detail__c bankAccObjLead = CommonDataTracker.insertBankAccDetails(leadObj.Id, null);
        insert bankAccObjLead; 
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Bank_Account_Detail__c WHERE id =: bankAccObjLead.Id].Lead__c);
        
        Address_Details__c addDetailsRegObj1 = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Registered');
        insert  addDetailsRegObj1;
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsRegObj1.Id].Lead__c);
        
        Address_Details__c addDetailsOpeObj1 = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Operating');
        insert  addDetailsOpeObj1;
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsOpeObj1.Id].Lead__c);
    }
    
    @isTest static void testMethodOne() {        
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c  FROM Bank_Account_Detail__c WHERE Opportunity__c =: opportunityObj.Id LIMIT 1];
        
        String queryStr = 'SELECT Id, PennyPayload__c, RawResponse__c, Penny_Deposit_Status__c, Active__c, Opportunity__c, Opportunity__r.AccountId, Lead__c, IFSC_Code__c FROM Bank_Account_Detail__c WHERE Id = \'' + bankAccObj.Id + '\'';
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        BankDetailTriggerHelper.pennyTestUtility(queryStr, 'PennyPayload__c', 'RawResponse__c');            
        Test.stopTest();        
    }
    
    @isTest static void testMethodTwo() {
        Lead leadObj = [SELECT id, Product__c FROM Lead LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Lead__c  FROM Bank_Account_Detail__c WHERE Lead__c =: leadObj.Id LIMIT 1];
        
        String queryStr = 'SELECT Id, Lead__r.Product__c, Lead__r.ProductLabel__c, Lead__r.Integration_Type__c, PennyPayload__c, RawResponse__c, Penny_Deposit_Status__c, Active__c, Opportunity__c, Opportunity__r.AccountId, Lead__c, IFSC_Code__c FROM Bank_Account_Detail__c WHERE Id = \'' + bankAccObj.Id + '\'';
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());  
        
        BankDetailTriggerHelper.pennyTestUtility(queryStr, 'PennyPayload__c', 'RawResponse__c');            
        Test.stopTest();
    }
    
    @isTest static void testMethodThree() {
        Lead leadObj = [SELECT Id, Product__c FROM Lead LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT Id, Lead__c, Penny_Deposit_Status__c  FROM Bank_Account_Detail__c WHERE Lead__c =: leadObj.Id LIMIT 1];
		        
        List<Address_Details__c> lstAddress = [SELECT Id, Lead__c FROM Address_Details__c WHERE Lead__c =: leadObj.Id];
        if(lstAddress != null && !lstAddress.isEmpty())	delete lstAddress;
        
        String queryStr = 'SELECT Id, Lead__r.Product__c, Lead__r.ProductLabel__c, Lead__r.Integration_Type__c, PennyPayload__c, RawResponse__c, Penny_Deposit_Status__c, Active__c, Opportunity__c, Opportunity__r.AccountId, Lead__c, IFSC_Code__c FROM Bank_Account_Detail__c WHERE Id = \'' + bankAccObj.Id + '\'';
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        BankDetailTriggerHelper.pennyTestUtility(queryStr, 'PennyPayload__c', 'RawResponse__c');            
        Test.stopTest();        
    }
    
    @isTest static void testMethodFour() {
        Lead leadObj = [SELECT Id, Product__c FROM Lead LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT Id, Lead__c, IFSC_Code__c, Penny_Deposit_Status__c  FROM Bank_Account_Detail__c WHERE Lead__c =: leadObj.Id LIMIT 1];
        bankAccObj.IFSC_Code__c = null;
        update bankAccObj;
        
        String queryStr = 'SELECT Id, PennyPayload__c, RawResponse__c, Penny_Deposit_Status__c, Active__c, Opportunity__c, Opportunity__r.AccountId, Lead__c, IFSC_Code__c FROM Bank_Account_Detail__c WHERE Id = \'' + bankAccObj.Id + '\'';
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());  
        
        BankDetailTriggerHelper.pennyTestUtility(queryStr, 'PennyPayload__c', 'RawResponse__c');            
        Test.stopTest();        
    }
    
    @isTest static void testMethodFive() {
        Lead leadObj = [SELECT Id, Product__c FROM Lead LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT Id, Lead__c, Penny_Deposit_Status__c  FROM Bank_Account_Detail__c WHERE Lead__c =: leadObj.Id LIMIT 1];
        bankAccObj.Penny_Deposit_Status__c = 'Pending';        
        update bankAccObj;
        
        String queryStr = 'SELECT Id, Lead__r.Product__c, Lead__r.ProductLabel__c, Lead__r.Integration_Type__c, PennyPayload__c, RawResponse__c, Penny_Deposit_Status__c, Active__c, Opportunity__c, Opportunity__r.AccountId, Lead__c, IFSC_Code__c FROM Bank_Account_Detail__c WHERE Id = \'' + bankAccObj.Id + '\'';
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());  
        
        BankDetailTriggerHelper.pennyTestUtility(queryStr, 'PennyPayload__c', 'RawResponse__c');            
        Test.stopTest();        
    }
    
    @isTest static void testMethodSix() {
        Lead leadObj = [SELECT Id, Product__c FROM Lead LIMIT 1];
        
        Bank_Account_Detail__c bankAccObj = [SELECT Id, Lead__c, IFSC_Code__c, Penny_Deposit_Status__c  FROM Bank_Account_Detail__c WHERE Lead__c =: leadObj.Id LIMIT 1];
        bankAccObj.Penny_Deposit_Status__c = 'Success';
        update bankAccObj;
        
        String queryStr = 'SELECT Id, PennyPayload__c, RawResponse__c, Penny_Deposit_Status__c, Active__c, Opportunity__c, Opportunity__r.AccountId, Lead__c, IFSC_Code__c FROM Bank_Account_Detail__c WHERE Id = \'' + bankAccObj.Id + '\'';
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());  
        
        BankDetailTriggerHelper.pennyTestUtility(queryStr, 'PennyPayload__c', 'RawResponse__c');            
        Test.stopTest();        
    }
}