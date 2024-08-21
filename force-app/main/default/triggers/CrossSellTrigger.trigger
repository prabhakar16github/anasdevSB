trigger CrossSellTrigger on Cross_Sell__c (before insert,after insert,after update,before update) {

    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Cross_Sell__c');
        
        if(trgSwtchObj != null && trgSwtchObj.Active__c){    
            if(Trigger.isAfter){
                if(Trigger.isInsert) CrossSellTriggerHandler.afterInsertHandler(Trigger.New);
                if(Trigger.isUpdate) CrossSellTriggerHandler.afterUpdateHandler(Trigger.New, Trigger.oldMap);
            }
            if(Trigger.isBefore){
                if(Trigger.isInsert) CrossSellTriggerHandler.beforeInsertHandler(Trigger.New);
                if(Trigger.isUpdate) CrossSellTriggerHandler.beforeUpdateHandler(Trigger.New, Trigger.oldMap);
            }
        }
}