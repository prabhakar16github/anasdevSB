trigger AccountTrigger on Account (after update, after insert, Before Insert, Before Update) {
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Account');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    AccountTriggerHandler.beforeInsertHandler(Trigger.new);
            
            if(Trigger.isUpdate)     AccountTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert)    AccountTriggerHandler.afterInsertHandler(Trigger.new);
            
            if(Trigger.isUpdate)    AccountTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}