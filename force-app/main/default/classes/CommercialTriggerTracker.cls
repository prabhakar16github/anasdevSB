@isTest
public class CommercialTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Commercial__c', true);
        insert triggerSwitchObj ;
		
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
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
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);     
        
        Plan__c planObj = CommonDataTracker.insertPlan('Pay Citrus');
        insert planObj;
        System.assertEquals('Pay Citrus', [SELECT id, Name FROM Plan__c WHERE Id =: planObj.Id].Name);
    }
    
    @isTest static void testMethodOne(){        
        Account accountObj = [SELECT id, PAN_Number__c FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity WHERE AccountId =: accountObj.Id]; 

		Plan__c planObj = [SELECT id, Name FROM Plan__c LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Commercial__c commercialObj = CommonDataTracker.insertCommercial(opportunityObj, planObj);
        insert  commercialObj;
        System.assertEquals(opportunityObj.Id, [SELECT id, Opportunity__c FROM Commercial__c WHERE Id =: commercialObj.Id].Opportunity__c);
        
        Commercial__c commercialObj1 = new Commercial__c();
        commercialObj1.Id = commercialObj.Id;
        commercialObj1.Identifier__c = 'gvjkml';
        update commercialObj;
        
        Test.stopTest();
    }
}