@isTest
public class DocuMasterTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Document_Master__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Document_Master__c DocMasObj = new Document_Master__c();
        DocMasObj.Active__c = true;
        insert DocMasObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Document_Master__c WHERE Id =: DocMasObj.Id].Active__c);    
        
        Test.stopTest();
    }
}