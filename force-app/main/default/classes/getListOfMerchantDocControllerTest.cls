@isTest
public class getListOfMerchantDocControllerTest{
    
    @testSetup static void setupCommonData(){     
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT Id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);      
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        businessCategoryNGO.Doable__c = true;
        businessCategoryNGO.Categories_For__c = 'Merchant';
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT Id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        System.assertEquals('Address Proof', [SELECT Id, Name FROM Document_Category_Master__c WHERE Id =: docCategoryMasterObj.Id].Name);  
        
        Id addendumRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Merchant Document').getRecordTypeId();
        
        Document_Master__c docMasterAddendumObj = CommonDataTracker.insertDocumentMaster('Passport', docCategoryMasterObj, addendumRecordTypeId, 'ServiceAgreementHUF');
        insert docMasterAddendumObj ;
        System.assertEquals(docCategoryMasterObj.Id, [SELECT Id, Document_Category__c FROM Document_Master__c WHERE Id =: docMasterAddendumObj.Id].Document_Category__c);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Delivery_Duration__c = 9;
        accountObj.Monthly_Expected_Sale__c = 5.0;
        accountObj.Transaction_Facility_Required__c = 'Domestic';
        accountObj.Business_Category__c = businessCategoryNGO.Id;
        accountObj.type__c = 'Merchant';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Merchant_Id__c = 82646;
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Account accountObj1 = CommonDataTracker.insertAccount('Test Account1', 'LegalName86673', 'GKMSF4892W');
        accountObj1.type__c = 'Partner';
        
        insert accountObj1;
        
        Merchant_Document__c merchantDocObj = CommonDataTracker.insertMerchantDoc(accountObj);
        merchantDocObj.Document_Category__c = docCategoryMasterObj.Id;
        merchantDocObj.Onboarding_Status__c = 'Declined';
        insert merchantDocObj;
        
        Bank_Account_Detail__c bankObj = CommonDataTracker.insertBankAccDetails(null, opportunityObj.Id);
        insert bankObj;
        Test.stopTest();  
    }
    
    @isTest static void testMethodOne(){
        
        Id accountObj = [SELECT Id FROM Account LIMIT 1].id;
        
        Test.startTest();
        getListOfMerchantDocController getList = new getListOfMerchantDocController();
        getList.strAccountId = accountObj;
        getList.getlstofMercDoc();
        getList.getListofFailedDocuments();
        Test.stopTest();
    }    
    
    @isTest static void testMethodTwo(){
        
        Id bankObj = [SELECT Id FROM Bank_Account_Detail__c LIMIT 1].id;
        
        Test.startTest();
        getListOfMerchantDocController getList = new getListOfMerchantDocController();
        getList.strAccountId = bankObj;
        getList.getlstofMercDoc();
        Test.stopTest();
    }   
    
}