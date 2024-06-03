@isTest
public class MilestoneUtilsTracker {

    public static testMethod void testData1(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
                
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Verified';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='test';
        insert oCase;
         
        MilestoneUtils.sendEmailtoManager(new List<Case>{oCase},new Map<Id,Id>{userinfo.getUserId()=>userinfo.getUserId()},'Violation Notification to Parent to Manager'); 
        MilestoneUtils.sendEmailtoOwner(new List<Case>{oCase},new Map<Id,Id>{userinfo.getUserId()=>userinfo.getUserId()},'Violation Notification to Parent to Manager'); 
        MilestoneUtils.sendEmails(new List<Case>{oCase},'Violation Notification to Parent to Manager');
        MilestoneUtils.completeMilestone(new List<Case>{oCase},'Parent Ticket Milestone',System.now());
    }
    
    public static testMethod void testData2(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Account acc = New Account();
        acc.Name='Test Acc';
        insert acc;
        
        Trigger_Switch__c osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
                
        contact oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
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
        insert oCase;
        
        oCase.OwnerId = userInfo.getUserId();
        update oCase;
         
        MilestoneUtils.sendEmailtoManager(new List<Case>{oCase},new Map<Id,Id>{userinfo.getUserId()=>userinfo.getUserId()},'Violation Notification to Parent to Manager'); 
        MilestoneUtils.sendEmailtoOwner(new List<Case>{oCase},new Map<Id,Id>{userinfo.getUserId()=>userinfo.getUserId()},'Violation Notification to Parent to Manager'); 
        MilestoneUtils.sendEmails(new List<Case>{oCase},'Violation Notification to Parent to Manager');
        MilestoneUtils.completeMilestone(new List<Case>{oCase},'Parent Ticket Milestone',System.now());
    }
    
    
}