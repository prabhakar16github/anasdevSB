trigger CommercialTrigger on Commercial__c (Before Update, Before Insert, after Insert, after update) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Commercial__c');
    
     if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isUpdate) CommercialTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
            if(Trigger.isInsert) CommercialTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) CommercialTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) CommercialTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}