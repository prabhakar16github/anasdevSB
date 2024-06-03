public class OutboundIVRCallBatch_PL implements Database.batchable <sObject>,Database.Stateful,Database.AllowsCallouts {
    public map<string,Id> mapOfQueueVsQueueId;
    public string strCondition;
    
    public OutboundIVRCallBatch_PL(){
        list<string> lstQueues = new list<string>{'LP_Manual_Call_Queue_Collection','LP_Outbound_IVR_Queue_Collection'};
        mapOfQueueVsQueueId = SystemUtility.getQueuesInfo(lstQueues);
        strCondition = CollectionNotificationUtility.getWhereConditionFromMtdt('IVR_Call_2');
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        string strquery = 'SELECT id,recordtype.developerName,LP_Current_Outstanding_Amount__c,LP_Communication_Sub_Type__c,LP_APP_Notification__c,LP_Email__c,Identifier__c,LP_IVR_Call__c,LP_IVR_Call_Count__c,LP_Manual_Call__c,LP_SMS__c,Contact.MobilePhone,Contact.Email,Contact.LastName,LP_KYC_State__c,LP_Due_Since__c,LP_Mobile_Pay_URL__c,LP_Onboarding_Status__c,LP_Outstanding_Amount__c,LP_Type_of_IVR__c,LP_Funnel_Status__c,ContactId,LP_IVR_Id__c FROM Case WHERE  contactId != null AND recordtype.developername = \'Collection\' AND ownerId =\''+mapOfQueueVsQueueId.get('LP_Outbound_IVR_Queue_Collection') + '\'';
        if(String.isNotBlank(strCondition))
            strquery += ' AND '+ strCondition;
        System.debug('strCondition======='+strCondition);
        System.debug('strquery======='+strquery);
        strquery += ' order by LP_Status_Priority_Order__c asc';
        System.debug('strquery======='+strquery); 
       
       // String strquery = 'SELECT id,recordtype.developerName,LP_Current_Outstanding_Amount__c,LP_Communication_Sub_Type__c,LP_APP_Notification__c,LP_Email__c,Identifier__c,LP_IVR_Call__c,LP_IVR_Call_Count__c,LP_Manual_Call__c,LP_SMS__c,Contact.MobilePhone,Contact.Email,Contact.LastName,LP_KYC_State__c,LP_Due_Since__c,LP_Mobile_Pay_URL__c,LP_Onboarding_Status__c,LP_Outstanding_Amount__c,LP_Type_of_IVR__c,LP_Funnel_Status__c,ContactId,LP_IVR_Id__c FROM Case where Id =\'500N000000DfIFJ\'';
        return Database.getQueryLocator(strquery);
    }
    
    public void execute(Database.BatchableContext info, List<Case> scope){
        try{
            map<Id,Case> mapOfUpdatedCase = new map<Id,Case>();
            list<Case> listOfIVRCalls = new list<Case>();
            //send list<Case> to knowlarity for IVR Calls
            for(Case eachCase : scope){
                if(eachCase.LP_IVR_Call__c != NULL && eachCase.LP_IVR_Call__c > 0){
                       listOfIVRCalls.add(eachCase);
                       eachCase.LP_IVR_Call_Count__c = eachCase.LP_IVR_Call_Count__c != NULL?eachCase.LP_IVR_Call_Count__c+1:1;
                       mapOfUpdatedCase.put(eachCase.Id,eachCase);
                }
                //update owner on case
                if(eachCase.LP_Manual_Call__c != NULL && eachCase.LP_Manual_Call__c >0){
                    if(mapOfUpdatedCase!=null && mapOfUpdatedCase.containsKey(eachCase.Id)){
                        mapOfUpdatedCase.get(eachCase.Id).OwnerId = mapOfQueueVsQueueId.get('LP_Manual_Call_Queue_Collection');
                    }
                    else{
                        eachCase.OwnerId = mapOfQueueVsQueueId.get('LP_Manual_Call_Queue_Collection');
                        mapOfUpdatedCase.put(eachCase.Id,eachCase);
                    }
                }
            }
            system.debug('listOfIVRCalls=============='+listOfIVRCalls);
            if(listOfIVRCalls != NULL && listOfIVRCalls.size()>0){
                string jsonBody = KnowlarityUtility.prepareIVRPayload('IVR_Call',listOfIVRCalls,'Collection');
                HttpResponse res = CollectionNotificationUtility.sendRequest(jsonBody,'knowlarityIVRCall','IVR_Call');
                system.debug('res=============='+res.getBody());
            }
            
            
            if(mapOfUpdatedCase != NULL && mapOfUpdatedCase.size()>0){
                update mapOfUpdatedCase.Values();
            }
        }
        catch(Exception ex){
            System.debug('Exception ::::');
            LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
            objWrapper.message = ex.getMessage();
            objWrapper.process = 'OutboundIVRCallBatch';
            objWrapper.stackTrace = ex.getStackTraceString();
            LazyPayExceptionHandling.insertErrorLog(objWrapper);
        }
    }
    
    public void finish(Database.BatchableContext info){
        //OutboundIVRCallBatch objBatch = new OutboundIVRCallBatch(listOfCase,mapOfQueueVsQueueId);
        //Database.executeBatch(objBatch)
    }
}