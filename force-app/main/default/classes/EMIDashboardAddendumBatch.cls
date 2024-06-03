public class EMIDashboardAddendumBatch implements Database.Batchable<sObject>, 
Database.AllowsCallouts, Database.stateful{
    
    public Static Boolean isAddendumBulkUploadBatch = false;
    public Set<String> ContractIds = new Set<String>();
    public set<string> setContractId = new Set<String>();
    public string DocMaster='';
    public string strEndPoint='';
    public Boolean publishCall=false;
    public Map<string, String> addNameVsPageAssociationMap;
        /*
    public EMIDashboardAddendumBatch(set<string> setContractId,string DocMaster,Boolean checkCall) {
        this.setContractId = setContractId;
        this.DocMaster = DocMaster;
        this.strEndPoint = '';
        this.publishCall = checkCall;
    }
    */
    public EMIDashboardAddendumBatch(set<string> setContractId,Map<string, String> addendumNameVsPageAssociationMap,Boolean checkCall) {
        this.setContractId = setContractId;
        this.DocMaster = DocMaster;
        this.strEndPoint = '';
        this.publishCall = checkCall;
        this.addNameVsPageAssociationMap = addendumNameVsPageAssociationMap;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        string queryResult = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Contract')), ',') + ',Opportunity__r.Identifier__c FROM Contract WHERE Id IN (\'' + String.join(new List<String>(setContractId), '\',\'') + '\')';
        return Database.getQueryLocator(queryResult);        
    }
    
    public void execute(Database.BatchableContext BC, List<Contract> ContractList) {
        list<contract> updatedList = new list<contract>();
        for(Contract eachContract : ContractList){
            if(!publishCall){
                if(!addNameVsPageAssociationMap.isEmpty() && addNameVsPageAssociationMap.containsKey(eachContract.Name) && addNameVsPageAssociationMap.get(eachContract.Name) != null){
                    PageReference pageRef = new PageReference('/apex/' + addNameVsPageAssociationMap.get(eachContract.Name));
                    pageRef.getParameters().put('id', eachContract.Opportunity__c);     
                    
                    Blob body;
                    
                    if(!Test.isRunningTest()){
                        body = pageRef.getContentAsPDF();
                    }else{
                        body = Blob.valueOf('Test Attachment Body');
                    }
                    if(!Test.isRunningTest()) strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(eachContract,eachContract.Opportunity__r.Identifier__c, body, 'merchants');
                    //if(!Test.isRunningTest()) strEndPoint = AWSUtility.uploadAndGetDocUrlS3(eachContract, eachContract.Opportunity__r.Identifier__c, body);
                    
                    if(String.isNotBlank(strEndPoint) || Test.isRunningTest())
                    {
                        system.debug('strEndPoint=='+strEndPoint);
                        eachContract.URL__c = strEndPoint;
                        updatedList.add(eachContract);
                    }
                }
            }
                ContractIds.add(eachContract.id);
                        
        }
        
        if(updatedList.size() > 0 && updatedList != null ){
            Database.SaveResult[] updatedAddendumResult= Database.update(updatedList,false);
        }
    }
    
    public void finish(Database.BatchableContext BC){
       
        if(!ContractIds.isEmpty() && ContractIds.size()>0 ){
            isAddendumBulkUploadBatch = true;
            for(Contract each : Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Contract')), ',') + ' FROM Contract WHERE Id IN (\'' + String.join(new List<String>(ContractIds), '\',\'') + '\')')){                 
                if(each.URL__c != NULL){
                    IntegrationUtility.isFutureUpdate = true;
                    IntegrationUtility.checkMaintenance(each, null, 'Contract', 'Merchant_Document__c');
                }                   
            }
        }        
    }   
}