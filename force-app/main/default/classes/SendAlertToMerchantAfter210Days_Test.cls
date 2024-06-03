@isTest
public class SendAlertToMerchantAfter210Days_Test {
    @isTest
    static void test1(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'test contact';
        con.AccountId = acc.Id;
        con.Email = 'test@abc.com';
        con.Authorised_Signatory__c = true;
        con.Active__c = true;
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Settlement_Status__c = 'Risk Hold';
        opp.Last_txn_date__c = System.today().addDays(-210);
        opp.CloseDate = System.today();
        insert opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opportunity';
        opp2.AccountId = acc.Id;
        opp2.StageName = 'Open';
        opp2.Settlement_Status__c = 'Risk Hold';
        opp2.Last_txn_date__c = System.today().addDays(-270);
        opp2.CloseDate = System.today();
        insert opp2;
        
        test.startTest();
        SendAlertToMerchantAfter210Days_Sch sch = new SendAlertToMerchantAfter210Days_Sch();
        sch.execute(NULL);
        //Database.executeBatch(new SendAlertToMerchantAfter210DaysBatch());
        test.stoptest();
    }
}