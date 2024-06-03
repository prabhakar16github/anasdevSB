@isTest 
public class changeStatus_test_class {
    
    @testSetup static void setupCommonData(){
        Account accountObj = new Account();
        accountObj.Name='test1';
        //accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Delivery_Duration__c = 1;
        accountObj.Monthly_Expected_Sale__c = 10000;
        insert accountObj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
       
        Contact ContObj = new contact();
        ContObj.LastName = 'Test Lead';
        ContObj.AccountId = accountObj.id;
         insert ContObj;
        
       Case caseObj = new Case();
        CaseObj.Status='Resolved';
        CaseObj.Comments='Resolving the test case';
        insert CaseObj;
        Test.stopTest();  
        
    }
        
    static testMethod void testCase() 
    {
        Case cs1 = [Select ID,Status,Comments from Case ];
        Test.startTest();
        Test.setCurrentPage(Page.ChangeStatus);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Case> {cs1});
        stdSetController.setSelected(new List<Case> {cs1});
        ChangeCaseStatus ext = new ChangeCaseStatus(stdSetController);
        ext.getSelectedCase();
        ext.getMySelectedSize();
        ext.getcasestatus();
        Test.stopTest();
    
    }
    
}