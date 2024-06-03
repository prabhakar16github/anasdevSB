@istest

public class oneCareEmailToCaseTriggerTracker {
    public static Contact ocontact;
    public static Case oCase;
    public static EmailMessage Objemail;
    public static EmailMessage Objemail1;
    
    @isTest
    public static void LoadData()
    {  
        Test.startTest();
        
        List<EmailServicesAddress> emailServiceAddList = [select localPart from EmailServicesAddress];
        
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='EmailMessage';
        insert osetting;
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='airtelsupport@test.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        insert oOpp;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='airtelsupport@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'airtelsupport@test.com';
        oCase.SuppliedName = 'test';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PayU Bizz').getRecordTypeId(); 
        oCase.Origin = 'Merchant_Support_SMB';
        oCase.LOB_Name__c = 'Merchant_Support_SMB';
        
        oCase.AccountId = acc.Id;        
        oCase.ContactId=oContact.Id;
        insert oCase;
        
        Status_SLA__c  sla = new Status_SLA__c();
        sla.Case__c = oCase.Id;
        sla.Active__c = true;
        sla.OneCare_LOB_Name__c = oCase.LOB_Name__c;
        sla.OneCare_New_Time__c = system.now();
        insert sla;
        
        //oCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Merchant_Support_SMB' and group.type='Queue' LIMIT 1].userorgroupid;
        oCase.Previous_QueueId_OwnerId__c = userInfo.getUserId();
        update oCase;
        
        oCase.Status = 'Resolved';
        oCase.Merchant_Id__c = '1111';
        oCase.Problem_area_ETC__c = 'Miscellaneous';
        oCase.Details_ETC__c = 'Duplicate';
        oCase.Comments = 'test';
        update oCase;
        
        Objemail=new EmailMessage();
        Objemail.Subject='Re: test';
        Objemail.ParentId=oCase.id;
        Objemail.Incoming=true; 
        Objemail.fromAddress = 'airtelsupport@test.com';
        Objemail.ToAddress='airtelsupport@intest.com';
        insert Objemail;
                
        oCase.Status = 'Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        oCase.Comments = 'sdvfsdfds';
        oCase.Previous_QueueId_OwnerId__c = userInfo.getUserId();
        update oCase;
        
        EmailMessage Objemail2=new EmailMessage();
        Objemail2.Subject='Re: test';
        Objemail2.ParentId=oCase.id;
        Objemail2.Incoming=true;  
        Objemail2.fromAddress='airtelsupport@test.com';
        Objemail2.ToAddress='airtelsupport@intest.com';
        Objemail2.CcAddress = 'test@testing.cam';
        insert Objemail2;
        
        oCase.Status = 'Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Buyer';
        oCase.Comments = 'sdvfsdfds';
        oCase.Previous_QueueId_OwnerId__c = userInfo.getUserId();
        update oCase;
        
        EmailMessage Objemail3=new EmailMessage();
        Objemail3.Subject='Re: test';
        Objemail3.ParentId=oCase.id;
        Objemail3.Incoming=true;  
        Objemail3.fromAddress='airtelsupport@test.com';
        Objemail3.ToAddress='airtelsupport@intest.com';
        insert Objemail3;
        
        Objemail3.TextBody = 'ascas';
        update Objemail3;
        
        EmailMessage Objemail4=new EmailMessage();
        Objemail4.Subject='Re: testing';
        Objemail4.ParentId=oCase.id;
        Objemail4.Incoming=false;  
        Objemail4.fromAddress='airtelsupport@test.com';
        Objemail4.ToAddress='airtelsupport@intest.com';
        Objemail4.CcAddress = 'test@testing.cam';
        insert Objemail4;
        
        
        Test.stopTest();
    }  
    
    public static testMethod void testdata_3(){
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='EmailMessage';
        insert osetting;
        
        List<EmailServicesAddress> emailServiceAddList = [select localPart from EmailServicesAddress];
        
        Account acc = New Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Opportunity oOpp = New Opportunity();
        oOpp.Name='test1';
        oOpp.Email__c='airtelsupport@test.com';
        oOpp.AccountId=acc.Id;
        oOpp.StageName='MAF';
        oOpp.CloseDate=Date.today();
        insert oOpp;
        
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.AccountId = acc.Id;
        oContact.Email='airtelsupport@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        List<OrgWideEmailAddress> owdAddressList = [select id, Address from OrgWideEmailAddress];
        Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.Subject='testing';
        oCase.SuppliedEmail = 'airtelsupport@test.com';
        oCase.SuppliedName = 'test';
        oCase.Origin = 'citrus_wallet';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId();        
        oCase.AccountId = acc.Id;        
        oCase.ContactId=oContact.Id;
        insert oCase;
        
            
        EmailMessage Objemail3=new EmailMessage();
        Objemail3.Subject='Re: test';
        Objemail3.ParentId=oCase.id;
        Objemail3.Incoming=true;
        Objemail3.FromAddress = 'airtelsupport@test.com';
        Objemail3.ToAddress = 'testyPayu@has.com';
        insert Objemail3;
        
        //oCase.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='citrus_wallet' and group.type='Queue' LIMIT 1].userorgroupid;
        update oCase;
        
        oCase.Status='Closed';
        oCase.Previous_QueueId_OwnerId__c = userInfo.getUserId();
        oCase.Platform_e__c = 'citrus_wallet';
        update oCase;
        
        EmailMessage Objemail4=new EmailMessage();
        Objemail4.Subject='Re: test';
        Objemail4.ParentId=oCase.id;
        Objemail4.Incoming=true;
        Objemail4.FromAddress = 'airtelsupport@test.com';
        Objemail4.ToAddress = 'testyPayu@has.com';
        insert Objemail4;
    }
}