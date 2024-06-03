@isTest
public class AWSConsumerBatchTracker {
        
    @testSetup static void setupCommonData(){  
        Publisher_Flag_for_Payload__mdt pub = new Publisher_Flag_for_Payload__mdt();
        pub.Prevent_AwsConsumer_Batch__c = false;
        //insert pub;
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '6b66-1940-e2950947-5809-13fb6474c3f3';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);  
        
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
        opportunityObj.Website__c = 'test.com';
        opportunityObj.Integration_Type__c = 'ThirdParty';
        opportunityObj.Identifier__c = '11ec-00fa-f2121ade-b55b-0242a53cdb42';
        opportunityObj.Website_Status__c = 'Verification in Process';
        opportunityObj.iOS_URL__c = 'test1.com';
        opportunityObj.Android_URL__c ='test2.com';
        
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);    
    }
    
    @isTest static void testMethodOne() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XMLMockClass());
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethodTwo() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethodThree_1() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new payUbizSettlementMockResponse());
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethodThree_2() {            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new payUbizSettlementMockResponse());
         
        Database.executeBatch(new AWSConsumerBatch()); 
        
        Test.stopTest();        
    }
    
    @isTest static void testMethodFour() {            
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new payUbizBankMockResponse());
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethodFive() {  
        Account accountObj = [Select Id from Account LIMIT 1];
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new deleteMockResponse());
         
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethodSix() {            
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new createProductMockResponse());
         
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethodSeven() {            
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new updateMDocMockResponse());
         
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethod8() {            
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new consumeOnboardingConfigResponse());
         
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethod9() {            
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new consumeLoginConfigMockResponse());
         
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethod10() {            
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new consumeBankDetailConfigMockResponse());
         
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    @isTest static void testMethod11() {   
        Opportunity opportunityObj = [Select Id from Opportunity LIMIT 1];
        
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new consumeMerchantStatusResponse());
         
        Database.executeBatch(new AWSConsumerBatch());           
        Test.stopTest();        
    }
    
    public class bankMockResponse implements HttpCalloutMock{     
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLBankBody);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class payUbizSettlementMockResponse implements HttpCalloutMock{     
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLBizData);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class payUbizBankMockResponse implements HttpCalloutMock{     
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLBizBankData);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class deleteMockResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLDeleteData);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class createProductMockResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLCreateProductData);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class updateMDocMockResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLMerchantDocData);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class consumeBankDetailConfigMockResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLBankDetailData);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class consumeLoginConfigMockResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLloginURLData);
            res.setStatusCode(200); 
            return res;
        }
    }
    
    public class consumeOnboardingConfigResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLOnboardingConfigData);
            res.setStatusCode(200); 
            return res;
        }
    }
        
        public class consumeMerchantStatusResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestXMLMerchantStatusData);
            res.setStatusCode(200); 
            return res;
        }
    }
}