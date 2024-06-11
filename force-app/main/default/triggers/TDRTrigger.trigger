trigger TDRTrigger on TDR__c(Before Insert, after Insert, after update){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('TDR__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) TDRTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) TDRTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) TDRTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}