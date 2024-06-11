trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert,before update,after update,after insert) {
	
    Trigger_Switch__c trgSwitch = Trigger_Switch__c.getValues('LiveChatTranscript');
    
    if(trgSwitch != null && trgSwitch.Active__c){        
        if(Trigger.isAfter){
            if(Trigger.isInsert) LiveChatTranscriptTriggerHandler.afterInsertHandler(Trigger.New,Trigger.OldMap); 
            if(Trigger.isUpdate) LiveChatTranscriptTriggerHandler.afterUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
        
        if(Trigger.isBefore){            
            if(Trigger.isInsert) LiveChatTranscriptTriggerHandler.beforeInsertHandler(Trigger.New);             
            if(Trigger.isUpdate) LiveChatTranscriptTriggerHandler.beforeUpdateHandler(Trigger.New, Trigger.OldMap); 
        }
    }
}