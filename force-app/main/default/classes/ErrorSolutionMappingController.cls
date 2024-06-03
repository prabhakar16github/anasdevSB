public class ErrorSolutionMappingController {

    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the list of Error Solution mapping based on Entity Type from Account
    ---------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static WrapperErrorSolution getErrorSolutionMapping(String strContractId){
        
        
        if(string.isNotBlank(strContractId)){
            List<Contract> lstContract = new List<Contract>();
            
            getContractRecord(strContractId, lstContract);
            system.debug(lstContract.size()+' ********* lstContract********** '+lstContract);
            
            WrapperErrorSolution wrpErrorSolutionObj = new WrapperErrorSolution();
            wrpErrorSolutionObj.contractObj = lstContract[0];
            List<Error_Solution_Mapping__c> lstErrorSolution = new List<Error_Solution_Mapping__c>();
            
            if(!lstContract.isEmpty() && String.isNotBlank(lstContract[0].AccountId) && String.isNotBlank(lstContract[0].Account.Business_Entity__c)) {
                getErrorSolutionMappingRecords(lstContract[0].Account.Business_Entity__c, lstErrorSolution);
            }            
            system.debug(lstErrorSolution.size()+' ********* lstErrorSolution********** '+lstErrorSolution);
            
            if(!lstErrorSolution.isEmpty()){
                wrpErrorSolutionObj.lstErrorSolutionsExist = lstErrorSolution;
            }
            //wrpErrorSolutionObj.lstErrorSolutionsCustom = new List<Error_Solution_Mapping__c>{new Error_Solution_Mapping__c()};
            return wrpErrorSolutionObj;
        }
        return null;
    }
    
    /*-----------------------------------------------------------------------------------------------------
    Description:    method to add the selected error solution values in merchant document error solution
    ------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String saveErrorSolution(String strContractId, String strError, String strSolution){
        system.debug('strContractId ********* '+strContractId);
        system.debug(strError+' ********** '+strSolution);
        
        if(String.isNotBlank(strContractId) && String.isNotBlank(strError) && String.isNotBlank(strSolution)){
            List<Contract> lstContract = new List<Contract>();
            getContractRecord(strContractId, lstContract);
            
            if(String.isNotBlank(lstContract[0].Error__c)){
                lstContract[0].Error__c = lstContract[0].Error__c + strError;
            }else{
                lstContract[0].Error__c = strError;
            }
            
            if(String.isNotBlank(lstContract[0].Solution__c)){
                lstContract[0].Solution__c = lstContract[0].Solution__c + strSolution;
            }else{
                lstContract[0].Solution__c = strSolution;
            }
            
            try{
                update lstContract[0];
                return 'Error_Solution_Added';
            }catch(DMLException ex){
                return 'Error : '+ex.getMessage()+' at Line number '+ex.getLineNumber();    
            }
            
        }
        return null;
    }
    
    
    
    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the list of Error Solution records based on Entity Type Id
    ---------------------------------------------------------------------------------------------------*/
    public static void getErrorSolutionMappingRecords(Id businesEntityId, List<Error_Solution_Mapping__c> lstErrorSolution){
        lstErrorSolution.addAll([SELECT  Id, Name, Error__c, Solution__c, Entity__c
                                FROM Error_Solution_Mapping__c
                                WHERE Entity__c =: businesEntityId]);
    }
    
    /*-------------------------------------------------------------------------------------------------
    Description:    method to get the list of Contract records based on Contract Id
    ---------------------------------------------------------------------------------------------------*/
    public static void getContractRecord(String strContractId, List<Contract> lstContract){
        lstContract.addAll([SELECT Id, AccountId, Account.Business_Entity__c, Error__c, Solution__c 
                            FROM Contract 
                            WHERE Id =: strContractId 
                            LIMIT 1]);
    }
}