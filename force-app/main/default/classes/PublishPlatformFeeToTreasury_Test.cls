@isTest
public class PublishPlatformFeeToTreasury_Test {
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
        
        Platform_Fee__c plafrom = new Platform_Fee__c();
        plafrom.Commercial__c = com.Id;
        plafrom.Need_to_Publish__c = true;
        plafrom.Amount__c = 10000;
        plafrom.Flat_Fee__c = 200;
        Insert plafrom;  
        Fixed_Pricing1__c  fixed = new Fixed_Pricing1__c ();
        fixed.Commercial__c = com.Id;
        fixed.Debit_Model__c = 'Net';
        fixed.Start_Date__c = System.today();
        fixed.End_Date__c = System.today().addDays(1);
        fixed.Need_to_Publish__c = true;
        insert fixed;
    }
    @isTest
    static void test1(){
        List<opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        List<Commercial2__c> commList = [SELECT Id,Name,Opportunity__c FROM Commercial2__c LIMIT 1];
        System.assertEquals(oppList[0].Id,commList[0].Opportunity__c);
        PublishPlatformFeeToTreasury_CTRL.PricingToTreasury(commList[0].Id);
        PublishFixedFeeToTreasury_CTRL.FixedFeeToTreasury(commList[0].Id);
    }
}