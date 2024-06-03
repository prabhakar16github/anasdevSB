@isTest(seealldata=false)
public class OutbondIVRCallBatchtracker{ 
    public static QueuesObject testQueue;
    public static QueuesObject testQueue1;
    public static Contact ocontact;
    public static Case oCase1;
    public static Case oCase2;
    public static Group testGroup;
    public static Group testGroup1;
    
    Public static testmethod void OutboundIVRCallBatchMethod(){             
        
        test.StartTest();
        loadData();
        OutboundIVRCallBatch obj = new OutboundIVRCallBatch();
        database.executeBatch(obj);
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
        oCase1.LP_APP_Notification__c=1;
        oCase1.LP_Communication_Type__c='Unaware';
        oCase1.LP_Communication_sub_type__c='type_u6';
        oCase1.LP_IVR_Call_Count__c=1;
        oCase1.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();        
        oCase1.Status='New';      
        oCase1.ContactId=oContact.id;
        oCase1.LP_CL_Status__c = '0';
        oCase1.Collection_Rule_Time__c = Date.Today().format();
        insert oCase1;
        system.debug('case'+oCase1);
        
        
    }
   
    /*public static void loadData2() {   
        
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Outbound_IVR_Queue_Collection', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact; 
        
        oCase2=new Case();
        oCase2.OwnerId = testGroup.Id;
        oCase2.Priority='Medium';
        oCase2.LP_IVR_Call__c=0;
        oCase2.LP_Customer_Score__c=6.5;
        oCase2.LP_Manual_Call__c=0;
        oCase2.LP_Due_Since__c = Date.today().addDays(-14);
        oCase2.LP_Outstanding_Amount__c = 4000;
        oCase2.LP_SMS__c=1;
        oCase2.LP_Email__c=0;
        oCase2.LP_APP_Notification__c=1;       
        oCase2.LP_Communication_Type__c='Intentional Default';
        oCase2.LP_Communication_sub_type__c='type_i6';
        oCase2.LP_IVR_Call_Count__c=1;
        oCase2.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();        
        oCase2.Status='New';      
        oCase2.ContactId=oContact.id;
        insert oCase2;
        system.debug('case'+oCase2);
    }
    
    public static void loadData5() {   
        
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Outbound_IVR_Queue_Collection', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
        }
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact; 
        
        oCase2=new Case();
        oCase2.OwnerId = testGroup.Id;
        oCase2.Priority='Medium';
        oCase2.LP_IVR_Call__c=0;
        oCase2.LP_Customer_Score__c=4.5;
        oCase2.LP_Manual_Call__c=0;
        oCase2.LP_Due_Since__c = Date.today();
        oCase2.LP_Outstanding_Amount__c = 56;
        oCase2.LP_SMS__c=1;
        oCase2.LP_Email__c=0;
        oCase2.LP_APP_Notification__c=1;       
        oCase2.LP_Communication_Type__c='Intentional Default';
        oCase2.LP_Communication_sub_type__c='type_i6';
        oCase2.LP_IVR_Call_Count__c=1;
        oCase2.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();        
        oCase2.Status='New';      
        oCase2.ContactId=oContact.id;
        insert oCase2;
        system.debug('case'+oCase2);
    }
    public static void loadData3() {   
        
        User aUser = [ SELECT Id FROM User WHERE  id=:userinfo.getuserid()];        
        system.runAs(aUser){ 
            testGroup = new Group(Name='LP_Email_Queue', type='queue');
            insert testGroup;
            system.debug('testGroup'+testGroup);
            
            testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            system.debug('testQueue'+testQueue);
            
            testGroup1 = new Group(Name='LP_Outbound_IVR_Queue_Collection', type='queue');
            insert testGroup1;
            
            testQueue1 = new QueueSObject(QueueID = testGroup1.id, SobjectType = 'Case');
            insert testQueue1;
            
        }
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact; 
        
        oCase2=new Case();
        oCase2.OwnerId = testGroup1.Id;
        oCase2.Priority='Medium';
        oCase2.LP_IVR_Call__c=1;
        oCase2.LP_Customer_Score__c=0.02;
        oCase2.LP_Manual_Call__c=0;
        oCase2.LP_Due_Since__c = Date.today().addDays(-25);
        oCase2.LP_Outstanding_Amount__c = 90;
        oCase2.LP_SMS__c=0;
        oCase2.LP_Email__c=1;
        oCase2.LP_APP_Notification__c=1;       
        oCase2.LP_Communication_Type__c='Intentional Default';
        oCase2.LP_Communication_sub_type__c='type_i6';
        oCase2.LP_IVR_Call_Count__c=1;
        oCase2.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();        
        oCase2.Status='New';      
        oCase2.ContactId=oContact.id;
        insert oCase2;
        system.debug('case'+oCase2);
    }*/
}