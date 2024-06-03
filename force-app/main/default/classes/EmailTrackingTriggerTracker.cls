@isTest
public class EmailTrackingTriggerTracker {
    
    @testSetup static void setupCommonData(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales User'].Id,
            LastName = 'Test',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            MobilePhone  = '9090909090',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        system.runAs(u){
            Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            Test.setMock(HttpCalloutMock.class, new MockClass());
            
            Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
            insert triggerSwitchObj ;
            
            Enable_UUID_Objects__c enableUUIDObjObj = CommonDataTracker.insertEnableUUIDRec('Opportunity', true);
            insert enableUUIDObjObj;
            
            Enable_UUID_Objects__c enableUUIDObjObj1 = CommonDataTracker.insertEnableUUIDRec('Lead', true);
            insert enableUUIDObjObj1;
            
            Trigger_Switch__c triggerSwitchEmailObj = CommonDataTracker.insertTriggerSwitch('Email_Status_Tracking__c', true);
            insert triggerSwitchEmailObj ;
            
            Enable_UUID_Objects__c enableUUIDObjObj2 = CommonDataTracker.insertEnableUUIDRec('Email_Status_Tracking__c', true);
            insert enableUUIDObjObj2;
            
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
            insert subCategory;
            
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
            opportunityObj.Email__c = 'test@test.com';
            insert opportunityObj;
            
            System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
            Test.stopTest(); 
            
        }
    }
    
    public static testMethod void testData1(){
        Test.startTest();
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
        Opportunity opp = [SELECT id, AccountId,Email__c FROM Opportunity LIMIT 1];
        
        User u = New User(Id=userInfo.getUserId());
            EmailTemplate e;
        System.runAs(u){
        e = new EmailTemplate (developerName = 'test', FolderId = userInfo.getUserId(), 
                               TemplateType= 'Text', Name = 'test',subject='Dear {!Opportunity.Name}',
                                             HtMLValue = 'hshshsh'); // plus any other fields that you want to set
        
        insert e;
        }
        Email_Status_Tracking__c estObj = New Email_Status_Tracking__c();
        estObj.Template_Name__c = e.developerName;
        estObj.Opportunity__c = opp.Id;
        estObj.To_Addresses__c = opp.Email__c;
        estObj.CC_Addresses__c = opp.Email__c;
        insert estObj;
        
        Test.stopTest();
    }
    
    public static testMethod void testData2(){
        Test.startTest();
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
        Opportunity opp = [SELECT id, AccountId,Email__c FROM Opportunity LIMIT 1];
        
        User u = New User(Id=userInfo.getUserId());
            EmailTemplate e;
        System.runAs(u){
        e = new EmailTemplate (developerName = 'test', FolderId = userInfo.getUserId(), 
                               TemplateType= 'Text', Name = 'test',subject='Dear {!Opportunity.Name}',
                                             HtMLValue = 'hshshsh'); // plus any other fields that you want to set
        
        insert e;
        }
        Email_Status_Tracking__c estObj = New Email_Status_Tracking__c();
        estObj.Template_Name__c = e.developerName;
        estObj.Opportunity__c = opp.Id;
        estObj.To_Addresses__c = opp.Email__c+';test@abc.com';
        estObj.CC_Addresses__c = opp.Email__c+';test@abc.com';
        insert estObj;
        
        Test.stopTest();
    }
}