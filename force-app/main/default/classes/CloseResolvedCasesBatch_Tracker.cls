@isTest
public class CloseResolvedCasesBatch_Tracker {

@isTest
    public static void unitTest1(){    
    case obj = new Case ();
    obj.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();        
    obj.LP_Resolved_Date__c = Date.TODAY().addDays(-9);
    obj.status = 'Resolved';    
    insert obj;

    CloseResolvedCasesBatch_Schedular sh1 = new CloseResolvedCasesBatch_Schedular();
    String sch = '0 0 2 * * ?';
    test.startTest();    
    system.schedule('Check', sch, sh1);  
    test.stopTest();    
    //CloseResolvedCasesBatch batchObj =new CloseResolvedCasesBatch();        
    //Database.executeBatch(batchObj);   
    }  

}