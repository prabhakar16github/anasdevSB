@isTest
public class PricingTriggerHandlerTest {
    @testSetup
    public static void testDataSetup() {
        Trigger_Switch__c trgSwtchObj = new Trigger_Switch__c();
        trgSwtchObj.Active__c = True;
        trgSwtchObj.Name = 'Pricing';
        insert trgSwtchObj;
        Payment_Mode__c pMode = new Payment_Mode__c();
        pMode.Name = 'Net Banking';
        insert pMode;
        
        Payment_Option2__c po = new Payment_Option2__c();
        po.Name = 'Default';
        insert po;
        
        Pricing_Specification__c ps = new Pricing_Specification__c();
        ps.Name = 'Default';
        insert ps;
        
        Payment_Gateway2__c pg = new Payment_Gateway2__c();
        pg.Name = 'Default';
        pg.Type__c = 'PostApproved';
        insert pg;
        
        Master_Pricing_Data__c mpd = new Master_Pricing_Data__c();
        mpd.Payment_Mode__c = pMode.Id;
        mpd.Payment_Option__c = po.Id;
        mpd.Pricing_Specification__c = ps.Id;
        mpd.Payment_Gateway__c = pg.Id;
        mpd.Salesforce_Primary_Key__c = 'Default_PG1001';
        mpd.Donation_0_Flat__c = 50;
        mpd.Donation_0_Percentage__c = 1.5;
        mpd.Donation_2000_Flat__c = 100;
        mpd.Donation_2000_Percentage__c = 1.6;
        mpd.ONUS_OFFUS__c = 'ONUS';
        mpd.Bank__c = 'HDFC Bank';
        mpd.POR_Type__c = 'Cards';
        mpd.Active_Instrument__c = true;
        insert mpd;
        Master_Pricing_Data__c mpd1 = new Master_Pricing_Data__c();
        mpd1.Payment_Mode__c = pMode.Id;
        mpd1.Payment_Option__c = po.Id;
        mpd1.Pricing_Specification__c = ps.Id;
        mpd1.Payment_Gateway__c = pg.Id;
        mpd1.Salesforce_Primary_Key__c = 'PayUPG_3546';
        mpd1.Donation_0_Flat__c = 50;
        mpd1.Donation_0_Percentage__c = 1.5;
        mpd1.Donation_2000_Flat__c = 100;
        mpd1.Donation_2000_Percentage__c = 1.6;
        mpd1.ONUS_OFFUS__c = 'Offus';
        mpd1.Bank__c = 'Axis Bank';
        mpd1.POR_Type__c = 'Cards';
        mpd1.Active_Instrument__c = true;
        insert mpd1;
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Bank_Category__c bc = new Bank_Category__c();
        bc.Name = 'Donation';
        insert bc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Open';
        opp.Bank_Category__c = bc.Id;
        opp.CloseDate = System.today();
        opp.Prod_Merchant_Id__c = 123456;
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
        
        List<Pricing__c> listPricing = new List<Pricing__c>(); 
        Pricing__c price = new Pricing__c();
        price.Commercial2__c = comm.Id;
        price.Below_Rack_Rates__c = true;
        price.Master_Pricing_Data__c = mpd.Id;
        price.Payment_Gateway2__c = pg.Id;
        price.Remarks__c = 'test Remarks';
        price.Rule_Id__c = '7119698';
        price.Opportunity__c = opp.Id;
        price.Deleted__c = false;
        price.Transaction_Type__c='TDR';
        listPricing.add(price);
        
        Pricing__c price1 = new Pricing__c();
        price1.Commercial2__c = comm.Id;
        price1.Below_Rack_Rates__c = true;
        price1.Master_Pricing_Data__c = mpd.Id;
        price1.Payment_Gateway2__c = pg.Id;
        price1.Remarks__c = 'test 1';
        price1.Banking_Ops_Status__c = 'Approved';
        price1.Rule_Id_Conv__c = '7119698';
        price1.Deleted__c = false;
        price1.Transaction_Type__c='Convenience';
        price1.Opportunity__c = opp.Id;
        price1.Deleted__c = true;
        listPricing.add(price1); 
        
        Pricing__c price3 = new Pricing__c();
        price3.Commercial2__c = comm1.Id;
        price3.Below_Rack_Rates__c = true;
        price3.Remarks__c = 'test';
        price3.deleted__c = false;
        price3.Banking_Ops_Status__c = 'Pending with Banking ops';
        price3.Master_Pricing_Data__c = mpd.Id;
        price3.Payment_Gateway2__c = pg.Id;
        price3.Rule_Id__c = '7119698';
        price3.Opportunity__c = opp.Id;
        price3.Transaction_Type__c='TDR + Convenience';
        listPricing.add(price3);
        insert listPricing;
        listPricing[2].Deleted__c = true;
        listPricing[2].Banking_Ops_Status__c ='Approved';
        update listPricing;
        
        
    }
    @isTest
    public static void testMethod1() {
        Test.startTest();
        List<Pricing__c> pricingList = [Select Id,Commercial2__c,Remarks__c,Opportunity__c,Master_Pricing_SF_Key__c,deleted__c,
                                        Master_Pricing_Data__c,Transaction_Type__c FROM Pricing__c WHERE Transaction_Type__c ='TDR + Convenience' LIMIT 1];      
        PricingTriggerHandler.afterInsertHandler(pricingList);
        Test.stopTest();
    }
    @isTest
    public static void testMethod2() {
        Test.startTest();
        List<Pricing__c> pricingList = [Select Id,Commercial2__c,Remarks__c,Fee_Model__c,TDR_Amount__c,TDR__c,TDR_Flat_Fee__c,
                                        Convenience_Amount__c,Convenience__c,Convenience_Flat_Fee__c,Opportunity__c,
                                        Master_Pricing_SF_Key__c,deleted__c,Master_Pricing_Data__c,Transaction_Type__c
                                        FROM Pricing__c 
                                        WHERE Transaction_Type__c ='TDR' LIMIT 1];
        pricingList[0].Deleted__c = true;
        pricingList[0].Fee_Model__c = 'Gross';
        pricingList[0].Banking_Ops_Status__c ='Approved';
        update pricingList;
        Map<Id,Pricing__c> triggerOldMap = new Map<Id,Pricing__c>();
        triggerOldMap.put(pricingList[0].Id,pricingList[0]);    
        PricingTriggerHandler.afterUpdate(pricingList,triggerOldMap);
        Test.stopTest();
    }
    @isTest
    public static void testMethod3() {
        Test.startTest();
        List<Pricing__c> pricingList = [Select Id,Remarks__c,Commercial2__c,Fee_Model__c,TDR_Amount__c,TDR__c,TDR_Flat_Fee__c,
                                        Convenience_Amount__c,Convenience__c,Convenience_Flat_Fee__c,Opportunity__c,
                                        Master_Pricing_SF_Key__c,deleted__c,Master_Pricing_Data__c,Transaction_Type__c
                                        FROM Pricing__c 
                                        WHERE Transaction_Type__c ='Convenience' LIMIT 1];
        pricingList[0].Deleted__c = true;
        pricingList[0].Fee_Model__c = 'Gross';
        pricingList[0].Banking_Ops_Status__c ='Approved';
        update pricingList;
        Map<Id,Pricing__c> triggerOldMap = new Map<Id,Pricing__c>();
        triggerOldMap.put(pricingList[0].Id,pricingList[0]);        
        PricingTriggerHandler.afterUpdate(pricingList,triggerOldMap);
        Test.stopTest();
    }
    @isTest
    public static void testMethod4() {
        Test.startTest();
        List<Pricing__c> pricingList = [Select Id,Remarks__c,Commercial2__c,Fee_Model__c,TDR_Amount__c,TDR__c,TDR_Flat_Fee__c,
                                        Convenience_Amount__c,Convenience__c,Convenience_Flat_Fee__c,Opportunity__c,
                                        Master_Pricing_SF_Key__c,deleted__c,Master_Pricing_Data__c,Transaction_Type__c
                                        FROM Pricing__c 
                                        WHERE Transaction_Type__c ='TDR + Convenience' LIMIT 1];
        pricingList[0].Deleted__c = true;
        pricingList[0].Fee_Model__c = 'Gross';
        pricingList[0].Banking_Ops_Status__c ='Approved';
        update pricingList;
        Map<Id,Pricing__c> triggerOldMap = new Map<Id,Pricing__c>();
        triggerOldMap.put(pricingList[0].Id,pricingList[0]);      
        PricingTriggerHandler.afterUpdate(pricingList,triggerOldMap);
        Test.stopTest();
    }
    @isTest
    public static void testMethod5() {
        Test.startTest();
        List<Pricing__c> listPricing = [SELECT Id,Fee_Model__c,Convenience_Flat_Fee__c,Convenience__c,Convenience_Amount__c,TDR__c,TDR_Amount__c,TDR_Flat_Fee__c,Transaction_Type__c,ONUS__c,Bank__c,POR_File_Name__c,POR_Type__c,Payment_Mode__c,Pricing_Specification__c,Invisible__c,Payment_Gateway2__c,Payment_Option2__c,Master_Pricing_Data__c,Opportunity__c,Master_Pricing_SF_Key__c,Commercial2__c,Below_Rack_Rates__c,Banking_Ops_Status__c,
                                        Rule_Id_Conv__c,Rule_Id__c FROM Pricing__c WHERE Transaction_Type__c='Convenience' LIMIT 1];
        PricingTriggerHandler.afterInsertHandler(listPricing);
        Test.stopTest();
    }
    @isTest
    public static void testMethod6() {
        Test.startTest();
        List<Pricing__c> listPricing = [SELECT Id,Fee_Model__c,Convenience_Flat_Fee__c,Convenience__c,Convenience_Amount__c,TDR__c,TDR_Amount__c,TDR_Flat_Fee__c,Transaction_Type__c,ONUS__c,Bank__c,POR_File_Name__c,POR_Type__c,Payment_Mode__c,Pricing_Specification__c,Invisible__c,Payment_Gateway2__c,Payment_Option2__c,Master_Pricing_Data__c,Opportunity__c,Master_Pricing_SF_Key__c,Commercial2__c,Below_Rack_Rates__c,Banking_Ops_Status__c,
                                        Rule_Id_Conv__c,Rule_Id__c FROM Pricing__c WHERE Transaction_Type__c='TDR + Convenience' LIMIT 1];
        PricingTriggerHandler.afterInsertHandler(listPricing);
        Test.stopTest();
    }
}