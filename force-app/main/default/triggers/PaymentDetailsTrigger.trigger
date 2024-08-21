trigger PaymentDetailsTrigger on Payment_Details__c (Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Payment_Details__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    PaymentDetailsTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}