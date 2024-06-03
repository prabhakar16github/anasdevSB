@isTest
public class VerifyPennyControllerTracker{
    
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
        
        Product__c productObj = CommonDataTracker.insertCustomProduct('payu biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert productObj;
        System.assertEquals('payu biz', [SELECT id,Name FROM Product__c WHERE id =: productObj.Id].Name);
        
        Entity__c EntityObj = CommonDataTracker.insertEntity('Test BEntity');
        insert EntityObj;
        
        Business_Category__c businessCategoryObj = CommonDataTracker.insertBusinessCategory('businessCat', false);
        insert businessCategoryObj;
        
        Sub_Category__c subCategoryObj = CommonDataTracker.insertSubCategory('subCat', false);
        subCategoryObj.Category__c = businessCategoryObj.Id;
        insert subCategoryObj;
        
        Lead leadObj = CommonDataTracker.insertLead(productObj, businessCategoryObj, subCategoryObj, EntityObj);
        insert leadObj;
          
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'LegalName86823', 'GKMSF4212W');
        accountObj.Business_Entity__c =  entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        accountObj.Document_Status__c = 'Docs Approved';
        accountObj.LOB_Status__c = 'Approved';
        accountObj.Agreement_Status__c = 'Approved';
        accountObj.Dow_Jones_Status__c = 'Match Found';
        accountObj.Document_Status__c = 'Docs Approved';
        insert accountObj;
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
        insert opportunityObj;
        
        Bank_Account_Detail__c bankDetailObj = CommonDataTracker.insertBankAccDetails(leadObj.Id, null);
        insert bankDetailObj;
        
        Bank_Account_Detail__c bankDetailObj1 = CommonDataTracker.insertBankAccDetails(null, opportunityObj.Id);
        insert bankDetailObj1;
    }
    
    @isTest static void testMethodTwo(){        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Lead__c FROM Bank_Account_Detail__c WHERE Lead__c != null LIMIT 1];
        bankAccObj.Verification_Status__c = 'Success';
        update bankAccObj;
        
        test.startTest();
        
        Lead leadObj = [SELECT id, Name FROM Lead LIMIT 1 ];
        leadObj.Business_Entity__c = null;
        leadObj.BusinessCategory__c = null;
        leadObj.Sub_Category__c = null;
        update leadObj;
        
        VerifyPennyController.pennyVerificationDetails(bankAccObj.Id);
        
        leadObj.Delivery_Duration__c = null;
        leadObj.PAN_Holder_Name__c = '';
        leadObj.PAN_Number__c = '';
        leadObj.Website__c = '';
        leadObj.Legal_Name__c = '';
        leadObj.Merchant_Id__c = null;
        leadObj.GST_Number__c = null;
        update leadObj;
        
        VerifyPennyController.pennyVerificationDetails(bankAccObj.Id);
        VerifyPennyController.penyVerificationStatus(bankAccObj);
        
        Product__c productObj = [SELECT id, Name FROM Product__c LIMIT 1];
        productObj.Name = 'payu money';
        update productObj;
        
        VerifyPennyController.pennyVerificationDetails(bankAccObj.Id);
        test.stopTest();
    }
    
    @isTest static void testMethodOne(){        
        Bank_Account_Detail__c bankAccObj = [SELECT id, Opportunity__c FROM Bank_Account_Detail__c WHERE Opportunity__c != null LIMIT 1];
        bankAccObj.Verification_Status__c = 'Success';
        update bankAccObj;
        
        test.startTest();
        
        Opportunity leadObj = [SELECT id, Name FROM Opportunity LIMIT 1 ];
        
        
        
        update leadObj;
        
        VerifyPennyController.pennyVerificationDetails(bankAccObj.Id);
                        
        
        leadObj.Website__c = '';
        
        leadObj.Merchant_Id__c = null;
        leadObj.GST_Number__c = null;
        update leadObj;
        
        VerifyPennyController.pennyVerificationDetails(bankAccObj.Id);
        VerifyPennyController.penyVerificationStatus(bankAccObj);
        
        Product__c productObj = [SELECT id, Name FROM Product__c LIMIT 1];
        productObj.Name = 'payu money';
        update productObj;
        
        VerifyPennyController.pennyVerificationDetails(bankAccObj.Id);
        test.stopTest();
    }
}