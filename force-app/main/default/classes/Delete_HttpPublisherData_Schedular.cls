public class Delete_HttpPublisherData_Schedular implements Schedulable {

    public  void execute(SchedulableContext SC){
        
        Database.executeBatch(new Delete_HttpPublisherData());
    }
    
}