public class Delete_PayloadLogsDataSchedular implements Schedulable {

    public void execute(SchedulableContext SC){
       Database.executeBatch(new Delete_PayloadLogsData()); 
    }
    
}