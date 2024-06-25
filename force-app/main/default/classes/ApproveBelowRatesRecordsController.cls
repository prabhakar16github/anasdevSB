/*
* Name of the class : ApproveBelowRatesRecordsController
* Author's Name     : Anas Yar Khan  
* Description       : Controller for the VF page (ApproveBelowRatesRecords) - Send Data to BH for Approval
* Version.          : 1   
*/
public class ApproveBelowRatesRecordsController {
    public List<Pricing__c> listBelowRackRatesRecords   {get;set;}
    public List<Pricing__c> listAllRecords   {get;set;}
    public static Map<String,Object> mapPriorityToStatus = (Map<String,Object>)JSON.deserializeUntyped(Label.PricingStatusPriority);
    public static Map<String,Integer> mapStatusToPriority = getStatusToPriorityMap();
    
    /*
* Description       : This method is called internally to get the mapStatusToPriority 
* Version.          : 1   
*/
    private static Map<String,Integer> getStatusToPriorityMap() {
        Map<String,Integer> mapStatusToPriority = new Map<String,Integer>();
        If(mapPriorityToStatus != NULL && mapPriorityToStatus.keySet().size() > 0) {
            for(String key : mapPriorityToStatus.keySet()) {
                mapStatusToPriority.put((String)mapPriorityToStatus.get(key),Integer.valueOf(key));    
            }
        }
        return mapStatusToPriority;
    }    
    
    /*
* Description       : This method is called internally to get the MapBankAndPORTypeToStatus 
* Version.          : 1   
*/
    public static Map<String,Integer> getMapBankAndPORTypeToStatus(String opportunityId) {
        Map<String,Integer> mapBankAndPORTypeToStatus = new Map<String,Integer>();
        for(Pricing__c price : [SELECT Bank_Name__c,POR_Type_Name__c,Banking_Ops_Status__c FROM Pricing__c 
                                WHERE Commercial2__r.Opportunity__c = :opportunityId 
                                AND Payment_Gateway2__r.Type__c = 'PostApproved'
                                AND Invisible__c = false
                                AND Deleted__c = false
                                AND Banking_Ops_Status__c IN ('Approved','Rejected','Pending with Bank','Pending with KAM','Pending with Banking ops') 
                                LIMIT 50000]) {
                                    String key = price.Bank_Name__c + '#'+price.POR_Type_Name__c;
                                    if(mapBankAndPORTypeToStatus.containsKey(key)) {
                                        Integer currentPriority = mapBankAndPORTypeToStatus.get(key);
                                        Integer priorityToBeCheck = mapStatusToPriority.get(price.Banking_Ops_Status__c);
                                        if(priorityToBeCheck < currentPriority) {
                                            mapBankAndPORTypeToStatus.put(key,mapStatusToPriority.get(price.Banking_Ops_Status__c));    
                                        }
                                    }   
                                    else {
                                        mapBankAndPORTypeToStatus.put(key,mapStatusToPriority.get(price.Banking_Ops_Status__c));	    
                                    }
                                }
        return mapBankAndPORTypeToStatus;
    }
    
    /*
* Description       : This method is called internally to get the status 
* Version.          : 1   
*/
    private static String getStatus(Pricing__c pricing,Map<String,Integer> mapBankAndPORTypeToStatus,Map<String,Object> mapPriorityToStatus) {
        String keyNew = pricing.Bank_Name__c + '#' + pricing.POR_Type_Name__c;
        if(mapBankAndPORTypeToStatus.containsKey(keyNew)) {
            Integer priority = mapBankAndPORTypeToStatus.get(keyNew);
            return (String)mapPriorityToStatus.get(String.valueOf(priority));
        }
        else {
            return 'Pending with Banking ops';    
        }
    }
    
    
    /*
* Description       : Constructor 
* Version.          : 1   
*/
    public ApproveBelowRatesRecordsController() {
        String commercialId = ApexPages.currentPage().getParameters().get('commercialId');
        if(commercialId != NULL){
            
            Blob bas64decodedId = EncodingUtil.base64Decode(commercialId);
            commercialId = bas64decodedId.toString();
            
            listBelowRackRatesRecords = new List<Pricing__c>();
            listBelowRackRatesRecords = [SELECT Id,Payment_Mode_Text__c,Payment_Option_Text__c,Specifcation__c,Payment_Gateway_Text__c ,TDR_Percentage_Reference__c,
                                         TDR_Amount_Reference__c,TDR_Amount__c,TDR_Flat_Fee__c,TDR__c,Convenience_Percentage_Reference__c,Convenience_Amount_Reference__c,
                                         Convenience_Amount__c,Convenience_Flat_Fee__c,Convenience__c,BH_Status__c,Bank_Name__c,POR_Type_Name__c,Commercial2__r.Opportunity__c,
                                         Payment_Gateway2__r.Type__c
                                         FROM Pricing__c 
                                         WHERE Commercial2__c = :commercialId
                                         AND Below_Rack_Rates__c = true 
                                         AND Deleted__c = false
                                         AND Invisible__c = false
                                         AND Banking_Ops_Status__c = 'Pending with BH'];
            
            listAllRecords = new List<Pricing__c>();
            listAllRecords = [SELECT Id,Payment_Mode_Text__c,Payment_Option_Text__c,Specifcation__c,Payment_Gateway_Text__c ,TDR_Percentage_Reference__c,
                              TDR_Amount_Reference__c,TDR_Amount__c,TDR_Flat_Fee__c,TDR__c,Convenience_Percentage_Reference__c,Convenience_Amount_Reference__c,
                              Convenience_Amount__c,Convenience_Flat_Fee__c,Convenience__c,BH_Status__c,Bank_Name__c,POR_Type_Name__c,Commercial2__r.Opportunity__c,
                              Payment_Gateway2__r.Type__c
                              FROM Pricing__c 
                              WHERE Commercial2__c = :commercialId
                              AND Deleted__c = false
                              AND Invisible__c = false
                              AND Banking_Ops_Status__c != 'Pending with BH'];
        }        
    }
    
    /*
* Description       : This method is called on click of Approve All button 
* Version.          : 1   
*/
    public void approveAllFunction() {
        //To enable the last lastest status of the pricing records
        String opportunityId = listBelowRackRatesRecords[0].Commercial2__r.Opportunity__c;
        Map<String,Integer> mapBankAndPORTypeToStatus = getMapBankAndPORTypeToStatus(opportunityId);
        //----------End | To enable the last lastest status of the pricing records
        Set<String> setPricingIds = new Set<String>();
        for(Pricing__c pricing : listBelowRackRatesRecords) {
            if(pricing.Payment_Gateway2__r.Type__c == 'PostApproved') {
                pricing.Banking_Ops_Status__c = getStatus(pricing,mapBankAndPORTypeToStatus,mapPriorityToStatus);
                if(pricing.Banking_Ops_Status__c == 'Approved') {
                    setPricingIds.add(pricing.Id);    
                }
            }
            else {
                pricing.Banking_Ops_Status__c = 'Approved with BH'; 
                setPricingIds.add(pricing.Id);    
            }
            pricing.BH_Status__c = 'Approved with BH'; 
        }    
        if(listBelowRackRatesRecords.size() > 0) {
            update listBelowRackRatesRecords;
            if(setPricingIds.size() > 0) {
                //Database.executeBatch(new PublishPricingToTreasuryTempTableApprove(setPricingIds),100); 
                /** Update to flow the data to temp table, if commercial status is live and approved from BH */
                Database.executeBatch(new PublishPricingToTreasuryTempTable(setPricingIds,'SaveBulkRules-CheckerFalseActionSave',false),50); 
            }
        }
    }
    
    /*
* Description       : This method is called on click of Reject All button 
* Version.          : 1   
*/
    public void rejectAllFunction() {
        Set<String> setPricingIds = new Set<String>();
        for(Pricing__c pricing : listBelowRackRatesRecords) {
            pricing.Banking_Ops_Status__c = 'Rejected with BH';
            pricing.BH_Status__c = 'Rejected with BH';
            setPricingIds.add(pricing.Id);
        }    
        if(listBelowRackRatesRecords.size() > 0) {
            update listBelowRackRatesRecords;
            //Database.executeBatch(new PublishPricingToTreasuryTempTableReject(setPricingIds),100); 
        }   
    }
    
    /*
* Description       : This method is called on click of Approve button from a row 
* Version.          : 1   
*/
    public void approveSingleRecord() {
        String recordId = Apexpages.currentPage().getParameters().get('pricingId1');
        Set<String> setPricingId = new Set<String>();
        List<Pricing__c> listPricing = [SELECT Bank_Name__c,POR_Type_Name__c,Payment_Gateway2__r.Type__c,Commercial2__r.Opportunity__c FROM Pricing__c WHERE Id = :recordId AND Invisible__c = false];
        if(listPricing != NULL && listPricing.size() > 0) {
            //To enable the last lastest status of the pricing records
            String opportunityId = listPricing[0].Commercial2__r.Opportunity__c;
            Map<String,Integer> mapBankAndPORTypeToStatus = getMapBankAndPORTypeToStatus(opportunityId);
            //----------End | To enable the last lastest status of the pricing records 
            Pricing__c pricing = new Pricing__c();
            pricing.Id = recordId;
            if(listPricing[0].Payment_Gateway2__r.Type__c == 'PostApproved') {
                pricing.Banking_Ops_Status__c = getStatus(listPricing[0],mapBankAndPORTypeToStatus,mapPriorityToStatus);
                if(pricing.Banking_Ops_Status__c == 'Approved') {
                    setPricingId.add(pricing.Id);    
                }
            }
            else {
                pricing.Banking_Ops_Status__c = 'Approved with BH';
                setPricingId.add(recordId);
            }
            pricing.BH_Status__c = 'Approved with BH'; 	
            update pricing;
            if(setPricingId.size() > 0) {
                /** Update to flow the data to temp table, if commercial status is live and approved from BH */
                Database.executeBatch(new PublishPricingToTreasuryTempTable(setPricingId,'SaveBulkRules-CheckerFalseActionSave',false),50); 
                
            }
        }
    }
    
    /*
* Description       : This method is called on click of Reject button from a row 
* Version.          : 1   
*/
    public void rejectSingleRecord() {
        String recordId = Apexpages.currentPage().getParameters().get('pricingId2');
        Set<String> setPricingId = new Set<String>();
        setPricingId.add(recordId);
        Pricing__c pricing = new Pricing__c();
        pricing.Id = recordId;
        pricing.Banking_Ops_Status__c = 'Rejected with BH';
        pricing.BH_Status__c = 'Rejected with BH';
        update pricing;
        //Database.executeBatch(new PublishPricingToTreasuryTempTableReject(setPricingId),100); 
    }
}