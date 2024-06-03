public class PlanPricingTriggerHandler{
    public static void beforeInsertHandler(List<Plan_Pricing__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Plan_Pricing__c');         
        for(Plan_Pricing__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    public static void afterInsertHandler(List<Plan_Pricing__c> triggerNew){
        ESBPublisherBatch.sendDataInBatch('Plan_Pricing__c', 'TDR__c');
    }
    
    public static void afterUpdateHandler(List<Plan_Pricing__c> triggerNew, Map<Id, Plan_Pricing__c> triggerOldMap){
        ESBPublisherBatch.sendDataInBatch('Plan_Pricing__c', 'TDR__c');
    }
}