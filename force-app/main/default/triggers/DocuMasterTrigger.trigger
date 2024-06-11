trigger DocuMasterTrigger on Document_Master__c(Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Document_Master__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    DocuMasterTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}