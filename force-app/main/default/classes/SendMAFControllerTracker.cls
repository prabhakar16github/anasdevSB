@isTest
public class SendMAFControllerTracker{
    @testSetup static void setupCommonData(){ 
        
        E_Stamp_Master__c EStampMasterObj = CommonDataTracker.insertEStampMaster('12345678');
        EStampMasterObj.Used__c = false; 
        insert EStampMasterObj;
        System.assertEquals(true, [SELECT Id, Active__c FROM E_Stamp_Master__c WHERE Id =: EStampMasterObj.Id].Active__c);
        
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
        
        Business_Category__c businessCategoryObj = CommonDataTracker.insertBusinessCategory('businessCat', false);
        insert businessCategoryObj;
        
        Sub_Category__c subCategoryObj = CommonDataTracker.insertSubCategory('subCat', false);
        subCategoryObj.Category__c = businessCategoryObj.Id;
        insert subCategoryObj;
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryObj, subCategoryObj, entityObj);
        insert leadObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        opportunityObj.Last_Name__c = 'LeadLAstName';
        insert opportunityObj;
        System.assertEquals(accountObj.id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.id].AccountId);
        
        Website_Page__c websitePageObj = CommonDataTracker.insertWebsitePage('Test Website Page', true, opportunityObj);
        insert websitePageObj;
        System.assertEquals(opportunityObj.id, [SELECT id, Opportunity__c FROM Website_Page__c WHERE id =: websitePageObj.id].Opportunity__c);
        
        Merchant_Document__c MerchantDocumentObj = CommonDataTracker.insertMerchantDoc(accountObj);
        insert MerchantDocumentObj;
        System.assertEquals(accountObj.id, [SELECT id, Account__c FROM Merchant_Document__c WHERE id =: MerchantDocumentObj.id].Account__c);
    }
        
    @isTest static void testMethodOne(){
        
        Product__c productObj = [SELECT id, Name, MAF_Enable__c, MAF_Template_Name__c FROM Product__c LIMIT 1];
        productObj.MAF_Enable__c  = false;
        productObj.MAF_Template_Name__c = null;
        update productObj;
        System.assertEquals(false, [SELECT id,MAF_Enable__c FROM Product__c WHERE id =: productObj.Id].MAF_Enable__c);
        
        Account accountObj = [SELECT id, Name FROM Account LIMIT 1 ];
        
        Opportunity opportunityObj = [SELECT Id, AccountId, MAF_Status__c, Sub_Source__c, Product__c, 
                                      Product__r.MAF_Enable__c, Product__r.MAF_Template_Name__c, Email__c
                                      FROM Opportunity WHERE AccountId =: accountObj.Id];
        system.debug(opportunityObj.Product__r.MAF_Enable__c +' &&&&&& '+opportunityObj.Product__r.MAF_Template_Name__c);
        
        Test.startTest();
        
        String str1 = SendMAFController.sendMAFforOpp(opportunityObj.Id);
        
        productObj.MAF_Enable__c=true;
        update productObj;
        
        str1 = SendMAFController.sendMAFforOpp(opportunityObj.Id);
        
        productObj.MAF_Template_Name__c='Biz_Introduction_Template_With_MAF';
        update productObj;
        
        str1 = SendMAFController.sendMAFforOpp(opportunityObj.Id);
        
        opportunityObj.Email__c = 'umashankattest@saasfocus.com';
        update opportunityObj;
        
        str1 = SendMAFController.sendMAFforOpp(opportunityObj.Id);
        
        opportunityObj.MAF_Status__c = 'sent';
        opportunityObj.First_Name__c = 'FirstLeadname';
        update opportunityObj;
        
        str1 = SendMAFController.sendMAFforOpp(opportunityObj.Id);
        Test.stopTest();
    }
    
    @isTest static void testMethodTwo(){
        
        Product__c productObj = [SELECT id, Name, MAF_Enable__c, MAF_Template_Name__c FROM Product__c LIMIT 1];
        productObj.MAF_Enable__c  = false;
        productObj.MAF_Template_Name__c = null;
        update productObj;
        System.assertEquals(false, [SELECT id,MAF_Enable__c FROM Product__c WHERE id =: productObj.Id].MAF_Enable__c);
        
        Lead leadObj = [SELECT Name, id,email, Owner.Email FROM Lead LIMIT 1];
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'TestST', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='TestingUserr', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testt.com');
        insert usr ;
        System.runAs(usr)
        {
            leadObj.ownerId = usr.id;
            update leadObj;
        }
        
        SendMAFController.sendMAFforLead(leadObj.Id);
        
        productObj.MAF_Enable__c=true;
        update productObj;
        
        SendMAFController.sendMAFforLead(leadObj.Id);
        
        productObj.MAF_Template_Name__c='Biz_Introduction_Template_With_MAF';
        update productObj;
        
        SendMAFController.sendMAFforLead(leadObj.Id);
        
        leadObj.MAF_Status__c = 'Sent';
        update leadObj;
        
        SendMAFController.sendMAFforLead(leadObj.Id);
        
        leadObj.MAF_Status__c = null;
        leadObj.email = null; 
        update leadObj;    
        
        SendMAFController.sendMAFforLead(leadObj.Id);
        
        leadObj.email = 'uma.shankar@saasfocus.com';
        update leadObj;
        
        SendMAFController.sendMAFforLead(leadObj.Id);
        
        Test.stopTest();
    } 
}