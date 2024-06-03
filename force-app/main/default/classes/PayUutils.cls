public with sharing class PayUutils {
    
    public static HTTPResponse sendRequest(String endPoint, String body, String request){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(request);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        if(request.equalsIgnoreCase('post')){
            req.setBody(body);
        }
        System.debug('METH '+req.getMethod());
        Http http = new Http();
        System.debug('REQ '+req.getBody());
        HTTPResponse res = http.send(req);
        System.debug('RES '+res);
        return res;
    }
    public static String getViewPendingTokenDetail (String endPoint){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        String body = 'grant_type=client_credentials&scope=find_or_create&client_id={!$Credential.ViewPendingTokanDetails.client_id}&client_secret={!$Credential.ViewPendingTokanDetails.client_secret}';
        req.setBody(body);
        req.setTimeout(120000);
        req.setMethod('POST');
 
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String accesstoken = (String)resultMap.get('access_token');
        return accesstoken;
    }
    
}