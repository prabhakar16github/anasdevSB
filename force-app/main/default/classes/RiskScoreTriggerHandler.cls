public with sharing class RiskScoreTriggerHandler {

    public static void beforeInsertHandler(List<Risk_Score__c> triggerNew){ 
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Risk_Score__c');
        
        for(Risk_Score__c each : TriggerNew){         
            
            if(each.uuid__c != null && each.Identifier__c == null) {
                each.Identifier__c = each.uuid__c;
            }
        }
    }
}