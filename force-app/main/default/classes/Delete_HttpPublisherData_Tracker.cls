@isTest
public class Delete_HttpPublisherData_Tracker {

   @isTest
    public static void unitTest(){       
        LP_HTTP_Publisher__c obj = new LP_HTTP_Publisher__c();
        obj.LP_ProcessName__c = 'Knowlarity' ;
        insert obj ;
        Test.setCreatedDate(obj.Id, DateTime.newInstanceGmt(2018,12,12));
        test.startTest();
        Delete_HttpPublisherData batchObj = new Delete_HttpPublisherData();
        database.executeBatch(batchObj);  
        test.stopTest();
   
    } 
}