trigger DocuTypeMasterTrigger on Document_Type_Master__c (Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Document_Type_Master__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    DocuTypeMasterTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}