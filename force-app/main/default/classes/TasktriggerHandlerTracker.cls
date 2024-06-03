/**
@author:            jatin arora
@company:           SaaSFocus
@description:       cover TaskTriggerHandler
@history
<Date>        <Authors Name>        
24-Sep-18     eitika Verma          
**/
@isTest(seealldata=false)
public class TasktriggerHandlerTracker {
    
    
    public static Trigger_Switch__c osetting;
    public static Contact ocontact;
    public static Case oCase;
    public static Task objTask;
    public static Opportunity opp;
    public static Merchant_plan__c Plan;
    
    public static void LoadData()
    {
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Task';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='test';
        insert oCase;
        
        objTask = new Task();
        objTask.Subject = 'Manual Call';
        insert objTask;
        
        
    }
    
    public static void LoadData2()
    {
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Task';
        insert osetting;
        
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
        
        opp = New Opportunity();
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
        insert opp;
        
        Plan = new Merchant_Plan__c();
        Plan.Name = 'business_plus';
        Plan.Status__c = 'payment_completed';
        Plan.Price__c = 950;
        plan.Opportunity__c = opp.id;
        insert Plan;
        
    }
    
    @isTest
    public static void validateVerifiedTest(){
        LoadData();
        
        Test.startTest();
        Task updateTask = new Task(Id = objTask.Id,WhatId = oCase.Id,LP_Manual_Call_Status__c = 'Not Available',LP_Next_Scheduled_Call__c = System.Now());
        update updateTask;
        Test.stopTest();
    } 
    
    @isTest
    public static void validateReminderTest(){
        
        LoadData2();
        objTask = new Task();
        objTask.WhatId = opp.id;
        objTask.Subject = 'Task for Purchased Plan';
        objTask.Merchant_Plan__c = Plan.Id;
        objTask.OwnerId = Label.integrationUserid;
        insert objTask;
        
        objTask.ReminderDateTime = system.now();
        objTask.L1_Escalated__c = true;
        update objTask;
        
        objTask.OwnerId = userInfo.getUserId();
        update objTask;
    }
    
}