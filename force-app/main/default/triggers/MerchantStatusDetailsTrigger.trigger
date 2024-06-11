trigger MerchantStatusDetailsTrigger on Merchant_Status_Details__c (before insert, after insert, before update, after update) {

    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Merchant_Status_Details__c');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(Trigger.isAfter){
            if(Trigger.isInsert) MerchantStatusDetailsTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) MerchantStatusDetailsTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isBefore){
            if(Trigger.isInsert) MerchantStatusDetailsTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate) MerchantStatusDetailsTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}