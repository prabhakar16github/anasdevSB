public class KAMAssignmentUpdateBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC) {
        string batchName = 'KAMAssignmentUpdateBatch';
        Boolean isPublisher = false;
        Boolean isUpdate = true;
        Set<Id> oppIds = New Set<Id>();
        KAMAssignmentUpdateBatch batchable = new KAMAssignmentUpdateBatch(batchName,isPublisher, isUpdate, oppIds); 
        Database.executeBatch(batchable);
    }
}