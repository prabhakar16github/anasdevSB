@isTest(SeeAllData=true)
public class OneCareCaseReportBulkUpdate_Tracker {
   
    @isTest
     static void createData(){
         
       List<Status_SLA__c> caseList = [Select Id,Case__r.RecordTypeId,Case__r.Id,Case__r.LOB_Name__c,createdDate from Status_SLA__c
                              where createdDate>2019-11-30T00:00:00Z AND createdDate<2020-01-01T00:00:00Z LIMIT 1];
         
        
         
         Test.startTest();
        Database.executeBatch(new OneCareCaseReportBulkUpdate());
        Test.stopTest();
    }
    
    /*@isTest(SeeAllData=true)
	private static void StatusNewToOpen(){
       
        List<Case> newCaseList = [SELECT Id,Status,RecordTypeId,LP_Sub_Status__c,LastModifiedDate,lob_name__c From Case 
                                  where LOB_Name__c!='Technical Team'];
        
        newCaseList[0].Status = 'Open';
        update newCaseList;
                
        Status_SLA__c status  = new Status_SLA__c(); 
        status.Case__c = newCaseList[0].Id;
        status.OneCare_New_Open_Time__c = system.now();
        upsert status;
                
        Test.startTest();
        Database.executeBatch(new OneCareCaseReportBulkUpdate());
        Test.stopTest();
    }
    
    @isTest
    private static void StatusNewToOpen2(){
       
        List<Case> newCaseList = [SELECT Id,Status,RecordTypeId,LP_Sub_Status__c,LastModifiedDate,lob_name__c From Case 
                                  Where LOB_Name__c='Technical Team'];
        
        newCaseList[0].Status = 'Open';
        update newCaseList;
                
        Status_SLA__c status2  = new Status_SLA__c(); 
        status2.Case__c = newCaseList[0].Id;
        status2.OneCare_New_Open_Time__c = system.now();
        upsert status2;
        
        Test.startTest();
        Database.executeBatch(new OneCareCaseReportBulkUpdate());
        Test.stopTest();
    }*/
}