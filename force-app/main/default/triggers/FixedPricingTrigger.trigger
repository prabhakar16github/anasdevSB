trigger FixedPricingTrigger on Fixed_Pricing1__c (before update) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Fixed_Pricing1__c');
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        
        switch on Trigger.OperationType  {
            when BEFORE_UPDATE {
                FixedPricingTriggerHandler.beforeUpdateHandler(Trigger.new,Trigger.oldMap);
            }
        }
    }
}