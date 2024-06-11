trigger MCareDashboardCaseTrigger on MCare_Dashboard_Case__c (after update, after insert, Before Insert, Before Update) {

    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('MCare_Dashboard_Case__c');
        
        if(trgSwtchObj != null && trgSwtchObj.Active__c){    
            if(Trigger.isAfter){
                if(Trigger.isInsert) MCareDashboardCaseTriggerHandler.afterInsertHandler(Trigger.new);
                if(Trigger.isUpdate) MCareDashboardCaseTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            }
            
            if(Trigger.isBefore){
                if(Trigger.isInsert) MCareDashboardCaseTriggerHandler.beforeInsertHandler(Trigger.new);
                if(Trigger.isUpdate) MCareDashboardCaseTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
            }
        }
}