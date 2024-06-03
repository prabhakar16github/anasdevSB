@isTest
public class DocuCateMasterTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Document_Category_Master__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Document_Category_Master__c docCatMasObj = new Document_Category_Master__c();
        docCatMasObj.Active__c = true;
        insert  docCatMasObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Document_Category_Master__c WHERE Id =:  docCatMasObj.Id].Active__c);    
        
        Test.stopTest();
    }
}