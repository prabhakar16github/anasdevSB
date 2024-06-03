@isTest
public class TDRTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('TDR__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        TDR__c tdrObj = new TDR__c();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        tdrObj.Active__c = true;
        insert tdrObj;
        System.assertEquals(true, [SELECT id, Active__c FROM TDR__c WHERE Id =: tdrObj.Id].Active__c);    
        
        TDR__c tdrObj1 = new TDR__c(Id=tdrObj.Id);
        tdrObj1.Active__c = true;
        update tdrObj1;
        
        Test.stopTest();
    }
}