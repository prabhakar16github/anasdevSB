public class PaymentDetailsTriggerHandler{
    public static void beforeInsertHandler(List<Payment_Details__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Payment_Details__c');         
        for(Payment_Details__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
}