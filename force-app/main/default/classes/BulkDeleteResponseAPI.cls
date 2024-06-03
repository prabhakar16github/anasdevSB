/**
* @Name         : BulkDeleteResponseAPI 
* @Author       : Anas Yar Khan
* @Created Date : 21th Feb, 2024
* @Group        : Pricing
* @Description  : This webservice is used to get the response back in Salesforce 
for the request sent out to delete pricing in Treasury
*/
@RestResource(urlMapping='/sendBulkDeleteResponse/*')
global class BulkDeleteResponseAPI {
    @HttpPost
    global static ResponseClass doConsumeBulkDeleteAPIResponse() {
        ResponseClass response = new ResponseClass();
        try {
            if(!String.isBlank(RestContext.request.requestBody.toString())) {
                Map<String,Object> mapKeyToValue = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString()); 
                if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0 && mapKeyToValue.containsKey('requestId')) {
                    if(mapKeyToValue.get('requestId') != null) {
                        List<Publish_Pricing_Detail__c> listPublishPricingDetails = [SELECT Id,Sync_Status__c,Response_Body__c,Merchant__c 
                                                                                     FROM Publish_Pricing_Detail__c  
                                                                                     WHERE Request_Id__c = :(String)mapKeyToValue.get('requestId') 
                                                                                     AND Sync_Status__c = 'Processing' AND Type__c = 'TDR'];
                        if(listPublishPricingDetails != NULL && listPublishPricingDetails.size() > 0) {
                            if(mapKeyToValue.containsKey('responseDtos')){
                                Map<String,String> mapRuleIdToSuccessCode = new Map<String,String>();
                                for(Object obj : (List<Object>)mapKeyToValue.get('responseDtos')){
                                    Map<String,Object> mapKeyToValueInner1 = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                                    mapRuleIdToSuccessCode.put(String.valueOf(mapKeyToValueInner1.get('result')),String.valueOf(mapKeyToValueInner1.get('code')));
                                }
                                List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
                                if(mapRuleIdToSuccessCode.keySet().size() > 0){
                                    for(Pricing__c pr : [SELECT Id,Rule_Id__c,Rule_Id_Conv__c,Published__c 
                                                         FROM Pricing__c
                                                         WHERE Opportunity__c = :listPublishPricingDetails[0].Merchant__c
                                                         AND (Rule_Id__c IN :mapRuleIdToSuccessCode.keySet() 
                                                              OR Rule_Id_Conv__c IN :mapRuleIdToSuccessCode.keySet())]){
                                                                  if(mapRuleIdToSuccessCode.get(pr.Rule_Id__c) == '2000' 
                                                                     || mapRuleIdToSuccessCode.get(pr.Rule_Id_Conv__c) == '2000'){
                                                                         pr.Rule_Id__c = '';
                                                                         pr.Rule_Id_Conv__c = '';
                                                                         pr.Published__c = false;
                                                                         pr.Deleted__c = true;
                                                                         listPricingToUpdate.add(pr);
                                                                     }
                                                              }
                                }
                                if(listPricingToUpdate.size() > 0) update listPricingToUpdate;
                                listPublishPricingDetails[0].Sync_Status__c = 'Completed';
                                listPublishPricingDetails[0].Async_Response_Body__c = RestContext.request.requestBody.toString();
                                update listPublishPricingDetails[0];
                                getResponseClass(response,true,'Async Response processed successfully');
                            }
                            else getResponseClass(response,false,'responseDtos is missing.');
                        }
                        else getResponseClass(response,false,'requestId not found'); 
                    }	
                    else getResponseClass(response,false,'requestId can not be null/blank');    
                }
                else getResponseClass(response,false,'requestId is not present in the request'); 
            }  
            else getResponseClass(response,false,'Body can not be blank'); 
        }
        catch(Exception e) {
            getResponseClass(response,false,e.getMessage());
        }
        return response;
    }
    
    //this class is used to send response back to treasury
    global class ResponseClass {
        global Boolean success;
        global String message;
    }
    
    //this method is used to get response to return
    private static void getResponseClass(ResponseClass response,Boolean success,String message){
        response.success = success;
        response.message = message;
    }
}