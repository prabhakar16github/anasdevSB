public class WrapperErrorSolution {
    
    @AuraEnabled
    public List<Error_Solution_Mapping__c> lstErrorSolutionsExist {get; Set;}
    
    @AuraEnabled
    public List<Error_Solution_Mapping__c> lstErrorSolutionsCustom {get; Set;}
    
    @AuraEnabled
    public Contract contractObj {get; Set;}
}