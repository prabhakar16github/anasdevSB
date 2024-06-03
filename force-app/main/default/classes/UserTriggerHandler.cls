public class UserTriggerHandler{
    // this method call FROM User trigger at before insert
    public static void beforeInsertHandler(List<User> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('User'); 
        
        for(User each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);
        }
    }
}