/*
* Name of the Class   : PricingTriggerHandler
* Author's Name       : Anas Yar Khan  
* Description         : Handler class for PricingTrigger
* Version.            : 1  
*/
public class PricingTriggerHandler {
    public static  Map<String,List<String>> mapOfDefaultMetadata  = getCustomMeadataRecords();
    public static Map<String,Master_Pricing_Data__c> mapOfMpdData = fetchMasterPricingData();
    
    public static Set<Id> processedIdSet = new Set<Id>();


    /** Added to update belowRack Rate = false,if Source != 'Salesforce',  Added by Prabhakar */
    public static void beforeUpdateHandler(List<Pricing__c> triggerNew,Map<Id,Pricing__c> triggerOldMap){
        for(Pricing__c pricing : triggerNew){
            if(!processedIdSet.contains(pricing.Id)){
                if(pricing.Source__c != 'Salesforce'){
                    if(pricing.Fee_Model__c != triggeroldMap.get(pricing.Id).Fee_Model__c 
                        || pricing.Transaction_Type__c != triggeroldMap.get(pricing.Id).Transaction_Type__c 
                        || pricing.TDR__c != triggerOldMap.get(pricing.Id).TDR__c
                        || pricing.TDR_Amount__c != triggerOldMap.get(pricing.Id).TDR_Amount__c 
                        || pricing.TDR_Flat_Fee__c != triggerOldMap.get(pricing.Id).TDR_Flat_Fee__c
                        || pricing.Convenience__c != triggerOldMap.get(pricing.Id).Convenience__c
                        || pricing.Convenience_Amount__c != triggerOldMap.get(pricing.Id).Convenience_Amount__c 
                        || pricing.Convenience_Flat_Fee__c != triggerOldMap.get(pricing.Id).Convenience_Flat_Fee__c) {
                            
                        /***End******/
                    }else{
                        pricing.Below_Rack_Rates__c = false;
                    }
                }
                processedIdSet.add(pricing.Id);
            }
        }
    }/** END */

    /*
*  Method to fetch all Master Pricing Data records
*/
    public static Map<String,Master_Pricing_Data__c> fetchMasterPricingData(){
        Map<String,Master_Pricing_Data__c> mapOfMpdDataKeyWithPgId = new Map<String,Master_Pricing_Data__c>();
        for(Master_Pricing_Data__c mpd : [SELECT Id,Salesforce_Primary_Key__c,ONUS_OFFUS__c,Payment_Gateway__c,
                                          Payment_Mode__r.Name,Payment_Option__r.Name,Pricing_Specification__r.Name,
                                          Payment_Gateway__r.Name,Payment_Option__c,Pricing_Specification__c,
                                          Payment_Mode__c,POR_File_Name__c,POR_Type__c,Bank__c 
                                          FROM Master_Pricing_Data__c]){
                                              mapOfMpdDataKeyWithPgId.put(mpd.Salesforce_Primary_Key__c, mpd);        
                                          } 
        return mapOfMpdDataKeyWithPgId;
    }
    /**
* THis method is used to get default pricing records from custom metadata  
**/
    public static  Map<String,List<String>> getCustomMeadataRecords(){
        Map<String,List<String>> mapOfMetadata = new  Map<String,List<String>>();
        // Fetching metadata from Custom Metadata Type
        for(Default_Pricing_Records__mdt defaultPricingRecord:[SELECT Id, Default_PayuPgId__c ,Salesforce_Primary_Key__c
                                                               FROM Default_Pricing_Records__mdt ]){
            mapOfMetadata.put(defaultPricingRecord.Default_PayuPgId__c,defaultPricingRecord.Salesforce_Primary_Key__c.split(','));
        }
        return mapOfMetadata;
    }
      /*
*  Method to fetch  Pricing Data records based on custom default metadata keys
*/
    public static Map<String,Pricing__c> fetchPricingData(){
        Set<String> sfPrimeryKey = new Set<String>();
        for(List<String> str :mapOfDefaultMetadata.values() ){
            sfPrimeryKey.addAll(str);
        }
        Map<String,Pricing__c> mapOfPricingDataKeyWithPgId = new Map<String,Pricing__c>();
        for(Pricing__c pricing : [SELECT Id,TDR_Amount__c,TDR__c,TDR_Flat_Fee__c,Convenience_Amount__c,Convenience__c,
                                  Convenience_Flat_Fee__c,Fee_Model__c,Transaction_Type__c,Master_Pricing_SF_Key__c FROM 
                                  Pricing__c 
                                  WHERE Master_Pricing_SF_Key__c IN : sfPrimeryKey AND Invisible__c=true]){
            mapOfPricingDataKeyWithPgId.put(pricing.Master_Pricing_SF_Key__c , pricing);        
        } 
        return mapOfPricingDataKeyWithPgId;
    }
    
    public static void afterInsertHandler(List<Pricing__c> triggerNew){
        /*******SFI-1728 Below logic has written for**********/
       Set<String> uniquePayuPg = new Set<String>();
        try{
            List<Pricing__c> pricingListToInsert = new List<Pricing__c>();
            // Iterate over Pricing records
            for(Pricing__c pricing : triggerNew){
                // Check if metadata contains the key
                if(mapOfDefaultMetadata.containsKey(pricing.Master_Pricing_SF_Key__c ) && !uniquePayuPg.contains(pricing.Master_Pricing_SF_Key__c)){
                    for(String defaultRecordPg : mapOfDefaultMetadata.get(pricing.Master_Pricing_SF_Key__c )){
                        Master_Pricing_Data__c mpd = mapOfMpdData.get(defaultRecordPg);
                        // Creating pricing records based on default payuPgid
                        if(mpd !=NULL){
                            Pricing__c pricingRecord = new Pricing__c();
                            pricingRecord.Opportunity__c = pricing.Opportunity__c;
                            pricingRecord.Commercial2__c = pricing.Commercial2__c;
                            pricingRecord.Master_Pricing_Data__c = mpd.Id;
                            pricingRecord.Fee_Model__c = pricing.Fee_Model__c;
                            pricingRecord.Transaction_Type__c = pricing.Transaction_Type__c;
                            pricingRecord.Payment_Gateway2__c = mpd.Payment_Gateway__c;
                            pricingRecord.Invisible__c = True;
                            pricingRecord.Banking_Ops_Status__c = 'Pending with Banking ops';
                            pricingRecord.Payment_Option2__c = mpd.Payment_Option__c;
                            pricingRecord.Pricing_Specification__c = mpd.Pricing_Specification__c;
                            pricingRecord.Specifcation__c =  mpd.Pricing_Specification__r.Name;
                            pricingRecord.Payment_Mode__c = mpd.Payment_Mode__c;
                            pricingRecord.POR_File_Name__c = mpd.POR_File_Name__c;
                            pricingRecord.POR_Type__c = mpd.POR_Type__c;
                            pricingRecord.Bank__c = mpd.Bank__c;
                            pricingRecord.ONUS__c = mpd.ONUS_OFFUS__c;
                            if(pricing.Transaction_Type__c=='TDR'){
                                pricingRecord.TDR_Amount__c = pricing.TDR_Amount__c;
                                pricingRecord.TDR__c =    pricing.TDR__c;  
                                pricingRecord.TDR_Flat_Fee__c = pricing.TDR_Flat_Fee__c;
                            }
                            else if(pricing.Transaction_Type__c=='Convenience'){
                                pricingRecord.Convenience_Amount__c = pricing.Convenience_Amount__c;
                                pricingRecord.Convenience__c =    pricing.Convenience__c;    
                                pricingRecord.Convenience_Flat_Fee__c = pricing.Convenience_Flat_Fee__c;
                            }
                            else if(pricing.Transaction_Type__c=='TDR + Convenience'){
                                pricingRecord.TDR_Amount__c = pricing.TDR_Amount__c;
                                pricingRecord.TDR__c =    pricing.TDR__c; 
                                pricingRecord.TDR_Flat_Fee__c = pricing.TDR_Flat_Fee__c;
                                pricingRecord.Convenience_Amount__c = pricing.Convenience_Amount__c;
                                pricingRecord.Convenience__c =    pricing.Convenience__c;  
                                pricingRecord.Convenience_Flat_Fee__c = pricing.Convenience_Flat_Fee__c;
                            }
                            uniquePayuPg.add(pricing.Master_Pricing_SF_Key__c);
                            pricingListToInsert.add(pricingRecord); 
                        }
                    }
                }
            }  
            // Insert Pricing records
            if(!pricingListToInsert.isEmpty()){
                Insert pricingListToInsert;
            }
        }
        catch(Exception ex){
            System.debug('Exception:::::'+ex.getMessage() +' Line number:::::'+ex.getLinenumber());
        }
        /**********END*********/
    }
    /*
* Name of the function   : afterUpdate
* Author's Name          : Anas Yar Khan  
* Description            : This method will call on the after update event
* Version.            : 1  
*/
    public static void afterUpdate(List<Pricing__c> triggerNew,Map<Id,Pricing__c> triggerOldMap) {
        // this list is used to store all the pricing records which we need to query from sf
        Set<String> sfDefaultKeyListToDelete = new Set<String>();
        List<Pricing__c> defaultPricingList = new List<Pricing__c>();
        // Created a map to store commercial id and there related pricing records Id
        Map<Id,Set<String>> commPricingMap = new Map<Id,Set<String>>();
        List<Pricing__c> listPricingToUpdate = new List<Pricing__c>();
        for(Pricing__c pricing : triggerNew) {
            Pricing__c oldPricing = triggerOldMap.get(pricing.Id);
            if(pricing.Fee_Model__c != triggeroldMap.get(pricing.Id).Fee_Model__c 
               || pricing.Transaction_Type__c != triggeroldMap.get(pricing.Id).Transaction_Type__c 
               || pricing.TDR__c != triggerOldMap.get(pricing.Id).TDR__c
               || pricing.TDR_Amount__c != triggerOldMap.get(pricing.Id).TDR_Amount__c 
               || pricing.TDR_Flat_Fee__c != triggerOldMap.get(pricing.Id).TDR_Flat_Fee__c
               || pricing.Convenience__c != triggerOldMap.get(pricing.Id).Convenience__c
               || pricing.Convenience_Amount__c != triggerOldMap.get(pricing.Id).Convenience_Amount__c 
               || pricing.Convenience_Flat_Fee__c != triggerOldMap.get(pricing.Id).Convenience_Flat_Fee__c) {
                   /* Pricing__c pricingDummy = new Pricing__c();
                   pricingDummy.Id = pricing.Id;
                   pricingDummy.Need_to_Publish__c = true;
                   listPricingToUpdate.add(pricingDummy); */
                   //*******SFI-1728 By Rohit*****/
                   if(mapOfDefaultMetadata.containsKey(pricing.Master_Pricing_SF_Key__c )){
                       defaultPricingList.add(pricing);
                   }
                   /***End******/
               }
            /********SFI-1651 By Rohit************/
            /*else if(pricing.Banking_Ops_Status__c != oldPricing.Banking_Ops_Status__c
                    && pricing.Banking_Ops_Status__c=='Approved'){
                        Set<String> setPricingIds = new Set<String>();
                        if(commPricingMap.containsKey(pricing.Commercial2__c)) {
                            commPricingMap.get(pricing.Commercial2__c).add(pricing.Id);
                        } 
                        else{
                            commPricingMap.put(pricing.Commercial2__c, new Set<String>{pricing.Id}); 
                        }
                    }*/
            /********End**********/
            //*******SFI-1728 Rohit This condition is written when defalut pricing records will be removed then all the pricing records should
            // be deleted which created while inserting the default pricing records from commercial
            else if(mapOfDefaultMetadata.containsKey(pricing.Master_Pricing_SF_Key__c ) && 
                    pricing.Deleted__c != oldPricing.Deleted__c && pricing.Deleted__c){
                        sfDefaultKeyListToDelete.addAll(mapOfDefaultMetadata.get(pricing.Master_Pricing_SF_Key__c));
                    }
        }
        // Process collected pricing records in batches
        /********SFI-1651************/
        /*if(!commPricingMap.isEmpty()){
            for(Id commercialId : commPricingMap.keySet()) {
                // calling the batch class to send every commercial related pricing records to temp table
                Database.executeBatch(new PublishPricingToTreasuryTempTable(commPricingMap.get(commercialId)),500);
            }
        }*/
        /********End**********/
        /*******SFI-1728******/
        if(!sfDefaultKeyListToDelete.isEmpty()){
            List<Pricing__c> pricingListToUpdateForDeletedREcords = new List<Pricing__c>();
            for(Pricing__c pricing :  [SELECT Id,Deleted__c FROM Pricing__c WHERE Master_Pricing_SF_Key__c 
                                       IN: sfDefaultKeyListToDelete AND Invisible__c = True ]){
                pricing.Deleted__c = True;
                pricingListToUpdateForDeletedREcords.add(pricing);
            } 
            if(!pricingListToUpdateForDeletedREcords.isEmpty()){
                Update pricingListToUpdateForDeletedREcords;
            }
        }
        /*******End*********/
        if(listPricingToUpdate.size() > 0) update listPricingToUpdate; 
         /*******SFI-1728******/
        if(!defaultPricingList.isEmpty()){
            // fetch Pricing records based on all payuPgId(sf primery Key) and Invisible true
            Map<String,Pricing__c> mapOfPricingData = fetchPricingData();
            List<Pricing__c> pricingListToUpdateREcords = new List<Pricing__c>();
            for(Pricing__c defaultPricing : defaultPricingList) {
                for(String defaultRecordPg : mapOfDefaultMetadata.get(defaultPricing.Master_Pricing_SF_Key__c )){
                    Pricing__c pricingRecord = mapOfPricingData.get(defaultRecordPg);
                    if(pricingRecord !=NULL){
                        // Updating pricing records
                        pricingRecord.Fee_Model__c = defaultPricing.Fee_Model__c;
                        pricingRecord.Transaction_Type__c = defaultPricing.Transaction_Type__c;
                        if(defaultPricing.Transaction_Type__c=='TDR'){
                            pricingRecord.TDR_Amount__c = defaultPricing.TDR_Amount__c;
                            pricingRecord.TDR__c =    defaultPricing.TDR__c;  
                            pricingRecord.TDR_Flat_Fee__c = defaultPricing.TDR_Flat_Fee__c;
                        }
                        else if(defaultPricing.Transaction_Type__c=='Convenience'){
                            pricingRecord.Convenience_Amount__c = defaultPricing.Convenience_Amount__c;
                            pricingRecord.Convenience__c =    defaultPricing.Convenience__c;    
                            pricingRecord.Convenience_Flat_Fee__c = defaultPricing.Convenience_Flat_Fee__c;
                        }
                        else if(defaultPricing.Transaction_Type__c=='TDR + Convenience'){
                            pricingRecord.TDR_Amount__c = defaultPricing.TDR_Amount__c;
                            pricingRecord.TDR__c =    defaultPricing.TDR__c; 
                            pricingRecord.TDR_Flat_Fee__c = defaultPricing.TDR_Flat_Fee__c;
                            pricingRecord.Convenience_Amount__c = defaultPricing.Convenience_Amount__c;
                            pricingRecord.Convenience__c =    defaultPricing.Convenience__c;  
                            pricingRecord.Convenience_Flat_Fee__c = defaultPricing.Convenience_Flat_Fee__c;
                        }
                        pricingListToUpdateREcords.add(pricingRecord);
                    }
                }
            }
            if(!pricingListToUpdateREcords.isEmpty()) Update pricingListToUpdateREcords;
        }
        /********End*****/
    }
}