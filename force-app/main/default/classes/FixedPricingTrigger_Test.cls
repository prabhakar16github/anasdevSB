@isTest
public class FixedPricingTrigger_Test {
	@isTest
    static void test1(){
        Trigger_Switch__c ts = new Trigger_Switch__c();
        ts.Name = 'Fixed_Pricing1__c';
        ts.Active__c = true;
        insert ts;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        
        opp.CloseDate = System.today();
        opp.Prod_Merchant_Id__c = 123456;
        //opp.Aggregator_UUID__c = '11ed-e4ea-b74b48aa-929c-02e708f88ebc';
        insert opp;
        
        
        Commercial2__c comm = new Commercial2__c();
        comm.Name = 'Test Commercial';
        comm.Opportunity__c = opp.Id;
        comm.Is_Updated__c = true;
        comm.Status__c = 'Live';
        insert comm;
        
        Fixed_Pricing1__c fp1 = new Fixed_Pricing1__c();
        fp1.Commercial__c = comm.Id;
        fp1.Fee_Type__c = 'AMC';
        fp1.Status__c = 'Approved (Awaiting Publishing)';
        fp1.Need_to_Publish__c = true;
        fp1.Deleted__c = false;
        fp1.Start_Date__c = System.today();
        insert fp1;
        fp1.Status__c = 'Error (Override Required)';
        update fp1;
        
    }
}