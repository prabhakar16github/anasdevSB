public class PaymentGatewayTriggerHandler{
    public static void beforeInsertHandler(List<Payment_Gateway__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Payment_Gateway__c');         
        for(Payment_Gateway__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    public static void afterInsertHandler(List<Payment_Gateway__c> triggerNew){
        for(Payment_Gateway__c each : triggerNew){
            IntegrationUtility.sendPayLoadData(each, null, 'Payment_Gateway__c', 'Payment_Gateway__c'); 
        }
    }
    
    public static void afterUpdateHandler(List<Payment_Gateway__c> triggerNew, Map<Id, Payment_Gateway__c> triggerOldMap){
        for(Payment_Gateway__c each : triggerNew){
            Payment_Gateway__c oldEach = triggerOldMap.get(each.Id);
            IntegrationUtility.sendPayLoadData(each, oldEach, 'Payment_Gateway__c', 'Payment_Gateway__c');
        }
    }
}