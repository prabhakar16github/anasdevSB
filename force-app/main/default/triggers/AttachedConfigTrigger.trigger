trigger AttachedConfigTrigger on Attached_Configuration__c (after update, after insert, Before Insert, Before Update) {
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Attached_Configuration__c');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    AttachedConfigTriggerHandler.beforeInsertHandler(Trigger.new);
            
            if(Trigger.isUpdate)     AttachedConfigTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert)	AttachedConfigTriggerHandler.afterInsertHandler(Trigger.new);
            
            if(Trigger.isUpdate)    AttachedConfigTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}