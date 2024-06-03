@isTest
public class FeeMasterTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Fee_Master__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Fee_Master__c feeMastObj = new Fee_Master__c();
        feeMastObj.Active__c = true;
        insert feeMastObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Fee_Master__c WHERE Id =: feeMastObj.Id].Active__c);    
        
        Test.stopTest();
    }
}