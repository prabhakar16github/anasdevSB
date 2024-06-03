@isTest
public class AWSConsumerAPITracker {
    @isTest static void testMethodOne() {            
         
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new XMLMockClass());
        AWSConsumerAPI.start();
        Test.stopTest();        
    }
}