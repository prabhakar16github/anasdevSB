trigger MPOTrigger on MerchantPaymentOption__c(Before Insert, after Insert, after update){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('MerchantPaymentOption__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) MPOTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) MPOTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) MPOTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}