@isTest
public class CreateWebsiteDocumentsController_OnbTest {

    public static testMethod void setupCommonData(){
        Platform__c platformObj = CommonDataTracker.insertPlatform('Pay Money');
        insert platformObj;
        System.assertEquals('Pay Money', [SELECT id,Name FROM Platform__c WHERE id =: platformObj.Id].Name);
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c productObj = CommonDataTracker.insertCustomProduct('Pay Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert productObj;
        System.assertEquals('Pay Money', [SELECT id,Name FROM Product__c WHERE id =: productObj.Id].Name);
        
        Entity__c EntityObj = CommonDataTracker.insertEntity('Test BEntity');
        insert EntityObj;
        
        Account accountObj = CommonDataTracker.InsertAccount('Test Account', 'LegalTestName', 'BMUPA1234Q');
        accountObj.Business_Entity__c = EntityObj.Id;
        accountObj.Type__c = 'Merchant';
        accountObj.Identifier__c = '0009990099';
        insert accountObj;
        system.assertEquals('BMUPA1234Q', [SELECT Id, Name, PAN_Number__c FROM Account WHERE id =:accountObj.id].PAN_Number__c);
        
        Website_Page_Master__c wpm = CommonDataTracker.insertWPM();
        insert wpm;
        System.assertEquals('Terms & Conditions Details', [SELECT Id, Name FROM Website_Page_Master__c WHERE id =:wpm.id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.InsertOpportunity(accountObj);
        opportunityObj.Product__c = productObj.Id;
        opportunityObj.Identifier__c = 'uuid88990045';
        insert opportunityObj;
        
        test.startTest();
        CreateWebsiteDocumentsController_Onb.getMerchantDocumentRecords(opportunityObj.id);
        CreateWebsiteDocumentsController_Onb.createMerchantDocumentRecords(opportunityObj.id);
        CreateWebsiteDocumentsController_Onb.getWPM(wpm.Id);
        CreateWebsiteDocumentsController_Onb.getPicklist();
        CreateWebsiteDocumentsController_Onb.updateWPM(wpm);
        CreateWebsiteDocumentsController_Onb.getWebsite_Error_Meta();
        String result = CreateWebsiteDocumentsController_Onb.getWebsiteError('Limited Liability Clause');
        test.stopTest();
        system.assertEquals('Customers are not being made to accept the Limited Liability Clause before making the payment for the product/service', result);
    }
}