@isTest
public class webPageDetailHelperTracker {
    
    @testSetup static void setupCommonData(){
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);  
        
		Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId); 
        
        Website_Page_Master__c wpm1 = CommonDataTracker.insertWPM();
        insert wpm1;
        
        Website_Page_Master__c wpm2 = CommonDataTracker.insertWPM();
            wpm2.Name = 'Contact Us Details';
            wpm2.Page_Details__c = '{"name":"Functional email ID","status":"Pending","is_present":false,"error":null,"remarks":null}';
            insert wpm2;
        
         Website_Page_Master__c wpm3 = CommonDataTracker.insertWPM();
            wpm3.Name = 'Product/Services Details';
            wpm3.Page_Details__c = '{"name":"Legal Products/Services","is_present":false,"status":"Pending","remarks":"","error":""}';
            insert wpm3;
    }

    @isTest static void testMethodOne(){
        String pgDetails = '[{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}]';
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Terms & Conditions Details'];
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        websitePageObj.Page_Details__c = String.ValueOf(pgDetails);
        insert websitePageObj;
        
        String str = 'Terms & Conditions Details';
        List<String> strList = new List<String>();
        strList.add('{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}');
        strList.add('{"name":"Limited Liability Clause","is_present":false,"status":"Pending","remarks":"","error":""}');
        Map<string,List<string>> pageDetailWithNameMap = new Map<string,List<string>>();
        pageDetailWithNameMap.put(str, strList);
        
        webPageDetailHelper.statusApprovedSerialization(pageDetailWithNameMap, 'Approved');
    }
    
    @isTest static void testMethodTwo(){
        String pgDetails = '[{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}]';
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Product/Services Details'];
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        websitePageObj.Page_Details__c = pgDetails;
        insert websitePageObj;
        
        String str = 'Product/Services Details';
        List<String> strList = new List<String>();
        strList.add('{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}');
        strList.add('{"name":"Limited Liability Clause","is_present":false,"status":"Pending","remarks":"","error":""}');
        Map<string,List<string>> pageDetailWithNameMap = new Map<string,List<string>>();
        pageDetailWithNameMap.put(str, strList);
        
        webPageDetailHelper.statusApprovedSerialization(pageDetailWithNameMap, 'Approved');
    }
    
     @isTest static void testMethodThree(){
        String pgDetails = '[{"remarks":null,"error":null,"is_present":true,"status":"Verification in Process","name":"Legal Products/Services"}]';
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        Website_Page_Master__c wpm = [SELECT Id, Name, Page_Details__c, Active__c FROM Website_Page_Master__c WHERE Name = 'Contact Us Details'];
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        websitePageObj.Page_Details__c = pgDetails;
        insert websitePageObj;
        
        String str = 'Contact Us Details';
        List<String> strList = new List<String>();
        strList.add('{"name":"Advanced Booking Duration","is_present":false,"status":"Pending","remarks":"","error":""}');
        strList.add('{"name":"Limited Liability Clause","is_present":false,"status":"Pending","remarks":"","error":""}');
        Map<string,List<string>> pageDetailWithNameMap = new Map<string,List<string>>();
        pageDetailWithNameMap.put(str, strList);
        
        webPageDetailHelper.statusApprovedSerialization(pageDetailWithNameMap, 'Approved');
    }
}