/*
@author: Eitika Verma
@company: Saasfocus
@date : 22/4/2019
@description: This class is used to send sms notification for collection records
*/
public class SMSNotificationBatch_PL implements Database.batchable <sObject>,Database.stateful,Database.AllowsCallouts{
    public string strCondition;
    map<string,Id> mapOfQueueVsQueueId;
    List<PayloadActMap__mdt> payloadList;
    List<Integration_Setting__mdt> lstIntegarion;
    list<Case> updatedListCase = new list<Case>();
    
    public SMSNotificationBatch_PL(){
        mapOfQueueVsQueueId = new map<string,Id>();
        payloadList = CollectionNotificationUtility.getPayLoadMap('Send_Sms');
        strCondition = CollectionNotificationUtility.getWhereConditionFromMtdt('Send_SMS_2');
        lstIntegarion = CollectionNotificationUtility.getIntegrationDt('SendCollectionNotification');
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(mapOfQueueVsQueueId != NULL && mapOfQueueVsQueueId.size() ==0){
            list<string> lstQueues = new list<string>{'LP_SMS_Queue','LP_Manual_Call_Queue_Collection'};
                mapOfQueueVsQueueId = SystemUtility.getQueuesInfo(lstQueues);
        }
        
        string strquery = 'SELECT ';
        if(payloadList != NULL && payloadList.size()>0)
            strquery+= payloadList[0].Field_To_Query__c;
        strquery += ' FROM Case WHERE recordtype.developername = \'Collection\' AND ownerId =\''+mapOfQueueVsQueueId.get('LP_SMS_Queue')+'\'';
        if(String.isNotBlank(strCondition))
            strquery += ' AND '+ strCondition;
        strquery += ' order by LP_Status_Priority_Order__c desc';
        System.debug('strquery===='+strquery);
        return Database.getQueryLocator(strquery);
    }
    
    public void execute(Database.BatchableContext info, List<Case> scope){
        try{
            //List<Task> taskList = new List<Task>();
            list<string> listOfJSONString = new list<string>();
            list<LP_HTTP_Publisher__c> lstPub = new list<LP_HTTP_Publisher__c>();
            List<Case> caseList = new List<Case>();
            
            for(Case eachCase : scope){ 
                // call Lazy Pay Db and send the data for sms
                if(eachCase.LP_SMS__c != NULL && eachCase.LP_SMS__c > 0){
                   caseList.add(eachCase); 
                }
                
            }
            
            // string jsonstr = CollectionNotificationUtility.preparepayloadData(eachCase,payloadList[0],'SMS',null);
            // prepareBulkPayloadData() is used to send records in Bulk (Changed By : Kapil Chauhan : 07-10-2019)
             string jsonstr = CollectionNotificationUtility.prepareBulkPayloadData(caseList,payloadList[0],'SMS',null);
            
            LP_HTTP_Publisher__c objPub = CollectionNotificationUtility.sendRequestForSMS(jsonStr,lstIntegarion,'Send_SMS');
            //createTask(eachCase, 'SMS Notification', taskList);
                    
             if(objPub != NULL){
               insert objPub ;
             }
               // lstPub.add(objPub);
            
            //System.debug('taskList======'+taskList);
            //if(!taskList.isEmpty())   insert taskList;
            
           // if(lstPub.isEmpty() == false)
            //    insert lstPub;
        }
        catch(Exception ex){
            LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
            objWrapper.message = ex.getMessage();
            objWrapper.process = 'SMSNotificationBatch';
            objWrapper.stackTrace = ex.getStackTraceString();
            LazyPayExceptionHandling.insertErrorLog(objWrapper);
        }
    }
    
    public void finish(Database.BatchableContext info){
        
        
    }
    
    /*public void createTask(Case objCase, String subject, List<Task> taskList){
        System.debug('ObjCase.LP_SMS_Content__c========='+ObjCase.LP_SMS_Content__c);
        System.debug('ObjCase.Id ========='+ObjCase.Id );
        if(ObjCase != NULL && String.isNotBlank(ObjCase.LP_SMS_Content__c) && ObjCase.Id != Null){
            task objtask = new task ();
            Objtask.WhatId = objCase.ID;
            Objtask.Subject = subject;
            ObjTask.LP_Customer_Number__c = objCase.Contact.MobilePhone;
            ObjTask.SMS_Content__c = ObjCase.LP_SMS_Content__c;
            taskList.add(objTask);
            System.debug('taskList========='+taskList);
        }
    }*/
}