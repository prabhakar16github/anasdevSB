@isTest
public class TDRScreenControllerTracker{
    
	@testSetup static void setupCommonData(){     
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Address_Details__c', true);
        insert triggerSwitchObj ; 
        
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
        System.assertEquals('GKMSF4212W', [SELECT Id, PAN_Number__c FROM Account WHERE Id =: accountObj.Id].PAN_Number__c);        
        
        Contact contactObj = CommonDataTracker.insertContact(accountObj);
        contactObj.Email = 'uma.shankar@saasfocus.com';
        insert contactObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Contact WHERE Id =: contactObj.Id].AccountId);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Biz');
        insert platformObj;
        System.assertEquals('PayU Biz', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].Id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Biz', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Plan__c planObj = CommonDataTracker.insertPlan('Pay Citrus');
        insert planObj;
        System.assertEquals('Pay Citrus', [SELECT id, Name FROM Plan__c WHERE Id =: planObj.Id].Name);
        
        Opportunity opportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        opportunityObj.Product__c = prodObj.Id;
        insert opportunityObj;
        System.assertEquals(accountObj.Id, [SELECT id, AccountId FROM Opportunity WHERE id =: opportunityObj.Id].AccountId);
        
        Bank_Account_Detail__c bankAccOptyObj = CommonDataTracker.insertBankAccDetails(null, opportunityObj.Id);
        insert bankAccOptyObj; 
        System.assertEquals(opportunityObj.Id, [SELECT id, Opportunity__c FROM Bank_Account_Detail__c WHERE id =: bankAccOptyObj.Id].Opportunity__c);
        
        Commercial__c commercialObj = CommonDataTracker.insertCommercial(opportunityObj, planObj);
        insert commercialObj;
        System.assertEquals(opportunityObj.Id, [SELECT id, Opportunity__c FROM Commercial__c WHERE id =: commercialObj.Id].Opportunity__c);        
    }
    
    @isTest static void testMethodOne(){ 
        
        Opportunity opportunityObj = [SELECT id, AccountId FROM Opportunity LIMIT 1];
        
        Bank_Account_Detail__c bankAccOptyObj = [SELECT id, Opportunity__c FROM Bank_Account_Detail__c WHERE Opportunity__c =: opportunityObj.Id];
        
        Plan__c planObj = [SELECT id, Name FROM Plan__c LIMIT 1];
        
        Commercial__c commercialObj = [SELECT id, Opportunity__c FROM Commercial__c WHERE Opportunity__c =: opportunityObj.Id];
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockClass());
        
        TDRScreenController.getCommercials(opportunityObj.Id);
        
        TDRScreenController.getCommercialRecords(opportunityObj.Id, false, bankAccOptyObj.Id);
        
        TDRScreenController.getRequiredData(commercialObj.Id, planObj.Id, '', opportunityObj.Id, false);
        
        TDRScreenController.getPlanPricingList(opportunityObj.Id);
        
        TDRScreenController.getTdrList(bankAccOptyObj.Id, opportunityObj.Id);
        
        TDRScreenController.getPlans(null, bankAccOptyObj.Id, opportunityObj.Id);
            
        TDRScreenController.pastPlans(opportunityObj.Id); 
        
        TDRScreenController.pastPlans(opportunityObj.Id);
        
        TDRScreenController.getMPOData(opportunityObj.Id, bankAccOptyObj.Id);
        
        TDRScreenController.getMcpData(opportunityObj.Id);
        
        TDRScreenController.getCreateCommData(opportunityObj.Id);
        
        TDRScreenController.getNewTDRData(planObj.Id, false, null, opportunityObj.Id);
        
        TDRScreenController.getPaymentsData(opportunityObj.Id);
        
        TDRScreenController.savePaymentsData(commercialObj, new List<Payment__c>(), new List<Payment__c>());
        
        TDRScreenController.upsertMcpData(new List<Sobject>(), new List<Sobject>(), new List<Sobject>());
        
        TDRScreenController.insertCommercialData(commercialObj, false, new List<String>(), new List<TDR__c>(), new List<MerchantPaymentOption__c>(), new List<MerchantPaymentOption__c>(), new List<TDR__c>(), new List<TDR__c>());
        
        TDRScreenController.deleteCommercial(commercialObj);
        Test.stopTest();
    }
}