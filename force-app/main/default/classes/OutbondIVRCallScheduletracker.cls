@isTest(seealldata=false)
public class OutbondIVRCallScheduletracker{ 
    public static QueuesObject testQueue;
    public static QueuesObject testQueue1;
    public static Contact ocontact;
    public static Case oCase1;
    public static Case oCase2;
    public static Group testGroup;
    public static Group testGroup1;
    
    Public static testmethod void OutboundIVRCallBatchMethod(){ 
        loadData();
        OutboundIVRSchedule sh1 = new OutboundIVRSchedule();
        String sch = '0 0 2 * * ?'; 
        test.StartTest();
        system.schedule('Check', sch, sh1);
        
       
        test.stopTest();
       
}

     Public static testmethod void OutboundIVRCallBatchMethod2(){ 
        loadData();
        
        test.StartTest();
       
        Case objCase = [SELECT id,LP_CL_Status__c from Case limit 1];
        objCase.LP_CL_Status__c = '1';
        update objCase;
        OutboundIVRSchedulePL sh2 = new OutboundIVRSchedulePL();
        String sch2 = '0 0 2 * * ?'; 
        system.schedule('Check1', sch2, sh2);
        
        
       // CollectionNotificationUtility.createHTTPPublisher('res','Case','res');
        test.stopTest();
       
}
    
      Public static testmethod void OutboundIVRCallBatchMethod3(){ 
        loadData();
        
        test.StartTest();
       
        Case objCase = [SELECT id,LP_CL_Status__c from Case limit 1];
        objCase.LP_CL_Status__c = '1';
        update objCase;
        OutboundIVRScheduleAdditional sh2 = new OutboundIVRScheduleAdditional();
        String sch2 = '0 0 2 * * ?'; 
        system.schedule('Check1', sch2, sh2);
        
        
       // CollectionNotificationUtility.createHTTPPublisher('res','Case','res');
        test.stopTest();
       
}
    
    
    
    public static void LoadData() {   
        
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Outbound_IVR_Queue_Collection', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        Id queueID = [SELECT Id,DeveloperName,Name FROM Group WHERE type ='queue' AND DeveloperName = 'LP_Outbound_IVR_Queue_Collection'].id;
        
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
        oCase1.LP_Customer_Score__c=5;
        oCase1.LP_Manual_Call__c=1;
        oCase1.LP_Due_Since__c = Date.today().addDays(-26);
        oCase1.LP_Outstanding_Amount__c = 5445;
        oCase1.LP_SMS__c=1;
        oCase1.LP_Email__c=1;
        oCase1.LP_CL_Status__c = '0';
        oCase1.LP_APP_Notification__c=1;
        oCase1.LP_Communication_Type__c='Unaware';
        oCase1.LP_Communication_sub_type__c='type_u6';
        oCase1.LP_IVR_Call_Count__c=1;
        oCase1.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();        
        oCase1.Status='New';      
        oCase1.ContactId=oContact.id;
        String dateStr = Date.today().format();
        oCase1.Collection_Rule_Time__c = dateStr;
        insert oCase1;
        system.debug('case'+oCase1);
        
        
    }
   
    
}