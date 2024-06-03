@isTest
public class DataUpdateBatch_Test {
    @isTest
    static void test1(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Settlement_Status__c = 'Risk Hold';
        opp.Last_txn_date__c = System.today().addDays(-210);
        opp.CloseDate = System.today();
        opp.Prod_Merchant_Id__c = 1234;
        //opp.Onboarding_Completed__c = true;
        insert opp;
        
        test.startTest();
        String query = 'SELECT Id,VKYC_Exemption__c from Opportunity WHERE VKYC_Exemption__c = NULL';
        Database.executeBatch(new DataUpdateBatch(query,'VKYC_Exemption__c','not_applicable','String',NULL),2000);
        test.stoptest();
    }
    
    @isTest
    static void test2(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Settlement_Status__c = 'Risk Hold';
        opp.Last_txn_date__c = System.today().addDays(-210);
        opp.CloseDate = System.today();
        opp.Prod_Merchant_Id__c = 1234;
        //opp.Onboarding_Completed__c = true;
        insert opp;
        
        test.startTest();
        String query = 'SELECT Id,Prod_Merchant_Id__c,Prod_MID__c,VKYC_Exemption__c from Opportunity ';
        Database.executeBatch(new DataUpdateBatch(query,'VKYC_Exemption__c',NULL,'String',new Set<String>{String.valueOf(opp.Prod_Merchant_Id__c)}),2000);
        test.stoptest();
    }
}