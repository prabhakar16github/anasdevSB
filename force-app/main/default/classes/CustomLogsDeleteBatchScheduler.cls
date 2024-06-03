public class CustomLogsDeleteBatchScheduler implements Schedulable{

    public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        string payLoadSObject = 'PayLoad_Log__c';
        database.executebatch(new CustomLogsDeleteBatch(payLoadSObject));
        
        string errorSObject = 'Error_Details__c';
        database.executebatch(new CustomLogsDeleteBatch(errorSObject));
     }
}