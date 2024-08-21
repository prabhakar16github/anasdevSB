trigger DocuCateMasterTrigger on Document_Category_Master__c (Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Document_Category_Master__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    DocuCateMasterTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}