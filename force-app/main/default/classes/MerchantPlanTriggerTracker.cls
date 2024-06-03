@isTest
public class MerchantPlanTriggerTracker {
    
    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Merchant_Plan__c', true);
        insert triggerSwitchObj ;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Entity__c entityObj1 = CommonDataTracker.insertEntity('Individual');
        insert entityObj1;
        System.assertEquals('Individual', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj1.id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        //CommonDataTracker.insertCase(accountObj, contactObj, 'New'); 
        Case caseobj = CommonDataTracker.CreateCase(accountObj, contactObj, 'New');
        insert caseobj;
        System.assertEquals('New', [SELECT id, Status FROM Case WHERE Id =: caseobj.id].Status);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj1.Identifier__c = '10e9-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        insert opportunityObj1;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj1.id].AccountId);
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategoryOthers.Doable__c = True;
        insert businessCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryOthers.id].Name);
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Business_Category__c businessCategoryInd = CommonDataTracker.insertBusinessCategory('Individual', true);
        businessCategoryInd.Categories_For__c = 'Partner';
        insert businessCategoryInd;
        System.assertEquals('Individual', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryInd.id].Name);
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        insert subCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryInd = CommonDataTracker.insertSubCategory('Individual', false);
        subCategoryInd.Category__c = businessCategoryInd.Id;
        insert subCategoryInd ;
        System.assertEquals('Individual', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryInd.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        subCategoryBooks.Delivery_duration__c = 5;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
        Sub_Category__c subCategoryNGO = CommonDataTracker.insertSubCategory('NGO', true);
        subCategoryNGO.Category__c = businessCategoryNGO.Id;
        insert subCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryNGO.id].Name);
        
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
        leadObj.Identifier__c = '11e4-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Lead leadObj1 = CommonDataTracker.insertLead(prodObj, businessCategoryInd, subCategoryInd, entityObj);            
        leadObj1.Lead_Type__c = 'Partner';
        leadObj1.Identifier__c = '11e5-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        insert leadObj1;
        
        Bank_Account_Detail__c bankAccObj1 = CommonDataTracker.insertBankAccDetails(leadObj1.Id, null);
        insert bankAccObj1; 
        System.assertEquals(leadObj1.Id, [SELECT id, Lead__c FROM Bank_Account_Detail__c WHERE id =: bankAccObj1.Id].Lead__c);
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.Id, null, 'Registered');
        insert  addDetailsRegObj;
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Lead__c);
        
    }
    
    @isTest static void testMethodOne() {
        
        Business_Category__c businessCategoryNGO = [SELECT id, name FROM Business_Category__c WHERE name =: 'NGO'];
        
        Sub_Category__c subCategoryBooks = [SELECT id, name FROM Sub_Category__c WHERE name =: 'Books'];
        
        Business_Category__c businessCategoryOthers = [SELECT id, name FROM Business_Category__c WHERE name =: 'Others'];
        
        Sub_Category__c subCategoryOthers = [SELECT id, name FROM Sub_Category__c WHERE name =: 'Others'];
        
        Lead leadObj = [SELECT id, BusinessCategory__c, Business_Category_Other__c, Sub_Category__c, 
                        Sub_Category_Other__c  FROM Lead LIMIT 1 ];
        
        Bank_Account_Detail__c bad = [Select Id,Active__c,Verification_Status__c,Lead__c from Bank_Account_Detail__c LIMIT 1];
        bad.Verification_Status__c = 'Success';
        bad.Active__c = true;
        bad.Lead__c = leadObj.Id;
        update bad;
        
        Entity__c ent = [Select Id from Entity__c where Name=:'Individual' LIMIT 1];
        
        List<Address_Details__c> addDetailsRegObj = [Select Id from Address_Details__c];
        addDetailsRegObj[0].Lead__c = leadObj.Id;
        update addDetailsRegObj;
        
        test.startTest();
        Merchant_Plan__c Plan = new Merchant_Plan__c();
        Plan.Name = 'business_plus';
        Plan.Status__c = 'payment_failed';
        Plan.Price__c = 950;
        Plan.Lead__c = leadObj.id;
        insert Plan;
        
        Plan.Status__c = 'plan_selected';
        Plan.Purchase_Date__c = system.now();
        update Plan;
        
        Plan.Status__c = 'payment_failed';
        Plan.Purchase_Date__c = system.now();
        update Plan;
        
        Plan.Status__c = 'payment_completed';
        Plan.Purchase_Date__c = system.now();
        update Plan;
        
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo() {
        
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        Opportunity opp = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        opp.iOS_URL__c = 'a.b.com';
        opp.MAF_Status__c = 'Received';
        opp.Bank_Verification_Status__c = 'Success'; 
        opp.Product__c = prodObj.Id;
        opp.Agent_Details__c='Shivani Mishra - 7877002681';
        opp.BusinessCategory__c = businessCategory.id;
        opp.Transaction_Facility_Required__c = 'Domestic';
        opp.Manual_Call_Response__c = 'CallStartTime:05-03-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:90';
        opp.Delivery_Duration__c = 90;
        opp.NEFT_Hold_Status__c = 'Hold';
        update opp; 
        
        Merchant_Plan__c Plan = new Merchant_Plan__c();
        Plan.Name = 'business_plus';
        Plan.Status__c = 'payment_completed';
        Plan.Price__c = 950;
        Plan.Opportunity__c = opp.id;
        insert Plan;
        
        Plan.Status__c = 'payment_failed';
        Plan.Purchase_Date__c = system.now();
        update Plan;
        
        Test.stopTest();
    }
}