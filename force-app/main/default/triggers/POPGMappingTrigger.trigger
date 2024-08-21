trigger POPGMappingTrigger on PO_PG_Mapping__c(Before Insert, before update, after Insert, after update){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('PO_PG_Mapping__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) POPGMappingTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate) POPGMappingTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) POPGMappingTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) POPGMappingTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}