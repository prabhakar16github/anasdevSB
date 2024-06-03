@isTest
public class MPOTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('MerchantPaymentOption__c', true);
        insert triggerSwitchObj;
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        MerchantPaymentOption__c mpoObj = new MerchantPaymentOption__c();
        mpoObj.Active__c = true;
        insert mpoObj; 
        
        MerchantPaymentOption__c mpoObj1 = new MerchantPaymentOption__c(Id=mpoObj.Id);
        //mpoObj1.Status__c = 'Activated';
        update mpoObj1;
        
        Test.stopTest();
    }
}