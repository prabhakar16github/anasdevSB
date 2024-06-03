@isTest
private class DocumentWebsiteTrackerTriggerHandlerTest {

    @testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Account', true);
        insert triggerSwitchObj ;  
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT Id, Name FROM Entity__c WHERE Id =: entityObj.id].Name); 
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        businessCategoryNGO.Doable__c = true;
        businessCategoryNGO.Categories_For__c = 'Merchant';
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT Id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Delivery_Duration__c = 9;
        accountObj.Monthly_Expected_Sale__c = 5.0;
        accountObj.Transaction_Facility_Required__c = 'Domestic';
        accountObj.Business_Category__c = businessCategoryNGO.Id;
        accountObj.Type__c = 'Merchant';
        accountObj.Document_Status__c = null;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c);
    }
    
    static testmethod void testMethodOne(){
        Account accountObj = [SELECT Id, PAN_Number__c, Document_Status__c FROM Account LIMIT 1];
        accountObj.Document_Status__c = 'Pending';
        Test.startTest();
        update accountObj;
        accountObj.Document_Status__c = 'Docs Received';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Approved';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Received';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Error';
        update accountObj;
        accountObj.Document_Status__c = 'Pending';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Received';
        update accountObj;
        Test.stopTest();
    }
    
    static testmethod void testMethodTwo(){
        Account accountObj = [SELECT Id, PAN_Number__c, Document_Status__c FROM Account LIMIT 1];
        Document_Website_Tracker__c docObj = new Document_Website_Tracker__c(Account__c = accountObj.Id);
        Test.startTest();
        insert docObj;
        accountObj.Document_Status__c = 'Pending';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Received';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Approved';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Received';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Error';
        update accountObj;
        accountObj.Document_Status__c = 'Pending';
        update accountObj;
        Test.stopTest();
    }
    
    static testmethod void testMethodThree(){
        Account accountObj = [SELECT Id, PAN_Number__c, Document_Status__c FROM Account LIMIT 1];
        accountObj.Document_Status__c = 'Pending';
        Test.startTest();
        update accountObj;
        accountObj.Document_Status__c = 'Docs Error';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Received';
        update accountObj;
        Test.stopTest();
    }
    
    static testmethod void testMethodFour(){
        Account accountObj = [SELECT Id, PAN_Number__c, Document_Status__c FROM Account LIMIT 1];
        Document_Website_Tracker__c docObj = new Document_Website_Tracker__c(Account__c = accountObj.Id);
        insert docObj;
        Test.startTest();
        accountObj.Document_Status__c = 'Docs Error';
        update accountObj;
        accountObj.Document_Status__c = 'Docs Received';
        update accountObj;
        Test.stopTest();
    }
    
    static testmethod void testMethodFive(){
        Account accountObj = [SELECT Id, PAN_Number__c, Document_Status__c FROM Account LIMIT 1];
        Document_Website_Tracker__c docObj = new Document_Website_Tracker__c(Account__c = accountObj.Id);
        insert docObj;
        Test.startTest();
        accountObj.Document_Status__c = 'Pending';
        update accountObj;
        Test.stopTest();
    }
    
    static testmethod void testMethodSix(){
        Account accountObj = [SELECT Id, PAN_Number__c, Document_Status__c, LastModifiedDate FROM Account LIMIT 1];
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromNull = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromPending = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenApprovedFromRec = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenErrorFromRec = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromError = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromError = new Map<Id, List<Document_Website_Tracker__c>>();
        Boolean boolDocWebMapWhenPendingFromNull = true;
        Boolean boolDocWebMapWhenRecFromPending = true; 
        Boolean boolDocWebMapWhenApprovedFromRec = true;
        Boolean boolDocWebMapWhenErrorFromRec = true;
		Boolean boolDocWebMapWhenPendingFromError = true;
        Boolean boolDocWebMapWhenRecFromError = true;
        Map<Id, List<Document_Website_Tracker__c>> DocWebMap = new Map<Id, List<Document_Website_Tracker__c>>();
        List<Account> triggerNew = new List<Account> {accountObj};
		BusinessHours busnHrs = [SELECT Id FROM BusinessHours where Name='PayU'];
        system.debug('-->> 122 '+busnHrs.id);
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastApproved = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastError = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastPending = new Map<Id, List<Document_Website_Tracker__c>>();
        Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastRecieved = new Map<Id, List<Document_Website_Tracker__c>>();
        Boolean boolDocWebMapWhenLastApproved = true;
        Boolean boolDocWebMapWhenLastError = true;
        Boolean boolDocWebMapWhenLastPending = true;
        Boolean boolDocWebMapWhenLastRecieved = true;
        
        DocumentWebsiteTrackerTriggerHandler.createUpdateDocWebTrackerRecord(DocWebMapWhenPendingFromNull, DocWebMapWhenRecFromPending, DocWebMapWhenApprovedFromRec, DocWebMapWhenErrorFromRec, DocWebMapWhenPendingFromError, DocWebMapWhenRecFromError, boolDocWebMapWhenPendingFromNull, boolDocWebMapWhenRecFromPending, boolDocWebMapWhenApprovedFromRec, boolDocWebMapWhenErrorFromRec, boolDocWebMapWhenPendingFromError, boolDocWebMapWhenRecFromError, DocWebMap, triggerNew, busnHrs, DocWebMapWhenLastApproved, DocWebMapWhenLastError, DocWebMapWhenLastPending, DocWebMapWhenLastRecieved, boolDocWebMapWhenLastApproved, boolDocWebMapWhenLastError, boolDocWebMapWhenLastPending, boolDocWebMapWhenLastRecieved);
    }
}