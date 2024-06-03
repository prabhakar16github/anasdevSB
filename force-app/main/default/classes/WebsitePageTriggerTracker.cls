@isTest
public class WebsitePageTriggerTracker {
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Website_Page__c', true);
        insert triggerSwitchObj ; 
        
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
        
        Trigger_Switch__c triggerSwitchObjOpty = CommonDataTracker.insertTriggerSwitch('Opportunity', true);
        insert triggerSwitchObjOpty ; 
        
        string pageDetails = '[{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}]';
        Website_Page_Master__c wpm = CommonDataTracker.insertWPM('Contact Us Details',pageDetails);
        insert wpm;
        
        Website_Page__c websitePageObj1 = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObj1.Active__c = true;
        insert websitePageObj1;
        
        string pageDetails2 = '[{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}]';
        Website_Page_Master__c wpm2 = CommonDataTracker.insertWPM('Terms & Conditions Details',pageDetails2);
        insert wpm2;
        
        Website_Page__c websitePageObj2 = CommonDataTracker.insertWebsitePage('Terms & Conditions Details', true, opportunityObj);
        websitePageObj2.Active__c = true;
        insert websitePageObj2;
    }
    
    @isTest static void testMethodOne(){     
        
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Contact Us Details' LIMIT 1];
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObj.Page_Details__c = wpm.Page_Details__c;
        Test.startTest();
        insert websitePageObj;
        Test.stopTest();
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c); 
    }
    
    @isTest static void testMethodTwo(){
        String pgDetails = '{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}, {"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Detailed Description"}';
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Test.startTest();
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObj.Page_Details__c = pgDetails;
        insert websitePageObj;
        websitePageObj.Status__c = 'Approved';
        update websitePageObj;
        Test.stopTest();
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
    }
    
    @isTest static void testMethodThree(){
        String pgDetails = '[]';
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Test.startTest();
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Contact Us Details' LIMIT 1];
        wpm.Page_Details__c = '[]';
        update wpm;
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Contact Us Details', true, opportunityObj);
        websitePageObj.Page_Details__c = pgDetails;
        insert websitePageObj;
        websitePageObj.Status__c = 'Approved';
        update websitePageObj;
        Test.stopTest();
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
    }   
    /*
    @isTest static void testMethodFur(){
        List<Opportunity> opportunityObj = [SELECT id, AccountId, LastModifiedById, website__c, Android_URL__c, ios_URL__c, Integration_Type__c FROM Opportunity LIMIT 1];
        Test.startTest();
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Terms & Conditions Details'];
        //WebsitePageTriggerHandler.createWebsiteDataFromMasterRecords(null, opportunityObj, new List<Website_Page_Master__c> {wpm}, 'Pending');
        Test.stopTest();
        System.assertNotEquals(null, [SELECT Id, Name FROM Website_Page__c WHERE Opportunity__c = :opportunityObj[0].Id]);
    }  
    
    @isTest static void testMethodFive(){
        String pgDetails = '{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}, {"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Advanced Booking Duration"}';
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Test.startTest();
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage(' Terms & Conditions Details', true, opportunityObj);
        websitePageObj.Page_Details__c = pgDetails;
        insert websitePageObj;
        Test.stopTest();
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
    }
    
    @isTest static void testMethodSix(){
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Test.startTest();
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage(' Terms & Conditions Details', true, opportunityObj);
        insert websitePageObj;
        //WebsitePageTriggerHelper.checkDataBeforeInsert(new List<Website_Page__c> { websitePageObj });
        Test.stopTest();
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
    }
    
    @isTest static void testMethodSeven(){
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Terms & Conditions Details'];
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage(' Terms & Conditions Details', true, opportunityObj);
        insert websitePageObj;
         Website_Page__c websitePageObj1 = CommonDataTracker.insertWebsitePage(' Contact Us Details', true, opportunityObj);
        insert websitePageObj1;
        String pgDetails = '[{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}]';
        String pgDetails1 = '{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}, {"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Advanced Booking Duration"}';
        Website_Page__c websitePageObj2 = CommonDataTracker.insertWebsitePage(' Terms & Conditions Details', true, opportunityObj);
        websitePageObj2.Page_Details__c = pgDetails;
        insert websitePageObj2;
        test.startTest();
        //List<Website_Page__c> result = WebsitePageTriggerHelper.createWebsitePageAfterOppInsert(opportunityObj, new List<Website_Page_Master__c> {wpm}, 'Approved');
        //Boolean resultBool = WebsitePageTriggerHelper.checkWebPageBeforeInsert(new Set<String> {wpm.Name}, new List<Website_Page__c> {websitePageObj} );
        //Boolean resultBool1 = WebsitePageTriggerHelper.checkWebPageBeforeInsert(new Set<String> {wpm.Name}, new List<Website_Page__c> {websitePageObj1} );
        //Boolean resultBool2 = WebsitePageTriggerHelper.checkWebPageBeforeInsert(new Set<String> {wpm.Name}, new List<Website_Page__c> {} );
        //WebsitePageTriggerHelper.checkPageDetailData(pgDetails, new List<String> {'test page'}, websitePageObj2);
        test.stopTest();
        //System.assertEquals('Approved', result[0].status__c);
        //System.assertEquals(true, resultBool2);
    }*/
}