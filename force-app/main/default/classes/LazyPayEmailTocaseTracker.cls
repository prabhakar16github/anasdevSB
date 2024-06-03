@isTest
public class LazyPayEmailTocaseTracker {

    @isTest
    public static void unitTest1(){
     test.startTest();   
     Case oCase=new Case();
     oCase.status='New';
     oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
     oCase.Subject = 'Test';
     oCase.SuppliedEmail = 'test@gmail.com';   
     insert oCase; 
     List<Case> caseList = new List<Case>(); 
     caseList.add(oCase); 
     LazyPayEmailTocase.beforeInsertHandler(caseList);   
     test.stopTest();   
    }
}