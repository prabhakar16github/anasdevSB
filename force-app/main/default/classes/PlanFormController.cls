public class PlanFormController{
    
    public static List<String> poFieldList = new List<String>{'Name', 'Active__c', 'Authorize_Channel__c', 'Identifier__c', 'Mode__c', 'Payment_Instrument__c', 'PaymentOptionHeader__c', 'Sponsor__c'}; 
    public static List<String> pgFieldList = new List<String>{'Serve_International__c', 'Name', 'Active__c', 'Identifier__c', 'Provider__c', 'Route__c'};
    public static List<String> planPricingPOList = new List<String>{'Active__c', 'Payment_Gateway__c', 'Payment_Gateway__r.Name','Payment_Gateway__r.Provider__c','Payment_Gateway__r.Route__c'};
    public static List<String> planFieldsList = new List<String>{'Business_Category_2__c','Business_Category_2__r.Name','Department__c','Category_Groups__c', 'Default__c', 'IdentifierUI__c', 'PartnerSetupFeeIns__c', 'Merchant_Category__c', 'GMV_Threshold__c', 'One_time_Bonus__c', 'Name', 'Active__c', 'AMC__c', 'Business_Category__c', 'Deposit_Fee__c', 'Description__c', 'Identifier__c', 'Offered_By__c', 'Plan_For__c', 'Pricing_Type__c', 'Product__c', 'Settlement_Cycle__c', 'Settlement_Type__c', 'Setup_Fee__c', 'Type__c'};
    public static List<String> planPricingList = new List<String>{'Category_Group__c', 'Bearer_Split__c', 'Settlement_Type__c', 'Active__c', 'Authorize_Channel__c', 'Card_Classification__c', 'Identifier__c', 'MDR__c', 'Mode__c', 'Routing_Type__c', 'Payment_Gateway__c', 'Payment_Gateway__r.Name', 'Payment_Instrument__c', 'Sponsor__c', 'TSF__c','Payment_Gateway__r.Provider__c','Payment_Gateway__r.Route__c'};
    
    @auraEnabled    
    public static InitData getPaymentOptionData(String planId){
        InitData theData = new InitData();
        theData.planTypesPickList = PicklistGenerator.getPicklistValues('Plan__c', 'Type__c', '', false);
        theData.routingTypes = PicklistGenerator.getPicklistValues('Plan_Pricing__c', 'Routing_Type__c', '', false);
        theData.planForPickList = PicklistGenerator.getPicklistValues('Plan__c', 'Plan_For__c', '', false);        
        theData.offeredByPickList = PicklistGenerator.getPicklistValues('Plan__c', 'Offered_by__c', '', false); 
        theData.settCycles = PicklistGenerator.getPicklistValues('Plan__c', 'Settlement_Cycle__c', '', false);  
        theData.merchantCategs = PicklistGenerator.getPicklistValues('Plan__c', 'Merchant_Category__c', '', false);                    
        theData.cardClassPickList = PicklistGenerator.getPicklistValues('Plan_Pricing__c', 'Card_Classification__c', '', false);               
        theData.productsList = PicklistGenerator.getSobjectRecords('SELECT Id, Name FROM Product__c WHERE Active__c = true', '', false, 'Name');
        theData.paymentOptionData = getPOData(planId);        
        
        if(String.isNotBlank(planId)){
            theData.thePlan = getPlanData(planId);            
        }        
        theData.businessCategs = Database.query('SELECT Id, Name,Category_Group__c, Categories_For__c FROM Business_Category__c WHERE Active__c = true'); 
        //theData.categoryPickList = PicklistGenerator.getSobjectRecords('SELECT Id, Name FROM Business_Category__c WHERE Active__c = true', '', true, 'Name'); 
        return theData;
    }
    
    @auraEnabled    
    public static Plan__c getPlanData(String planId){
        String queryStr = 'SELECT Id, ' + String.join(planFieldsList, ', ') + ', ';
        
        queryStr += '(SELECT Id, ';
        queryStr += String.join(planPricingList, ', ');
        queryStr += ' FROM Plan_Pricings__r)';
        queryStr += ' FROM Plan__c WHERE Id =\'' + planId + '\'';        
        return Database.query(queryStr);
    }
    
    @auraEnabled    
    public static List<Payment_Option__c> getPOData(String planId){ 
        String queryStr = 'SELECT Id, ' + String.join(poFieldList, ', ') + ', ';
        
        queryStr += '(SELECT Id, Payment_Gateway__c, ';
        queryStr += 'Payment_Gateway__r.' + String.join(pgFieldList, ', Payment_Gateway__r.');
         //queryStr += ', Payment_Option__r.' + String.join(poFieldList, ', Payment_Option__r.');
        queryStr += ' FROM PO_PG_Mappings__r)';
        
        if(String.isNotBlank(planId)){
            queryStr += ', (SELECT Id, '+ String.join(planPricingPOList, ', ');
            queryStr += ' FROM Pricing_Payment_Options__r WHERE Plan__c =\'' + planId + '\')';
        }
        
        queryStr += ' FROM Payment_Option__c';        
        return Database.query(queryStr);
    }
    
    @auraEnabled    
    public static Id insertPlanAndPricing(Plan__c thePlan, List<String> ppoToDelete, List<Plan_Pricing__c> pricingToDelete, List<PricingPaymentOption__c> paypentOptionsToInsert, List<PricingPaymentOption__c> paypentOptionsToUpdate, List<Plan_Pricing__c> pricingToInsert, List<Plan_Pricing__c> pricingToUpdate){
        upsert thePlan;
        
        if(!paypentOptionsToInsert.isEmpty()){
            
            for(PricingPaymentOption__c each : paypentOptionsToInsert){
                each.Plan__c = thePlan.Id;
            }
            
            insert paypentOptionsToInsert;
        }
        
        if(!ppoToDelete.isEmpty()){
            delete [SELECT Id FROM PricingPaymentOption__c WHERE Id IN: ppoToDelete];
        }
        
        if(!pricingToDelete.isEmpty()){
            delete pricingToDelete;
        }
        
        if(!pricingToInsert.isEmpty()){                        
            
            for(Plan_Pricing__c each : pricingToInsert){
                each.Plan__c = thePlan.Id;
            }
            
            insert pricingToInsert;
        }
        
        if(!paypentOptionsToUpdate.isEmpty()){
            
            for(PricingPaymentOption__c each : paypentOptionsToUpdate){                
                each.Plan__c = thePlan.Id;
            }
            
            update paypentOptionsToUpdate;
        }
        
        if(!pricingToUpdate.isEmpty()){                        
            
            for(Plan_Pricing__c each : pricingToUpdate){            
                each.Plan__c = thePlan.Id;
            }
            
            update pricingToUpdate;
        }
                        
        return thePlan.Id;
    }
    
    public class InitData{
        @auraEnabled
        public String planTypesPickList;
        @auraEnabled
        public String settCycles;            
        @auraEnabled
        public String routingTypes;
        @auraEnabled
        public String merchantCategs;
        @auraEnabled      
        public String planForPickList;  
        @auraEnabled      
        public String offeredByPickList;
        @auraEnabled      
        public String categoryPickList; 
        @auraEnabled      
        public String cardClassPickList;  
        @auraEnabled
        public String productsList;
        @auraEnabled
        public List<Payment_Option__c> paymentOptionData;
        @auraEnabled
        public List<Business_Category__c> businessCategs;
        @auraEnabled
        public Plan__c thePlan;  
    }
    
}