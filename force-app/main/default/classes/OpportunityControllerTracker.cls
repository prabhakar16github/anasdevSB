@isTest
public class OpportunityControllerTracker {
    /*@testSetup static void setupCommonData(){        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'Legal', '12345');
        insert accountObj;
        system.debuG(accountObj);
        System.assertEquals('Legal-12345', [SELECT id, Name FROM Account WHERE Id =: accountObj.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
    }*/
    
    @isTest static void testMethodOne(){
        /*Account accountObj = [SELECT id, Name FROM Account LIMIT 1];
        
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];*/
        
        Test.startTest();
        //OpportunityController.getOptyRecord(opportunityObj.Id);
        
        OpportunityController.getOptyRecord(null);
        Test.stopTest();
    }
}