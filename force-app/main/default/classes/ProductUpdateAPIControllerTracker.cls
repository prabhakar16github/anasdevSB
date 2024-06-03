@isTest
public class ProductUpdateAPIControllerTracker {

    public static testMethod void testData1(){
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
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
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        //prodObj.Identifier__c = '11e8-a536-37ea0c3e-ad17-f45c89c91a7b';
        prodObj.Identifier__c = 'c10c-09ed-2a4d1e54-5bde-2ae0ed54ea8a';
        insert prodObj;
        
        Product__c prodObj2 = CommonDataTracker.insertCustomProduct('payU Now', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        //prodObj2.Identifier__c = '11e8-a536-37ed592a-ad17-f45c89c91a7b';
        prodObj2.Identifier__c = '7318-c204-87737a95-13e3-eaf3d52cd3a4';
        insert prodObj2;
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Monthly_Expected_Sale__c = 200;
        accountObj.Delivery_Duration__c = 2;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = merchantRecordTypeId;
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90; 
        opportunityObj.Prod_Merchant_Id__c = 45678789;
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Identifier__c = '11eb-24e5-912b991c-8ee3-02053299b2da';
        insert opportunityObj;
        
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateProduct';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"merchant_uuids":["11eb-24e5-912b991c-8ee3-02053299b2da","11ea-5de2-6d26359c-b76e-02053299b2da"],"product":"PayUnow"}]');
        RestContext.request = req;
        RestContext.response= res;
        
        ProductUpdateAPIController.getMerchantsProduct();
    }
    
    public static testMethod void testData2(){
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
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
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        //prodObj.Identifier__c = '11e8-a536-37ea0c3e-ad17-f45c89c91a7b';
        prodObj.Identifier__c = 'c10c-09ed-2a4d1e54-5bde-2ae0ed54ea8a';
        insert prodObj;
        
        Product__c prodObj2 = CommonDataTracker.insertCustomProduct('payU Now', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        //prodObj2.Identifier__c = '11e8-a536-37ed592a-ad17-f45c89c91a7b';
        prodObj2.Identifier__c = '7318-c204-87737a95-13e3-eaf3d52cd3a4';
        insert prodObj2;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategory, subCategory, entityObj);   
        leadObj.Identifier__c = '11e4-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateProduct';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"merchant_uuids":["11e4-d9f0-6fc7926c-bf11-02aa98a2d2b0","11ea-5de2-6d26359c-b76e-02053299b2da"],"product":"PayUnow"}]');
        RestContext.request = req;
        RestContext.response= res;
        
        ProductUpdateAPIController.getMerchantsProduct();
    }
    
    public static testMethod void testData3(){
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
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
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        //prodObj.Identifier__c = '11e8-a536-37ea0c3e-ad17-f45c89c91a7b';
        prodObj.Identifier__c = 'c10c-09ed-2a4d1e54-5bde-2ae0ed54ea8a';
        insert prodObj;
        
        Product__c prodObj2 = CommonDataTracker.insertCustomProduct('payU Now', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        //prodObj2.Identifier__c = '11e8-a536-37ed592a-ad17-f45c89c91a7b';
        prodObj2.Identifier__c = '7318-c204-87737a95-13e3-eaf3d52cd3a4';
        insert prodObj2;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategory, subCategory, entityObj);   
        leadObj.Identifier__c = '11e9-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateProduct';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"merchant_uuids":[],"product":"PayUnow"}]');
        RestContext.request = req;
        RestContext.response= res;
        
        ProductUpdateAPIController.getMerchantsProduct();
    }
}