/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 1/11/2018
    @description: To reset the manual call flag on case
*/
public class ResetManualCallBatch implements database.Batchable <sObject>,Database.Stateful{
	public Database.QueryLocator start(Database.BatchableContext BC){
        string strquery = 'SELECT id,LP_IVR_Call__c,LP_Manual_Call_Completed__c,LP_KYC_Last_Modified_Date__c,LP_Notification_1__c,LP_Notification_2__c,LP_Notification_3__c';
        strquery +=  ',LP_Notification_4__c,LP_Manual_Call__c,LP_Type_of_IVR__c,LP_KYC_State__c,LP_Onboarding_Status__c FROM Case ' ;
        strquery += 'WHERE recordtype.developername = \'KYC\' AND LP_Manual_Call_Completed__c = true'; 
        return Database.getQueryLocator(strquery);
	}
    
    public void execute(Database.BatchableContext BC, List<Case> scope){
        list<Case> updatedListCase = new list<Case>();
        for(Case eachCase : scope){
            eachCase.LP_Manual_Call_Completed__c = false;
            updatedListCase.add(eachCase);
        }
        
        if(updatedListCase!= NULL && updatedListCase.size()>0)
            update updatedListCase;
    }
    
    public void finish(Database.BatchableContext BC){}
}