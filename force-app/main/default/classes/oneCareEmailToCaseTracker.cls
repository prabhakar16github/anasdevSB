@isTest
public class oneCareEmailToCaseTracker {
   
    public static entitlement oEntitlement; 
     
    public static testMethod void SMBMerchantTestData(){
          
        Test.startTest();
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
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
        
        oEntitlement = new Entitlement();
            oEntitlement.Name='ETC Parent Entitlement';
            oEntitlement.AccountId= acc.id;
            oEntitlement.BusinessHoursId = bHours;
            oEntitlement.StartDate=Date.Today();
            insert oEntitlement;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='testEmail@test.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        insert oOpp;
                
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='testEmail@test.com';
        oContact.MobilePhone='1234567890';
        oContact.Owner_Assignment_Header__c = 'SMB-00G7F0000039n8C';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'testEmail@test.com';
        oCase.SuppliedName = 'shivani';
        oCase.Is_Warning_Notification__c=false;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId(); 
        oCase.AccountId = acc.Id;
        oCase.Origin = 'ENT_Care_Team';
        oCase.LOB_Name__c = 'Merchant_Support_ENT';
        insert oCase;
        
        oCase.Platform_e__c = 'SMB_Care_Team';
        update oCase;
        Test.stopTest();
        
    }
    
     
    public static testMethod void SMBMerchantTestData2(){
          
        Test.startTest();
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
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
        
        oEntitlement = new Entitlement();
            oEntitlement.Name='ETC Parent Entitlement';
            oEntitlement.AccountId= acc.id;
            oEntitlement.BusinessHoursId = bHours;
            oEntitlement.StartDate=Date.Today();
            insert oEntitlement;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='testEmail@test.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        insert oOpp;
                
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='testEmail@test.com';
        oContact.MobilePhone='1234567890';
        oContact.Owner_Assignment_Header__c = 'ENT-00G7F0000039n8C';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'testEmail@test.com';
        oCase.SuppliedName = 'shivani';
        oCase.Is_Warning_Notification__c=false;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId(); 
        oCase.AccountId = acc.Id;
        oCase.Origin = 'ENT_Care_Team';
        oCase.LOB_Name__c = 'Merchant_Support_ENT';
        insert oCase;
        
        Test.stopTest();
        
    }
    
    public static testMethod void SMBMerchantTestData3(){
          
        Test.startTest();
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
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
        
        oEntitlement = new Entitlement();
            oEntitlement.Name='ETC Parent Entitlement';
            oEntitlement.AccountId= acc.id;
            oEntitlement.BusinessHoursId = bHours;
            oEntitlement.StartDate=Date.Today();
            insert oEntitlement;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='testEmail@test.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        insert oOpp;
                
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='testEmail@test.com';
        oContact.MobilePhone='1234567890';
        oContact.Owner_Assignment_Header__c = 'ENT-00G7F0000039n8C';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'testEmail@test.com';
        oCase.SuppliedName = 'shivani';
        oCase.Is_Warning_Notification__c=false;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId(); 
        oCase.AccountId = acc.Id;
        oCase.Origin = 'Merchant_Support_ENT';
        oCase.LOB_Name__c = 'Merchant_Support_ENT';
        insert oCase;
        
        Test.stopTest();
        
    }
    
    
    public static testMethod void SMBMerchantTestData4(){
          
        Test.startTest();
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
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
        
        oEntitlement = new Entitlement();
            oEntitlement.Name='ETC Parent Entitlement';
            oEntitlement.AccountId= acc.id;
            oEntitlement.BusinessHoursId = bHours;
            oEntitlement.StartDate=Date.Today();
            insert oEntitlement;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='testEmail@test.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        insert oOpp;
                
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='testEmail@test.com';
        oContact.MobilePhone='1234567890';
        oContact.Owner_Assignment_Header__c = 'SMB-00G7F0000039n8C';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'testEmail@test.com';
        oCase.SuppliedName = 'shivani';
        oCase.Is_Warning_Notification__c=false;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId(); 
        oCase.AccountId = acc.Id;
        oCase.Origin = 'Merchant_Support_ENT';
        oCase.LOB_Name__c = 'Merchant_Support_ENT';
        insert oCase;
        
        Test.stopTest();
        
    }
    
    public static testMethod void testData2(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        //test.startTest();
        insert logIntiator;
       Map<id,Account> caseIdWithNewAccountMap = new Map<id,Account>();
        Map<string,Case> existingCaseWithSubjectMap = new Map<string,Case>();
        Map<string,Contact> caseIdWithNewContactMap = New Map<string,Contact>();
        Map<String,Opportunity> caseIdWithExistingOppMap = New Map<String,Opportunity>();
        Map<string,Case> caseWithCaseSubjectMap = New Map<string,Case>();
         
       
        id entitlementProcessId = [select id
                                   from slaprocess 
                                   where name = 'ETC Parent Entitlement' and isActive = true].id;
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting; 
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='test@PayUNow.com';
        oContact.MobilePhone='1234567890';
        insert oContact;

        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Comments='test45678';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'test@PayUMoney.com';
        oCase.SuppliedName = 'test';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId(); 
        existingCaseWithSubjectMap.put(oCase.CaseNumber,oCase);
        caseIdWithNewContactMap.put(oCase.Id,oContact);
        caseWithCaseSubjectMap.put(oCase.subject,oCase);
        insert oCase;
        
        EmailMessage em = New EmailMessage();
        em.HtmlBody='dfghjk';
        em.TextBody='fghjk';
        em.TextBody='sdfwdvfw';
        em.ParentId = oCase.Id;
        em.Subject = 'Re:testing';
        em.ToAddress='test@test.com';
        insert em;        
        Case childCase = New Case();
        childCase.Parent_Case__c = oCase.Id;
        childCase.ParentId = oCase.Id;
        childCase.Status='New';
        childCase.Priority='Medium';
        childCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Merchant_Maintenance' and group.type='Queue' LIMIT 1].userorgroupid;
        childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_to_Case_Child').getRecordTypeId(); 
        insert childCase;
        
        oCase.Status='Pending';
        oCase.Agent_Comments__c='Auto-closed due to no reply';
        oCase.Comments='Auto-closed due to no reply';
        caseIdWithNewContactMap.put(oCase.Id,oContact);
        update oCase;
        oCase.Status='Closed';
        oCase.Is_L3_Violated__c=true;
        oCase.Comments='teset123';
        oCase.Start_Parent_Ticket_Milestone__c=true;
        update oCase;
                    
        oCase.Start_L3_Ticket_Milestone__c=true;
        update oCase;
        //oCase.Comment__c='testh';
        /*oCase.isAutoClosed__c=true;
        oCase.Priority='High';
        oCase.LP_TAT__c='5';
        */
        try{
            childCase.OwnerId=userinfo.getUserId();
            update childCase;            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You cant change child case owner from one queue to another.')) ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }      
        
    }
    public static testMethod void testData3(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        //test.startTest();
        insert logIntiator;
        Map<id,Account> caseIdWithNewAccountMap = new Map<id,Account>();
        Map<string,Case> existingCaseWithSubjectMap = new Map<string,Case>();
        Map<string,Contact> caseIdWithNewContactMap = New Map<string,Contact>();
        Map<String,Opportunity> caseIdWithExistingOppMap = New Map<String,Opportunity>();
        Map<string,Case> caseWithCaseSubjectMap = New Map<string,Case>();
        
        Id bHIdChild;
        Id bhIdParent;
        id entitlementProcessId = [select id
                                   from slaprocess 
                                   where name = 'ETC Parent Entitlement' and isActive = true].id;
        
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
        
        Contact con = new contact();
        con.lastName = 'Test';
        con.Email = 'test@easytripmentor.in';
        con.Owner_Assignment_Header__c = 'SMB-'+system.label.SMB_Care_Team;
        insert con;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'test@easytripmentor.in';
        oCase.SuppliedName = 'test';
        oCase.Origin = 'ENT_Care_Team';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId(); 
        existingCaseWithSubjectMap.put(oCase.CaseNumber,oCase);
       // caseIdWithNewContactMap.put(oCase.Id,oContact);
        caseWithCaseSubjectMap.put(oCase.subject,oCase);
        insert oCase;
        
        oCase.Status='Open';
        oCase.Comments = 'testacu';
        oCase.Merchant_Id__c= 'NA';
        oCase.Problem_area_ETC__c = 'Test1';
        oCase.Details_ETC__c = 'test';
        oCase.Sub_details_ETC__c = 'test';
        oCase.Amount__c = 10;
        update oCase;
       
        EmailMessage em = New EmailMessage();
        em.TextBody='sdfwdvfw';
        em.ParentId = ocase.Id;
        em.ToAddress='test@test.com';
        insert em;
       
        oCase.status='Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant Maintenance';
        oCase.Comments = 'testacu';
        oCase.Merchant_Id__c= 'NA';
        oCase.Problem_area_ETC__c = 'Test1';
        oCase.Details_ETC__c = 'test';
        oCase.Sub_details_ETC__c = 'test';
        oCase.Amount__c = 10;
        update oCase;
        
        oCase.Response_Received__c=true;
        oCase.IsStopped=false;
        oCase.Is_L2_Violated__c=false;
        update oCase;
		 
        oCase.Is_L2_Violated__c=true;
        oCase.Agent_Comments__c='testing';
        oCase.Comments='testing';
        oCase.LP_TAT__c='4';
        oCase.Priority='High';
        update oCase;
        oCase.LP_TAT__c='5';
        update oCase;
       oCase.Start_L2_Ticket_Milestone__c=true;
        update oCase;
        
         /*system.assertEquals(1,[Select count() from Case where ParentId=:oCase.Id]);
        
        Case childCase = [select id,status,comments,ownerid from case where parentId=:oCase.Id];*/
        Case childCase = New Case();
        childCase.Parent_Case__c = oCase.Id;
        childCase.ParentId = oCase.Id;
        childCase.Status='New';
        childCase.Priority='Medium';
        childCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Merchant_Maintenance' and group.type='Queue' LIMIT 1].userorgroupid;
        childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_to_Case_Child').getRecordTypeId(); 
        insert childCase;
        
        try{
            childCase.OwnerId=userinfo.getUserId();
            update childCase;            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You cant change child case owner from one queue to another.')) ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }      
        
    }
    
    public static testMethod void testData4(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        //test.startTest();
        insert logIntiator;
        Map<id,Account> caseIdWithNewAccountMap = new Map<id,Account>();
        Map<string,Case> existingCaseWithSubjectMap = new Map<string,Case>();
        Map<string,Contact> caseIdWithNewContactMap = New Map<string,Contact>();
        Map<String,Opportunity> caseIdWithExistingOppMap = New Map<String,Opportunity>();
        Map<string,Case> caseWithCaseSubjectMap = New Map<string,Case>();
        
        id entitlementProcessId = [select id
                                   from slaprocess 
                                   where name = 'ETC Parent Entitlement' and isActive = true].id;
        
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
        contact oContact=new contact();
        oContact.LastName='teqst';
        oContact.AccountId = acc.Id;
        oContact.Email='test@qtest.com';
        oContact.MobilePhone='12q34567890';

        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'test@test.com';
        oCase.SuppliedName = 'test';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId(); 
         existingCaseWithSubjectMap.put(oCase.CaseNumber,oCase);
		caseIdWithNewContactMap.put(oCase.Id,oContact);
        caseWithCaseSubjectMap.put(oCase.subject,oCase);       
        insert oCase;
       
                
        Opportunity opp1 =new Opportunity();
        opp1.Name='testAccount';
        opp1.Email__c='test@test.com';
        opp1.AccountId =acc.Id;
        opp1.StageName='MAF';
        opp1.CloseDate=Date.today();
        //opp1.Prod_MID__c='4956004';
        insert opp1;
        
        EmailMessage em = New EmailMessage();
        em.TextBody='sdfwdvfw';
        em.ParentId = ocase.Id;
        em.ToAddress='test@test.com';
        insert em;
        /*
        oCase.status='Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant Maintenance';
        oCase.Comments = 'testacu';
        update oCase;
        //system.assertEquals(1,[Select count() from Case where ParentId=:oCase.Id]);
        
        Case childCase = [select id,status,comments,ownerid from case where parentId=:oCase.Id];*/
        Case childCase = New Case();
        childCase.Parent_Case__c = oCase.Id;
        childCase.ParentId = oCase.Id;
        childCase.Status='New';
        childCase.Priority='Medium';
        childCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Merchant_Maintenance' and group.type='Queue' LIMIT 1].userorgroupid;
        childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_to_Case_Child').getRecordTypeId(); 
        insert childCase;
        //update childCase;
        try{
            childCase.Status='Pending';            
            childCase.LP_Sub_Status__c = 'Waiting On Merchant';
            childCase.Comments=null;
            update childCase;            
        }catch(Exception e){
            system.debug('###### '+e.getMessage());
            Boolean expectedExceptionThrown =  (e.getMessage().contains(Label.LP_Please_Enter_Comments)) ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        try{
            childCase.Status='Closed';
            update childCase;            
        }catch(Exception e){
            system.debug('###### '+e.getMessage());
            Boolean expectedExceptionThrown =  (e.getMessage().contains(Label.LP_Please_Enter_Comments)) ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    public static testMethod void LoadData1()
    { 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
       Map<id,Account> caseIdWithNewAccountMap = new Map<id,Account>();
        Map<string,Case> existingCaseWithSubjectMap = new Map<string,Case>();
        Map<string,Contact> caseIdWithNewContactMap = New Map<string,Contact>();
        Map<String,Opportunity> caseIdWithExistingOppMap = New Map<String,Opportunity>();
        Map<string,Case> caseWithCaseSubjectMap = New Map<string,Case>();
        
        Account oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
        
        
        Contact oContact=new contact();
        oContact.LastName='test';
        oContact.Email='xy@gmail.com';
        oContact.MobilePhone='+911234567890';
        oContact.AccountId=oAccount.id;
        oContact.Identifier__c = '4444477444';
        insert oContact; 
        
        Case oCase=new Case();
        oCase.ContactId=oContact.id;
        oCase.AccountId=oAccount.id;
        oCase.Status='New'; 
        oCase.Priority='high';
        oCase.Origin = 'Email';
        oCase.Expected_Closure_Date__c=Date.today()+5;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId();
        oCase.isAutoClosed__c=false;
        oCase.Is_L3_Violated__c=false;
        oCase.LP_TAT__c='4';
         existingCaseWithSubjectMap.put(oCase.CaseNumber,oCase);
       caseIdWithNewContactMap.put(oCase.Id,oContact);
        caseWithCaseSubjectMap.put(oCase.subject,oCase);
        insert oCase;
        oCase.Status='open';
        oCase.Is_L3_Violated__c=true;
        oCase.Comments='test';
        oCase.isAutoClosed__c=true;
        oCase.Priority='High';
        oCase.LP_TAT__c='5';
        update oCase;
        oCase.Status='Pending';
        oCase.Agent_Comments__c='Auto-closed due to no reply';
        oCase.Comments='Auto-closed due to no reply';
        update oCase;
        
        /*oEntitlement = new Entitlement();
        oEntitlement.Name='ETC Parent Entitlement';
        oEntitlement.AccountId= oAccount.id;
        oEntitlement.BusinessHoursId = '01mN0000000960zIAA';
        
        oEntitlement.StartDate=Date.Today();
        insert oEntitlement;*/
        
    }
    public static testMethod void testData5(){
        Id bHIdChild;
        Id bhIdParent;
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        //test.startTest();
        insert logIntiator;
       Map<id,Account> caseIdWithNewAccountMap = new Map<id,Account>();
        Map<string,Case> existingCaseWithSubjectMap = new Map<string,Case>();
        Map<string,Contact> caseIdWithNewContactMap = New Map<string,Contact>();
        Map<String,Opportunity> caseIdWithExistingOppMap = New Map<String,Opportunity>();
        Map<string,Case> caseWithCaseSubjectMap = New Map<string,Case>();
        
        id entitlementProcessId = [select id
                                   from slaprocess 
                                   where name = 'ETC Parent Entitlement' and isActive = true].id;
        
        id bHours = [SELECT Id,Name 
                     FROM BusinessHours 
                     where name IN ('OneCare Business Hour')].id;
        
        
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting; 
        
        Account oAccount=new Account();
        oAccount.Name='test';
        insert oAccount;
        contact oContact=new contact();
        oContact.LastName='teqst';
        oContact.AccountId = oAccount.Id;
        oContact.Email='test@qtest.com';
        oContact.MobilePhone='12q34567890';

        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'test@test.com';
        oCase.SuppliedName = 'test';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId(); 
         existingCaseWithSubjectMap.put(oCase.CaseNumber,oCase);
		caseIdWithNewContactMap.put(oCase.Id,oContact);
          caseWithCaseSubjectMap.put(oCase.subject,oCase);     
        insert oCase;
        
        EmailMessage em = New EmailMessage();
        em.TextBody='sdfwdvfw';
        em.ParentId = ocase.Id;
        em.ToAddress='test@test.com';
        insert em;
		oCase.status='Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant Maintenance';
        oCase.Comments = 'testacu';
        oCase.IsStopped=false;
        update oCase;
        
        Case childCase = New Case();
        childCase.Parent_Case__c = oCase.Id;
        childCase.ParentId = oCase.Id;
        childCase.Status='New';
        childCase.Priority='Medium';
        childCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_Merchant_Maintenance' and group.type='Queue' LIMIT 1].userorgroupid;
        childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_to_Case_Child').getRecordTypeId(); 
        insert childCase;
        childCase.Is_Violated__c = true;
        childCase.Comments = 'sfsvcew';        
        //update childCase;
        
        try{
            childCase.OwnerId=userinfo.getUserId();
            update childCase;            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You cant change child case owner from one queue to another.')) ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    
    public static testMethod void BankSupportTestData(){
       
        Test.startTest();
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
       
        insert logIntiator;
        
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting; 
        
        id bHours = [SELECT Id,Name FROM BusinessHours where name IN ('OneCare Business Hour')].id;
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        oEntitlement = new Entitlement();
            oEntitlement.Name='ETC Parent Entitlement';
            oEntitlement.AccountId= acc.id;
            oEntitlement.BusinessHoursId = bHours;
            oEntitlement.StartDate=Date.Today();
            insert oEntitlement;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='testEmail@email.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        insert oOpp;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='testEmail@email.com';
        oContact.MobilePhone='1234567890';
        oContact.Owner_Assignment_Header__c = '';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'testEmail@email.com';
        oCase.SuppliedName = 'shivani';
        oCase.Is_Warning_Notification__c=false;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bank Support').getRecordTypeId(); 
        oCase.AccountId = acc.Id;        
        oCase.ContactId=oContact.Id;
        oCase.Origin = 'Banks Support';
        insert oCase;
        
        EmailMessage em = New EmailMessage();
        em.HtmlBody='dfghjk';
        em.TextBody='fghjk';
        em.TextBody='sdfwdvfw';
        em.ParentId = oCase.Id;
        em.Subject = 'RE: testing';
        em.ToAddress='test@test.com';
        insert em;
        
        Test.stopTest();
        
    }
    
    public static testMethod void mCareCaseTest(){
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='testEmail@email.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        oOpp.Prod_Merchant_Id__c = 132455;
        insert oOpp;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='testEmail@email.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        MCare_dashboard_Case__c mCareObj = New MCare_dashboard_Case__c();
        mCareObj.Status__c = 'Risk Hold';
        mCareObj.Merchant_Id__c = '132455';
        mCareObj.Product_Name__c = 'PayUbiz';
        insert mCareObj;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'testEmail@email.com';
        oCase.SuppliedName = 'shivani';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId(); 
        oCase.AccountId = acc.Id;        
        oCase.ContactId=oContact.Id;
        oCase.Merchant_Id__c = '';
        oCase.LP_Business_Vertical__c = 'PayU Biz';
        insert oCase;
        

		oCase.Merchant_Id__c = '132455';
        oCase.LP_Business_Vertical__c = 'PayU Biz';
        update oCase;
    }
}