public class FixedPricingTriggerHandler {
    public static void beforeUpdateHandler(List<Fixed_Pricing1__c> triggeNew, Map<Id,Fixed_Pricing1__c> oldMap){
        for(Fixed_Pricing1__c fp : triggeNew){
            if(String.isNotBlank(fp.Status__c) && fp.Status__c != oldMap.get(fp.Id).Status__c && fp.Status__c == 'Error (Override Required)' && String.isBlank(fp.Rule_Id__c)){
                fp.Status__c = 'Error (Override Not Required)';
                fp.Temp_Id__c = NULL;
            }
        }
    }
}