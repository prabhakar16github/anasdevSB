trigger BusinessCategoryTrigger on Business_Category__c (Before Insert){
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Business_Category__c');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    BusinessCategoryTriggerHandler.beforeInsertHandler(Trigger.new);
        }
    }
}