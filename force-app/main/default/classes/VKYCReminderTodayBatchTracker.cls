@isTest
public class VKYCReminderTodayBatchTracker {
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
        
        Video_KYC__c vkycObj = new Video_KYC__c();
        vkycObj.Start_At__c = System.Today();
        vkycObj.Opportunity__c = opp.Id;
        insert vkycObj;
    }
    @isTest
    static void test1(){
        test.startTest();
        Database.executeBatch(new VKYCReminderTodayBatch());
        test.stoptest();
    } 

}