public class SettlementStatusSyncBatchScheduler implements Schedulable{
	public void execute(SchedulableContext SC) {
        String batchName = 'SettlementStatusSyncBatch';
        Database.executeBatch(new SettlementStatusSyncBatch(batchName,true,false),5);
    }
}