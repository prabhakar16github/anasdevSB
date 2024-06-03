public class MPOTriggerHandler{
    
    public static void beforeInsertHandler(List<MerchantPaymentOption__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('MerchantPaymentOption__c');         
        for(MerchantPaymentOption__c each : triggerNew){                             
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
    }
    
    public static void afterInsertHandler(List<MerchantPaymentOption__c> triggerNew){
        ESBPublisherBatch.sendDataInBatch('MerchantPaymentOption__c', 'MerchantPaymentOption__c'); 
    }
    
    public static void afterUpdateHandler(List<MerchantPaymentOption__c> triggerNew, Map<Id, MerchantPaymentOption__c> triggerOldMap){
        ESBPublisherBatch.sendDataInBatch('MerchantPaymentOption__c', 'MerchantPaymentOption__c');
    }
    
    /*commented by Uma Shankar at Dec.13, 2018 due to test class and this metjod is not used any where
     * 
     * public static void createMerchantPGKeys(List<MerchantPaymentOption__c> lstMerchantPO){
        
        Set<Id> setPGId = new Set<Id>();
        MAP<Id, Payment_Gateway__c> mapPaymentGateway = new Map<Id, Payment_Gateway__c>();
        
        for(MerchantPaymentOption__c eachMPO :  lstMerchantPO){
            if(String.isNotBlank(eachMPO.Payment_Gateway__c)){
                setPGId.add(eachMPO.Payment_Gateway__c);
            }
        }
        
        if(!setPGId.isEmpty())		getPaymenrGateway(setPGId, mapPaymentGateway);
        System.debug(mapPaymentGateway.size()+' ***** mapPaymentGateway &&&&&&&& '+mapPaymentGateway);
        
    }
    
    public static void getPaymenrGateway(Set<Id> setPGId, MAP<Id, Payment_Gateway__c> mapPaymentGateway){
        
        mapPaymentGateway.putAll([SELECT Id FROM Payment_Gateway__c WHERE ID in : setPGId]);
        //MAP<Id, Payment_Gateway__c> mapPayGate = new MAP<Id, Payment_Gateway__c>([SELECT Id FROM Payment_Gateway__c WHERE ID in : setPGId]);
    }*/
}