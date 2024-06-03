@isTest
public class KAMAssignmentUpdateBatchTracker {
    
    public static testMethod void testData1(){
       
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        insert triggerSwitchObj ;
        
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
        insert enableUUIDObjObj;
        
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu biz');
        insert platformObj;
        System.assertEquals('payu biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Monthly_Expected_Sale__c = 200;
        accountObj.Delivery_Duration__c = 2;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = merchantRecordTypeId;
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.Move_to_Farming__c = True;
        opportunityObj.Potential__c = 'Lowest';
        opportunityObj.Priority__c = 'Low';
        opportunityObj.GMV_Latest_Date__c = Date.today();
        opportunityObj.Last_3_months_GMV__c = 12344;
        opportunityObj.Settlement_Status__c = 'Active';
        opportunityObj.Lead_Type__c = 'Merchant';
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        system.debug('@@@@@@ '+opportunityObj.Lead_Type__c+' @@@@@ '+opportunityObj.Last_3_months_GMV__c+' @@@@@@@@ '+opportunityObj.Settlement_Status__c);
        
        Test.startTest();
        String batchSettingName = 'KAMAssignmentUpdateBatch';
        Database.executeBatch(New KAMAssignmentUpdateBatch(batchSettingName,false,true,new Set<Id>()));
        Test.stopTest();
    }
    
    public static testMethod void testData2(){
        
        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        insert triggerSwitchObj ;
        
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
        insert enableUUIDObjObj;
        
        Credentials__c credObj = CommonDataTracker.insertCredentials();
        insert credObj;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu biz');
        insert platformObj;
        System.assertEquals('payu biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.Monthly_Expected_Sale__c = 200;
        accountObj.Delivery_Duration__c = 2;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        insert subCategory;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = merchantRecordTypeId;
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.Move_to_Farming__c = True;
        opportunityObj.Potential__c = 'Lowest';
        opportunityObj.Priority__c = 'Low';
        opportunityObj.GMV_Latest_Date__c = Date.today();
        opportunityObj.Last_3_months_GMV__c = 12344;
        opportunityObj.Settlement_Status__c = 'Active';
        opportunityObj.Lead_Type__c = 'Merchant';
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        system.debug('@@@@@@ '+opportunityObj.Lead_Type__c+' @@@@@ '+opportunityObj.Last_3_months_GMV__c+' @@@@@@@@ '+opportunityObj.Settlement_Status__c);
        
        
        Test.startTest();
        String batchSettingName = 'KAMAssignmentUpdateBatch';
        KAMAssignmentUpdateBatch batchableClass = new KAMAssignmentUpdateBatch(batchSettingName,true,false,new Set<Id>{opportunityObj.Id});
        Database.executeBatch(batchableClass);
		String cron_Exp = '0 0 23 * * ?'; 
        system.schedule('KAM Update Scheduler', cron_Exp, new KAMAssignmentUpdateBatchScheduler());
        Test.stopTest();
    }
}