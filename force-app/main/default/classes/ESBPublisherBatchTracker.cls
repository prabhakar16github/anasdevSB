@isTest
public class ESBPublisherBatchTracker{
    
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Address_Details__c', true);
        insert triggerSwitchObj ; 
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        EStampMasterObj.Used__c = false; 
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.Id].AccountId);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].Id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.Id].AccountId);
        
        /*Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, 'Registered');
        insert  addDetailsRegObj;
        System.assertEquals(accountObj.Id, [SELECT id, Account__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Account__c);
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(null, accountObj.Id, 'Operating');
        insert  addDetailsOpeObj;
        System.assertEquals(accountObj.Id, [SELECT id, Account__c FROM Address_Details__c WHERE id =: addDetailsOpeObj.Id].Account__c);*/
    }
    
    @isTest static void testMethodOne(){        
        Account accountObj = [SELECT Id, PAN_Number__c FROM Account LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Database.executeBatch(new ESBPublisherBatch(new List<Account>{accountObj },null,false,true,false,false,'Account', 'Account')); 
        Test.stopTest();
    }
}