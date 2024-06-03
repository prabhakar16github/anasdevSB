public class GetMerchantIdController {
    
    static Map<String, String> urlParamMap = new Map<String, String>{'Opportunity' => 'Identifier__c'};
    
    @AuraEnabled
    public static String getMerchantId(Id leadId, String sObjectName){
        if(String.isNotBlank(leadId)){
            return LeadTriggerHelper.fetchMIdwithButton(leadId, sObjectName, urlParamMap.containsKey(sObjectName) ? urlParamMap.get(sObjectName).split(',') : null);
        }        
        return null;
    }
}