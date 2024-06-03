@isTest(seealldata=false)
public class SendEmailScheduletracker{ 
    public static QueuesObject testQueue;
    public static QueuesObject testQueue1;
    public static Contact ocontact;
    public static Case oCase1;
    public static Case oCase2;
    public static Group testGroup;
    public static Group testGroup1;
    
    Public static testmethod void SendEmailBatchMethod(){ 
        loadData();
        EmailSchedule sh1 = new EmailSchedule();
        String sch = '0 0 2 * * ?'; 
        test.StartTest();
        system.schedule('Check', sch, sh1);
        test.stopTest();      
}   
    Public static testmethod void SendEmailBatchMethod2(){ 
        loadData();
        EmailSchedulePL sh1 = new EmailSchedulePL();
        String sch = '0 0 2 * * ?'; 
        test.StartTest();
         Case objCase = [SELECT id,LP_CL_Status__c from Case limit 1];
        objCase.LP_CL_Status__c = '1';
        update objCase;
        system.schedule('Check', sch, sh1);
        test.stopTest();
       
}
    
     Public static testmethod void SendEmailBatchMethod3(){ 
        loadData();
        EmailScheduleAdditional sh1 = new EmailScheduleAdditional();
        String sch = '0 0 2 * * ?'; 
        test.StartTest();
         Case objCase = [SELECT id,LP_CL_Status__c from Case limit 1];
        objCase.LP_CL_Status__c = '1';
        update objCase;
        system.schedule('Check', sch, sh1);
        test.stopTest();
       
}
    
    
    
    public static void LoadData() {   
        
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Email_Queue', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        Id queueID = [SELECT Id,DeveloperName,Name FROM Group WHERE type ='queue' AND DeveloperName = 'LP_Email_Queue'].id;
        
        system.debug('queueID======'+queueID);
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact; 
        
        oCase1=new Case();
        oCase1.OwnerId = queueID;
        oCase1.Priority='High';
        oCase1.LP_IVR_Call__c=1;
        oCase1.LP_Customer_Score__c=7;
        oCase1.LP_Manual_Call__c=1;
        oCase1.LP_Due_Since__c = Date.today().addDays(-9);
        oCase1.LP_Outstanding_Amount__c = 200;
        oCase1.LP_SMS__c=1;
        oCase1.LP_Email__c=1;
        oCase1.LP_APP_Notification__c=1;
        oCase1.LP_Communication_Type__c='Competitive';
        oCase1.LP_Communication_sub_type__c='Type Default';
        oCase1.LP_IVR_Call_Count__c=1;
        oCase1.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();        
        oCase1.Status='New';
        oCase1.LP_CL_Status__c = '0';
        oCase1.ContactId=oContact.id;
        oCase1.LP_Email_Template_Name__c = 'DPD';
        String dateStr = Date.today().format();
        oCase1.Collection_Rule_Time__c = dateStr; 
        oCase1.ContactId = oContact.Id;
        oCase1.LP_NBFC_Type__c = null;
        
        insert oCase1;
        system.debug('case'+oCase1);
        
        Task taskObj = new task();
        taskObj.WhatId = oCase1.id;
        taskObj.WhoId = oContact.Id;
        taskObj.Subject = 'activity'; 
        taskObj.status = 'Completed';
        insert taskObj;
        
        // Create HTTP Publisher 
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();
        objHTTPPublisher.LP_Request_body__c = 'Test String';
        objHTTPPublisher.Related_Object__c = 'Case';
        objHTTPPublisher.LP_Response__c =  'Test Response';
        objHTTPPublisher.LP_ProcessName__c   = 'Test Process';  
        insert objHTTPPublisher;
    }
   
   
}