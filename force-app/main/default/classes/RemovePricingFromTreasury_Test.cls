@isTest
public class RemovePricingFromTreasury_Test {
	@testSetup
    static void dataSetupMethod(){
        Opportunity opp = New Opportunity();
        opp.Name='test1';
        opp.Email__c='test@test.com';
        opp.StageName='MAF';
        opp.CloseDate=Date.today();
        insert opp;
        
        Commercial2__c com = new Commercial2__c();
        com.Status__c = 'Draft';
        com.Opportunity__c = opp.Id;
        insert com;
        
        Payment_Mode__c mode = new Payment_Mode__c();
        mode.Name = 'Credit Card';
        insert mode;
        
        Payment_Option2__c payOption = new Payment_Option2__c();
        payOption.Name = 'VISA Credit Card';
        insert payOption;
        
        Payment_Gateway2__c payGate = new Payment_Gateway2__c();
        payGate.Name = 'HdfcCYBER';
        payGate.Type__c = 'PostApproved';
        payGate.Payment_Gateway_Id__c = '117';
        insert payGate;
        
        Pricing_Specification__c prSpec = new Pricing_Specification__c();
        prSpec.Name = 'International';
        insert prSpec;
            
        
        Master_Pricing_Data__c mp = new Master_Pricing_Data__c();
        mp.Salesforce_Primary_Key__c = 'SF774';
        mp.Payment_Mode__c = mode.Id;
        mp.Payment_Option__c = payOption.Id;
        mp.Payment_Gateway__c = payGate.Id;
        mp.Pricing_Specification__c = prSpec.Id;
        insert mp;
        
        Pricing__c pr = new Pricing__c();
        pr.Commercial2__c = com.Id;
        pr.Fee_Model__c = 'Net';
        pr.Transaction_Type__c = 'TDR';
        pr.TDR_Amount__c = 1000;
        pr.TDR_Flat_Fee__c = 150;
        pr.TDR__c = 1.50;
        pr.Convenience_Amount__c = 0;
        pr.Convenience_Flat_Fee__c = 200;
        pr.Convenience__c = 2;
        pr.Banking_Ops_Status__c = 'Approved';
        pr.Master_Pricing_Data__c = mp.Id;
        pr.Rule_Id__c = '5656';
        pr.Opportunity__c = opp.Id;
        insert pr;
        
        Pricing__c pr2 = new Pricing__c();
        pr2.Commercial2__c = com.Id;
        pr2.Fee_Model__c = 'Net';
        pr2.Transaction_Type__c = 'Convenience';
        pr2.TDR_Amount__c = 1000;
        pr2.TDR_Flat_Fee__c = 150;
        pr2.TDR__c = 1.50;
        pr2.Convenience_Amount__c = 0;
        pr2.Convenience_Flat_Fee__c = 200;
        pr2.Convenience__c = 2;
        pr2.Banking_Ops_Status__c = 'Approved';
        pr2.Master_Pricing_Data__c = mp.Id;
        pr2.Rule_Id_Conv__c = '9090';
        pr2.Opportunity__c = opp.Id;
        insert pr2;
        
        Pricing__c pr3 = new Pricing__c();
        pr3.Commercial2__c = com.Id;
        pr3.Fee_Model__c = 'Net';
        pr3.Transaction_Type__c = 'TDR + Convenience';
        pr3.TDR_Amount__c = 1000;
        pr3.TDR_Flat_Fee__c = 150;
        pr3.TDR__c = 1.50;
        pr3.Convenience_Amount__c = 0;
        pr3.Convenience_Flat_Fee__c = 200;
        pr3.Convenience__c = 2;
        pr3.Banking_Ops_Status__c = 'Approved';
        pr3.Master_Pricing_Data__c = mp.Id;
        pr3.Rule_Id__c = '54321';
        pr3.Rule_Id_Conv__c = '1234';
        pr3.Opportunity__c = opp.Id;
        insert pr3;
    }
    
    @isTest
    static void test1(){
        List<opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        
        RemovePricingFromTreasury.deletePricing('5656,9090,54321,1234',oppList[0].Name,oppList[0].Id);
        
    }
    @isTest
    static void test2(){
        List<opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        
        RemovePricingFromTreasury.deletePricing('112233',oppList[0].Name,'incorrect Id');
        
    }
    
    @isTest
    static void test3(){
        List<opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        
        RemovePricingFromTreasury.deletePricing('112233',oppList[0].Name,oppList[0].Id);
        
    }
}