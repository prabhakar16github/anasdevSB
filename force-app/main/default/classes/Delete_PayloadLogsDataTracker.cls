@isTest
public class Delete_PayloadLogsDataTracker {

    @isTest
    public static void unitTest(){
      loadData();
      Database.executeBatch(new Delete_PayloadLogsData());
       
    }
    public static void loaddata(){
        Payload_Log__c obj = new Payload_Log__c();
        obj.Producer__c = 'salesforce';
        insert obj ;        
        Test.setCreatedDate(obj.Id, DateTime.newInstanceGmt(2019,02,12));
      
    }  

}