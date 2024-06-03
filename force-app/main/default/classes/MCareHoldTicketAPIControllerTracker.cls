@isTest
public class MCareHoldTicketAPIControllerTracker {

    @testSetup static void setupCommonData(){
        Test.startTest();
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
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
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Prod_Merchant_Id__c = 98321432;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Test.stopTest(); 
    }
    
    public static testMethod void testData_1(){
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,ProductLabel__c FROM Opportunity LIMIT 1];
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        Case caseObj = new Case();
        caseObj.ContactId=conObj.id;
        caseObj.AccountId=accObj.id;
        caseObj.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
        insert caseObj;
        
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/MCareHoldTicketAPI?mid='+oppObj.Prod_Merchant_Id__c+'&product='+oppObj.ProductLabel__c;
        request.httpMethod = 'PUT';
        
        RestContext.request = request;
        RestContext.response = response;
		MCareHoldTicketAPIController.getHoldTicketData();
        
        RestResponse response2 = new RestResponse();
        RestRequest request2 = new RestRequest();
        request2.requestUri ='/services/apexrest/MCareHoldTicketAPI';
        request2.addParameter('product', oppObj.ProductLabel__c);
        request2.addParameter('mid', '');
        request2.httpMethod = 'PUT';
        RestContext.request = request2;
        
        RestContext.response = response2;
		MCareHoldTicketAPIController.getHoldTicketData();
        
        RestResponse response3 = new RestResponse();
        RestRequest request3 = new RestRequest();
        request3.requestUri ='/services/apexrest/MCareHoldTicketAPI';
        request3.addParameter('mid', String.valueOf(oppObj.Prod_Merchant_Id__c));
        request3.addParameter('product', '');
        request3.httpMethod = 'PUT';
        RestContext.request = request3;
        
        RestContext.response = response3;
		MCareHoldTicketAPIController.getHoldTicketData();
        
        RestResponse response4 = new RestResponse();
        RestRequest request4 = new RestRequest();
        request4.requestUri ='/services/apexrest/MCareHoldTicketAPI';
        request4.addParameter('mid', String.valueOf(oppObj.Prod_Merchant_Id__c));
        request4.addParameter('product', oppObj.ProductLabel__c);
        request4.httpMethod = 'PUT';
        RestContext.request = request4;
        
        RestContext.response = response4;
		MCareHoldTicketAPIController.getHoldTicketData();
    }
    
    public static testMethod void testData_2(){
        Account accObj = [Select Id from Account LIMIT 1];
        
        Opportunity oppObj = [SELECT id, AccountId,Prod_Merchant_Id__c,ProductLabel__c FROM Opportunity LIMIT 1];
        
        Contact conObj = New contact();
        conObj.LastName = 'test';
        conObj.Email = 'xy@gmail.com';
        conObj.MobilePhone = '+911234567890';
        conObj.AccountId = accObj.id;
        conObj.Identifier__c = '4444477444';
        insert conObj; 
        
        Case caseObj = new Case();
        caseObj.ContactId=conObj.id;
        caseObj.AccountId=accObj.id;
        caseObj.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
        caseObj.Opportunity__c = oppObj.Id;
        caseObj.LP_Transaction_Reason__c = 'test Hold Reason';
        caseObj.TicketId__c = 'Test###213';
        caseObj.Status = 'New';
        caseObj.LP_Issue__c = 'Pricing Inquiry';
        caseObj.Payment_Id__c = '234242,234324';
        insert caseObj;
        
        system.assertEquals(98321432, oppObj.Prod_Merchant_Id__c);
        system.assertEquals('PayUmoney', oppObj.ProductLabel__c);
        
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/MCareHoldTicketAPI';
        request.addParameter('mid', String.valueOf(oppObj.Prod_Merchant_Id__c));
        request.addParameter('product', oppObj.ProductLabel__c);
        request.httpMethod = 'PUT';
        RestContext.request = request;
        
        RestContext.response = response;
		MCareHoldTicketAPIController.getHoldTicketData();
    }
}