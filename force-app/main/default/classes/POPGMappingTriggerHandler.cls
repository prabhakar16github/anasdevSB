public class POPGMappingTriggerHandler{
    
    public static void beforeInsertHandler(List<PO_PG_Mapping__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('PO_PG_Mapping__c');         
        for(PO_PG_Mapping__c each : triggerNew){            
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);  
            poPgIdentifier(each);              
        }
    }
    
    public static void beforeUpdateHandler(List<PO_PG_Mapping__c> triggerNew, Map<Id, PO_PG_Mapping__c> triggerOldMap){
        
        for(PO_PG_Mapping__c each : triggerNew){            
            poPgIdentifier(each);           
        }
    }
    
    public static void afterInsertHandler(List<PO_PG_Mapping__c> triggerNew){
        for(PO_PG_Mapping__c each : triggerNew){
            IntegrationUtility.sendPayLoadData(each, null, 'PO_PG_Mapping__c', 'PO_PG_Mapping__c'); 
        }
    }
    
    public static void afterUpdateHandler(List<PO_PG_Mapping__c> triggerNew, Map<Id, PO_PG_Mapping__c> triggerOldMap){
        for(PO_PG_Mapping__c each : triggerNew){
            PO_PG_Mapping__c oldEach = triggerOldMap.get(each.Id);
            IntegrationUtility.sendPayLoadData(each, oldEach, 'PO_PG_Mapping__c', 'PO_PG_Mapping__c');
        }
    }
    
    public static void poPgIdentifier(PO_PG_Mapping__c thePOPG){
        thePOPG.PO_PG_Identifier__c = thePOPG.Payment_Option__c + '__' + thePOPG.Payment_Gateway__c;
    }
}