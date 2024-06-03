public class PayoutPricingDetailVFCompController {
    public string assignedOppId {get;set;}
    public string assignedCSId {get;set;}
    
    public List<Fee_Master__c> listFeeMaster {get; set;}
    public List<Cross_Sell__c> listCrossSell {get; set;}
    public List<Fee_Master__c> listPayoutFeeMaster {get; set;}
    public Map<String, List<pricingTableWrapper>> pricingMap {get;set;} 
    public Map<String, Integer> pricingCountMap{get;set;}
    public List<String> modeList {get;set;}
    
    public Boolean init{
        get{
            init();
            return false;
        }
    }
    
    public Boolean detailCompInit{
        get{
            if(string.isNotBlank(assignedCSId)) detailCompInit();
            return false;
        }
    }

    public Address_Details__c regAddress {get;set;} 
    public Address_Details__c opAddress {get;set;}
    public string merchantDocLink {get;set;}
    public Opportunity optyObj {get;set;}
    
    public void init(){
        listFeeMaster = New List<Fee_Master__c>();
        listCrossSell = New List<Cross_Sell__c>();
        listPayoutFeeMaster = New List<Fee_Master__c>();
        pricingMap = new Map<String, List<pricingTableWrapper>>();
        pricingCountMap = new Map<String, Integer>();
        modeList = new List<String>();
       
        if(assignedOppId != null && assignedOppId !=''){
            listCrossSell = getPayoutCrossSell(assignedOppId);
             
            if(!listCrossSell.isEmpty() && listCrossSell !=null){
                Set<String> payoutCSIds = New Set<String>();
                for(Cross_Sell__c eachCS : listCrossSell){
                    if(eachCS.Custom_Product__r.Name == 'Payout') payoutCSIds.add(eachCS.Id);
                }
                if(!payoutCSIds.isEmpty() && payoutCSIds != null){
                    listPayoutFeeMaster = getPayoutFeeMaster(payoutCSIds);
                }
                if(!listPayoutFeeMaster.isEmpty()){
                    for(Fee_Master__c eachFM : listPayoutFeeMaster){
                        List<pricingTableWrapper> pricingWrapperList = new List<pricingTableWrapper>();
                        if(String.isNotBlank(eachFM.Pricing_Configurator__c)){
                            Map<String, Object> pricingObjList = (Map<String, Object>)JSON.deserializeUntyped(eachFM.Pricing_Configurator__c);
                            system.debug('####### pricingObjList '+pricingObjList);
                            
                            for(string keyAmount : pricingObjList.keySet()){
                                Map<String, Object> pricingObjValueMap = (Map<String, Object>)pricingObjList.get(keyAmount);
                                if(pricingMap.containsKey(eachFM.Mode__c)){
                                    pricingWrapperList = pricingMap.get(eachFM.Mode__c);
                                    if(pricingObjValueMap.containsKey('percent'))
                                        pricingWrapperList.add(new pricingTableWrapper(eachFM.Mode__c,keyAmount,'INR '+String.valueOf(pricingObjValueMap.get('percent'))));
                                    pricingMap.put(eachFM.Mode__c, pricingWrapperList);
                                    pricingCountMap.put(eachFM.Mode__c, pricingWrapperList.size());
                                }else{
                                    if(pricingObjValueMap.containsKey('percent'))
                                        pricingWrapperList.add(new pricingTableWrapper(eachFM.Mode__c,keyAmount,'INR '+String.valueOf(pricingObjValueMap.get('percent'))));
                                    pricingMap.put(eachFM.Mode__c, pricingWrapperList);
                                    
                                    //store count of rows per Module Name
                                    pricingCountMap.put(eachFM.Mode__c, pricingWrapperList.size());
                                }
                            }
                        }
                    }
                    modeList = new List<String>(pricingMap.keySet());
                }
            }
        }
    }
    
    public void detailCompInit(){
        listFeeMaster = New List<Fee_Master__c>();
        listCrossSell = New List<Cross_Sell__c>();
        listPayoutFeeMaster = New List<Fee_Master__c>();
        pricingMap = new Map<String, List<pricingTableWrapper>>();
        pricingCountMap = new Map<String, Integer>();
        modeList = new List<String>();
        regAddress = New Address_Details__c();
    	opAddress = New Address_Details__c();
        set<String> oppIds = New Set<String>();
        optyObj = New Opportunity();
        
        if(assignedCSId != null && assignedCSId !=''){
            listCrossSell = getPayoutCrossSellById(assignedCSId);
            System.debug('listCrossSell2'+listCrossSell);
            if(!listCrossSell.isEmpty() && listCrossSell !=null){
                Set<String> payoutCSIds = New Set<String>();
                for(Cross_Sell__c eachCS : listCrossSell){
                    if(eachCS.Custom_Product__r.Name == 'Payout') payoutCSIds.add(eachCS.Id);
                    if(String.isNotBlank(eachCS.Opportunity__c)) oppIds.add(eachCS.Opportunity__c);
                }
                if(!payoutCSIds.isEmpty() && payoutCSIds != null){
                    listPayoutFeeMaster = getPayoutFeeMaster(payoutCSIds);
                }
                if(!listPayoutFeeMaster.isEmpty()){
                    for(Fee_Master__c eachFM : listPayoutFeeMaster){
                        List<pricingTableWrapper> pricingWrapperList = new List<pricingTableWrapper>();
                        if(String.isNotBlank(eachFM.Pricing_Configurator__c)){
                            Map<String, Object> pricingObjList = (Map<String, Object>)JSON.deserializeUntyped(eachFM.Pricing_Configurator__c);
                            system.debug('####### pricingObjList '+pricingObjList);
                            
                            for(string keyAmount : pricingObjList.keySet()){
                                Map<String, Object> pricingObjValueMap = (Map<String, Object>)pricingObjList.get(keyAmount);
                                if(pricingMap.containsKey(eachFM.Mode__c)){
                                    pricingWrapperList = pricingMap.get(eachFM.Mode__c);
                                    if(pricingObjValueMap.containsKey('percent'))
                                        pricingWrapperList.add(new pricingTableWrapper(eachFM.Mode__c,keyAmount,'INR '+String.valueOf(pricingObjValueMap.get('percent'))));
                                    pricingMap.put(eachFM.Mode__c, pricingWrapperList);
                                    pricingCountMap.put(eachFM.Mode__c, pricingWrapperList.size());
                                }else{
                                    if(pricingObjValueMap.containsKey('percent'))
                                        pricingWrapperList.add(new pricingTableWrapper(eachFM.Mode__c,keyAmount,'INR '+String.valueOf(pricingObjValueMap.get('percent'))));
                                    pricingMap.put(eachFM.Mode__c, pricingWrapperList);
                                    
                                    //store count of rows per Module Name
                                    pricingCountMap.put(eachFM.Mode__c, pricingWrapperList.size());
                                }
                            }
                        }
                    }
                   
                    modeList = new List<String>(pricingMap.keySet());
                }
            }
            
            optyObj = getOpportunity(OppIds);
            
            if(optyObj != null){ 
                for(Address_Details__c addDetail : getAccountAddressDetails(optyObj.AccountId)){
                    if(addDetail.Type__c == 'Registered'){
                        regAddress = addDetail;
                    }
                    if(addDetail.Type__c == 'Operating'){
                        opAddress = addDetail;
                    }
                }
                for(Merchant_Document__c mdocDetail : getAccountMerchantDocDetails(optyObj.AccountId)){
                    if(mdocDetail.Document_Category__r.Name == 'Government Issued Certificate'){
                        merchantDocLink = mdocDetail.URL__c;
                    }
                }
            }
        }
    }
    
    private static List<Fee_Master__c> getFeeMasters(Id feeMasterId){
        return [Select Id, Name, Active__c,
                Amex__c,Credit_Card__c,Debit_Card_RuPay__c,
                Debit_Card_Transaction_less_than_2000__c,
                Debit_Card_Transaction_more_than_2000__c,Net_Banking__c,UPI__c,Wallets__c 
                FROM Fee_Master__c 
                WHERE Id =: feeMasterId AND Active__c = True 
                ORDER BY LastModifiedDate DESC Limit 1];
    }
    
    private static List<Cross_Sell__c> getPayoutCrossSell(Id assignedOppId){
        return [Select Id,Custom_Product__c,Custom_Product__r.Name,Opportunity__c,Nature_of_Payout_intended_to_be_made__c
                ,Beneficiary_and_Merchant_relationship__c 
                From Cross_Sell__c Where Opportunity__c=:assignedOppId];
    }
    
    private static List<Fee_Master__c> getPayoutFeeMaster(Set<String> csIds){
        return [Select Id,Mode__c, Pricing_Configurator__c,Active__c  from Fee_Master__c Where Cross_Sell__c IN: csIds AND Active__c=true];
    }
    
    private static List<Cross_Sell__c> getPayoutCrossSellById(Id assignedCSId){
        return [Select Id,Custom_Product__c,Custom_Product__r.Name,Opportunity__c,Nature_of_Payout_intended_to_be_made__c
                ,Beneficiary_and_Merchant_relationship__c 
                From Cross_Sell__c Where Id=:assignedCSId];
    }
    
    public static List<Address_Details__c> getAccountAddressDetails(Id accountId){
        return[SELECT Id, Name, Address_Line__c, Pincode__c, City__c, State__c, Country__c, Type__c
                FROM Address_Details__c WHERE Active__c=true AND Type__c IN ('Registered', 'Operating') 
               AND Account__c =: accountId];
    }
    
    public static List<Merchant_Document__c> getAccountMerchantDocDetails(Id accountId){
        return[SELECT Id,URL__c,Document_Category__r.Name  from Merchant_Document__c 
               WHERE KYC_Documentable_Type__c IN ('Account','',null) 
                AND Active__c=True 
               AND Account__c =: accountId];
    }
    
    public static opportunity getOpportunity(Set<String> oppId){
        return[Select Id,Website__c,Android_URL__c ,Website_Status__c,iOS_URL__c,Key_Assigned_Manager__c,Integration_Type__c, 
               First_Name__c,AccountId,Last_Name__c,Account.Business_Category__r.Name,Account.Business_Entity__r.Name,Legal_Name_Account__c
               from opportunity where Id IN:oppId];
    }
    
    public class pricingTableWrapper{
        public pricingTableWrapper(string mode,string range,string amount){
            this.mode = mode;
            this.priceRange = range;
            this.amount = amount;
        }
        
        public String mode {get;set;}
        public String priceRange {get;set;}
        public String amount {get;set;}
    }

}