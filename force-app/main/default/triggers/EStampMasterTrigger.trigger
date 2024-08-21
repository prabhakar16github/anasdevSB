trigger EStampMasterTrigger on E_Stamp_Master__c(Before Insert){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('E_Stamp_Master__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    EStampMasterTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}