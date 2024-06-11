trigger MerchantDocTrigger on Merchant_Document__c(before Insert, after insert, before update, before delete, after update, after delete){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Merchant_Document__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){
        if(Trigger.isBefore){
            if(Trigger.isInsert)    MerchantDocTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate)    MerchantDocTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
            if(Trigger.isDelete)    MerchantDocTriggerHandler.beforeDeleteHandler(Trigger.old);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert)    MerchantDocTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate)    MerchantDocTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            if(Trigger.isDelete)    MerchantDocTriggerHandler.afterDeleteHandler(Trigger.old);
        }
    }
}