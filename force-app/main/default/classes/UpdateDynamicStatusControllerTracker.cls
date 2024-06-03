@isTest
public class UpdateDynamicStatusControllerTracker {
    
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
    
    public static testMethod void testDataforUpdateSettlementStatus(){
        List<Opportunity> oppList = [SELECT id from Opportunity];
        Opportunity opp = [Select id,Pre_Risk_Hold_Reason__c,Pre_Risk_Hold_Reason_Email_Content__c,Risk_Hold_Reasons__c,Risk_Hold_Reason__c,Risk_Hold_Reason_Email_Content__c from opportunity Limit 1];
        UpdateDynamicStatusController.getSettlementStatusPicklist(opp.id);
        UpdateDynamicStatusController.getOBHoldReason();
        test.startTest();
        UpdateDynamicStatusController.updateSelectedStatus(opp.Pre_Risk_Hold_Reason__c, opp.Risk_Hold_Reason_Email_Content__c, opp.Pre_Risk_Hold_Reason_Email_Content__c, 'Opportunity', opp.id, 'Settlement_Status__c', 'Pre-Risk Hold', opp.Risk_Hold_Reasons__c);
        UpdateDynamicStatusController.updateSelectedStatus(opp.Pre_Risk_Hold_Reason__c, opp.Risk_Hold_Reason_Email_Content__c, opp.Pre_Risk_Hold_Reason_Email_Content__c, 'Opportunity', opp.id, 'Settlement_Status__c', 'Risk Hold', 'R1 - Phishing/Vishing attack');
        UpdateDynamicStatusController.updateSelectedStatus(opp.Pre_Risk_Hold_Reason__c, opp.Risk_Hold_Reason_Email_Content__c, opp.Pre_Risk_Hold_Reason_Email_Content__c, 'Opportunity', opp.id, 'Settlement_Status__c', 'OB Hold', 'R1 - Phishing/Vishing attack');
        UpdateDynamicStatusController.updateSelectedStatus('Pre_Risk_Hold_Reason__c', 'Risk_Hold_Reason_Email_Content', 'Pre_Risk_Hold_Reason_Email_Content',  'Opportunity', '23456789' , 'Risk_Hold', 'Test comment', 'R1 - Phishing/Vishing attack');
        test.stopTest();
    }
    
    public static testMethod void testDataQueryListOfReasons(){
        test.startTest();
        UpdateDynamicStatusController.getRiskHoldReason();
        UpdateDynamicStatusController.getRiskHoldAccess();
        UpdateDynamicStatusController.getRiskHoldContent('R1 - Phishing/Vishing attack');
        UpdateDynamicStatusController.getPreRiskHoldReason();
        UpdateDynamicStatusController.getPreRiskHoldEmailContent('PR 2 – Incomplete product and Services detail');
        test.stopTest();
    }
    
    
    public static testMethod void testGetRiskStatusDetail() {

        // Create a test MCare_Dashboard_Case__c record and an associated Opportunity
        MCare_Dashboard_Case__c mcareCase = new MCare_Dashboard_Case__c(
            		Comments_By_Enforcer__c = 'KYC'
            
        );
        insert mcareCase;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
           CloseDate = Date.today(),
            	Risk_Hold_Reasons__c = 'R1 - Phishing/Vishing attack',
            	Risk_Hold_Reason_Email_Content__c = 'merchant',
            	On_OB_Hold__c = 'Y'
              
              
           
         );
        insert opp;
         // Link mcareCase to Opportunity
        mcareCase.Opportunity__c = opp.Id;
        update mcareCase;

        // Create a 'Post Risk' RecordType
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Post Risk' AND SObjectType = 'Risk_status_Detail__c' LIMIT 1];

        // Create Risk_status_Detail__c record
        Risk_status_Detail__c riskDetail = new Risk_status_Detail__c(
            Opportunity__c = opp.Id,
            RecordTypeId = rt.Id
           
        );
        insert riskDetail;

        Test.startTest();

        // Call the getRiskStatusDetail method
        UpdateDynamicStatusController.PostHoldWrapper result = UpdateDynamicStatusController.getRiskStatusDetail(mcareCase.Id);
         
        Test.stopTest();
       

        // Add assertions to verify the result
        System.assertNotEquals(null, result);
         System.assertEquals(opp.Id, result.oppId);
        System.assertEquals(riskDetail.Id, result.postRiskId);
      
    }
     public static testMethod void testWithoutRiskStatusDetails() {

        // Create a test MCare_Dashboard_Case__c record and an associated Opportunity
        MCare_Dashboard_Case__c mcareCase = new MCare_Dashboard_Case__c(
            		Comments_By_Enforcer__c = 'KYC'
          
        );
        insert mcareCase;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
           CloseDate = Date.today(),
            	Risk_Hold_Reasons__c = 'R1 - Phishing/Vishing attack',
            	Risk_Hold_Reason_Email_Content__c = 'merchant',
            	On_OB_Hold__c = 'Y'
              
              
           
         );
        insert opp;
         // Link mcareCase to Opportunity
        mcareCase.Opportunity__c = opp.Id;
        update mcareCase;

       

        Test.startTest();

        // Call the getRiskStatusDetail method
        UpdateDynamicStatusController.PostHoldWrapper result = UpdateDynamicStatusController.getRiskStatusDetail(mcareCase.Id);
         
        Test.stopTest();
       

        // Add assertions to verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(opp.Id, result.oppId);
        System.assertNotEquals(null, result.postRiskId);
        System.assertNotEquals(null, result.obRiskId);
        System.assertNotEquals(null, result.preRiskId);
    }

   public static testMethod void testMcareCaseUpdate() {
        // Create a test MCare_Dashboard_Case__c record
        MCare_Dashboard_Case__c mcareCase = new MCare_Dashboard_Case__c(
            Status__c = 'Risk Hold',
            Risk_Hold_Reason__c = 'R1 - Phishing/Vishing attack',
            	Comments_By_Enforcer__c = 'kyc'
            
        );
        insert mcareCase;

        Test.startTest();

        // Call the mcareCaseUpdate method
        UpdateDynamicStatusController.mcareCaseUpdate(mcareCase.Id, 'R1 - Phishing/Vishing attack', 'Test Comment');

        Test.stopTest();

        // Query the record and assert that it was updated as expected
        MCare_Dashboard_Case__c updatedMcareCase = [SELECT Risk_Hold_Reason__c, Comments_By_Enforcer__c, Status__c FROM MCare_Dashboard_Case__c WHERE Id = :mcareCase.Id];
        System.assertEquals('R1 - Phishing/Vishing attack', updatedMcareCase.Risk_Hold_Reason__c);
        System.assertEquals('Test Comment', updatedMcareCase.Comments_By_Enforcer__c);
        System.assertEquals('Risk Hold', updatedMcareCase.Status__c);
    }
   
 
}