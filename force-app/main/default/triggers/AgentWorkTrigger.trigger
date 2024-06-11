trigger AgentWorkTrigger on Agentwork (after update, after insert, Before Insert, Before Update) {
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Agentwork');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isAfter){
            if(Trigger.isInsert) {
                AgentWorkTriggerHandler.afterInsertHandler(Trigger.new);
                OneCareAgentWorkTriggerHandler.afterInsertAgentWork(Trigger.New);
            }
            
            if(Trigger.isUpdate) {
                AgentWorkTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
             	OneCareAgentWorkTriggerHandler.afterUpdateAgentWork(Trigger.new, Trigger.oldMap);
            }
        }
    }

}