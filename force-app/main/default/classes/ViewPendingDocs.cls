/*
* Name of the class : ViewPendingDocs
* Author's Name     : Rahul Pandey  
* Created Date      : 15th Dec, 2023
* Description       : API controller for fetching external data using Opportunity information, handling access token retrieval and API callouts. 
*/ 


/**
* Apex class to interact with an external API to fetch data based on Opportunity information.
* This class includes methods to obtain an access token and make a callout to the external API.
*/

public with sharing class ViewPendingDocs {
    
    /**
* Private method to obtain an access token from the external authentication service.
* @return String - Access token for API authentication.
*/
    
  /*  private static String getAccessToken (){
         Integration_Setting__mdt authDetail = IntegrationUtility.getIntSetting('Pending_Docs_Generate_Auth');
        system.debug ('>>>>>>>'+authDetail);
        String ACCESS_TOKEN = !Test.isRunningTest() ? IntegrationUtility.getAuthToken('Pending_Docs_Generate_Auth') : '2ec99b26f0536a6bea12a9a46dd587330f551d87750ad19bee82d9458b816844';

        // Create HTTP request for access token
        HttpRequest req=new HttpRequest();
        req.setEndpoint(authDetail.EndPointUrl__c);
        req.setMethod(authDetail.Method__c);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
         request.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        request.setTimeout(120000);
        
          Http http = new Http();
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()) {
            response = http.send(request);
        }else {
            String testResponseBody = '{"uuid":"11ee-7d58-1e1bfdbc-a7d0-02053299b2da","status":"link_generated","profile_id":"c7af44cc-69b8-4b9d-ab63-cfa596f09b9f","capture_link":"https://capture.kyc.idfy.com/captures?t=i3-7Bo_44aXs","scheduled_at":null,"start_time":null,"end_time":null,"capture_expires_at":null}';
            response.setBody(testResponseBody);
            response.setStatusCode(200);
        }
        
       
      
    }*/
    
    /**
* Private method to make a callout to the external API using the obtained access token.
* @param identifier String - Identifier used in the API request.
* @return Map<String, Object> - Response from the API in key-value format.
*/
    private static map<string, object> getDataFromCO(String identifier){
      //  Integration_Setting__mdt authDetail = IntegrationUtility.getIntSetting('Pending_Docs_Generate_Auth');
       
        // Obtain access token
            String ACCESS_TOKEN = !Test.isRunningTest() ?  IntegrationUtility.getAuthToken('Pending_Docs_Generate_Auth') : '2ec99b26f0536a6bea12a9a46dd587330f551d87750ad19bee82d9458b816844';
        system.debug('>>>>>>>>>>'+ACCESS_TOKEN);
         if(String.isBlank(ACCESS_TOKEN)){
            return null ;
        }
                 Integration_Setting__mdt apiDetail = IntegrationUtility.getIntSetting('Pending_Docs_Generate_API');

        // Create HTTP request for API data
        HttpRequest request=new HttpRequest();
        //request.setEndpoint('https://test10-onboarding.payu.in/api/v3/product_enrollments/product_account_details/'+identifier);
        request.setEndpoint(apiDetail.EndPointUrl__c+identifier);

        request.setMethod(apiDetail.Method__c);
        request.setHeader('Authorization','Bearer '+ACCESS_TOKEN);
        
        // Send HTTP request and process response
        Http http =new Http();
        HttpResponse response=http.send(request);
        Map<String,Object> responseMap = new Map<String,Object>();
        
        // Check if the API call was successful (HTTP status code 200)
        if(response.getStatusCode() == 200){
            String responseBody = response.getBody();
            responseMap=(Map<String,Object>) JSON.deserializeUntyped(responseBody);
            system.debug(responseMap);
            System.debug('Response from API: ' + responseMap);
            
        }else{
            // Log error if the API call was not successful
            
            System.debug('Error : '+response.getStatusCode());
        }
        return responseMap;
    }
    
    /**
* AuraEnabled method to fetch data from the external API based on the Opportunity identifier.
* @param oppId String - Opportunity Id used to identify the record.
* @return Map<String, Object> - Response from the external API.
*/
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchDataFromApi(String oppId) {
        system.debug('>>>>>>>'+oppId);
        // Query Opportunity information based on the provided Id
        
        List<opportunity> oppList =[ SELECT Id,Identifier__c FROM opportunity WHERE Id =:oppId LIMIT 1];
        
        
       
        // Check if the Opportunity record exists
        if(!oppList.isEmpty()){
            System.debug('Opportunity Identifier: ' + oppList[0].Identifier__c);
            
            // Call private method to get data from the external API
            
            return getDataFromCO(oppList[0].Identifier__c);
        }
        // Return null if the Opportunity record does not exist
        return null;
    }
}