@isTest
public class AgreementManagerControllerTest {
    
    @testSetup 
    public static void setupCommonData(){
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id,Name FROM Platform__c WHERE id =: platformObj.Id].Name);
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c productObj  = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert productObj;
        System.assertEquals('PayU Money', [SELECT id,Name FROM Product__c WHERE id =: productObj.Id].Name);
        
        Entity__c EntityObj = CommonDataTracker.insertEntity('Test BEntity');
        insert EntityObj;
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'LegalTestName', 'BMUPA1234Q');
        accountObj.Business_Entity__c = EntityObj.Id;
        accountObj.Type__c = 'Merchant';
        accountObj.Identifier__c = '0009990099';
        insert accountObj;
        //System.assertEquals('LegalTestName-BMUPA1234Q', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Product__c = productObj.Id;
        opportunityObj.Identifier__c = 'uuid88990045';
        opportunityObj.Lead_Type__c = 'Merchant';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        E_Stamp_Master__c eStampObj = CommonDataTracker.insertEStampMaster('777888999');
        insert eStampObj;
        
        Document_Category_Master__c docCatObj = CommonDataTracker.insertDocCategoryMaster('docCatMaster');
        insert docCatObj;
        
        Id recordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterObj = CommonDataTracker.insertDocumentMaster('docMaster', docCatObj, recordTypeId, 'testPageAssociation1');
        docMasterObj.Entity__c = EntityObj.Id;
        docMasterObj.Product__c = productObj.Id;
        docMasterObj.Document_For__c = 'Merchant';
        insert docMasterObj;
    }
    
    static testMethod void testFailure(){
        
         Document_Master__c docObj = [SELECT id, Name FROM Document_Master__c LIMIT 1 ];
        docObj.Document_For__c = 'Partner';
        update docObj;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/generateAgreement/';  
        String postData = '{"merchant_uuid" : "uuid88990045"}';
        //String JsonMsg=JSON.serialize(postData);
        //String js = JsonMsg.removeStart('"').removeEnd('"');
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        AgreementManagerController.getAgreementUrl(); 
        Test.stopTest();
        
    }
     static testMethod void testFailurenewwithContract(){
     
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        insert EStampMasterObj;
        Account accountObj =[SELECT id,Name, Business_Entity__c, Identifier__c FROM Account LIMIT 1];
        Opportunity opportunityObj = [SELECT id FROM Opportunity LIMIT 1];
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        
        Document_Master__c docObj = [SELECT id, Name FROM Document_Master__c LIMIT 1 ];
        docObj.Document_For__c = 'Merchant';
        update docObj;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj, docObj, 'Draft Sent');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Type__c = 'Final';
        insert contractObj;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/generateAgreement/';  
        String postData = '{"merchant_uuid" : "uuid88990045"}';
        //String JsonMsg=JSON.serialize(postData);
        //String js = JsonMsg.removeStart('"').removeEnd('"');
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        AgreementManagerController.getAgreementUrl(); 
        Test.stopTest();
        
    }
    
    static testMethod void testDoPost2(){
        
        Account accObj = [SELECT Id FROM Account WHERE Identifier__c = '0009990099' LIMIT 1];
        Product__c productObj = [SELECT Id FROM Product__c WHERE Name= 'PayU Money' LIMIT 1];
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accObj);
        opportunityObj.Product__c = productObj.Id;
        opportunityObj.Identifier__c = 'uuid78990045';
        opportunityObj.Lead_Type__c = 'Aggregator';
        opportunityObj.Android_URL__c = 'abc.com';
        opportunityObj.iOS_URL__c = 'abc.com';
        opportunityObj.Website__c = 'abc.com';
        insert opportunityObj;
        System.assertEquals(accObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/generateAgreement/';  
        String postData = '{"merchant_uuid" : "uuid78990045"}';
        //String JsonMsg=JSON.serialize(postData);
        //String js = JsonMsg.removeStart('"').removeEnd('"');
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        AgreementManagerController.getAgreementUrl(); 
        Test.stopTest();
        
    }
    
    static testMethod void testDoPost3(){
        
        Account accObj = [SELECT Id,Identifier__c FROM Account WHERE Identifier__c = '0009990099' LIMIT 1];
        Product__c productObj = [SELECT Id FROM Product__c WHERE Name= 'PayU Money' LIMIT 1];
        Document_Master__c docObj = [SELECT id, Name,Customized_Agreement__c,RecordType.DeveloperName,Active__c,Document_For__c
                                     FROM Document_Master__c LIMIT 1 ];
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accObj);
        opportunityObj.Product__c = productObj.Id;
        opportunityObj.Identifier__c = 'uuid78990045';
        opportunityObj.Lead_Type__c = 'Merchant';
        opportunityObj.Android_URL__c = 'abc.com';
        opportunityObj.iOS_URL__c = 'abc.com';
        opportunityObj.Website__c = 'abc.com';
        insert opportunityObj;
        System.assertEquals(accObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/generateAgreement/';  
        String postData = '{"merchant_uuid" : "uuid78990045"}';
        //String JsonMsg=JSON.serialize(postData);
        //String js = JsonMsg.removeStart('"').removeEnd('"');
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        AgreementManagerController.getAgreementUrl(); 
        Test.stopTest();
        
    }
    static testMethod void testDoPost4(){
        
        Account accObj = [SELECT Id,Identifier__c FROM Account WHERE Identifier__c = '0009990099' LIMIT 1];
        Product__c productObj = [SELECT Id FROM Product__c WHERE Name= 'PayU Money' LIMIT 1];
         Document_Master__c docObj = [SELECT id, Name FROM Document_Master__c LIMIT 1 ];
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accObj);
        opportunityObj.Product__c = productObj.Id;
        opportunityObj.Identifier__c = 'uuid78990045';
        opportunityObj.Lead_Type__c = 'Partner';
        opportunityObj.Android_URL__c = 'abc.com';
        opportunityObj.iOS_URL__c = 'abc.com';
        opportunityObj.Website__c = 'abc.com';
     
        insert opportunityObj;
        System.assertEquals(accObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/generateAgreement/';  
        String postData = '{"merchant_uuid" : "uuid78990045"}';
        //String JsonMsg=JSON.serialize(postData);
        //String js = JsonMsg.removeStart('"').removeEnd('"');
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        AgreementManagerController.getAgreementUrl(); 
        Test.stopTest();
        
    }
    
    static testMethod void testDoPost5(){
        
        Account accObj = [SELECT Id,Identifier__c FROM Account WHERE Identifier__c = '0009990099' LIMIT 1];
        Product__c productObj = [SELECT Id FROM Product__c WHERE Name= 'PayU Money' LIMIT 1];
        Document_Master__c docObj = [SELECT id, Name,Customized_Agreement__c,RecordType.DeveloperName,Active__c,Document_For__c
                                     FROM Document_Master__c LIMIT 1 ];
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accObj);
        opportunityObj.Product__c = productObj.Id;
        opportunityObj.Identifier__c = 'uuid78990045';
        opportunityObj.Lead_Type__c = 'Merchant';
        opportunityObj.Android_URL__c = 'abc.com';
        opportunityObj.iOS_URL__c = 'abc.com';
        opportunityObj.Website__c = 'abc.com';
        insert opportunityObj;
        System.assertEquals(accObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Contact contObj = CommonDataTracker.insertContact(accObj);
        contObj.Email = 'asadsaf@payu.in';
            insert contObj;
        Contract contrObj = CommonDataTracker.insertContract(accObj,contObj,opportunityObj,docObj,'Pending');
        insert contrObj;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/generateAgreement/';  
        String postData = '{"merchant_uuid" : "uuid78990045"}';
        //String JsonMsg=JSON.serialize(postData);
        //String js = JsonMsg.removeStart('"').removeEnd('"');
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        AgreementManagerController.getAgreementUrl(); 
        Test.stopTest();
        
    }
}