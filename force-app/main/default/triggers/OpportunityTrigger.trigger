trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    
    Trigger_Switch__c trgSwtchObj = Trigger_Switch__c.getValues('Opportunity');
    String SupportRecortypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
    List<Opportunity> SupportOppList = new list<Opportunity>();
    
    if(trgSwtchObj != null && trgSwtchObj.Active__c){    
        if(Trigger.isAfter){
            if(Trigger.isInsert) {
                for(Opportunity each : trigger.new){
                    if(each.RecordTypeId == SupportRecortypeId){
                        SupportOppList.add(each);
                    }
                }
                if(SupportOppList != null && SupportOppList.size() > 0) SupportOppTriggerHandler.afterInsertHandler(Trigger.new);
                else OpportunityTriggerHandler.afterInsertHandler(Trigger.new);
            }
            
            if(Trigger.isUpdate) {
                for(Opportunity each : trigger.new){
                        system.debug('each.RecordTypeId ==='+each.RecordTypeId );
                        system.debug('SupportRecortypeId=='+SupportRecortypeId);
                        if(each.RecordTypeId == SupportRecortypeId){
                            SupportOppList.add(each);
                        }
                    }
                    system.debug('SupportOppList size='+SupportOppList.size());
                    if(SupportOppList != null && SupportOppList.size() > 0) SupportOppTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
                    else OpportunityTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            }
        }
        if(Trigger.isBefore){
            if(Trigger.isInsert) {
                for(Opportunity each : trigger.new){
                    if(each.RecordTypeId == SupportRecortypeId){
                        SupportOppList.add(each);
                    }
                }
                if(SupportOppList != null && SupportOppList.size() > 0) SupportOppTriggerHandler.beforeInsertHandler(Trigger.new);
                else OpportunityTriggerHandler.beforeInsertHandler(Trigger.new);
            }
            
            if(Trigger.isUpdate) {
                for(Opportunity each : trigger.new){
                    if(each.RecordTypeId == SupportRecortypeId){
                        SupportOppList.add(each);
                    }
                }
                if(SupportOppList != null && SupportOppList.size() > 0) SupportOppTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap, Trigger.NewMap);
                else OpportunityTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap, Trigger.NewMap);
            }
        }
    }    
}