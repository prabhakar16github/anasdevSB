trigger ContactTrigger on Contact (Before Insert,after Insert,after update){
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Contact');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    ContactTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if (Trigger.isAfter){
            if(Trigger.isInsert)    ContactTriggerHandler.afterInsertHandler(Trigger.new);
            if (trigger.isupdate){
                ContactTriggerHandler.afterUpdateHandler(trigger.new,trigger.oldmap);
            }
        }
        
    }
}