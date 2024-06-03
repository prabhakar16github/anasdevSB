public class PlanTriggerHandler{
    public static void beforeInsertHandler(List<Plan__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Plan__c');         
        for(Plan__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    public static void afterInsertHandler(List<Plan__c> triggerNew){
        for(Plan__c each : triggerNew){
            IntegrationUtility.sendPayLoadData(each, null, 'Plan__c', 'Plan__c'); 
        }
    }
    
    public static void afterUpdateHandler(List<Plan__c> triggerNew, Map<Id, Plan__c> triggerOldMap){
        for(Plan__c each : triggerNew){
            Plan__c oldEach = triggerOldMap.get(each.Id);
            IntegrationUtility.sendPayLoadData(each, oldEach, 'Plan__c', 'Plan__c');
        }
    }
}