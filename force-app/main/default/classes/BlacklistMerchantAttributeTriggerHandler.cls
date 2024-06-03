public class BlacklistMerchantAttributeTriggerHandler {
    public static void afterInsertHandler(List<Blacklist_Merchant_Attribute__c> blacklistDataList){
        System.debug('afterInsertHandler');
        
    }
    
}