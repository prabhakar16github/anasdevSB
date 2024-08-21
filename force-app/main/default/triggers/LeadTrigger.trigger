trigger LeadTrigger on Lead (after update, after insert, Before Insert, Before Update){
    //if(AvoidRecursion.isFirstRun()){
        Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Lead');
        
        if(trgSwtchObj != null && trgSwtchObj.Active__c){    
            if(Trigger.isAfter){
                if(Trigger.isInsert) LeadTriggerHandler.afterInsertHandler(Trigger.new);
                if(Trigger.isUpdate) LeadTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            
            if(Trigger.isBefore){
                if(Trigger.isInsert) LeadTriggerHandler.beforeInsertHandler(Trigger.new);
                if(Trigger.isUpdate) LeadTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
            }
        } 
    //}   
}