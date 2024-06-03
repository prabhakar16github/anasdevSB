@isTest
global class MockClass implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){        
        HttpResponse res = new HttpResponse();
        Map<String, Object> resMap = new Map<String, Object>();
        res.setHeader('Content-Type', 'application/json');
        resMap.put('access_token', 'qwertyy');
        resMap.put('id', '69e40e6b-0203-493c-bfea-12e8f5daf27e'); 
        resMap.put('merchant', new Map<String, Object>{'test_mid' => 123});
        resMap.put('test_mid', 'qwertyy');
        resMap.put('registered_contact_person_name', 'Manav');
        resMap.put('operations_contact_person_name', 'ManavTest');
        resMap.put('queries_contact_name', 'ManavArora');
        resMap.put('registered_address', 'Delhi');
        resMap.put('operations_address', 'Noida');
        resMap.put('bank_account_number', '30551209999');
        resMap.put('bank_ifsc_code', 'SBIN0000001');
        res.setBody(JSON.serialize(resMap));
        res.setStatusCode(200);
        return res;
    }
}