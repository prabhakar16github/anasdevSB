global class OneCareCaseReportBulkUpdateScheduler implements Schedulable{
    
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new OneCareCaseReportBulkUpdate()); 
   }

}