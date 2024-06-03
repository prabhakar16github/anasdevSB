@isTest
public class OpportunityTriggerTracker{
    
    @testSetup static void setupCommonData(){
        OpportunityOwnerWebsiteNull__c objSetting=new OpportunityOwnerWebsiteNull__c();
        objsetting.Current_Value__c =1;
        objSetting.Maximum_Value__c = 2;
        objSetting.Name='OppOwnerWebsiteNullMerchant';
        insert objSetting;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            LastName = 'Shivdeep test',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            MobilePhone  = '7877002681',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        system.runAs(u){
            Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            Test.setMock(HttpCalloutMock.class, new MockClass());
            
            Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
            insert triggerSwitchObj ;
            
            Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
            insert enableUUIDObjObj;
            
            Enable_UUID_Objects__c enableUUIDObjObj1 = CommonDataTracker.insertEnableUUIDRec('Lead', true);
            insert enableUUIDObjObj1;
            
            Credentials__c credObj = CommonDataTracker.insertCredentials();
            insert credObj;
            
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
            System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockClass()); 
            
            Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
            businessCategory.Doable__c = True;
            insert businessCategory;
            
            Business_Category__c businessCategory1 = CommonDataTracker.insertBusinessCategory('Real Estate', false);
            businessCategory1.Doable__c = True;
            insert businessCategory1;
            
            Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
            insert subCategory;
            
            Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
            opportunityObj.BusinessCategory__c = businessCategory.id;
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Delivery_Duration__c = 90;
            opportunityObj.Manual_Call_Response__c = 'CallStartTime:01-03-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:323';
            //opportunityObj.Partner_ID__c = Label.Shopmatric_UUID;
            opportunityObj.C2C_Call_Count__c=2;
            opportunityObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
            opportunityObj.Risk_Type_Multi_Select__c = 'Website URL';
            opportunityObj.Blacklist__c = true;
            opportunityObj.Agent_Details__c='Shivdeep test - 7877002681';
            insert opportunityObj;
            
            System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
            Test.stopTest(); 
            
        }
    }
    
    @isTest static void testMethodOne() {
        
        Test.startTest();
        Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
        babyCareFlow.Name = 'FlowActivate ';
        babyCareFlow.Active__c  = true;
        insert babyCareFlow;
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
        
        User usr = [Select Id, MobilePhone,Name from User LIMIT 1];
        
        Opportunity opp = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        opp.iOS_URL__c = 'a.b.com';
        opp.MAF_Status__c = 'Received';
        opp.Bank_Verification_Status__c = 'Success'; 
        opp.Product__c = prodObj.Id;
        opp.Agent_Details__c='Shivdeep test - 7877002681';
        opp.BusinessCategory__c = businessCategory.id;
        opp.Transaction_Facility_Required__c = 'Domestic';
        opp.Manual_Call_Response__c = 'CallStartTime:05-03-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:90';
        opp.Delivery_Duration__c = 90;
        // opp.NEFT_Hold_Status__c = 'Hold';
        update opp; 
        
        opp.NEFT_Hold_Status__c = 'Active';
        //opp.Settlement_Status__c='Risk Hold';
        opp.Risk_Type_Multi_Select__c = 'Website URL';
        opp.Blacklist__c = true;
        update opp;
        
        opp.Settlement_Status__c='Active';
        opp.Key_Assigned_Manager__c=null;
        opp.GMV_Lifetime__c=null;
        update opp;
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account WHERE Name='Test Account'];
        Opportunity opportunityObj3 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj3.Website_Status__c = 'Website OK';
        opportunityObj3.Integration_Type__c = 'ThirdParty';
        opportunityObj3.Product__c = prodObj.Id;
        opportunityObj3.Lead_Type__c='Merchant';
        opportunityObj3.Partner__c=null;
        opportunityObj3.BusinessCategory__c = businessCategory.id;
        opportunityObj3.Delivery_Duration__c = 90;
        opportunityObj3.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj3.isConverted__c = True;
        opportunityObj3.LOB_Status__c = 'Approved';
        opportunityObj3.Prod_Merchant_Id__c = 2305677;
        opportunityObj3.Document_Status__c=accountObj.Document_Status__c;
        opportunityObj3.Website__c='payu.in';
        opportunityObj3.Blacklist__c = true;
        opportunityObj3.Settlement_Status__c='Active';
        opportunityObj3.OwnerId=('0057F000005HnDkQAK') ;
        opportunityObj3.Agent_Details__c='Shivdeep test - 7877002681';
        insert opportunityObj3;
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj4.stageName = 'Terminated';
        opportunityObj4.Website_Status__c = 'Website Error';
        opportunityObj4.Risk_Level__c = '';
        opportunityObj4.Merchant_Type__c = 'Seller';
        opportunityObj4.BusinessCategory__c = businessCategory.id;
        opportunityObj4.Sub_Category__c = subCategory.id;
        opportunityObj4.Delivery_Duration__c = 23;
        opportunityObj4.Monthly_Expected_Sale__c = 2342;
        opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj4.MAF_Status__c = 'Received';
        opportunityObj4.Agreement_Status__c='Pending';
        opportunityObj4.Document_Status__c='Pending';
        opportunityObj4.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj4.Bank_Verification_Status__c = 'Success';
        opportunityObj4.LOB_Status__c='Pending';
        opportunityObj4.Prod_Merchant_Id__c = 2345677;
        opportunityObj4.Settlement_Status__c='Active';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj4.Blacklist__c = true;
        opportunityObj4.Business_Entity__c =entityObj.Id;
        opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Bank Detail';
        insert opportunityObj4;
        
        System.debug('OB Hold ss =========');
        opportunityObj4.stageName = 'MAF';
        opportunityObj4.Blacklist__c = false;
        opportunityObj4.Settlement_Status__c = 'Active';
        
        update opportunityObj4; 
        
        Opportunity opportunityObj5 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj5.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        
        insert opportunityObj5;
        Test.stopTest();
    }
    
    @isTest static void testHoldChanges() {
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account WHERE Name='Test Account'];
        Opportunity opportunityObj3 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj3.Website_Status__c = 'Website OK';
        opportunityObj3.Integration_Type__c = 'ThirdParty';
        opportunityObj3.Product__c = prodObj.Id;
        opportunityObj3.Lead_Type__c='Merchant';
        opportunityObj3.Partner__c=null;
        opportunityObj3.BusinessCategory__c = businessCategory.id;
        opportunityObj3.Delivery_Duration__c = 90;
        opportunityObj3.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj3.isConverted__c = True;
        opportunityObj3.LOB_Status__c = 'Approved';
        opportunityObj3.Prod_Merchant_Id__c = 2305677;
        opportunityObj3.Document_Status__c=accountObj.Document_Status__c;
        opportunityObj3.Website__c='payu.in';
        opportunityObj3.Blacklist__c = true;
        opportunityObj3.Settlement_Status__c='Active';
        opportunityObj3.OwnerId=('0057F000005HnDkQAK') ;
        opportunityObj3.Agent_Details__c='Shivdeep test - 7877002681';
        insert opportunityObj3;
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj4.stageName = 'Terminated';
        opportunityObj4.Website_Status__c = 'Website Error';
        opportunityObj4.Risk_Level__c = '';
        opportunityObj4.Merchant_Type__c = 'Seller';
        opportunityObj4.BusinessCategory__c = businessCategory.id;
        opportunityObj4.Sub_Category__c = subCategory.id;
        opportunityObj4.Delivery_Duration__c = 23;
        opportunityObj4.Monthly_Expected_Sale__c = 2342;
        opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj4.MAF_Status__c = 'Received';
        opportunityObj4.Agreement_Status__c='Pending';
        opportunityObj4.Document_Status__c='Pending';
        opportunityObj4.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj4.Bank_Verification_Status__c = 'Success';
        opportunityObj4.LOB_Status__c='Pending';
        opportunityObj4.Prod_Merchant_Id__c = 6969696;
        opportunityObj4.Settlement_Status__c='Active';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj4.Blacklist__c = true;
        opportunityObj4.Business_Entity__c =entityObj.Id;
        opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Bank Detail';
        insert opportunityObj4;
        
        System.debug('OB Hold ss =========');
        opportunityObj4.stageName = 'MAF';
        opportunityObj4.Blacklist__c = false;
        opportunityObj4.Settlement_Status__c = 'Active';
        update opportunityObj4; 
        
        opportunityObj4.Settlement_Status__c = 'Risk Hold';
        opportunityObj4.Merchant_Business_Type__c = 'Longtail';
        opportunityObj4.On_OB_Hold__c = 'N';
        opportunityObj4.On_Post_Risk_Hold__c = 'N';
        opportunityObj4.On_Pre_Risk_Hold__c = 'N';
        opportunityObj4.Integration_Type__c = 'Thirdparty';
        opportunityObj4.Document_Status_Document_Issue__c = 'Pending';
        update opportunityObj4;
        
        opportunityObj4.Settlement_Status__c = 'Active';
        update opportunityObj4;
        
        /*opportunityObj4.Settlement_Status__c = 'OB Hold';
update opportunityObj4;

opportunityObj4.Settlement_Status__c = 'Active';
update opportunityObj4;

opportunityObj4.Settlement_Status__c = 'Pre-Risk Hold';
update opportunityObj4;*/
    }
    
    @isTest static void testMethodTwo() {
        try{
            Test.startTest();
            Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
            babyCareFlow.Name = 'FlowActivate ';
            babyCareFlow.Active__c  = true;
            insert babyCareFlow;
            Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
            
            Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
            
            Sub_Category__c subCategory2 = CommonDataTracker.insertSubCategory('DTH', false);
            insert subCategory2;
            
            Test.setMock(HttpCalloutMock.class, new MockClass());
            Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
            insert platformObj;
            System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
            
            string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
            system.assertNotEquals(profileId, null);
            
            Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
            insert prodObj; 
            System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
            
            String pgDetails = '{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}';
            Website_Page_Master__c wpm = CommonDataTracker.insertWPM('Contact Us Details',pgDetails);
            wpm.Integration_Type__c = 'ThirdParty';
            wpm.Product__c = prodObj.Id;
            insert wpm;
            
            Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                                  Name,Pan_Verification_Status__c FROM Account WHERE Name='Test Account'];
            
            accountObj.Risk_Type_Multi_Select__c = 'Website URL';
            accountObj.Monthly_Expected_Sale__c = 2343;
            accountObj.Delivery_Duration__c = 23;
            accountObj.Pan_Verification_Status__c = 'Success';
            update accountObj;
            Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityObj4.stageName = 'MAF';
            opportunityObj4.Website_Status__c = 'Verification in Process';
            opportunityObj4.Risk_Level__c = '';
            opportunityObj4.Merchant_Type__c = '';
            opportunityObj4.BusinessCategory__c = businessCategory.id;
            opportunityObj4.Sub_Category__c = subCategory.id;
            opportunityObj4.Delivery_Duration__c = 23;
            opportunityObj4.Monthly_Expected_Sale__c = 2342;
            opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj4.Prod_Merchant_Id__c = 2345677;
            opportunityObj4.Product__c = prodObj.Id;
            opportunityObj4.Website__c='payu.in';
            opportunityObj4.iOS_URL__c='payu.in';
            opportunityObj4.Android_URL__c='payu.in';
            opportunityObj4.Lead_Type__c='Merchant';
            opportunityObj4.OwnerId=('0057F000005HnDk') ;
            opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
            opportunityObj4.Manual_Call_Response__c = 'CallStartTime:01-06-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:32';
            opportunityObj4.Document_Status_Document_Issue__c='Pending';
            opportunityObj4.Credit_Underwriting_Status__c='';
            opportunityObj4.Settlement_Status__c='Active';
            opportunityObj4.Integration_Type__c='ThirdParty';
            opportunityObj4.LeadSource='Organic';
            opportunityObj4.Partner__c=null;
            
            insert opportunityObj4;
            opportunityObj4.Website_Status__c = 'Verification in Process';
            opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
            opportunityObj4.StageName = 'Terminated';
            opportunityObj4.Document_Status_Document_Issue__c='Docs Received';
            opportunityObj4.Credit_Underwriting_Status__c='Approved';
            opportunityObj4.C2C_Call_Count__c=3;
            opportunityObj4.Risk_Type_Multi_Select__c = 'Website URL';
            opportunityObj4.Manual_Call_Response__c = 'CallStartTime:10-06-2020 12:16 AM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:';
            opportunityObj4.Missed_Call_Time__c='06-05-2020 17:10 PM';
            opportunityObj4.Blacklist__c = true;
            update opportunityObj4;
            
            opportunityObj4.Merchant_Type__c = 'Seller';
            opportunityObj4.Website_Status__c = 'Website OK';
            opportunityObj4.Website__c = 'www.google.com';
            opportunityObj4.Document_Status_Document_Issue__c='Docs Approved';
            update opportunityObj4;
            
            opportunityObj4.Lead_Type__c = 'Seller';
            opportunityObj4.Delivery_Duration__c = 33;
            opportunityObj4.Sub_Category__c = subCategory2.id;
            update opportunityObj4;
            opportunityObj4.Missed_Call_Time__c='06-05-2020 07:10 AM';
            opportunityObj4.Lead_Type__c = 'Merchant';
            update opportunityObj4;
            
            opportunityObj4.Lead_Type__c = 'Merchant';
            opportunityObj4.Website__c = 'www.google.com';
            opportunityObj4.Website__c = 'Pending';
            opportunityObj4.Integration_Type__c = 'Thirdparty';
            opportunityObj4.Settlement_Status__c='Active';
            update opportunityObj4;
            
        }Catch(Exception Ex){}
        Test.stopTest();
    }
    
    @isTest static void testMethodThree() {
        
        Test.startTest();
        
        
        Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
        babyCareFlow.Name = 'FlowActivate ';
        babyCareFlow.Active__c  = true;
        insert babyCareFlow;
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Sub_Category__c subCategory2 = CommonDataTracker.insertSubCategory('DTH', false);
        insert subCategory2;
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu Money');
        insert platformObj;
        System.assertEquals('payu Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                              Name,Pan_Verification_Status__c FROM Account WHERE Name='Test Account'];
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        accountObj.Monthly_Expected_Sale__c = 2343;
        accountObj.Delivery_Duration__c = 23;
        accountObj.Pan_Verification_Status__c = 'Success';
        update accountObj;
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj4.stageName = 'MAF';
        opportunityObj4.Risk_Level__c = '';
        opportunityObj4.Merchant_Type__c = '';
        opportunityObj4.BusinessCategory__c = businessCategory.id;
        opportunityObj4.Sub_Category__c = subCategory.id;
        opportunityObj4.Delivery_Duration__c = 23;
        opportunityObj4.Monthly_Expected_Sale__c = 2342;
        opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj4.Prod_Merchant_Id__c = 2345677;
        opportunityObj4.Product__c = prodObj.Id;
        opportunityObj4.Lead_Type__c='Merchant';
        opportunityObj4.OwnerId=('0057F000005HnDkQAK') ;
        opportunityObj4.Document_Status_Document_Issue__c='Pending';
        opportunityObj4.Credit_Underwriting_Status__c='';
        opportunityObj4.Integration_Type__c='Tools';
        opportunityObj4.Settlement_Status__c='Active';
        opportunityObj4.LeadSource='Organic';
        opportunityObj4.Partner__c=null;
        opportunityObj4.Merchant_Business_Type__c='LongTail';
        opportunityObj4.CreatedDate=date.today();
        opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj4.Manual_Call_Response__c = 'CallStartTime:10-06-2020 12:16 AM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:4334';
        opportunityObj4.Missed_Call_Time__c='06-05-2020 17:10 PM';
        insert opportunityObj4;
        opportunityObj4.Settlement_Status__c='Active';
        opportunityObj4.Website__c='test123@payu.in';
        opportunityObj4.iOS_URL__c='test123@payu.in';
        opportunityObj4.Android_URL__c='test123@payu.in';
        opportunityObj4.Integration_Type__c='ThirdParty';
        update opportunityObj4;
        opportunityObj4.Merchant_Business_Type__c='Compulsive';
        update opportunityObj4;
        
        System.debug('##### '+opportunityObj4.Partner_ID__c);
        
        Test.stopTest();  
        
    }
    @isTest static void testMethodFour() {
        try{
            Test.startTest();
            Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
            babyCareFlow.Name = 'FlowActivate ';
            babyCareFlow.Active__c  = true;
            insert babyCareFlow;
            
            Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
            
            Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
            
            Sub_Category__c subCategory2 = CommonDataTracker.insertSubCategory('DTH', false);
            insert subCategory2;
            
            Test.setMock(HttpCalloutMock.class, new MockClass());
            Platform__c platformObj = CommonDataTracker.insertPlatform('payu Money');
            insert platformObj;
            System.assertEquals('payu Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
            
            string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
            system.assertNotEquals(profileId, null);
            
            Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
            insert prodObj; 
            System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
            
            String pgDetails = '{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}';
            Website_Page_Master__c wpm = CommonDataTracker.insertWPM('Contact Us Details',pgDetails);
            wpm.Integration_Type__c = 'ThirdParty';
            wpm.Product__c = prodObj.Id;
            insert wpm;
            
            Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                                  Name,Pan_Verification_Status__c FROM Account WHERE Name='Test Account'];
            
            accountObj.Risk_Type_Multi_Select__c = 'Website URL';
            accountObj.Monthly_Expected_Sale__c = 2343;
            accountObj.Delivery_Duration__c = 23;
            accountObj.Pan_Verification_Status__c = 'Success';
            update accountObj;
            
            Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
            opportunityObj.Identifier__c = Label.Shopmatric_UUID;
            opportunityObj.Lead_Type__c = 'Partner';
            opportunityObj.Manual_Call_Response__c = 'CallStartTime:10-06-2020 12:16 AM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:2344';
            opportunityObj.Missed_Call_Time__c='06-05-2020 17:10 PM';
            Insert opportunityObj;
            
            Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityObj4.stageName = 'MAF';
            opportunityObj4.Website_Status__c = 'Verification in Process';
            opportunityObj4.Risk_Level__c = '';
            opportunityObj4.Merchant_Type__c = '';
            opportunityObj4.Partner__c = opportunityObj.Id;
            opportunityObj4.BusinessCategory__c = businessCategory.id;
            opportunityObj4.Sub_Category__c = subCategory.id;
            opportunityObj4.Delivery_Duration__c = 23;
            opportunityObj4.Monthly_Expected_Sale__c = 2342;
            opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj4.Prod_Merchant_Id__c = 2345677;
            opportunityObj4.Product__c = prodObj.Id;
            opportunityObj4.Risk_Type_Multi_Select__c = 'Website URL';
            opportunityObj4.Integration_Type__c = 'Tools';
            opportunityObj4.Blacklist__c = true;
            opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
            opportunityObj4.Manual_Call_Response__c = 'CallStartTime:10-06-2020 12:16 AM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:232';
            opportunityObj4.Missed_Call_Time__c='06-05-2020 17:10 PM';
            insert opportunityObj4;
            
            opportunityObj4.Integration_Type__c='ThirdParty';
            opportunityObj4.Partner__c = null;
            
            opportunityObj4.Manual_Call_Response__c = 'CallStartTime:11-06-2020 12:19 AM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765486,Bill_Seconds:32423';
            opportunityObj4.Missed_Call_Time__c='06-05-2020 17:10 PM';
            update opportunityObj4;
            
            System.debug('##### '+opportunityObj4.Partner_ID__c);
        }Catch(Exception Ex){}
        Test.stopTest();
    }
    
    @isTest static void testMethod5() {
        try{
            Test.startTest();
            Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
            babyCareFlow.Name = 'FlowActivate ';
            babyCareFlow.Active__c  = false;
            insert babyCareFlow;
            
            Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
            
            Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
            
            Sub_Category__c subCategory2 = CommonDataTracker.insertSubCategory('DTH', false);
            insert subCategory2;
            
            Test.setMock(HttpCalloutMock.class, new MockClass());
            Platform__c platformObj = CommonDataTracker.insertPlatform('payu Money');
            insert platformObj;
            System.assertEquals('payu Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
            
            Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
            insert prodObj; 
            System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
            
            Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                                  Name,Pan_Verification_Status__c FROM Account WHERE Name='Test Account'];
            
            accountObj.Risk_Type_Multi_Select__c = 'Website URL';
            accountObj.Monthly_Expected_Sale__c = 2343;
            accountObj.Delivery_Duration__c = 23;
            accountObj.Pan_Verification_Status__c = 'Success';
            update accountObj;
            
            Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Wibmo').getRecordTypeId();
            opportunityObj4.stageName = 'Stage 4 - Closure';
            opportunityObj4.Risk_Level__c = '';
            opportunityObj4.Target_Close_Date__c=Date.today()+4;
            opportunityObj4.Merchant_Type__c = '';
            opportunityObj4.BusinessCategory__c = businessCategory.id;
            opportunityObj4.Sub_Category__c = subCategory.id;
            opportunityObj4.Delivery_Duration__c = 23;
            opportunityObj4.Monthly_Expected_Sale__c = 2342;
            opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj4.Prod_Merchant_Id__c = 2345677;
            opportunityObj4.Product__c = prodObj.Id;
            opportunityObj4.Lead_Type__c = 'Merchant';
            opportunityObj4.Document_Status_Document_Issue__c='Pending';
            opportunityObj4.Credit_Underwriting_Status__c='';
            opportunityObj4.Integration_Type__c='Tools';
            opportunityObj4.Settlement_Status__c='Active';
            opportunityObj4.LeadSource='Organic';
            opportunityObj4.Partner__c=null; 
            opportunityObj4.Merchant_Business_Type__c='LongTail';
            opportunityObj4.Agent_Details__c='Shivani Mishra - 7877002681';
            opportunityObj4.Manual_Call_Response__c = 'CallStartTime:10-06-2020 12:16 AM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:3223';
            opportunityObj4.Missed_Call_Time__c='06-05-2020 17:10 PM';
            opportunityObj4.Website__c='test123444@payu.in';
            opportunityObj4.iOS_URL__c='test123@payu.in';
            opportunityObj4.Android_URL__c='test123@payu.in';
            insert opportunityObj4;
            
            opportunityObj4.Manual_Call_Response__c = 'CallStartTime:10-06-2020 12:16 AM,CallStatus:ANSWER,CallID:c2c_71b94765426,Bill_Seconds:33';
            update opportunityObj4;
            
            opportunity opportunityObj = [SELECT id,Integration_Type__c FROM opportunity WHERE Website__c='test123444@payu.in'];
            opportunityObj.Integration_Type__c = 'Tools';
            update opportunityObj;
            
            opportunityObj4.Merchant_Business_Type__c='Compulsive';
            update opportunityObj4;
            
        }Catch(Exception Ex){}
        Test.stopTest();
    }
    
    @isTest static void testMethod6() {
        try{
            Test.startTest();
            Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
            babyCareFlow.Name = 'FlowActivate ';
            babyCareFlow.Active__c  = true;
            insert babyCareFlow;
            Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
            
            Business_Category__c businessCategory1 = [Select Id,Doable__c from Business_Category__c  where name = 'Real Estate' LIMIT 1];
            
            Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
            
            Sub_Category__c subCategory2 = CommonDataTracker.insertSubCategory('DTH', false);
            insert subCategory2;
            
            Test.setMock(HttpCalloutMock.class, new MockClass());
            Platform__c platformObj = CommonDataTracker.insertPlatform('payu Money');
            insert platformObj;
            System.assertEquals('payu Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
            
            string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
            system.assertNotEquals(profileId, null);
            
            Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
            insert prodObj; 
            System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
            
            String pgDetails = '{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}';
            Website_Page_Master__c wpm = CommonDataTracker.insertWPM('Contact Us Details',pgDetails);
            wpm.Integration_Type__c = 'ThirdParty';
            wpm.Product__c = prodObj.Id;
            insert wpm;
            
            Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                                  Name,Pan_Verification_Status__c FROM Account WHERE Name='Test Account'];
            
            //accountObj.Risk_Type_Multi_Select__c = 'Website URL';
            accountObj.Monthly_Expected_Sale__c = 234334567;
            accountObj.Delivery_Duration__c = 2663;
            accountObj.Pan_Verification_Status__c = 'Success';
            update accountObj;
            
            Merchant_Plan__c Plan = new Merchant_Plan__c();
            Plan.Name = 'business_plus';
            Plan.Status__c = 'payment_completed';
            Plan.Price__c = 950;
            insert Plan;
            
            Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityObj4.stageName = 'MAF';
            opportunityObj4.Website__c = 'test.com';
            opportunityObj4.Website_Status__c = 'Verification in Process';
            opportunityObj4.Risk_Level__c = '';
            opportunityObj4.Merchant_Type__c = '';
            opportunityObj4.BusinessCategory__c = businessCategory.id;
            opportunityObj4.Sub_Category__c = subCategory.id;
            opportunityObj4.Delivery_Duration__c = 23;
            opportunityObj4.Monthly_Expected_Sale__c = 2342;
            opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj4.Prod_Merchant_Id__c = 2345677;
            opportunityObj4.Product__c = prodObj.Id;
            opportunityObj4.Integration_Type__c='ThirdParty';
            opportunityObj4.Partner__c = null;
            insert opportunityObj4;
            
            Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityObj.stageName = 'MAF';
            opportunityObj.Risk_Level__c = '';
            opportunityObj.Merchant_Type__c = '';
            opportunityObj.BusinessCategory__c = businessCategory.id;
            opportunityObj.Sub_Category__c = subCategory.id;
            opportunityObj.Delivery_Duration__c = 23;
            opportunityObj.Monthly_Expected_Sale__c = 2342;
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Prod_Merchant_Id__c = 2345677;
            opportunityObj.Product__c = prodObj.Id;
            opportunityObj.Integration_Type__c='ThirdParty';
            opportunityObj.Partner__c = null;
            insert opportunityObj;
            
            Plan.Opportunity__c = opportunityObj.id;
            update Plan;
            
            opportunityObj.isPremiumCustomer__c = true;
            opportunityObj.Website__c = 'test.com';
            opportunityObj.Website_Status__c = 'Verification in Process';
            update opportunityObj;
            
            
            accountObj.Monthly_Expected_Sale__c = 27;
            accountObj.Delivery_Duration__c = 23;
            accountObj.Agreement_Status__c = 'Not Generated';
            update accountObj;
            
            Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityObj1.stageName = 'MAF';
            opportunityObj1.Risk_Level__c = '';
            opportunityObj1.Merchant_Type__c = '';
            opportunityObj1.BusinessCategory__c = businessCategory1.id;
            opportunityObj1.Sub_Category__c = subCategory.id;
            opportunityObj1.Delivery_Duration__c = 23;
            opportunityObj1.Monthly_Expected_Sale__c = 22;
            opportunityObj1.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj1.Prod_Merchant_Id__c = 2345677;
            opportunityObj1.Product__c = prodObj.Id;
            opportunityObj1.Integration_Type__c='ThirdParty';
            opportunityObj1.Partner__c = null;
            opportunityObj1.Website__c = 'test.com';
            insert opportunityObj1;
            
            Plan.Opportunity__c = opportunityObj1.id;
            update Plan;
            
            opportunityObj1.isPremiumCustomer__c = true;
            opportunityObj1.Website__c = 'google.com';
            opportunityObj1.Website_Status__c = 'Verification in Process';
            update opportunityObj1;
            
        }Catch(Exception Ex){}
        Test.stopTest();
    }
    
    @isTest static void testMethod7() {
        
        Test.startTest();
        Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
        babyCareFlow.Name = 'FlowActivate';
        babyCareFlow.Active__c  = true;
        insert babyCareFlow;
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Business_Category__c businessCategory1 = [Select Id,Doable__c from Business_Category__c  where name = 'Real Estate' LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Sub_Category__c subCategory2 = CommonDataTracker.insertSubCategory('DTH', false);
        insert subCategory2;
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu Money');
        insert platformObj;
        System.assertEquals('payu Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                              Name,Pan_Verification_Status__c FROM Account WHERE Name='Test Account'];
        
        accountObj.Monthly_Expected_Sale__c = 27;
        accountObj.Delivery_Duration__c = 23;
        accountObj.Agreement_Status__c = 'Not Generated';
        update accountObj;
        
        Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj1.stageName = 'MAF';
        opportunityObj1.Risk_Level__c = '';
        opportunityObj1.Merchant_Type__c = '';
        opportunityObj1.BusinessCategory__c = businessCategory1.id;
        opportunityObj1.Sub_Category__c = subCategory.id;
        opportunityObj1.Delivery_Duration__c = 23;
        opportunityObj1.Monthly_Expected_Sale__c = 22;
        opportunityObj1.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj1.Prod_Merchant_Id__c = 2345677;
        opportunityObj1.Product__c = prodObj.Id;
        opportunityObj1.Integration_Type__c='ThirdParty';
        opportunityObj1.Partner__c = null;
        opportunityObj1.Website__c = 'test.com';
        opportunityObj1.Business_Entity__c = accountObj.Business_Entity__c;
        insert opportunityObj1;
        
        opportunityObj1.isPremiumCustomer__c = true;
        opportunityObj1.Website__c = 'google.com';
        opportunityObj1.Website_Status__c = 'Verification in Process';
        update opportunityObj1;
        
        opportunityObj1.NB_Eligible__c = True;
        update opportunityObj1;
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        insert EStampMasterObj;
        
        Contact contactObj = CommonDataTracker.InsertContact(accountObj);
        contactObj.Email = 'test@test2.com';
        insert contactObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        
        Document_Category_Master__c docCategoryMasterObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof');
        insert docCategoryMasterObj; 
        
        Id agreementRecordTypeId = Schema.SObjectType.Document_Master__c.getRecordTypeInfosByName().get('Agreement').getRecordTypeId();
        
        Document_Master__c docMasterAgreementObj = CommonDataTracker.insertDocumentMaster('Aadhar Card', docCategoryMasterObj, agreementRecordTypeId, 'ServiceAgreementIndianTrustsActOf1882');
        docMasterAgreementObj.Entity__c = entityObj.Id;
        insert docMasterAgreementObj ;
        
        Contract contractObj = CommonDataTracker.insertContract(accountObj, contactObj, opportunityObj1, docMasterAgreementObj, 'Pending');
        contractObj.E_Stamp__c = EStampMasterObj.Id;
        contractObj.Active__c = False;
        contractObj.Type__c = 'Final';
        insert contractObj;
        
        List<Opportunity> oppList = [Select Id,AccountId,Website_updated_last__c,VFPageKey__c,Agreement_Regeneration__c,
                                     Account.Agreement_Status__c from opportunity];
        
        opportunityTriggerHandler.updateagreementWithNewWebURL(oppList,New Map<String,String>());
       
        
        Test.stopTest();
    }
    
    public static testMethod void testData8(){
        Test.startTest();
        
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Government');
        entityObj.Identifier__c = '1d34-4e1f-259ec05d-1ea9-534dcc7967e5';
        insert entityObj;
        System.assertEquals('Government', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                              Name,Pan_Verification_Status__c FROM Account WHERE Name='Test Account'];
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj1.Website_Status__c = 'Verification in Process';
        opportunityObj1.Website__c = 'google.com';
        opportunityObj1.Monthly_Expected_Sale__c = 213331341;
        opportunityObj1.Delivery_Duration__c = 30;
        opportunityObj1.Business_Entity__c = entityObj.Id;
        opportunityObj1.Integration_Type__c = 'Thirdparty';
        opportunityObj1.Website_Addendum_Status__c = 'accepted';
        opportunityObj1.Lead_Type__c = 'Merchant';
        insert opportunityObj1;
        
        //oppList.add(opportunityObj1);
        
        Opportunity opportunityObj2 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        opportunityObj2.Lead_Type__c = 'Partner';
        opportunityObj2.Queue_Name__c = 'Partnerships_Alliances';
        opportunityObj2.Identifier__c = '11eb-818c-41ac9e28-be20-0a696b110fde';
        insert opportunityObj2;
        
        //oppList.add(opportunityObj2);
        
        Opportunity opportunityObj3 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        opportunityObj3.Lead_Type__c = 'Partner';
        opportunityObj3.Queue_Name__c = '';
        insert opportunityObj3;
        
        //oppList.add(opportunityObj3);
        
        opportunityObj3.Queue_Name__c = 'Partnerships_Alliances';
        update opportunityObj3;
        
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj4.Lead_Type__c = 'Merchant';
        opportunityObj4.Partner__c = opportunityObj2.Id;
        insert opportunityObj4;
        
        //oppList.add(opportunityObj4);
        
        Opportunity opportunityObj5 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj5.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj5.Lead_Type__c = 'Merchant';
        opportunityObj5.Merchant_Business_Type__c = 'Compulsive';
        opportunityObj5.Settlement_Status__c = 'Thirdparty Hold';
        opportunityObj5.Integration_Type__c = 'Thirdparty';
        insert opportunityObj5;
        
        opportunityObj5.Merchant_Business_Type__c = 'LongTail';
        update opportunityObj5;
        
        oppList.add(opportunityObj5);
        
        //OpportunityTriggerHandler.offlineLead(oppList);
        
        Test.stopTest();
    }
    
    public static testMethod void testData9(){
        Test.startTest();
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Government');
        entityObj.Identifier__c = '1d34-4e1f-259ec05d-1ea9-534dcc7967e5';
        insert entityObj;
        System.assertEquals('Government', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,Monthly_Expected_Sale__c,Delivery_Duration__c,
                              Name,Pan_Verification_Status__c,NDX_Score__c FROM Account LIMIT 1];
        accountObj.Monthly_Expected_Sale__c = 0;
        update accountObj;
        
        Opportunity opportunityObj1 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj1.Business_Entity__c = entityObj.Id;
        opportunityObj1.Integration_Type__c = 'Thirdparty';
        opportunityObj1.Lead_Type__c = 'Merchant';
        opportunityObj1.Manual_Call_Response__c = '';
        opportunityObj1.Website__c = 'payu.in';
        opportunityObj1.Merchant_Business_Type__c = 'LongTail';
        opportunityObj1.Product__c = prodObj.Id;
        insert opportunityObj1;
        
        System.assertEquals(DATE.today(), [SELECT id, Business_Entity__c,CreatedDate FROM Opportunity WHERE Id =: opportunityObj1.Id].CreatedDate.Date());
        System.assertEquals('Government', [SELECT id, Business_Entity__c,Business_Entity_Formula__c FROM Opportunity WHERE Id =: opportunityObj1.Id].Business_Entity_Formula__c);
        System.assertEquals('PayUmoney', [SELECT id, Product__c,ProductLabel__c FROM Opportunity WHERE Id =: opportunityObj1.Id].ProductLabel__c);
        
        Opportunity opportunityObj2 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj2.Blacklist__c = True;
        opportunityObj2.Risk_Type_Multi_Select__c = 'Lead Legal Name';
        insert opportunityObj2;
        
        Account accountObj2 = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        insert accountObj2;
        
        Opportunity opportunityObj3 = CommonDataTracker.insertOpportunity(accountObj2);
        opportunityObj3.Website__c = 'Payu.in';
        opportunityObj3.Merchant_Business_Type__c = 'LongTail';
        opportunityObj3.Integration_Type__c = 'Thirdparty';
        opportunityObj3.Website_Status__c = 'Verification in process';
        opportunityObj3.Monthly_Expected_Sale__c = 12330000;
        opportunityObj3.Delivery_Duration__c = 3;
        opportunityObj3.isPremiumCustomer__c = true;
        opportunityObj3.Lead_Type__c = 'Merchant';
        opportunityObj3.Website_Addendum_Status__c = 'accepted';
        insert opportunityObj3;
        
        opportunityObj3.isPremiumCustomer__c = false;
        update opportunityObj3;
        
        opportunityObj3.isPremiumCustomer__c = true;
        //opportunityObj3.Document_Status_Document_Issue__c = 'Docs Received';
        update opportunityObj3;
        
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj2);
        opportunityObj4.Website__c = 'Payu.in';
        opportunityObj4.Merchant_Business_Type__c = 'LongTail';
        opportunityObj4.Integration_Type__c = 'Thirdparty';
        opportunityObj4.Website_Status__c = 'Pending';
        opportunityObj4.Monthly_Expected_Sale__c = 12330000;
        opportunityObj4.Delivery_Duration__c = 3;
        opportunityObj4.isPremiumCustomer__c = true;
        opportunityObj4.Lead_Type__c = 'Merchant';
        opportunityObj4.Website_Addendum_Status__c = 'accepted';
        insert opportunityObj4;
        
        opportunityObj4.isPremiumCustomer__c = false;
        update opportunityObj4;
        
        opportunityObj4.isPremiumCustomer__c = true;
        update opportunityObj4;
        
        Account accountObj3 = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        accountObj3.Monthly_Expected_Sale__c = 1234344555;
        accountObj3.Delivery_Duration__c = 3;
        insert accountObj3;
        
        Opportunity opportunityObj5 = CommonDataTracker.insertOpportunity(accountObj3);
        opportunityObj5.Website__c = 'Payu.in';
        opportunityObj5.Merchant_Business_Type__c = 'LongTail';
        opportunityObj5.Integration_Type__c = 'Thirdparty';
        opportunityObj5.Website_Status__c = 'Verification in process';
        opportunityObj5.isPremiumCustomer__c = true;
        opportunityObj5.Lead_Type__c = 'Merchant';
        opportunityObj5.Website_Addendum_Status__c = 'accepted';
        insert opportunityObj5;
        
        opportunityObj5.isPremiumCustomer__c = false;
        update opportunityObj5;
        
        opportunityObj5.isPremiumCustomer__c = true;
        update opportunityObj5;
        
        Test.stopTest();
    }
    
    @istest static void testData_10(){
        
        Account accountObj2 = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        insert accountObj2;
        
        Opportunity opportunityObj3 = CommonDataTracker.insertOpportunity(accountObj2);
        opportunityObj3.Website__c = 'Payu.in';
        opportunityObj3.Merchant_Business_Type__c = 'LongTail';
        opportunityObj3.Integration_Type__c = 'Thirdparty';
        opportunityObj3.Website_Status__c = 'Verification in process';
        opportunityObj3.Monthly_Expected_Sale__c = 12330000;
        opportunityObj3.Delivery_Duration__c = 3;
        opportunityObj3.isPremiumCustomer__c = false;
        opportunityObj3.Lead_Type__c = 'Merchant';
        opportunityObj3.Website_Addendum_Status__c = 'accepted';
        insert opportunityObj3;
        
        Merchant_Plan__c mPlanObj = New Merchant_Plan__c();
        mPlanObj.Opportunity__c = opportunityObj3.Id;
        insert mPlanObj;
        
        opportunityObj3.isPremiumCustomer__c = true;
        opportunityObj3.Document_Status_Document_Issue__c = 'Docs Received';
        update opportunityObj3;
    }
    
    @istest static void testData_11(){
        Entity__c entityObj = CommonDataTracker.insertEntity('Government');
        entityObj.Identifier__c = '1d34-4e1f-259ec05d-1ea9-534dcc7967e5';
        insert entityObj;
        System.assertEquals('Government', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj2 = CommonDataTracker.insertAccount('Test Account2', 'LegalName86823', 'GKMSF4212W');
        insert accountObj2;
        
        Opportunity opportunityObj6 = CommonDataTracker.insertOpportunity(accountObj2);
        opportunityObj6.Website__c = 'Payu.in';
        opportunityObj6.Merchant_Business_Type__c = 'LongTail';
        opportunityObj6.Integration_Type__c = 'Thirdparty';
        opportunityObj6.Website_Status__c = 'Pending';
        opportunityObj6.isPremiumCustomer__c = true;
        opportunityObj6.Lead_Type__c = 'Merchant';
        opportunityObj6.Website_Addendum_Status__c = 'accepted';
        insert opportunityObj6;
        
        opportunityObj6.isPremiumCustomer__c = false;
        update opportunityObj6;
        
        opportunityObj6.isPremiumCustomer__c = true;
        update opportunityObj6;
        
        opportunityObj6.Integration_Type__c = 'Tools';
        update opportunityObj6;
        
        opportunityObj6.Integration_Type__c = 'Thirdparty';
        opportunityObj6.Manual_Call_Response__c = '';
        opportunityObj6.Business_Entity__c = entityObj.Id;
        opportunityObj6.Merchant_Business_Type__c = 'LongTail';
        update opportunityObj6;
        
        opportunityObj6.MAF_Status__c = 'Received';
        opportunityObj6.Website_Status__c = 'Website OK';
        opportunityObj6.Pricing_Negotiation_Status__c = 'Accepted';
        update opportunityObj6;
        system.assertEquals('Website OK', [Select Id,Website_Status__c from Opportunity Where Id=:opportunityObj6.Id].Website_Status__c);
        
    }
    
    @isTest static void testMethod12() {
        
        Test.startTest();
        Baby_Care_Flow__c babyCareFlow = new Baby_Care_Flow__c();
        babyCareFlow.Name = 'FlowActivate ';
        babyCareFlow.Active__c  = true;
        insert babyCareFlow;
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
        
        User usr = [Select Id, MobilePhone,Name from User LIMIT 1];
        
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> producerNameSet = new Set<String>();
        //producerNameSet.add('Salesforce');
        producerNameSet.add('MerchantOnboarding');
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account WHERE Name='Test Account'];
        Opportunity opportunityObj3 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj3.Website_Status__c = 'Website OK';
        opportunityObj3.Integration_Type__c = 'ThirdParty';
        opportunityObj3.Product__c = prodObj.Id;
        opportunityObj3.Lead_Type__c='Merchant';
        opportunityObj3.Partner__c=null;
        opportunityObj3.BusinessCategory__c = businessCategory.id;
        opportunityObj3.Delivery_Duration__c = 90;
        opportunityObj3.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj3.isConverted__c = True;
        opportunityObj3.LOB_Status__c = 'Approved';
        opportunityObj3.Prod_Merchant_Id__c = 2305677;
        opportunityObj3.Document_Status__c=accountObj.Document_Status__c;
        opportunityObj3.Website__c='payu.in';
        opportunityObj3.Blacklist__c = true;
        opportunityObj3.Settlement_Status__c='Active';
        opportunityObj3.OwnerId=('0057F000005HnDkQAK') ;
        opportunityObj3.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj3.Campaign_Name__c = 'Telesales';
        insert opportunityObj3;
        oppList.add(opportunityObj3);
        
        
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj4.stageName = 'Terminated';
        opportunityObj4.Website_Status__c = 'Website Error';
        opportunityObj4.Risk_Level__c = '';
        opportunityObj4.Merchant_Type__c = 'Seller';
        opportunityObj4.BusinessCategory__c = businessCategory.id;
        opportunityObj4.Sub_Category__c = subCategory.id;
        opportunityObj4.Delivery_Duration__c = 23;
        opportunityObj4.Monthly_Expected_Sale__c = 2342;
        opportunityObj4.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj4.MAF_Status__c = 'Received';
        opportunityObj4.Agreement_Status__c='Pending';
        opportunityObj4.Document_Status__c='Pending';
        opportunityObj4.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj4.Bank_Verification_Status__c = 'Success';
        opportunityObj4.LOB_Status__c='Pending';
        opportunityObj4.Prod_Merchant_Id__c = 2345677;
        opportunityObj4.Settlement_Status__c='Active';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj4.Blacklist__c = true;
        opportunityObj4.Business_Entity__c =entityObj.Id;
        opportunityObj4.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj4.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj4.Campaign_Name__c = 'Telesales';
        insert opportunityObj4;
        
        opportunityObj4.Blacklist__c = false;
        update opportunityObj4;
        oppList.add(opportunityObj4);
        oppIdSet.add(opportunityObj4.Id);
        
        // testing for campaign before insert code
        // 
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opp1 = CommonDataTracker.insertOpportunity(accountObj);
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opp1.stageName = 'Terminated';
        opp1.Website_Status__c = 'Website Error';
        opp1.Risk_Level__c = '';
        opp1.Merchant_Type__c = 'Seller';
        opp1.BusinessCategory__c = businessCategory.id;
        opp1.Sub_Category__c = subCategory.id;
        opp1.Delivery_Duration__c = 23;
        opp1.Monthly_Expected_Sale__c = 2342;
        opp1.Transaction_Facility_Required__c = 'Domestic';
        opp1.MAF_Status__c = 'Received';
        opp1.Agreement_Status__c='Pending';
        opp1.Document_Status__c='Pending';
        opp1.Activation_Status_Onboarding__c='ME Code Activated';
        opp1.Bank_Verification_Status__c = 'Success';
        opp1.LOB_Status__c='Pending';
        opp1.Prod_Merchant_Id__c = 2345688;
        opp1.Settlement_Status__c='Active';
        opp1.Risk_Type_Multi_Select__c = 'Website URL';
        opp1.Blacklist__c = true;
        opp1.Business_Entity__c =entityObj.Id;
        opp1.Agent_Details__c='Shivdeep test - 7877002681';
        opp1.Risk_Type_Multi_Select__c = 'Bank Detail';
        opp1.Campaign_Name__c = 'Enterprise';
        insert opp1;
        oppList.add(opp1);
        
        
        
        System.debug('OB Hold ss =========');
        opportunityObj4.stageName = 'MAF';
        opportunityObj4.Blacklist__c = false;
        opportunityObj4.Settlement_Status__c = 'Active';
        
        //update opportunityObj4; 
        
        Opportunity opportunityObj5 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj5.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        
        insert opportunityObj5;
        oppList.add(opportunityObj5);
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj6 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj6.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj6.stageName = 'Terminated';
        opportunityObj6.Website_Status__c = 'Website Error';
        opportunityObj6.Risk_Level__c = '';
        opportunityObj6.Merchant_Type__c = 'Seller';
        opportunityObj6.BusinessCategory__c = businessCategory.id;
        opportunityObj6.Sub_Category__c = subCategory.id;
        opportunityObj6.Delivery_Duration__c = 23;
        opportunityObj6.Monthly_Expected_Sale__c = 2342;
        opportunityObj6.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj6.MAF_Status__c = 'Received';
        opportunityObj6.Agreement_Status__c='Pending';
        opportunityObj6.Document_Status__c='Pending';
        opportunityObj6.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj6.Bank_Verification_Status__c = 'Success';
        opportunityObj6.LOB_Status__c='Pending';
        opportunityObj6.Prod_Merchant_Id__c = 2345677;
        opportunityObj6.Settlement_Status__c='Active';
        opportunityObj6.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj6.Blacklist__c = true;
        opportunityObj6.Business_Entity__c =entityObj.Id;
        opportunityObj6.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj6.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj6.Campaign_Name__c = 'Vista-Lending-AR';
        insert opportunityObj6;
        oppList.add(opportunityObj6);
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj7 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj7.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj7.stageName = 'Terminated';
        opportunityObj7.Website_Status__c = 'Website Error';
        opportunityObj7.Risk_Level__c = '';
        opportunityObj7.Merchant_Type__c = 'Seller';
        opportunityObj7.BusinessCategory__c = businessCategory.id;
        opportunityObj7.Sub_Category__c = subCategory.id;
        opportunityObj7.Delivery_Duration__c = 23;
        opportunityObj7.Monthly_Expected_Sale__c = 2342;
        opportunityObj7.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj7.MAF_Status__c = 'Received';
        opportunityObj7.Agreement_Status__c='Pending';
        opportunityObj7.Document_Status__c='Pending';
        opportunityObj7.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj7.Bank_Verification_Status__c = 'Success';
        opportunityObj7.LOB_Status__c='Pending';
        opportunityObj7.Settlement_Status__c='Active';
        opportunityObj7.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj7.Blacklist__c = true;
        opportunityObj7.Business_Entity__c =entityObj.Id;
        opportunityObj7.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj7.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj7.Campaign_Name__c = 'SMB-Farming';
        insert opportunityObj7;
        oppList.add(opportunityObj7);
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj8 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj8.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj8.stageName = 'Terminated';
        opportunityObj8.Website_Status__c = 'Website Error';
        opportunityObj8.Risk_Level__c = '';
        opportunityObj8.Merchant_Type__c = 'Seller';
        opportunityObj8.BusinessCategory__c = businessCategory.id;
        opportunityObj8.Sub_Category__c = subCategory.id;
        opportunityObj8.Delivery_Duration__c = 23;
        opportunityObj8.Monthly_Expected_Sale__c = 2342;
        opportunityObj8.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj8.MAF_Status__c = 'Received';
        opportunityObj8.Agreement_Status__c='Pending';
        opportunityObj8.Document_Status__c='Pending';
        opportunityObj8.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj8.Bank_Verification_Status__c = 'Success';
        opportunityObj8.LOB_Status__c='Pending';
        opportunityObj8.Prod_Merchant_Id__c = 2345679;
        opportunityObj8.Settlement_Status__c='Active';
        opportunityObj8.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj8.Blacklist__c = true;
        opportunityObj8.Business_Entity__c =entityObj.Id;
        opportunityObj8.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj8.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj8.Campaign_Name__c = 'SMB-Outbound';
        insert opportunityObj8;
        oppList.add(opportunityObj8);
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj9 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj9.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj9.stageName = 'Terminated';
        opportunityObj9.Website_Status__c = 'Website Error';
        opportunityObj9.Risk_Level__c = '';
        opportunityObj9.Merchant_Type__c = 'Seller';
        opportunityObj9.BusinessCategory__c = businessCategory.id;
        opportunityObj9.Sub_Category__c = subCategory.id;
        opportunityObj9.Delivery_Duration__c = 23;
        opportunityObj9.Monthly_Expected_Sale__c = 2342;
        opportunityObj9.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj9.MAF_Status__c = 'Received';
        opportunityObj9.Agreement_Status__c='Pending';
        opportunityObj9.Document_Status__c='Pending';
        opportunityObj9.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj9.Bank_Verification_Status__c = 'Success';
        opportunityObj9.LOB_Status__c='Pending';
        opportunityObj9.Prod_Merchant_Id__c = 2345680;
        opportunityObj9.Settlement_Status__c='Active';
        opportunityObj9.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj9.Blacklist__c = true;
        opportunityObj9.Business_Entity__c =entityObj.Id;
        opportunityObj9.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj9.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj9.Campaign_Name__c = 'SMB-Strategy';
        insert opportunityObj9;
        oppList.add(opportunityObj9);
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj10 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj10.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj10.stageName = 'Terminated';
        opportunityObj10.Website_Status__c = 'Website Error';
        opportunityObj10.Risk_Level__c = '';
        opportunityObj10.Merchant_Type__c = 'Seller';
        opportunityObj10.BusinessCategory__c = businessCategory.id;
        opportunityObj10.Sub_Category__c = subCategory.id;
        opportunityObj10.Delivery_Duration__c = 23;
        opportunityObj10.Monthly_Expected_Sale__c = 2342;
        opportunityObj10.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj10.MAF_Status__c = 'Received';
        opportunityObj10.Agreement_Status__c='Pending';
        opportunityObj10.Document_Status__c='Pending';
        opportunityObj10.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj10.Bank_Verification_Status__c = 'Success';
        opportunityObj10.LOB_Status__c='Pending';
        opportunityObj10.Prod_Merchant_Id__c = 2345681;
        opportunityObj10.Settlement_Status__c='Active';
        opportunityObj10.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj10.Blacklist__c = true;
        opportunityObj10.Business_Entity__c =entityObj.Id;
        opportunityObj10.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj10.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj10.Campaign_Name__c = 'Payout-Sales';
        insert opportunityObj10;
        oppList.add(opportunityObj10);
        
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        /*Opportunity opportunityObj11 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj11.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj11.stageName = 'Terminated';
        opportunityObj11.Website_Status__c = 'Website Error';
        opportunityObj11.Risk_Level__c = '';
        opportunityObj11.Merchant_Type__c = 'Seller';
        opportunityObj11.BusinessCategory__c = businessCategory.id;
        opportunityObj11.Sub_Category__c = subCategory.id;
        opportunityObj11.Delivery_Duration__c = 23;
        opportunityObj11.Monthly_Expected_Sale__c = 2342;
        opportunityObj11.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj11.MAF_Status__c = 'Received';
        opportunityObj11.Agreement_Status__c='Pending';
        opportunityObj11.Document_Status__c='Pending';
        opportunityObj11.Activation_Status_Onboarding__c='ME Code Activated';
        opportunityObj11.Bank_Verification_Status__c = 'Success';
        opportunityObj11.LOB_Status__c='Pending';
        opportunityObj11.Prod_Merchant_Id__c = 2345680;
        opportunityObj11.Settlement_Status__c='Active';
        opportunityObj11.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj11.Blacklist__c = true;
        opportunityObj11.Business_Entity__c =entityObj.Id;
        opportunityObj11.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj11.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj11.Campaign_Name__c = 'Enterprise-Hunting';
        insert opportunityObj11;
        oppList.add(opportunityObj11);*/
        
        /*Opportunity opportunityObj12 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj12.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj12.stageName = 'Terminated';
        opportunityObj12.Website_Status__c = 'Website Error';
        opportunityObj12.Prod_Merchant_Id__c = 2345680;
        opportunityObj12.Settlement_Status__c='Active';
        opportunityObj12.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj12.Blacklist__c = false;
        opportunityObj12.Business_Entity__c =entityObj.Id;
        opportunityObj12.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj12.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj12.Campaign_Name__c = 'Enterprise-Farming';
        insert opportunityObj12;
        oppList.add(opportunityObj12);*/
        
        /*Opportunity opportunityObj13 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj13.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj13.stageName = 'Terminated';
        opportunityObj13.Website_Status__c = 'Website Error';
        opportunityObj13.Prod_Merchant_Id__c = 2345680;
        opportunityObj13.Settlement_Status__c='Active';
        opportunityObj13.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj13.Blacklist__c = false;
        opportunityObj13.Business_Entity__c =entityObj.Id;
        opportunityObj13.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj13.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj13.Campaign_Name__c = 'Inbound-Contact-Center';
        insert opportunityObj13;
        oppList.add(opportunityObj13);*/
        
        //insert oppList;
        
        OpportunityTriggerHandler.sendSettlementStatusToMCare(oppIdSet, producerNameSet);
        OpportunityTriggerHandler.deleteWebsitePages(oppList);
		// OpportunityTriggerHandler.justIncrement2();        
        
        /*Opportunity opportunityObj14 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj14.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        opportunityObj14.stageName = 'Terminated';
        opportunityObj14.Website_Status__c = 'Website Error';
        opportunityObj14.Prod_Merchant_Id__c = 2345680;
        opportunityObj14.Settlement_Status__c='Active';
        opportunityObj14.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj14.Blacklist__c = false;
        opportunityObj14.Business_Entity__c =entityObj.Id;
        opportunityObj14.Agent_Details__c='Shivdeep test - 7877002681';
        opportunityObj14.Risk_Type_Multi_Select__c = 'Bank Detail';
        opportunityObj14.Campaign_Name__c = 'Partnership-Conversions-Insta-Wix';
        insert opportunityObj14;*/
        
        
        Test.stopTest();
    }
 
   @isTest
    public static void testSendRetryFailedEmail() {
        String merchantId = '12345'; // Replace with the actual merchant ID
        String responseBody = 'Failed response'; // Replace with the actual response body
        Test.startTest();
        OpportunityTriggerHandler.sendRetryFailedEmail(merchantId, responseBody);        
        Test.stopTest();
    }
}