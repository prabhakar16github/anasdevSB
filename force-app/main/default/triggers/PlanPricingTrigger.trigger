trigger PlanPricingTrigger on Plan_Pricing__c(Before Insert, after Insert, after update){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Plan_Pricing__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) PlanPricingTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) PlanPricingTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) PlanPricingTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}