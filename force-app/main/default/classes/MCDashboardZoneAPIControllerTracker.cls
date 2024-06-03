@isTest
public class MCDashboardZoneAPIControllerTracker {

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
        insert prodObj;
        
        Product__c prodObj2 = CommonDataTracker.insertCustomProduct('EMI', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
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
        insert opportunityObj;
        
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Contact oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        oContact.AccountId = accountObj.id;
        insert oContact;
        
        OpportunityContactRole ocr = New OpportunityContactRole();
        ocr.ContactId = oContact.Id;
        ocr.OpportunityId = opportunityObj.Id;
        Insert ocr; 
        
        Cross_Sell__c csObj = New Cross_Sell__c();
        csObj.Name = 'EMI';
        csObj.Custom_Product__c = prodObj2.Id;
        csObj.Risk_Zone__c = 'Green Zone';
        csObj.Opportunity__c = opportunityObj.Id;
        insert csObj;
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/MCDashboardZoneAPI';
        req1.httpMethod = 'GET';
        req1.params.put('merchant_id', '67328789');
        req1.params.put('product_name', 'PayUmoney');
        req1.params.put('sellProduct_name', 'EMI');
        req1.addHeader('Content-Type', 'application/json');
        RestContext.request = req1;
        RestContext.response= res1;
        
        MCDashboardZoneAPIController.getRiskZoneStatus();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MCDashboardZoneAPI';
        req.httpMethod = 'GET';
        req.params.put('product_name', 'PayUmoney');
        req.params.put('sellProduct_name', 'EMI');
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        
        MCDashboardZoneAPIController.getRiskZoneStatus();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/MCDashboardZoneAPI';
        req2.httpMethod = 'GET';
        req2.params.put('merchant_id', '45678789');
        req2.params.put('sellProduct_name', 'EMI');
        req2.addHeader('Content-Type', 'application/json');
        RestContext.request = req2;
        RestContext.response= res2;
        
        MCDashboardZoneAPIController.getRiskZoneStatus();
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = '/services/apexrest/MCDashboardZoneAPI';
        req3.httpMethod = 'GET';
        req3.params.put('merchant_id', '45678789');
        req3.params.put('product_name', 'PayUmoney');
        req3.addHeader('Content-Type', 'application/json');
        RestContext.request = req3;
        RestContext.response= res3;
        
        MCDashboardZoneAPIController.getRiskZoneStatus();
        
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        req4.requestURI = '/services/apexrest/MCDashboardZoneAPI';
        req4.httpMethod = 'GET';
        req4.params.put('merchant_id', '45678789');
        req4.params.put('product_name', 'PayUmoney');
        req4.params.put('sellProduct_name', 'MCP');
        req4.addHeader('Content-Type', 'application/json');
        RestContext.request = req4;
        RestContext.response= res4;
        
        MCDashboardZoneAPIController.getRiskZoneStatus();
        
        RestRequest req5 = new RestRequest(); 
        RestResponse res5 = new RestResponse();
        req5.requestURI = '/services/apexrest/MCDashboardZoneAPI';
        req5.httpMethod = 'GET';
        req5.params.put('merchant_id', '45678789');
        req5.params.put('product_name', 'PayUmoney');
        req5.params.put('sellProduct_name', 'EMI');
        req5.addHeader('Content-Type', 'application/json');
        RestContext.request = req5;
        RestContext.response= res5;
        
        MCDashboardZoneAPIController.getRiskZoneStatus();
    }
}