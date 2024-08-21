trigger EntityTrigger on Entity__c (Before Insert){
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Entity__c');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    EntityTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}