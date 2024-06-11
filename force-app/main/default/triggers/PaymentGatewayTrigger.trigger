trigger PaymentGatewayTrigger on Payment_Gateway__c(Before Insert, after Insert, after update){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Payment_Gateway__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) PaymentGatewayTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) PaymentGatewayTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) PaymentGatewayTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}