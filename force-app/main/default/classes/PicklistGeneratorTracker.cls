@isTest
public class PicklistGeneratorTracker{
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Entity__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        PicklistGenerator.getPicklistValues('Lead', 'Status', 'Ram;Sahay;', true);
        
        PicklistGenerator.getSobjectRecords('SELECT Id, Name FROM Product__c WHERE Active__c = true', '', false, 'Name');
        Test.stopTest();
    }
}