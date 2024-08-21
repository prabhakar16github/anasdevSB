trigger VideoKYCTrigger on Video_KYC__c (before insert, before update) {

    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Video_KYC__c');
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(Trigger.isBefore){
            if(Trigger.isInsert) VideoKYCTriggerHandler.beforeInsertHandler(Trigger.new);
            if(Trigger.isUpdate) VideoKYCTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }
}