@istest
public class Commercial2Trigger_Test {
    
    
    @testSetup
    public static void testDataSetup() {
        
        
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
        
        List<Commercial2__c> listCommercial = new List<Commercial2__c>();
        Commercial2__c comm = new Commercial2__c();
        comm.Name = 'Test Commercial';
        comm.Opportunity__c = opp.Id;
        comm.Is_Updated__c = true;
        comm.Status__c = 'Live';
        listCommercial.add(comm);
        
        Commercial2__c comm1 = new Commercial2__c();
        comm1.Name = 'Test Commercial 1';
        comm1.Opportunity__c = opp.Id;
        comm1.Is_Updated__c = true;
        comm1.Status__c = 'Draft';
        listCommercial.add(comm1);
        
        insert listCommercial;
        
        
    }
    
    @isTest
    public static void testCommercial2Trigger() {
        Test.startTest();
        Trigger_Switch__c ts = new Trigger_Switch__c();
        ts.Name = 'Commercial2__c';
        ts.Active__c = true;
        insert ts;
        
        List<Opportunity> listOpp = [SELECT Id from Opportunity LIMIT 1];
        
        List<Commercial2__c> listComm = new List<Commercial2__c>();
        Commercial2__c comm = new Commercial2__c();
        comm.Name = 'Test Commercial';
        comm.Opportunity__c = listOpp[0].Id;
        comm.Is_Updated__c = true;
        comm.Status__c = 'Live';
        listComm.add(comm);
        
        
        Commercial2__c comm1 = new Commercial2__c();
        comm1.Name = 'Test Commercial 1';
        comm1.Opportunity__c = listOpp[0].Id;
        comm1.Is_Updated__c = true;
        comm1.Status__c = 'Live';
        listComm.add(comm1);
        try{
            insert listComm;
        }catch(Exception ex){}
        
        
        
        Test.stopTest();
    }
    

}