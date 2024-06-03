/**
@author:            Shivdeep
@description:       Test class for OneCareAgentWorktriggerHandler
@history
<Date>        11/11/2019          
**/
@isTest(seealldata=true)

public class OneCareAgentWorktriggerHandlerTracker {
    public static Case oCase;
    public static Contact oContact;
    public static LP_KYC_Document__c oKYCDocument;
    public static Trigger_Switch__c osetting;
    public static Agentwork oAgentwork;
    public static list<case> lst;
    public static User oUser;
    @isTest
    static void test(){
         
        LoadData();
        LoadData1();
        //Test.startTest();
       
        system.runAs(oUser){
            LP_KYC_DocumentControllerMock fakeResponse = new LP_KYC_DocumentControllerMock(200,
                                                 'Complete',
                                                 '[{"Name": "sForceTest1"}]',
                                                 null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
            AgentWork objAgentWork = createAgentWorks(lst[0],oUser);
            system.debug('##### '+objAgentWork);
            insert objAgentWork;
            //objAgentWork.workItemId = lst[0].id;
            update objAgentWork;
            
            
        }
        //Test.stopTest();
    }
    public static void LoadData()
    {  
        Test.startTest();
        profile obj=[select id from profile where name='system administrator' limit 1];
        oUser = [Select id from user where id=:userinfo.getUserId()];
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='AgentWork';
        insert osetting; 
        
                oContact=new contact();
        oContact.LastName='test';
        oContact.Email='test@test.com';
        oContact.MobilePhone='1234567890';
        insert oContact;
        
        oCase=new Case();
        oCase.Status='Resolved';
        oCase.Priority='High';
        oCase.contactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        oCase.OwnerId=[select id from group where developername ='L1_KYC_Queue'].id;
        insert oCase;
                
        lst =new list<case>();
        lst.add(oCase);
        
        Status_SLA__c oStatusSLA = new Status_SLA__c();
		oStatusSLA.CreatedById = oUser.id;
        oStatusSLA.Case__c = oCase.id;
        insert oStatusSLA;
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Verified';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument;
        Test.stopTest();
        
    }
    
   
    public static void LoadData1()
    {  
       // Test.startTest();
        profile obj=[select id from profile where name='system administrator' limit 1];
        oUser = [Select id from user where id=:userinfo.getUserId()];
        
        osetting = new Trigger_Switch__c();
        osetting.Active__c=true;
        osetting.Name='AgentWork11';
        insert osetting; 
        
        oContact=new contact();
        oContact.LastName='test1';
        oContact.Email='test11@test.com';
        oContact.MobilePhone='12345617890';
        insert oContact;
        
        oCase=new Case();
        oCase.Status='New';
        //oCase.OwnerId='00G7F000000XofPUAS';
       
        oCase.Priority='Medium';
        oCase.contactId=oContact.id;
        oCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to case Parent').getRecordTypeId();
        oCase.OwnerId=[select id,developername from group where developername ='Waiting_On_PUM_Farming'].id;
        oCase.OwnerId='0057F000005wg1HQAQ';
        insert oCase;
		
        oCase.Status='Pending';
        oCase.LP_Sub_Status__c='Waiting On Merchant';
        oCase.OwnerId='00G7F000000XofPUAS';
        update oCase;
        oCase.Status='Open';
        update oCase;
        
        lst =new list<case>();
        lst.add(oCase);
        
         Error_details__c ed = new Error_details__c();
        ed.Message__c='error message';
        
        insert ed;
        
        Status_SLA__c oStatusSLA = new Status_SLA__c();
		oStatusSLA.CreatedById = oUser.id;
        oStatusSLA.Case__c = oCase.id;
        insert oStatusSLA;
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Verified';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument;
       //Test.stopTest();
        
    }
    
    public static AgentWork createAgentWorks(case objcase, User user) {
        ServiceChannel sc = [SELECT Id
                             FROM ServiceChannel
                             WHERE DeveloperName = 'LP_Case_Assignment'
                             LIMIT 1];
        PresenceUserConfig puc = [SELECT Id
                                  FROM PresenceUserConfig
                                  WHERE DeveloperName = 'Assign_Case_To_L1_Agent'
                                  LIMIT 1];
        ServicePresenceStatus sps = [SELECT Id
                                     FROM ServicePresenceStatus
                                     WHERE DeveloperName = 'Available'
                                     LIMIT 1];
         //for (Case testCase : cases) {
        AgentWork objAgentWork = new AgentWork(ServiceChannelId = sc.Id,
                                               WorkItemId = objcase.Id,
                                               UserId = user.Id);
        
        
        
        // }
        return objAgentWork;
       
        
    }      
}