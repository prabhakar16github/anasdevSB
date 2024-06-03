/**
@author:            jatin arora
@company:           SaaSFocus
@description:       cover AgentWorkTriggerHandler
@history
<Date>        <Authors Name>        
26-Sep-18     jatin arora          
**/
@isTest(seealldata=true)

public class AgentWorkTriggerHandlerTracker {
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
    }
    public static void LoadData()
    { 
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
        oCase.Status='NEW';
        oCase.Priority='High';
        oCase.contactId=oContact.id;
        oCase.LP_KYC_Last_Modified_Date__c = System.now();
        oCase.LP_KYC_State__c ='User Documents Pending';
        oCase.OwnerId=[select id from group where developername ='L1_KYC_Queue'].id;
        insert oCase;
        
        lst =new list<case>();
        lst.add(oCase);
        
        
        
        oKYCDocument=new LP_KYC_Document__c();
        oKYCDocument.LP_Status__c='Verified';
        oKYCDocument.Name='Aadhaar Back';
        oKYCDocument.LP_Case__c=oCase.id;
        oKYCDocument.LP_Rejection_Reason__c='Test';
        oKYCDocument.LP_Date_Created__c=system.today();
        oKYCDocument.LP_Last_Modified_Date__c=system.today();
        insert oKYCDocument;
        
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