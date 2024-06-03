public class PricingPOTriggerHandler{
    public static void beforeInsertHandler(List<PricingPaymentOption__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('PricingPaymentOption__c');         
        for(PricingPaymentOption__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
}