@isTest
public class PaymentOptionTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Payment_Option__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Payment_Option__c payOptObj = new Payment_Option__c();
        payOptObj.Active__c = true;
        insert payOptObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment_Option__c WHERE Id =: payOptObj.Id].Active__c); 
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Payment_Option__c payOptObj1 = new Payment_Option__c(Id=payOptObj.Id);
        update payOptObj1;
        
        Test.stopTest();
    }
}