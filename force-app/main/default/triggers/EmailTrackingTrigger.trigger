trigger EmailTrackingTrigger on Email_Status_Tracking__c (before Insert, after insert, before update, before delete,after update, after delete) {

    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Email_Status_Tracking__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){
        if(Trigger.isBefore){
            if(Trigger.isInsert) EmailTrackingTriggerHandler.beforeInsertHandler(Trigger.new);
        }
        
        if(Trigger.isAfter){
            if(Trigger.isInsert) EmailTrackingTriggerHandler.afterInsertHandler(Trigger.new);
        }
    }

}