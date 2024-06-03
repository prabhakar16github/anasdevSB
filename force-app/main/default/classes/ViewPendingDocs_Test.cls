@isTest
private class ViewPendingDocs_Test {

    @isTest
    static void testFetchDataFromApi() {
        // Create a test opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() + 30
        );
        insert testOpp;

        // Create a mock response for the access token request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the fetchDataFromApi method
        Test.startTest();
        ViewPendingDocs.fetchDataFromApi(testOpp.Id);
        Test.stopTest();

       
    }

    // Mock HTTP callout class for generating a mock response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mockAccessToken"}');
            return res;
        }
    }
}