/*	
Name : ProductInterestController
Author : Kunal Raj
Date : 27th March 2023
*/
public class ProductInterestController {
    
    /**** Method to pull the Merchant Product Interest's data related to the Opportunity for Platform "Core Payments"***/
    
    @AuraEnabled(cacheable=true)
    public static List<Merchant_Product_Interest__c> getRelatedProductInterest(List<Id> oppId){
        return [SELECT Id, Active_Status__c, toLabel(Active__c), Insights__c, Risk_Eligibility_Flag__c, Merchant_Interest_Flag__c, Merchant_Interest_Reason__c, Product_Bundle_Detail__r.Platform_Id__c , Product_Bundle_Detail__r.MPA_Platform_ID__c, Product_Bundle_Detail__r.Sales_Bundle__r.Name, Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
        FROM Merchant_Product_Interest__c 
        WHERE MID__c IN: oppId AND Active__c != '2' AND Platform__c = 'Core Payments' ORDER BY Product_Bundle_Detail__r.Sales_Bundle__r.Name ASC];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Merchant_Product_Interest__c> getActiveProductInterest(List<Id> oppId){
        List<Merchant_Product_Interest__c> merchantList = new List<Merchant_Product_Interest__c>();
        List<String> listName = new List<String>();
        for(AggregateResult agr : [SELECT SUM(GMV_Lifetime__c) sum,Product_Bundle_Detail__r.Sales_Bundle__r.Name name
                                FROM Merchant_Product_Interest__c WHERE MID__c IN: oppId AND Active__c IN('1', '2')  AND Platform__c = 'Core Payments'
                                GROUP BY Product_Bundle_Detail__r.Sales_Bundle__r.Name ORDER BY SUM(GMV_Lifetime__c) DESC]) {
                               listName.add((String)agr.get('name')); 
                           }
 
        Map<String,List<Merchant_Product_Interest__c>> mapNameToRecords = new Map<String,List<Merchant_Product_Interest__c>>();
        for(Merchant_Product_Interest__c obj : [SELECT Active_Status__c, Active__c, GMV_Lifetime__c, GMV_Last_month__c, GMV_Last_3_months__c,
                                         GMV_Last_6_months__c, GMV_Last_12_months__c, Activation_Date__c, Insights__c, Transacting__c, Product_Bundle_Detail__r.Platform_Id__c , Product_Bundle_Detail__r.MPA_Platform_ID__c, Product_Bundle_Detail__r.Sales_Bundle__r.Name, Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name,Merchant_Interest_Flag__c
                                        FROM Merchant_Product_Interest__c 
                                        WHERE  MID__c IN: oppId AND Active__c IN('1', '2')  AND Platform__c = 'Core Payments' AND Product_Bundle_Detail__r.Sales_Bundle__r.Name  IN :listName 
                                        ORDER BY GMV_Lifetime__c DESC]) {
                                            List<Merchant_Product_Interest__c> listRecords = new List<Merchant_Product_Interest__c>();
                                            if(mapNameToRecords.containsKey(obj.Product_Bundle_Detail__r.Sales_Bundle__r.Name)) {
                                                listRecords = mapNameToRecords.get(obj.Product_Bundle_Detail__r.Sales_Bundle__r.Name);	
                                            }	
                                            listRecords.add(obj);
                                            mapNameToRecords.put(obj.Product_Bundle_Detail__r.Sales_Bundle__r.Name,listRecords); 
                                        }
 
            for(String name : listName) {
                for(Merchant_Product_Interest__c obj : mapNameToRecords.get(name)) {
                    merchantList.add(obj);
                }
            }
            return merchantList;
    }
    
    /**** END**********"Core Payments" Product Interest***/
    
    /**** Method to pull the Merchant Product Interest's data related to the Opportunity for Platform "Payment Stack"***/
    
    @AuraEnabled(cacheable=true)
    public static List<Merchant_Product_Interest__c> getRelatedProductInterestForStack(List<Id> oppId){
        return [SELECT Id, Active_Status__c, toLabel(Active__c), Insights__c, Risk_Eligibility_Flag__c, Merchant_Interest_Flag__c, Merchant_Interest_Reason__c, Product_Bundle_Detail__r.Platform_Id__c , Product_Bundle_Detail__r.MPA_Platform_ID__c, Product_Bundle_Detail__r.Sales_Bundle__r.Name, Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
        FROM Merchant_Product_Interest__c 
        WHERE MID__c IN: oppId AND Active__c != '2' AND Platform__c = 'Payment Stack' ORDER BY Product_Bundle_Detail__r.Sales_Bundle__r.Name DESC];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Merchant_Product_Interest__c> getActiveProductInterestForStack(List<Id> oppId){
        return [SELECT Id, Active_Status__c, Active__c, GMV_Lifetime__c, GMV_Last_month__c, GMV_Last_3_months__c, GMV_Last_6_months__c, GMV_Last_12_months__c, Activation_Date__c, Insights__c, Transacting__c, Product_Bundle_Detail__r.Platform_Id__c , Product_Bundle_Detail__r.MPA_Platform_ID__c, Product_Bundle_Detail__r.Sales_Bundle__r.Name, Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name,Merchant_Interest_Flag__c
        FROM Merchant_Product_Interest__c
        WHERE MID__c IN: oppId AND Active__c IN('1', '2')  AND Platform__c = 'Payment Stack'];
    }
    
    /**** END**********"Payment Stack" Product Interest***/
    
    /*************************Fetching Fields from Opportunity**************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Opportunity > getOppGMVFields(List<Id> oppId){
        return [SELECT Id, GMV_Latest_Date__c, GMV_Lifetime__c, Last_12_months_GMV__c, Last_3_months_GMV__c, Last_6_months_GMV__c, YTD_GMV__c, MTD_GMV__c 
                FROM Opportunity   
                WHERE Id IN: oppId LIMIT 1];
    }
    /*******************************************************************************************************************/
    
    @AuraEnabled
    public static void updateProductInterest(String prodInterest){
        Merchant_Product_Interest__c productInterestNew = (Merchant_Product_Interest__c) JSON.deserialize(prodInterest, Merchant_Product_Interest__c.class);
        update productInterestNew;
    }
    /** Added for getting the active instrument */
    @AuraEnabled(cacheable=true)
    public static List<ActiveInstrumentWrapper> getActiveInstrumentBundle(String prodIntId){
        List<Map<String,String>> JSONData = new List<Map<String,String>>();
        System.debug('>>>>>prodIntId>>>>'+prodIntId);
        String activeSFIDs = '';
        String bundleId = '';
        
        Map<String,ActiveInstrumentWrapper> wrapperMap = new Map<String,ActiveInstrumentWrapper>();
        List<Merchant_Product_Interest__c> prodIntList = [SELECT Id,Product_Bundle_Detail__c,Active_SF_IDs__c,Sales_Bundle__c,Sub_Sales_Bundle__c FROM Merchant_Product_Interest__c WHERE Id = :prodIntId LIMIT 1];
        if(!prodIntList.isEmpty()){
            activeSFIDs = prodIntList[0].Active_SF_IDs__c != NULL ? prodIntList[0].Active_SF_IDs__c : '';
            bundleId = prodIntList[0].Product_Bundle_Detail__c != NULL ? prodIntList[0].Product_Bundle_Detail__c  : '';
            
            JSONData = getJSONData(activeSFIDs);
            
            if(!JSONData.isEmpty()){
                
                Map<String,Master_Pricing_Data__c> masterPricingMap = new Map<String,Master_Pricing_Data__c>();
                
                
                for(Map<String,String> dataMap : JSONData){
                    ActiveInstrumentWrapper wrap = new ActiveInstrumentWrapper();
                    wrap.lifetime_GMV = dataMap.get('lifetime_GMV');
                    wrap.lastMonth_GMV = dataMap.get('lastMonth_GMV');
                    wrap.last3Month_GMV = dataMap.get('last3Month_GMV');
                    wrap.last6Month_GMV = dataMap.get('last6Month_GMV');
                    wrap.last12Month_GMV = dataMap.get('last12Month_GMV');
                    wrap.activation_Date = dataMap.get('activation_Date');
                    /*********Below both if condition added by rohit */
                    if(dataMap.get('transacting')=='0'){
                        wrap.transacting = 'false';
                    }
                    if(dataMap.get('transacting')=='1'){
                        wrap.transacting = 'true';
                    }
                    /**********End */
                  
                    wrapperMap.put(dataMap.get('instrumentId'), wrap);
                }
                
                if(!wrapperMap.keySet().isEmpty()){ //
                    for(Master_Pricing_Data__c masterPricing : [SELECT Id,Salesforce_Primary_Key__c,Payment_Option__r.Name,Pricing_Specification__r.Name,
                                                                Payment_Gateway__r.Name,ONUS_OFFUS__c 
                                                                FROM Master_Pricing_Data__c 
                                                                WHERE Salesforce_Primary_Key__c  IN :wrapperMap.keySet()
                                                                AND Product_Bundle_Detail__c = :bundleId]){ // 
                        
                        if(wrapperMap.containsKey(masterPricing.Salesforce_Primary_Key__c)){
                            ActiveInstrumentWrapper tempWrap = wrapperMap.get(masterPricing.Salesforce_Primary_Key__c);
                            tempWrap.master_PR = masterPricing;
                            wrapperMap.put(masterPricing.Salesforce_Primary_Key__c, tempWrap);
                        }
                    }
                    if(!wrapperMap.values().isEmpty()){
                        return wrapperMap.values();
                    }
                }
                
            }
        } 
        
        return NULL;
        
    }

    /** Added for getting the Inactive instrument */
    @AuraEnabled(cacheable=true)
    public static List<InActiveInstrumentWrapper> getInActiveInstrumentBundle(String prodIntId){
        List<Map<String,String>> JSONData = new List<Map<String,String>>();
        System.debug('>>>>>prodIntId>>>>'+prodIntId);
        String InActiveSFIDs = '';
        String bundleId = '';
        
        Map<String,InActiveInstrumentWrapper> wrapperMap = new Map<String,InActiveInstrumentWrapper>();
        List<Merchant_Product_Interest__c> prodIntList = [SELECT Id,Product_Bundle_Detail__c,Active_SF_IDs__c,
                                                            Risk_Eligibility_Flag__c,Merchant_Interest_Flag__c,Non_Active_SF_IDs__c
                                                         FROM Merchant_Product_Interest__c WHERE Id = :prodIntId LIMIT 1];
        if(!prodIntList.isEmpty()){
            InActiveSFIDs = prodIntList[0].Non_Active_SF_IDs__c != NULL ? prodIntList[0].Non_Active_SF_IDs__c : '';
            bundleId = prodIntList[0].Product_Bundle_Detail__c != NULL ? prodIntList[0].Product_Bundle_Detail__c  : '';

            JSONData = getJSONDataForInactive(InActiveSFIDs);

            if(!JSONData.isEmpty()){
                
                Map<String,Master_Pricing_Data__c> masterPricingMap = new Map<String,Master_Pricing_Data__c>();
                
                
                for(Map<String,String> dataMap : JSONData){
                    InActiveInstrumentWrapper wrap = new InActiveInstrumentWrapper();
                    wrap.prodInt = prodIntList[0];
                    wrapperMap.put(dataMap.get('instrumentId'), wrap);
                }
                
                if(!wrapperMap.keySet().isEmpty()){ //
                    for(Master_Pricing_Data__c masterPricing : [SELECT Id,Salesforce_Primary_Key__c,Payment_Option__r.Name,Pricing_Specification__r.Name,
                                                                Payment_Gateway__r.Name,ONUS_OFFUS__c 
                                                                FROM Master_Pricing_Data__c 
                                                                WHERE Salesforce_Primary_Key__c  IN :wrapperMap.keySet()
                                                                AND Product_Bundle_Detail__c = :bundleId]){ // 
                        
                        if(wrapperMap.containsKey(masterPricing.Salesforce_Primary_Key__c)){
                            InActiveInstrumentWrapper tempWrap = wrapperMap.get(masterPricing.Salesforce_Primary_Key__c);
                            tempWrap.master_PR = masterPricing;
                            wrapperMap.put(masterPricing.Salesforce_Primary_Key__c, tempWrap);
                        }
                    }
                    if(!wrapperMap.values().isEmpty()){
                        return wrapperMap.values();
                    }
                }
                
            }
        }
        return NULL;
    }

    
    public static List<Map<String,String>> getJSONData(String sfId){
        String input = sfId;
        List<Map<String,String>> mapList = new List<Map<String,String>>();
        Map<Integer,String> fieldIndexMap = new Map<Integer,String>{0=>'instrumentId',1=>'lifetime_GMV',2=>'last12Month_GMV',3=>'last6Month_GMV',4=>'last3Month_GMV',5=>'lastMonth_GMV',6=>'lastFY_GMV',7=>'activation_Date',8=>'transacting',9=>'insights'};
        List<String> items = input.split(',');
        for(String str : items){
            System.debug('>>>str>>>'+str);
            str = str.substringBetween('{','}');
            List<String> dataList = str.split('::');
            Map<String,String> dataMap = new map<String,String>();
            for(Integer i=0;i<dataList.size();i++){
                dataMap.put(fieldIndexMap.get(i),dataList[i]);
            }
            System.debug('dataMap>>>>>'+dataMap);
            mapList.add(dataMap);
            
            
        }
        return mapList;
        
    }

    public static List<Map<String,String>> getJSONDataForInactive(String sfId){
        String input = sfId;
        List<Map<String,String>> mapList = new List<Map<String,String>>();
        Map<Integer,String> fieldIndexMap = new Map<Integer,String>{0=>'instrumentId',1=>'insights'};
        List<String> items = input.split(',');
        for(String str : items){
            System.debug('>>>str>>>'+str);
            str = str.substringBetween('{','}');
            List<String> dataList = str.split('::');
            Map<String,String> dataMap = new map<String,String>();
            for(Integer i=0;i<dataList.size();i++){
                dataMap.put(fieldIndexMap.get(i),dataList[i]);
            }
            System.debug('dataMap>>>>>'+dataMap);
            mapList.add(dataMap);
            
            
        }
        return mapList;
        
    }

    /* public class InstrumentWrapper{
        @AuraEnabled 
        public ActiveInstrumentWrapper activeIns;
        @AuraEnabled 
        public ActiveInstrumentWrapper inActiveIns;
    } */
    
    @AuraEnabled(cacheable=true)
    public static List<Merchant_Product_Interest__c> getInterestFields(String prodIntId){
        return [SELECT Id, Sales_Bundle__c,Sub_Sales_Bundle__c FROM Merchant_Product_Interest__c WHERE Id = :prodIntId LIMIT 1];
    }
    
    public class ActiveInstrumentWrapper{
        @AuraEnabled 
        public Master_Pricing_Data__c master_PR = new Master_Pricing_Data__c();
        @AuraEnabled 
        public String lifetime_GMV = '';
        @AuraEnabled 
        public String last12Month_GMV = '';
        @AuraEnabled 
        public String last6Month_GMV = '';
        @AuraEnabled 
        public String last3Month_GMV = '';
        @AuraEnabled 
        public String lastMonth_GMV = '';
        @AuraEnabled 
        public String activation_Date = '';
        @AuraEnabled 
        public String transacting = '';
    }
    public class InActiveInstrumentWrapper{
        @AuraEnabled 
        public Master_Pricing_Data__c master_PR = new Master_Pricing_Data__c();
        @AuraEnabled 
        public Merchant_Product_Interest__c prodInt = new Merchant_Product_Interest__c();
        
        
    }
    
    
    
    
    /*
    @AuraEnabled(cacheable=true)
    public static user getUserInfo() {
        String userId = UserInfo.getUserId(); // current user
        return [SELECT ID, FirstName, LastName, Name, Title, Profile.Name,  Email From User WHERE ID =: userId LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Merchant_Product_Interest__c> getLeadProductInterest(List<Id> leadId){
        Lead midLead = [SELECT Prod_Merchant_Id__c FROM Lead WHERE Id IN: leadId LIMIT 1];
        Decimal mid = midLead.Prod_Merchant_Id__c;
        //Integer midLead = [SELECT Prod_Merchant_Id__c FROM Lead WHERE Id IN: leadId]; 
        return [SELECT Id, Active_Status__c, toLabel(Active__c), Insights__c, Risk_Eligibility_Flag__c, Merchant_Interest_Flag__c, Merchant_Interest_Reason__c, Product_Bundle_Detail__r.Platform_Id__c , Product_Bundle_Detail__r.MPA_Platform_ID__c, Product_Bundle_Detail__r.Sales_Bundle__r.Name, Product_Bundle_Detail__r.Sub_Sales_Bundle__r.Name
        FROM Merchant_Product_Interest__c 
        WHERE MID__r.Prod_Merchant_Id__c = :mid AND Active__c != '2' ORDER BY Product_Bundle_Detail__r.Sales_Bundle__r.Name DESC];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Lead_Product_Interest__c> getProductInterests(Id leadId) {
        return [SELECT Checkbox_1__c, Checkbox_2__c, Checkbox_3__c, Picklist_1__c, Picklist_2__c, Picklist_3__c 
        FROM Lead_Product_Interest__c
        WHERE Lead__c = :leadId];
    }
    
    @AuraEnabled
    public static void updateProductInterest_2(List<Lead_Product_Interest__c> productInterestsToUpdate){
        update productInterestsToUpdate;
    }
    */
    
    
}