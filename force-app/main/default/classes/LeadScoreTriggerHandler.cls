public class LeadScoreTriggerHandler {

    public static void beforeInsertHandler(List<Lead_Score__c> triggerNew){ 
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Lead_Score__c');
        
        for(Lead_Score__c each : TriggerNew){         
            
            if(each.uuid__c != null && each.Identifier__c == null) {
                each.Identifier__c = each.uuid__c;
            }
        }
    }
}