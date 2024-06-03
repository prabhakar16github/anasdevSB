@isTest
public class PaymentDetailsTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Payment_Details__c', true);
        insert triggerSwitchObj ;  
        
        Payment__c paymentAMCObj = CommonDataTracker.insertPayment();
        paymentAMCObj.Charges_Type__c = 'AMC';
        insert paymentAMCObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment__c WHERE Id =: paymentAMCObj.Id].Active__c);  
        
    }
    
    @isTest static void testMethodOne(){        
        Payment__c paymentAMCObj = [SELECT id, Name FROM Payment__c LIMIT 1];
        
        Test.startTest();
        
        Payment_Details__c payDetObj = new Payment_Details__c();
        payDetObj.Active__c = true;
        payDetObj.Payment__c = paymentAMCObj.Id;
        insert payDetObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment_Details__c WHERE Id =: payDetObj.Id].Active__c);    
        
        Test.stopTest();
    }
}