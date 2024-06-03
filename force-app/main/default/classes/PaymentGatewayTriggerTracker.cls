@isTest
public class PaymentGatewayTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Payment_Gateway__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Payment_Gateway__c payGateObj = CommonDataTracker.insertPaymentGateway();
        payGateObj.Active__c = true;
        insert payGateObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment_Gateway__c WHERE Id =: payGateObj.Id].Active__c);   
        
        Payment_Gateway__c payGateObj1 = new Payment_Gateway__c(Id=payGateObj.Id);
        update payGateObj1;
        
        Test.stopTest();
    }
}