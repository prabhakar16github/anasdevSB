trigger PaymentTrigger on Payment__c(Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Payment__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    PaymentTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}