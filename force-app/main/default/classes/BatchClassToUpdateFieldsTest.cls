@isTest
public class BatchClassToUpdateFieldsTest {
    @testSetup
    public static void testDataSetup() {
        test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        test.stopTest();
    }
    
    @isTest
    public static void testBatchClassToUpdateFields() {
        test.startTest();
        Database.executeBatch(new BatchClassToUpdateFields('SELECT Id FROM Account','Account','{"Industry" : "Agriculture"}'),200);
        test.stopTest();
    }
}