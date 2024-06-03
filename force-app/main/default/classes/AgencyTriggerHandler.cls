public class AgencyTriggerHandler {
    public static void beforeInsertHandler(list<Agency__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Agency__c');         
        for(Agency__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);    
            system.debug('hello'+ each.Identifier__c );
        }
    }

}