public class CommercialTriggerHandler{  

    public static void beforeInsertHandler(List<Commercial__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Commercial__c');         
        for(Commercial__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    
    public static void beforeUpdateHandler(List<Commercial__c> newList, Map<Id, Commercial__c> oldMap){        
        //updateSettlementFieldValue(newList, oldMap);
    }
    
    public static void afterInsertHandler(List<Commercial__c> triggerNew){
        for(Commercial__c each : triggerNew){
            IntegrationUtility.sendPayLoadData(each, null, 'Commercial__c', 'Commercial__c'); 
        }
    }
    
    public static void afterUpdateHandler(List<Commercial__c> triggerNew, Map<Id, Commercial__c> triggerOldMap){
        for(Commercial__c each : triggerNew){
            Commercial__c oldEach = triggerOldMap.get(each.Id);
            IntegrationUtility.sendPayLoadData(each, oldEach, 'Commercial__c', 'Commercial__c');
        }
    }
    /*
    private static void updateSettlementFieldValue(List<Commercial__c> newList, Map<Id, Commercial__c> oldMap){
        for(Commercial__c commercialObj : newList){
            if(commercialObj.Active__c 
                && commercialObj.Settlement_Cycle_Approval_Status__c != oldMap.get(commercialObj.Id).Settlement_Cycle_Approval_Status__c
                && commercialObj.Settlement_Cycle_Approval_Status__c == 'Rejected' 
                && String.isNotBlank(commercialObj.Old_Settlement_Cycle__c)){
                commercialObj.Settlement_Cycle__c = commercialObj.Old_Settlement_Cycle__c;
                commercialObj.Old_Settlement_Cycle__c = null;
            }
            
            if(commercialObj.Active__c 
                && commercialObj.Settlement_Type_Approval_Status__c != oldMap.get(commercialObj.Id).Settlement_Type_Approval_Status__c
                && commercialObj.Settlement_Type_Approval_Status__c == 'Rejected' 
                && String.isNotBlank(commercialObj.Old_Settlement_Type__c)){
                commercialObj.Settlement_Type__c = commercialObj.Old_Settlement_Type__c;
                commercialObj.Old_Settlement_Type__c = null;
            }    
        }
    }*/
}