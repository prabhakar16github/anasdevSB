public class SMSAndAppNotificationBatch implements Database.batchable <sObject>,Database.stateful,Database.AllowsCallouts{
    map<string,Id> mapOfQueueVsQueueId;
    public SMSAndAppNotificationBatch(map<string,Id> mapOfQueueNameVsQueueId){
        mapOfQueueVsQueueId = mapOfQueueNameVsQueueId;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        string strquery = 'SELECT id,LP_APP_Notification__c,LP_Email__c,LP_IVR_Call__c,LP_Manual_Call__c,LP_SMS__c FROM Case WHERE recordtype.developername = \'Collection\' AND ownerId =\''+mapOfQueueVsQueueId.get('LP_SMS_and_App_Notification_Queue')+'\' order by LP_Status_Priority_Order__c asc';
        System.debug('strquery===='+strquery);
        return Database.getQueryLocator(strquery);
    }
    
    public void execute(Database.BatchableContext info, List<Case> scope){
        try{
            list<Case> updatedListCase = new list<Case>();
            for(Case eachCase : scope){ 
                // call Lazy Pay Db and send the data for app notification and sms
                system.debug('eachCase=='+eachCase);
                //update owner on case
                if(eachCase.LP_Email__c != NULL && eachCase.LP_Email__c > 0){
                    eachCase.OwnerId = mapOfQueueVsQueueId.get('LP_Email_Queue');
                    updatedListCase.add(eachCase);
                }
                else if(eachCase.LP_IVR_Call__c != NULL && eachCase.LP_IVR_Call__c > 0){
                    eachCase.OwnerId = mapOfQueueVsQueueId.get('LP_Outbound_IVR_Queue_Collection');
                    updatedListCase.add(eachCase);
                }
                else if(eachCase.LP_Manual_Call__c != NULL && eachCase.LP_Manual_Call__c > 0){
                    eachCase.OwnerId = mapOfQueueVsQueueId.get('LP_Manual_Call_Queue_Collection');
                    updatedListCase.add(eachCase);
                }
            }
            
            if(updatedListCase != NULL && updatedListCase.size()>0){
                update updatedListCase;
            }  
        }
        catch(Exception ex){
            LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
            objWrapper.message = ex.getMessage();
            objWrapper.process = 'SMSAndAppNotificationBatch';
            objWrapper.stackTrace = ex.getStackTraceString();
            LazyPayExceptionHandling.insertErrorLog(objWrapper);
        }
    }
    
    public void finish(Database.BatchableContext info){
        SendEmailBatch objBatch = new SendEmailBatch(mapOfQueueVsQueueId);
        Database.executeBatch(objBatch);
    }
}