@isTest
public class UploadMAFControllerTracker{
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Address_Details__c', true);
        insert triggerSwitchObj ; 
        
        /*Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    */
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        //accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c); 
        
        /*Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].Id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);*/
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        //opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.Id].AccountId);
        
        Lead leadObj = CommonDataTracker.insertLead();
        insert leadObj;
        
        //Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Registered');
       // insert  addDetailsRegObj;
        //System.assertEquals(accountObj.Id, [SELECT id, Account__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Account__c);
        
        /*Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, 'Operating');
        insert  addDetailsOpeObj;
        System.assertEquals(accountObj.Id, [SELECT id, Account__c FROM Address_Details__c WHERE id =: addDetailsOpeObj.Id].Account__c);*/
        
        //Lead leadObj = CommonDataTracker.insertLead(prodObj, null, null, entityObj);
        
        //System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        ContentVersion contentVersionObj =  CommonDataTracker.insertContentVersion('Test title');
        insert contentVersionObj;
    }
    
    @isTest static void testMethodForOpty(){        
        Account accountObj = [SELECT Id, PAN_Number__c FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity WHERE AccountId =: accountObj.Id];
        
        ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        ContentDocument contentDocumentObj = new ContentDocument();
        contentDocumentObj = [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                              from ContentDocument WHERE Id =: contentVersionObj.ContentDocumentId];
        
        Test.startTest();
         
        UploadMAFController.mafEnabledStatus(opportunityObj.Id);
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        UploadMAFController.getDetail(opportunityObj.Id, contentVersionObj.ContentDocumentId);
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.type__c = 'Secondary Contact';
        insert contactObj;
        
        UploadMAFController.mafEnabledStatus(opportunityObj.Id);
        UploadMAFController.getDetail(opportunityObj.Id, null);
        
        Test.stopTest();
    }
    
    @isTest static void testMethodForLead(){        
        Lead leadObj = [SELECT id, Product__c FROM Lead LIMIT 1];
        
        ContentVersion contentVersionObj = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        ContentDocument contentDocumentObj = new ContentDocument();
        contentDocumentObj = [select id, ContentSize, Description, FileExtension, FileType, ParentId, Title
                              from ContentDocument WHERE Id =: contentVersionObj.ContentDocumentId];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
         
        UploadMAFController.mafEnabledStatus(leadObj.Id);
        
        UploadMAFController.getDetail(leadObj.Id, contentVersionObj.ContentDocumentId);
        
        Bank_Account_Detail__c bankDetailObj = CommonDataTracker.insertBankAccDetails(leadObj.Id, null);
        bankDetailObj.Account_Number__c = '30551209999';
        bankDetailObj.IFSC_Code__c = 'SBIN0000001';
        insert bankDetailObj;
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Registered');
        insert addDetailsRegObj;
        
        UploadMAFController.mafEnabledStatus(leadObj.Id);
        
        UploadMAFController.getDetail(leadObj.Id, null);
        
        Test.stopTest();
    }
}