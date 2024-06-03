@isTest
public class DocuTypeMasterTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Document_Type_Master__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        Document_Type_Master__c docTypeMasObj = new Document_Type_Master__c();
        docTypeMasObj.Active__c = true;
        insert  docTypeMasObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Document_Type_Master__c WHERE Id =:  docTypeMasObj.Id].Active__c);    
        
        Test.stopTest();
    }
}