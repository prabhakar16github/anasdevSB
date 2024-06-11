trigger MerchantPlan on Merchant_Plan__c (after insert, after update, before insert, before update) {
    
    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('Merchant_Plan__c');
    
    if(trgSwitch != null && trgSwitch.Active__c){        
        if(Trigger.isAfter){
            if(Trigger.isInsert) MerchantPlanTriggerHandler.afterInsertHandler(Trigger.New); 
            if(Trigger.isUpdate) MerchantPlanTriggerHandler.afterUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
        
        if(Trigger.isBefore){            
            if(Trigger.isInsert) MerchantPlanTriggerHandler.beforeInsertHandler(Trigger.New);             
            if(Trigger.isUpdate) MerchantPlanTriggerHandler.beforeUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
    }
}