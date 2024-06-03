@isTest
public class SubCategoryTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Sub_Category__c', true);
        insert triggerSwitchObj ;
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
    }
    
    @isTest static void testMethodOne(){   
        Business_Category__c businessCategoryNGO = [SELECT id, name FROM Business_Category__c LIMIT 1];
        
        Test.startTest();
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
        Test.stopTest();
    }
}