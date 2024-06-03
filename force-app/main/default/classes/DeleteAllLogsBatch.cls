public class DeleteAllLogsBatch implements Database.Batchable<String>{
    
    public Iterable<String> start(Database.BatchableContext BC){
        return new List<String> {'1'};
            }
    
    public void execute(Database.BatchableContext info, List<String> strings){
        Boolean checkOneSuccessLog = false;
        List<Error_Details__c> errorDetailList = New List<Error_Details__c>();
        List<String> lstErrors = New List<String>();
        
        if(getErrorDetails().size() >0){
            List<Error_Details__c> deletedErrorLogs = getErrorDetails();
            Database.DeleteResult[] DR_Dels = Database.delete(deletedErrorLogs,false);
            
            List<id> deletedRecordIds = New List<Id>();
            for(Database.DeleteResult dr : DR_Dels) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                    deletedRecordIds.add(dr.getId());
                }
            }
            
            if(!deletedRecordIds.isEmpty()){
                Database.EmptyRecycleBinResult[] emptyRecycleBinErrorLogResults = DataBase.emptyRecycleBin(deletedRecordIds);
                for(Database.EmptyRecycleBinResult drRecycle : emptyRecycleBinErrorLogResults){
                    if(!drRecycle.isSuccess()){
                        List<Database.Error> errs1 = drRecycle.getErrors();
                        for(Database.Error err : errs1) {
                            System.debug(err.getMessage() + ' ' + err.getStatusCode());
                            Error_Details__c objErrorLog = new Error_Details__c();
                            objErrorLog.Process__c = 'Custom Error Log Deletion Failed';
                            objErrorLog.Message__c = err.getMessage() + ' ' + err.getStatusCode();
                            errorDetailList.add(objErrorLog);
                        }
                    }
                    
                    else if(drRecycle.isSuccess()){
                        checkOneSuccessLog = true;
                    }
                }
            }
        }else{
            checkOneSuccessLog = true;
        }
        
        if(checkOneSuccessLog){
            List<Payload_log__c> deletedPayloadLogs = getPayloadLogs();
            Database.DeleteResult[] DR_Dels = Database.delete(deletedPayloadLogs,false);
            
            List<id> deletedRecordIds = New List<Id>();
            for(Database.DeleteResult dr : DR_Dels) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                    deletedRecordIds.add(dr.getId());
                }
            }
            
            if(!deletedRecordIds.isEmpty()){
                Database.EmptyRecycleBinResult[] emptyRecycleBinPayloadLogResults = DataBase.emptyRecycleBin(deletedRecordIds);
                
                for(Database.EmptyRecycleBinResult drRecycle : emptyRecycleBinPayloadLogResults){
                    if(!drRecycle.isSuccess()){
                        List<Database.Error> errs1 = drRecycle.getErrors();
                        for(Database.Error err : errs1) {
                            System.debug(err.getMessage() + ' ' + err.getStatusCode());
                            Error_Details__c objErrorLog = new Error_Details__c();
                            objErrorLog.Process__c = 'Custom Paylod Log Deletion Failed';
                            objErrorLog.Message__c = err.getMessage() + ' ' + err.getStatusCode();
                            errorDetailList.add(objErrorLog);
                        }
                    }
                }
            }
        }
        
        if(!errorDetailList.isEmpty()) insert errorDetailList;
    }
    
    public void finish(Database.BatchableContext info){
        if(!Test.isRunningTest()) {
            Database.executeBatch(new DeleteAllLogsBatch());
        }
    }
    
    public List<Error_Details__c> getErrorDetails(){
        return[Select Id from Error_Details__c Where CreatedDate < Last_N_Days : 45 LIMIT 10000];
    }
    
    public List<Payload_Log__c> getPayloadLogs(){
        return[Select Id from Payload_log__c Where CreatedDate < Last_N_Days : 45 LIMIT 10000];
    }
}