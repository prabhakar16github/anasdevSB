@isTest
public class WebsiteDetailsTriggerTracker {
    
    @testSetup static void setupCommonData(){
        
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Website_Details__c', true);
        insert triggerSwitchObj ;
        
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
        insert enableUUIDObjObj;
        
        Enable_UUID_Objects__c enableUUIDObjObj1 = CommonDataTracker.insertEnableUUIDRec('Lead', true);
        insert enableUUIDObjObj1;
        
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Business_Category__c businessCategory1 = CommonDataTracker.insertBusinessCategory('Real Estate', false);
        businessCategory1.Doable__c = True;
        insert businessCategory1;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Business_Entity__c =  entityObj.Id;
        opportunityObj.Integration_Type__c = 'Thirdparty';
        opportunityObj.Merchant_Business_Type__c = 'LongTail';
        opportunityObj.Monthly_Expected_Sale__c = 1200000;
        opportunityObj.Delivery_Duration__c = 4;
        opportunityObj.Email__c = 'esdef@efef.com';
        insert opportunityObj;
        
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Merchant_Plan__c merchantPlanObj = CommonDataTracker.insertMerchantPlan(null, opportunityObj);
        insert merchantPlanObj;
        Test.stopTest(); 
        
    }
    
    @isTest static void testMethodOne() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, Email__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c FROM Opportunity LIMIT 1];
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        websiteObj.Website_URL__c = 'payu.in';
        websiteObj.Website_Status__c = 'Verification in Process';
        insert websiteObj;
        
        websiteObj.IOS_URL__c = 'payu.in';
        websiteObj.Website_Status__c = 'Website Error';
        update websiteObj;
    }
    
    @isTest static void testMethod2() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c,Name from Business_Category__c LIMIT 1];
        businessCategory.Name = 'Financial Services';
        update businessCategory;
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, Email__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c FROM Opportunity LIMIT 1];
        update oppObj;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        insert websiteObj;
        
        websiteObj.IOS_URL__c = 'payu.in';
        websiteObj.Website_Status__c = 'Verification in Process';
        update websiteObj;
    }
    
    @isTest static void testMethod3() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, BusinessCategory__r.Name,isPremiumCustomer__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c FROM Opportunity LIMIT 1];
        oppObj.isPremiumCustomer__c = true;
        //oppObj.isPremiumCustomer__c = false;
        update oppObj;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Merchant_Plan__c merchantPlanObj = [Select Id, Opportunity__c from Merchant_Plan__c LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        websiteObj.IOS_URL__c = 'payu.in';
        websiteObj.Is_Website_Live__c = 'active';
        websiteObj.Website_Status__c = 'Pending';
        insert websiteObj;
    }
    
    @isTest static void testMethod4() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c,Name from Business_Category__c LIMIT 1];
        businessCategory.Name = 'Financial Services';
        update businessCategory;
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, BusinessCategory__r.Name,isPremiumCustomer__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c,Skip_Website_Verification__c FROM Opportunity LIMIT 1];
        oppObj.isPremiumCustomer__c = true;
        oppObj.BusinessCategory__c = businessCategory.Id;
        //added - Kunal
        oppObj.Identifier__c = '11ea-a012-07abe5e6-9e47-020aca9875be';
        update oppObj;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Merchant_Plan__c merchantPlanObj = [Select Id, Opportunity__c from Merchant_Plan__c LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        websiteObj.Is_Website_Live__c = 'active';
        websiteObj.Website_Status__c = 'Pending';
        websiteObj.Website_URL__c = 'ascv.com';
        insert websiteObj;
        
    }
    @isTest static void testMethod5() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, BusinessCategory__r.Name,isPremiumCustomer__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c FROM Opportunity LIMIT 1];
        oppObj.isPremiumCustomer__c = false;
        update oppObj;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Merchant_Plan__c merchantPlanObj = [Select Id, Opportunity__c from Merchant_Plan__c LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        websiteObj.IOS_URL__c = 'payu.in';
        websiteObj.Is_Website_Live__c = 'active';
        websiteObj.Website_Status__c = 'Pending';
        insert websiteObj;
    }
   @isTest static void testMethod6() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c,Name from Business_Category__c LIMIT 1];
        businessCategory.Name = 'Financial Services';
        update businessCategory;
       
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, BusinessCategory__r.Name,isPremiumCustomer__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c FROM Opportunity LIMIT 1];
        oppObj.isPremiumCustomer__c = false;
        update oppObj;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Merchant_Plan__c merchantPlanObj = [Select Id, Opportunity__c from Merchant_Plan__c LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        websiteObj.IOS_URL__c = 'payu.in';
        websiteObj.Is_Website_Live__c = 'active';
        websiteObj.Website_Status__c = 'Pending';
       
        insert websiteObj;
    }
    @isTest static void testMethod7() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c,Name from Business_Category__c LIMIT 1];
        businessCategory.Name = 'Financial Services';
        update businessCategory;
       
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, BusinessCategory__r.Name,isPremiumCustomer__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c FROM Opportunity LIMIT 1];
        oppObj.isPremiumCustomer__c = true;
        update oppObj;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Merchant_Plan__c merchantPlanObj = [Select Id, Opportunity__c from Merchant_Plan__c LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        websiteObj.IOS_URL__c = 'payu.in';
        websiteObj.Is_Website_Live__c = 'active';
        websiteObj.Website_Status__c = 'Verification in Process';
       
        insert websiteObj;
    }
    @isTest static void testMethod8() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c,Name from Business_Category__c LIMIT 1];
        businessCategory.Name = '';
        update businessCategory;
       
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = [Select Id from Product__c LIMIT 1];
        
        Opportunity oppObj = [SELECT id, BusinessCategory__r.Name,isPremiumCustomer__c,AccountId,Integration_Type__c,Website_Status__c,Merchant_Business_Type__c,NDX_Score__c FROM Opportunity LIMIT 1];
        oppObj.isPremiumCustomer__c = true;
        update oppObj;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account LIMIT 1];
        
        Merchant_Plan__c merchantPlanObj = [Select Id, Opportunity__c from Merchant_Plan__c LIMIT 1];
        
        Website_Details__c websiteObj = New Website_Details__c();
        websiteObj.Opportunity__c = oppObj.Id;
        websiteObj.Active__c = true;
        websiteObj.IOS_URL__c = 'payu.in';
        websiteObj.Is_Website_Live__c = 'active';
        websiteObj.Website_Status__c = 'Verification in Process';
       
        insert websiteObj;
    }
}