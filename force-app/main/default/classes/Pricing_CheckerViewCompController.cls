public with sharing class Pricing_CheckerViewCompController {
    
    @AuraEnabled
    public static DataWrapper getDataOnLoad(String oppId){
        try {
            DataWrapper dataWrap = new DataWrapper();
            List<Commercial2__c> commercialList = [SELECT Id FROM Commercial2__c 
            WHERE Opportunity__c = :oppId
            LIMIT 1];
            if(!commercialList.isEmpty() ){
                if(!isValidToShowData(commercialList[0].Id)){
                    dataWrap.editAllowed = false;
                    return dataWrap;
                }
                
                for(Pricing__c price : [SELECT Id,Fee_Model__c,Transaction_Type__c,Payment_Mode_Text__c,
                Payment_Option_Text__c,Payment_Gateway_Text__c,Pricing_Specification__r.Name,
                ONUS__c,TDR_Amount__c,TDR_Flat_Fee__c,TDR__c,Convenience_Amount__c,
                Convenience_Flat_Fee__c,Convenience__c,Rule_Id__c,Rule_Id_Conv__c
                FROM Pricing__c
                WHERE Commercial2__c = :commercialList[0].Id 
                AND (Temp_Id_TDR__c != NULL OR Temp_Id_Conv__c != NULL)]){
                    TDRConvPricingWrapper pricingWrap = new TDRConvPricingWrapper();
                    pricingWrap.recordId = price.Id;
                    pricingWrap.paymentMode = price.Payment_Mode_Text__c;
                    pricingWrap.paymentOption = price.Payment_Option_Text__c;
                    pricingWrap.pricingSpecification = price.Pricing_Specification__r.Name;
                    pricingWrap.paymentGateway = price.Payment_Gateway_Text__c;
                    pricingWrap.onusOffus = price.ONUS__c;
                    pricingWrap.debitModel = price.Transaction_Type__c;
                    pricingWrap.feeModel = price.Fee_Model__c;
                    if(price.Transaction_Type__c == 'TDR'){
                        pricingWrap.tdrAmount = price.TDR_Amount__c != NULL ? String.valueOf(price.TDR_Amount__c) : '';
                        pricingWrap.tdrPer = price.TDR__c != NULL ? String.valueOf(price.TDR__c) : '';
                        pricingWrap.tdrFlatFee = price.TDR_Flat_Fee__c != NULL ? String.valueOf(price.TDR_Flat_Fee__c) : '';
                        pricingWrap.showTDR = true;
                    }else if(price.Transaction_Type__c == 'Convenience'){
                        pricingWrap.convAmount = price.Convenience_Amount__c != NULL ? String.valueOf(price.Convenience_Amount__c) : '';
                        pricingWrap.convPer = price.Convenience__c != NULL ? String.valueOf(price.Convenience__c) : '';
                        pricingWrap.convFlatFee = price.Convenience_Flat_Fee__c != NULL ? String.valueOf(price.Convenience_Flat_Fee__c) : '';
                        pricingWrap.showConv = true;
                    }else{
                        pricingWrap.tdrAmount = price.TDR_Amount__c != NULL ? String.valueOf(price.TDR_Amount__c) : '';
                        pricingWrap.tdrPer = price.TDR__c != NULL ? String.valueOf(price.TDR__c) : '';
                        pricingWrap.tdrFlatFee = price.TDR_Flat_Fee__c != NULL ? String.valueOf(price.TDR_Flat_Fee__c) : '';
                        pricingWrap.convAmount = price.Convenience_Amount__c != NULL ? String.valueOf(price.Convenience_Amount__c) : '';
                        pricingWrap.convPer = price.Convenience__c != NULL ? String.valueOf(price.Convenience__c) : '';
                        pricingWrap.convFlatFee = price.Convenience_Flat_Fee__c != NULL ? String.valueOf(price.Convenience_Flat_Fee__c) : '';
                        pricingWrap.showTDR = true;
                        pricingWrap.showConv = true;
                    }
                    if(String.isNotBlank(price.Rule_Id__c) || String.isNotBlank(price.Rule_Id_Conv__c)){
                        pricingWrap.requestType = 'Update';
                    }
                    
                    dataWrap.listPricing.add(pricingWrap);
                    
                }
                
                for(Fixed_Pricing1__c fixedPrice : [SELECT Id,Fee_Type__c,Debit_Model__c,Start_Date__c,End_Date__c,Payment_Frequency__c,
                Amount__c,Percentage__c,Flat_Fee__c 
                FROM Fixed_Pricing1__c
                WHERE Commercial__c = :commercialList[0].Id]){
                    FixedAndPlatformFeeWrapper fixedPriceWrap = new FixedAndPlatformFeeWrapper();
                    fixedPriceWrap.recordId = fixedPrice.Id;
                    fixedPriceWrap.feeType = fixedPrice.Fee_Type__c;
                    fixedPriceWrap.debitModel = fixedPrice.Debit_Model__c;
                    fixedPriceWrap.startDate = fixedPrice.Start_Date__c != NULL ? String.valueOf(fixedPrice.Start_Date__c): '';
                    fixedPriceWrap.endDate = fixedPrice.End_Date__c != NULL ? String.valueOf(fixedPrice.End_Date__c): '';
                    fixedPriceWrap.paymentFrequency = fixedPrice.Payment_Frequency__c;
                    fixedPriceWrap.amount = fixedPrice.Amount__c != NULL ? String.valueOf(fixedPrice.Amount__c): '';
                    fixedPriceWrap.flatFee = fixedPrice.Flat_Fee__c != NULL ? String.valueOf(fixedPrice.Flat_Fee__c): '';
                    fixedPriceWrap.percentage = fixedPrice.Percentage__c != NULL ? String.valueOf(fixedPrice.Percentage__c): '';
                    dataWrap.listFixedPricing.add(fixedPriceWrap);
                }
                
                for(Platform_Fee__c platformFee : [SELECT Id,Type__c,Debit_Model__c,Start_Date__c,End_Date__c,Interval__c,
                Amount__c,Percentage__c,Flat_Fee__c 
                FROM Platform_Fee__c
                WHERE Commercial__c = :commercialList[0].Id]){
                    FixedAndPlatformFeeWrapper platformFeeWrap = new FixedAndPlatformFeeWrapper();
                    platformFeeWrap.recordId = platformFee.Id;
                    platformFeeWrap.feeType = platformFee.Type__c;
                    platformFeeWrap.debitModel = platformFee.Debit_Model__c;
                    platformFeeWrap.startDate = platformFee.Start_Date__c != NULL ? String.valueOf(platformFee.Start_Date__c): '';
                    platformFeeWrap.endDate = platformFee.End_Date__c != NULL ? String.valueOf(platformFee.End_Date__c): '';
                    platformFeeWrap.paymentFrequency = platformFee.Interval__c;
                    platformFeeWrap.amount = platformFee.Amount__c != NULL ? String.valueOf(platformFee.Amount__c): '';
                    platformFeeWrap.flatFee = platformFee.Flat_Fee__c != NULL ? String.valueOf(platformFee.Flat_Fee__c): '';
                    platformFeeWrap.percentage = platformFee.Percentage__c != NULL ? String.valueOf(platformFee.Percentage__c): '';
                    dataWrap.listPlatformPricing.add(platformFeeWrap);
                }
                
                
                
            }
            return dataWrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        //return NULL;
    }
    
    @AuraEnabled
    public static DataWrapper getDataOnLoadDelete(String oppId){
        try {
            DataWrapper dataWrap = new DataWrapper();
            List<Commercial2__c> commercialList = [SELECT Id FROM Commercial2__c 
            WHERE Opportunity__c = :oppId
            LIMIT 1];
            if(!commercialList.isEmpty()){
                if(!isValidToShowData(commercialList[0].Id)){
                    dataWrap.editAllowed = false;
                    return dataWrap;
                }
                for(Pricing__c price : [SELECT Id,Fee_Model__c,Transaction_Type__c,Payment_Mode_Text__c,
                                        Payment_Option_Text__c,Payment_Gateway_Text__c,Pricing_Specification__r.Name,
                                        ONUS__c,TDR_Amount__c,TDR_Flat_Fee__c,TDR__c,Convenience_Amount__c,
                                        Convenience_Flat_Fee__c,Convenience__c
                                        FROM Pricing__c
                                        WHERE Commercial2__c = :commercialList[0].Id 
                                        AND (Temp_Id_Delete_TDR__c != NULL OR Temp_Id_Delete_Conv__c != NULL)]){
                    TDRConvPricingWrapper pricingWrap = new TDRConvPricingWrapper();
                    pricingWrap.recordId = price.Id;
                    pricingWrap.paymentMode = price.Payment_Mode_Text__c;
                    pricingWrap.paymentOption = price.Payment_Option_Text__c;
                    pricingWrap.pricingSpecification = price.Pricing_Specification__r.Name;
                    pricingWrap.paymentGateway = price.Payment_Gateway_Text__c;
                    pricingWrap.onusOffus = price.ONUS__c;
                    pricingWrap.debitModel = price.Transaction_Type__c;
                    pricingWrap.feeModel = price.Fee_Model__c;
                    if(price.Transaction_Type__c == 'TDR'){
                        pricingWrap.tdrAmount = price.TDR_Amount__c != NULL ? String.valueOf(price.TDR_Amount__c) : '';
                        pricingWrap.tdrPer = price.TDR__c != NULL ? String.valueOf(price.TDR__c) : '';
                        pricingWrap.tdrFlatFee = price.TDR_Flat_Fee__c != NULL ? String.valueOf(price.TDR_Flat_Fee__c) : '';
                        pricingWrap.showTDR = true;
                    }else if(price.Transaction_Type__c == 'Convenience'){
                        pricingWrap.convAmount = price.Convenience_Amount__c != NULL ? String.valueOf(price.Convenience_Amount__c) : '';
                        pricingWrap.convPer = price.Convenience__c != NULL ? String.valueOf(price.Convenience__c) : '';
                        pricingWrap.convFlatFee = price.Convenience_Flat_Fee__c != NULL ? String.valueOf(price.Convenience_Flat_Fee__c) : '';
                        pricingWrap.showConv = true;
                    }else{
                        pricingWrap.tdrAmount = price.TDR_Amount__c != NULL ? String.valueOf(price.TDR_Amount__c) : '';
                        pricingWrap.tdrPer = price.TDR__c != NULL ? String.valueOf(price.TDR__c) : '';
                        pricingWrap.tdrFlatFee = price.TDR_Flat_Fee__c != NULL ? String.valueOf(price.TDR_Flat_Fee__c) : '';
                        pricingWrap.convAmount = price.Convenience_Amount__c != NULL ? String.valueOf(price.Convenience_Amount__c) : '';
                        pricingWrap.convPer = price.Convenience__c != NULL ? String.valueOf(price.Convenience__c) : '';
                        pricingWrap.convFlatFee = price.Convenience_Flat_Fee__c != NULL ? String.valueOf(price.Convenience_Flat_Fee__c) : '';
                        pricingWrap.showTDR = true;
                        pricingWrap.showConv = true;
                    }
                    
                    dataWrap.listPricing.add(pricingWrap);
                    
                }
            }
            return dataWrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        //return NULL;
    }
    
    private static Boolean isValidToShowData(String commercialId){
        List<Publish_Pricing_Detail__c> listPublishPricingDetails = [SELECT Id FROM Publish_Pricing_Detail__c
                                                                     WHERE Commercial__c = :commercialId 
                                                                     AND Type__c = 'TDR' 
                                                                     AND Sync_Status__c = 'Processing'];
        if(!listPublishPricingDetails.isEmpty()){
            return false;
        }else{
            return true;
        }
    }

    @AuraEnabled
    public static string handleApprovePricing(List<String> pricingIdList){
        try {
            Set<String> pricingIds = new Set<String>(pricingIdList);
            Database.executeBatch(new PublishPricingToTreasuryTempTableApprove(pricingIds,'SaveBulkRules-CheckerTrueActionApprove',false),50);
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string handleRejectPricing(List<String> pricingIdList,String rejectionReason){
        try {
            Set<String> pricingIds = new Set<String>(pricingIdList);
            List<Pricing__c> pricingListToUpdate = new List<Pricing__c>();
            for(String pricingId : pricingIds){
                Pricing__c pr = new Pricing__c();
                pr.Id = pricingId;
                pr.Checker_Rejection_Reason__c = rejectionReason;
                pricingListToUpdate.add(pr);
            }

            if(!pricingListToUpdate.isEmpty()){
                update pricingListToUpdate;
            }

            Database.executeBatch(new PublishPricingToTreasuryTempTableReject(pricingIds,'SaveBulkRules-CheckerTrueActionReject',false),50);
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string handleDeleteApprovePricing(List<String> pricingIdList){
        try {
            Set<String> pricingIds = new Set<String>(pricingIdList);
            Database.executeBatch(new PublishPricingToTreasuryTempTableApprove(pricingIds,'DeleteBulkRules-CheckerTrueActionApproveDelete',true),50);
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string handleDeleteRejectPricing(List<String> pricingIdList,String rejectionReason){
        try {
            Set<String> pricingIds = new Set<String>(pricingIdList);
            List<Pricing__c> pricingListToUpdate = new List<Pricing__c>();
            for(String pricingId : pricingIds){
                Pricing__c pr = new Pricing__c();
                pr.Id = pricingId;
                pr.Checker_Delete_Rejection_Reason__c = rejectionReason;
                pricingListToUpdate.add(pr);
            }

            if(!pricingListToUpdate.isEmpty()){
                update pricingListToUpdate;
            }

            Database.executeBatch(new PublishPricingToTreasuryTempTableReject(pricingIds,'DeleteBulkRules-CheckerTrueActionReject',true),50);
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    public class DataWrapper{
        @AuraEnabled public Boolean editAllowed = true;
        @AuraEnabled public List<TDRConvPricingWrapper> listPricing = new List<TDRConvPricingWrapper>();
        @AuraEnabled public List<FixedAndPlatformFeeWrapper> listFixedPricing = new List<FixedAndPlatformFeeWrapper>();
        @AuraEnabled public List<FixedAndPlatformFeeWrapper> listPlatformPricing = new List<FixedAndPlatformFeeWrapper>();
        
    }
    
    public class TDRConvPricingWrapper{
        @AuraEnabled public Boolean isChecked = false;
        @AuraEnabled public String recordId = '';
        @AuraEnabled public String paymentMode = '';
        @AuraEnabled public String paymentOption = '';
        @AuraEnabled public String pricingSpecification = '';
        @AuraEnabled public String paymentGateway = '';
        @AuraEnabled public String onusOffus = '';
        @AuraEnabled public String debitModel = '';
        @AuraEnabled public String feeModel = '';
        @AuraEnabled public String tdrAmount = '';
        @AuraEnabled public String tdrPer = '';
        @AuraEnabled public String tdrFlatFee = '';
        @AuraEnabled public String convAmount = '';
        @AuraEnabled public String convPer = '';
        @AuraEnabled public String convFlatFee = '';
        @AuraEnabled public Boolean showTDR = false;
        @AuraEnabled public Boolean showConv = false;
        @AuraEnabled public String requestType = 'Add';

    }
    public class FixedAndPlatformFeeWrapper{
        @AuraEnabled public String recordId = '';
        @AuraEnabled public String feeType = '';
        @AuraEnabled public String debitModel = '';
        @AuraEnabled public String startDate = '';
        @AuraEnabled public String endDate = '';
        @AuraEnabled public String paymentFrequency = '';
        @AuraEnabled public String amount = '';
        @AuraEnabled public String flatFee = '';
        @AuraEnabled public String percentage = '';
    }
    
    
    
    
}