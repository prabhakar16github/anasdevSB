/**
* @Name         RemovePricingFromTreasury 
* @Author       Prabhakar Joshi
* @Group        Pricing
* @Description  Apex class to remove the pricing from treasury using removePricing API call.
*/

public with sharing class RemovePricingFromTreasury {
    private static FINAL String PROCESS_NAME = 'removePricing';
    /** 
    * Method definition to remove pricing from treasury using removePricing API call.
    * Calling from pricing screen. 
    * @param 1 : comma seperated ruleIds for request body.
    * @param 2 : merchantId for request body.
    * @param 3 : opportunity record Id to map the logs with opportunity.
    */
    public static void deletePricing(String ruleIds, String merchantId,String oppId){
        String requestBody = '';
        try{
            if(String.isNotBlank(ruleIds) && String.isNotBlank(merchantId)){
                Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
                publishDetail.Merchant__c = oppId;
                publishDetail.Process__c = PROCESS_NAME;
                publishDetail.Request_Count__c = ruleIds.split(',').size();
                requestBody = '{"clientId":"1","merchantId":"'+merchantId+'","ruleId":"'+ruleIds+'","userUuid" : "SF"}';
                String access_token = PricingIntegrationUtility.getAccessToken('Get_Access_Token_Remove');
                
                if(String.isNotBlank(access_token)){
                    HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_Remove',access_token,requestBody,PROCESS_NAME);
                    
                    Map<String,Object> responseObj = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    publishDetail.Message__c = (String)responseObj.get('message');
                    
                    if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                        publishDetail.Status__c = 'Success';
                        String ruleIdsFromResponse = (String)(((Map<String,Object>)responseObj.get('result')).get('ruleId'));
                        /** Need to add remove pricing in SF */

                        
                        if(String.isNotBlank(ruleIdsFromResponse)) {
                            updatePricing(ruleIdsFromResponse,oppId);
                        }
                    }else{
                        publishDetail.Status__c = 'Error';
                    }
                    publishDetail.Request_Body__c = requestBody;
                    publishDetail.Response_Body__c = response.getBody();
                }else{
                    publishDetail.Message__c = 'Authorization Error';
                    publishDetail.Status__c = 'Error';
                    publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
                }
                insert publishDetail;
            }
        }catch(Exception e){
            Error_Details__c errorDetails = new Error_Details__c(Request__c = requestBody,Process__c = PROCESS_NAME+' API',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }/** END */

        /** 
     * Private method definition to update the pricing record.
     * @param : comma-seperated ruleIds, OpportunityId. 
     */
    private static void updatePricing(String ruleIdsFromResponse,String oppId){
        if(String.isNotBlank(ruleIdsFromResponse)) {
            List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
            Set<String> setRuleIds = new Set<String>(); 
            for(String ruleId : ruleIdsFromResponse.split(',')) {
                setRuleIds.add(ruleId);

            }
            for(Pricing__c price : [SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Published__c FROM Pricing__c WHERE Opportunity__c = :oppId AND (Rule_Id__c IN :setRuleIds OR Rule_Id_Conv__c IN :setRuleIds)]) {
                price.Rule_Id__c = '';
                price.Rule_Id_Conv__c = '';
                price.Published__c = false;
                listPricingToUpdate.add(price);
            }   
            if(listPricingToUpdate.size() > 0) {
                update listPricingToUpdate;
            }
        }
    }/** END */
}