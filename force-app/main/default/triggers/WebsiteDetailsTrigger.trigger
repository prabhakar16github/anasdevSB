trigger WebsiteDetailsTrigger on Website_Details__c (after update, after insert, Before Insert, Before Update) {

    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Website_Details__c');
        
        if(trgSwtchObj != null && trgSwtchObj.Active__c){    
            if(Trigger.isAfter){
                if(Trigger.isInsert) WebsiteDetailsTriggerHandler.afterInsertHandler(Trigger.new);
                if(Trigger.isUpdate) WebsiteDetailsTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            }
            
            if(Trigger.isBefore){
                if(Trigger.isInsert) WebsiteDetailsTriggerHandler.beforeInsertHandler(Trigger.new);
                if(Trigger.isUpdate) WebsiteDetailsTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
            }
        }
}