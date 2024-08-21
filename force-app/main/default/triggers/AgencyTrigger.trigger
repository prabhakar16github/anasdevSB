trigger AgencyTrigger on Agency__c (before insert) {
   Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Agency__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) AgencyTriggerHandler.beforeInsertHandler(Trigger.new);
           
        }
        
        
    }
}