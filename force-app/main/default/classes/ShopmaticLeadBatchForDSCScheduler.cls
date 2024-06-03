global class ShopmaticLeadBatchForDSCScheduler implements Schedulable{
    
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new ShopmaticLeadBatchForDSC()); 
   }

}