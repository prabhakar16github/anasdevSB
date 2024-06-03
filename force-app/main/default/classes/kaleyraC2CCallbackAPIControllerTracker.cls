@isTest
public class kaleyraC2CCallbackAPIControllerTracker {
	@testSetup
    public static void commonData(){
        
         Lead leadobj =new Lead();
        leadobj.FirstName = 'Test';
        leadobj.LastName = 'Test';
        leadobj.MobilePhone = '8080808080';
        leadobj.Email = 'p@gmail.com';
        leadobj.Company = 'ABC Pvt Ltd.';
        leadobj.Identifier__c= '11e9-ec55-b3f5bc58-ae1d-02c11504db8f';
        insert leadobj;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('Pay Money');
        insert platformObj;
        System.assertEquals('Pay Money', [SELECT id,Name FROM Platform__c WHERE id =: platformObj.Id].Name);
        Entity__c EntityObj = CommonDataTracker.insertEntity('Test BEntity');
        insert EntityObj;
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c productObj  = CommonDataTracker.insertCustomProduct('Pay Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert productObj;
        System.assertEquals('Pay Money', [SELECT id,Name FROM Product__c WHERE id =: productObj.Id].Name);
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'LegalTestName', 'BMUPA1234Q');
        accountObj.Business_Entity__c = EntityObj.Id;
        accountObj.Type__c = 'Merchant';
        accountObj.Identifier__c = '0009990099';
        insert accountObj;
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Product__c = productObj.Id;
        opportunityObj.Identifier__c = 'uuid88990045';
        opportunityObj.Lead_Type__c = 'Merchant';
        opportunityObj.Identifier__c= '11e9-ec55-b3f5bc58-ae1d-02c11504db9e';
        insert opportunityObj;
        
        MCare_Dashboard_Case__c mCareObj = New MCare_Dashboard_Case__c();
        mCareObj.Customer1_Phone__c = '8765435678';
        mCareObj.Identifier__c = '23455676789fgghhjjkkk';
        insert mCareObj;
    }
    @isTest
    public static void testDoPost1(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/kaleyraC2CCallbackAPI/';  
        String postData = '{"identifier":"11e9-ec55-b3f5bc58-ae1d-02c11504db9e","Manual_Call_response":"jskchsudihcoischio","Audio_Clip":"jsdhkjahds","Call_Type":"C2C"}';
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        kaleyraC2CCallbackAPIController.updateCallbackOpportunity(); 
        Test.stopTest();
        
    }
    @isTest
    public static void testDoPost2(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/kaleyraC2CCallbackAPI/';  
        String postData = '{"identifier":"","Manual_Call_response":"jskchsudihcoischio","Audio_Clip":"jsdhkjahds","Call_Type":"C2C"}';
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        kaleyraC2CCallbackAPIController.updateCallbackOpportunity(); 
        Test.stopTest();
        
    }
    
    @isTest
    public static void testDoPost3(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/kaleyraC2CCallbackAPI/';  
        String postData = '{"identifier":"11e9-ec55-b3f5bc58-ae1d-02c11504db8f","Manual_Call_response":"jskchsudihcoischio","Audio_Clip":"jsdhkjahds","Call_Type":"C2C"}';
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        kaleyraC2CCallbackAPIController.updateCallbackOpportunity(); 
        Test.stopTest();
        
    }
    
    @isTest
    public static void testDoPost4(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/kaleyraC2CCallbackAPI/';  
        String postData = '{"identifier":"23455676789fgghhjjkkk","Manual_Call_response":"jskchsudihcoischio","Audio_Clip":"jsdhkjahds","Call_Type":"C2C","customer_number":"8765435678"}';
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        kaleyraC2CCallbackAPIController.updateCallbackOpportunity(); 
        Test.stopTest();
        
    }
}