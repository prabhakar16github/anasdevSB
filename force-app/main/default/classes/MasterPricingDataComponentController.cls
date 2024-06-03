public class MasterPricingDataComponentController {
    
    @AuraEnabled
    public static MasterPricingDataWrapper getMasterPricingDataInfo(String recordId) {
        MasterPricingDataWrapper wrpCls = new MasterPricingDataWrapper();
        List<Master_Pricing_Data__c> listMasterPricingData = [SELECT Id,Active_Instrument__c FROM Master_Pricing_Data__c 
                                                              WHERE Id =:recordId];
        if(listMasterPricingData != NULL && listMasterPricingData.size() > 0) {
            wrpCls.currentStatus = listMasterPricingData[0].Active_Instrument__c;
            
            List<Template_Details__c> listTemplateDetails = [SELECT Id FROM Template_Details__c 
                                                             WHERE Master_Pricing_Data__c =:recordId]; 
            if(listTemplateDetails != NULL && listTemplateDetails.size() > 0) 
                wrpCls.numberOfTemplateDetailsRecord = listTemplateDetails.size();
            
            if(wrpCls.currentStatus) {
                List<Pricing__c> listAllPricing = [SELECT Id FROM Pricing__c WHERE Master_Pricing_Data__c = :recordId AND Deleted__c = false];
                if(listAllPricing != NULL && listAllPricing.size() > 0) 
                    wrpCls.numberOfPricingRecords = listAllPricing.size();
                
                List<Pricing__c> listAllPricingPublishedCommercial = [SELECT Id FROM Pricing__c 
                                                                      WHERE Master_Pricing_Data__c = :recordId 
                                                                      AND Commercial2__r.Status__c = 'Live' AND Deleted__c = false AND Published__c = true];
                if(listAllPricingPublishedCommercial != NULL && listAllPricingPublishedCommercial.size() > 0) 
                    wrpCls.numberOfPricingRecordsNeedToSendToTreasury = listAllPricingPublishedCommercial.size(); 
                
                List<AggregateResult> listAgr = [SELECT Count(Id),Opportunity__c FROM Pricing__c 
                                                 WHERE Master_Pricing_Data__c = :recordId AND Deleted__c = false 
                                                 GROUP BY Opportunity__c];
                if(listAgr != NULL && listAgr.size() > 0)
                    wrpCls.numberOfMerchantsImpacted = listAgr.size();
                
            }
            else {
                List<Pricing__c> listUndeletePricing = [SELECT Id FROM Pricing__c WHERE Master_Pricing_Data__c =:recordId AND Deleted_By_Instrument_as_Inactive__c = true];
                if(listUndeletePricing != NULL && listUndeletePricing.size() > 0) 
                    wrpCls.numberOfPricingRecordsToUndelete = listUndeletePricing.size();
                
                List<Pricing__c> listUnpublishedPricing = [SELECT Id FROM Pricing__c WHERE Master_Pricing_Data__c =:recordId AND Unpublished_by_Instrument_as_Inactive__c = true];
                if(listUnpublishedPricing != NULL && listUnpublishedPricing.size() > 0) 
                    wrpCls.numberOfPricingRecordsToPublish = listUnpublishedPricing.size();
                
                List<AggregateResult> listAgr = [SELECT Count(Id),Opportunity__c FROM Pricing__c 
                                                 WHERE Master_Pricing_Data__c =:recordId 
                                                 AND Deleted_By_Instrument_as_Inactive__c = true 
                                                 GROUP BY Opportunity__c];
                if(listAgr != NULL && listAgr.size() > 0) 
                    wrpCls.numberOfMerchantsImpacted = listAgr.size();
                
            }
            
            
        }
        return wrpCls;
    }
    
    public class MasterPricingDataWrapper {
        @AuraEnabled public Boolean currentStatus = false;
        @AuraEnabled public Integer numberOfTemplateDetailsRecord = 0;
        @AuraEnabled public Integer numberOfPricingRecords = 0;
        @AuraEnabled public Integer numberOfPricingRecordsNeedToSendToTreasury = 0;
        @AuraEnabled public Integer numberOfPricingRecordsToUndelete = 0;
        @AuraEnabled public Integer numberOfPricingRecordsToPublish = 0;
        @AuraEnabled public Integer numberOfMerchantsImpacted = 0;
    }
    
    @AuraEnabled 
    public static String updateData(String recordId,Boolean currentStatus) {
        String message = 'SUCCESS';
        try {
            Master_Pricing_Data__c mpd = new Master_Pricing_Data__c();
            mpd.Id = recordId;
            if(currentStatus) mpd.Active_Instrument__c = false;
            else mpd.Active_Instrument__c = true;
            update mpd;
            
            Database.executeBatch(new BatchClassToUpdateTemplateDetails(recordId,currentStatus),2000);
            if(currentStatus) {
                Database.executeBatch(new BatchClassToMarkPricingAsDeletedTrue(recordId),2000);
            }
            else {
                //Database.executeBatch(new BatchClassToMarkPricingAsDeletedFalse(recordId),2000);
            }
        }   
        catch(Exception e) {
            message = e.getMessage();	    
        }
        return message;
    }
}