@isTest
public class PendingSettlementAmount_Test {
    @isTest
    static void testUpdateMethod() {
        // Test data setup
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity',stageName='Onboarding',closeDate=System.today());
        insert testOpportunity;
        // Start test for update method
        Test.startTest();
        // Set up a mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call the update method
        PendingSettlementAmount_Controller.updatePendingAmount(testOpportunity.Id);
        // Query the updated Opportunity record
        Opportunity updatedOpportunity = [SELECT Id, Settlement_Amount_on_Hold__c  FROM Opportunity WHERE Id = :testOpportunity.Id];
        Test.stopTest();
    }

    // Mock HTTP callout response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response based on the request
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"code": "2000","message": "Success","status": 0,"result": {"20000770": 0}}');
            return res;
        }
    }
}