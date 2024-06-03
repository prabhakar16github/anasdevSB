@isTest
public class BulkTeamChangeTest 
{
		@testSetup static void setupCommonData(){
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        insert triggerSwitchObj ;
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
        insert enableUUIDObjObj;
        Enable_UUID_Objects__c enableUUIDObjObj1 = CommonDataTracker.insertEnableUUIDRec('Lead', true);
        insert enableUUIDObjObj1;
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Delivery_Duration__c = 1;
        accountObj.Monthly_Expected_Sale__c = 10000;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.Website_Status__c = 'Not Applicable';
        opportunityObj.Website__c = 'testweb.com';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        Test.stopTest();  
    }
    static testMethod void testOpportunity() 
    {
        Opportunity opp = [Select ID,Prod_Merchant_Id__c,Merchant_Business_Type__c,Team__c,New_Merchant_Business_Type_Requested__c,New_Team_Requested__c,KAM_Change_Approval__c,Team_Change_Approval_Status__c from opportunity ];
        Test.startTest();
        Test.setCurrentPage(Page.Bulk_Team_Change_Approval);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Opportunity> {opp});
        stdSetController.setSelected(new List<Opportunity> {opp});
        BulkTeamChangeApprovalController ext = new BulkTeamChangeApprovalController(stdSetController);
        ext.getSelectedOpps();
        Test.stopTest();
    }
    static testMethod void testGetDetailsOnApprovalPage() {
          Id userId = UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
     	FirstName = 'test35562',
            LastName = 'user6546',
            Email = 'testemail@payu.in',
            Username = 'testuser3562643@test.com',
            Alias = 'tu19',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
		);
        insert u;
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity 1', Team_Change_Requested_To__c = userId, Team_Change_Approval_Status__c = 'Pending',CloseDate=Date.newInstance(2024, 12, 31));
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity 2', Team_Change_Requested_To__c = userId, Team_Change_Approval_Status__c = 'Approved',CloseDate=Date.newInstance(2024, 12, 31));
        insert new List<Opportunity>{opp1, opp2};
        System.runAs(u) {
            Test.startTest();
            List<Opportunity> results = BulkTeamChangeApprovalController.getDetailsOnApprovalPage();
            Test.stopTest();
            System.assertEquals(0, results.size());
        }
    }
    @isTest
    static void actionOnSelectedOppsFromLWC_approves_pending_ownership_change_requests() {
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', amount = 800, CloseDate = Date.newInstance(2024, 12, 31));
		insert objOpp;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            FirstName = 'test35562',
            LastName = 'user6546',
            Email = 'testemail@payu.in',
            Username = 'testuser3562643@test.com',
            Alias = 'tu19',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(objOpp.id);
        app.setComments('');
		Approval.ProcessResult result = Approval.process(app);
		Test.startTest();
        System.runAs(testUser){
        String response = BulkTeamChangeApprovalController.actionOnSelectedOppsFromLWC(String.ValueOf(objOpp.Id), 'Approve');
		System.assertEquals('0', response);
        List<Opportunity> updatedOpportunity = [SELECT OwnerId FROM Opportunity WHERE Id = :objOpp.Id];
        if(updatedOpportunity.size()>0 && updatedOpportunity!=null)
        System.assertEquals(testUser.Id, updatedOpportunity[0].OwnerId);
            Test.stopTest();
        }
    }
    @isTest
    public static void CanChangeApprovalAction () {
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', amount = 800, CloseDate = Date.newInstance(2024, 12, 31));
		insert objOpp;
        Approval.ProcessSubmitRequest testapproval = new Approval.ProcessSubmitRequest();
        testapproval.setComments('Submitting request for approval');
        testapproval.setObjectId(objOpp.Id);
        Approval.ProcessResult result1 = Approval.process(testapproval);
        Approval.ProcessWorkitemRequest testApp = new Approval.ProcessWorkitemRequest();
        testApp.setWorkitemId(objOpp.Id);
        testApp.setAction('Approve');
        testApp.setComments('Good to go');
        List<Approval.ProcessResult> regAppList = new List<Approval.ProcessResult>();
        Test.startTest();
        String cmp = BulkTeamChangeApprovalController.actionOnSelectedOppsFromLWC(objOpp.Id,'Reject');
        System.assertEquals('0',cmp);  
        Test.stopTest();
    }
}