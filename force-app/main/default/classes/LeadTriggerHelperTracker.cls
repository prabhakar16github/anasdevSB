@isTest
public class LeadTriggerHelperTracker {

    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Lead', true);
        insert triggerSwitchObj;
        
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryOthers.id].Name);
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        insert subCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        leadObj.Merchant_Id__c = null;
        leadObj.Email = 'uma.shankar+jbshadbash7y281y@gmail.com';
        leadObj.LeadSource = 'Organic';
        leadObj.Sub_Source__c = 'Email';
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(leadObj.Id, null);
        insert bankAccObj; 
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Bank_Account_Detail__c WHERE id =: bankAccObj.Id].Lead__c);
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Registered');
        insert  addDetailsRegObj;
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Lead__c);
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Operating');
        insert  addDetailsOpeObj;
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsOpeObj.Id].Lead__c);
        
        Contact contactLeadObj = CommonDataTracker.InsertContact(accountObj);
        contactLeadObj.Email = 'uma.shankar+fd5@saasfocus.com';
        contactLeadObj.Lead__c = leadObj.Id;
        contactLeadObj.AccountId = null;
        insert contactLeadObj;
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Contact WHERE Id =: contactLeadObj.id].Lead__c);
        
    }
    
    @isTest static void testMethodOne() {
        
        Lead leadObj = [SELECT id, ProductLabel__c, Merchant_Id__c, IntegrationInfo__c, Name, FirstName, LastName, Email, MobilePhone__c, Identifier__c, 
                        Business_Entity_Identifier__c, Business_Category_Identifier__c, Sub_Category_Identifier__c, Website__c, Merchant_Trading_Name__c, Device__c, 
                        Merchant_Business_Type__c, PAN_Holder_Name__c, PAN_Number__c, Android_URL__c, iOS_URL__c, GST_Number__c, Integration_Type__c, Delivery_Duration__c, 
                        Monthly_Expected_Sale__c, SAP_Id__c, Active__c, Campaign_Name__c, Campaign_Medium__c, Campaign_Source__c, Campaign_Term__c, Partner_UUID__c, LeadSource, Sub_Source__c 
                        FROM Lead LIMIT 1 ];
        system.debug('>>>>>>>>> '+leadObj);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());        
        LeadTriggerHelper.fetchMIdwithButton(leadObj.Id, 'Lead', null);
        LeadTriggerHelper.fetchMIdwithTrigger(leadObj.Id, 'Lead', null);
        Test.stopTest();        
    }
}