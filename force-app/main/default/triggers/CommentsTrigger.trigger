trigger CommentsTrigger on Comments__c (after update, after insert, Before Insert, Before Update) {
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Comments__c');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(Trigger.isAfter){
            if(Trigger.isInsert) CommentsTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate) CommentsTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isBefore){
            if(Trigger.isInsert) CommentsTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate) CommentsTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}