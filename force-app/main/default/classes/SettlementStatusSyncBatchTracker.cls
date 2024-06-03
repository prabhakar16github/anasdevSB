@isTest
public class SettlementStatusSyncBatchTracker {
	
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
        accountObj.PAN_Verification_Status__c = 'Success';
        accountObj.Monthly_Expected_Sale__c = 200;
        accountObj.Delivery_Duration__c = 2;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategory;
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.Website_Status__c = 'Website OK';
        opportunityObj.Document_Status_Document_Issue__c = 'Docs Approved';
        opportunityObj.Agreement_Status__c = 'Approved';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        Test.stopTest();  
    }
    
    public static testMethod void testDataOne(){
        Test.startTest();
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategory;
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu now');
        insert platformObj;
        System.assertEquals('payu now', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        Opportunity opp = [SELECT id, AccountId,Account.Document_Status__c,Account.Agreement_Status__c,
                           Account.Pan_Verification_Status__c,Website_Status__c,Settlement_Status__c
                           FROM Opportunity LIMIT 1];
        opp.Product__c = prodObj.Id;
        opp.BusinessCategory__c = businessCategory.id;
        opp.Transaction_Facility_Required__c = 'Domestic';
        opp.Delivery_Duration__c = 90;
        opp.Settlement_Status__c = 'Thirdparty Hold';
        opp.Integration_Type__c = 'Thirdparty';
        update opp; 
        
        String batchName = 'SettlementStatusSyncBatch';
        Database.executeBatch(new SettlementStatusSyncBatch(batchName),10);
        test.stopTest();
    }
    
    public static testMethod void testDataTwo(){
        Test.startTest();
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategory;
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu now');
        insert platformObj;
        System.assertEquals('payu now', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        Opportunity opp = [SELECT id, AccountId,Account.Document_Status__c,Account.Agreement_Status__c,
                           Account.Pan_Verification_Status__c,Website_Status__c,Settlement_Status__c
                           FROM Opportunity LIMIT 1];
        opp.Product__c = prodObj.Id;
        opp.BusinessCategory__c = businessCategory.id;
        opp.Transaction_Facility_Required__c = 'Domestic';
        opp.Delivery_Duration__c = 90;
        opp.Settlement_Status__c = 'Thirdparty Hold';
        opp.Integration_Type__c = 'Tools';
        update opp; 
        
        String batchName = 'SettlementStatusSyncBatch';
        Database.executeBatch(new SettlementStatusSyncBatch(batchName),10);
        test.stopTest();
    }
}