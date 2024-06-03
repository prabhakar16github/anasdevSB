public class SendEmailBatch implements Database.batchable <sObject>,Database.Stateful,Database.AllowsCallouts{
    public string strCondition;
    map<string,Id> mapOfQueueVsQueueId ;
    List<PayloadActMap__mdt> payloadList;
    public map<string,Id> mapOfEmailNameVsId;
    List<Integration_Setting__mdt> lstIntegarion;
    
   
    
    public SendEmailBatch(){
        mapOfQueueVsQueueId = new map<string,Id>();
        // Updated by Kapil (29-10-2019) Get template Id based on template developer name
        //mapOfEmailNameVsId = CollectionNotificationUtility.getSMSTemplateId('Collection Templates');
        mapOfEmailNameVsId = CollectionNotificationUtility.getEmailTemplateId('Collection Templates'); 
        strCondition = CollectionNotificationUtility.getWhereConditionFromMtdt('Send_Email');
        payloadList = CollectionNotificationUtility.getPayLoadMap('Send_Email');
        lstIntegarion = CollectionNotificationUtility.getIntegrationDt('SendCollectionNotification');
    }
    public SendEmailBatch(map<string,Id> mapOfQueueVsQueueId){
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(mapOfQueueVsQueueId != NULL && mapOfQueueVsQueueId.size() ==0){
            list<string> lstQueues = new list<string>{'LP_Email_Queue','LP_Manual_Call_Queue_Collection'};
                mapOfQueueVsQueueId = SystemUtility.getQueuesInfo(lstQueues);
        }
       String dateStr = Date.today().format(); 
       string strquery = 'SELECT ';
        if(payloadList != NULL && payloadList.size()>0)
            strquery+= payloadList[0].Field_To_Query__c;
        strquery += ' FROM Case WHERE ContactId != null AND recordtype.developername = \'Collection\' AND Collection_Rule_Time__c= \''+ dateStr +'\' AND ownerId =\''+mapOfQueueVsQueueId.get('LP_Email_Queue') +'\'';
        if(String.isNotBlank(strCondition))
          strquery += ' AND '+ strCondition;
        strquery += ' order by LP_Status_Priority_Order__c desc';
        System.debug('strquery======='+strquery);
       
       // String strquery = 'SELECT LP_APP_Notification__c,LP_Communication_Sub_Type__c,LP_Email__c,LP_IVR_Call__c,LP_Manual_Call__c,LP_SMS__c,Contact.MobilePhone,LP_SMS_Content__c,Id,LP_Status_Priority_Order__c,Identifier__c,ContactId,LP_Email_Template_Name__c,Contact.Email FRom Case where id = \'500N000000DfK3M\'';
       //System.debug('strquery======='+strquery);
        return Database.getQueryLocator(strquery);
    }
    
    public void execute(Database.BatchableContext info, List<Case> scope){
        try{
            System.debug('Scope Size Inside Execute : ' + scope.size()); 
            list<string> listOfJSONString = new list<string>();
            list<LP_HTTP_Publisher__c> lstPub = new list<LP_HTTP_Publisher__c>();
            list<case> listOfCasesToSend = new List<Case>();
    
            for(Case eachCase : scope){ 
                // call Lazy Pay Db and send the data for sms
                if(eachCase.LP_Email__c != NULL && eachCase.LP_Email__c > 0){                
                    listOfCasesToSend.add(eachCase); 
                }
                
             }   
             // Single payload has been changed to Bulk Payload , Changed BY kapil Chauhan (04-10-2019)
             // string jsonstr = CollectionNotificationUtility.preparepayloadData(eachCase,payloadList[0],'Email',mapOfEmailNameVsId);
                string jsonstr = CollectionNotificationUtility.prepareBulkPayloadData(listOfCasesToSend,payloadList[0],'Email',mapOfEmailNameVsId);           
                System.debug('jsonstr======='+jsonstr);
                LP_HTTP_Publisher__c objPub = CollectionNotificationUtility.sendRequestForSMS(jsonStr,lstIntegarion,'Send_Email');
                System.debug('objPub======='+objPub);
                if(objPub != NULL)
                   insert objPub;
            
            // Create the activity 
            CollectionNotificationUtility.CreateTask(listOfCasesToSend, 'Email Sent');
             
        }
        catch(Exception ex){
            LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
            objWrapper.message = ex.getMessage();
            objWrapper.process = 'SendEmailBatch';
            objWrapper.stackTrace = ex.getStackTraceString();
            LazyPayExceptionHandling.insertErrorLog(objWrapper);
        }
    }
    
    public void finish(Database.BatchableContext info){
     
       
    }
}