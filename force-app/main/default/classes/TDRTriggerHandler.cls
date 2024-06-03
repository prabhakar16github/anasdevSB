public class TDRTriggerHandler{
    public static void beforeInsertHandler(List<TDR__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('TDR__c');         
        for(TDR__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    public static void afterInsertHandler(List<TDR__c> triggerNew){
        ESBPublisherBatch.sendDataInBatch('TDR__c', 'TDR__c');
    }
    
    public static void afterUpdateHandler(List<TDR__c> triggerNew, Map<Id, TDR__c> triggerOldMap){
        ESBPublisherBatch.sendDataInBatch('TDR__c', 'TDR__c');
    }
}