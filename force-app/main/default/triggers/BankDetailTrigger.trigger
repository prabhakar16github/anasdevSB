trigger BankDetailTrigger on Bank_Account_Detail__c (after insert, after update, before insert, before update){
    
    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('Bank_Account_Detail__c');
    
    if(trgSwitch != null && trgSwitch.Active__c){        
        if(Trigger.isAfter){
            if(Trigger.isInsert) BankDetailTriggerHandler.afterInsertHandler(Trigger.New); 
            if(Trigger.isUpdate) BankDetailTriggerHandler.afterUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
        
        if(Trigger.isBefore){            
            if(Trigger.isInsert) BankDetailTriggerHandler.beforeInsertHandler(Trigger.New);             
            if(Trigger.isUpdate) BankDetailTriggerHandler.beforeUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
    }
}