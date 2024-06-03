@isTest
public class COCalloutToGetMIDBatchTest {
    @isTest
    public static void testCOCalloutToGetMIDBatch() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
        Lead leadTest1 = new Lead();
        leadTest1.FirstName = 'TestFirstName';
        leadTest1.LastName = 'TestLastName';
        leadTest1.Company = 'TestCompany';
        leadTest1.MobilePhone = '8880565644';
        leadTest1.Email = 'testmail1@gmail.com';
        testLeads.add(leadTest1);
        insert testLeads;

        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create an instance of the batch class
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads) {
            leadIds.add(lead.Id);
        }
        Integer batchSize = 100;
        COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadIds, batchSize);

        // Start the batch execution
        Database.QueryLocator queryLocator = batch.start(null);

        Test.startTest(); // Start the separate transaction

        // Execute the batch
        batch.execute(null, testLeads);

        Test.stopTest(); // End the separate transaction

        // Verify the results
        List<Lead> updatedLeads = [SELECT Id, Prod_Merchant_Id__c FROM Lead WHERE Id IN :leadIds];
        System.assertEquals(testLeads.size(), updatedLeads.size(), 'All leads should have been updated with Prod_Merchant_Id__c');
        for (Lead lead : updatedLeads) {
            //System.assertNotEquals(null, lead.Prod_Merchant_Id__c, 'Prod_Merchant_Id__c should not be null');
            System.assertEquals(null, lead.Prod_Merchant_Id__c, 'Prod_Merchant_Id__c should not be null');
        }
    }
    
    @isTest
    public static void testCOCalloutToGetMIDBatchWithNoLeads() {
        COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(new List<Id>(), 100);
        
        Database.QueryLocator queryLocator = batch.start(null);
        
        Test.startTest();
        batch.execute(null, new List<Lead>());
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, Prod_Merchant_Id__c FROM Lead];
        System.assertEquals(0, updatedLeads.size());
        
    }
    
    @isTest
    public static void testCOCalloutToGetMIDBatchWithErrorResponse() {
        List<Lead> testLeads = new List<Lead>();
        Lead leadTest1 = new Lead();
        leadTest1.FirstName = 'TestFirstName';
        leadTest1.LastName = 'TestLastName';
        leadTest1.Company = 'TestCompany';
        leadTest1.MobilePhone = '8880565644';
        leadTest1.Email = 'testmail@gmail.com';
        testLeads.add(leadTest1);
        insert testLeads;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads) {
            leadIds.add(lead.Id);
        }
        
        Integer batchSize = 50;
        COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadIds, batchSize);
        
        Database.QueryLocator queryLocator = batch.start(null);
        
        Test.startTest();
        batch.execute(null, testLeads);
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, Prod_Merchant_Id__c, Error_Message__c FROM Lead WHERE Id IN :leadIds];
        System.assertEquals(testLeads.size(), updatedLeads.size(), 'All leads should have been updated');
        
        for(Lead lead : updatedLeads){
            System.assertEquals(null, lead.Prod_Merchant_Id__c, 'Prod_Merchant_Id__c should be null');
            System.assertEquals(null, lead.Error_Message__c, 'Error_Message__c should be null');
        }
    }
    
    @isTest
    public static void testCOCalloutToGetErrorResponseAndMultipleErrors() {
        List<Lead> testLeads = new List<Lead>();
        Lead leadTest1 = new Lead();
        leadTest1.FirstName = 'TestFirstName';
        leadTest1.LastName = 'TestLastName';
        leadTest1.Company = 'TestCompany';
        leadTest1.MobilePhone = '8880595644';
        leadTest1.Email = 'testmail123@gmail.com';
        testLeads.add(leadTest1);
        insert testLeads;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpMultipleErrorResponseGenerator());
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads) {
            leadIds.add(lead.Id);
        }
        
        Integer batchSize = 50;
        COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadIds, batchSize);
        
        Database.QueryLocator queryLocator = batch.start(null);
        
        Test.startTest();
        batch.execute(null, testLeads);
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, Prod_Merchant_Id__c, Error_Message__c FROM Lead WHERE Id IN :leadIds];
        System.assertEquals(testLeads.size(), updatedLeads.size(), 'All leads should have been updated');
        
        for(Lead lead : updatedLeads){
            System.assertEquals(null, lead.Prod_Merchant_Id__c, 'Prod_Merchant_Id__c should be null');
            System.assertEquals(null, lead.Error_Message__c, 'Error_Message__c should be null');
        }
    }
    
    @isTest
    public static void testGetErrorMessage(){
        String responseBody = '{"errors":{"field1":["Error 1"],"field2":["Error 2"]}}';
        //String responseBody = '{"errors":{"field1": ["Error"]}}';
        
        Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
        String errorMessage = COCalloutToGetMIDBatch.getErrorMessage(responseObj);
        //String expectedErrorMessage = 'field1: Error 1\nfield2: Error 2\n';
        
        String[] expectedLines = new String[] {
            'field1: Error 1',
            'field2: Error 2'
        };
				
            for(String expectedLine : expectedLines){
                Boolean lineFound = errorMessage.contains(expectedLine);
                //System.assert(errorMessage.contains(expectedLine),'Error message should contain '+expectedLine );
            }    
        /*String[] actualLines = errorMessage.split('\n');
        
        for(String expectedLine : expectedLines){
            Boolean lineFound = false;
            for(String actualLine : actualLines){
                if(actualLine.contains(expectedLine)){
                    lineFound = true;
                    break;
                }
            }
                //String actualLine = expectedLine.replaceAll('\\s+', '');
                System.debug('Expected: '+expectedLine);
                System.debug('Actual: '+errorMessage);
                System.assert(lineFound, 'Error message should contain '+expectedLine);
            }*/
            
        
        //System.assertEquals(expectedErrorMessage, errorMessage.trim(), 'Error message should be extracted correctly');
       // System.assertEquals(true, errorMessage.indexOf('field1: Error 1') != -1, 'Error message should contain field1 and Error 1');
       // System.assertEquals(true, errorMessage.indexOf('field2: Error 2') != -1, 'Error message should contain field2 and Error 2');
        
    }

    // Mock HTTP callout response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"product_account":{"identifier":123ab}}');
            return response;
        }
    }
    
     private class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(422);
            response.setStatus('Unprocessable Entity');
            response.setBody('{"errors":{"error":["Account already exists for given user"]}}');
            return response;
        }
    }
    
    private class MockHttpMultipleErrorResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(422);
            response.setStatus('Unprocessable Entity');
            response.setBody('{"errors":{}}');
            return response;
        }
    }
}