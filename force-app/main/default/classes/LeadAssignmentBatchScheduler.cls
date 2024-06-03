public class LeadAssignmentBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC) {
        // For Normal leads
        string normalBatchName = 'LeadAssignmentBatch';
        If(validateBatchClass(normalBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(normalBatchName)); 
        
        // For Shopmatic leads
        string shopmaticBatchName = 'LeadAssignmentShopmaticsBatch';
        If(validateBatchClass(shopmaticBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(shopmaticBatchName));
        
        // For Shopify leads
        string shopifyBatchName = 'LeadAssignmentShopifyBatch';
        If(validateBatchClass(shopifyBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(shopifyBatchName));
        
        // For Marketing leads
        string marketingBatchName = 'LeadAssignmentMarketingBatch';
        If(validateBatchClass(marketingBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(marketingBatchName));
      
     // For PayUTuition leads
        string PayUTuitionBatchName = 'LeadAssignmentPayUTuitionBatch';
        If(validateBatchClass(PayUTuitionBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(PayUTuitionBatchName));
      
      // For SalendraKumar leads
        string SalendraKumarBatchName = 'LeadAssignmentSalendraKumarBatch';
        If(validateBatchClass(SalendraKumarBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(SalendraKumarBatchName));
      
      // For PayURetailStoresBatchName leads
        string PayURetailStoresBatchName = 'LeadAssignmentPayURetailStoresBatch';
        If(validateBatchClass(PayURetailStoresBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(PayURetailStoresBatchName));
      
      // For PayUNGO leads
        string PayUNGOBatchName = 'LeadAssignmentPayUNGOBatch';
        If(validateBatchClass(PayUNGOBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(PayUNGOBatchName));
      
      // For PayUCAs leads
        string PayUCAsBatchName = 'LeadAssignmentPayUCAsBatch';
        If(validateBatchClass(PayUCAsBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(PayUCAsBatchName));
      
      // For PayUFreelancers leads
        string PayUFreelancersBatchName = 'LeadAssignmentPayUFreelancersBatch';
        If(validateBatchClass(PayUFreelancersBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(PayUFreelancersBatchName));
      
      // For PayUHomeEntrepreneu leads
        string PayUHomeEntrepreneuBatchName = 'LeadAssignmentPayUHomeEntrepreneuBatch';
        If(validateBatchClass(PayUHomeEntrepreneuBatchName))
      		Database.executeBatch(new LeadAssignmentBatch(PayUHomeEntrepreneuBatchName)); 
   }
    
    Public static Boolean validateBatchClass(String batchSettingName){
        Batch_Setting__mdt batchSetting = [SELECT MasterLabel, Where_Clause__c,Record_Limit__c,Iteration_Count__c,Re_Run_Apex_Job__c, 
                        Fields_To_Query__c,Verification_Hours__c,Group_Developer_Name__c,Partner_UUID__c,Active__c
                        FROM Batch_Setting__mdt WHERE MasterLabel =:batchSettingName LIMIT 1];
        return batchSetting.Active__c;
    }
}