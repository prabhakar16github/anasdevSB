@isTest
public class Delete_PayloadLogsDataSchedularTracker {

    @isTest    
    public static void unitTest(){
        loadData();
        String schTime = '0 0 2 * * ?';
        Delete_PayloadLogsDataSchedular obj = new Delete_PayloadLogsDataSchedular();
        System.schedule('Payload Delete', schTime, obj);
        
    }
    
    public static void loaddata(){
        Payload_Log__c obj = new Payload_Log__c();
        obj.Producer__c = 'salesforce';
        insert obj ;        
        Test.setCreatedDate(obj.Id, DateTime.newInstanceGmt(2019,02,12));
      
    }
}