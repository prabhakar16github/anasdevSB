global class ShopmaticLeadBatchForDSC implements Database.Batchable<sObject>{

   global Database.QueryLocator start(Database.BatchableContext BC){
       Batch_Setting__mdt batchSetting = [SELECT MasterLabel, Iteration_Count__c, Partner_UUID__c, Record_Limit__c, Where_Clause__c FROM Batch_Setting__mdt WHERE MasterLabel = 'ShopmaticLeadBatchForDSC'];
       String squery = 'SELECT Id, ownerId, Bank_Verification_Status__c, Partner_ID__c, createdDate, ProductLabel__c, Lead_Type__c, Partner__c, Partner_Source__c FROM LEAD WHERE Bank_Verification_Status__c != \'Success\' AND ProductLabel__c = \'PayUmoney\' AND Lead_Type__c = \'Merchant\' AND Owner_Queue_name__c != \'PayU SMB Outsource Team\'';
       squery += String.isNotBlank(batchSetting.Partner_UUID__c) ? ' AND Partner_ID__c IN ('+batchSetting.Partner_UUID__c+')' : '';
       squery += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+ batchSetting.Where_Clause__c : '';
       squery += batchSetting.Record_Limit__c != null ? ' LIMIT '+batchSetting.Record_Limit__c : '';
       system.debug('-->> '+squery);
       return Database.getQueryLocator(squery);
   }

   global void execute(Database.BatchableContext BC, List<Lead> scope){
       Batch_Setting__mdt batchSetting = [SELECT Verification_Hours__c FROM Batch_Setting__mdt WHERE MasterLabel = 'ShopmaticLeadBatchForDSC'];
       system.debug('Hours'+Integer.valueof(batchSetting.Verification_Hours__c));
       DateTime dtForShopmatic = Datetime.now().addHours(Integer.valueof(batchSetting.Verification_Hours__c));
       List<Lead> leadsToUpdate = new List<Lead>();
       Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));
       Group grp = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName ='PayU_SMB_Outsource_Team' AND Type =: 'Queue' LIMIT 1];
       if(grp != null && grp.GroupMembers != null && !grp.GroupMembers.isEmpty()){
           for(Lead lead : scope){
               Integer userIndex = Math.mod(IntrandomNumber, grp.GroupMembers.Size());
               if(lead.Partner_ID__c == Label.Shopmatric_UUID){
                   if(lead.CreatedDate < dtForShopmatic){
                       lead.ownerId = grp.GroupMembers.get(userIndex).UserOrGroupId;
                       leadsToUpdate.add(lead); 
                   }
               }
               IntrandomNumber += 1;
           }
       }
       if(!leadsToUpdate.isEmpty()) update leadsToUpdate;
    }

   global void finish(Database.BatchableContext BC){}

}