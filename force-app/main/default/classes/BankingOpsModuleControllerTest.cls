@isTest
public class BankingOpsModuleControllerTest {
    @testSetup static void BankingOpsModule(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            FirstName = 'HDFC',
            LastName = 'Bank',
            Email = 'rohit.gupta@payu.in',
            Username = 'rohit.gupta@payu.in.onepayudev' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            MobilePhone  = '7877002681',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        Group gp = new Group();
        gp.Type = 'Queue';
        gp.Name = 'Banking_Ops_Team';
        insert gp;
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Monthly_Expected_Sale__c = 200;
        accountObj.Delivery_Duration__c = 2;
        insert accountObj;
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.Manual_Call_Response__c = 'CallStartTime:01-03-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:323';
        opportunityObj.C2C_Call_Count__c=2;
        opportunityObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
        opportunityObj.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj.Blacklist__c = true;
        opportunityObj.Agent_Details__c='Rohit test - 7877002681';
        insert opportunityObj;
            
        Payment_Gateway2__c paymentGate = new Payment_Gateway2__c();
        paymentGate.Type__c = 'PostApproved';
        insert paymentGate;
        Master_Pricing_Data__c master = new Master_Pricing_Data__c ();
        master.POR_File_Name__c =  'PayU_HDFC_CCDC_24_06_2022';
        master.POR_Type__c = 'Cards';
        master.Bank__c  = 'HDFC Bank';
        master.Salesforce_Primary_Key__c = 'SF2142';
        Insert master;
        List<Pricing__c> pricingList = new List<Pricing__c>();
        Pricing__c pricing = new Pricing__c();
        pricing.Master_Pricing_Data__c = master.id;
        pricing.Payment_Gateway2__c = paymentGate.Id;
        pricing.Opportunity__c = opportunityObj.Id;
        pricing.Banking_Ops_Status__c    = 'Pending with KAM';
        pricing.Status__c  = 'Pending with KAM';
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Master_Pricing_Data__c = master.id;
        pricing2.Payment_Gateway2__c = paymentGate.Id;
        pricing2.Opportunity__c = opportunityObj.Id;
        pricing2.Banking_Ops_Status__c   ='Pending with Banking ops';
        pricing2.Status__c  = 'Pending with Banking ops';        
        
        Pricing__c pricing3 = new Pricing__c();
        pricing3.Master_Pricing_Data__c = master.id;
        pricing3.Payment_Gateway2__c = paymentGate.Id;
        pricing3.Opportunity__c = opportunityObj.Id;
        pricing3.Banking_Ops_Status__c   ='Pending with Bank';
        pricing3.Status__c  = 'Pending with Bank';
        pricing3.Below_Rack_Rates__c = true;
        pricingList.add(pricing3);
        pricingList.add(pricing2);
        pricingList.add(pricing);
        Insert pricingList;
        
        List<OpportunityFieldHistory> oppHisList = new List<OpportunityFieldHistory>();
        OpportunityFieldHistory oppHis = new OpportunityFieldHistory();
        oppHis.OpportunityId = opportunityObj.Id;
        oppHis.Field = 'Owner';
        oppHisList.add(oppHis);
        Insert oppHisList;
        
        List<Pricing__History> priHisList = new List<Pricing__History>();
        Pricing__History pricingHis = new Pricing__History();
        pricingHis.ParentId = pricingList[0].Id;
        pricingHis.Field = 'Owner';
        priHisList.add(pricingHis);
        Insert priHisList;
        
        Address_Details__c add = new Address_Details__c();
        add.Type__c = 'Operating';
        add.Opportunity__c =opportunityObj.Id;
        Insert add;
        Website_Page__c web = new Website_Page__c();
        web.URL__c = 'www.google.com';
        web.Page_Details__c = 'Test';
        web.Opportunity__c = opportunityObj.Id;
        Insert web;
        Bank_Account_Detail__c back = new Bank_Account_Detail__c();
        back.Account_Number__c = '123456765432';
        back.Opportunity__c = opportunityObj.Id;
        back.Active__c = true;
        Insert back;
    }
    @istest static void testMethodOne(){
        Payment_Gateway2__c pay = [SELECT Type__c FROM Payment_Gateway2__c WHERE Type__c=:'PostApproved'];
        Master_Pricing_Data__c master =[SELECT POR_File_Name__c,POR_Type__c,Bank__c FROM Master_Pricing_Data__c WHERE POR_File_Name__c=:'PayU_HDFC_CCDC_24_06_2022'];
        List<Pricing__c> pricing = [SELECT Id,Banking_Ops_Status__c,Status__c,Opportunity__c FROM Pricing__c WHERE Banking_Ops_Status__c=:'Pending with KAM'];
        List<Pricing__c> pricing2 = [SELECT Id,Banking_Ops_Status__c,Status__c,Opportunity__c FROM Pricing__c WHERE Banking_Ops_Status__c=:'Pending with Banking ops'];
        List<Pricing__c> pricing3 = [SELECT Id,Banking_Ops_Status__c,Status__c,Opportunity__c FROM Pricing__c WHERE Banking_Ops_Status__c=:'Pending with Bank'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Transaction_Facility_Required__c=:'Domestic'];
        BankingOpsModuleController.GetWrapperOfSObjectFieldColumnActionValues(master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.getBankingPickListValues(pricing[0].Banking_Ops_Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.getBankingPickListValues('New Request',master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.getBankingPickListValues('All Request',master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.chatterStatusChange(pricing[0].Status__c,pricing[0].Id,master.Bank__c,master.POR_Type__c );
        BankingOpsModuleController.chatterStatusChange(pricing2[0].Status__c,pricing2[0].Id,master.Bank__c,master.POR_Type__c );
        BankingOpsModuleController.chatterStatusChange(pricing3[0].Status__c,pricing3[0].Id,master.Bank__c,master.POR_Type__c );
        BankingOpsModuleController.OpportunityDetailsWithPricig(pricing3[0].Id);
        BankingOpsModuleController.OwnerAssignmentLogic(opp.Id,pricing[0].Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.OwnerAssignmentLogic(opp.Id,pricing2[0].Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.OwnerAssignmentLogic(opp.Id,pricing3[0].Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.OwnerAssignmentLogic(opp.Id,pricing3[0].Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.getStatusValueUpdate(pricing3,pricing3[0].Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.getStatusValueUpdate(pricing2,pricing2[0].Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.getStatusValueUpdate(pricing,pricing[0].Status__c,master.Bank__c,master.POR_Type__c);
        BankingOpsModuleController.getProfileName();
        BankingOpsModuleController.getBankAndPorType();
        BankingOpsModuleController.searchBank('AXIS Bank-Cards');
    }       
}