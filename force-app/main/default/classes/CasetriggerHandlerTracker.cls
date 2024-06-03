/**
@author:            jatin arora
@company:           SaaSFocus
@description:       cover CasetriggerHandler,lazyPayPublish
@history
<Date>        <Authors Name>        
24-Sep-18     jatin arora          
**/
@isTest(seealldata=false)
public class CasetriggerHandlerTracker {
    
    public static LP_KYC_Document__c oKYCDocument;
    public static Trigger_Switch__c osetting;
     public static Contact ocontact;
    public static boolean isTriggerExecuted  = false; 
    
   
 public static void LoadData()
    {
        //Insert  Custom setting 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        Id KYCRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.recordTypeId = KYCRecordTypeId;
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='test';
        insert oCase;
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Verified';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument;   
    }
     public static void LoadData1()
    {
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        /*Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.Id, SObjectType = 'Case');
        insert testQueue;*/
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
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
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Verified';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument; 
        
         Id childcaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ChildCase').getRecordTypeId();
       contact oContact1;
        oContact1=new contact();
        oContact1.LastName='test';
        oContact1.Email='test@test.com';
        oContact1.MobilePhone='1234567890';
        insert oContact1;
        test.startTest();
        Case oCase1;
        oCase1=new Case();
        oCase1.RecordTypeId = childcaseRecordTypeId;
        oCase1.Status='new';
        oCase1.Priority='High';
        oCase1.ContactId=oContact.id;
        oCase1.LP_KYC_Last_Modified_Date__c = System.now();
       // oCase.LP_KYC_State__c ='User Documents Pending';
        oCase1.Comments='test';
        insert oCase1; 
        
        oCase1.Status = 'closed';
        update oCase1;
        
        
        
    }
     public static void LoadData2()
    {
        // Custom Settings 
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='{"ivr_type": "type_c3", "call_date": "2019-02-12", "call_uuid": "9bac87f0-dacc-41fe-a8e6-b5bd039f66ed_0", "customer_status": "Connected", "customer_call_duration": "0:00:11", "call_time": "20:50:09", "legA_hangup_cause": "900", "customer_number": "+919818960069"}';
        insert oCase;
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Verified';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument;   
    }
    
    public static void LoadData6()
    {
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        oContact.Identifier__c = '4355';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_Outstanding_Amount__c = 10;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_RecordTypeName__c ='Collection';
        oCase.LP_UUID_For_Collection__c = '4355';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        oCase.LP_IVR_Call_Response__c='{"ivr_type": "type_c3", "call_date": "2019-02-12", "call_uuid": "9bac87f0-dacc-41fe-a8e6-b5bd039f66ed_0", "customer_status": "Connected", "customer_call_duration": "0:00:11", "call_time": "20:50:09", "legA_hangup_cause": "900", "customer_number": "+919818960069"}';
        insert oCase;
        
          
    }
    
    public static void LoadData8()
    {
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test2@test.com';
        oContact.MobilePhone='1236567890';
        oContact.Identifier__c = '4375';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_Outstanding_Amount__c = 10;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_RecordTypeName__c ='Collection';
        oCase.LP_UUID_For_Collection__c = '4375';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        oCase.LP_IVR_Call_Response__c='{"ivr_type": "type_c3", "call_date": "2019-02-12", "call_uuid": "9bac87f0-dacc-41fe-a8e6-b5bd039f66ed_0", "customer_status": "Connected", "customer_call_duration": "0:00:11", "call_time": "20:50:09", "legA_hangup_cause": "900", "customer_number": "+919818960069"}';
        insert oCase;
        
          
    }
    
    public static void LoadData7()
    {
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test1@test.com';
        oContact.MobilePhone='2234567890';
        oContact.Identifier__c = '4359';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_Outstanding_Amount__c = 10;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_RecordTypeName__c ='Collection';
        oCase.LP_UUID_For_Collection__c = '4359';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        oCase.LP_IVR_Call_Response__c='{"ivr_type": "type_c3", "call_date": "2019-02-12", "call_uuid": "9bac87f0-dacc-41fe-a8e6-b5bd039f66ed_0", "customer_status": "Connected", "customer_call_duration": "0:00:11", "call_time": "20:50:09", "legA_hangup_cause": "900", "customer_number": "+919818960069"}';
        insert oCase;
        
          
    }
    
     public static void LoadData3()
    {
         SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Pending';
        oCase.Priority='High';
        oCase.ContactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.LP_IVR_Call_Response__c='test';
        oCase.LP_Sub_Status__c = 'Cannot Resolve';
        insert oCase;
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Verified';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument;   
    }
    @isTest
    public static void validateVerifiedTest(){
        LoadData();
        Test.startTest();
        oKYCDocument.LP_status__c ='Pending';
        update oKYCDocument;
           LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '{"Name": "sForceTest1"}',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L1 KYC Queue'].Id;
        system.debug('q id : '+queueId);
      
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Case oCase = [Select id from Case Limit 1];
        oCase.Status='Verified';
        oCase.OwnerId=queueId;
        oCase.LP_IVR_Call_Response__c='{"ivr_type": "type_c3", "call_date": "2019-02-12", "call_uuid": "9bac87f0-dacc-41fe-a8e6-b5bd039f66ed_0", "customer_status": "Connected", "customer_call_duration": "0:00:11", "call_time": "20:49:09", "legA_hangup_cause": "900", "customer_number": "+919718960069"}';
        update oCase;
        Test.stopTest();
    }  
     public static void validateVerifiedTestone(){
        LoadData();
        Test.startTest();
        oKYCDocument.LP_status__c ='Pending';
        update oKYCDocument;
           LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L1 KYC Queue'].Id;
        system.debug('q id : '+queueId);
         
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator; 
      
        Case oCase = [Select id from Case Limit 1];
        oCase.Status='pending';
        oCase.OwnerId=queueId;
        oCase.LP_IVR_Call_Response__c='{"ivr_type": "type_c3", "call_date": "2019-02-12", "call_uuid": "9bac87f0-dacc-41fe-a8e6-b5bd039f66ed_0", "customer_status": "Connected", "customer_call_duration": "0:00:11", "call_time": "20:49:09", "legA_hangup_cause": "900", "customer_number": "+919718960069"}';
        update oCase;
        Test.stopTest();
    }  
    @isTest
    public static void validateVerifiedTestone4(){
        LoadData7();
        Test.startTest();
        
           LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Case oCase = [Select id,LP_IVR_Call_Response__c from Case Limit 1];
        oCase.LP_Outstanding_Amount__c = 0;
        oCase.LP_Manual_Call_Response__c='{"customer_status": "Connected", "call_time": "20:39:29", "ivr_type": "none", "agent_number": "+919999709773", "call_type": "C2C", "call_date": "2019-02-12", "agent_list": "+919999709773", "customer_call_duration": "0:00:24", "lega_hangup_cause": "legA_hangup_cause", "customer_number": "+919718960069", "call_uuid": "411e08cf-7a7c-4ac1-8975-36dcdddfb1b3_0", "recording_url": "https://sr.knowlarity.com/vr/fetchsound/?callid=411e08cf-7a7c-4ac1-8975-36dcdddfb1b3", "call_transfer_duration": "00:00:09"}';
            update oCase;
        Test.stopTest();
    } 
    @isTest
    public static void validateVerifiedTestone3(){
        LoadData8();
        Test.startTest();
        
           LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);  
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Case oCase = [Select id,LP_IVR_Call_Response__c from Case Limit 1];
        oCase.LP_Outstanding_Amount__c = 0;
        oCase.LP_IVR_Call_Response__c='{"ivr_type": "type_c3", "call_date": "2019-02-13", "call_uuid": "9bac87f0-dacc-41fe-a8e6-b5bd039f66ed_0", "customer_status": "Connected", "customer_call_duration": "0:00:11", "call_time": "20:49:09", "legA_hangup_cause": "900", "customer_number": "+919718960069"}';
        update oCase;
        Test.stopTest();
    }  
    @isTest
    public static void validateVerifiedTest1(){
        LoadData2();
        Test.startTest();
        oKYCDocument.LP_status__c ='Pending';
        update oKYCDocument;
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L1 KYC Queue'].Id;
        system.debug('q id : '+queueId);
      
        Case oCase = [Select id from Case Limit 1];
       
        Test.stopTest();
    }  
     @isTest
    public static void assignBackToL1AgentTest(){
       Test.startTest();
        LoadData();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        case oCase = [SELECT id FROM Case LIMIT 1];
        
        oCase.status='Verified';
        update oCase;
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        system.debug('q id : '+queueId);
        oCase.Status='Pending';
        oCase.OwnerId=queueId;
        update oCase;
        Test.stopTest();
    }      
     @isTest
    public static void validateSubStatusL2(){
        LoadData();
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Pending';
        oCase.LP_Sub_Status__c = 'Assign to checker';
        update oCase;
        
        Test.stopTest();
        
    } 
     @isTest
    public static void validateSubStatusL2SECOND(){
        LoadData();
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Verified';
        oCase.LP_Sub_Status__c = NULL;
        update oCase;
        
        Test.stopTest();
        
    } 
     @isTest
    public static void validateSubStatusL2third(){
        LoadData();
        Test.startTest();
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Pending';
        oCase.LP_Sub_Status__c = 'Additional Documents Requested';
        update oCase;     
        Test.stopTest();
        
    } 
  @isTest
    public static void validateSubStatusL2FOURTH(){
        LoadData1();
       // Test.startTest();
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Approved';
        oCase.LP_Sub_Status__c = NULL;
        update oCase;   
         oCase.Status='Rejected';
       // Test.stopTest();
        
    } 
     @isTest
    public static void validateSubStatusL2FIFTH(){
        LoadData1();
       // Test.startTest();
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Rejected';
        oCase.LP_Sub_Status__c = NULL;
        update oCase;   
         
       // Test.stopTest();
        
    } 
     @isTest
    public static void validateSubStatusL1(){
        LoadData();
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L1 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Pending';
        oCase.LP_Sub_Status__c = 'Additional Documents Requested';
        update oCase;
        
        Test.stopTest();
        
    } 
   @isTest
    public static void contactTriggerHandlerMethod1(){
        LoadData();
       // Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Verified';
        update oCase;
        
       // Test.stopTest();
        
    }  
    
    @isTest
    public static void validateApproved(){
        LoadData();
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Verified';
        update oCase;
         Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        GroupMember objMem = new GroupMember(GroupId = queueId, UserOrGroupId = userInfo.getUserId());
        
        oCase.Status='Approved';
        //oCase.LP_Sub_Status__c = 'Additional Documents Requested';
        update oCase;
        
        oCase.Status='Rejected';
        update oCase;
        
        Test.stopTest();
        
    } 
    
     @isTest
    public static void KYCCasePublishtest(){
        LoadData();
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id FROM Case LIMIT 1]; 
        oCase.Status='Pending';
        //oCase.LP_Sub_Status__c = 'Additional docs required_L1';
        update oCase;
        
        Test.stopTest();
}
    
    @isTest
    public static void contactTriggerHandlerMethod2(){
        LoadData();
        Test.startTest();
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        case oCase = [SELECT id,LP_Manual_Call_Status__c FROM Case LIMIT 1]; 
        system.debug('LP_Manual_Call_Status__c======='+oCase.LP_Manual_Call_Status__c);
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        oCase.LP_Manual_Call_Status__c='Not Available';
        oCase.LP_Manual_Call_Sub_Status__c ='No answer';
        update oCase;       
        Test.stopTest();        
    } 
    
     public static void careData()
    {
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Open';
        oCase.Priority='Medium';
        oCase.ContactId=oContact.id;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId(); 
        insert oCase;
        
           
    }
    
    public static void careData1()
    {
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='New';
        oCase.Priority='Medium';
        oCase.SuppliedEmail = 'test1@test.com';
        oCase.SuppliedName = 'test';
        oCase.LP_Business_Vertical__c = 'LazyPay';
        oCase.LP_Category__c = 'LazyPay';
        //oCase.ContactId=oContact.id;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId(); 
        insert oCase;
        
           
    }
    
    public static void MerchantCareData()
    {
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        Id L2queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 Payu Money'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Case oCase;
        oCase=new Case();
        oCase.Status='Open';
        oCase.Priority='Medium';
        oCase.L2_Queue_Id__c = L2queueId;
        oCase.SuppliedEmail = 'test1@test.com';
        oCase.SuppliedName = 'test';
        oCase.LP_TAT__c = '3';
        oCase.LP_Business_Vertical__c = 'PayU Money';
        oCase.LP_Category__c = 'PayU Money';
        oCase.ContactId=oContact.id;
        oCase.LOB_Name__c='Payu Money';
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        insert oCase;
        
           
    }
    
     public static void ChildCaseData()
    {
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
         User u = new User(
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
        
        Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        Id L2queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 Payu Money'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;      
        
         Case oCase;
        oCase=new Case();
        oCase.Status='Open';
        oCase.Priority='Medium';
        oCase.L2_Queue_Id__c = L2queueId;
        oCase.SuppliedEmail = 'test1@test.com';
        oCase.SuppliedName = 'test';
        oCase.LP_TAT__c = '3';
        oCase.LP_Business_Vertical__c = 'PayU Money';
        oCase.LP_Category__c = 'PayU Money';
        oCase.ContactId=oContact.id;
        oCase.OwnerId = u.Id;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
        insert oCase;
        
        Case childCase;
        childCase=new Case();
        childCase.Status='Open';
        oCase.OwnerId = u.Id;
        childCase.Priority='Medium';
        childCase.L2_Queue_Id__c = L2queueId;
        childCase.SuppliedEmail = 'test1@test.com';
        childCase.SuppliedName = 'test';
        childCase.LP_TAT__c = '3';
        childCase.LP_Business_Vertical__c = 'PayU Money';
        childCase.LP_Category__c = 'PayU Money';
        childCase.Parent_Case__c = oCase.Id;
        childCase.ContactId=oContact.id;
        childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId(); 
        insert childCase;
                
           
    }
    
    @isTest
    public static void MCTestMethod(){
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        MerchantCareData();
        //ChildCaseData();
        Test.startTest();
        User managerUser = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchant Care Parent'].Id,
         LastName = 'lastManger',
         Email = 'puser000@amanager.com',
         Username = 'puser000@manager.com' + System.currentTimeMillis(),
         CompanyName = 'TEST Payu',
         Title = 'title',
         Alias = 'aliasP',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US'
         //UserRoleId = r.Id
    );
        insert managerUser;
        User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchant Care Parent'].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
            managerId=managerUser.Id
         //UserRoleId = r.Id
    );
        insert u;
        
        
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        system.assertEquals(managerUser.Id, u.ManagerId);
        Case objCase = [SELECT id,status from Case limit 1];
        objCase.status = 'Resolved';
        objCase.Comments = 'resolved';
        objCase.isAutoClosed__c = true;
        objCase.Is_Violated__c = true;
        objCase.Is_L2_Violated__c = true;
        objCase.Is_L3_Violated__c = true;
       // objCase.ownerId = u.id;
        objCase.LOB_Name__c='Buyer Care';
        update objCase;
        MilestoneUtils.sendEmails(new list<Case>{objCase}, 'Violation Notification to Parent to Manager');
        Test.stopTest();
    }
    
    @isTest
    public static void ChildCaseTestMethod(){
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        MerchantCareData();
        //ChildCaseData();
        Test.startTest();
        User u = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'Merchant Care Parent'].Id,
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
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Account AccountObj = new Account();
        AccountObj.Name = 'strName';
        AccountObj.PAN_Number__c = 'AFPPH1444D';
        //AccountObj.Legal_Name__c = strLegalName;
        AccountObj.PAN_Holder_Name__c = 'Pan Holder';
        insert AccountObj;
        Case objCase = [SELECT id,status from Case limit 1];
        objCase.status = 'Pending';
        objCase.AccountId = AccountObj.Id;
        objCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        objCase.Comments = 'resolved';
        //objCase.Is_Violated__c = true;
        objCase.ownerId = u.id;
        update objCase;
        Test.stopTest();
    }
    
    @isTest
    public static void ChildCaseTestMethod1(){
         SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        ChildCaseData();
        Test.startTest();
       
         LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Case objCase = [SELECT id,status from Case where recordtype.name = 'MerchantChildCase'];
        objCase.isAutoClosed__c = true;
        objCase.Is_Violated__c = true;
        objCase.Comments = 'resolved';
        update objCase;
        Test.stopTest();
    }
    @isTest
    public static void contactTriggerHandlerMethod4(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        careData();
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        case oCase = [SELECT id,status,LP_Sub_status__c FROM Case LIMIT 1];
        system.assertEquals('Open',oCase.Status);
        oCase.Status='Resolved';
        oCase.Comments='test';
        oCase.LP_Sub_Status__c = 'Waiting On Customer';
        
       // update oCase;
        
        oCase.Status = 'Pending';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        oCase.Comments = null;
        update oCase;
        
        oCase.LP_Sub_Status__c = 'Waiting On Pre-Onboarding Risk';
        oCase.Comments = 'test hbsd';
        update oCase;
        Test.stopTest();        
    }   
    
    @isTest
    public static void contactTriggerHandlerMethod5(){
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        careData1();
        Test.startTest();
       
        case oCase = [SELECT id,status,LP_Sub_status__c,LP_Category__c FROM Case LIMIT 1]; 
        oCase.LP_Business_Vertical__c = 'LazyPay';
        oCase.LP_Category__c = 'LazyPay'; 
        update oCase;
        Test.stopTest();        
    }   
    @isTest
    public static void contactTriggerHandlerMethod7(){
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        careData();
        Test.startTest();
        LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Id CareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        case oCase = [SELECT id,status,LP_Sub_status__c FROM Case LIMIT 1]; 
        oCase.Status='Pending';
        oCase.RecordTypeId = CareRecordTypeId;
        oCase.Comments='test';      
        oCase.LP_Sub_Status__c = 'Waiting On Customer';      
        update oCase;    
      //  oCase.LP_Sub_Status__c = 'Waiting On Customer';
       oCase.Status='Resolved';
        oCase.LP_Sub_Status__c = ''; 
       update oCase;
        Test.stopTest();        
    } 
    
      @isTest
    public static void contactTriggerHandlerMethod8(){
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Id childcaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ChildCase').getRecordTypeId();
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        test.startTest();
        Case oCase1;
        oCase1=new Case();
        oCase1.RecordTypeId = childcaseRecordTypeId;
        oCase1.Status='new';
        oCase1.Priority='High';
        oCase1.ContactId=oContact.id;
        oCase1.LP_KYC_Last_Modified_Date__c = System.now();
       // oCase.LP_KYC_State__c ='User Documents Pending';
        oCase1.Comments='test';
        insert oCase1; 
        oCase1.Status='Closed';
        update oCase1;
        system.debug('childrecord!!'+oCase1);
        test.stopTest();
    }
    @isTest
    public static void unitTest(){
         Id childcaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        test.startTest();
        Case oCase1;
        oCase1=new Case();
        oCase1.RecordTypeId = childcaseRecordTypeId;
        oCase1.Status='new';
        oCase1.Priority='High';
        oCase1.ContactId=oContact.id; 
        insert ocase1;
        oCase1.Status = 'Verified';
        update oCase1;
        test.stopTest();
    }
    
    /*
     @isTest
    public static void ChildCaseForOneCareProcessHandler(){
        User u = new User(
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
        
        System.runAs(u) {
            Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
        
        Id L2queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 Payu Money'].Id;
        
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
            
         List<Child_Case_Queue__mdt> metadataList = [Select id,MasterLabel,SubStatus__c,QueueId__c,Queue_Manager_Id__c FROM Child_Case_Queue__mdt];
            System.debug('>>>>>>>>>>'+metadataList);
        
        Account AccountObj = new Account();
        AccountObj.Name = 'strName';
        AccountObj.PAN_Number__c = 'AFPPH1444D';
        //AccountObj.Legal_Name__c = strLegalName;
        AccountObj.PAN_Holder_Name__c = 'Pan Holder';
        insert AccountObj;
        
         Case oCase;
        oCase=new Case();
        oCase.Status='Open';
        oCase.Priority='Medium';
        oCase.L2_Queue_Id__c = L2queueId;
        oCase.SuppliedEmail = 'test1@test.com';
        oCase.SuppliedName = 'test';
        oCase.LP_TAT__c = '3';
        oCase.LP_Business_Vertical__c = 'PayU Money';
        oCase.LP_Category__c = 'PayU Money';
        oCase.ContactId=oContact.id;
        oCase.OwnerId = u.Id;
        oCase.Status = 'No Resolution From Other Teams';
        oCase.Is_Violated__c = true;
        oCase.Is_L2_Violated__c = false;
        oCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId(); 
       
        insert oCase;
        
        Case childCase;
        childCase=new Case();
        childCase.Status='Open';
        //oCase.OwnerId = u.Id;
        childCase.Priority='Medium';
        childCase.L2_Queue_Id__c = L2queueId;
        childCase.SuppliedEmail = 'test1@test.com';
        childCase.SuppliedName = 'test';
        childCase.LP_TAT__c = '3';
        childCase.LP_Business_Vertical__c = 'PayU Money';
        childCase.LP_Category__c = 'PayU Money';
        childCase.Parent_Case__c = oCase.Id;
        childCase.ContactId=oContact.id;
        childCase.AccountId = AccountObj.Id;
        childCase.Comments = 'Test';  
        childCase.isAutoClosed__c = true;
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(AccountObj.Id);
        childCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId(); 
        insert childCase;
            List<Case> caseList = new List<Case>();
        caseList.add(childCase);
        
        oneCareProcessHandler.createChildCase(caseList, accIdSet, 'MerchantChildCase');
        oneCareProcessHandler.updateCaseCommentsOnParent(caseList);
        }
        
        
    }
    
    @isTest
    private static void testMethod1(){
        LoadData1();
        /*Group testGroup = [SELECT Id FROM Group WHERE Name='test group'];
        QueuesObject testQueue = [SELECT Id FROM QueuesObject LIMIT 1];
        Child_Case_Queue__mdt ccq = new Child_Case_Queue__mdt(MasterLabel = 'tst mdt', DeveloperName = 'tst', QueueId__c = testQueue.Id,
                                                             SubStatus__c = 'Waiting On Product', Queue_Manager_Id__c = UserInfo.getUserId());*/
       /* Id CareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        Case oCase = [SELECT Id, Subject FROM Case WHERE LP_KYC_State__c ='User Documents Pending'];
        oCase.Subject = 'test subj';
        oCase.RecordTypeId = CareRecordTypeId;
        oCase.Status = 'Pending';
        oCase.Comments = 'test comments';
        oCase.LP_Sub_Status__c = 'Assign to checker';
        //Test.startTest();
        update oCase;
        //Test.stopTest();
    }   
 
    @isTest
    private static void testMethod2(){
        LoadData1();
        Id MerchantchildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        Case oCase = [SELECT Id, Subject FROM Case WHERE LP_KYC_State__c ='User Documents Pending'];
        oCase.Subject = 'test subj';
        oCase.RecordTypeId = MerchantchildCaseRecordTypeId;
        oCase.Status = 'Pending';
        oCase.Is_Violated__c = true;
        oCase.Is_L2_Violated__c = false;
        oCase.Comments = 'test comments';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        oCase.OwnerId = userInfo.getUserId();
        update oCase;
    }   
    
    @isTest
    private static void testMethod3(){
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Id MerchantchildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        Case oCase = new Case();
        oCase.RecordTypeId = MerchantchildCaseRecordTypeId;
        oCase.ContactId=oContact.id;
        oCase.Subject = 'test subj';
        oCase.LP_TAT__c = '3';
        oCase.Comments = 'test comments';
        oCase.LP_Sub_Status__c = 'Pending';
        test.startTest();
        insert oCase;
        oCase.Status = 'Closed';
        oCase.LP_Sub_Status__c = 'Assign to checker';
        oCase.Is_Violated__c = true;
        oCase.Is_L2_Violated__c = false;
        oCase.Comments='';
        update oCase;
        test.stopTest();
    }   
    
    @isTest
    private static void testMethod4(){
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='Case';
        insert osetting;
        
        
        oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        Id ChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        Case oCase = new Case();
        oCase.RecordTypeId = ChildRecordTypeId;
        oCase.ContactId=oContact.id;
        oCase.Subject = 'test subj';
        oCase.Comments = 'test comments';
        oCase.LP_TAT__c = '3';
        oCase.LP_Sub_Status__c = 'Waiting On Buyer';
        test.startTest();
        insert oCase;
        oCase.Status = 'Closed';
        oCase.LP_Sub_Status__c = 'Waiting On Merchant';
        update oCase;
        oCase.Status = 'Waiting On Salesforce Team';
        update oCase;
        test.stopTest();
    }*/   
}