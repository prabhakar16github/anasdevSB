trigger WebsitePageTrigger on Website_Page__c(Before Insert, Before Update, After Insert, After Update, before Delete, After Delete){    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Website_Page__c');    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert)    WebsitePageTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate)	WebsitePageTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert)	WebsitePageTriggerHandler.afterInsertHandler(Trigger.new);
            if(Trigger.isUpdate)   	WebsitePageTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap); 
        }
    }
}