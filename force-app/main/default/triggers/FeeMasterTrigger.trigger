trigger FeeMasterTrigger on Fee_Master__c (Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Fee_Master__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    FeeMasterTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}