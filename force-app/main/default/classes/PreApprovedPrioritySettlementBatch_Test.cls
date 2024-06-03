@isTest
public class PreApprovedPrioritySettlementBatch_Test {
	@testsetup
    static void testSetupMethod(){
        Opportunity opp1 = New Opportunity();
        opp1.Name='test1';
        opp1.Email__c='test@test.com';
        opp1.StageName='MAF';
        opp1.CloseDate=Date.today();
        opp1.Integration_Type__c = 'Tools';
        opp1.CTS__c = 0.9;
        opp1.Last_6_months_GMV__c = 1234;
        opp1.Last_3_months_GMV__c = 630;
        opp1.Pre_Approved_for_priority_settlement__c = false;
        opp1.First_Txn_date__c = System.today().addMonths(-6);
        insert opp1;
        
        Opportunity opp2 = New Opportunity();
        opp2.Name='test2';
        opp2.Email__c='test2@test.com';
        opp2.StageName='MAF';
        opp2.CloseDate=Date.today();
        opp2.Integration_Type__c = 'ThirdParty';
        opp2.CTS__c = 1.5;
        opp2.Last_6_months_GMV__c = 1234;
        opp2.Last_3_months_GMV__c = 630;
        opp2.Pre_Approved_for_priority_settlement__c = true;
        opp1.First_Txn_date__c = System.today().addMonths(-3);
        insert opp2;
        
    }
    
    @isTest
    static void test1(){
        List<Opportunity> oppList = [SELECT Id,CTS__c,Last_3_months_GMV__c,Last_6_months_GMV__c,Priority_Settlement_Pre_Approved_Limit__c,
                                     Pre_Approved_for_priority_settlement__c,Integration_Type__c FROM Opportunity WHERE CTS__c < 1 LIMIT 1];
        Test.startTest();
        Database.executeBatch(new PreApprovedPrioritySettlementBatch());
        Test.stopTest();
    }
    
    @isTest
    static void test2(){
        List<Opportunity> oppList = [SELECT Id,CTS__c,Last_3_months_GMV__c,Last_6_months_GMV__c,Priority_Settlement_Pre_Approved_Limit__c,
                                     Pre_Approved_for_priority_settlement__c,Integration_Type__c FROM Opportunity WHERE CTS__c >= 1 
                                     AND Pre_Approved_for_priority_settlement__c = true LIMIT 1];
        Test.startTest();
        Database.executeBatch(new PreApprovedPrioritySettlementBatch());
        Test.stopTest();
    }
}