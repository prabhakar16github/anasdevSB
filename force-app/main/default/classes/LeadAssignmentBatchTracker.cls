@isTest
public class LeadAssignmentBatchTracker {

    @testSetup static void setupCommonData(){
        Trigger_Switch__c triggerSwitchObj = CommonDataTracker.insertTriggerSwitch('Lead', true);
        insert triggerSwitchObj ;
        
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);  
                
        Business_Category__c businessCategoryNGO = CommonDataTracker.insertBusinessCategory('NGO', true);
        insert businessCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Business_Category__c WHERE id =: businessCategoryNGO.id].Name);
                
        Sub_Category__c subCategoryNGO = CommonDataTracker.insertSubCategory('NGO', true);
        subCategoryNGO.Category__c = businessCategoryNGO.Id;
        insert subCategoryNGO ;
        System.assertEquals('NGO', [SELECT id, name FROM Sub_Category__c WHERE id =: subCategoryNGO.id].Name);
        
        Platform__c platformObj = CommonDataTracker.insertPlatform('PayU Money');
        insert platformObj;
        System.assertEquals('PayU Money', [SELECT id, name FROM Platform__c WHERE Id =: platformObj.Id].Name);    
        
        string profileId = [SELECT Id, Name FROM Profile WHERE Name =: 'System Administrator' limit 1].id;
        system.assertNotEquals(profileId, null);
        
        user leadConversionUser = CommonDataTracker.insertUser(profileId);
        insert leadConversionUser;
        system.assertNotEquals(leadConversionUser.Id, null);
        
        Product__c prodObj = CommonDataTracker.insertCustomProduct('PayU Money', platformObj, true, 'Biz_Introduction_Template_With_MAF', leadConversionUser);
        insert prodObj; 
        System.assertEquals(platformObj.Id, [SELECT id, name, Platform__c FROM Product__c WHERE Id =: prodObj.Id].Platform__c);
        
        Lead leadObj = CommonDataTracker.insertLead(prodObj, businessCategoryNGO, subCategoryNGO, entityObj);
        leadObj.Lead_Type__c = 'Merchant';
        leadObj.Bank_Verification_Status__c = 'Pending';
        insert leadObj;
        System.assertEquals(prodObj.Id, [SELECT id, Product__c FROM Lead WHERE id =: leadObj.Id].Product__c);
                
    }    
    
    public static testMethod void testData_1(){
        Lead ld = [Select Id,Lead_Type__c,Bank_Verification_Status__c,BatchAssignment__c,IsConverted,ProductLabel__c from Lead];
        test.startTest();
        LeadAssignmentBatchScheduler scdlr = new LeadAssignmentBatchScheduler();
        String sch = '0 0 2 * * ?';
        system.schedule('Check', sch, scdlr);
        Test.stopTest();
    }
}