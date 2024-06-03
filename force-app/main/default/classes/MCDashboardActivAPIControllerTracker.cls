@isTest
public class MCDashboardActivAPIControllerTracker {
    
    @testSetup static void setupCommonData(){
        
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        insert triggerSwitchObj ;
        
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
        insert enableUUIDObjObj;
        
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj;
        
        Product__c prodObj2 = CommonDataTracker.insertCustomProduct('EMI', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj2;
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        
        
        Contact oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        oContact.AccountId = accountObj.id;
        insert oContact;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj.Prod_Merchant_Id__c = 45678789;
        opportunityObj.Product__c = prodObj.Id;    
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        Test.stopTest(); 
        
    }
    
    public static testMethod void testData1(){
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];    
        
        Product__c prodObj = [Select Id from Product__c Where Name = 'PayU Money' LIMIT 1];
        
        Product__c prodObj2 = [Select Id from Product__c Where Name = 'EMI' LIMIT 1];
        
        Account accountObj = [Select Id from Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = [Select Id from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Opportunity opportunityObj = [Select Id,ProductLabel__c, Prod_Merchant_Id__c from Opportunity LIMIT 1];
        
        Contact oContact = [Select Id from Contact LIMIT 1];
        
        Cross_Sell__c csObj = New Cross_Sell__c();
        csObj.Name = 'EMI';
        csObj.Custom_Product__c = prodObj2.Id;
        csObj.Risk_Zone__c = 'Green Zone';
        csObj.Opportunity__c = opportunityObj.Id;
        insert csObj;
        
        string JsonMsg = '{"merchant_id":"678789","product_name":"PayUmoney","sellProduct_name":"EMI","activation_date":"2015-12-09 12:22:13"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MCDashboardActivationAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        MCDashboardActivationAPIController.activateCrossSellProduct();
        
        string JsonMsg2 = '{"merchant_id":"45678789","product_name":"PayUmoney","sellProduct_name":"EMI","activation_date":"2015-12-09 12:22:13"}';
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/MCDashboardActivationAPI';
        req2.httpMethod = 'POST';
        req2.requestBody = Blob.valueof(JsonMsg2);
        RestContext.request = req2;
        RestContext.response= res2;
        
        MCDashboardActivationAPIController.activateCrossSellProduct();
        
        string JsonMsg3 = '{"merchant_id":"45678789","product_name":"PayUmoney","sellProduct_name":"","activation_date":"2015-12-09 12:22:13","product_type":"bank_update","addendum_status":"Approved"}';
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = '/services/apexrest/MCDashboardActivationAPI';
        req3.httpMethod = 'POST';
        req3.requestBody = Blob.valueof(JsonMsg3);
        RestContext.request = req3;
        RestContext.response= res3;
        
        MCDashboardActivationAPIController.activateCrossSellProduct();
    }
    
    public static testMethod void testData2(){
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Entity__c entityObj = [Select Id from Entity__c LIMIT 1];
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];    
        
        Product__c prodObj = [Select Id from Product__c Where Name = 'PayU Money' LIMIT 1];
        
        Account accountObj = [Select Id from Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = [Select Id from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Opportunity opportunityObj = [Select Id,ProductLabel__c, Prod_Merchant_Id__c from Opportunity LIMIT 1];
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Addendum').getRecordTypeId();
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);   
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        docMasterAddendumObj.Entity__c = entityObj.Id;
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        Contact oContact = [Select Id from Contact LIMIT 1];
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, oContact, opportunityObj, docMasterAddendumObj, 'Pending');
        contractObj.Type__c = 'Final';
        contractObj.Active__c = True;
        contractObj.Contract_Type__c = 'Addendum';
        contractObj.Opportunity__c = opportunityObj.id;
        contractObj.Name = 'EMI';
        insert contractObj;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj.Id].AccountId);
        
        string JsonMsg = '{"merchant_id":"45678789","product_name":"PayUmoney","sellProduct_name":"EMI","activation_date":"2015-12-09 12:22:13"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/MCDashboardActivationAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        MCDashboardActivationAPIController.activateCrossSellProduct();
        
        Contract contractObj2 = CommonDataTracker.insertContract(accountObj, oContact, opportunityObj, docMasterAddendumObj, 'Pending');
        contractObj2.Type__c = 'Final';
        contractObj2.Active__c = True;
        contractObj2.Contract_Type__c = 'Addendum';
        contractObj2.Opportunity__c = opportunityObj.id;
        contractObj2.Name = 'bank_update';
        insert contractObj2;
        System.assertEquals(accountObj.Id, [SELECT ID, AccountId FROM Contract WHERE Id =: contractObj2.Id].AccountId);
        System.assertEquals('bank_update', [SELECT ID, Name,AccountId FROM Contract WHERE Id =: contractObj2.Id].Name);
        System.assertEquals('Addendum', [SELECT ID, AccountId,Contract_Type__c FROM Contract WHERE Id =: contractObj2.Id].Contract_Type__c);
        System.assertEquals(opportunityObj.Id, [SELECT ID, AccountId,Opportunity__c FROM Contract WHERE Id =: contractObj2.Id].Opportunity__c);
        
        string JsonMsg3 = '{"merchant_id":"45678789","product_name":"PayUmoney","sellProduct_name":"","activation_date":"","product_type":"bank_update","addendum_status":"Approved"}';
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = '/services/apexrest/MCDashboardActivationAPI';
        req3.httpMethod = 'POST';
        req3.requestBody = Blob.valueof(JsonMsg3);
        RestContext.request = req3;
        RestContext.response= res3;
        
        MCDashboardActivationAPIController.activateCrossSellProduct();
    }
}