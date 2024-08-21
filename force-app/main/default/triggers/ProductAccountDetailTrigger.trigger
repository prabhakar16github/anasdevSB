trigger ProductAccountDetailTrigger on Product_Account_Detail__c (before insert, before update, after insert, after update) {

    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('Product_Account_Detail__c');
    
    if(trgSwitch != null && trgSwitch.Active__c){        
        if(Trigger.isAfter){
            if(Trigger.isInsert) ProductAccountDetailTriggerHandler.afterInsertHandler(Trigger.New); 
            if(Trigger.isUpdate) ProductAccountDetailTriggerHandler.afterUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
        
        if(Trigger.isBefore){            
            if(Trigger.isInsert) ProductAccountDetailTriggerHandler.beforeInsertHandler(Trigger.New);             
            if(Trigger.isUpdate) ProductAccountDetailTriggerHandler.beforeUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
    }
}