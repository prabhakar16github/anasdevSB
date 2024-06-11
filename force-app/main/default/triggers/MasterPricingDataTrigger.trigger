trigger MasterPricingDataTrigger on Master_Pricing_Data__c (after update) {
    Trigger_Switch__c triggerSwitch = Trigger_Switch__c.getInstance('Master Pricing Data');
    if(triggerSwitch != NULL && triggerSwitch.Active__c) {
        if(trigger.isAfter && trigger.isUpdate) {
        	MasterPricingDataTriggerHandler.afterUpdate(trigger.new,trigger.oldMap);    
        }	    
    }
}