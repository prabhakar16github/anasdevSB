trigger Commercial2Trigger on Commercial2__c (before insert) {
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Commercial2__c');
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(trigger.isInsert && trigger.isBefore) {
            Commercial2TriggerHandler.beforeInsert(trigger.new);
        }
    }
}