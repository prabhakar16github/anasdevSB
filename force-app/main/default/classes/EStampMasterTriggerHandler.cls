public class EStampMasterTriggerHandler{
    public static void beforeInsertHandler(List<E_Stamp_Master__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('E_Stamp_Master__c');         
        for(E_Stamp_Master__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
}