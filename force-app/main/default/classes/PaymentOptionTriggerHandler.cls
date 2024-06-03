public class PaymentOptionTriggerHandler{
    public static void beforeInsertHandler(List<Payment_Option__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Payment_Option__c');         
        for(Payment_Option__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    public static void afterInsertHandler(List<Payment_Option__c> triggerNew){
        for(Payment_Option__c each : triggerNew){
            IntegrationUtility.sendPayLoadData(each, null, 'Payment_Option__c', 'Payment_Option__c'); 
        }
    }
    
    public static void afterUpdateHandler(List<Payment_Option__c> triggerNew, Map<Id, Payment_Option__c> triggerOldMap){
        for(Payment_Option__c each : triggerNew){
            Payment_Option__c oldEach = triggerOldMap.get(each.Id);
            IntegrationUtility.sendPayLoadData(each, oldEach, 'Payment_Option__c', 'Payment_Option__c');
        }
    }
}