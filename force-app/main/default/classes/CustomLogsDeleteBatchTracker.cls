@isTest
public class CustomLogsDeleteBatchTracker {

    public static testMethod void data1(){
        payload_log__c pl = new payload_log__c();
        insert pl;
        Test.startTest();
        string payLoadObj = 'payload_log__c';
        database.executeBatch(new CustomLogsDeleteBatch(payLoadObj));  
        system.schedule('test To delete Log', '0 25 15 1/1 * ? *', new CustomLogsDeleteBatchScheduler());
        Test.stopTest();
    }
}