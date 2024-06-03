public class Check_AgencyAllocationBatchSchedular implements Schedulable{
        
    public  void execute(SchedulableContext SC){        
        Database.executeBatch(new Check_AgencyAllocationBatch());
    }

}