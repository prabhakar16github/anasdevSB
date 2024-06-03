@isTest
public class PlatformTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Platform__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest(); 
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        Test.stopTest();
    }
}