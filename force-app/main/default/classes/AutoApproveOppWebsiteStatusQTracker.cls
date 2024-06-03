@isTest
public class AutoApproveOppWebsiteStatusQTracker {

    @testSetup static void setupCommonData(){
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
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
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity optyObj = CommonDataTracker.insertOpportunity(accountObj);
        optyObj.Product__c = prodObj.Id;
        optyObj.Re_Published__c = true;
        optyObj.Integration_Type__c = 'ThirdParty';
        insert optyObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: optyObj.id].AccountId);
    }
    
    static testmethod void testOne() {
        Opportunity optyObj = [SELECT Name, Re_Published__c FROM Opportunity WHERE Website__c = 'test.com'];
        
        Test.startTest();        
        System.enqueueJob(new AutoApproveOppWebsiteStatusQueueable(new List<Opportunity> {optyObj}));
        Test.stopTest();
        
    }
    
    static testmethod void testTwo() {
        Opportunity optyObj = [SELECT Name, Re_Published__c, Website_Status__c FROM Opportunity WHERE Re_Published__c = true];
        
        Test.startTest();        
        System.enqueueJob(new AutoApproveOppWebsiteStatusQueueable(new List<Opportunity> {optyObj}));
        Test.stopTest();
    }
}