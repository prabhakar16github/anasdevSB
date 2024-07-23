public class Pricing_BulkPostResponseAPI_Handler {
    public static void handlePricingResponse(List<Publish_Pricing_Detail__c> listPublishPricingDetails,Map<String,Object> mapKeyToValue,String body) {
        
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
        if(listPublishPricingDetails[0].Request_Count__c > 40){
            listPublishPricingDetails[0].Async_Response_Body__c  = '*** Please view ResponseBody attachment ***';
            Attachment att = new Attachment();
                att.Name = 'ResponseBody';
                att.ParentId = listPublishPricingDetails[0].Id;
                att.Body = Blob.valueOf(body);
                insert att;
        }else{
            listPublishPricingDetails[0].Async_Response_Body__c  = body;
        }
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
                    //pricing.Deleted__c = true;
                    
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
                        if(listPublishPricingDetails[0].Process__c != 'SaveBulkRules-CheckerTrueActionRejectDelete'){
                             pricing.Banking_Ops_Status__c = 'Pending with Checker';
                        }
                       
                        
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
                        if(listPublishPricingDetails[0].Process__c != 'SaveBulkRules-CheckerTrueActionRejectDelete'){
                            pricing.Banking_Ops_Status__c = 'Pending with Checker';
                        }
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
    }

    public static void handleFixedPricingResponse(List<Publish_Pricing_Detail__c> listPublishPricingDetails,Map<String,Object> mapKeyToValue,String body) {
        
        Boolean checker = listPublishPricingDetails[0].Checker__c; 
        listPublishPricingDetails[0].Sync_Status__c = 'Completed';
        listPublishPricingDetails[0].Async_Response_Body__c  = body;
        Map<Id,Fixed_Pricing1__c> mapIdToFixedPricing = new Map<Id,Fixed_Pricing1__c>();
        //Traversing the response to get the ruleId and sfId
        for(Object obj : (List<Object>)mapKeyToValue.get('responseDtos')) {
            Map<String,Object> mapInnerKeyToValue = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            Map<String,Object> mapInner2KeyToValue = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapInnerKeyToValue.get('result')));
            if(String.valueOf(mapInnerKeyToValue.get('code')) == '2000' && mapInner2KeyToValue.get('sfId') != NULL) {
                Fixed_Pricing1__c pricing = new Fixed_Pricing1__c();
                pricing.Id = String.valueOf(mapInner2KeyToValue.get('sfId')).split('#')[0];
                pricing.Valid_From__c = String.valueOf(mapInner2KeyToValue.get('validFrom'));
                pricing.Added_On__c = String.valueOf(mapInner2KeyToValue.get('addedOn'));
                pricing.Valid_Till__c = String.valueOf(mapInner2KeyToValue.get('validTill'));
                if(mapIdToFixedPricing.containsKey(pricing.Id)) pricing = mapIdToFixedPricing.get(pricing.Id);
                else mapIdToFixedPricing.put(pricing.Id,pricing);
                
                pricing.Published__c = true;
                pricing.Need_to_Publish__c = false;
                pricing.Version_Number__c = Integer.valueOf(mapInner2KeyToValue.get('versionNumber'));
                
                if(checker) {
                    if(String.isNotBlank(String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId')))) {
                        pricing.Rule_Id__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId'));    
                    }
                    if(listPublishPricingDetails[0].Process__c == 'SaveBulkRules-CheckertrueActionapproveFixed_Pricing1__c'){
                        pricing.Status__c = 'Checker Approved';
                    }else{
                        pricing.Status__c = 'Checker Rejected';
                    }
                    
                    pricing.Temp_Id__c = '';

                } 
                else{
                    if(String.isNotBlank(String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId')))) {
                        pricing.Temp_Id__c = String.valueOf(mapInner2KeyToValue.get('pricingRuleConfigId'));    
                    }
                    pricing.Status__c = 'Pending with Checker';
                }
                
            }else if(String.valueOf(mapInnerKeyToValue.get('code')) != '2000' && mapInner2KeyToValue.get('sfId') != NULL){
                Fixed_Pricing1__c pricing = new Fixed_Pricing1__c();
                pricing.Id = String.valueOf(mapInner2KeyToValue.get('sfId')).split('#')[0];
                if(mapIdToFixedPricing.containsKey(pricing.Id)) pricing = mapIdToFixedPricing.get(pricing.Id);
                else mapIdToFixedPricing.put(pricing.Id,pricing);
                pricing.Error_Message__c = mapInnerKeyToValue.get('message') != NULL ? (String)mapInnerKeyToValue.get('message') : '';
                pricing.Status__c = 'Error (Override Required)';
            }
        }  
        if(mapIdToFixedPricing.keySet().size() > 0) update mapIdToFixedPricing.values();
        update listPublishPricingDetails[0];
    }
}