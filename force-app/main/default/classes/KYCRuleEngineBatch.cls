/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 1/11/2018
    @description: To execute the KYC Rule Engine
*/
public class KYCRuleEngineBatch implements Database.batchable <sObject>,Database.Stateful,Database.AllowsCallouts{
    Map<string, Id> MapQueuebyID = new Map<string, Id>();
    map<string,KYC_Rule_Engine__mdt> mapkYCRuleEngine;
    list<KYC_Rule_Engine__mdt> lstKycRuleEngine = new list<KYC_Rule_Engine__mdt>();
    string strTerminateQueueID ;
    
    /*
    @author: Eitika Verma
	@date : 1/11/2018
    @description: constructor of batch and it prepares the map which contains queues information and KYC rule engine metadata
	*/
    public KYCRuleEngineBatch(){
        mapkYCRuleEngine = new map<string,KYC_Rule_Engine__mdt>();
        list<String> lstQueue = new list<string>();
        lstQueue.add('LP_Outbound_IVR_Queue_KYC');
        lstQueue.add('LP_Manual_Call_Queue_KYC');
        lstQueue.add('LP_Terminate_Queue');
        
        MapQueuebyID = systemutility.getQueuesInfo(lstQueue);
        
        if (MapQueuebyID.containskey('LP_Terminate_Queue')){
            strTerminateQueueID = MapQueuebyID.get('LP_Terminate_Queue');
        }
        
        lstKycRuleEngine = SystemUtility.getAllFieldsOfObject(null,'KYC_Rule_Engine__mdt',null);
        if (!lstKycRuleEngine.isempty()){
            for (KYC_Rule_Engine__mdt eachKycRuleEngine:lstKycRuleEngine){
                mapkYCRuleEngine.put(eachKycRuleEngine.LP_Onboarding_Status__c +eachKycRuleEngine.LP_KYC_State__c,eachKycRuleEngine);
			}
        }
    }
    
    /*
    @author: Eitika Verma
	@date : 1/11/2018
    @description: start method of batch and it get all the records of case on which recordtype is KYC and 
					owner is not equal to Terminate Queue
	*/
	public Database.QueryLocator start(Database.BatchableContext BC){
        string strquery = 'SELECT id,LP_IVR_Call__c,LP_KYC_Last_Modified_Date__c,LP_Notification_1__c,LP_Notification_2__c,LP_Notification_3__c';
        strquery +=  ',LP_Notification_4__c,LP_Manual_Call__c,LP_Type_of_IVR__c,LP_KYC_State__c,LP_Onboarding_Status__c FROM Case WHERE recordtype.developername = \'KYC\' AND ownerid != \'' + strTerminateQueueID + '\'';
        return Database.getQueryLocator(strquery);
	}
    
    public void execute(Database.BatchableContext BC, List<Case> scope){
        list<Case> updatedListCase = new list<Case>();
        for(Case eachCase : scope){
            //update owner on case
            if (mapkYCRuleEngine!= NULL && mapkYCRuleEngine.size()>0 && 
                mapkYCRuleEngine.containskey(eachCase.LP_Onboarding_Status__c + eachCase.LP_KYC_State__c)){
                KYC_Rule_Engine__mdt objKycRuleEngine = mapkYCRuleEngine.get(eachCase.LP_Onboarding_Status__c + eachCase.LP_KYC_State__c);
                
                if (objKycRuleengine != null){
                    eachCase.LP_Type_of_IVR__c  =  objKycRuleEngine.LP_Type_of_IVR__c;
                    eachCase.LP_Notification_1__c  =  objKycRuleEngine.LP_Notification_1__c;
                    eachCase.LP_Notification_2__c  =  objKycRuleEngine.LP_Notification_2__c;
                    eachCase.LP_Notification_3__c  =  objKycRuleEngine.LP_Notification_3__c;
                    eachCase.LP_Notification_4__c  =  objKycRuleEngine.LP_Notification_4__c;
                    eachCase.LP_Status_Priority_Order__c  =  objKycRuleEngine.LP_Call_Priority__c;
                    eachCase.LP_Manual_Call__c = objKycRuleEngine.LP_Manual_Call__c ;
                    eachCase.LP_IVR_Call__c = objKycRuleEngine.LP_IVR_Call__c ;
                    
                    if (objKycRuleEngine.LP_Manual_Call__c!= NULL && objKycRuleEngine.LP_Manual_Call__c > 0) {
                        KYCRuleEngineCommonCls.RuleEngineWrapper objRuleEngine = KYCRuleEngineCommonCls.getOwnerAndCallsInfo(eachCase,objKycRuleEngine,'Manual',MapQueuebyID);   
                        eachCase.ownerid = objRuleEngine.ownerId;
                        
                    }
                    else if(objKycRuleEngine.LP_Manual_Call__c != NULL && objKycRuleEngine.LP_Manual_Call__c == 0 && objKycRuleEngine.LP_IVR_Call__c != NULL && 
                            objKycRuleEngine.LP_IVR_Call__c > 0 ){
                        	KYCRuleEngineCommonCls.RuleEngineWrapper objRuleEngine = KYCRuleEngineCommonCls.getOwnerAndCallsInfo(eachCase,objKycRuleEngine,'IVR',MapQueuebyID);   
                            eachCase.ownerid = objRuleEngine.ownerId;
                    }
                    updatedListCase.add(eachCase);
                }
            }
        }
        
        system.debug('updatedListCase==========='+updatedListCase);
        if(updatedListCase != NULL && updatedListCase.size()>0){
            update updatedListCase;
        }
            
		
	}
    
    public void finish(Database.BatchableContext BC){
        //call out for IVR
        KYCIVRCallBatch objBatch = new KYCIVRCallBatch(false);
        database.executeBatch(objBatch);
      
	}
    
}