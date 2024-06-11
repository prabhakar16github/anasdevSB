trigger MasterPricingTrigger on Master_Pricing_Data__c (after insert,after update) {
    Trigger_Switch__c triggerSwitch = Trigger_Switch__c.getInstance('Master Pricing Data');
    if((triggerSwitch != NULL && triggerSwitch.Active__c) && (Trigger.isInsert || Trigger.isUpdate)){
        MasterPricingTrigger_CTRL.primeryKeyUpdateData(trigger.new,trigger.oldMap);    
    }
}