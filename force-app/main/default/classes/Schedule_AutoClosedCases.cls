global class Schedule_AutoClosedCases implements Schedulable {
    global void execute(SchedulableContext SC) {
        
        Batch_AutoClosedCases batchable = new Batch_AutoClosedCases(false,true,false,New Set<String>()); 
        Database.executeBatch(batchable);
    }
}