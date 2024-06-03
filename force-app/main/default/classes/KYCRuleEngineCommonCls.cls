public class KYCRuleEngineCommonCls {
	/*----------------------------------------------------------------------
        Description:    method to get the ownerid and ivr call happens or not
						on the basis of metadata and case fields
        Inputs:         case, KYC Rule Engine metadata, string type of call ('Manual','IVR') and map contains the queue name and id
        Outputs:        RuleEngineWrapper wrapper instance
        History
        <Date>      <Authors Name>      <Brief Description of Change>
        01-Nov-18   Eitika Verma        Created
    -------------------------------------------------------------------------*/
    public static RuleEngineWrapper getOwnerAndCallsInfo(Case objcase,KYC_Rule_Engine__mdt kycMdt,string typeOfCall,map<string,Id> mapOfQueueNameVsQueueId){
        RuleEngineWrapper objWrapper = new RuleEngineWrapper();
        if(objcase != NULL && objcase.LP_KYC_Last_Modified_Date__c != NULL && kycMdt!= NULL){
            
            //get the difference of current date and last modified date
            integer numberOfDays = objcase.LP_KYC_Last_Modified_Date__c.Date().daysBetween(Date.Today());
            
            //SCENARIO 1: If difference of above date is equal to IVR/Manual frequency then owner id will be set 
            //accordingly on the basis of type of call
            if(numberOfDays == kycMdt.LP_Notification_1__c || numberOfDays == kycMdt.LP_Notification_2__c || 
               numberOfDays == kycMdt.LP_Notification_3__c || numberOfDays == kycMdt.LP_Notification_4__c){
                   if(String.isNotBlank(typeOfCall) && typeOfCall.contains('Manual') && 
                      mapOfQueueNameVsQueueId!= NULL && mapOfQueueNameVsQueueId.size()>0 && 
                      mapOfQueueNameVsQueueId.containsKey('LP_Manual_Call_Queue_KYC')){
                       objWrapper.ownerId = mapOfQueueNameVsQueueId.get('LP_Manual_Call_Queue_KYC');
                       objWrapper.isIVREligible = false;
                   }
                   else if(String.isNotBlank(typeOfCall) && typeOfCall.contains('IVR') && 
                      mapOfQueueNameVsQueueId!= NULL && mapOfQueueNameVsQueueId.size()>0 && 
                      mapOfQueueNameVsQueueId.containsKey('LP_Outbound_IVR_Queue_KYC')){
                       objWrapper.ownerId = mapOfQueueNameVsQueueId.get('LP_Outbound_IVR_Queue_KYC');
                       objWrapper.isIVREligible = true;
                   }
               }//SCENARIO 2: If differene is greater than 4th notification duration then case move to terminate queue
            else if(numberOfDays > kycMdt.LP_Notification_4__c && 
                      mapOfQueueNameVsQueueId!= NULL && mapOfQueueNameVsQueueId.size()>0 && 
                      mapOfQueueNameVsQueueId.containsKey('LP_Terminate_Queue')){
                objWrapper.ownerId = mapOfQueueNameVsQueueId.get('LP_Terminate_Queue');
                objWrapper.isIVREligible = false;
            }
            else{
                //SCENARIO 3: If differene is lie in between frequency then owner will be IVR queue
                if(mapOfQueueNameVsQueueId!= NULL && mapOfQueueNameVsQueueId.size()>0 && 
                      mapOfQueueNameVsQueueId.containsKey('LP_Outbound_IVR_Queue_KYC'))
                objWrapper.ownerId = mapOfQueueNameVsQueueId.get('LP_Outbound_IVR_Queue_KYC');
                objWrapper.isIVREligible = false;
            }
        }
        return objWrapper;
    }
    
    public class RuleEngineWrapper{
        public Id ownerId;
        public boolean isIVREligible;
    }
}