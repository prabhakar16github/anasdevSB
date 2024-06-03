@isTest
global class AddendumMockClass implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){        
        HttpResponse res = new HttpResponse();
        Map<String, Object> resMap = new Map<String, Object>();
        res.setHeader('Content-Type', 'application/json');
        resMap.put('document_path ', '"https://test-dms.payu.in/accounts/7597-0adb-00a5bb9c-457f-c38c19d0cbce/documents/83b351f46332241359666d56e35906f6');
        res.setBody(JSON.serialize(resMap));
        res.setStatusCode(200);
        return res;
    }
}