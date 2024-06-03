@isTest
public class getListOfWebsitepagesControllerTracker {

    @testSetup static void setupCommonData(){
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
        
        Website_Page_Master__c wpm = CommonDataTracker.insertWPM();
        insert wpm;
        
    }
    
    @isTest static void testMethodOne(){
        String pgDetails = '[{"remarks":null,"error":null,"is_present":true,"status":"Rejected","name":"Legal Products/Services"}]';
        Opportunity optyObj = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Website_Page__c websitePageObj1 = CommonDataTracker.insertWebsitePage('Test Website Page1', true, optyObj);
        websitePageObj1.Active__c = true;
        websitePageObj1.Page_Details__c = pgDetails;
        insert websitePageObj1;
        getListOfWebsitepagesController contllr = new getListOfWebsitepagesController();
        contllr.strOptyId = optyObj.Id;
        getListOfWebsitepagesController.errorDataWrapper obj = new getListOfWebsitepagesController.errorDataWrapper();
        obj.websitePagesError = 'test errror';
        obj.websitePagesName = 'Test Website Page1';
        contllr.wrapperList = new List<getListOfWebsitepagesController.errorDataWrapper> {obj};
		contllr.objWrapper = obj;
        contllr.objerrorDataWrapper = new List<getListOfWebsitepagesController.errorDataWrapper> {obj};
        List<getListOfWebsitepagesController.errorDataWrapper> obj1 = new List<getListOfWebsitepagesController.errorDataWrapper>();
        obj1 = contllr.objerrorDataWrapper;
        system.assertNotEquals(null, obj1);
    }
}