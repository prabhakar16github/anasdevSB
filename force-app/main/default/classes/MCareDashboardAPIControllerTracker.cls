@isTest
public class MCareDashboardAPIControllerTracker {
    
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
        
        Id KYCRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.recordTypeId = KYCRecordTypeId;
        oCase.ContactId=oContact.id;
        oCase.TicketId__c = '321453';
        oCase.Opportunity__c = opportunityObj.Id;
        insert oCase;
        
        OpportunityContactRole ocr = New OpportunityContactRole();
        ocr.ContactId = oContact.Id;
        ocr.OpportunityId = opportunityObj.Id;
        Insert ocr; 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MCareDashboardController';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        MCareDashboardAPIController.createActivationDocument();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        MCareDashboardAPIController.createActivationDocument();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        req.params.put('ticket_id', oCase.TicketId__c);
        MCareDashboardAPIController.createActivationDocument();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        req.params.put('ticket_id', oCase.TicketId__c);
        req.params.put('product_name','PayUmoney');
        MCareDashboardAPIController.createActivationDocument();
        MCareDashboardAPIController.getDocumentStatus();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        req.params.put('ticket_id', oCase.TicketId__c);
        req.params.put('product_name','PayUmoney');
        req.requestBody = Blob.valueOf('te');
        MCareDashboardAPIController.createActivationDocument();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        req.params.put('ticket_id', '98765432');
        req.params.put('product_name','PayUmoney');
        MCareDashboardAPIController.getDocumentStatus();
        req.params.put('transaction_id','567899');
        req.params.put('content_type','image/png');
        req.requestBody = Blob.valueOf('"teasdfghjkqwertyuiozxcvbnm"');
        MCareDashboardAPIController.createActivationDocument();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        req.params.put('ticket_id', '98765432');
        req.params.put('product_name','PayUmoney');
        MCareDashboardAPIController.getDocumentStatus();
        req.params.put('transaction_id','567899');
        req.requestBody = Blob.valueOf('"teasdfghjkqwertyuiozxcvbnm"');
        MCareDashboardAPIController.createActivationDocument();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        req.params.put('ticket_id', '98765432');
        req.params.put('product_name','PayUmoney');
        MCareDashboardAPIController.getDocumentStatus();
        req.params.put('transaction_id','567899');
        req.params.put('content_type','image/png');
        req.requestBody = Blob.valueOf('""');
        MCareDashboardAPIController.createActivationDocument();
        
        req.params.put('merchant_id', string.valueOf(opportunityObj.Prod_Merchant_Id__c));        
        req.params.put('ticket_id', '98765432');
        req.params.put('product_name','PayUmoney');
        MCareDashboardAPIController.getDocumentStatus();
        req.params.put('transaction_id','567899');
        req.requestBody = Blob.valueOf('""');
        MCareDashboardAPIController.createActivationDocument();
        
    }
    
    public static testMethod void testData2(){
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MCareDashboardController';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        MCareDashboardAPIController.createActivationDocument();
        MCareDashboardAPIController.getDocumentStatus();
        
        req.params.put('merchant_id', '44353');        
        MCareDashboardAPIController.createActivationDocument();
        MCareDashboardAPIController.getDocumentStatus();
        
        req.params.put('merchant_id','434324324');        
        req.params.put('ticket_id', '3242432');
        MCareDashboardAPIController.createActivationDocument();
        MCareDashboardAPIController.getDocumentStatus();
        
        req.params.put('merchant_id', '998776');        
        req.params.put('ticket_id', '876');
        req.params.put('product_name','PayUmoney');
        MCareDashboardAPIController.createActivationDocument();
        MCareDashboardAPIController.getDocumentStatus();
        
        req.params.put('merchant_id', '34567');        
        req.params.put('ticket_id', '456789');
        req.params.put('product_name','PayUmoney');
        req.requestBody = Blob.valueOf('tevv');
        MCareDashboardAPIController.createActivationDocument();
        
    }
    
    
}