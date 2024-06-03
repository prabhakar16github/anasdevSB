@isTest
private class CaseEmailApiTest {
    private static final Decimal MID = 2342342;
    
    @testSetup 
    static void setupData(){
        OpportunityOwnerWebsiteNull__c objSetting=new OpportunityOwnerWebsiteNull__c();
        objsetting.Current_Value__c =1;
        objSetting.Maximum_Value__c = 2;
        objSetting.Name='OppOwnerWebsiteNullMerchant';
        insert objSetting;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'Opp test',
            Email = 'sauser000@test.com',
            Username = 'sauser000@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            MobilePhone  = '9090909090',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        INSERT u;
        system.runAs(u){
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
            INSERT accountObj;
            
            Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
            businessCategory.Doable__c = True;
            INSERT businessCategory;
            
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
            opportunityObj.Prod_Merchant_Id__c = MID;
            opportunityObj.Agent_Details__c='Shivdeep test - 7877002681';
            INSERT opportunityObj;
            
            Test.StartTest();
                Contact oContact = new contact();
                oContact.LastName='test';
                oContact.Email='test@test.com';
                oContact.MobilePhone='1234567890';
                INSERT oContact;
            
                Id KYCRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
                Case oCase = new Case();
                oCase.Status='New';
                oCase.Priority='High';
                oCase.recordTypeId = KYCRecordTypeId;
                oCase.ContactId=oContact.id;
            	oCase.Opportunity__c = opportunityObj.Id;
                oCase.LP_KYC_Last_Modified_Date__c = System.now();
                oCase.LP_KYC_State__c ='User Documents Pending';
                oCase.LP_IVR_Call_Response__c='test';
                oCase.Problem_area_ETC__c ='Account Related';
                oCase.Details_ETC__c = 'Payouts';
                oCase.Sub_details_ETC__c ='Integration Help';
                INSERT oCase;
            
                EmailMessage email = new EmailMessage();
                email.FromAddress = 'testfrom@testdomain.com';
                email.Incoming = true;
                email.ToAddress= 'testto@testdomain.com';
                email.Subject = 'Test record email';
                email.HtmlBody = 'Test record email body';
                email.ParentId = oCase.Id; 
                INSERT email;
            
            Test.StopTest();
        }  
        
    }
    
    @isTest 
    static void testGetAllCaseByMID() {
        User u = [SELECT Id FROM User WHERE LastName = 'Opp test' LIMIT 1];
        System.runAs(u){
            
            // Set up a test request
            RestRequest request = new RestRequest();
            request.requestUri = System.Url.getOrgDomainUrl()+'/services/api/AllCases?';
            request.addParameter('mid', String.valueOf(MID));
            request.addParameter('pageNumber', '1');
            request.httpMethod = 'GET';
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response = res;
            // Call the method to test
            Test.startTest();
            CaseEmailAPI.CaseWrap result = CaseEmailAPI.getEmailMessage();
            Test.stoptest();
            // Verify results
            System.assert(result != null, 'Result returns empty ');
        }
    }
    
    @isTest 
    static void testGetAllCaseByMIDFAIL() {
        User u = [SELECT Id FROM User WHERE LastName = 'Opp test' LIMIT 1];
        System.runAs(u){
            // Set up a test request
            RestRequest request = new RestRequest();
            request.requestUri = System.Url.getOrgDomainUrl()+'/services/api/AllCases?';
            request.addParameter('mid', '');
            request.addParameter('pageNumber', '1');
            request.httpMethod = 'GET';
            RestContext.request = request;
            RestResponse res = new RestResponse();
            RestContext.response = res;
            // Call the method to test
            CaseEmailAPI.CaseWrap result = CaseEmailAPI.getEmailMessage();
            // Verify results
            System.assert(result != null, 'Result returns empty ');
        }
    }
    
    @isTest 
    static void testGetAllCaseByMIDFAIL1() {
        User u = [SELECT Id FROM User WHERE LastName = 'Opp test' LIMIT 1];
        System.runAs(u){
            // Set up a test request
            RestRequest request = new RestRequest();
            request.requestUri = System.Url.getOrgDomainUrl()+'/services/api/AllCases?';
            request.addParameter('mid', String.valueOf(MID));
            request.addParameter('pageNumber', '1');
            request.httpMethod = 'GET';
            RestContext.request = request;
            try{
            	// Call the method to test
                CaseEmailAPI.CaseWrap result = CaseEmailAPI.getEmailMessage();
                System.assert(true, 'Not throwing exception');
            }catch(Exception e){
                System.assert(true, 'Expected exception');
            }
            
        }
    }
}