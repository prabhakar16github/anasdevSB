@isTest
global class S3CalloutMockTestClass implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        String endPoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        if(endPoint.contains('https://login.microsoftonline.com')) {
        	res.setStatusCode(200);
        	res.setBody('{"access_token" : "123"}');    
        }
        else if(endPoint.contains('https://graph.microsoft.com')) {
        	res.setStatusCode(201);    
        }
        else {
         	res.setStatusCode(200);   
        }
        return res;
    }
}