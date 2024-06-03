public class OpportunityController {
    // =================== Used for "OptyButton" Component=====================
    /*--------------------------------------------------------------------------------
    Description:    method to get the opttortunity records based on opportunity id 
    Inputs:         Opportunity Id
    Outputs:        Opportunity Obj
    History
    <Date>          <Authors Name>      <Brief Description of Change>
    Aug.22, 2018    Uma Shankar        Created
    ---------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Opportunity getOptyRecord(Id opportunityId){
        /*if(String.isNotBlank(opportunityId)){
            Opportunity optyObj = [SELECT Id, Prod_Merchant_Id__c, Merchant_Id__c, Platform_new__c FROM Opportunity WHERE Id =: opportunityId];
            return optyObj;
        }*/
        return null;
    }      
}