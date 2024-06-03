@isTest(seealldata= false)
public class KYCRuleEngineScheduletracker{ 
    public static QueuesObject testQueue;
    public static Contact ocontact;
    public static case oCase;
    public static Group testGroup;
    
  /*  Public static testmethod void test1(){       
        Test.startTest();
        loaddata();       
        KYCRuleEngineSchedule sh1 = new KYCRuleEngineSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Check', sch, sh1);      
        Test.stopTest();
    }*/
    Public static testmethod void test2(){      
        
        loaddata();
        oCase.LP_KYC_Last_Modified_Date__c=date.today().adddays(-10);
     //   oCase.LP_IVR_Call_Count_Per_Day__c=0;
        oCase.LP_KYC_State__c='Initiated';
        oCase.LP_Onboarding_Status__c='KYC Pending';
        update oCase;
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
        Test.startTest();
        
        KYCRuleEngineSchedule sh1 = new KYCRuleEngineSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Check', sch, sh1); 
        Test.stopTest();
    }
     Public static testmethod void test5(){      
        
        loaddata1();
        
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
        Test.startTest();
        
        KYCRuleEngineSchedule sh1 = new KYCRuleEngineSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Check', sch, sh1); 
        Test.stopTest();
    }
    
    Public static testmethod void test6(){      
        
        loaddata3();
        
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
        Test.startTest();
        
        KYCRuleEngineSchedule sh1 = new KYCRuleEngineSchedule();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Check', sch, sh1); 
        Test.stopTest();
    }
    public static void LoadData()
    { 
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Outbound_IVR_Queue_KYC', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        oCase = new Case();
        oCase.OwnerId = testGroup.Id;
        oCase.Status='New';       
        oCase.ContactId=oContact.id;
        oCase.LP_IVR_Call__c=2;
        oCase.LP_KYC_Last_Modified_Date__c=date.today().adddays(-5);
        oCase.LP_IVR_Call_Count_Per_Day__c=1;
        oCase.LP_Notification_1__c=5;
        oCase.LP_Notification_2__c=10;
        oCase.LP_Notification_3__c=0;
        oCase.LP_Notification_4__c=4;
        oCase.LP_Manual_Call__c=1;
        oCase.LP_Type_of_IVR__c='abc';
        oCase.LP_KYC_State__c='Manual Documents Declined';
        oCase.LP_Onboarding_Status__c='Awaiting Nach File';
        oCase.LP_Status_Priority_Order__c=2;
        oCase.LP_IVR_Id__c = '66990';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();        
        insert oCase;
    }   
    
    public static void LoadData1()
    { 
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Outbound_IVR_Queue_KYC', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        oCase = new Case();
        oCase.OwnerId = testGroup.Id;
        oCase.Status='New';       
        oCase.ContactId=oContact.id;
        oCase.LP_IVR_Call__c=2;
        oCase.LP_KYC_Last_Modified_Date__c=date.today().adddays(-5);
        oCase.LP_IVR_Call_Count_Per_Day__c=1;
        oCase.LP_Notification_1__c=5;
        oCase.LP_Notification_2__c=10;
        oCase.LP_Notification_3__c=0;
        oCase.LP_Notification_4__c=4;
        oCase.LP_Manual_Call__c=1;
        oCase.LP_Type_of_IVR__c='abc';
        oCase.LP_KYC_State__c='Manual Marked Success';
        oCase.LP_Onboarding_Status__c='Post KYC DS Check Completed';
        oCase.LP_Status_Priority_Order__c=2;
        oCase.LP_IVR_Id__c = '66990';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();        
        insert oCase;
    }   
    
    public static void LoadData3()
    { 
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Outbound_IVR_Queue_KYC', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        oCase = new Case();
        oCase.OwnerId = testGroup.Id;
        oCase.Status='New';       
        oCase.ContactId=oContact.id;
        oCase.LP_IVR_Call__c=2;
        oCase.LP_KYC_Last_Modified_Date__c=date.today().adddays(-30);
        oCase.LP_IVR_Call_Count_Per_Day__c=1;
        oCase.LP_Notification_1__c=5;
        oCase.LP_Notification_2__c=10;
        oCase.LP_Notification_3__c=0;
        oCase.LP_Notification_4__c=4;
        oCase.LP_Manual_Call__c=1;
        oCase.LP_Type_of_IVR__c='abc';
        oCase.LP_KYC_State__c='Manual Marked Success';
        oCase.LP_Onboarding_Status__c='Post KYC DS Check Completed';
        oCase.LP_Status_Priority_Order__c=2;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        oCase.LP_IVR_Id__c = '66990';        
        insert oCase;
    }   
}