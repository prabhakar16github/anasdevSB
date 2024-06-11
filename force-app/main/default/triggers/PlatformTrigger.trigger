trigger PlatformTrigger on Platform__c(Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Platform__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    PlatformTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}