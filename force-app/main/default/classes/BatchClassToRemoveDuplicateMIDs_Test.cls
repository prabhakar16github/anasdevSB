@isTest
public class BatchClassToRemoveDuplicateMIDs_Test {
    @testSetup
    public static void testDataSetup() {
        
        List<Opportunity> listOpportunityToInsert = new List<Opportunity>();
        
        Opportunity testOpportunity1 = new Opportunity();
        testOpportunity1.Name = 'Test Opportunity 1';
        testOpportunity1.Product__c = 'a0U0p000001OWB6EAO';
        testOpportunity1.Prod_Merchant_Id__c = 12345;
        testOpportunity1.Identifier__c = '11ed-b8db-c747e03c-b152-02053299b2da';
        testOpportunity1.StageName = 'Closed';
        testOpportunity1.CloseDate = System.today() + 10;
        listOpportunityToInsert.add(testOpportunity1);
        
        Opportunity testOpportunity2 = new Opportunity();
        testOpportunity2.Name = 'Test Opportunity 1';
        testOpportunity2.Product__c = 'a0U0p000001OWB6EAO';
        testOpportunity2.Prod_Merchant_Id__c = 12345;
        testOpportunity2.Identifier__c = '11ed-b8db-c747e03c-b152-02053299b2db';
        testOpportunity2.StageName = 'Closed';
        testOpportunity2.CloseDate = System.today() + 10;
        testOpportunity2.Is_Duplicate__c = 'Y';
        listOpportunityToInsert.add(testOpportunity2);
        
        insert listOpportunityToInsert;
        
        Temporary_Object__c tempObject = new Temporary_Object__c();
        tempObject.MID__c = '12345';
        tempObject.UUID__c = '11ed-b8db-c747e03c-b152-02053299b2da';
        insert tempObject; 
        
    }
    
    @isTest
    public static void testMethod1() {
        Test.startTest();
        Database.executeBatch(new BatchClassToRemoveDuplicateMIDs());
        Test.stopTest();
    }
    
    
}