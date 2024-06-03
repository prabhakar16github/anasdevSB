@isTest
public class Whatsapp_fetchSelectedTracker {
    
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
            
            Trigger_Switch__c triggerSwitchObj2 = CommonDataTracker.insertTriggerSwitch('Merchant_Document__c', true);
            insert triggerSwitchObj2 ; 
            
            Credentials__c credObj = CommonDataTracker.insertCredentials();
            insert credObj;
            
            Entity__c entityObj = CommonDataTracker.insertEntity('Individual');
            insert entityObj;
            
            Document_Category_Master__c docCategoryPanObj =  CommonDataTracker.insertDocCategoryMaster('PAN Card of Signing Authority');
            
            Document_Category_Master__c docCategoryBankObj =  CommonDataTracker.insertDocCategoryMaster('Bank Account Proof');
            
            Document_Category_Master__c docCategoryAddressObj =  CommonDataTracker.insertDocCategoryMaster('Address Proof of Signing Authority');
            
            
            Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
            accountObj.Business_Entity__c =  entityObj.Id;
            accountObj.Identifier__c = '9867587879089887';
            accountObj.Document_Status__c = 'Pending';
            accountObj.LOB_Status__c = 'Pending';
            accountObj.Agreement_Status__c = 'Not generated';
            //accountObj.Dow_Jones_Status__c = 'Match Found';
            //accountObj.Document_Status__c = 'Docs Approved';
            accountObj.Monthly_Expected_Sale__c = 200;
            accountObj.Delivery_Duration__c = 2;
            insert accountObj;
            
            
            test.startTest();
            
            MessagingEndUser msgEndUser = new MessagingEndUser();
            msgEndUser.MessagingChannelId = System.label.MessagingChannelId;
            msgEndUser.Name = 'test:+919999999999';
            msgEndUser.messageType = 'WhatsApp';
            msgEndUser.MessagingPlatformKey = 'test:+919999999999';
            //msgEndUser.IsFullyOptedIn = true;
            insert msgEndUser;
            
            Business_Category__c businessCategory = CommonDataTracker.insertBusinessCategory('Others', false);
            businessCategory.Doable__c = True;
            insert businessCategory;
            
            Business_Category__c businessCategory1 = CommonDataTracker.insertBusinessCategory('Real Estate', false);
            businessCategory1.Doable__c = True;
            insert businessCategory1;
            
            Sub_Category__c subCategory = CommonDataTracker.insertSubCategory('Others', false);
            insert subCategory;
            
            Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
            opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityObj.BusinessCategory__c = businessCategory.id;
            opportunityObj.Transaction_Facility_Required__c = 'Domestic';
            opportunityObj.Delivery_Duration__c = 90;
            opportunityObj.C2C_Call_Count__c=2;
            opportunityObj.Missed_Call_Time__c='06-05-2020 17:08 PM';
            opportunityObj.Risk_Type_Multi_Select__c = 'Website URL';
            opportunityObj.Blacklist__c = true;
            insert opportunityObj;
            
            System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
            
            test.stopTest();
        }
    }
    
    @isTest
    public static void testData1(){
        
        
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account WHERE Name='Test Account'];
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Lead leadObj1 = CommonDataTracker.insertLead(prodObj, businessCategory, subCategory, entityObj);            
        leadObj1.Lead_Type__c = 'Partner';
        leadObj1.Prod_Merchant_Id__c = 12398231;
        leadObj1.MobilePhone = '9999999999';
        insert leadObj1;
        
        leadObj1.Email = 'test@test.com';
        update leadObj1;
        
        Test.startTest();
        Whatsapp_fetchSelectedLeadOppDetails.MessagingInput input = new Whatsapp_fetchSelectedLeadOppDetails.MessagingInput();
        input.selectedOption = 'MID : '+String.valueOf(leadObj1.Prod_Merchant_Id__c)+', Email : '+leadObj1.Email;
        
        
        List<Whatsapp_fetchSelectedLeadOppDetails.MessagingInput> listInput = new List<Whatsapp_fetchSelectedLeadOppDetails.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_fetchSelectedLeadOppDetails.getMIDDetails(listInput);
        
        test.StopTest();
    }
    
    @isTest
    public static void testData2(){
        
        
        Business_Category__c businessCategory = [Select Id,Doable__c from Business_Category__c LIMIT 1];
        
        Sub_Category__c subCategory = [Select Id from Sub_Category__c LIMIT 1];
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        Platform__c platformObj = CommonDataTracker.insertPlatform('payu money');
        insert platformObj;
        System.assertEquals('payu money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('payU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        
        Account accountObj = [SELECT id,Document_Status__c,Agreement_Status__c,LOB_Status__c, Name FROM Account WHERE Name='Test Account'];
        accountObj.Risk_Type_Multi_Select__c = 'Website URL';
        update accountObj;
        
        Opportunity opportunityObj4 = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        
        opportunityObj4.Website_Status__c = 'Website Error';
        opportunityObj4.Merchant_Type__c = 'Seller';
        opportunityObj4.BusinessCategory__c = businessCategory.id;
        opportunityObj4.Sub_Category__c = subCategory.id;
        opportunityObj4.Delivery_Duration__c = 23;
        opportunityObj4.Monthly_Expected_Sale__c = 2342;
        opportunityObj4.Agreement_Status__c='Pending';
        opportunityObj4.Document_Status__c='Pending';
        opportunityObj4.Bank_Verification_Status__c = 'Success';
        opportunityObj4.Product__c = prodObj.id;
        opportunityObj4.Mobile__c = '9999999999';
        opportunityObj4.Display_Name__c = 'test';
        opportunityObj4.Prod_Merchant_Id__c = 87654567;
        insert opportunityObj4;
        
        Test.startTest();
        Whatsapp_fetchSelectedLeadOppDetails.MessagingInput input = new Whatsapp_fetchSelectedLeadOppDetails.MessagingInput();
        input.selectedOption = 'MID : '+String.valueOf(opportunityObj4.Prod_Merchant_Id__c)+', Name : '+String.valueof(opportunityObj4.Display_Name__c);
        
        
        List<Whatsapp_fetchSelectedLeadOppDetails.MessagingInput> listInput = new List<Whatsapp_fetchSelectedLeadOppDetails.MessagingInput>();
        listInput.add(input);
        
        Whatsapp_fetchSelectedLeadOppDetails.getMIDDetails(listInput);
        
        test.StopTest();
    }
    
}