@isTest
public class PricingPOTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('PricingPaymentOption__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();    
        PricingPaymentOption__c PricingPayOptionObj = new PricingPaymentOption__c();
        PricingPayOptionObj.Active__c = true;
        insert PricingPayOptionObj;
        Test.stopTest();
    }
}