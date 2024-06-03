@istest 
public class UpdateCareServiceTracker {
    public static Contact ocontact;
    public static Case merchantCase;
    public static Case buyerCase;
    public static Account oAccount;
    
    /*@testSetup
    public static void setup1(){
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '44444444';
        insert oContact; 
        
        /*merchantCase=new Case();
        merchantCase.ContactId=oContact.id;
        merchantCase.AccountId=oAccount.id;
        merchantCase.Status='Pending';
        merchantCase.LP_sub_status__c='Waiting On Merchant';
        merchantCase.Priority='high';
        merchantCase.Origin = 'App';
        merchantCase.Identifier__c = '3295-15e8-02fc45e7-270e-b388e09d554a';
        merchantCase.LP_Transaction_status__c='Success';
        merchantCase.LP_Transaction_ID__c='65656';
        merchantCase.LP_Business_Vertical__c='LazyPay';
        merchantCase.LP_Category__c='BNPL';
        merchantCase.LP_Issue__c = 'What is LazyPay?';
        merchantCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert merchantCase;*/
        
       /* buyerCase=new Case();
        buyerCase.ContactId=oContact.id;
        buyerCase.AccountId=oAccount.id;
        buyerCase.Status='Pending';
        buyerCase.LP_sub_status__c='Waiting On Buyer';
        buyerCase.Priority='high';
        buyerCase.Origin = 'App';
        buyerCase.Identifier__c = '3295-15e8-02fc45e7-270e-b388e09d664a';
        buyerCase.LP_Transaction_status__c='Success';
        buyerCase.LP_Transaction_ID__c='6565677';
        buyerCase.LP_Business_Vertical__c='Payu Money';
        buyerCase.LP_Category__c='BNPL';
        buyerCase.LP_Issue__c = 'What is LazyPay?';
        buyerCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
        insert buyerCase;
        
    }*/
    
   /* @isTest
    public static void MCServiceMethod1(){
        
        Test.startTest();
        Case mcCase = [select id,RecordTypeId,LP_Issue__c,LP_Business_Vertical__c,LP_Category__c,LP_sub_status__c from case limit 1];
        system.debug('####### '+mccase);
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);   
      	updateCareService.createCaseAndContact('{\"Attachment\":[{\"type\":\"image/jpeg\",\"name\":\"yellow-poisonous-frog-image.jpg\",\"url\":\"https://onecare.blob.core.windows.net/onecare/B043PO-vzxIXqqN0gbGn6.jpg\"}],\"Status\":\"CLOSED\",\"Identifier\":\"3295-15e8-02fc45e7-270e-b388e09d554a\",\"Rating\":4,\"RatingValue\":\"Good Experience\",\"FeedbackValue\":\"\",\"Comment\":\"You can initiate a refund from PayUmoney dashboard in the following link  https://www.payumoney.com/merchant-dashboard/#/transactions    <Watch Video> <https://www.youtube.com/watch?v=ZJHhGrb6geE>to see more details:\"}');
         updateCareService.createCaseAndContact('{"TicketId":"IS7800138824","Category":"PayU Money","Issue_description":"test","MerchantID":"29010166","MerchantBusinessType":"LongTail","MerchantType":"PG Merchant","Issue":"Technical integration help","SubIssue":"Other issue","AggregatorId":null,"Attachment":[],"MerchantName":"Ak test1","Case_Origin":"Web","ChildAggregatorID":null,"Email":"11.shivdeep.yadav@payutest.in","Business_Vertical":"PayU Money","SubCategory":"","Mobile":"8826991161","UUID":"11e9-ba88-842c7ec0-879d-024241c0a2e9","RecordTypeName":"MerchantCare","secondaryMobile":"8826991161","secondaryEmail":"testAk1@payutest.in}');                                      
        Test.stopTest();
    }*/
    
    
   // public static Contact ocontact;
    public static Case oCase;
   // public static Account oAccount;
   /* 
    public static void LoadData()
    { 
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
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
        oCase.LP_Category__c='LazyPay';
        oCase.LP_Issue__c = 'What is LazyPay?';
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
     //CareService.createCaseAndContact('{\"Customer_Name\":\"testCare4\",\"Email\":\"xy@gmail.com\",\"UUID\":\"44444444\",\"Mobile\":\"+911234567890\",\"PanVerificationStatus\":\"default\",\"Available_Withdrawal_Limit\":456,\"Available_Cash_Limit\":345,\"Nach_Status\":\"default\",\"Customer_Status\":\"Active\",\"MerchantName\":\"test Care4\",\"MerchantID\":\"\",\"KYCState\":\"Under Manual Verification\",\"OnboardingStatus\":\"Nach Initiated\",\"Product_Type\":\"Wallet\",\"Transaction_Date\":\"2019-02-15 12:33:45\",\"Transaction_ID\":\"65656\",\"Transaction_Status\":\"Success\",\"Transaction_Type\":\"\",\"Transaction_Reason\":\"\",\"Transaction_Amount\":8787,\"Case_Origin\":\"App\",\"Business_Vertical\":\"LazyPay\",\"Category\":\"BNPL\",\"SubCategory\":\"\",\"Issue\":\"What is LazyPay?\",\"SubIssue\":\"\",\"Issue_description\":\"\",\"Platform\":\"\",\"IP_Detail\":\"\",\"OS_Version\":\"\",\"App_Version\":\"\",\"Manufacturer\":\"\",\"Model\":\"\",\"Carrier\":\"\",\"Socket_Connection\":\"\",\"Connection_Details\":\"\",\"Permissions_Granted\":\"\",\"Mobile_Browser_Name\":\"\",\"Mobile_Browser_Version\":\"\",\"Browser_Name\":\"\",\"Browser_version\":\"\",\"Attachment\":[{\"name\":\"signature\",\"url\":\"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/4984118867290880393_OSV_SIGNATURE_b3afe02494dc4c3a84ec3f9d35204d6e.jpeg\",\"type\":\"image/jpeg\"},{}]}'); 
   //updateCareService.createCaseAndContact('{\"Customer_Name\":\"testCare4\",\"Email\":\"xy@gmail.com\",\"UUID\":\"4440044444\",\"Mobile\":\"+911234567890\",\"PanVerificationStatus\":\"default\",\"Available_Withdrawal_Limit\":456,\"Available_Cash_Limit\":345,\"Nach_Status\":\"default\",\"Customer_Status\":\"Active\",\"MerchantName\":\"test Care4\",\"MerchantID\":\"\",\"KYCState\":\"Under Manual Verification\",\"OnboardingStatus\":\"Nach Initiated\",\"Product_Type\":\"Wallet\",\"Transaction_Date\":\"2019-02-15 12:33:45\",\"Transaction_ID\":\"65656\",\"Transaction_Status\":\"Success\",\"Transaction_Type\":\"\",\"Transaction_Reason\":\"\",\"Transaction_Amount\":8787,\"Case_Origin\":\"App\",\"Business_Vertical\":\"LazyPay\",\"Category\":\"BNPL\",\"SubCategory\":\"\",\"Issue\":\"What is LazyPay?\",\"SubIssue\":\"\",\"Issue_description\":\"\",\"Platform\":\"\",\"IP_Detail\":\"\",\"OS_Version\":\"\",\"App_Version\":\"\",\"Manufacturer\":\"\",\"Model\":\"\",\"Carrier\":\"\",\"Socket_Connection\":\"\",\"Connection_Details\":\"\",\"Permissions_Granted\":\"\",\"Mobile_Browser_Name\":\"\",\"Mobile_Browser_Version\":\"\",\"Browser_Name\":\"\",\"Browser_version\":\"\",\"Attachment\":[{\"name\":\"signature\",\"url\":\"https://s3.ap-south-1.amazonaws.com/document-prod/userDocuments/4984118867290880393_OSV_SIGNATURE_b3afe02494dc4c3a84ec3f9d35204d6e.jpeg\",\"type\":\"image/jpeg\"},{}]}');  
        Test.stopTest();
    }
    */
     public static void LoadData1()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
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
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.LP_Issue__c = 'What is LazyPay?';
        oCase.Identifier__c='c4a4-b049-98d44427-52fd-40195b4a185f';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.LP_Rating__c = 3;
        insert oCase;
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
        system.assertEquals(1,[select id from Status_SLA__c where case__c=:oCase.Id].size());
        Attachment attach = New Attachment();
        attach.parentId = oCase.Id;
        attach.Body = blob.valueOf('sdvsd');
        attach.Name = 'test 1';
        insert attach;
        
        oCase.Status = 'Re-Open';
        update oCase;
    }
    
    @isTest
    public static void MCServiceMethod(){
        
        
        LoadData1();   
        Test.startTest();       
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"RESOLVED","Identifier":"c4a4-b049-98d44427-52fd-40195b4a185f","Rating":4,"RatingValue":"Good","FeedbackValue":"Courtesy"}');  
        Test.stopTest();
    }
    public static void LoadData2()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Resolved'; 
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'ae7d-904c-d202cc7a-7bbb-9aea3bcffef7';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
        
        
    }
    
    @isTest
    public static void MCChildServiceMethod(){
        LoadData2();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"CLOSED","Identifier":"ae7d-904c-d202cc7a-7bbb-9aea3bcffef7","Rating":3,"RatingValue":"Fair","FeedbackValue":"Courtesy"}');  
        Test.stopTest();
    }
    
    public static void LoadData3()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '666664444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Resolved'; 
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.LP_Issue__c = 'What is LazyPay?';
        oCase.Identifier__c='06ce-04da-e8b01683-12a3-ad3805a079aa';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.LP_Rating__c = 3;
        insert oCase;
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
        system.assertEquals(1,[select id from Status_SLA__c where case__c=:oCase.Id].size());
        Attachment attach = New Attachment();
        attach.parentId = oCase.Id;
        attach.Body = blob.valueOf('sdvsd');
        attach.Name = 'test 1';
        insert attach;
        
        oCase.Status = 'Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        oCase.Comments = 'fwefwev';
        ocase.Is_Parent_Owner_Change__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Is_Violated__c = true;
        update oCase;
        
    }
    
        
        
    @isTest
    public static void MCParentServiceMethod(){
        LoadData3();   
        Test.startTest();
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);        
        updateCareService.createCaseAndContact('{"Attachment":[{"type":"image/jpeg","name":"PayU Logo.jpg","url":"https://testcarestorage.blob.core.windows.net/onecare/DSfJEbCap9qPqYnvgIGgB.jpg"}],"Status":"IN_PROGRESS","Issue_description":"Attaching the statement.","Identifier":"06ce-04da-e8b01683-12a3-ad3805a079aa"}');  
        Test.stopTest();
    }
    
    public static void LoadData4()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Pending'; 
        oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
        
        Case childCase = New Case();
        childCase.Status = 'New';
        childCase.ContactId = oCase.ContactId;
        childCase.Parent_Case__c = oCase.Id;
        childCase.ParentId = oCase.Id;
        childCase.AccountId = oCase.AccountId;
        childCase.Subject = 'seffvrswd';
        //childCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        Id MerchantchildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        childCase.RecordTypeId = MerchantchildCaseRecordTypeId;
        childCase.Is_Violated__c = false;
        insert childCase;
                
        childCase.Status = 'Pending';
        //childCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        childCase.LP_Sub_Status__c = 'Waiting On Merchant';
        childCase.Comments='dscsdc';
        update childCase;
    }
    
    @isTest
    public static void MCChildCasesServiceMethod(){
        LoadData4();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"IN_PROGRESS","Issue_description":"mnbvcxz","Identifier":"b049-98d44427-52fd-40195b4a185f"}');  
        Test.stopTest();
    }
    
    public static void LoadData6()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='New'; 
        //oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Counter__c = 1;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
    }
    
    @isTest
    public static void MCParentCasesServiceStatusNew(){
        LoadData6();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"IN_PROGRESS","Issue_description":"mnbvcxz","Identifier":"b049-98d44427-52fd-40195b4a185f"}');  
        Test.stopTest();
    }
    public static void LoadData7()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Open'; 
        //oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Counter__c = 1;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
    }
    
    @isTest
    public static void MCParentCasesServiceStatusopen(){
        LoadData7();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"IN_PROGRESS","Issue_description":"mnbvcxz","Identifier":"b049-98d44427-52fd-40195b4a185f"}');  
        Test.stopTest();
    }
    
    public static void LoadData8()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Transferred from other teams'; 
        //oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Counter__c = 1;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
    }
    
    @isTest
    public static void MCParentCasesServiceStatusTransfered(){
        LoadData8();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"IN_PROGRESS","Issue_description":"mnbvcxz","Identifier":"b049-98d44427-52fd-40195b4a185f"}');  
        Test.stopTest();
    }
    
    public static void LoadData9()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='No Resolution From Other Teams'; 
        //oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Counter__c = 1;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
    }
    
    @isTest
    public static void MCParentCasesServiceStatusNoResponse(){
        LoadData9();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"IN_PROGRESS","Issue_description":"mnbvcxz","Identifier":"b049-98d44427-52fd-40195b4a185f"}');  
        Test.stopTest();
    }
    
    public static void LoadData10()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Tat Exceeded'; 
        //oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Counter__c = 1;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
    }
    
    @isTest
    public static void MCParentCasesServiceStatusTATexceed(){
        LoadData10();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"IN_PROGRESS","Issue_description":"mnbvcxz","Identifier":"b049-98d44427-52fd-40195b4a185f"}');  
        Test.stopTest();
    }
    public static void LoadData11()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
                
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '2224444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Response received from merchant'; 
        //oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.Identifier__c = 'b049-98d44427-52fd-40195b4a185f';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.TicketId__c = 'AL5498736096';
        oCase.LP_Issue__c = 'New Product inquiry';
        oCase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Start_L2_Ticket_Milestone__c = true;
        oCase.Start_Parent_Ticket_Milestone__c = true;
        oCase.Start_L3_Ticket_Milestone__c = true;
        oCase.Counter__c = 1;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        insert oCase;
        
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
    }
    
    @isTest
    public static void MCParentCasesServiceStatusResponse(){
        LoadData11();   
        Test.startTest();        
        updateCareService.createCaseAndContact('{"Attachment":[],"Status":"IN_PROGRESS","Issue_description":"mnbvcxz","Identifier":"b049-98d44427-52fd-40195b4a185f"}');  
        Test.stopTest();
    }
    
    public static void LoadData5()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '666664444477444';
        insert oContact; 
        
        oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='Resolved'; 
        oCase.Priority='high';
        oCase.Origin = 'App';
        oCase.LP_Transaction_status__c='Success';
        oCase.LP_Transaction_ID__c='65656';
        oCase.LP_Business_Vertical__c='PayU Money';
        oCase.LP_Category__c='PayU Money';
        oCase.LP_Issue__c = 'What is LazyPay?';
        oCase.Identifier__c='04da-e8b01683-12a3-ad3805a079aa';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.LP_Rating__c = 3;
        insert oCase;
        
        Status_SLA__c sla = New Status_SLA__c();
        sla.Case__c = oCase.Id;
        insert sla;
        system.assertEquals(1,[select id from Status_SLA__c where case__c=:oCase.Id].size());
        Attachment attach = New Attachment();
        attach.parentId = oCase.Id;
        attach.Body = blob.valueOf('sdvsd');
        attach.Name = 'test 1';
        attach.ContentType = 'image/jpeg';
        insert attach;
        
        oCase.Status = 'Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Buyer';
        oCase.Comments = 'fwefwev';
        ocase.Is_Parent_Owner_Change__c = true;
        oCase.Is_L2_Violated__c = true;
        oCase.Is_L3_Violated__c = true;
        oCase.Is_Violated__c = true;
        update oCase;
        
    }
    
        
        
    @isTest
    public static void MCParentServiceMethod1(){
        LoadData5();   
        
        Attachment attach = New Attachment();
        attach.parentId = oCase.Id;
        attach.Body = blob.valueOf('sdvsd');
        attach.Name = 'test 1';
        attach.ContentType = 'image/jpeg';
        insert attach;
        
        Test.startTest();
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        String tempAttachment = '{"Attachment":[{"type":'+'"'+attach.ContentType+'"'+',"name":'+'"'+attach.Name+'"'+',"url":'+'"'+attach.Body+'"'+'}],"Status":"IN_PROGRESS","Issue_description":"Attaching the statement.","Identifier":"04da-e8b01683-12a3-ad3805a079aa"}';
        System.debug('tempAttachment'+tempAttachment);
        updateCareService.createCaseAndContact(tempAttachment);  
        Test.stopTest();
    }
    
    
    @isTest
    public static void testCatchBlock(){
        updateCareService.createCaseAndContact('Test');
    }
    
}