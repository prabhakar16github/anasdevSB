trigger PGKeysTrigger on PG_Keys__c (Before Insert, after Insert, after update) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('PG_Keys__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) PGKeysTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) PGKeysTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) PGKeysTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}