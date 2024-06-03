@isTest
private class OfflineOnboardingForm_ControllerTracker {
    @isTest
    private static void testData1(){
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'eGQPS7145A');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('eGQPS7145A', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);
        
        Contact contactObj1 = CommonDataTracker.insertContact(accountObj);
        contactObj1.Email = 'test@payu.in';
        insert contactObj1;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj1.id].AccountId);
        
        Contact contactObj2 = CommonDataTracker.insertContact(accountObj);
        contactObj2.Email = 'test1@payu.in';
        insert contactObj2;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj2.id].AccountId);
        
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.recordTypeId = recordTypeId;
        opportunityObj.LeadSource = 'Partner';
        opportunityObj.Lead_Type__c = 'Partner';
        opportunityObj.Active__c = true;
        //opportunityObj.Prod_Merchant_Id__c = 12345;
        opportunityObj.Sub_Source__c = 'BankingPartner';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj;
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        businessCategoryNGO.Active__c = true;
        insert businessCategoryNGO ;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Books', true);
        subCategory.Category__c = businessCategoryNGO.Id;
        subCategory.Delivery_duration__c = 5;
        subCategory.Active__c = true;
        insert subCategory;
        
        
        
        Id offlineOnboardingrecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Offline Onboarding').getRecordTypeId();
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategory, entityObj);
        leadObj.RecordTypeId = offlineOnboardingrecordTypeId;
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(leadObj.Id, null);
        insert bankAccObj; 
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Bank_Account_Detail__c WHERE id =: bankAccObj.Id].Lead__c);
        
        List<Address_Details__c> address_List = new List<Address_Details__c>();
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Registered');
        insert  addDetailsRegObj;
        address_List.add(addDetailsRegObj);
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Lead__c);
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Operating');
        insert  addDetailsOpeObj;
        address_List.add(addDetailsOpeObj);
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsOpeObj.Id].Lead__c);
        Test.startTest();
        OfflineOnboardingForm_Controller.getMerchantRecordData(leadObj.Id);
        OfflineOnboardingForm_Controller.fetchPanNumber('eGQPS7145A', 'PanNumber');
        OfflineOnboardingForm_Controller.fetchPanNumber('LegalName86823', 'LegalName');
        OfflineOnboardingForm_Controller.saveLeadData(JSON.serialize(leadObj));
        OfflineOnboardingForm_Controller.fetchBusinessEntity();
        OfflineOnboardingForm_Controller.fetchProduct();
        OfflineOnboardingForm_Controller.fetchBusinessCategory();
        OfflineOnboardingForm_Controller.fetchSubCategory();
        OfflineOnboardingForm_Controller.generateIdentifier();
        OfflineOnboardingForm_Controller.fetchPartner('BankingPartner');
        OfflineOnboardingForm_Controller.saveContactDetailsData(JSON.serialize(contactObj1),JSON.serialize(contactObj2));
        OfflineOnboardingForm_Controller.saveAddressData(JSON.serialize(address_List));
        OfflineOnboardingForm_Controller.saveBankDetailsData(JSON.serialize(bankAccObj));
        OfflineOnboardingForm_Controller.fetchPicklistValue(leadObj,'Sub_Status__c');
        Test.stopTest();
    }

    
}