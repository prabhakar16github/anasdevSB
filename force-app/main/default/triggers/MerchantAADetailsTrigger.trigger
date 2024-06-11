trigger MerchantAADetailsTrigger on Merchant_Auto_Approval_Details__c (before insert, before update, after insert, after update) {

    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Merchant_Auto_Approval_Details__c');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(Trigger.isAfter){
            if(Trigger.isInsert) MerchantAADetailsTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) MerchantAADetailsTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isBefore){
            if(Trigger.isInsert) MerchantAADetailsTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate) MerchantAADetailsTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}