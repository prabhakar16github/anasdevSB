@isTest
public class PlanFormControllerTracker {
	
    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Lead', true);
        insert triggerSwitchObj ;
        
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
        
        Plan__c planObj = CommonDataTracker.insertPlan('Pay Citrus');
        insert planObj;
        System.assertEquals('Pay Citrus', [SELECT id, Name FROM Plan__c WHERE Id =: planObj.Id].Name);
        
        Payment_Gateway__c payGateObj = CommonDataTracker.insertPaymentGateway();
        payGateObj.Active__c = true;
        insert payGateObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Payment_Gateway__c WHERE Id =: payGateObj.Id].Active__c);
        
        Plan_Pricing__c planPricingObj = CommonDataTracker.insertPlanPricing(payGateObj);
        insert planPricingObj;
        System.assertEquals(true, [SELECT id, Active__c FROM Plan_Pricing__c WHERE Id =: planPricingObj.Id].Active__c);
        
        PricingPaymentOption__c PricingPayOptionObj = CommonDataTracker.insertPricingPayOption();
        insert PricingPayOptionObj;
        System.assertNotEquals(null, PricingPayOptionObj.Id);    
    }
    
    @isTest static void testMethodOne() {
        Plan__c planObj = [SELECT id, Name FROM Plan__c LIMIT 1];
        
        List<Plan_Pricing__c> lstPlanPricing = [SELECT id, Active__c FROM Plan_Pricing__c];
        
        PricingPaymentOption__c pricingPayOptObj = [SELECT Id FROM PricingPaymentOption__c LIMIT 1];  
        List<PricingPaymentOption__c> paypentOptionsToInsert = new List<PricingPaymentOption__c>();
        List<Plan_Pricing__c> pricingToInsert = new List<Plan_Pricing__c>();
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockClass());
        PlanFormController.getPaymentOptionData(planObj.Id);
        
        PlanFormController.insertPlanAndPricing(planObj, new List<String>{pricingPayOptObj.Id}, lstPlanPricing, paypentOptionsToInsert, paypentOptionsToInsert, pricingToInsert, pricingToInsert);
        
        Test.stopTest();
        
    }
}