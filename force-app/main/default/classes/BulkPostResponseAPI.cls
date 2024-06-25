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
        try {
            if(!String.isBlank(RestContext.request.requestBody.toString())) {
                Map<String,Object> mapKeyToValue = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString()); 
                if(mapKeyToValue != NULL && mapKeyToValue.keySet().size() > 0 && mapKeyToValue.containsKey('requestId')) {
                    if(mapKeyToValue.get('requestId') != null) {
                        List<Publish_Pricing_Detail__c> listPublishPricingDetails = [SELECT Id,Delete_Request__c,Sync_Status__c,Response_Body__c,Checker__c,Process__c
                                                                                     FROM Publish_Pricing_Detail__c  
                                                                                     WHERE Request_Id__c = :(String)mapKeyToValue.get('requestId') 
                                                                                     AND Sync_Status__c = 'Processing' AND Type__c = 'TDR'];
                        if(listPublishPricingDetails != NULL && listPublishPricingDetails.size() > 0) {
                            Boolean deleteContext = false;
                            Boolean checkerRejectDeleteRequest = false;
                            Boolean checkerApproveDeleteRequest = false;

                            Set<String> overrideRequiredProcesses = new Set<String>{'SaveBulkRules-CheckerFalseActionSave','SaveBulkRules-CheckerTrueActionApprove','SaveBulkRules-CheckerTrueActionReject'};
                            // Set<String> overrideNotRequiredProcesses = new Set<String>{'SaveBulkRules-CheckerTrueActionRejectDelete','DeleteBulkRules-CheckerFalseActionDelete','DeleteBulkRules-CheckerTrueActionApproveDelete','DeleteBulkRules-CheckerTrueActionReject'};

                            if(listPublishPricingDetails[0].Process__c == 'SaveBulkRules-CheckerTrueActionRejectDelete') deleteContext = true;
                            else if(listPublishPricingDetails[0].Process__c == 'DeleteBulkRules-CheckerTrueActionReject') checkerRejectDeleteRequest = true;
                            else if(listPublishPricingDetails[0].Process__c == 'DeleteBulkRules-CheckerTrueActionApproveDelete') checkerApproveDeleteRequest = true;
                            Boolean checker = listPublishPricingDetails[0].Checker__c; 
                            Boolean deleteRequest = listPublishPricingDetails[0].Delete_Request__c;
                            listPublishPricingDetails[0].Sync_Status__c = 'Completed';
                            listPublishPricingDetails[0].Async_Response_Body__c  = RestContext.request.requestBody.toString();
                            Map<Id,Pricing__c> mapIdToPricing = new Map<Id,Pricing__c>();
                            //Traversing the response to get the ruleId and sfId
                            for(Object obj : (List<Object>)mapKeyToValue.get('responseDtos')) {
                                Map<String,Object> mapInnerKeyToValue = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                                Map<String,Object> mapInner2KeyToValue = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapInnerKeyToValue.get('result')));
                                if(String.valueOf(mapInnerKeyToValue.get('code')) == '2000' && mapInner2KeyToValue.get('sfId') != NULL) {
                                    Pricing__c pricing = new Pricing__c();
                                    pricing.Id = String.valueOf(mapInner2KeyToValue.get('sfId')).split('#')[0];
                                    pricing.Valid_From__c = String.valueOf(mapInner2KeyToValue.get('validFrom'));
                                    if(mapIdToPricing.containsKey(pricing.Id)) pricing = mapIdToPricing.get(pricing.Id);
                                    else mapIdToPricing.put(pricing.Id,pricing);
                                    pricing.Published__c = true;
                                    pricing.Need_to_Publish__c = false;
                                    if(deleteContext){
                                        pricing.Deleted__c = true;
                                        
                                    } 
                                    else if(checkerRejectDeleteRequest){
                                        pricing.Deleted__c = false;
                                    }
                                    if(listPublishPricingDetails[0].Process__c == 'SaveBulkRules-CheckerTrueActionApprove' || listPublishPricingDetails[0].Process__c == 'DeleteBulkRules-CheckerTrueActionApproveDelete'){
                                        pricing.Banking_Ops_Status__c = 'Checker Approved';
                                    }
                                    if(listPublishPricingDetails[0].Process__c == 'SaveBulkRules-CheckerTrueActionReject' || listPublishPricingDetails[0].Process__c == 'DeleteBulkRules-CheckerTrueActionReject'){
                                        pricing.Banking_Ops_Status__c = 'Checker Rejected';
                                    }
                                    
                                   	pricing.Version_Number__c = Integer.valueOf(mapInner2KeyToValue.get('versionNumber'));
                                    
                                    if((String)mapInner2KeyToValue.get('revenueModel') == 'TDR') {
                                        

                                        if(checker) {
                                            if(String.isNotBlank(String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId')))) {
                                            	pricing.Rule_Id__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId'));    
                                            }
                                        	pricing.Temp_Id_TDR__c = '';
                                            pricing.Temp_Id_Delete_TDR__c = '';
                                        } 
                                        else{
                                            if(deleteRequest){
                                                pricing.Temp_Id_Delete_TDR__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId')); 
                                            }else{
                                                pricing.Temp_Id_TDR__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId')); 
                                            }
                                            pricing.Banking_Ops_Status__c = 'Pending with Checker';
                                            
                                        }
                                        if(checkerApproveDeleteRequest){
                                            pricing.Rule_Id__c = '';
                                        }
                                    }   
                                    else if((String)mapInner2KeyToValue.get('revenueModel') == 'Conv Fee') {
                                        if(checker) {
                                            if(String.isNotBlank(String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId')))) {
                                            	pricing.Rule_Id_Conv__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId'));    
                                            }
                                            
                                            pricing.Temp_Id_Conv__c = ''; 
                                            pricing.Temp_Id_Delete_Conv__c = '';
                                        }   
                                        else{
                                            if(deleteRequest){
                                                pricing.Temp_Id_Delete_Conv__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId'));  
                                            }else{
                                                pricing.Temp_Id_Conv__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId'));   
                                            }
                                            pricing.Banking_Ops_Status__c = 'Pending with Checker';
                                        } 

                                        if(checkerApproveDeleteRequest){
                                            pricing.Rule_Id_Conv__c = '';
                                        }
                                    }
                                }else if(String.valueOf(mapInnerKeyToValue.get('code')) != '2000' && mapInner2KeyToValue.get('sfId') != NULL){
                                    Pricing__c pricing = new Pricing__c();
                                    pricing.Id = String.valueOf(mapInner2KeyToValue.get('sfId')).split('#')[0];
                                    if(mapIdToPricing.containsKey(pricing.Id)) pricing = mapIdToPricing.get(pricing.Id);
                                    else mapIdToPricing.put(pricing.Id,pricing);
                                    
                                    pricing.Error_Message__c = mapInnerKeyToValue.get('message') != NULL ? (String)mapInnerKeyToValue.get('message') : '';
                                    if(overrideRequiredProcesses.contains(listPublishPricingDetails[0].Process__c)){
                                        pricing.Banking_Ops_Status__c = 'Error(Override Required)';
                                    }else{
                                        pricing.Banking_Ops_Status__c = 'Error(Override Not Required)';
                                        pricing.Deleted__c = false;
                                    }
                                }
                            }  
                            if(mapIdToPricing.keySet().size() > 0) update mapIdToPricing.values();
                            update listPublishPricingDetails[0];
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