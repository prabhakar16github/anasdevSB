trigger RiskScoreTrigger on Risk_Score__c (before insert){
    
    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('Risk_Score__c');
    
    if(trgSwitch != null && trgSwitch.Active__c){        
        if(Trigger.isBefore){            
            if(Trigger.isInsert) RiskScoreTriggerHandler.beforeInsertHandler(Trigger.New);
        }
    }
}