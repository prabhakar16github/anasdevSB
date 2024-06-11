trigger BlacklistMerchantAttributeTrigger on Blacklist_Merchant_Attribute__c (before insert,After insert) {
    System.debug('trigger');
	Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Blacklist_Merchant_Attribute__c');
    if(trgSwtchObj != null && trgSwtchObj.Active__c){
        System.debug('Inside1');
        if(Trigger.isAfter && Trigger.isInsert){
            System.debug('Inside2');
            BlacklistMerchantAttributeTriggerHandler.afterInsertHandler(Trigger.new);
        }
        
    }
}