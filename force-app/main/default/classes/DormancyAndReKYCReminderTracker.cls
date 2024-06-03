@isTest
public class DormancyAndReKYCReminderTracker {
    @testSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'test contact';
        con.AccountId = acc.Id;
        con.Email = 'test@abc.com';
        con.Authorised_Signatory__c = true;
        con.Active__c = true;
        con.PAN__c = 'ABCDE1234F';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Dormancy_Date__c = System.today().addDays(30);
        opp.CloseDate = System.today();
        insert opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opportunity';
        opp2.AccountId = acc.Id;
        opp2.StageName = 'Open';
        opp2.Next_ReKYC_Date__c = System.today().addDays(-1);
        opp2.CloseDate = System.today();
        insert opp2;
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test Opportunity';
        opp3.AccountId = acc.Id;
        opp3.StageName = 'Open';
        opp3.Next_ReKYC_Date__c = System.today().addDays(30);
        opp3.CloseDate = System.today();
        insert opp3;

    }
	@isTest
    static void test1(){
                
        test.startTest();
        //DormancyAndReKYCReminder sch = new DormancyAndReKYCReminder('REKYC_REMINDER');
        //sch.execute(NULL);
        Database.executeBatch(new DormancyAndReKYCReminder('REKYC_REMINDER'));
        test.stoptest();
    }
    @isTest
    static void test2(){
        test.startTest();
        Database.executeBatch(new DormancyAndReKYCReminder('DORMANCY_REMINDER'));
        test.stoptest();
    } 
    @isTest
    static void test3(){
        test.startTest();
        Database.executeBatch(new DormancyAndReKYCReminder('REKYC_OVERDUE'));
        test.stoptest();
    }
}