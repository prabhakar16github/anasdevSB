/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 1/11/2018
    @description: To execute the KYC IVR Calls
*/
public class KYCIVRCallBatch implements database.Batchable <sObject>,Database.Stateful,Database.AllowsCallouts{    
    Map<string, Id> MapQueuebyID = new Map<string, Id>();
    map<string,KYC_Rule_Engine__mdt> mapKYCRuleEngine = new map<string,KYC_Rule_Engine__mdt>();
    list<KYC_Rule_Engine__mdt> lstKycRuleEngine = new list<KYC_Rule_Engine__mdt>();
    string KYCIVRQueueId ;
    string strWhereCondition;
    boolean isNextBatch = false;
    
    /*
    @author: Eitika Verma
    @date : 1/11/2018
    @description: constructor of batch and it prepares the map which contains queues information and KYC rule engine metadata
    */
     public KYCIVRCallBatch(boolean isNextbatchparam){ 
        isNextBatch = isNextbatchparam;
        list<String> lstQueue = new list<string>();
        lstQueue.add('LP_Outbound_IVR_Queue_KYC');
        lstQueue.add('LP_Manual_Call_Queue_KYC');
        lstQueue.add('LP_Terminate_Queue');
        MapQueuebyID = systemutility.getQueuesInfo(lstQueue);
        if (MapQueuebyID.containskey('LP_Outbound_IVR_Queue_KYC')){
            KYCIVRQueueId = MapQueuebyID.get('LP_Outbound_IVR_Queue_KYC');
        } 
       
         if (isNextbatch == false)
         {
             strWhereCondition = ' WHERE recordtype.developername = \'KYC\' AND ownerid = \'' + KYCIVRQueueId + '\'';
         }
         else
         {
             strWhereCondition = ' WHERE recordtype.developername = \'KYC\' AND  LP_Manual_Call__c > 0 and LP_IVR_Call__c > 0 and LP_Manual_Call_Completed__c = false';
         }
         
         lstKycRuleEngine = SystemUtility.getAllFieldsOfObject(null,'KYC_Rule_Engine__mdt',null);
         if (!lstKycRuleEngine.isempty()){
             for (KYC_Rule_Engine__mdt eachKycRuleEngine:lstKycRuleEngine){
                 mapkYCRuleEngine.put(eachKycRuleEngine.LP_Onboarding_Status__c +eachKycRuleEngine.LP_KYC_State__c,eachKycRuleEngine);
             }
         }
         system.debug('mapKYCRuleEngine============'+mapKYCRuleEngine);
         system.debug('MapQueuebyID============'+MapQueuebyID);
    }
    
    /*
    @author: Eitika Verma
    @date : 1/11/2018
    @description: start method of batch and it get all the records of case on which recordtype is KYC and 
                    owner is equal to IVR Queue Id
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        string strquery = 'SELECT id,LP_IVR_Call__c,LP_Onboarding_Status__c,LP_Outstanding_Amount__c,LP_Type_of_IVR__c,Identifier__c,LP_Communication_Sub_Type__c,LP_Funnel_Status__c,LP_KYC_Last_Modified_Date__c,LP_Notification_1__c,LP_Notification_2__c,LP_Mobile_Pay_URL__c,LP_Notification_3__c';
        strquery +=  ',Contact.MobilePhone,Contact.Email,Contact.LastName,LP_Due_Since__c,LP_Notification_4__c,LP_Manual_Call__c,LP_KYC_State__c,LP_IVR_Id__c,LP_Current_Outstanding_Amount__c FROM Case' ;
        strquery += strWhereCondition; 
        return Database.getQueryLocator(strquery);
    }
    
    /*
    @author: Eitika Verma
    @date : 1/11/2018
    @description: execute method is used to do IVR calls and update the owner
    */
     public void execute(Database.BatchableContext BC, List<Case> scope){
        list<Case> updatedListCase = new list<Case>();
        list<Case> listOfIVRCalls = new list<Case>();
         for(Case eachCase : scope){
             //update owner on case
             if (mapKYCRuleEngine!= NULL && mapKYCRuleEngine.size()>0 &&
                 mapKYCRuleEngine.containskey(eachCase.LP_Onboarding_Status__c + eachCase.LP_KYC_State__c)){
                     KYC_Rule_Engine__mdt objKycRuleEngine = mapKYCRuleEngine.get(eachCase.LP_Onboarding_Status__c + eachCase.LP_KYC_State__c);
                     
                     if (objKycRuleEngine != null){
                         
                         KYCRuleEngineCommonCls.RuleEngineWrapper objRuleEngine;
                         objRuleEngine = KYCRuleEngineCommonCls.getOwnerAndCallsInfo(eachCase,objKycRuleengine,'IVR',MapQueuebyID);   
                         eachCase.ownerid = objRuleEngine.ownerId;
                         if (objRuleEngine.isIVREligible ==true){
                             listOfIVRCalls.add(eachCase);
                         }
                         
                         updatedListCase.add(eachCase);
                     }
                 }
         }
         
         //do IVR calls
         if(listOfIVRCalls != NULL && listOfIVRCalls.size()>0){
             string jsonBody = KnowlarityUtility.prepareIVRPayload('IVR_Call',listOfIVRCalls,'KYC');
             HttpResponse res = KnowlarityUtility.sendRequest(jsonBody,'knowlarityIVRCall');
           //  system.debug('res=============='+res.getBody());
         }
         if(updatedListCase != NULL && updatedListCase.size()>0){
             update updatedListCase;
         }
    }
    
    public void finish(Database.BatchableContext BC){
        if(isNextBatch){
            //this batch resets the manual call flag
            ResetManualCallBatch objBatch = new ResetManualCallBatch();
            database.executeBatch(objBatch);
        }
    }
}