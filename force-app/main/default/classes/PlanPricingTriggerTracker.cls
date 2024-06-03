@isTest
public class  PlanPricingTriggerTracker{
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Plan_Pricing__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Plan_Pricing__c planPricingObj = new Plan_Pricing__c();
        planPricingObj.Active__c = true;
        insert planPricingObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Plan_Pricing__c WHERE Id =: planPricingObj.Id].Active__c); 
        
        Plan_Pricing__c planPricingObj1 = new Plan_Pricing__c();
        planPricingObj1.Id = planPricingObj.Id;
        planPricingObj1.Authorize_Channel__c = 'jhghjg';
        update planPricingObj1;
        
        Test.stopTest();
    }
}