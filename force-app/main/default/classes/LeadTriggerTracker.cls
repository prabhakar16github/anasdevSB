@isTest
public class LeadTriggerTracker{ 
    
    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Lead', true);
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
        
        List<Opportunity> opportunityObjectList = new List<Opportunity>();
        List<Business_Category__c> bussinessCatObjectList = new List<Business_Category__c>();
        List<Sub_Category__c> subCatObjectList = new List<Sub_Category__c>();
        List<Lead> leadObjectList = new List<Lead>();
        List<Bank_Account_Detail__c> bankDetailObjectList = new List<Bank_Account_Detail__c>();
        List<Address_Details__c> addressDetailObjectList = new List<Address_Details__c>();
        
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);       
        opportunityObjectList.add(opportunityObj);
        
        //insert opportunityObj;
        //System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj1.Identifier__c = '10e9-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        opportunityObjectList.add(opportunityObj1);
        
        //insert opportunityObj1;
        //System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj1.id].AccountId);
        
        insert opportunityObjectList;
        
        
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategoryOthers.Doable__c = True;
        bussinessCatObjectList.add(businessCategoryOthers);
        //insert businessCategoryOthers ;
        //System.assertEquals('Others', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryOthers.id].Name);
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        bussinessCatObjectList.add(businessCategoryNGO);
        //insert businessCategoryNGO ;
        //System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Business_Category__c businessCategoryInd = CommonDataTracker.insertBusinessCategory('Individual', true);
        businessCategoryInd.Categories_For__c = 'Partner';
        bussinessCatObjectList.add(businessCategoryInd);
        //insert businessCategoryInd;
        //System.assertEquals('Individual', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryInd.id].Name);
        
        insert bussinessCatObjectList;
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        subCatObjectList.add(subCategoryOthers);
        //insert subCategoryOthers ;
        //System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryInd = CommonDataTracker.insertSubCategory('Individual', false);
        subCategoryInd.Category__c = businessCategoryInd.Id;
        subCatObjectList.add(subCategoryInd);
        //insert subCategoryInd ;
        //System.assertEquals('Individual', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryInd.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        subCategoryBooks.Delivery_duration__c = 5;
        subCatObjectList.add(subCategoryBooks);
        //insert subCategoryBooks ;
        //System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
        Sub_Category__c subCategoryNGO = CommonDataTracker.insertSubCategory('NGO', true);
        subCategoryNGO.Category__c = businessCategoryNGO.Id;
        subCatObjectList.add(subCategoryNGO);
        //insert subCategoryNGO ;
        //System.assertEquals('NGO', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryNGO.id].Name);
        
        insert subCatObjectList;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);   
        leadObj.Identifier__c = '11e4-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        leadObj.Missed_Call_Time__c = '06-05-2020 17:08 PM';
        leadObjectList.add(leadObj);
        //insert leadObj;
        //System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Lead leadObj1 = CommonDataTracker.insertLead(prodObj, businessCategoryInd, subCategoryInd, entityObj);            
        leadObj1.Lead_Type__c = 'Partner';
        leadObj1.Identifier__c = '11e5-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        leadObjectList.add(leadObj1);
        //insert leadObj1;
        
        Lead alliancePartner = CommonDataTracker.insertLead(prodObj, businessCategoryInd, subCategoryInd, entityObj);            
        alliancePartner.Lead_Type__c = 'Partner';
        alliancePartner.Identifier__c = '1111-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        alliancePartner.Queue_Name__c = 'Partnerships_Alliances';
        leadObjectList.add(alliancePartner);
        //insert alliancePartner;
        
        Lead leadObj2 = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        leadObj2.Merchant_Type__c = 'Seller';
        leadObjectList.add(leadObj2);
        //insert leadObj2;
        //System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj2.Id].Product__c);
        
        Lead leadObj3 = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);   
        leadObj3.Android_URL__c = 'androidurltest.com';
        leadObj3.partner__c = opportunityObj1.id;
        leadObj3.Identifier__c = '10e6-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        leadObjectList.add(leadObj3);
        //insert leadObj3;
        insert leadObjectList;
        
        Bank_Account_Detail__c bankAccObj = CommonDataTracker.insertBankAccDetails(leadObj.Id, null);
        bankDetailObjectList.add(bankAccObj);
        //insert bankAccObj; 
        //System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Bank_Account_Detail__c WHERE id =: bankAccObj.Id].Lead__c);
        
        Bank_Account_Detail__c bankAccObj1 = CommonDataTracker.insertBankAccDetails(leadObj1.Id, null);
        bankDetailObjectList.add(bankAccObj1);
        //insert bankAccObj1; 
        //System.assertEquals(leadObj1.Id, [SELECT id, Lead__c FROM Bank_Account_Detail__c WHERE id =: bankAccObj1.Id].Lead__c);
        insert bankDetailObjectList;
        
        Address_Details__c addDetailsRegObj = CommonDataTracker.insertAddressDetails(leadObj.Id,null, null, 'Registered');
        addressDetailObjectList.add(addDetailsRegObj);
        //insert  addDetailsRegObj;
        //System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsRegObj.Id].Lead__c);
        
        Address_Details__c addDetailsRegObj1 = CommonDataTracker.insertAddressDetails(leadObj1.Id,null, null, 'Registered');
        addressDetailObjectList.add(addDetailsRegObj1);
        //insert  addDetailsRegObj1;  
        //System.assertEquals(leadObj1.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsRegObj1.Id].Lead__c);
        
        Address_Details__c addDetailsOpeObj = CommonDataTracker.insertAddressDetails(leadObj.Id,null, null, 'Operating');
        addressDetailObjectList.add(addDetailsOpeObj);
        //insert  addDetailsOpeObj;
        //System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Address_Details__c WHERE id =: addDetailsOpeObj.Id].Lead__c);
        insert addressDetailObjectList;
        
        Contact contactLeadObj = CommonDataTracker.InsertContact(accountObj);
        contactLeadObj.Email = 'uma.shankar+fd5@saasfocus.com';
        contactLeadObj.Lead__c = leadObj.Id;
        contactLeadObj.AccountId = null;
        insert contactLeadObj;
        System.assertEquals(leadObj.Id, [SELECT id, Lead__c FROM Contact WHERE Id =: contactLeadObj.id].Lead__c);
    }    
    
    @isTest static void testMethodOne() {
        
        Test.startTest();
        
        Business_Category__c businessCategoryNGO = [SELECT id, name FROM Business_Category__c WHERE name =: 'NGO'];
        
        Sub_Category__c subCategoryBooks = [SELECT id, name FROM Sub_Category__c WHERE name =: 'Books'];
        
        
        
        Entity__c entityObj = [SELECT id, Name FROM Entity__c LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Client_Name__c clnm= new Client_Name__c ();
        clnm.Name='Axis Bank';
        clnm.Region__c='India';
        clnm.Country__c='India';
        insert clnm;
        
        Product__c prodObj = [SELECT id, name, Platform__c FROM Product__c LIMIT 1];
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        leadObj.MobilePhone = '9986458750';
        leadObj.Email = 'uma.shank+tf67tyghg7hqa@saasfocus.com';
        leadobj.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Wibmo').getRecordTypeId();
        leadobj.Lead_Type__c = 'Wibmo';
        leadobj.Client_Name_New__c = clnm.id;	
        leadobj.Region__c='India';  
        leadObj.Legal_Name__c = 'test classs Queue Ass';
        leadObj.PAN_Number__c = 'GKMSF4212W';
        leadObj.Delivery_Duration__c = 89;
        leadObj.Manual_Call_Response__c = 'CallStartTime:01-03-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:890';
        leadObj.C2C_Call_Count__c=0;
        leadObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
        leadObj.Agent_Details__c = 'Richa Aneja - +919999490451';
        leadObj.Identifier__c = '11e1-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        leadObj.Prod_Merchant_Id__c = 1234;
        insert leadObj;
        
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
        
        Lead ExtleadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        ExtleadObj.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('External Partner Lead').getRecordTypeId();
        ExtleadObj.Prod_Merchant_Id__c = 1234;
        Insert ExtleadObj;
        
        Lead alliancePartner = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        alliancePartner.Queue_Name__c = 'Partnerships_Alliances';
        alliancePartner.Lead_Type__c = 'Partner';
        alliancePartner.Prod_Merchant_Id__c = 1234;
        insert alliancePartner;
        
        Lead existingMerchant = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        existingMerchant.Queue_Name__c = 'Existing_Lead_Assignment';
        existingMerchant.Lead_Type__c = 'Merchant';
        existingMerchant.Prod_Merchant_Id__c = 1234;
        insert existingMerchant;
        
        Lead ld3 = new Lead();
        ld3.LastName = 'Testing Lead Partner';
        ld3.Email = 'test@qwerty.com';
        ld3.Sub_Source__c = 'Chat';
        ld3.Company = 'Test Company';
        ld3.Lead_Type__c = 'Partner';
        ld3.Prod_Merchant_Id__c = 1234;
        insert ld3;
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo() {        
        Business_Category__c businessCategoryOthers = [SELECT id, name FROM Business_Category__c WHERE name =: 'Others'];
        
        Sub_Category__c subCategoryOthers = [SELECT id, name FROM Sub_Category__c WHERE name =: 'Others'];
        
        Product__c prodObj = [SELECT id, name, Platform__c FROM Product__c LIMIT 1];
        
        Partner_Lead_Ownership__mdt  ownerMetadata = [Select id, PartnerId_OwnerId_Map__c FROM Partner_Lead_Ownership__mdt Limit 1];
        
        Entity__c entityObj = [Select Id from Entity__c where Name=:'Individual' LIMIT 1];
        Entity__c entityObjSociety = [Select Id from Entity__c where Name=:'Society' LIMIT 1];
        Lead leadObj = [SELECT id, BusinessCategory__c, Business_Category_Other__c, Sub_Category__c, 
                        Sub_Category_Other__c  FROM Lead LIMIT 1 ];
        
        Bank_Account_Detail__c bad = [Select Id,Active__c,Verification_Status__c,Lead__c from Bank_Account_Detail__c LIMIT 1];
        bad.Verification_Status__c = 'Success';
        bad.Active__c = true;
        bad.Lead__c = leadObj.Id;
        //update bad;
        
        List<Address_Details__c> addDetailsRegObj = [Select Id from Address_Details__c];
        addDetailsRegObj[0].Lead__c = leadObj.Id;
        //update addDetailsRegObj;
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Test.startTest();
        QueuesObject testQueue;
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        GroupMember grpMem1 = new GroupMember();
        System.runAs(new User(Id=userinfo.getUserId())){
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = testGroup.Id;
            Insert grpMem1;
            testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
            insert testQueue;
        }
        
        leadObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
        leadObj.BusinessCategory__c = businessCategoryOthers.id ;
        leadObj.Status = 'Nurturing';
        leadObj.Sub_Status__c = 'Contacted';
        leadObj.Business_Category_Other__c = 'NGO';
        leadObj.Sub_Category__c = subCategoryOthers.id ;
        leadObj.Sub_Category_Other__c = 'Books' ;
        leadObj.Merchant_Type__c = 'seller' ;
        leadObj.Legal_Name__c = 'test classs Queue Ass';
        leadObj.MobilePhone = '9911111750';
        leadObj.Email = 'shiv.Kum+tf67tyg7hqa@payu.in';
        leadObj.Prod_Merchant_Id__c = 12398231;
        leadObj.Sub_Source__c = 'WebsiteSignUp';
        leadObj.Business_Entity__c = entityObj.Id;
        leadObj.Transaction_Facility_Required__c = 'Domestic';
        leadObj.Delivery_Duration__c = 21;
        leadObj.Monthly_Expected_Sale__c = 122;
        leadObj.Bank_Verification_Status__c = 'Success';
        leadObj.Manual_Call_Response__c = 'CallStartTime:05-04-2020 12:06 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765926,Bill_Seconds:100';
        leadObj.Delivery_Duration__c = 90;
        leadObj.lead_type__c = 'seller' ;
        leadObj.OwnerId = testGroup.Id;
        leadObj.Agent_Details__c='Shivani Mishra - 7877002681';
        leadObj.Identifier__c = '10f9-d9f0-6fc7926c-bf11-02aa98a2d2b0';
        update leadObj;
        
        leadObj.lead_type__c = 'Buyer' ;
        update leadObj;
        leadObj.Legal_Name__c='test part1';
        leadObj.Merchant_Trading_Name__c='';
        //update leadObj;
        
        Merchant_Plan__c Plan = new Merchant_Plan__c();
        Plan.Name = 'business_plus';
        Plan.Status__c = 'payment_completed';
        Plan.Price__c = 950;
        plan.Lead__c = leadobj.Id;
        //insert Plan;
        
        Lead ld3 = new Lead();
        ld3.LastName = 'Testing Lead Partner Private Limited';
        ld3.Email = 'test@qwerty.com';
        ld3.Sub_Source__c = 'Chat';
        ld3.Company = 'Test Company';
        ld3.Lead_Type__c = 'Partner';
        ld3.Business_Entity__c = entityObjSociety.Id;
        //insert ld3;
        
            
        Lead convertedLead = [SELECT ConvertedAccountId,ConvertedOpportunityId FROM Lead WHERE Id = :leadObj.Id];
        //System.assertNotEquals(null, convertedLead.ConvertedAccountId, 'Expected lead to be converted.');
        if(!leadObj.IsConverted && convertedLead.ConvertedOpportunityId==null){
            database.leadConvert lc = new database.leadConvert();
            lc.setLeadId(leadObj.id);
            lc.setOwnerId(userinfo.getUserId());
            leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess()); 
        }
        
        Lead existingMerchant = CommonDataTracker.insertLead(prodObj, businessCategoryOthers, subCategoryOthers, entityObj);
        existingMerchant.Queue_Name__c = '';
        existingMerchant.Lead_Type__c = 'Merchant';
        insert existingMerchant;
        
		existingMerchant.Queue_Name__c = 'Existing_Lead_Assignment';
        update existingMerchant; 
        
        Test.stopTest();
    }
    
    @isTest static void testMethodThree() {
        /*List<Contact> listContact = new List<Contact>();
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact'
        );
        
        listContact.add(testContact);*/
        Test.startTest();
        
        //System.assertEquals(1, listContact.size(), 'Contact was not updated successfully');
        
        Business_Category__c businessCategoryNGO = [SELECT id, name FROM Business_Category__c WHERE name =: 'NGO'];
        
        Sub_Category__c subCategoryBooks = [SELECT id, name FROM Sub_Category__c WHERE name =: 'Books'];
        
        Product__c prodObj = [SELECT id, name, Platform__c FROM Product__c LIMIT 1];
        
        Entity__c entityObj = [SELECT id, Name FROM Entity__c LIMIT 1];
        
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        leadObj.MobilePhone = '9986458750';
        leadObj.Email = 'uma.shank1+tf67tyghg7hqa@saasfocus.com';
        leadObj.Delivery_Duration__c = 30;
        leadObj.Manual_Call_Response__c = 'CallStartTime:01-02-2020 12:15 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:31';
        leadObj.C2C_Call_Count__c=3;
        leadObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
        leadObj.Agent_Details__c = 'Richa Aneja - +919999490451'; 
        leadObj.Identifier__c = '11e1-d9f0-6fc7926c-bf11-02la98a2d2b0';
        insert leadObj; 
        
        
        //System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);        
        LeadTriggerHandler.convertLead(leadObj.Id);
        
        Bank_Account_Detail__c bad = [Select Id,Active__c,Verification_Status__c,Lead__c from Bank_Account_Detail__c LIMIT 1];
        bad.Verification_Status__c = 'Success';
        bad.Active__c = true;
        bad.Lead__c = leadObj.Id;
        update bad;
        LeadTriggerHandler.convertLead(leadObj.Id);
        
        
        
        QueuesObject testQueue;
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        GroupMember grpMem1 = new GroupMember();
        System.runAs(new User(Id=userinfo.getUserId())){
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = testGroup.Id;
            Insert grpMem1;
            testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
            insert testQueue;
        }
        
        
        leadObj.OwnerId = testGroup.Id;
        LeadTriggerHandler.convertLead(leadObj.Id);
        Test.stopTest(); 
    }
    
    @isTest static void testMethodfour() {   
        Test.startTest();
        Business_Category__c businessCategoryOthers = [SELECT id, name FROM Business_Category__c WHERE name =: 'Others'];
        
        Sub_Category__c subCategoryOthers = [SELECT id, name FROM Sub_Category__c WHERE name =: 'Others'];
        
        Lead leadObj = [SELECT id, BusinessCategory__c, Business_Category_Other__c, Sub_Category__c, 
                        Sub_Category_Other__c,Partner_ID__c  FROM Lead LIMIT 1 ];
        
        Bank_Account_Detail__c bad = [Select Id,Active__c,Verification_Status__c,Lead__c from Bank_Account_Detail__c LIMIT 1];
        bad.Verification_Status__c = 'Success';
        bad.Active__c = true;
        bad.Lead__c = leadObj.Id;
        update bad;
        
        Entity__c ent = [Select Id from Entity__c where Name=:'Individual' LIMIT 1];
        
        List<Address_Details__c> addDetailsRegObj = [Select Id from Address_Details__c];
        addDetailsRegObj[0].Lead__c = leadObj.Id;
        update addDetailsRegObj;
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        
        QueuesObject testQueue;
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        GroupMember grpMem1 = new GroupMember();
        System.runAs(new User(Id=userinfo.getUserId())){
            grpMem1.UserOrGroupId = UserInfo.getUserId();
            grpMem1.GroupId = testGroup.Id;
            Insert grpMem1;
            testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
            insert testQueue;
        }
        
        Account accountObj1 = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        //accountObj1.Business_Entity__c =  entityObj.Id;
        accountObj1.Identifier__c = '9867587879089887';
        insert accountObj1;
        
        Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj1);
        opportunityObj1.Lead_Type__c = 'Partner';
        opportunityObj1.LeadSource = 'Partner';
        insert opportunityObj1;
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;

        User usr = new User(LastName = 'Mishra',
                           FirstName='Shivani',
                           Alias = 'shmish',
                            MobilePhone='%7877002681',
                            isActive=true,
                           Email = 'shivani.mishra@example.com',
                           Username = 'shivani.mishra@example.com',
                           ProfileId = (Id) profileId,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        //User userObj = new User(FirstName='Shivani',LastName='Mishra', isActive=true, MobilePhone='%7877002681');
        insert usr;
        
        leadObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
        leadObj.BusinessCategory__c = businessCategoryOthers.id ;
        leadObj.Status = 'Nurturing';
        leadObj.Sub_Status__c = 'Contacted';
        leadObj.Business_Category_Other__c = 'NGO'; 
        leadObj.Sub_Category__c = subCategoryOthers.id ;
        leadObj.Sub_Category_Other__c = 'Books' ;
        leadObj.Merchant_Type__c = 'seller' ;
        leadObj.Legal_Name__c = 'test classs Queue Ass';
        leadObj.MobilePhone = '9911111750';
        leadObj.Email = 'shiv.Kum+tf67tyg7hqa@payu.in';
        leadObj.Prod_Merchant_Id__c = 12398231;
        leadObj.Sub_Source__c = 'WebsiteSignUp';
        leadObj.Business_Entity__c = ent.Id;
        leadObj.Transaction_Facility_Required__c = 'Domestic';
        leadObj.Delivery_Duration__c = 21;
        leadObj.Monthly_Expected_Sale__c = 122;
        leadObj.Bank_Verification_Status__c = 'Success';
        leadObj.Manual_Call_Response__c = 'CallStartTime:05-04-2020 12:06 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765926,Bill_Seconds:100';
        leadObj.Delivery_Duration__c = 90;
        leadObj.lead_type__c = 'seller' ;
        leadObj.OwnerId = testGroup.Id;
        leadObj.Agent_Details__c='Shivani Mishra - 7877002681';
        leadObj.Identifier__c = '11e1-d9f0-6fc7926c-bf11-02aa98afd2b0';
        update leadObj;
        
        leadobj.Partner__c= opportunityObj1.Id;
        update leadObj;
        
        //getTaskList
//        LeadTriggerHandler.
        
        
        Test.stopTest();    
        Lead convertedLead = [SELECT ConvertedAccountId,ConvertedOpportunityId FROM Lead WHERE Id = :leadObj.Id];
        //System.assertNotEquals(null, convertedLead.ConvertedAccountId, 'Expected lead to be converted.');
        if(!leadObj.IsConverted && convertedLead.ConvertedOpportunityId==null){
            database.leadConvert lc = new database.leadConvert();
            lc.setLeadId(leadObj.id);
            lc.setOwnerId(userinfo.getUserId());
            leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            // Database.LeadConvertResult lcr = Database.convertLead(lc);
            // System.assert(lcr.isSuccess());
        }
        List<Lead> leadList = new List<Lead>();
        leadList.add(leadObj);
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        leadMap.put(leadObj.Id,leadObj);
        LeadTriggerHandler.checkModifyOwner(leadList,leadMap);
        LeadTriggerHandler.createTaskforClickToCall(leadList,leadMap);
        
        
    }
    
    
    
    /*@isTest
    public static void testCOCalloutToGetMIDBatch() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
        Lead leadTest1 = new Lead();
        leadTest1.FirstName = 'TestFirstName';
        leadTest1.LastName = 'TestLastName';
        leadTest1.Company = 'TestCompany';
        leadTest1.MobilePhone = '8880565644';
        leadTest1.Email = 'testmail@gmail.com';
        testLeads.add(leadTest1);
        insert testLeads;

        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create an instance of the batch class
        List<Id> leadIds = new List<Id>();
        for (Lead lead : testLeads) {
            leadIds.add(lead.Id);
        }
        Integer batchSize = 100;
        COCalloutToGetMIDBatch batch = new COCalloutToGetMIDBatch(leadIds, batchSize);

        // Start the batch execution
        Database.QueryLocator queryLocator = batch.start(null);

        Test.startTest(); // Start the separate transaction

        // Execute the batch
        batch.execute(null, testLeads);

        Test.stopTest(); // End the separate transaction

        // Verify the results
        List<Lead> updatedLeads = [SELECT Id, Prod_Merchant_Id__c FROM Lead WHERE Id IN :leadIds];
        System.assertEquals(testLeads.size(), updatedLeads.size(), 'All leads should have been updated with Prod_Merchant_Id__c');
        for (Lead lead : updatedLeads) {
            System.assertNotEquals(null, lead.Prod_Merchant_Id__c, 'Prod_Merchant_Id__c should not be null');
        }
    }
    
    // Mock HTTP callout response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"product_account":{"identifier":123}}');
            return response;
        }
    }*/
    
}