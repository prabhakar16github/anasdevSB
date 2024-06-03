/*
* Name of the class : AwsConsumerAPI_Test
* Author's Name     : Rohit Gupta  
* Created Date      : 22th Sep, 2022
* Description       : Test Class for AwsConsumerAPI_CTRL.
* Version.          : 1   
*/ 
@isTest
public class AwsConsumerAPI_Test {
    static XmlFileStore__mdt xml = [Select CreateLeadXML__c ,CreateMerchanAccountStatustXML__c ,ApiURL__c  ,UpdateLeadXML__c  FROM XmlFileStore__mdt ];

    @testSetup static void setupCommonData(){  
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
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(xml.CreateLeadXML__c);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();
        AwsConsumerAPI_CTRL.finishFromApi();
        Test.stopTest();        
    }
    
    @isTest static void testMethodTwo() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(xml.CreateMerchanAccountStatustXML__c);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
    
    @isTest static void testMethodThree() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(xml.UpdateLeadXML__c);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
     @isTest static void testMethodFive() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonBizData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
     @isTest static void testMethodSix() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonDeleteData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
     @isTest static void testMethodSeven() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TextJsonCreateProductData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
    @isTest static void testMethodEight() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonBankBody);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
     @isTest static void testMethodNine() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonBizBankData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
     @isTest static void testMethodTen() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonMerchantDocData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
    @isTest static void testMethod11() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonBankDetailData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
    @isTest static void testMethod12() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonLoginUrlData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
    @isTest static void testMethod13() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonOnboardingConfigData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
     @isTest static void testMethod14() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new bankMockResponse());
        RestRequest request = new RestRequest();
        request.requestUri =xml.ApiURL__c;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(Label.TestJsonMerchantStatusData);
        RestContext.request = request;
        AwsConsumerAPI_CTRL.parseXML();     
        Test.stopTest();        
    }
    public class bankMockResponse implements HttpCalloutMock{     
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');            
            res.setBody(Label.TestJsonBankBody);
            res.setStatusCode(200); 
            return res;
        }
    }
}