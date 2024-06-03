@isTest
public class AttachedConfigTriggerTracker {
    
    @testSetup
    public static void setupdata(){
        
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        insert triggerSwitchObj ;
        
        Trigger_Switch__c triggerSwitchObj2 = CommonDataTracker.insertTriggerSwitch('Attached_Configuration__c', true);
        insert triggerSwitchObj2 ;
        
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
        accountObj.Monthly_Expected_Sale__c = 200;
        accountObj.Delivery_Duration__c = 2;
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass()); 
        
        Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
        businessCategory.Doable__c = True;
        insert businessCategory;
        
        Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
        subCategory.Category__c = businessCategory.Id;
        insert subCategory;
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategory, subCategory, entityObj);            
        insert leadObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Support Opportunity').getRecordTypeId();
        opportunityObj.BusinessCategory__c = businessCategory.id;
        opportunityObj.Transaction_Facility_Required__c = 'Domestic';
        opportunityObj.Delivery_Duration__c = 90;
        opportunityObj.Manual_Call_Response__c = 'CallStartTime:01-03-2020 12:16 PM,CallStatus:ANSWER,CallID:c2c_5e82e71b94765426,Bill_Seconds:';
        //opportunityObj.Partner_ID__c = Label.Shopmatric_UUID;
        opportunityObj.C2C_Call_Count__c=2;
        opportunityObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
        opportunityObj.Risk_Type_Multi_Select__c = 'Website URL';
        opportunityObj.Blacklist__c = true;
        insert opportunityObj;
        
    }
    
    public static testMethod void testData1(){
        Test.startTest();
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Attached_Configuration__c', true);
        insert enableUUIDObjObj;
        
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Opportunity opp = [SELECT id, AccountId,Escrow_Lock__c,Identifier__c FROM Opportunity LIMIT 1];
        
        Map<String,String> attachConfigMap = (Map<String,String>)JSON.deserialize(Label.Attached_Config_Identifier, Map<String,String>.class);
        
        Attached_Configuration__c eachAttach = New Attached_Configuration__c();
        eachAttach.Active__c = true;
        eachAttach.Bank_Updatable__c = opp.Escrow_Lock__c;
        eachAttach.Configurable_Identifier__c = opp.Identifier__c;
        eachAttach.Opportunity__c = opp.Id;
        eachAttach.Name = 'bank_detail_config';
        eachAttach.Configurable_Type__c = 'Merchant';
        eachAttach.Configuration_Identifier__c = attachConfigMap.get('bank_detail_config');
        SystemUtility.getIdentifierUUID(eachAttach, 'Identifier__c', enableUUIDObjObj);
        eachAttach.Attached_Config_Identifier__c = eachAttach.Identifier__c;
        insert eachAttach;
        
        system.assertEquals(eachAttach.name, [Select name from Attached_Configuration__c limit 1].name);
        
        eachAttach.Active__c = false;
        update eachAttach;
        
        Test.stopTest();        
    }
    
    public static testMethod void testData2(){
        Test.startTest();
        Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Attached_Configuration__c', true);
        insert enableUUIDObjObj;
        
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        Lead lead = [SELECT id,Escrow_Lock__c,Identifier__c FROM Lead LIMIT 1];
        
        Map<String,String> attachConfigMap = (Map<String,String>)JSON.deserialize(Label.Attached_Config_Identifier, Map<String,String>.class);
        
        Attached_Configuration__c eachAttach = New Attached_Configuration__c();
        eachAttach.Active__c = true;
        eachAttach.Bank_Updatable__c = lead.Escrow_Lock__c;
        eachAttach.Configurable_Identifier__c = lead.Identifier__c;
        eachAttach.Lead__c = lead.Id;
        eachAttach.Name = 'bank_detail_config';
        eachAttach.Configurable_Type__c = 'Merchant';
        eachAttach.Configuration_Identifier__c = attachConfigMap.get('bank_detail_config');
        SystemUtility.getIdentifierUUID(eachAttach, 'Identifier__c', enableUUIDObjObj);
        eachAttach.Attached_Config_Identifier__c = eachAttach.Identifier__c;
        insert eachAttach;
        
        system.assertEquals(eachAttach.name, [Select name from Attached_Configuration__c limit 1].name);
        
        eachAttach.Active__c = false;
        update eachAttach;
        
        Test.stopTest();        
    }
}