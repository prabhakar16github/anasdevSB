public class UpdateMerchantPlanController {
    
    @AuraEnabled
    public static merchantPlanWrapper getMerchantPlanData(Id sObjectId, string sObjectName){
        merchantPlanWrapper clsWrapperMerchantPlan =  new merchantPlanWrapper();
        try{
            If(String.isNotBlank(sObjectId) && String.isNotBlank(sObjectName)){
                
                if(getSObject(sObjectId,sObjectName) != null) 
                    clsWrapperMerchantPlan.sObjectRecord = getSObject(sObjectId,sObjectName); 
                
                If(getMerchantPlan(sObjectId, sObjectName) != null)
                    clsWrapperMerchantPlan.mPlanList = getMerchantPlan(sObjectId,sObjectName); 
                return clsWrapperMerchantPlan;
            }
        }catch(Exception ex){
            clsWrapperMerchantPlan.errorMessage = ex.getMessage();
        }
        return clsWrapperMerchantPlan;
    }
    
    @AuraEnabled
    public static merchantPlanWrapper updateMerchantPlan(string jsonWrapper){
        merchantPlanWrapper clsWrapperMerchantPlan =  new merchantPlanWrapper();
        //try{
        if(String.isNotBlank(jsonWrapper)){  
            clsWrapperMerchantPlan = (merchantPlanWrapper) System.JSON.deserialize(jsonWrapper, merchantPlanWrapper.class);
            system.debug('clsWrapperMerchantPlan ************* '+clsWrapperMerchantPlan);
            update clsWrapperMerchantPlan.mPlanObj;
        }
        
        //}catch(Exception ex){
        //  clsWrapperMerchantPlan.errorMessage = ex.getMessage();
        // }
        return clsWrapperMerchantPlan;
    }
    
    @AuraEnabled
    public static merchantPlanWrapper getMerchantPlanObj(Id sObjectId){
        merchantPlanWrapper clsWrapperMerchantPlan =  new merchantPlanWrapper();
        try{
            
            Merchant_Plan__c mPlanObj = [Select Id,Name, Base_Amount__c, Default_Amount__c , Total_Amount__c, Discount_Start_Time__c 
                                         ,Discount_End_Time__c ,Merchant_Discount_Rates__c from Merchant_Plan__c Where Id =: sObjectId];
            clsWrapperMerchantPlan.mPlanObj = mPlanObj;
            return clsWrapperMerchantPlan;
        }catch(exception ex){
            clsWrapperMerchantPlan.errorMessage = ex.getMessage();
        }
        return clsWrapperMerchantPlan;
    }
    
    public static List<Merchant_Plan__c> getMerchantPlan(Id sObjectId, string sObjectName){
        return [Select Id,Name, Base_Amount__c , Default_Amount__c, Total_Amount__c, Discount_Start_Time__c 
                ,Discount_End_Time__c ,Merchant_Discount_Rates__c   from Merchant_Plan__c Where Opportunity__c =: sObjectId];
    }
    
    public Opportunity getOpportunities(Id sObjectId){
        return [Select Id from Opportunity Where Id =: sObjectId];
    }
    
    public Lead getLeads(Id sObjectId){
        return [Select Id from Lead Where Id =: sObjectId];
    }
    
    public static sObject getSObject(Id sObjectId,string sObjectName){
        string query = 'Select Id From '+sObjectName+' Where Id =: sObjectId';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static string getRecordTypeDataId(string sObjectName){
        String devRecordTypeId = Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get(sObjectName).getRecordTypeId();
        return devRecordTypeId;
    }
    
    public class merchantPlanWrapper{
        @AuraEnabled
        public List<Merchant_Plan__c> mPlanList {get;set;}
        @AuraEnabled
        public Merchant_Plan__c mPlanObj {get;set;}
        @AuraEnabled
        public Opportunity oppObj {get;set;}
        @AuraEnabled
        public Lead leadObj {get;set;}
        @AuraEnabled
        public sObject sObjectRecord {get;set;}
        @AuraEnabled
        public string errorMessage {get;set;}
    }
}