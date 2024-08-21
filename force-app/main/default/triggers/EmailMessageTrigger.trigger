trigger EmailMessageTrigger on EmailMessage (Before Insert,after update,after insert) {
	Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('EmailMessage');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) {
                oneCareEmailToCaseTriggerHandler.beforeInsertHandler(Trigger.new);
                EmailMessageTriggerHandler.beforeInsertHandler(Trigger.new);
            }   
            
        }
        
        if (Trigger.isAfter){
            if(Trigger.isInsert){ 
                EmailMessageTriggerHandler.afterInsertHandler(Trigger.new);
                oneCareEmailToCaseTriggerHandler.afterInsertHandler(Trigger.new);
            }
            if (trigger.isupdate){
                EmailMessageTriggerHandler.afterUpdateHandler(trigger.new,trigger.oldmap);
            }
        }
        
    }
}