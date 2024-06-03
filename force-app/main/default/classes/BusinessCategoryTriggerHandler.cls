public class BusinessCategoryTriggerHandler{
    public static void beforeInsertHandler(List<Business_Category__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Business_Category__c');         
        for(Business_Category__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
}