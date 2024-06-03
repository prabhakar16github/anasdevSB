public class PGKeysTriggerHandler{
    public static void beforeInsertHandler(List<PG_Keys__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('PG_Keys__c');         
        for(PG_Keys__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    
    public static void afterInsertHandler(List<PG_Keys__c> triggerNew){
        for(PG_Keys__c each : triggerNew){
            IntegrationUtility.sendPayLoadData(each, null, 'PG_Keys__c', 'PG_Keys__c'); 
        }
    }
    
    public static void afterUpdateHandler(List<PG_Keys__c> triggerNew, Map<Id, PG_Keys__c> triggerOldMap){
        for(PG_Keys__c each : triggerNew){
            PG_Keys__c oldEach = triggerOldMap.get(each.Id);
            IntegrationUtility.sendPayLoadData(each, oldEach, 'PG_Keys__c', 'PG_Keys__c');
        }
    }
}