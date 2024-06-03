global class LeadBankVerificationCheckBatchScheduler implements Schedulable{
    
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new LeadBankVerificationCheckBatch()); 
   }
    
}