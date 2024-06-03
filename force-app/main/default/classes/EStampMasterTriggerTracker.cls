@isTest
public class EStampMasterTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('E_Stamp_Master__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        EStampMasterObj.Used__c = false; 
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
        Test.stopTest();
    }
}