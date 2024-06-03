@isTest
public class DLQConsumerBatchTracker {
    @isTest static void testMethodOne() {            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XMLMockClass());
        Database.executeBatch(new DLQConsumerBatch());
        Database.executeBatch(new DLQConsumerBatch(true, false, 1));           
        Test.stopTest();        
    }
}