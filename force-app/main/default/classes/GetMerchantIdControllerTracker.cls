@isTest
public class GetMerchantIdControllerTracker {
	@testSetup static void setupCommonData(){     
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        System.assertEquals('GKMSF4212W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.id].AccountId);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Business_Category__c businessCategoryOthers = CommonDataTracker.insertBusinessCategory('Others', false);
        insert businessCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryOthers.id].Name);
        
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
        
        Sub_Category__c subCategoryOthers = CommonDataTracker.insertSubCategory('Others', false);
        subCategoryOthers.Category__c = businessCategoryOthers.Id;
        insert subCategoryOthers ;
        System.assertEquals('Others', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryOthers.id].Name);
        
        Sub_Category__c subCategoryBooks = CommonDataTracker.insertSubCategory('Books', true);
        subCategoryBooks.Category__c = businessCategoryNGO.Id;
        insert subCategoryBooks ;
        System.assertEquals('Books', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryBooks.id].Name);
        
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
    }
    
    @isTest static void testMethodOne(){
        Product__c prodObj = [SELECT id, name, Platform__c FROM Product__c LIMIT 1];
        
        Entity__c entityObj = [SELECT id, Name FROM Entity__c LIMIT 1];
        
        Business_Category__c businessCategoryNGO = [SELECT id, name FROM Business_Category__c WHERE Name =: 'NGO' LIMIT 1];
        
        Sub_Category__c subCategoryBooks = [SELECT id, name FROM Sub_Category__c WHERE Name =: 'Books' LIMIT 1];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryBooks, entityObj);
        insert leadObj;      
		System.assertEquals(prodObj.Id, [SELECT id, name, Product__c FROM Lead WHERE Id =: leadObj.Id].Product__c); 
        
        GetMerchantIdController.getMerchantId(leadObj.Id, 'Lead');
        
        GetMerchantIdController.getMerchantId(null, 'Lead');
        
        Test.stopTest();
    }
}