@isTest
public class PGKeysTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('PG_Keys__c', true);
        insert triggerSwitchObj ;
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        PG_Keys__c pgKeysObj = new PG_Keys__c();
        pgKeysObj.Active__c = true;
        insert pgKeysObj;
        System.assertEquals(true, [SELECT id, Active__c FROM PG_Keys__c WHERE Id =: pgKeysObj.Id].Active__c);    
        
        
        PG_Keys__c pgKeysObj1 = new PG_Keys__c();
        pgKeysObj1.Id = pgKeysObj.Id;
        pgKeysObj1.Key__c = 'fgjkjl';
        update pgKeysObj1;
        
        Test.stopTest();
    }
}