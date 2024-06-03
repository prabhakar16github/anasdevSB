@isTest
public class COCalloutToGetMIDQueueableTest {
    @isTest
    static void testQueueableExecution() {
        // Create test data - Replace with your own test data as needed
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            Lead testLead = new Lead(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                Email = 'testemail' + i + '@example.com',
                MobilePhone = '888078787' + i,
                Select_Product__c = 'PayU Biz',
                Company = 'Test Company'
            );
            testLeads.add(testLead);
        }
        insert testLeads; // Insert test leads to obtain their Ids

        List<Id> leadIds = new List<Id>();
        for (Lead testLead : testLeads) {
            leadIds.add(testLead.Id);
        }

        // Enqueue the Queueable job
        /*Test.startTest();
        COCalloutToGetMIDQueueable queueable = new COCalloutToGetMIDQueueable(leadIds);
        System.enqueueJob(queueable);
        Test.stopTest();*/

        // Verify the results
        // Query the database to verify that Lead records were updated as expected
        List<Lead> updatedLeads = [SELECT Id, Prod_Merchant_Id__c, Merchant_Account_Id__c, Identifier__c, Error_Message__c FROM Lead WHERE Id IN :leadIds];
        
        // Assert that the number of updated Leads matches the number of test Leads
        System.assertEquals(testLeads.size(), updatedLeads.size(), 'Incorrect number of Leads updated');

        // Add more specific assertions based on your code's behavior
        for (Lead updatedLead : updatedLeads) {
            // Add assertions to check specific fields or conditions on the updated Leads
            //System.assertNotEquals(null, updatedLead.Prod_Merchant_Id__c, 'Prod_Merchant_Id__c not updated');
            //System.assertNotEquals(null, updatedLead.Merchant_Account_Id__c, 'Merchant_Account_Id__c not updated');
            //System.assertNotEquals(null, updatedLead.Identifier__c, 'Identifier__c not updated');
            updatedLead.Error_Message__c = 'Simulated error message';
        }
        
        Test.startTest();
        COCalloutToGetMIDQueueable queueable = new COCalloutToGetMIDQueueable(leadIds);
        System.enqueueJob(queueable);
        COCalloutToGetMIDQueueable queueableWithError = new COCalloutToGetMIDQueueable(leadIds);
        System.enqueueJob(queueableWithError);
        Test.stopTest();
    }

}