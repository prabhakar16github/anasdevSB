trigger SLAtrigger on Status_SLA__c (before insert, before update) {
   Trigger_Switch__c objTriggerSwitch = Trigger_Switch__c.getValues('StatusSLA');
    
    if(objTriggerSwitch != null && objTriggerSwitch.Active__c){    
        if(Trigger.isAfter){
            if(Trigger.isInsert)    Status_SLATriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate)    Status_SLATriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        else if(Trigger.isBefore){
            if(Trigger.isInsert)    Status_SLATriggerHandler.beforeInsertHandler(Trigger.new);            
            if(Trigger.isUpdate)    Status_SLATriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }    
}