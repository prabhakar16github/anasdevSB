/**
* @Name         : BulkPostResponseAPI 
* @Author       : Anas Yar Khan
* @Created Date : 8th Feb, 2024
* @Group        : Pricing
* @Description  : This webservice is used to get the response back in Salesforce 
for the request sent out to add/update pricing in Treasury
*/
@RestResource(urlMapping='/sendBulkPostResponse/*')
global class BulkPostResponseAPI {
    @HttpPost
    global static ResponseClass doConsumeBulkPostAPIResponse() {
        ResponseClass response = new ResponseClass();
        String requestId = '';
        try {
            if(!String.isBlank(RestContext.request.requestBody.toString())) {
                Map<String,Object> mapKeyToValue = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString()); 
                if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0 && mapKeyToValue.containsKey('requestId')) {
                    if(mapKeyToValue.get('requestId') != null) {
                        List<Publish_Pricing_Detail__c> listPublishPricingDetails = [SELECT Id,Delete_Request__c,Sync_Status__c,Response_Body__c,Checker__c,Process__c,Object_API_Name__c,Request_Count__c,Request_Id__c 
                                                                                    FROM Publish_Pricing_Detail__c  
                                                                                     WHERE Request_Id__c = :(String)mapKeyToValue.get('requestId') 
                                                                                     AND Sync_Status__c = 'Processing' AND Type__c = 'TDR'];
                        if(listPublishPricingDetails != NULL && listPublishPricingDetails.size() > 0) {
                            requestId = listPublishPricingDetails[0].Request_Id__c;
                            if(listPublishPricingDetails[0].Object_API_Name__c == 'Pricing__c'){
                                Pricing_BulkPostResponseAPI_Handler.handlePricingResponse(listPublishPricingDetails,mapKeyToValue,RestContext.request.requestBody.toString());
                            }
                            else if(listPublishPricingDetails[0].Object_API_Name__c == 'Fixed_Pricing1__c'){
                                Pricing_BulkPostResponseAPI_Handler.handleFixedPricingResponse(listPublishPricingDetails,mapKeyToValue,RestContext.request.requestBody.toString());
                            }
                            getResponseClass(response,true,'Async Response processed successfully');
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
            Error_Details__c errorDetails = new Error_Details__c(Request__c = requestId,Process__c = 'BulkPostResponseAPI',Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
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