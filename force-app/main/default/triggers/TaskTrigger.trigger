Trigger TaskTrigger on Task(after update, after insert, Before Insert, Before Update){
    Trigger_Switch__c objTriggerSwitch = Trigger_Switch__c.getValues('Task');
    
    if(objTriggerSwitch != null && objTriggerSwitch.Active__c){    
        if(Trigger.isAfter){
            if(Trigger.isInsert)    TaskTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate)    TaskTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        else if(Trigger.isBefore){
            if(Trigger.isInsert)    TaskTriggerHandler.beforeInsertHandler(Trigger.new);            
            if(Trigger.isUpdate)    TaskTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }    
}