@isTest
public class oneCareProcessHandlerTracker  {
    
    @testSetup
    public static void createCustomSetting(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        test.startTest();
        insert logIntiator;
        
         User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        System.debug('u>>>'+u);
        system.runAs(u){
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Case', true);
        insert triggerSwitchObj ;
        
        CaseRiskAssignment__c custSett = new CaseRiskAssignment__c();
        custSett.Issue__c = 'Document Related';
        custSett.SubIssue__c = 'Documents Rejected';
        custSett.Amazon_MID__c = '654321';
        custSett.Amazon_Email_Domain__c = '@test';
        insert custSett;
        
        test.stopTest();
        
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='StatusSLA';
        insert osetting;
        
    }
 }   
    public static testMethod void testDataFor_Opp1(){
        User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
        system.runAs(u){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'Onecare Publisher Log';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        test.startTest();
        insert logIntiator;
        
        Platform__c plm = New Platform__c();
        plm.Name = 'PayU Money';
        plm.active__c = true;
        insert plm;
        
        Product__c prod = New Product__c();
        prod.Name = 'PayU Money';
        prod.Active__c = true;
        prod.Platform__c = plm.Id;
        insert prod;
        
        Account acc = New Account();
        acc.Name='Test Acc';
        insert acc;
            
        Legal_Entity__c  le = New Legal_Entity__c();
        le.Legal_Entity_Name__c  = 'Merchant';
        le.Email_Domain__c  = 'merchant';
        Insert le;
        
        Opportunity opp = New Opportunity();
        opp.Name='test1';
        opp.Email__c='test@test.com';
        opp.AccountId=acc.Id;
        opp.StageName='MAF';
        opp.CloseDate=Date.today();
        opp.Prod_Merchant_Id__c = 123456;
        opp.Lead_Created_date__c = Date.today();
        opp.OwnerId = Userinfo.getUserId();
        opp.Product__c = prod.Id;
        opp.Business_Origin__c = 'SMB-ENT';
        opp.Settlement_Status__c = 'Active';
        opp.Lead_Business_Name__c = 'Merchant';
        insert opp;
        
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.Email='test2@test.com';
        oContact.MobilePhone='1236567890';
        oContact.AccountId=acc.Id;
        insert oContact;
        
        /*User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchant Care Child'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        System.debug('u>>>'+u);*/
        
        Case etcCase=new Case();
        etcCase.Status='New';
        etcCase.Priority='High';
        etcCase.SuppliedEmail = 'shivani@merchant.com';
        etcCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_to_case_Parent').getRecordTypeId();
        etcCase.ContactId=oContact.id;
        etcCase.AccountId = acc.Id;
        etcCase.Merchant_Id__c = '123456';
        etcCase.LP_Issue__c = 'Document Related';
        etcCase.LP_Sub_Issue__c = 'Documents Rejected'; 
        insert etcCase;
        
        etcCase.Comments = 'test';
        update etcCase;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.ContactId=oContact.id;
        oCase.AccountId = acc.Id;
        oCase.Merchant_Id__c = '123456';
        oCase.LP_Business_Vertical__c = 'PayU Biz';
        oCase.LP_Issue__c = 'New Product Inquiry';
        oCase.LP_Sub_Issue__c = 'Payment Plugin For Excel';
        oCase.SuppliedEmail = 'abc@amazon.com';
        oCase.Opportunity__c = opp.id;
        //oCase.OwnerId = [Select id, developerName from group where type = 'queue' and developerName = 'Non_Mapped_KAM_Merchants_Payout' limit 1].id;
        insert oCase;
        
        Status_SLA__c  sla = new Status_SLA__c();
        sla.Case__c = oCase.Id;
        sla.OneCare_LOB_Name__c = oCase.LOB_Name__c;
        insert sla;
        
        oCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Merchant_Maintenance' and group.type='Queue' LIMIT 1].userorgroupid;
        update oCase;
        oCase.Status = 'Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        oCase.Comments = 'kjbjkb';
        update oCase;
        
        oCase.LP_Issue__c = 'Technical integration help';
        update oCase;
        test.stopTest();
        
        }     
    }   
    
    public static testMethod void testDataFor_Opp2(){
        User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
        system.runAs(u){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'Onecare Publisher Log';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        test.startTest();
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name='Test Acc';
        insert acc;
        
        Platform__c plm = New Platform__c();
        plm.Name = 'PayU Money';
        plm.active__c = true;
        insert plm;
        
        Product__c prod = New Product__c();
        prod.Name = 'PayU Money';
        prod.Active__c = true;
        prod.Platform__c = plm.Id;
        insert prod;
        
        Opportunity opp2 = New Opportunity();
        opp2.Name='test1';
        opp2.Email__c='test@test.com';
        opp2.AccountId=acc.Id;
        opp2.StageName='MAF';
        opp2.CloseDate=Date.today();
        opp2.Prod_Merchant_Id__c = 654321;
        opp2.Lead_Created_date__c = null;
        opp2.Product__c = prod.Id;
        opp2.On_Post_Risk_Hold__c = 'Y';
        opp2.On_Pre_Risk_Hold__c = 'Y';
        opp2.On_OB_Hold__c = 'Y';
        insert opp2;
        
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.Email='test2@test.com';
        oContact.MobilePhone='1236567890';
        oContact.AccountId=acc.Id;
        insert oContact;
        
        Case case2 =new Case();
        case2.Status='New';
        case2.Priority='High';
        case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        case2.ContactId=oContact.id;
        case2.AccountId = acc.Id;
        case2.Merchant_Id__c = '654321';
        case2.LP_Issue__c = 'Document Related';
        case2.LP_Sub_Issue__c = 'Documents Rejected';
        //case2.OwnerId = [select id from group where DeveloperName = 'Waiting_On_PayUSMB_Sales' and type = 'Queue' limit 1].id; 
        insert case2;
        
        case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_PayUSMB_Sales' and group.type='Queue' LIMIT 1].userorgroupid;
        update case2;
        
        case2.Status = 'Pending';
        case2.LP_Sub_Status__c = 'Waiting On Merchant';
        case2.Comments = 'test';
        update case2;
        
        case2.Status = 'Response received from merchant';
        case2.LP_Sub_Status__c ='';
        update case2;
        
        case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='payu_Money' and group.type='Queue' LIMIT 1].userorgroupid;
        update case2;
        
        test.stopTest();
        
}
    }
 
    public static testMethod void testDataFor_Opp3(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'Onecare Publisher Log';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    insert logIntiator;
    
    Account acc = New Account();
    acc.Name='Test Acc';
    acc.Document_Status__c = 'Docs Approved';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    //opp2.OwnerId = Userinfo.getUserId();
    opp2.Website_Status__c = 'Verification in Process';
    opp2.Lead_Created_date__c = null;
    opp2.Product__c = prod.Id;
    opp2.Settlement_Status__c = 'Risk Hold';
    opp2.On_Post_Risk_Hold__c = 'Y';
    opp2.On_Pre_Risk_Hold__c = 'Y';
    opp2.On_OB_Hold__c = 'Y';
    insert opp2;
    
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case1 =new Case();
    case1.Status='New';
    case1.Priority='High';
    case1.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case1.ContactId=oContact.id;
    case1.AccountId = acc.Id;
    case1.Merchant_Id__c = '654321';
    case1.LP_Issue__c = 'New Product Inquiry';
    case1.LP_Sub_Issue__c = 'Accept International Payment';
    insert case1;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Issue__c = 'Website Approval Pending';
    case2.LP_Sub_Issue__c = 'Website Approval Pending';
    insert case2;
        
    test.startTest();
    case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Pre_Onboarding_Risk' and group.type='Queue' LIMIT 1].userorgroupid;
    update case2;
    
    case2.Status = 'Pending';
    case2.LP_Sub_Status__c = 'Waiting On Merchant';
    case2.Comments = 'test';
    update case2;
    
    case2.Status = 'Response received from merchant';
    case2.LP_Sub_Status__c ='';
    update case2;
    
    case2.Status = 'Pending';
    case2.LP_Sub_Status__c = 'Waiting On Merchant';
    case2.Comments = 'test';
    update case2;
    
    case2.Status = 'Response received from merchant';
    case2.LP_Sub_Status__c ='';
    update case2;
    
    case2.Status = 'Resolved';
    case2.Problem_area_ETC__c ='Account Related';
    case2.Details_ETC__c = 'Payouts';
    case2.Sub_details_ETC__c ='Integration Help';
    update case2;
    
    test.stopTest();
}
    }
    
public static testMethod void testDataFor_Opp4(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'Onecare Publisher Log';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    
    Account acc = New Account();
    acc.Name='Test Acc';
    acc.Document_Status__c = 'Pending';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    opp2.OwnerId = Userinfo.getUserId();
    opp2.Website_Status__c = 'Pending';
    opp2.Lead_Created_date__c = Date.today();
    opp2.Product__c = prod.Id;
    opp2.On_Post_Risk_Hold__c = 'Y';
    opp2.On_Pre_Risk_Hold__c = 'Y';
    opp2.On_OB_Hold__c = 'Y';
    insert opp2;
    
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Business_Vertical__c = 'PayU Money';
    case2.LP_Issue__c = 'Website Approval Pending';
    case2.LP_Sub_Issue__c = 'Website Approval Pending';
    
    insert case2;
    test.stopTest();
    }
}


public static testMethod void testDataFor_Opp5(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'Onecare Publisher Log';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    
    Account acc = New Account();
    acc.Name='Test Acc';
    acc.Document_Status__c = 'Pending';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    opp2.OwnerId = Userinfo.getUserId();
    opp2.Website_Status__c = 'Verification in Process';
    opp2.Lead_Created_date__c = Date.today();
    opp2.Product__c = prod.Id;
    opp2.On_Post_Risk_Hold__c = 'Y';
    opp2.On_Pre_Risk_Hold__c = 'Y';
    opp2.On_OB_Hold__c = 'Y';
    insert opp2;
    
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Issue__c = 'Website Approval Pending';
    case2.LP_Sub_Issue__c = 'Website Approval Pending';
    
    insert case2;
    test.stopTest();
    }
}


public static testMethod void testDataFor_Opp6(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'Onecare Publisher Log';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    
    Account acc = New Account();
    acc.Name='Test Acc';
    acc.Document_Status__c = 'Pending';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;        
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    opp2.OwnerId = Userinfo.getUserId();
    opp2.Website_Status__c = 'Verification in Process';
    opp2.Lead_Created_date__c = Date.today()-80;
    opp2.Product__c = prod.Id;
    opp2.On_Post_Risk_Hold__c = 'Y';
    opp2.On_Pre_Risk_Hold__c = 'Y';
    opp2.On_OB_Hold__c = 'Y';
    insert opp2;
    
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Issue__c = 'Website Approval Pending';
    case2.LP_Sub_Issue__c = 'Website Approval Pending';
    
    insert case2;
    test.stopTest();
}
}

public static testMethod void testDataFor_Opp7(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'Onecare Publisher Log';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    //test.startTest();
    insert logIntiator;
    
    Account acc = New Account();
    acc.Name='Test Acc';
    insert acc;

    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    opp2.Key_Assigned_Manager__c = system.label.Farming_Team_Member;
    opp2.Key_Assigned_Manager_Segment__c = 'Silver Inactive';
    opp2.Lead_Created_date__c = null;
    opp2.Product__c = prod.id;
    insert opp2;
    
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Issue__c = 'Profile completion Issue';
    case2.LP_Sub_Issue__c = 'Business Details completion issue';
    case2.OwnerId = [Select Id from group where Group.DeveloperName='payu_money' and group.type='Queue' LIMIT 1].id;
    insert case2;
    
    /*case2.OwnerId =  [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Web_Integration' and group.type='Queue' LIMIT 1].userorgroupid;
    update case2;*/
    test.startTest();
    case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='payu_Money' and group.type='Queue' LIMIT 1].userorgroupid;
    update case2;
    
    case2.Status = 'Pending';
    case2.LP_Sub_Status__c = 'Waiting On Merchant';
    case2.Comments='ewfwef'; 
    update case2;
    
    case2.Status = 'Response received from merchant';
    case2.LP_Sub_Status__c = '';
    update case2;
    
    case2.Status = 'Pending';
    case2.LP_Sub_Status__c = 'Waiting On Merchant';
    case2.Comments='eawef'; 
    update case2;
    
    case2.Status = 'Response received from merchant';
    case2.LP_Sub_Status__c = '';
    update case2;
    
    case2.Status = 'Resolved';
    case2.Problem_area_ETC__c ='Account Related';
    case2.Details_ETC__c = 'Payouts';
    case2.Sub_details_ETC__c ='Integration Help';
    update case2;
    
    test.stopTest();
}
}

public static testMethod void testDataFor_Opp8(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'Onecare Publisher Log';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    //test.startTest();
    insert logIntiator;
    
    Account acc = New Account();
    acc.Name='Test Acc';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    opp2.OwnerId = Userinfo.getUserId();
    opp2.Lead_Created_date__c = null;
    opp2.Product__c = prod.Id;
    insert opp2;
    
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Issue__c = 'Profile completion Issue';
    case2.LP_Sub_Issue__c = 'Business Details completion issue';
    case2.OwnerId = [Select Id from group where Group.DeveloperName='payu_money' and group.type='Queue' LIMIT 1].id;
    insert case2;
    
    test.startTest();
    case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='payu_Money' and group.type='Queue' LIMIT 1].userorgroupid;
    update case2;
    
  	case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Post_Onboarding_Risk' and group.type='Queue' LIMIT 1].userorgroupid;
    update case2;
    
    case2.Status = 'Resolved';
    case2.Comments = 'test';
    case2.Problem_area_ETC__c ='Account Related';
    case2.Details_ETC__c = 'Payouts';
    case2.Sub_details_ETC__c ='Integration Help';
    update case2;
    
    case2.Status = 'Re-Open';
    update case2;
    
    case2.Status = 'Resolved';
    case2.Comments = 'test';
    update case2;
    
    case2.Status = 'Re-Open';
    update case2;
    
    /*case2.Status = 'Closed';
    case2.Comments = 'Auto Closed';
    update case2;*/
    
    test.stopTest();
}
}

/*public static testMethod void testDataFor_Opp9(){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'Onecare Publisher Log';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    
    Account acc = New Account();
    acc.Name='Test Acc';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Now';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Now';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    opp2.OwnerId = userInfo.getUserId() ;
    opp2.Lead_Created_date__c = null;
    opp2.Product__c = prod.Id;
    insert opp2;
    
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Issue__c = 'Document Related';
    case2.LP_Sub_Issue__c = 'Documents Rejected';
    case2.MerchantBucket__c = 'Risk hold for PP & TP merchants';
    insert case2;
    
    case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Post_Onboarding_Risk' and group.type='Queue' LIMIT 1].userorgroupid;
    update case2;
    
    case2.Status = 'Pending';
    case2.LP_Sub_Status__c = 'Waiting On Production Support';
    case2.Comments = 'test';
    update case2;
    
    case2.Status = 'Response Received from Other Teams';
    case2.LP_Sub_Status__c ='';
    update case2;
    
    case2.Status = 'Resolved';
    case2.Comments = 'test';
    update case2;
    
    test.stopTest();
}*/
    
    public static testMethod void testDataFor_Opp10(){
        User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
        system.runAs(u){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'Onecare Publisher Log';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        test.startTest();
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name='Test Acc';
        insert acc;
        
        Platform__c plm = New Platform__c();
        plm.Name = 'PayU Biz';
        plm.active__c = true;
        insert plm;
        
        Product__c prod = New Product__c();
        prod.Name = 'PayU Biz';
        prod.Active__c = true;
        prod.Platform__c = plm.Id;
        insert prod;
        
        Opportunity opp2 = New Opportunity();
        opp2.Name='test1';
        opp2.Email__c='test@test.com';
        opp2.AccountId=acc.Id;
        opp2.StageName='MAF';
        opp2.CloseDate=Date.today();
        opp2.Prod_Merchant_Id__c = 654321;
        opp2.OwnerId = userInfo.getUserId() ;
        opp2.Lead_Created_date__c = null;
        opp2.Product__c = prod.Id;
        opp2.Business_Origin__c = 'SMB-ENT';
        opp2.Key_Assigned_Manager__c = userInfo.getUserId();   
        insert opp2;
        
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.Email='test2@test.com';
        oContact.MobilePhone='1236567890';
        oContact.AccountId=acc.Id;
        insert oContact;
        
        Case case2 =new Case();
        case2.Status='New';
        case2.Priority='High';
        case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        case2.ContactId=oContact.id;
        case2.AccountId = acc.Id;
        case2.Merchant_Id__c = '654321';
        case2.LP_Business_Vertical__c = 'PayU Biz';
        case2.LP_Issue__c = 'New Product Inquiry';
        case2.LP_Sub_Issue__c = 'Payouts';
        insert case2;
        
        Case oCase =new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.ContactId=oContact.id;
        oCase.AccountId = acc.Id;
        oCase.Merchant_Id__c = '654321';
        oCase.LP_Business_Vertical__c = 'PayU Biz';
        oCase.LP_Issue__c = 'Document Related';
        oCase.LP_Sub_Issue__c = 'Documents Rejected';
        insert oCase;
        test.stopTest();
    }
    }
    
    public static testMethod void testDataFor_Opp11(){
        User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
        system.runAs(u){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'Onecare Publisher Log';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        test.startTest();
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name='wix com india pvt ltd';
        insert acc;
        
        Platform__c plm = New Platform__c();
        plm.Name = 'PayU Biz';
        plm.active__c = true;
        insert plm;
        
        Product__c prod = New Product__c();
        prod.Name = 'PayU Biz';
        prod.Active__c = true;
        prod.Platform__c = plm.Id;
        insert prod;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(acc);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        opportunityObj.Lead_Type__c = 'Partner';
        opportunityObj.Name = 'wix com india pvt ltd';
        Insert opportunityObj;
        
        Opportunity opp2 = New Opportunity();
        opp2.Name='test1';
        opp2.Email__c='test@test.com';
        opp2.AccountId=acc.Id;
        opp2.StageName='MAF';
        opp2.CloseDate=Date.today();
        opp2.Prod_Merchant_Id__c = 654321;
        opp2.OwnerId = userInfo.getUserId() ;
        opp2.Lead_Created_date__c = null;
        opp2.Product__c = prod.Id;
        opp2.Business_Origin__c = 'SMB-ENT';
        list<string> dormantList = Label.Dormant_Account_KAM_Id.split(',');
        opp2.Key_Assigned_Manager__c =  dormantList[0];
        opp2.Partner__c = opportunityObj.Id;
        insert opp2;
        
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.Email='test2@test.com';
        oContact.MobilePhone='1236567890';
        oContact.AccountId=acc.Id;
        insert oContact;
        
        Case case1 =new Case();
        case1.Status='New';
        case1.Priority='High';
        case1.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        case1.ContactId=oContact.id;
        case1.AccountId = acc.Id;
        case1.Merchant_Id__c = '654321';
        case1.LP_Business_Vertical__c = 'PayU Biz';
        case1.LP_Issue__c = 'Account related';
        case1.LP_Sub_Issue__c = 'Other';
        insert case1;
        
        Case case2 =new Case();
        case2.Status='New';
        case2.Priority='High';
        case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        case2.ContactId=oContact.id;
        case2.AccountId = acc.Id;
        case2.Merchant_Id__c = '654321';
        case2.LP_Business_Vertical__c = 'PayU Biz';
        case2.LP_Issue__c = 'Bank Verification Pending';
        case2.LP_Sub_Issue__c = 'Small Amount not deposited';
        insert case2;
        
        opp2.Settlement_Status__c = 'Active';
        update opp2;
        
        Case case3 =new Case();
        case3.Status='New';
        case3.Priority='High';
        case3.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        case3.ContactId=oContact.id;
        case3.AccountId = acc.Id;
        case3.Merchant_Id__c = '654321';
        case3.LP_Business_Vertical__c = 'PayU Biz';
        case3.LP_Issue__c = 'New Product Inquiry';
        case3.LP_Sub_Issue__c = 'Payouts';
        insert case3;
        
        Case case4 =new Case();
        case4.Status='New';
        case4.Priority='High';
        case4.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        case4.ContactId=oContact.id;
        case4.AccountId = acc.Id;
        case4.Merchant_Id__c = '654321';
        case4.LP_Business_Vertical__c = 'PayU Biz';
        case4.LP_Issue__c = 'Bank Verification pending';
        case4.LP_Sub_Issue__c = 'Small Amount not deposited';
        insert case4;
        
        test.stopTest();
    }
}

    public static testMethod void child_testData1(){
        User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
        system.runAs(u){
            test.starttest();
            SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
            logIntiator.Name = 'DebugLog Initiator';
            logIntiator.IsActive__c = true;
            logIntiator.IsShow_Debug_Logs__c =true;
            //test.startTest();
            insert logIntiator;
            id entitlementProcessId = [select id
                                       from slaprocess 
                                       where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].id;
            
            id bHours = [SELECT Id,Name 
                         FROM BusinessHours 
                         where name IN ('OneCare Business Hour')].id;
            
            
            Trigger_Switch__c osetting = new Trigger_Switch__c();
            osetting.Active__c=true;
            osetting.Name='Case';
            insert osetting; 
            
            Account acc = New Account();
            acc.Name='Test Acc';
            acc.Document_Status__c = 'Pending';
            insert acc;
            contact oContact =new contact();
            oContact.LastName='test';
            oContact.Email='test2@test.com';
            oContact.MobilePhone='1236567890';
            oContact.AccountId=acc.Id;
            insert oContact;
            
            Case case2 =new Case();
            case2.Status='New';
            case2.Priority='High';
            case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
            case2.ContactId=oContact.id;
            case2.AccountId = acc.Id;
            case2.Merchant_Id__c = '654321';
            case2.MerchantBucket__c = 'Risk hold for PP & TP merchants';        
            insert case2;
            
            Status_SLA__c  sla = new Status_SLA__c();
            sla.Case__c = case2.Id;
            sla.OneCare_LOB_Name__c = case2.LOB_Name__c;
            //sla.First_assigned_user__c = oldCase2.Owner__c;
            insert sla; 
            
            Case childCase=new Case();
            childCase.Status='New';
            childCase.Priority='Medium';
            childCase.Subject='testing';
            childCase.SuppliedEmail = 'test@test.com';
            childCase.SuppliedName = 'test';
            childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId(); 
            childCase.Parent_Case__c=case2.Id;
            childCase.ParentId = case2.Id;
            insert childCase;
            
            childCase.OwnerId = userInfo.getuserId();
            childCase.Status = 'Open';
            update childCase;
            
            childCase.Status = 'Pending';
            childCase.LP_Sub_Status__c = 'Waiting On Bank';
            childCase.Comments = 'sdcsdc';
            update childCase;
            
            childCase.status = 'Closed';
            childCase.Comments = 'sdcsdc';
            update childCase;
            test.stopTest();
            
            system.assertEquals(1, [select count() from Status_SLA__c where Active__c = true and case__c = :case2.id]);
            
        } 
    }

public static testMethod void child_testData2(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    test.startTest();
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'DebugLog Initiator';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    //test.startTest();
    insert logIntiator;
    id entitlementProcessId = [select id
                               from slaprocess 
                               where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].id;
    
    id bHours = [SELECT Id,Name 
                 FROM BusinessHours 
                 where name IN ('OneCare Business Hour')].id;
    
    
    Trigger_Switch__c osetting = new Trigger_Switch__c();
    osetting.Active__c=true;
    osetting.Name='Case';
    insert osetting; 
    
    Account acc = New Account();
    acc.Name='Test Acc';
    acc.Document_Status__c = 'Pending';
    insert acc;
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    //opp2.OwnerId = Userinfo.getUserId();
    opp2.Website_Status__c = 'Website Error';
    opp2.Lead_Created_date__c = null;
    opp2.Product__c = prod.Id;
    insert opp2;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.LP_Issue__c = 'Website Approval Pending';
    case2.LP_Sub_Issue__c = 'Website Approval Pending';        
    insert case2;
    
    Case childCase=new Case();
    childCase.Status='New';
    childCase.Priority='Medium';
    childCase.Subject='testing';
    childCase.SuppliedEmail = 'test@test.com';
    childCase.SuppliedName = 'test';
    childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId(); 
    childCase.Parent_Case__c = case2.Id;
    childCase.ParentId = case2.Id;
    insert childCase;
    
    childCase.Is_Violated__c = true;
    update childCase;
    
    childCase.Is_Warning_Notification__c = true;
    update childCase;
    try{
        childCase.Status='Pending';            
        childCase.LP_Sub_Status__c = 'Waiting On Merchant';
        childCase.Comments=null;
        update childCase;            
    }catch(Exception e){
        system.debug('###### '+e.getMessage());
        Boolean expectedExceptionThrown =  (e.getMessage().contains(Label.LP_Please_Enter_Comments)) ? true : false;
        System.AssertEquals(expectedExceptionThrown, true);
    }
    
    try{
        childCase.Status='Closed';
        update childCase;            
    }catch(Exception e){
        system.debug('###### '+e.getMessage());
        Boolean expectedExceptionThrown =  (e.getMessage().contains(Label.LP_Please_Enter_Comments)) ? true : false;
        System.AssertEquals(expectedExceptionThrown, true);
    }
    
    test.stopTest();
}
}

public static testMethod void child_testData3(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    test.startTest();
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'DebugLog Initiator';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    
    insert logIntiator;
    id entitlementProcessId = [select id
                               from slaprocess 
                               where name = 'ETC Child Entitlement' and isActive = true LIMIT 1].id;
    
    id bHours = [SELECT Id,Name 
                 FROM BusinessHours 
                 where name IN ('PayU OneCare Child')].id;
    
    
    Trigger_Switch__c osetting = new Trigger_Switch__c();
    osetting.Active__c=true;
    osetting.Name='Case';
    insert osetting;        
    
    Account acc = New Account();
    acc.Name='Test Acc';
    acc.Document_Status__c = 'Pending';
    insert acc;
    contact oContact =new contact();
    oContact.LastName='test';
    oContact.Email='test2@test.com';
    oContact.MobilePhone='1236567890';
    oContact.AccountId=acc.Id;
    insert oContact;
    
    Case case2 =new Case();
    case2.Status='New';
    case2.Priority='High';
    case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
    case2.ContactId=oContact.id;
    case2.AccountId = acc.Id;
    case2.Merchant_Id__c = '654321';
    case2.MerchantBucket__c = 'Profile completion pending | PP';
    case2.LP_Issue__c = 'Transaction Issues';
    case2.LP_Sub_Issue__c = 'Refund Related';
    insert case2;
   
    case2.OwnerId = [Select Id,userorgroupid,group.Id from groupMember where Group.DeveloperName='Buyers_Care' and group.type='Queue' LIMIT 1].group.Id;//.userorgroupid;
    update case2;
    
    case2.Status = 'Pending';
    case2.LP_Sub_Status__c = 'Waiting On Settlement Ops (inc biz)';
    case2.Comments = 'test';
    update case2;
    
    test.stoptest();}
    
}

public static testMethod void Parent_testData1(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'DebugLog Initiator';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    id entitlementProcessId = [select id
                               from slaprocess 
                               where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].id;
    
    id bHours = [SELECT Id,Name 
                 FROM BusinessHours 
                 where name IN ('OneCare Business Hour')].id;
    
    
    Trigger_Switch__c osetting = new Trigger_Switch__c();
    osetting.Active__c=true;
    osetting.Name='Case';
    insert osetting; 
    
    Account acc = New Account();
    acc.Name = 'testAccount';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity opp2 = New Opportunity();
    opp2.Name='test1';
    opp2.Email__c='test@test.com';
    opp2.AccountId=acc.Id;
    opp2.StageName='MAF';
    opp2.CloseDate=Date.today();
    opp2.Prod_Merchant_Id__c = 654321;
    opp2.Lead_Created_date__c = null;
    opp2.Product__c = prod.Id;
    insert opp2;
    
    opp2.OwnerId = userInfo.getUserId();
    update opp2;
    system.assertEquals(userInfo.getUserId(), opp2.OwnerId);
    
    Entitlement et = new entitlement();
    et.AccountId = acc.id;
    et.SlaProcessId = entitlementProcessId;
    et.BusinessHoursId = bHours;
    et.Name = 'ETC Parent Entitlement';
    et.StartDate = Date.today();
    insert et;
    
    contact oContact=new contact();
    oContact.LastName='test';
    oContact.AccountId = acc.Id;
    oContact.Email='test@test.com';
    oContact.MobilePhone='1234567890';
    insert oContact;
    
    Case case3 = New Case();
    case3.Status='New';
    case3.Priority='Medium';
    case3.Subject='Re: testing';
    case3.SuppliedEmail = 'test@test.com';
    case3.SuppliedName = 'test';
    case3.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
    case3.Merchant_Id__c = '654321';
    case3.LP_Issue__c = 'Website Approval Pending';
    case3.LP_Sub_Issue__c = 'Website Approval Rejected';
    case3.AccountId = acc.Id;        
    case3.ContactId=oContact.Id;
    insert case3;
    
    case3.OwnerId = [Select Id,userorgroupid,group.Id from groupMember where Group.DeveloperName='Waiting_On_PayUSMB_Sales' and group.type='Queue' LIMIT 1].group.Id;
    update case3;
	//system.assertEquals(opp2.OwnerId,  case3.OwnerId );
    
    case3.ownerId= userinfo.getUserId();
    update case3;
    
    case3.Status = 'Pending';
    case3.isAutoClosed__c = true;
    update case3;
    
    case3.Is_L2_Violated__c = true;
    update case3;
    
    case3.Is_L3_Violated__c = true;
    update case3;
    
    case3.isAutoClosed__c = false;
    update case3;
    
    } 
}

public static testMethod void parent_testData2(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'DebugLog Initiator';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    id entitlementProcessId = [select id
                               from slaprocess 
                               where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].id;
    
    id bHours = [SELECT Id,Name 
                 FROM BusinessHours 
                 where name IN ('OneCare Business Hour')].id;
    
    
    Trigger_Switch__c osetting = new Trigger_Switch__c();
    osetting.Active__c=true;
    osetting.Name='Case';
    insert osetting; 
    
    Account acc = New Account();
    acc.Name = 'testAccount';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity oOpp = New Opportunity();
    oOpp.Name='test1';
    oOpp.Email__c='test@test.com';
    oOpp.AccountId=acc.Id;
    oOpp.StageName='MAF';
    oOpp.CloseDate=Date.today();
    oOpp.Product__c = prod.id;
    insert oOpp;
    
    Entitlement et = new entitlement();
    et.AccountId = acc.id;
    et.SlaProcessId = entitlementProcessId;
    et.BusinessHoursId = bHours;
    et.Name = 'ETC Parent Entitlement';
    et.StartDate = Date.today();
    insert et;
    
    contact oContact=new contact();
    oContact.LastName='test';
    oContact.AccountId = acc.Id;
    oContact.Email='test@test.com';
    oContact.MobilePhone='1234567890';
    insert oContact;
    
    Case oCase;
    oCase=new Case();
    oCase.Status='New';
    oCase.Priority='Medium';
    oCase.Subject='testing';
    oCase.SuppliedEmail = 'test@test.com';
    oCase.SuppliedName = 'test';
    oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
    oCase.OwnerId = [Select Id from group where type='Queue' and developername='payu_money' limit 1].Id;
    oCase.AccountId = acc.Id;
    oCase.ContactId=oContact.Id;
    insert oCase;
    
    Status_SLA__c  sla = new Status_SLA__c();
    sla.Case__c = oCase.Id;
    sla.OneCare_LOB_Name__c = oCase.LOB_Name__c;
    insert sla;
    
    oCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Merchant_Maintenance' and group.type='Queue' LIMIT 1].userorgroupid;
    update oCase;
    
    oCase.Status = 'Resolved';
    oCase.Comments='ewfwef';  
    oCase.Problem_area_ETC__c ='Account Related';
    oCase.Details_ETC__c = 'Payouts';
    oCase.Sub_details_ETC__c ='Integration Help';
    update oCase;
    
    oCase.Status = 'Re-Open';
    update oCase;
    
    oCase.Status = 'Resolved';
    oCase.Comments = 'test';
    update oCase;
        
    }
}
    
public static testMethod void parent_testData3(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'DebugLog Initiator';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    id entitlementProcessId = [select id
                               from slaprocess 
                               where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].id;
    
    id bHours = [SELECT Id,Name 
                 FROM BusinessHours 
                 where name IN ('OneCare Business Hour')].id;
    
    
    Trigger_Switch__c osetting = new Trigger_Switch__c();
    osetting.Active__c=true;
    osetting.Name='Case';
    insert osetting; 
    
    Account acc = New Account();
    acc.Name = 'testAccount';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity oOpp = New Opportunity();
    oOpp.Name='test1';
    oOpp.Email__c='test@test.com';
    oOpp.AccountId=acc.Id;
    oOpp.StageName='MAF';
    oOpp.CloseDate=Date.today();
    oOpp.Product__c = prod.Id;
    insert oOpp;
    
    Entitlement et = new entitlement();
    et.AccountId = acc.id;
    et.SlaProcessId = entitlementProcessId;
    et.BusinessHoursId = bHours;
    et.Name = 'ETC Parent Entitlement';
    et.StartDate = Date.today();
    insert et;
    
    contact oContact=new contact();
    oContact.LastName='test';
    oContact.AccountId = acc.Id;
    oContact.Email='test@test.com';
    oContact.MobilePhone='1234567890';
    insert oContact;
    
    Case oCase;
    oCase=new Case();
    oCase.Status='New';
    oCase.Priority='Medium';
    oCase.Subject='testing';
    oCase.SuppliedEmail = 'test@test.com';
    oCase.SuppliedName = 'test';
    oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
    oCase.OwnerId = [Select Id from group where type='Queue' and developername='payu_money' limit 1].Id;
    oCase.AccountId = acc.Id;        
    oCase.ContactId=oContact.Id;
    insert oCase;
    
    system.assertEquals('00G7F000002iiTW', oCase.OwnerId, 'correct ownerId if true');
    system.debug('ownerId with error ==='+[Select Id,userorgroupid from groupMember where Group.DeveloperName='payu_money' and group.type='Queue' LIMIT 1].userorgroupid);
    
    oCase.Status = 'IN_PROGRESS';
    oCase.LOB_Name__c = 'TEST';
    update oCase;
    
    oCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='payu_money' and group.type='Queue' LIMIT 1].userorgroupid;
    //system.assertEquals('0057F000005HnLcQAK', oCase.OwnerId, 'correct ownerId if true');
    update oCase;
    
    oCase.Status = 'Resolved';
    oCase.Comments='ewfwef';
    oCase.Problem_area_ETC__c ='Account Related';
    oCase.Details_ETC__c = 'Payouts';
    oCase.Sub_details_ETC__c ='Integration Help';
    update oCase;  
    
    oCase.status = 'Re-Open';
    update oCase;
    
    oCase.Status = 'Pending';
    oCase.LP_Sub_Status__c = 'Waiting On Merchant';
    oCase.Comments='ewfwef'; 
    update oCase;
    
    oCase.Status = 'Response received from merchant';
    oCase.LP_Sub_Status__c = '';
    update oCase;
    
  /*  oCase.Status = 'Resolved';
    oCase.Comments = 'test';
    update oCase; */
    
    
    //oneCareReportHandler.testClassCompletionData(new list<case>{oCase});
}
}
    
    public static testMethod void parent_testData4(){
    User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
    system.runAs(u){
    SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
    logIntiator.Name = 'DebugLog Initiator';
    logIntiator.IsActive__c = true;
    logIntiator.IsShow_Debug_Logs__c =true;
    test.startTest();
    insert logIntiator;
    id entitlementProcessId = [select id
                               from slaprocess 
                               where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].id;
    
    id bHours = [SELECT Id,Name 
                 FROM BusinessHours 
                 where name IN ('OneCare Business Hour')].id;
    
    
    Trigger_Switch__c osetting = new Trigger_Switch__c();
    osetting.Active__c=true;
    osetting.Name='Case';
    insert osetting; 
    
    Account acc = New Account();
    acc.Name = 'testAccount';
    insert acc;
    
    Platform__c plm = New Platform__c();
    plm.Name = 'PayU Money';
    plm.active__c = true;
    insert plm;
    
    Product__c prod = New Product__c();
    prod.Name = 'PayU Money';
    prod.Active__c = true;
    prod.Platform__c = plm.Id;
    insert prod;
    
    Opportunity oOpp = New Opportunity();
    oOpp.Name='test1';
    oOpp.Email__c='test@test.com';
    oOpp.AccountId=acc.Id;
    oOpp.StageName='MAF';
    oOpp.CloseDate=Date.today();
    oOpp.Product__c = prod.id;
    insert oOpp;
    
    contact oContact=new contact();
    oContact.LastName='test';
    oContact.AccountId = acc.Id;
    oContact.Email='test@test.com';
    oContact.MobilePhone='1234567890';
    insert oContact;
    
    Case oCase;
    oCase=new Case();
    oCase.Status='New';
    oCase.Priority='Medium';
    oCase.Subject='testing';
    oCase.SuppliedEmail = 'test@test.com';
    oCase.SuppliedName = 'test';
    oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
    oCase.OwnerId = [Select Id from group where type='Queue' and developername='payu_money' limit 1].Id;
    oCase.AccountId = acc.Id;
    oCase.ContactId=oContact.Id;
    insert oCase;
    
    Status_SLA__c  sla = new Status_SLA__c();
    sla.Case__c = oCase.Id;
    sla.OneCare_LOB_Name__c = oCase.LOB_Name__c;
    insert sla;
    
    oCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Merchant_Maintenance' and group.type='Queue' LIMIT 1].userorgroupid;
    update oCase;
    
    oCase.Status = 'Resolved';
    oCase.Comments='ewfwef';    
    oCase.Problem_area_ETC__c ='Account Related';
    oCase.Details_ETC__c = 'Payouts';
    oCase.Sub_details_ETC__c ='Integration Help';
    update oCase;
    
    oCase.Status = 'Re-Open';
    update oCase;
    
    oCase.Status = 'Resolved';
    oCase.Comments = 'test';
    update oCase;
    }   
}
        
    
    public static testMethod void caseChildCoverage(){
        User u = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1];
        system.runAs(u){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        
        insert logIntiator;
        id entitlementProcessId = [select id
                                   from slaprocess 
                                   where name = 'ETC Parent Entitlement' and isActive = true LIMIT 1].id;
        
        id bHours = [SELECT Id,Name 
                     FROM BusinessHours 
                     where name IN ('OneCare Business Hour')].id;
        
        
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting; 
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Platform__c plm = New Platform__c();
        plm.Name = 'PayU Money';
        plm.active__c = true;
        insert plm;
        
        Product__c prod = New Product__c();
        prod.Name = 'PayU Money';
        prod.Active__c = true;
        prod.Platform__c = plm.Id;
        insert prod;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='test@test.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        oOpp.Product__c = prod.Id;
        insert oOpp;
        
        Entitlement et = new entitlement();
        et.AccountId = acc.id;
        et.SlaProcessId = entitlementProcessId;
        et.BusinessHoursId = bHours;
        et.Name = 'ETC Parent Entitlement';
        et.StartDate = Date.today();
        insert et;
        
        Test.startTest();
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'test@test.com';
        oCase.SuppliedName = 'test';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        oCase.OwnerId = [Select Id from group where type='Queue' and developername='payu_money' limit 1].Id;
        oCase.AccountId = acc.Id;        
        oCase.ContactId=oContact.Id;
        insert oCase;
        
        system.assertEquals('00G7F000002iiTW', oCase.OwnerId, 'correct ownerId if true');
        system.debug('ownerId with error ==='+[Select Id,userorgroupid from groupMember where Group.DeveloperName='payu_money' and group.type='Queue' LIMIT 1].userorgroupid);
        
        oCase.Status = 'Pending';
        update oCase;
        System.debug([SELECT Id, Status, LOB_Name__c FROM Case WHERE id = :oCase.Id]);
        Test.stopTest();
        
        oCase.LOB_Name__c = 'TEST';
        update oCase;
        /*
        oCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='payu_money' and group.type='Queue' LIMIT 1].userorgroupid;
        //system.assertEquals('0057F000005HnLcQAK', oCase.OwnerId, 'correct ownerId if true');
        update oCase;
        
        oCase.Status = 'Resolved';
        oCase.Comments='ewfwef';
        update oCase;  
        
        oCase.status = 'Re-Open';
        update oCase;
        
        oCase.Status = 'Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        oCase.Comments='ewfwef'; 
        update oCase;
        
        oCase.Status = 'Response received from merchant';
        oCase.LP_Sub_Status__c = '';
        update oCase;
        
      	 */
        //oneCareReportHandler.testClassCompletionData(new list<case>{oCase});
    }
    }

}