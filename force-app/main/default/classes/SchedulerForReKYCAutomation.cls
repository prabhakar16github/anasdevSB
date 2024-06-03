/*
 * Name of the class : SchedulerForReKYCAutomation
 * Author's Name     : Saksham Rohilla  
 * Description       : Scheduler class for ReKYCAutomationBatch
 */ 

global class SchedulerForReKYCAutomation implements Schedulable {
   global void execute(SchedulableContext sc) {
      ReKYCAutomationBatch obj1 = new ReKYCAutomationBatch(90); 
      Database.executeBatch(obj1,Integer.ValueOf(System.Label.Batch_Size_For_Bulk_Publish));
      //UpdateDormancyDetailsBatch obj2 = new UpdateDormancyDetailsBatch(); 
      //Database.executeBatch(obj2,25);
   }
}