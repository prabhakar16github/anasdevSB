public class SubCategoryTriggerHandler{
    public static void beforeInsertHandler(List<Sub_Category__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Sub_Category__c');         
        for(Sub_Category__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
}