@isTest
public class RiskScoreTriggerTracker {
    
    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Risk_Score__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Risk_Score__c RiskScoreObj = new Risk_Score__c();
        RiskScoreObj.Stage__c = 'BankInfoGiven';
        RiskScoreObj.UUID__c = '11ed-1a0e-08277b66-a475-02053299b2da';
        insert RiskScoreObj;
        System.assertEquals('BankInfoGiven', [SELECT id, Stage__c FROM Risk_Score__c WHERE Id =: RiskScoreObj.Id].Stage__c);    
        
        Test.stopTest();
    }

}