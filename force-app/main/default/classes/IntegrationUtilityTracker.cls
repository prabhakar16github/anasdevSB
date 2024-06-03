@isTest
public class IntegrationUtilityTracker {

    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        triggerSwitchObj.Publisher_Call__c = true;
        insert triggerSwitchObj ;
        
        Trigger_Switch__c triggerSwitchObj1 = CommonDataTracker.insertTriggerSwitch('Website_Page__c', true);
        triggerSwitchObj1.Publisher_Call__c = true;
        insert triggerSwitchObj1 ;
        
        Credentials__c creds = CommonDataTracker.insertCredentials();
        insert creds;
        System.assertEquals('f611fa0063b447ec135ed8ed80d0cef8e6badf33cf98ae8c15db55bcc25a7fd0', [SELECT id, OnboardingClientSecSB__c FROM Credentials__c WHERE Id =: creds.id].OnboardingClientSecSB__c);    
        
        String metaData = 'GetMessageSQS';
        Integration_Setting__mdt iSetting = [SELECT Id, Custom_Body__c,Custom_Header__c,DeveloperName, Body__c, SetCompressed__c, EndPointUrl__c, Headers__c, Method__c FROM Integration_Setting__mdt WHERE DeveloperName =: metaData];
        
        String metaData1 = 'BizAuthentication';
        Integration_Setting__mdt iSetting1 = [SELECT Id, Custom_Body__c,Custom_Header__c,DeveloperName, Body__c, SetCompressed__c, EndPointUrl__c, Headers__c, Method__c,User_Name__c, Password__c FROM Integration_Setting__mdt WHERE DeveloperName =: metaData1];
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);    
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);  
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
		Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Website__c = 'test.com';
        opportunityObj.Integration_Type__c = 'ThirdParty';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
    }
    
    @isTest
    private static void testMethodOne(){
        String metaData = 'GetMessageSQS';
        test.startTest();
        IntegrationUtility.getAuthToken(metaData); 
        
        Opportunity oppObj = [Select Id,NB_Eligible__c from Opportunity LIMIT 1];
        oppObj.NB_Eligible__c = True;
        update oppObj;
        test.stopTest();
    }
    
    @isTest
    private static void testMethodTwo(){
        String metaData = 'BizAuthentication';
        test.startTest();
        IntegrationUtility.getAuthToken(metaData);        
        test.stopTest();
    }
    
    @isTest
    private static void testMethodThree(){
        Opportunity opty = [SELECT id, Name From Opportunity LIMIT 1];
        Product__c prodObj = [SELECT id, Name From Product__c LIMIT 1];
        Account accountObj = [SELECT id, Name From Account LIMIT 1];
        
        Test.startTest();
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Website__c = 'test.com';
        opportunityObj.Integration_Type__c = 'Tools';
        opportunityObj.Maintenance_Status__c = 'NEW MID';
        insert opportunityObj;
        IntegrationUtility.checkMaintenance(opportunityObj, opty, 'Opportunity', 'Lead');
        IntegrationUtility.checkMaintenance(opportunityObj, null, 'Opportunity', 'Lead');
        Test.stopTest();
    }
    
    @isTest
    private static void testMethodFour(){
        String str = 'test Payload';
        test.startTest();
        IntegrationUtility.insertPayloadLog(null, str);
        
        Platform__c platformObj = [Select Id from Platform__c LIMIT 1];
        Opportunity opty = [SELECT id, Name,Merchant_Name__c From Opportunity LIMIT 1];
        Product__c prodObj = CommonDataTracker.insertCustomProduct('MCP', platformObj, true, 'Biz_Introduction_Template_With_MAF', null);
        insert prodObj; 
        Account accountObj = [SELECT id, Name From Account LIMIT 1];
        
        Cross_Sell__c crs = new Cross_Sell__c();
            crs.Care_Status__c = 'Interested';
            crs.Opportunity__c = opty.Id;
            crs.Risk_Status__c = 'Rejected';
            crs.RecordTypeId = Schema.SObjectType.Cross_Sell__c.getRecordTypeInfosByName().get('Product Cross-Selling').getRecordTypeId();
            crs.Custom_Product__c = prodObj.Id;
            insert crs;
        
        Integration_Setting__mdt theIntIns = [Select Id,Custom_Body__c,EndPointUrl__c,Method__c,SetCompressed__c,Headers__c,Custom_Header__c,Body__c,User_Name__c, Password__c from Integration_Setting__mdt Where DeveloperName='Payout_Activation'];
        IntegrationUtility.requestUtility(theIntIns, false, 'jkhgdja9878hgvjh', crs, null, null);
        test.stopTest();
    }
    
    @isTest
    private static void testMethodFive(){
        Opportunity opportunityObj = [SELECT Id, Name FROM Opportunity LIMIT 1];
        String pgDetails = '{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}, {"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Detailed Description"}';
        
        test.startTest();
        Website_Page__c websitePageObj1 = CommonDataTracker.insertWebsitePage('Test Website Page1', true, opportunityObj);
        websitePageObj1.Active__c = true;
        websitePageObj1.Page_Details__c = pgDetails;
        insert websitePageObj1;
        IntegrationUtility.sendPayLoadData(websitePageObj1, null, 'Website_Page__c', 'Website_Page__c'); 
        test.stopTest();
        system.assertEquals(true, [SELECT Id, Active__c FROM Website_Page__c WHERE Name='Test Website Page1'].Active__c);
    }
    
    @isTest
    public static void testMethodSix(){
        Opportunity oppOld = [SELECT Id, Name,Identifier__c,Escrow_Lock__c FROM Opportunity LIMIT 1];
        
        Opportunity oppNew = oppOld;
        oppNew.Name = 'Test';
        update oppNew;
       
        Set<String> fields = new Set<String>();
        fields.add('Payload_Header__c');
        PayloadActMap__mdt  mdt = [Select JSON_Map_sub_key_complex__c ,masterlabel ,JSONfieldMap__c , JsonMapComp__c ,Action__c,Delete_Action__c ,LookUpField__c,JSONMapPub__c from PayloadActMap__mdt  where masterLabel  = 'UpdateWebsite'];
        IntegrationUtility.payLoadGenerator(oppNew , oppOld , mdt, fields, 'Merchant');
        
        Trigger_Switch__c triggerObj = CommonDataTracker.insertTriggerSwitch('Attached_Configuration__c', True);
        triggerObj.Publisher_Call__c = True;
        insert triggerObj;
        IntegrationUtility.isFutureUpdate = True;
        Attached_Configuration__c attachObj = CommonDataTracker.insertAttachConfig('onboarding_config',oppNew);
        IntegrationUtility.sendPayLoadData(attachObj,null,'Attached_Configuration__c','Attached_Configuration__c');
    }
    
    @isTest
    public static void testMethodSeven(){
        Opportunity opportunityObj = [SELECT Id, Name, Escrow_Lock__c,Identifier__c  FROM Opportunity LIMIT 1];
        
        Trigger_Switch__c triggerObj = CommonDataTracker.insertTriggerSwitch('Attached_Configuration__c', True);
        triggerObj.Publisher_Call__c = True;
        insert triggerObj;
        IntegrationUtility.isFutureUpdate = True;
        Attached_Configuration__c attachObj = CommonDataTracker.insertAttachConfig('bank_detail_config',opportunityObj);
        IntegrationUtility.sendPayLoadData(attachObj,null,'Attached_Configuration__c','Attached_Configuration__c');
        
        delete opportunityObj;
    }
    
    @isTest
    public static void testMethod8(){
        Opportunity opportunityObj = [SELECT Id, Name, Escrow_Lock__c,Identifier__c  FROM Opportunity LIMIT 1];
        
        Trigger_Switch__c triggerObj = CommonDataTracker.insertTriggerSwitch('Attached_Configuration__c', True);
        triggerObj.Publisher_Call__c = True;
        insert triggerObj;
        IntegrationUtility.isFutureUpdate = True;
        Attached_Configuration__c attachObj = CommonDataTracker.insertAttachConfig('login_config',opportunityObj);
        IntegrationUtility.sendPayLoadData(attachObj,null,'Attached_Configuration__c','Attached_Configuration__c');
        
    }
}