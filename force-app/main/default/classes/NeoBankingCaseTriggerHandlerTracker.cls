@isTest
public class NeoBankingCaseTriggerHandlerTracker {
	
    public static testMethod void NeoTestData(){
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Case', true);
        insert triggerSwitchObj ;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Con';
        insert con;
        
        Opportunity opp2 = New Opportunity();
        opp2.Name='test1';
        opp2.Email__c='test@test.com';
        opp2.AccountId=acc.Id;
        opp2.StageName='MAF';
        opp2.CloseDate=Date.today();
        opp2.Prod_Merchant_Id__c = 654321;
        opp2.Lead_Created_date__c = null;
        //opp2.Product__c = prod.Id;
        insert opp2;
        
        Case caseObj = new Case();
        caseObj.AccountId = acc.Id;
        caseObj.contactId = con.id;
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NeoBanking').getRecordTypeID();
        caseObj.ticketID__c = '123456';
        caseObj.Status = 'Lead sent to RBL';
        caseObj.Merchant_Id__c = '654321';
        insert caseObj;
        
        //caseObj.Status = 'Lead sent to RBL';
        caseObj.LP_Sub_Status__c = 'Merchant is preparing docs';
        update caseObj;
        
        //system.assertEquals('0121s0000000gnqAAA', caseObj.RecordTypeId);
    }
    
    //test data for case trigger
    public static testMethod void TestData(){
        
        SalesforceDebugLogInitiator__c  logIntiator = new SalesforceDebugLogInitiator__c();
        logIntiator.Name = 'DebugLog Initiator';
        logIntiator.IsActive__c = true;
        logIntiator.IsShow_Debug_Logs__c =true;
        insert logIntiator;
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Case', true);
        insert triggerSwitchObj ;
        
        Account acc = New Account();
        acc.Name='Test Acc';
        insert acc;
        
        Opportunity opp2 = New Opportunity();
        opp2.Name='test1';
        opp2.Email__c='test@test.com';
        opp2.AccountId=acc.Id;
        opp2.StageName='MAF';
        opp2.CloseDate=Date.today();
        opp2.Prod_Merchant_Id__c = 654321;
        opp2.Lead_Created_date__c = null;
        //opp2.Product__c = prod.Id;
        insert opp2;
        
        contact oContact =new contact();
        oContact.LastName='test';
        oContact.Email='test2@test.com';
        oContact.MobilePhone='1236567890';
        oContact.AccountId=acc.Id;
        insert oContact;
        
        Case case2 =new Case();
        case2.Status='New';
        case2.Priority='High';
        case2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        case2.ContactId=oContact.id;
        case2.AccountId = acc.Id;
        case2.Merchant_Id__c = '654321';
        case2.LP_Issue__c = 'Document Related';
        case2.LP_Sub_Issue__c = 'Documents Rejected';
        //case2.OwnerId = [select id from group where DeveloperName = 'Waiting_On_PayUSMB_Sales' and type = 'Queue' limit 1].id; 
        insert case2;
        
        case2.OwnerId = [Select Id,userorgroupid from groupMember where Group.DeveloperName='Waiting_On_PayUSMB_Sales' and group.type='Queue' LIMIT 1].userorgroupid;
        update case2;
        
    }
}