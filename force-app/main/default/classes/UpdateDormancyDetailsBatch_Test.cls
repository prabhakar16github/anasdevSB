@isTest
public class UpdateDormancyDetailsBatch_Test {
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
        //opp1.Pre_Approved_for_priority_settlement__c = false;
        opp1.First_Txn_date__c = System.today().addMonths(-6);
        opp1.Last_txn_date__c = System.today().addDays(-280);
        
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
        //opp2.Pre_Approved_for_priority_settlement__c = true;
        opp1.First_Txn_date__c = System.today().addMonths(-3);
        insert opp2;
        
        Platform__c plat = new Platform__c ();
        plat.Name = 'test plat';
        insert plat;
        
        Product__c  prod = new Product__c ();
        prod.Name = 'test prod';
        prod.Platform__c = plat.Id;
        insert prod;
        
        Cross_Sell__c cs = new Cross_Sell__c();
        cs.Name = 'Payout';
        //cs.Active__c = true;
        cs.RecordTypeId = Schema.SobjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Payout').getRecordTypeId ();
        cs.Opportunity__c = opp1.Id;
        cs.Custom_Product__c = prod.Id;
        insert cs;
        
    }
	@isTest
    static void test1(){
        List<Opportunity> oppList = [SELECT Id,CTS__c,Last_3_months_GMV__c,Last_6_months_GMV__c,
                                     Pre_Approved_for_priority_settlement__c,Integration_Type__c FROM Opportunity WHERE CTS__c < 1 LIMIT 1];
        Test.startTest();
        Database.executeBatch(new UpdateDormancyDetailsBatch());
        Test.stopTest();
    }
}