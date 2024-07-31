public class PlatformFeeTriggerHandler {
    public static void beforeUpdateHandler(List<Platform_Fee__c> triggeNew, Map<Id,Platform_Fee__c> oldMap){
        for(Platform_Fee__c platformFee : triggeNew){
            if(String.isNotBlank(platformFee.Status__c) && platformFee.Status__c != oldMap.get(platformFee.Id).Status__c && platformFee.Status__c == 'Error (Override Required)' 
            && String.isBlank(platformFee.Rule_Id__c)){
                platformFee.Status__c = 'Error (Override Not Required)';
                platformFee.Temp_Id__c = NULL;
            }
            if(platformFee.Deleted__c && !oldMap.get(platformFee.Id).Deleted__c){
                platformFee.Rule_Id__c = NULL;
                platformFee.Temp_Id__c = NULL;
            }
        }
    }
}