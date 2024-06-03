@isTest
public class POPGMappingTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('PO_PG_Mapping__c', true);
        insert triggerSwitchObj ; 
        
        Payment_Gateway__c payGateObj = CommonDataTracker.insertPaymentGateway();
        payGateObj.Active__c = true;
        insert payGateObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment_Gateway__c WHERE Id =: payGateObj.Id].Active__c);
        
        Payment_Option__c payOptObj = new Payment_Option__c();
        payOptObj.Active__c = true;
        insert payOptObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment_Option__c WHERE Id =: payOptObj.Id].Active__c);
    }
    
    @isTest static void testMethodOne(){    
        Payment_Gateway__c payGateObj = [SELECT id, Active__c FROM Payment_Gateway__c LIMIT 1];
        
        Payment_Option__c payOptObj = [SELECT id, Active__c FROM Payment_Option__c LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        PO_PG_Mapping__c poPGMapObj = new PO_PG_Mapping__c();
        poPGMapObj.Payment_Gateway__c = payGateObj.Id;
        poPGMapObj.Payment_Option__c = payOptObj.Id;
        poPGMapObj.Active__c = true; 
        insert poPGMapObj;
        System.assertEquals(true, [SELECT id, Active__c FROM PO_PG_Mapping__c WHERE Id =: poPGMapObj.Id].Active__c);    
        
        PO_PG_Mapping__c poPGMapObj1 = new PO_PG_Mapping__c();
        poPGMapObj1.Id = poPGMapObj.Id;
        poPGMapObj1.Identifier__c = '87676';
        update poPGMapObj1;
        
        Test.stopTest();
    }
}