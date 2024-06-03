@isTest
private class BlacklistMerchantAttributeTriggerTracker {
    @isTest
    private static void testTethod1(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Blacklist_Merchant_Attribute__c', true);
        insert triggerSwitchObj ;
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
        accountObj.Monthly_Expected_Sale__c = 200;
        accountObj.Delivery_Duration__c = 2;
        insert accountObj;
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.Website__c = 'https://payuindia.atlassian.net';
        opportunityObj.Risk_Type_Multi_Select__c = 'Pan Number';
        opportunityObj.Mobile__c = '9809809809';
        opportunityObj.Email__c = 'test@gmail.com';
        insert opportunityObj;
        
        Bank_Account_Detail__c bank = new Bank_Account_Detail__c();
        bank.Opportunity__c = opportunityObj.id;
        bank.Account_Number_IFSC_Code__c = '1914357990~CBIN0280993';
        insert bank;
        System.debug('bank>>'+bank);
        List<Blacklist_Merchant_Attribute__c> blacklist_List = new List<Blacklist_Merchant_Attribute__c>();
        Blacklist_Merchant_Attribute__c blacklist = new Blacklist_Merchant_Attribute__c();
        blacklist.Name__c = '9809809809';
        blacklist.Blacklist_Type__c = 'Phone Number'; 
        blacklist.Is_Migrated__c = true;
        insert blacklist;
        blacklist_List.add(blacklist);
        Blacklist_Merchant_Attribute__c blacklist2 = new Blacklist_Merchant_Attribute__c();
        blacklist2.Name__c = 'https://payuindia.atlassian.net';
        blacklist2.Blacklist_Type__c = 'Website URL';  
        blacklist2.Is_Migrated__c = true;
        insert blacklist2;
        blacklist_List.add(blacklist2);
        Blacklist_Merchant_Attribute__c blacklist3 = new Blacklist_Merchant_Attribute__c();
        blacklist3.Name__c = '1914357990~CBIN0280993';
        blacklist3.Blacklist_Type__c = 'Bank Detail';  
        blacklist3.Is_Migrated__c = true;
        insert blacklist3;
        blacklist_List.add(blacklist3);
        
    }
    
}