trigger PaymentOptionTrigger on Payment_Option__c(Before Insert, after Insert, after update){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Payment_Option__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) PaymentOptionTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) PaymentOptionTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) PaymentOptionTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}