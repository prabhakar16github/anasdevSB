trigger UserTrigger on User (Before Insert){
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('User');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(Trigger.isBefore){
            if(Trigger.isInsert) UserTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}