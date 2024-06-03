@isTest
public class LeadScoreTriggerTracker {
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Lead_Score__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Lead_Score__c LeadScoreObj = new Lead_Score__c();
        LeadScoreObj.Stage__c = 'PanInfoGiven';
        LeadScoreObj.UUID__c = '11ed-3e37-a92d18a2-993a-02053299b2da';
        //LeadScoreObj.Merchant_UUID__c = '11ed-3e37-a92d18a2-993a-02053299b2da';
        
        insert LeadScoreObj;
        System.assertEquals('PanInfoGiven', [SELECT id, Stage__c FROM Lead_Score__c WHERE Id =: LeadScoreObj.Id].Stage__c);    
        
        Test.stopTest();
    }

}