@isTest
public class MCPDetailTriggerTracker{
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('MCP_Detail__c', true);
        insert triggerSwitchObj ;        
    }
    
    @isTest static void testMethodOne(){        
        Test.startTest();
        
        MCP_Detail__c mcpDetObj = new MCP_Detail__c();
        mcpDetObj.Identifier__c = 'Identifier';
        insert mcpDetObj;
        System.assertEquals('Identifier', [SELECT id, Identifier__c FROM MCP_Detail__c WHERE Id =: mcpDetObj.Id].Identifier__c);    
        
        Test.stopTest();
    }
}