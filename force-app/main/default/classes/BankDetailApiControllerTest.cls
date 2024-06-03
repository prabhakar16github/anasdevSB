@isTest
public class BankDetailApiControllerTest {
    
    @testSetup 
    public static void setupData(){
        
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
        
        Business_Category__c businessCategoryObj = CommonDataTracker.insertBusinessCategory('businessCat', false);
        insert businessCategoryObj;
        
        Sub_Category__c subCategoryObj = CommonDataTracker.insertSubCategory('subCat', false);
        subCategoryObj.Category__c = businessCategoryObj.Id;
        insert subCategoryObj;
        
        Lead leadObj = CommonDataTracker.insertLead(productObj, businessCategoryObj, subCategoryObj, EntityObj);
        leadObj.Identifier__c = '11e8-c0bf';
        insert leadObj;                
    }
    
    static testMethod void testInsertBankDetail(){
        
        Lead leadObj = [SELECT id, Name FROM Lead LIMIT 1 ];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/initiateleadConversion/';  
        String postData = '{"bank_detailable_uuid": "11e8-c0bf","active": false,"uuid": "c513-c4431C33","penny_deposit_status": "Not Initiated","verification_status": null,"penny_deposit_attempt_count": 2,"penny_deposit_method": null,"bank_detailable_type": null,"nodal_status": null,"nodal_code": null,"type": "Current","holder_name": "AGGREPAY PAYMENTS SOLUTIONS PRIVATE LIMITED","ifsc_code": "HDFC0000291","bank_account_number": "50200027848351","name": null}';
        req.requestBody = blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        BankDetailApiController.getBankDetails(); 
        
        Bank_Account_Detail__c bankDetailObj = CommonDataTracker.insertBankAccDetails(leadObj.Id, null);
        bankDetailObj.Identifier__c = 'Temp1234';
        insert bankDetailObj;
        
        BankDetailApiController.getBankDetails(); 
        
        leadObj.Identifier__c = '';
        update leadObj;
        
        BankDetailApiController.getBankDetails(); 
        
        Test.stopTest();
    }
}