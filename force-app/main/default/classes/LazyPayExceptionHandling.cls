/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       Apex class that creates exception logs
@history
<Date>        <Authors Name>        <Brief Description of Change>
3-Dec-18     Eitika Verma          created
**/
public class LazyPayExceptionHandling {
	public static void insertErrorLog(ErrorLogWrapper errorWrap){
        Error_Details__c objErrorLog = new Error_Details__c();
        objErrorLog.Message__c = errorWrap.message;
        objErrorLog.Response__c = errorWrap.response;
        objErrorLog.Request__c = errorWrap.request;
        objErrorLog.Process__c = errorWrap.process;
        objErrorLog.StackTrace__c = errorWrap.stackTrace;
        insert objErrorLog;
    }
    
    public static void insertErrorLog(list<ErrorLogWrapper> lsterrorWrap){
        list<Error_Details__c> lstErrorDetail = new list<Error_Details__c>();
        for(ErrorLogWrapper errorWrap : lsterrorWrap){
            Error_Details__c objErrorLog = new Error_Details__c();
            objErrorLog.Message__c = errorWrap.message;
            objErrorLog.Response__c = errorWrap.response;
            objErrorLog.Request__c = errorWrap.request;
            objErrorLog.Process__c = errorWrap.process;
            objErrorLog.StackTrace__c = errorWrap.stackTrace;
            lstErrorDetail.add(objErrorLog);
        }
        
        if(lstErrorDetail != NULL && lstErrorDetail.size()>0)
        	insert lstErrorDetail;
    }
    
    public class ErrorLogWrapper{
        public string message;
        public string process;
        public string request;
        public string response;
        public string stackTrace;
    }
}