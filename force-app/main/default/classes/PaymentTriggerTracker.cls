@isTest
public class PaymentTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Payment__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Payment__c paymentAMCObj = CommonDataTracker.insertPayment();
        paymentAMCObj.Charges_Type__c = 'AMC';
        insert paymentAMCObj;
        
        Test.stopTest();
    }
}