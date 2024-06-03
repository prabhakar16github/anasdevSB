public class MCPDetailTriggerHandler{
    public static void beforeInsertHandler(List<MCP_Detail__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('MCP_Detail__c');         
        for(MCP_Detail__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
}