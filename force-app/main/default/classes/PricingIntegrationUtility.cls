/**
* @Name         :    PricingIntegrationUtility 
* @Author       :    Prabhakar Joshi
* @Group        :    Pricing
* @Description  :    Utility class for pricing integration(fetchPricing,removePricing,saveBulkRules) with treasury.
*/

public with sharing class PricingIntegrationUtility {
    /** 
    * method definition to get the access token to access the Treasuty API.
    * @param - DeveloperName of Pricing_API_Setting__mdt metadata record.
    * @return type - access token getting from treasury for authentication.
    */

    public static String getAccessToken(String apiSettingName){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        Pricing_API_Setting__mdt tokenSetting = Pricing_API_Setting__mdt.getInstance(apiSettingName);
        
        req.setMethod(tokenSetting.Method__c);
        req.setEndpoint(tokenSetting.End_Point_URL__c);
        for(String header : tokenSetting.Headers__c.split(',')){
            req.setHeader(header.split(':')[0],header.split(':')[1]);
        }
        
        req.setBody(tokenSetting.Body__c);
        HttpResponse response = new HttpResponse();
        if(!test.isRunningTest()){response = http.send(req);
        }else{
            String testBody = '{"access_token": "81d3eb398ab2e01af62624e14e6f789dc6c65779c4e1fd9007fe14c3655df47c","token_type": "Bearer","expires_in": 7199,"scope": "test_rules","created_at": 1675063520}';
            response.setStatusCode(200);
            response.setBody(testBody);
        }
        
        if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
            Map<String,Object> authMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            return String.valueOf(authMap.get('access_token'));
        }
        return NULL;
    }/** END */
    
    /** 
    * method definition to perform the http callout with Treasury System & store the response in the SF.
    * @param 1 - DeveloperName of Pricing_API_Setting__mdt metadata record.
    * @param 2 - access token
    * @param 3 - request body in String
    * @return type - Http Response 
    */
    public static HttpResponse doCallout(String apiSettingName,String access_token,String bodyStr,String processName){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        Pricing_API_Setting__mdt callOutDetails = Pricing_API_Setting__mdt.getInstance(apiSettingName);
        req.setMethod(callOutDetails.Method__c);
        req.setEndPoint(callOutDetails.End_Point_URL__c);
        
        for(String header : callOutDetails.Headers__c.split(',')){
            if(header.contains('<access_token>')){
                header = header.replace('<access_token>',access_token);
            }
            req.setHeader(header.split(':')[0],header.split(':')[1]);
        }
        req.setBody(bodyStr);
        HttpResponse response = new HttpResponse();
        if(!test.isRunningTest()){response = http.send(req);
        }else{
            //String testBody = '[{"code": "2000","message": "Success","status": 0,"result": {"Type": "added","ruleId": "7119650"}}]';
            response.setBody(generateFakeResponse(processName,bodyStr));
            response.setStatusCode(200);
            response.setStatus('OK');
           
        }
        return response;
    }/** END */

    /** 
    * method definition to generate the mock response for pricing Integration (fetch,remove & savebulk).
    * @param 1 : name of the process (fetch/remove/savebulk) 
    * @param 2 : request body String
    * @return type - String (mock response String)
    */
    private static String generateFakeResponse(String processName, String bodyStr){
        String testBody = '';
        if(processName == 'saveBulkRules'){
            List<Map<String,String>> listBodyMap = (List<Map<String,String>>)JSON.deserialize(bodyStr,List<Map<String,String>>.class);
            String pricingId1,pricingId2;
            if(listBodyMap[0] != NULL && listBodyMap[0].get('pricingRecordId') != NULL){
                pricingId1 = (String)listBodyMap[0].get('pricingRecordId');
            }
            if(listBodyMap[1] != NULL && listBodyMap[1].get('pricingRecordId') != NULL){
                pricingId2 = (String)listBodyMap[1].get('pricingRecordId');
            }
            testBody = '[{"code": "2000","message": "Success","status": 0,"result": {"Type": "added","pricingRecordId": "'+pricingId1+'","ruleId": "873"}},{"code": "500","message": "Exception occurred while saving a rule : Mandatory field clientId missing,Mandatory field merchantId missing","status": 1,"result": {"pricingRecordId": "'+pricingId2+'"},"traceId": "157bfd067e6395596f46e8d4402b1802"}]';
        }
        else if(processName == 'Platform Fee'){testBody ='{"code": "2000","message": "Success","status": 0,"result": {"pricingRuleConfigId": 10796866,"clientId": 1,"subClientId": null,"entityId": 8607226,"revenueModel": "Platform fees","debitModel": "net","amountSlab": 0,"validFrom": "2023-07-12T19:30:00.000+00:00","validTill": null,"fromTime": null,"tillTime": null,"dayOfWeek": null,"frequency": null,"aggregationRequired": true,"percentFee": 0,"flatFee": 0,"isActive": true,"approved": 0,"sharedFee": 1.0,"feeBearerEntity": null,"feeBearerEntityId": 0,"attributes": [{"pricingRuleAttributesId": null,"clientId": null,"pricingRuleConfigId": null,"pricingRuleKey": null,"pricingRuleValue": null,"operator": "=","isActive": true}],"mappingId": null,"addedOn": "2023-09-13T13:07:23.419+00:00","updatedOn": "2023-09-13T13:07:23.419+00:00","addedBy": "","updatedBy": "","merchantName": null,"isAggregationRequired": null,"entityRatesId": null,"pgMid": null,"aggregationPeriod": "daily","gmvSlabValue": 0}}';
        }
        else if(processName == 'Fixed Pricing Fee'){testBody ='{"code": "2000","message": "Success","status": 0,"result": {"pricingRuleConfigId": 10796866,"clientId": 1,"subClientId": null,"entityId": 8607226,"revenueModel": "Platform fees","debitModel": "net","amountSlab": 0,"validFrom": "2023-07-12T19:30:00.000+00:00","validTill": null,"fromTime": null,"tillTime": null,"dayOfWeek": null,"frequency": null,"aggregationRequired": true,"percentFee": 0,"flatFee": 0,"isActive": true,"approved": 0,"sharedFee": 1.0,"feeBearerEntity": null,"feeBearerEntityId": 0,"attributes": [{"pricingRuleAttributesId": null,"clientId": null,"pricingRuleConfigId": null,"pricingRuleKey": null,"pricingRuleValue": null,"operator": "=","isActive": true}],"mappingId": null,"addedOn": "2023-09-13T13:07:23.419+00:00","updatedOn": "2023-09-13T13:07:23.419+00:00","addedBy": "","updatedBy": "","merchantName": null,"isAggregationRequired": null,"entityRatesId": null,"pgMid": null,"aggregationPeriod": "daily","gmvSlabValue": 0}}';
        }
        else if(processName == 'Other Product Pricing'){
            testBody ='{"code": "2000","message": "Success","status": 0,"result": {"pricingRuleConfigId": 10797207,"clientId": 1,"subClientId": null,"entityId": 8607226,"revenueModel": "instantSettlementTdr","debitModel": "net","amountSlab": 0,"validFrom": null,"validTill": null,"fromTime": null,"tillTime": null,"dayOfWeek": null,"frequency": null,"aggregationRequired": true,"percentFee": null,"flatFee": null,"isActive": true,"approved": 0,"sharedFee": null,"feeBearerEntity": "HDFC","feeBearerEntityId": 123,"attributes": [{"pricingRuleAttributesId": null,"clientId": null,"pricingRuleConfigId": null,"pricingRuleKey": "GmvSlab","pricingRuleValue": "10000","operator": "=","isActive": true}],"mappingId": null,"addedOn": "2023-10-16T07:35:02.550+00:00","updatedOn": "2023-10-16T07:35:02.550+00:00","addedBy": null,"updatedBy": null,"merchantName": null,"isAggregationRequired": null,"entityRatesId": null,"pgMid": null,"aggregationPeriod": "daily","gmvSlabValue": 0}}';
        }
        /*else if(processName == 'Fallback Fee'){String pricingId1;
            List<Map<String,String>> listBodyMap = (List<Map<String,String>>)JSON.deserialize(bodyStr,List<Map<String,String>>.class);
            if(listBodyMap[0] != NULL && listBodyMap[0].get('pricingRecordId') != NULL){
                pricingId1 = (String)listBodyMap[0].get('pricingRecordId');
            }
            testBody ='[{"code": "2000","message": "Success","status": 0,"result": { "Type": "updated","pricingRecordId": "'+pricingId1+'","ruleId": "9591812"}}]';
        }*/
        else if(processName == 'removePricing'){
            testBody = '{"code":"2001","message":"Removed SuccessFully","status":0,"result":{"ruleIdNotFound":"112233","ruleId":"5656,9090,1234,54321"}}';
            
        }else if(processName == 'FetchAPI'){
            testBody = '{"code":"2000","message":"Success","status":0,"result":[{"clientId":"1","merchantId":"8504102","ruleId":"7119698","paymentMode":"upi","type":"TDR","debitModel":"Net","subPaymentMode":"abc","paymentScheme":"abc","paymentEntity":123,"moreThanAmount":1000,"isOnus":1,"refundMode":null,"cardType":"Default","validFrom":"2023-04-27 12:00:00","validTill":null,"gmvLimit":null,"gmvLimtMode":null,"flatFee":5.01,"percentageFee":1.51,"tdrType":"0"}]}';
        }

        return testBody;
    }/** END */
}