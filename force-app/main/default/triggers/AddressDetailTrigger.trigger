trigger AddressDetailTrigger on Address_Details__c (after insert, after update, Before Insert, before update, After delete){
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Address_Details__c'); 
       
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    AddressDetailsTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate)    AddressDetailsTriggerHandler.beforeUpdateHandler(Trigger.new,Trigger.OldMap);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) AddressDetailsTriggerHandler.afterInsertHandler(Trigger.new);
            
            if(Trigger.isUpdate) AddressDetailsTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            if(Trigger.isDelete) AddressDetailsTriggerHandler.afterDeleteHandler(Trigger.old);
        }
    }
}