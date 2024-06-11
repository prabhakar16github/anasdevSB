trigger PlanTrigger on Plan__c(Before Insert, after Insert, after update){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Plan__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) PlanTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) PlanTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) PlanTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}