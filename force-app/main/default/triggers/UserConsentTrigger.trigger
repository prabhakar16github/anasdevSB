trigger UserConsentTrigger on User_Consent__c (before insert) {
    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('User_Consent__c');
    
    if(trgSwitch != null && trgSwitch.Active__c){        
        if(Trigger.isBefore){            
            if(Trigger.isInsert) UserConsentTriggerHandler.beforeInsertHandler(Trigger.New);
        }
    }
}