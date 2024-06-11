trigger CaseCommentTrigger on CaseComment (before insert,after insert) {
    Trigger_Switch__c objTriggerSwitch = Trigger_Switch__c.getValues('CaseComment');
    system.debug('CaseCommentTrigger');
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CaseCommentTriggerHandler.OneCareUpdateCaseField(Trigger.new);
        }
    }
    //if(objTriggerSwitch != null && objTriggerSwitch.Active__c){    
        if(Trigger.isAfter){
            system.debug('inside after');
            if(Trigger.isInsert)    {
                system.debug('inside after insert');
                CaseCommentTriggerHandler.afterInsertHandler(Trigger.new);
            }
            if(Trigger.isUpdate)    CaseCommentTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        
        else if(Trigger.isBefore){
            if(Trigger.isInsert) {
                CaseCommentTriggerHandler.beforeInsertHandler(Trigger.new);
                
            }   
            
            if(Trigger.isUpdate)    CaseCommentTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    //}    
}