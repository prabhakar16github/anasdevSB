public with sharing class CookbookBot_REST_Utils {
    
    public static Boolean getButtonAvailabilityForTransfer(String sBotOrgId, String sBotDeploymentId, String sBotTransferButtonId) {
        Boolean isAvailable = false;
        String sOrgId = sBotOrgId.substring(0, 15);
        String sButtonId = sBotTransferButtonId.substring(0, 15);
        String sDeploymentId = sBotDeploymentId.substring(0, 15);
        
        String sPath = 'callout:CookbookBot_LiveAgent_REST/chat/rest/Visitor/Availability?Availability.ids=['+sButtonId+']&deployment_id='+sDeploymentId+'&org_id='+sOrgId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(sPath);            
        
        request.setMethod('GET');
        request.setHeader('X-LIVEAGENT-API-VERSION', '42');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        system.debug('response '+response);
        if (response.getStatusCode() == 200) {
            system.debug('Chat Button Availability - raw data: ');
            System.debug(response.getBody());
            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'isAvailable')) {
                        // Get the value.
                        parser.nextToken();
                        isAvailable = parser.getBooleanValue();
                        if (isAvailable == null) isAvailable = false;
                    }
            }
        }    
        system.debug('Chat Button Availability - return value: ' +isAvailable);
        return isAvailable;
    }
}