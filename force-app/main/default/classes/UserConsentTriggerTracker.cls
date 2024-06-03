@isTest
public class UserConsentTriggerTracker {
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('User_Consent__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        User_Consent__c UserConsentObj = new User_Consent__c();
        UserConsentObj.UUID__c = '11ed-3e37-a92d18a2-993a-02053299b2da';
        insert UserConsentObj;
        System.assertEquals('11ed-3e37-a92d18a2-993a-02053299b2da', [SELECT id, UUID__c FROM User_Consent__c WHERE Id =: UserConsentObj.Id].UUID__c);    
        
        Test.stopTest();
    }

}