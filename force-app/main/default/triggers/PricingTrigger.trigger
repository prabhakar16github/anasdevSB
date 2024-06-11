/*
* Name of the Trigger : PricingTrigger
* Author's Name       : Anas Yar Khan  
* Description         : Trigger for the Pricing Object
* Version.            : 1  
*/
trigger PricingTrigger on Pricing__c (after insert,after update) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Pricing');
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(Trigger.isAfter && Trigger.isUpdate)PricingTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
    	if(Trigger.isAfter && Trigger.isInsert)PricingTriggerHandler.afterInsertHandler(Trigger.new);
    }
}