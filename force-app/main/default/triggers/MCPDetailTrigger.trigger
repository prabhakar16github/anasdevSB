trigger MCPDetailTrigger on MCP_Detail__c (Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('MCP_Detail__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    MCPDetailTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}