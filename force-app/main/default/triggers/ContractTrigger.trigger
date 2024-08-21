trigger ContractTrigger on Contract (Before Insert, Before Update, After Insert, After Update, After Delete) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Contract');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) ContractTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate) ContractTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.OldMap);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) ContractTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) ContractTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            if(Trigger.isDelete) ContractTriggerHandler.afterDeleteHandler(Trigger.old);
        }
    }    
}