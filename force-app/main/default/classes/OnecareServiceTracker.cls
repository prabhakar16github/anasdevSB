@istest(seeAllData=false) 
public class OnecareServiceTracker {
    public static Contact ocontact;
    public static Case oCase;
    public static entitlement oEntitlement;
    public static Account oAccount;
    
    public static void LoadData()
    { 
        SalesforceDebugLogInitiator__c  logIntiators = new SalesforceDebugLogInitiator__c(Name = 'DebugLog Initiator',IsShow_Debug_Logs__c =true);
        insert logIntiators;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        LIST <Duplicacy_And_Ownership__mdt> duplicacyOwnerMdt = [SELECT Business_Vertical__c,QueueId__c, Duplicate_Criteria__c, Queue_Name__c,L2_Queue_Id__c,L3_Queue_Id__c, Sub_Vertical__c 
                                FROM Duplicacy_And_Ownership__mdt 
                                WHERE Record_Type_Name__c != NULL];
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '4440044444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Resolved'; 
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='LazyPay';
        oCase.LP_Category__c='PayU Now';
        oCase.LP_Issue__c = 'What is LazyPay?';
        oCase.Problem_area_ETC__c ='Account Related';
        oCase.Details_ETC__c = 'Payouts';
        oCase.Sub_details_ETC__c ='Integration Help';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        insert oCase;
        
        
    }
    
    
    @isTest
    public static void CareServiceMethod(){
        LoadData();   
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                                                       'Complete',
                                                                                       '[{"Name": "sForceTest1"}]',
                                                                                       null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        OneCareService.createCaseAndContact('{\"Customer_Name\":\"testCare4\",\"Email\":\"xy@gmail.com\",\"UUID\":\"4440044444\",\"Mobile\":\"+911234567890\",\"PanVerificationStatus\":\"default\",\"Available_Withdrawal_Limit\":456,\"Available_Cash_Limit\":345,\"Nach_Status\":\"default\",\"Customer_Status\":\"Active\",\"MerchantName\":\"test Care4\",\"MerchantID\":\"\",\"KYCState\":\"Under Manual Verification\",\"OnboardingStatus\":\"Nach Initiated\",\"Product_Type\":\"Wallet\",\"Transaction_Date\":\"2019-02-15 12:33:45\",\"Transaction_ID\":\"65656\",\"Transaction_Status\":\"Success\",\"Transaction_Type\":\"\",\"Transaction_Reason\":\"\",\"Transaction_Amount\":8787,\"Case_Origin\":\"App\",\"Business_Vertical\":\"LazyPay\",\"Category\":\"BNPL\",\"SubCategory\":\"\",\"Issue\":\"What is LazyPay?\",\"SubIssue\":\"\",\"Issue_description\":\"\",\"Platform\":\"\",\"IP_Detail\":\"\",\"OS_Version\":\"\",\"App_Version\":\"\",\"Manufacturer\":\"\",\"Model\":\"\",\"Carrier\":\"\",\"Socket_Connection\":\"\",\"Connection_Details\":\"\",\"Permissions_Granted\":\"\",\"Mobile_Browser_Name\":\"\",\"Mobile_Browser_Version\":\"\",\"Browser_Name\":\"\",\"Browser_version\":\"\",\"Attachment\":[{\"name\":\"signature\",\"url\":\"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/4984118867290880393_OSV_SIGNATURE_b3afe02494dc4c3a84ec3f9d35204d6e.jpeg\",\"type\":\"image/jpeg\"},{}]}');  
        Test.stopTest();
    }
    
    public static void LoadData1()
    { 
        SalesforceDebugLogInitiator__c  logIntiators = new SalesforceDebugLogInitiator__c(Name = 'DebugLog Initiator',IsShow_Debug_Logs__c =true);
        insert logIntiators;
        
        Id bHours = [SELECT Id,Name 
                     FROM BusinessHours 
                     where name IN ('OneCare Business Hour')].Id;
        
        Id entitlementProcessId = [select Id
                               from slaprocess 
                               where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].Id;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '4444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Resolved'; 
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Expected_Closure_Date__c=Date.today()+5;
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.LP_Issue__c = 'What is LazyPay?';
        oCase.Problem_area_ETC__c ='Account Related';
        oCase.Details_ETC__c = 'Payouts';
        oCase.Sub_details_ETC__c ='Integration Help';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        oEntitlement = new Entitlement();
        oEntitlement.Name='Parent Ticket Entitlement Process';
        oEntitlement.AccountId= oAccount.id;
        oEntitlement.BusinessHoursId = bHours;
        oEntitlement.SlaProcessId= entitlementProcessId;
        oEntitlement.StartDate=Date.Today();
        insert oEntitlement;
        
    }
    @isTest
    public static void MCServiceMethod(){
        LoadData1();   
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                                                       'Complete',
                                                                                       '[{"Name": "sForceTest1"}]',
                                                                                       null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        OneCareService.createCaseAndContact('{\"TicketId\":\"UQ5934236030\",\"Category\":\"PayU Money\",\"Issue_description\":\"testst\",\"MerchantID\":null,\"MerchantType\":\"Potential Lead\",\"Issue\":\"New Product inquiry\",\"SubIssue\":\"Payment plugin for excel\",\"AggregatorId\":null,\"Attachment\":[{\"type\":\"image/jpeg\",\"name\":\"yellow-poisonous-frog-image.jpg\",\"url\":\"https://onecare.blob.core.windows.net/onecare/B043PO-vzxIXqqN0gbGn6.jpg\"}],\"MerchantName\":\"eitika\",\"Case_Origin\":\"Web\",\"ChildAggregatorID\":null,\"Email\":\"eett@dfh.com\",\"Business_Vertical\":\"PayU Money\",\"SubCategory\":\"\",\"Mobile\":\"9718960069\",\"RecordTypeName\":\"MerchantCare\"}');  
        Test.stopTest();
    }
    @isTest
    public static void MCServiceMethod2(){
        LoadData1();   
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                                                       'Complete',
                                                                                       '[{"Name": "sForceTest1"}]',
                                                                                       null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        OneCareService.createCaseAndContact('{\"TicketId\":\"UQ5934236030\",\"Category\":\"PayU Money\",\"Issue_description\":\"testst\",\"MerchantID\":null,\"MerchantType\":\"Potential Lead\",\"Issue\":\"New Product inquiry\",\"SubIssue\":\"Accept International Payment\",\"AggregatorId\":null,\"Attachment\":[{\"type\":\"image/jpeg\",\"name\":\"yellow-poisonous-frog-image.jpg\",\"url\":\"https://onecare.blob.core.windows.net/onecare/B043PO-vzxIXqqN0gbGn6.jpg\"}],\"MerchantName\":\"eitika\",\"Case_Origin\":\"Web\",\"ChildAggregatorID\":null,\"Email\":\"eett@dfh.com\",\"Business_Vertical\":\"PayU Money\",\"SubCategory\":\"\",\"Mobile\":\"9718960069\",\"RecordTypeName\":\"MerchantCare\"}');  
        Test.stopTest();
    }
    @isTest
    public static void MCServiceMethod3(){
        LoadData1();   
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                                                       'Complete',
                                                                                       '[{"Name": "sForceTest1"}]',
                                                                                       null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        OneCareService.createCaseAndContact('{\"TicketId\":\"UQ5934236030\",\"Category\":\"PayU Money\",\"Issue_description\":\"testst\",\"MerchantID\":null,\"MerchantType\":\"\",\"Issue\":\"New Product inquiry\",\"SubIssue\":\"Accept International Payment\",\"AggregatorId\":null,\"Attachment\":[{\"type\":\"image/jpeg\",\"name\":\"yellow-poisonous-frog-image.jpg\",\"url\":\"https://onecare.blob.core.windows.net/onecare/B043PO-vzxIXqqN0gbGn6.jpg\"}],\"MerchantName\":\"eitika\",\"Case_Origin\":\"Web\",\"ChildAggregatorID\":null,\"Email\":\"eett@dfh.com\",\"Business_Vertical\":\"PayU Money\",\"SubCategory\":\"\",\"Mobile\":\"9718960069\",\"RecordTypeName\":\"MerchantCare\"}');  
        Test.stopTest();
    }
    public static void LoadData2()
    { 
        SalesforceDebugLogInitiator__c  logIntiators = new SalesforceDebugLogInitiator__c(Name = 'DebugLog Initiator',IsShow_Debug_Logs__c =true);
        insert logIntiators;
        
        Id queueId = [SELECT Id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        Id bHours = [SELECT Id,Name 
                     FROM BusinessHours 
                     where name IN ('OneCare Business Hour')].Id;
        
        Id entitlementProcessId = [select Id
                               from slaprocess 
                               where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].Id;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '4444477444';
        insert oContact; 
        
        oEntitlement = new Entitlement();
        oEntitlement.Name='Parent Ticket Entitlement Process';
        oEntitlement.AccountId = oAccount.id;
        oEntitlement.BusinessHoursId = bHours;
        oEntitlement.SlaProcessId = entitlementProcessId;
        oEntitlement.StartDate = Date.Today();
        insert oEntitlement;
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.EntitlementId=oEntitlement.id;
        oCase.Status='Resolved'; 
        oCase.Priority='high';
        oCase.Origin = 'Web';
        oCase.Expected_Closure_Date__c=Date.today()+5;
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.LP_Sub_Issue__c='Accept EMI payments';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.Problem_area_ETC__c ='Account Related';
        oCase.Details_ETC__c = 'Payouts';
        oCase.Sub_details_ETC__c ='Integration Help';
        insert oCase;
    }
    
    @isTest
    public static void MCServiceMethod4(){
        LoadData2();   
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                                                       'Complete',
                                                                                       '[{"Name": "sForceTest1"}]',
                                                                                       null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        OneCareService.createCaseAndContact('{\"TicketId\":\"UQ5934236030\",\"Category\":\"PayU Money\",\"Issue_description\":\"testst\",\"MerchantID\":null,\"MerchantType\":\"Potential Lead\",\"Issue\":\"New Product inquiry\",\"SubIssue\":\"Accept EMI payments\",\"AggregatorId\":null,\"Attachment\":[{\"type\":\"image/jpeg\",\"name\":\"yellow-poisonous-frog-image.jpg\",\"url\":\"https://onecare.blob.core.windows.net/onecare/B043PO-vzxIXqqN0gbGn6.jpg\"}],\"MerchantName\":\"eitika\",\"Case_Origin\":\"Web\",\"ChildAggregatorID\":null,\"Email\":\"xy@gmail.com\",\"Business_Vertical\":\"PayU Money\",\"SubCategory\":\"\",\"Mobile\":\"+911234567890\",\"RecordTypeName\":\"MerchantCare\"}');  
        Test.stopTest();
    }
}