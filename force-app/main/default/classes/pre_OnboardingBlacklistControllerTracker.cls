@isTest
public class pre_OnboardingBlacklistControllerTracker {

    @testSetup static void setupCommonData(){
        
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        //accountObj.Risk_Type_Multi_Select__c = 'Phone Number';
        accountObj.Phone = '9999900000';
        //accountObj.Email__c = 'test@gmail.com';
        accountObj.Merchant_Trading_Name__c = 'Test';
        accountObj.Legal_Name__c = 'test';
        accountObj.PAN_Number__c = 'GKMSF4212W';
        
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);  
        
        /*Bank_Account_Detail__c bankDeatilObj  = CommonDataTracker.insertBankDetail('20472628463~ICICI0190H2');
        bankDeatilObj.IFSC_Code__c = '20472628463~ICICI0190H2';
        insert bankDeatilObj;*/
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.display_Name__c = 'Admin Blacklist';
        opportunityObj.Website__c = 'google.com';
        opportunityObj.Integration_Type__c = 'ThirdParty';
        opportunityObj.Mobile__c = '8880787898';
        opportunityObj.Email__c = 'test123@yopmail.com';
        insert opportunityObj;
        
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj1.display_Name__c = 'Admin Blacklist';
        opportunityObj1.Website__c = 'google.com';
        opportunityObj1.Integration_Type__c = 'Tools';
        opportunityObj1.Mobile__c = '8880787898';
        opportunityObj1.Email__c = 'test123@yopmail.com';
        insert opportunityObj1;
        
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj1.id].AccountId);
        
        Test.stopTest();  
    }
    
    @isTest static void testMethodOne() {
        Blacklist_Merchant_Attribute__c blacklist = new Blacklist_Merchant_Attribute__c();
        blacklist.Name__c = '20472628463~ICICI0190H2';
        blacklist.Blacklist_Type__c = 'Bank Detail';
        blacklist.Active__c = true;
        insert blacklist;
        
        Blacklist_Merchant_Attribute__c blacklist1 = new Blacklist_Merchant_Attribute__c();
        blacklist1.Name__c = 'Admin Blacklist';
        blacklist1.Blacklist_Type__c = 'Display Name';
        blacklist1.Active__c = true;
        insert blacklist1;
            
        Blacklist_Merchant_Attribute__c blacklist2 = new Blacklist_Merchant_Attribute__c();
        blacklist2.Name__c = 'google.com';
        blacklist2.Blacklist_Type__c = 'Website URL';
        blacklist2.Active__c = true;
        insert blacklist2;
        
        
        Opportunity opportunityObj1 = [Select Id, AccountId, Blacklist__c,Email__c, Blacklist_Comment__c,Mobile__c, Risk_Type_Multi_Select__c,Risk_Comment__c , Unblocked_by__c, 
               Website__c, Android_URL__c, iOS_URL__c, Was_Blacklisted__c,Settlement_Status__c,Display_name__c,Integration_Type__c FROM Opportunity WHERE Integration_Type__c IN ('Tools')  LIMIT 1];
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunityObj1);
        Map<Id,Bank_Account_Detail__c> oppIdVsBankDetail = new Map<Id,Bank_Account_Detail__c>();
        Map<Id,Opportunity> idVsOppMap = new Map<Id,Opportunity>();
        idVsOppMap.put(opportunityObj1.Id, opportunityObj1);
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.Account_Number_IFSC_Code__c = '20472628463~ICICI0190H2';
        //bankDeatilObj.lead__c = ld.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Verification_Status__c ='Pending';
        bankDeatilObj.Penny_Deposit_Status__c = 'Failed ';
        insert bankDeatilObj;
        oppIdVsBankDetail.put(opportunityObj1.Id,bankDeatilObj);
        List<String> strList = new List<String>();
        strList.add('Website URL');
        strList.add('Bank Detail');
        strList.add('Email ID');
        strList.add('Lead Business Name');
        strList.add('Lead Legal Name');
        strList.add('Phone Number');
        strList.add('Display Name');
        strList.add('PAN Number');
        strList.add('None');
        String riskTypeToRemove = '["Display Name",Website URL","PAN Number","Address(Operating)","Address(Registered)","Bank Detail","Email ID","Lead Business Name","Lead Legal Name","Phone Number"]';
        test.startTest();
        pre_OnboardingBlacklistController.getBlacklistDetails(opportunityObj1.Id);
        pre_OnboardingBlacklistController.unblockMerchant(opportunityObj1.Id, 'blacklistComment',riskTypeToRemove,strList);
        Account accountObj = [SELECT Id, Identifier__c,Legal_Name__c, Merchant_Trading_Name__c,Phone FROM Account LIMIT 1];
        pre_OnboardingBlacklistController.saveWrapperDetail(opportunityObj1,true,strList);
        pre_OnboardingBlacklistController.checkBlacklistForNewOpportunity(oppList,null);
        pre_OnboardingBlacklistController.checkBankAccountDetails(oppIdVsBankDetail);
        pre_OnboardingBlacklistController.checkBlacklistForNewOpportunity(oppList,idVsOppMap);
        test.stopTest();
        //system.assertEquals(false, opportunityObj.Blacklist__c);
    }
    
    @isTest static void testMethodTwo() {
        Blacklist_Merchant_Attribute__c blacklist = new Blacklist_Merchant_Attribute__c();
        blacklist.Name__c = '20472628463~ICICI0190H2';
        blacklist.Blacklist_Type__c = 'Bank Detail';
        blacklist.Active__c = true;
        insert blacklist;
            
        Blacklist_Merchant_Attribute__c blacklist1 = new Blacklist_Merchant_Attribute__c();
        blacklist1.Name__c = 'Admin Blacklist';
        blacklist1.Blacklist_Type__c = 'Display Name';
        blacklist1.Active__c = true;
        insert blacklist1;
            
        Blacklist_Merchant_Attribute__c blacklist2 = new Blacklist_Merchant_Attribute__c();
        blacklist2.Name__c = 'google.com';
        blacklist2.Blacklist_Type__c = 'Website URL';
        blacklist2.Active__c = true;
        insert blacklist2;
        
        Blacklist_Merchant_Attribute__c blacklist3 = new Blacklist_Merchant_Attribute__c();
        blacklist2.Name__c = 'EYNPS4665C';
        blacklist2.Blacklist_Type__c = 'PAN Number';
        blacklist2.Active__c = true;
        insert blacklist3;
        
        Opportunity opportunityObj = [Select Id, AccountId, Blacklist__c,Email__c, Blacklist_Comment__c,Mobile__c, Risk_Type_Multi_Select__c,Risk_Comment__c , Unblocked_by__c, 
               Website__c, Android_URL__c, iOS_URL__c, Was_Blacklisted__c,Settlement_Status__c,Display_name__c,Integration_Type__c FROM Opportunity LIMIT 1];
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunityObj);
        Map<Id,Bank_Account_Detail__c> oppIdVsBankDetail = new Map<Id,Bank_Account_Detail__c>();
        Map<Id,Opportunity> idVsOppMap = new Map<Id,Opportunity>();
        idVsOppMap.put(opportunityObj.Id, opportunityObj);
        
        
        Bank_Account_Detail__c bankDeatilObj = new Bank_Account_Detail__c();
        bankDeatilObj.Account_Number__c = '20472628463';
        bankDeatilObj.Account_Type__c = 'Saving';
        bankDeatilObj.IFSC_Code__c = 'ICICI0190H2';
        bankDeatilObj.Account_Holder_Name__c = 'Saasfocus';
        bankDeatilObj.Account_Number_IFSC_Code__c = '20472628463~ICICI0190H2';
        //bankDeatilObj.Display_Name__c = 'Test';
        //bankDeatilObj.lead__c = ld.Id;
        bankDeatilObj.Active__c = true;
        bankDeatilObj.Preforma_Processed__c = true;
        bankDeatilObj.Verification_Status__c ='Pending';
        bankDeatilObj.Penny_Deposit_Status__c = 'Failed ';
        insert bankDeatilObj;
        oppIdVsBankDetail.put(opportunityObj.Id,bankDeatilObj);
        List<String> strList = new List<String>();
        strList.add('Website URL');
        strList.add('Bank Detail');
        strList.add('Email ID');
        strList.add('Lead Business Name');
        strList.add('Lead Legal Name');
        strList.add('Phone Number');
        strList.add('Display Name');
        strList.add('PAN Number');
        strList.add('None');
        
        /*Opportunity opObj = new Opportunity();
        opObj.Email__c = 'test@yopmail.com';
        opObj.Integration_Type__c = 'Tools';//[Name, StageName, CloseDate]
        opObj.Name = 'Test MID';
        opObj.StageName = 'MAF';
        opObj.CloseDate = '06-05-2020 17:08 PM';
        insert opObj;*/
        
        String riskTypeToRemove = '["Display Name",Website URL","PAN Number","Address(Operating)","Address(Registered)","Bank Detail","Email ID","Lead Business Name","Lead Legal Name","Phone Number"]';
        test.startTest();
        pre_OnboardingBlacklistController.getBlacklistDetails(opportunityObj.Id);
        pre_OnboardingBlacklistController.unblockMerchant(opportunityObj.Id, 'blacklistComment',riskTypeToRemove,strList);
        Account accountObj = [SELECT Id, Identifier__c,Legal_Name__c, Merchant_Trading_Name__c,Phone,PAN_Number__c FROM Account LIMIT 1];
        pre_OnboardingBlacklistController.saveWrapperDetail(opportunityObj,true,strList);
        pre_OnboardingBlacklistController.checkBlacklistForNewOpportunity(oppList,null);
        pre_OnboardingBlacklistController.checkBankAccountDetails(oppIdVsBankDetail);
        pre_OnboardingBlacklistController.checkBlacklistForNewOpportunity(oppList,idVsOppMap);
        test.stopTest();
        //system.assertEquals(false, opportunityObj.Blacklist__c);
    }
   
    
}