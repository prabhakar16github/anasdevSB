/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       trigger handler for the apex trigger
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
public class AgentWorkTriggerHandler {
    public static void afterInsertHandler(list<AgentWork> triggerNew){
        updateCaseStatusToOpen(triggerNew);
    }
    
    public static void afterUpdateHandler(list<AgentWork> triggerNew,map<ID,AgentWork> maptriggerold){
        updateCaseStatusToOpen(triggerNew);
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       if status is new in old case it will update the the status=Open
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
   public static void updateCaseStatusToOpen(list<AgentWork> triggerNew){
        set<Id> setOfCaseId = new set<Id>();
        list<Case> lstCase = new list<Case>();
        for(AgentWork eachWork : triggerNew){
            if(eachWork.WorkItemId != NULL){
                setOfCaseId.add(eachWork.WorkItemId);
            }
        }
        system.debug('setOfCaseId====='+setOfCaseId);
        if(setOfCaseId != NULL && setOfCaseId.size()>0){
            for(Case eachCase : [SELECT id,status,LP_Business_Vertical__c,isStopped,ownerId,recordtype.Name,L1_L2_Agent_Id__c FROM Case WHERE Id IN:setOfCaseId 
                                 AND (recordtype.Name IN ('KYC','Care','ChildCase','MerchantCare','MerchantChildCase','BuyerCare','BuyerCareChild'))
                                 ]){ 
                system.debug('eachCase.ownerId========='+eachCase.ownerId);
                eachCase.ownerId = eachCase.ownerId;
                if(eachCase.status == 'New' || eachCase.Status=='IN_PROGRESS')
                  eachCase.status = 'Open';
                if((eachCase.recordtype.Name == 'Care' || eachCase.recordtype.Name == 'MerchantCare' 
                    || eachCase.recordtype.Name == 'MerchantChildCase' || eachCase.recordtype.Name == 'BuyerCare' 
                   || eachCase.recordtype.Name == 'BuyerCareChild') 
                    && eachCase.ownerId != NULL 
                   && String.ValueOf(eachCase.ownerId).startsWith('005'))
                  eachCase.L1_L2_Agent_Id__c = eachCase.ownerId;
                lstCase.add(eachCase);
            }
        }
        
        if(lstCase != NULL && lstCase.size()>0)
            update lstCase;
    }
}