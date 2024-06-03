@isTest
public class Delete_HttpPublisherDataSchedularTracker {

    @isTest
    public static void unitTest(){
        
        String schTime = '0 0 0 * * ?';
        System.schedule('HTTP Delete', schTime, new Delete_HttpPublisherData_Schedular());
    }
    
}