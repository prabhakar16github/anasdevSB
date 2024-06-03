@isTest
public class CreateCaseFormControllerTracker {
    
     @testSetup
    Public Static void testSetupData(){
        Entity__c entityObj = CommonDataTracker.insertEntity('Society');
        insert entityObj;
        System.assertEquals('Society', [SELECT id, Name FROM Entity__c WHERE Id =: entityObj.id].Name);
        
        Account accountObj = CommonDataTracker.insertAccount('Test Account', 'Legal', 'GATSF4253W');
        accountObj.Business_Entity__c = entityObj.Id;
        accountObj.Identifier__c = '9867587879089887';
        insert accountObj;
        Opportunity OpportunityObj = CommonDataTracker.insertOpportunity(accountObj);
        insert OpportunityObj;
        OpportunityObj.Pre_Risk_Hold_Reason__c = 'PR 6 - Line of business not supported by Visa / Master Card';
        OpportunityObj.Pre_Risk_Hold_Reason_Email_Content__c = 'Test Email Content';
        OpportunityObj.Risk_Hold_Reasons__c = 'R1 - Phishing/Vishing attack';
        OpportunityObj.Risk_Hold_Reason__c = 'Test';
        OpportunityObj.Risk_Hold_Reason_Email_Content__c = 'Test Email Content';
        update OpportunityObj;
        System.assertEquals('GATSF4253W', [SELECT id, PAN_Number__c FROM Account WHERE Id =: accountObj.id].PAN_Number__c);
     }
    
    
    @IsTest
    static void testgetRecordTypeId() {
        CreateCaseFormController.getRecordTypeId(true);
    }
    
    @isTest
        static void testGetMerchantDetails() {
           
            List<Opportunity> oppList = [SELECT id from Opportunity];
            Opportunity opp = [SELECT Id, MerchantName__c, Email__c, Mobile__c FROM Opportunity LIMIT 1];
           
            Map<String, Object> result = CreateCaseFormController.getMerchantDetails('23456789');
            
            // Verify the results
            /*System.assertEquals(true, result.get('success'), 'Success should be true for a valid merchantId');
            System.assertEquals(opp.Id, ((Opportunity)result.get('data')).Id, 'Returned data should match the test Opportunity record');
            
            // Test invalid merchantId scenario
            Map<String, Object> invalidResult = CreateCaseFormController.getMerchantDetails('InvalidMerchantId');
            System.assertEquals(false, invalidResult.get('success'), 'Success should be false for an invalid merchantId');
            System.assertEquals('Invalid Merchant Id', invalidResult.get('errorMessage'), 'Error message should be "Invalid Merchant Id"');*/
        }
    
    
    
}