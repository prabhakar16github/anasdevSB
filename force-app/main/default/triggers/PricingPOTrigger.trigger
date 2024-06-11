trigger PricingPOTrigger on PricingPaymentOption__c(Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('PricingPaymentOption__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) PricingPOTriggerHandler.beforeInsertHandler(Trigger.new);
        }        
    }
}