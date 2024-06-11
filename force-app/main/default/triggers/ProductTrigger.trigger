trigger ProductTrigger on Product__c(Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Product__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    ProductTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}