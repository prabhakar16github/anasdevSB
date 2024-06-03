@isTest
public class BusinessCategoryTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Business_Category__c', true);
        insert triggerSwitchObj ;
    }
    
    @isTest static void testMethodOne(){  
        
        Test.startTest();
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Test.stopTest();
    }
}