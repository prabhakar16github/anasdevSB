public class TDRScreenController{
    
    public static List<String> commercialFields = new List<String>{'Offered_By__c', 'IdentifierUI__c', 'Name', 'Plan__r.Name', 'Plan__r.Id', 'Plan__r.Type__c', 'Active__c', 'AMC__c', 'Deposit_Fee__c', 'Identifier__c', 'Old_Settlement_Cycle__c', 'Old_Settlement_Type__c', 'Opportunity__c', 'Plan__c', 'Settlement_Cycle__c', 'Settlement_Days_Approval_Status__c', 'Settlement_Type__c', 'Settlement_Type_Approval_Status__c', 'Setup_Fee__c', 'Type__c','Pricing_Approval_Status__c'};    
    public static List<String> planPricingFields = new List<String>{'Card_Classification__c', 'Active__c', 'Identifier__c', 'MDR__c', 'TSF__c', 'Sponsor__c', 'Plan__c', 'Payment_Option__c', 'Payment_Gateway__c', 'Routing_Type__c', 'Mode__c'};
    public static List<String> planPricingPOFields = new List<String>{'Active__c', 'Payment_Gateway__c'};
    public static List<String> merchantPricingPOFields = new List<String>{'Enable_International__c', 'Active__c', 'Payment_Gateway__c'};
    public static List<String> tdrFields = new List<String>{'Category_Group__c', 'Commercial__r.Plan__c', 'Active__c', 'Authorize_Channel__c', 'Bearer_Split__c', 'Card_Classification__c', 'Commercial__c', 'GMV_Rate_Override__c', 'Identifier__c', 'MDR__c', 'Mode__c', 'Routing_Type__c', 'Opportunity__c', 'Payment_Gateway__c', 'Payment_Instrument__c', 'Settlement_Type_Override__c', 'Sponsor__c', 'TSF__c'};        
    public static List<String> mcpDetailFields = new List<String>{'Markup_Rate__c', 'Settlement_Currency__c', 'Transaction_Currency__c'};
    public static List<String> pricingTypes = new List<String>{'Bank Rate', 'Rack Rate'};
    public static List<String> paymentsFields = new List<String>{'Remaining_Amount__c', 'Active__c', 'Standard_Amount__c', 'Amount1__c', 'Charges_Type__c', 'Due_Amount__c', 'Effective_Year__c', 'Occurance__c', 'Received_Amount__c', 'Recurring_Period__c', 'Renewal_Date__c', 'Start_Date__c', 'Waiver_Amount__c', 'Waiver_Period_In_Years__c', 'Waiver_Period_End_Date__c'};
    public static List<String> paymentDetailFields = new List<String>{'Amount__c', 'Auth_Code__c', 'Card_Number__c', 'Payment_Mode__c', 'Transaction_Date__c', 'Transaction_Id__c', 'Transaction_Reference_Number__c'};
        
    @auraEnabled
    public static TheInitData getCommercials(String oppId){
        TheInitData theData = new TheInitData();
        
        theData.mdrTSFMasterData = getMdrTSFMasterData();
        theData.commercialData = getCommercialRecords(oppId, false, '');
        theData.partners = getPartners();
        theData.routingTypes = PicklistGenerator.getPicklistValues('Plan_Pricing__c', 'Routing_Type__c', '', false);
        theData.cardClassPickList = PicklistGenerator.getPicklistValues('Plan_Pricing__c', 'Card_Classification__c', '', false);                     
        return theData;      
    }
    
    @auraEnabled
    public static List<Commercial__c> getCommercialRecords(String oppId, Boolean getPayments, String commercialId){
        String queryStr = 'SELECT Id, ' + String.join(commercialFields, ', ');
        if(getPayments) queryStr += ', (SELECT Id, ' + String.join(paymentsFields, ', ') + ' FROM Payments__r ORDER BY CreatedDate DESC)';
        queryStr += ' FROM Commercial__c WHERE Opportunity__c=\'' + oppId + '\''; 
        if(String.isNotBlank(commercialId)) queryStr += ' AND Id = \'' + commercialId + '\'';
        return Database.query(queryStr);   
    }
    
    
    @auraEnabled
    public static TheInitData getRequiredData(String commercialId, String planId, String planType, String oppId, Boolean mdrTsfMasterExists){    
        TheInitData theData = new TheInitData();
        theData.planTypes = PicklistGenerator.getPicklistValues('Plan__c', 'Type__c', planType, false);                   
        theData.settlementDays = PicklistGenerator.getPicklistValues('Commercial__c', 'Settlement_Cycle__c', '', false);
        theData.types = PicklistGenerator.getPicklistValues('Commercial__c', 'Type__c', '', false); 
        theData.plans = getPlans(planType, planId, oppId);
        theData.commercialData = getMPOData(oppId, planId);
        theData.tdrData = getTdrList(commercialId, planId);        
        theData.planPricingData = getPlanPricingList(planId); 
        if(!mdrTsfMasterExists) theData.mdrTSFMasterData = getMdrTSFMasterData(); 
        theData.theCommercial = getCommercial(commercialId); 
        theData.theRackRatePlan = getRackRatePlans('rack_rate',oppId);
        return theData;
    }
    
    public static List<Sobject> getPlanPricingList(String planId){
        String queryStr = 'SELECT Id, ' + String.join(PlanFormController.planPricingList, ', ');
        queryStr += ' FROM Plan_Pricing__c WHERE Active__c = true';        
        if(String.isNotBlank(planId)) queryStr += ' AND Plan__c = \'' + planId + '\'';       
        return Database.query(queryStr);       
    }
    
    public static List<Sobject> getTdrList(String commercialId, String planId){
        String queryStr = 'SELECT Id, ' + String.join(tdrFields, ', ');
        queryStr += ', Payment_Gateway__r.' + String.join(PlanFormController.pgFieldList, ', Payment_Gateway__r.');
        //queryStr += ', Payment_Option__r.' + String.join(PlanFormController.poFieldList, ', Payment_Option__r.');
        queryStr += ' FROM TDR__c';
        
        if(String.isNotBlank(commercialId)){
            queryStr += ' WHERE Commercial__c = \'' + commercialId + '\'';
            if(String.isNotBlank(planId)) queryStr += ' AND ';
        }
        if(String.isNotBlank(planId)){
            if(String.isBlank(commercialId)) queryStr += ' WHERE';
            queryStr += ' Commercial__r.Plan__c = \'' + planId + '\''; 
        }      
        return Database.query(queryStr);       
    }
    
    @auraEnabled
    public static List<Sobject> getPartners(){
        String queryStr = 'SELECT Id, Name, Identifier__c FROM Opportunity WHERE RecordType.DeveloperName = \'Reseller\'';
        return Database.query(queryStr);                 
    }
    
    @auraEnabled
    public static String getPlans(String planType, String planId, String oppId){
        String queryStr = 'SELECT Id, Name FROM Plan__c WHERE Active__c = true AND Type__c =\'' + planType + '\'';
        queryStr += ' AND Product__c != null AND Product__c IN (SELECT Product__c FROM Opportunity WHERE Id = \'' + oppId + '\')';        
        return PicklistGenerator.getSobjectRecords(queryStr, planId, false, 'Name');                         
    }
    
    @auraEnabled
    public static List<sObject> getRackRatePlans(String planType,String oppId){
        Set<String> businessCategoryIds = New Set<String>();
        if(String.isNotBlank(oppId)){
            for(Opportunity eachOpp : [SELECT BusinessCategory__c FROM Opportunity WHERE Id =: oppId]){
                if(String.isNotBlank(eachOpp.BusinessCategory__c)) businessCategoryIds.add(eachOpp.BusinessCategory__c);
            }
        }
        String queryStr = 'SELECT Id, ' + String.join(PlanFormController.planPricingList, ', ');
        queryStr += ' FROM Plan_Pricing__c WHERE Active__c = true';        
        if(String.isNotBlank(planType)) queryStr += ' AND Plan__r.Type__c =\'' + planType + '\'';         
        if(!businessCategoryIds.isEmpty()) queryStr += ' AND Plan__r.Business_Category_2__c IN (\'' + String.join(new List<String>(businessCategoryIds), '\' , \'') + '\')'; 
        return Database.query(queryStr);                         
               
    }
    
    @auraEnabled
    public static void deleteTDRList(List<Sobject> tdrToDelete){
        delete tdrToDelete;
    }
    
    public static Set<String> pastPlans(String oppId){
        Set<String> planIds = new Set<String>();
        for(Commercial__c each : [SELECT Plan__c FROM Commercial__c WHERE Opportunity__c =: oppId AND Plan__c != null]){
            planIds.add(each.Plan__c);
        }        
        return planIds;
    }            
        
    @auraEnabled
    public static List<Sobject> getMPOData(String oppId, String planId){
        
        Set<String> poIds = new Set<String>();
        
        for(PricingPaymentOption__c each : [SELECT Payment_Option__c FROM PricingPaymentOption__c WHERE Plan__c =: planId]){
            poIds.add(each.Payment_Option__c);
        }
        
        for(MerchantPaymentOption__c each : [SELECT Payment_Option__c FROM MerchantPaymentOption__c WHERE Opportunity__c =: oppId]){
            poIds.add(each.Payment_Option__c);
        }
        
        Set<String> planIds = pastPlans(oppId);
        planIds.add(planId);
        
        String queryStr = 'SELECT Id, ' + String.join(PlanFormController.poFieldList, ', ') + ', ';
        
        queryStr += '(SELECT Id, ' + String.join(planPricingPOFields, ', ');
        queryStr += ', Payment_Gateway__r.' + String.join(PlanFormController.pgFieldList, ', Payment_Gateway__r.');
        //queryStr += ', Payment_Option__r.' + String.join(PlanFormController.poFieldList, ', Payment_Option__r.');
        queryStr += ' FROM PO_PG_Mappings__r)';        
        
        if(String.isNotBlank(oppId)){
            queryStr += ', (SELECT Id, '+ String.join(merchantPricingPOFields, ', ');
            queryStr += ', Payment_Gateway__r.' + String.join(PlanFormController.pgFieldList, ', Payment_Gateway__r.');
			//queryStr += ', Payment_Option__r.' + String.join(PlanFormController.poFieldList, ', Payment_Option__r.');            
            queryStr += ' FROM Merchant_Payment_Options__r WHERE ' + 'Opportunity__c =\'' + oppId + '\')';
        }
        
        if(String.isNotBlank(planId)){
            queryStr += ', (SELECT Id, '+ String.join(planPricingPOFields, ', ');
            queryStr += ', Payment_Gateway__r.' + String.join(PlanFormController.pgFieldList, ', Payment_Gateway__r.');
			//queryStr += ', Payment_Option__r.' + String.join(PlanFormController.poFieldList, ', Payment_Option__r.');            
            queryStr += ' FROM Pricing_Payment_Options__r WHERE ' + 'Plan__c =\'' + planId + '\')';
        }
        
        queryStr += ' FROM Payment_Option__c';        
        
        return Database.query(queryStr);       
        
    }
            
    public static string joinfilterIds(Set<String> poIds){
        return '(\'' + String.join(new List<String>(poIds), '\', \'') + '\')';
    }
    
    @auraEnabled
    public static List<Sobject> getMdrTSFMasterData(){
        String queryStr = 'SELECT Id, ' + String.join(PlanFormController.planFieldsList, ', ');        
        queryStr += ', (SELECT Id, '+ String.join(PlanFormController.planPricingList, ', ') + ' FROM Plan_Pricings__r WHERE Active__c = true)';
        queryStr += ' FROM Plan__c WHERE Pricing_Type__c IN (\'' + String.join(pricingTypes, '\' , \'') + '\')';      
        return Database.query(queryStr);   
    }
    
    @auraEnabled
    public static TheInitData getMcpData(String oppId){        
        TheInitData theData = new TheInitData();                
        theData.mcpList = queryMcpData(oppId);        
        theData.currencies = PicklistGenerator.getPicklistValues('MCP_Detail__c', 'Settlement_Currency__c', '', false);         
        return theData;
    } 
        
    public static List<Sobject> queryMcpData(String oppId){
        String queryStr = 'SELECT Id, Settlement_Currency__c, '; 
        queryStr += '(SELECT Id, ' + String.join(mcpDetailFields, ', ') + ' FROM MCP_Details__r)';
        queryStr += ' FROM Opportunity WHERE Id =\'' + oppId + '\'';            
        return Database.query(queryStr);
    }
    
    @auraEnabled
    public static TheInitData getCreateCommData(String oppId){
        TheInitData theData = new TheInitData();
        theData.planTypes = PicklistGenerator.getPicklistValues('Plan__c', 'Type__c', '', false);            
        theData.types = PicklistGenerator.getPicklistValues('Commercial__c', 'Type__c', '', false); 
        theData.plans = getPlans('merchant_plan', '', oppId); 
        theData.settlementDays = PicklistGenerator.getPicklistValues('Commercial__c', 'Settlement_Cycle__c', '', false);
        return theData;   
    }
    
    @auraEnabled
    public static TheInitData getNewTDRData(String planId, Boolean mdrTsfMasterExists, String commercialId, String oppId){
        TheInitData theData = new TheInitData();                   
        theData.commercialData = getMPOData(oppId, planId);
        // ===== Updated for JIRA==========
        theData.selectedPlancommercialData = getSelectedPlanMPOData(oppId,planId);
        
        if(String.isNotBlank(commercialId)) theData.tdrData = getTdrList(commercialId, planId);
        theData.planPricingData = getPlanPricingList(planId); 
        theData.thePlan = getPlan(planId);
        if(!mdrTsfMasterExists) theData.mdrTSFMasterData = getMdrTSFMasterData();
        theData.theRackRatePlan = getRackRatePlans('rack_rate',oppId);
        return theData;   
    }
    
    @auraEnabled
    public static void deleteCommercial(Commercial__c theCommercial){
        delete theCommercial;
    }
    
    @auraEnabled
    public static void upsertMcpData(List<Sobject> mcpInsertData, List<Sobject> mcpUpdateData, List<Sobject> mcpDeleteData){
        
        if(!mcpInsertData.isEmpty()) insert mcpInsertData;
        if(!mcpUpdateData.isEmpty()) update mcpUpdateData;
        if(!mcpDeleteData.isEmpty()) delete mcpDeleteData;
    }    
    
    @auraEnabled    
    public static List<Commercial__c> insertCommercialData(Commercial__c theCommercial, Boolean isPlanChanged, List<String> ppoToDelete, List<TDR__c> pricingToDelete, List<MerchantPaymentOption__c> paypentOptionsToInsert, List<MerchantPaymentOption__c> paypentOptionsToUpdate, List<TDR__c> pricingToInsert, List<TDR__c> pricingToUpdate){
        
        if(theCommercial != null) upsert theCommercial;
        
        if(isPlanChanged){
            List<TDR__c> tdrToDelete = [SELECT Id FROM TDR__c WHERE Commercial__c =: theCommercial.Id];
            if(!tdrToDelete.isEmpty()) delete tdrToDelete;
        }else{            
            if(!ppoToDelete.isEmpty()){
                delete [SELECT Id FROM MerchantPaymentOption__c WHERE Id IN: ppoToDelete];
            }        
            if(!pricingToDelete.isEmpty()){
                delete pricingToDelete;
            }
        } 
                
        if(!paypentOptionsToInsert.isEmpty()){
            
            for(MerchantPaymentOption__c each : paypentOptionsToInsert){ 
                each.Opportunity__c = theCommercial.Opportunity__c;                               
            }            
            insert paypentOptionsToInsert;
        }
        
        if(!pricingToInsert.isEmpty()){                        
            
            for(TDR__c each : pricingToInsert){
                each.Commercial__c = theCommercial.Id;
                each.Opportunity__c = theCommercial.Opportunity__c;
            }            
            insert pricingToInsert;
        }
        
        if(!paypentOptionsToUpdate.isEmpty()){
            
            for(MerchantPaymentOption__c each : paypentOptionsToUpdate){
                each.Opportunity__c = theCommercial.Opportunity__c;
            }            
            update paypentOptionsToUpdate;
        }
        
        if(!pricingToUpdate.isEmpty()){                        
            
            for(TDR__c each : pricingToUpdate){
                each.Commercial__c = theCommercial.Id;
                each.Opportunity__c = theCommercial.Opportunity__c;
            }            
            update pricingToUpdate;
        }
                        
        return getCommercialRecords(theCommercial.Opportunity__c, false, '');   
    }
    
    @auraEnabled    
    public static List<Commercial__c> savePaymentsData(Commercial__c theCommercial, List<Payment__c> paymentsToInsert, List<Payment__c> paymentsToUpdate){
        
        if(!paymentsToInsert.isEmpty()){                        
            
            for(Payment__c each : paymentsToInsert){
                each.Commercial__c = theCommercial.Id;
                each.Active__c = true;
            }
            
            insert paymentsToInsert;
        }
        
        if(!paymentsToUpdate.isEmpty()){                        
            
            for(Payment__c each : paymentsToUpdate){
                each.Commercial__c = theCommercial.Id;
                each.Active__c = true;
            }
            
            update paymentsToUpdate;
        }
        
        return getCommercialRecords(theCommercial.Opportunity__c, true, theCommercial.Id);      
    }
    
    public static Commercial__c getCommercial(String commercialId){
        return Database.query('SELECT Id, ' + String.join(commercialFields, ', ') + ' FROM Commercial__c WHERE Id =\'' + commercialId + '\'');
    }
    
    @auraEnabled
    public static TheInitData getPaymentsData(String oppId){
        TheInitData theData = new TheInitData(); 
        theData.commercialData = getCommercialRecords(oppId, true, '');                  
        theData.chargeTypes = PicklistGenerator.getPicklistValues('Payment__c', 'Charges_Type__c', '', false); 
        theData.occurences = PicklistGenerator.getPicklistValues('Payment__c', 'Occurance__c', '', false);         
        theData.currentDate = Date.today();         
        return theData;
    }
    
    public static Plan__c getPlan(String planId){
        return Database.query('SELECT Id, ' + String.join(PlanFormController.planFieldsList, ', ') + ' FROM Plan__c WHERE Active__c = true AND Id = \'' + planId + '\'');
    }
    
    @auraEnabled
    public static List<Payment_Details__c> getPaymentDetails(String selectedPaymentId){
        return Database.query('SELECT Id, ' + String.join(paymentDetailFields, ', ') + ' FROM Payment_Details__c WHERE Id = \'' + selectedPaymentId + '\'');
    }
    
    //=== updated for JIRA=======
    @AuraEnabled
    public static List<SObject> getSelectedPlanMPOData(string oppId, String planId){
        Set<String> poIds = new Set<String>();
        
        for(PricingPaymentOption__c each : [SELECT Payment_Option__c FROM PricingPaymentOption__c WHERE Plan__c =: planId]){
            poIds.add(each.Payment_Option__c);
        }
                
        Set<String> planIds = pastPlans(oppId);
        planIds.add(planId);
        
        String queryStr = 'SELECT Id, ' + String.join(PlanFormController.poFieldList, ', ') + ', ';
        
        queryStr += '(SELECT Id, ' + String.join(planPricingPOFields, ', ');
        queryStr += ', Payment_Gateway__r.' + String.join(PlanFormController.pgFieldList, ', Payment_Gateway__r.');
        //queryStr += ', Payment_Option__r.' + String.join(PlanFormController.poFieldList, ', Payment_Option__r.');
        queryStr += ' FROM PO_PG_Mappings__r)';        
        
        if(String.isNotBlank(oppId)){
            queryStr += ', (SELECT Id, '+ String.join(merchantPricingPOFields, ', ');
            queryStr += ', Payment_Gateway__r.' + String.join(PlanFormController.pgFieldList, ', Payment_Gateway__r.');
			//queryStr += ', Payment_Option__r.' + String.join(PlanFormController.poFieldList, ', Payment_Option__r.');            
            queryStr += ' FROM Merchant_Payment_Options__r WHERE ' + 'Opportunity__c =\'' + oppId + '\')';
        }
        
        if(String.isNotBlank(planId)){
            queryStr += ', (SELECT Id, '+ String.join(planPricingPOFields, ', ');
            queryStr += ', Payment_Gateway__r.' + String.join(PlanFormController.pgFieldList, ', Payment_Gateway__r.'); 
            //queryStr += ', Payment_Option__r.' + String.join(PlanFormController.poFieldList, ', Payment_Option__r.');
            queryStr += ' FROM Pricing_Payment_Options__r WHERE ' + 'Plan__c =\'' + planId + '\')';
        }
        
        queryStr += ' FROM Payment_Option__c';        
        
        return Database.query(queryStr);
    }
    
    public class TheInitData{
        @auraEnabled
        public Commercial__c theCommercial;
        @auraEnabled
        public List<Sobject> commercialData;
        @auraEnabled
        public List<Sobject> tdrData;
        @auraEnabled
        public List<Sobject> planPricingData;
        @auraEnabled
        public Plan__c thePlan;        
        @auraEnabled
        public String types;
        @auraEnabled
        public String settlementDays;
        @auraEnabled
        public String planTypes;
        @auraEnabled
        public String plans;
        @auraEnabled
        public List<Sobject> mdrTSFMasterData;
        @auraEnabled
        public String currencies;
        @auraEnabled
        public List<Sobject> mcpList;
        @auraEnabled      
        public String cardClassPickList; 
        @auraEnabled
        public String chargeTypes;
        @auraEnabled
        public String occurences;
        @auraEnabled
        public List<Sobject> paymentsList;
        @auraEnabled
        public Date currentDate;
        @auraEnabled
        public String routingTypes;
        @auraEnabled
        public List<Sobject> partners;
        
        //=== updated for JIRA
        @auraEnabled
        public List<Sobject> selectedPlancommercialData;
        @auraEnabled
        public List<Sobject> theRackRatePlan;
    }
}