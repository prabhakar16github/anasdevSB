global class CloseResolvedCasesBatch_Schedular implements Schedulable {

            global void execute(SchedulableContext sc) {
            CloseResolvedCasesBatch obj = new CloseResolvedCasesBatch();
            Database.executeBatch(obj);
        }  
}