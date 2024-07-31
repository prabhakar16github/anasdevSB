trigger PlatformFeeTrigger on Platform_Fee__c (before insert) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Platform_Fee__c');
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        
        switch on Trigger.OperationType  {
            when BEFORE_UPDATE {
                PlatformFeeTriggerHandler.beforeUpdateHandler(Trigger.new,Trigger.oldMap);
            }
        }
    }
}