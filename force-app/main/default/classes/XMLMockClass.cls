@isTest
global class XMLMockClass implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){        
        HttpResponse res = new HttpResponse();
        Map<String, Object> resMap = new Map<String, Object>();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(Label.TestXMLData);
        res.setStatusCode(200);
        return res;
    }
}