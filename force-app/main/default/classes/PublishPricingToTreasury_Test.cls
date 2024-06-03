@isTest
public class PublishPricingToTreasury_Test {
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
        pr.Deleted__c = false;
        pr.Need_to_Publish__c = TRUE;
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
        pr2.Need_to_Publish__c = TRUE;
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
        pr3.Need_to_Publish__c = TRUE;
        insert pr3;
        
        SF_Treasury_Transformer__c transform = new SF_Treasury_Transformer__c();
        transform.IsOnus__c = '1';
        transform.Payment_Mode__c = 'upi';
        transform.Sub_Payment_Mode__c = 'abc';
        transform.SF_ID__c = 'SF774';
        transform.Payment_Scheme__c = 'abc';
        transform.Payment_Entity__c = 123;
        transform.Card_Type__c = 'Default';
        insert transform;
        
    }
    @isTest
    static void test1(){
        List<opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        List<Commercial2__c> commList = [SELECT Id,Name,Opportunity__c FROM Commercial2__c LIMIT 1];
        System.assertEquals(oppList[0].Id,commList[0].Opportunity__c);
        
        List<Pricing__c> prList = [SELECT Id,Name,Transaction_Type__c,Banking_Ops_Status__c,TDR_Amount__c,TDR_Flat_Fee__c,TDR__c,Convenience_Amount__c,Rule_Id__c,
                                   Rule_Id_Conv__c,Convenience_Flat_Fee__c,Convenience__c,Fee_Model__c,Commercial2__c FROM Pricing__c];
        System.assertEquals(commList[0].Id, prList[0].Commercial2__c);
        
        List<SF_Treasury_Transformer__c> transformDataList = [SELECT Id,Name,IsOnus__c,Payment_Mode__c,Sub_Payment_Mode__c,SF_ID__c,Payment_Scheme__c,Payment_Entity__c,Card_Type__c 
                                                              FROM SF_Treasury_Transformer__c LIMIT 50000];
        
        Database.executeBatch(new PublishPricingToTreasury(commList[0].Id), 500);
        Database.executeBatch(new PublishPricingToTreasury(new Set<String>{prList[0].Id}), 500);
        
    }
    
    
}