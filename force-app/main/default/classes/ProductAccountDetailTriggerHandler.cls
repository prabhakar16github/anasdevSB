public class ProductAccountDetailTriggerHandler {
    
    public static Boolean runningFromConsumerAPI = false;

    public static void beforeInsertHandler(List<Product_Account_Detail__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Product_Account_Detail__c');
        for(Product_Account_Detail__c each : TriggerNew){          
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);
        }
    }
    
    public static void beforeUpdateHandler(List<Product_Account_Detail__c> triggerNew, Map<Id,Product_Account_Detail__c> triggerOldMap){
        
    }
    
    public static void afterInsertHandler(List<Product_Account_Detail__c> triggerNew){
            for(Product_Account_Detail__c each : triggerNew){
                if(!runningFromConsumerAPI){
        			IntegrationUtility.checkMaintenance(each, null, 'Product_Account_Detail__c', 'Product_Account_Detail__c'); 
            	}
        	}
    }
    
    public static void afterUpdateHandler(List<Product_Account_Detail__c> triggerNew, Map<Id,Product_Account_Detail__c> triggerOldMap){
            for(Product_Account_Detail__c each : triggerNew){
                if(!runningFromConsumerAPI){
        			IntegrationUtility.checkMaintenance(each, TriggerOldMap.get(each.Id), 'Product_Account_Detail__c', 'Product_Account_Detail__c');
            	}
        	}
    }
}