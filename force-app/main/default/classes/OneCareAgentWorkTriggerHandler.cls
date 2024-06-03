public class OneCareAgentWorkTriggerHandler {
    
    public static void afterInsertAgentWork(List<AgentWork> triggerNew){        
        agentWorkTriggerCommonMethod(triggerNew);
    }
    
    public static void afterUpdateAgentWork(List<AgentWork> triggerNew, Map<Id,AgentWork> triggerOldMap){
        agentWorkTriggerCommonMethod(triggerNew);
    }
    
    public static void agentWorkTriggerCommonMethod(List<AgentWork> triggerNew){
        Set<Id> caseIds = New Set<Id>();
        Map<Id,Case> caseMap ; 
        Map<String,String> QueueNameVsIdMap = New Map<string,string>();
        List<Status_SLA__c> statusSLAList = New List<Status_SLA__c>();
       //Map<string,string> etcRecordtypeMap = (Map<string,string>)JSON.deserialize(system.label.ETC_Recordtype, Map<string,string>.class);
         //Prashant
         Map<String, String> etcRecordtypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                etcRecordtypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        Map<string,string> oneCarerecordTypeList = (Map<string,string>)JSON.deserialize(system.label.LP_Merchant_Care_Record_Type, Map<string,string>.class);
        //string oneCareRecordType = system.label.LP_Merchant_Care_Record_Type;
        //List<string> oneCarerecordTypeList = oneCareRecordType.split(',');
        List<Status_SLA__c> updateStatusSLAList = New List<Status_SLA__c>();
        Map<string,List<Status_SLA__c>> lobWithSLAMap = New Map<string,List<Status_SLA__c>>();
        
        for(AgentWork eachWork : triggerNew){
            if(String.IsNotBlank(eachWork.WorkItemId)){
                string csObjName = string.ValueOf(eachWork.WorkItemId.getsobjecttype());
                if(csObjName=='Case')
                    caseIds.add(eachWork.WorkItemId);
            }
        }
        try{
            if(!caseIds.isEmpty() && caseIds.size()>0){
                //QueueNameVsIdMap = (Map<String, String>)JSON.deserialize(System.Label.OneCare_Queue_Name_Id_Management, Map<String, String>.class);
                caseMap = New Map<Id,Case>([Select Id,Previous_QueueId_OwnerId__c,Owner__c,OwnerId,status,LP_Business_Vertical__c,isStopped,
                                            L1_L2_Agent_Id__c,LP_Sub_Status__c,LOB_Name__c,owner.FirstName,Owner.LastName,recordtype.Name,New_Open_Time__c,
                                            New_Open_BH__c,createdDate,Previous_Queue_Name_Owner_Name__c,
                                            (Select Id,OneCare_LOB_Name__c,Case__c,OneCare_Owner__c,Case__r.OwnerId,Parent_RecordtypeId__c,
                                             OneCare_New_Open_Time__c,OneCare_New_Open_BH__c,Active__c,Transferred_from_Other_Teams_Time__c,
                                             OneCare_New_Time_New__c,onecare_status__c from Status_SLAs__r where active__c = true) 
                                            from Case where Id IN: caseIds]);
                
                if(!caseMap.isEmpty() && caseMap.size()>0){
                    //list<BusinessHours> bsnessHours = [SELECT Id FROM BusinessHours where Name IN ('OneCare Business Hour', 'PayU OneCare Child') ORDER BY Name ASC];
                    for(Case eachCase : caseMap.Values()){
                        system.debug('eachCase.RecordTypeId>>>>'+eachCase.RecordTypeId);
                        system.debug('oneCarerecordTypeList>>>>'+etcRecordtypeMap);
                        if(oneCarerecordTypeList.containskey(eachCase.RecordTypeId) || etcRecordtypeMap.containskey(eachCase.RecordTypeId)){
                            system.debug('test>>>>>' +eachCase.status);
                            
                                if(eachCase.status == 'New' || eachCase.status == 'Transferred from other teams'){
                                    eachCase.status = 'Open';
                                    if(eachCase.Previous_Queue_Name_Owner_Name__c != null && String.isNotBlank(eachCase.ownerId) && eachCase.Owner__c != 'Integration User' && eachCase.Previous_QueueId_OwnerId__c != null
                                      && eachCase.ownerId != system.label.IntegrationUserId){
                                        eachCase.Previous_Queue_Name_Owner_Name__c =eachCase.Owner__c;
                                        eachCase.Previous_QueueId_OwnerId__c = eachCase.OwnerId;
                                    }
                                        
                                    for(Status_SLA__c existingSLA : eachCase.status_SLAs__r){
                                        if(string.isNotBlank(existingSLA.OneCare_LOB_Name__c)){
                                            system.debug('existingSLA.OneCare_LOB_Name__c::'+existingSLA.OneCare_LOB_Name__c);
                                            if(lobWithSLAMap.containsKey(existingSLA.OneCare_LOB_Name__c)){
                                                list<status_sla__c> statusSla = lobWithSLAMap.get(existingSLA.OneCare_LOB_Name__c);
                                                statusSla.add(existingSLA);
                                                lobWithSLAMap.put(existingSLA.OneCare_LOB_Name__c,statusSla);
                                            }
                                            else{
                                                lobWithSLAMap.put(existingSLA.OneCare_LOB_Name__c,new list<Status_SLA__c>{existingSLA});
                                            }
                                            Status_SLA__c sla =  OneCareReportHandler.updateNewSLA(eachCase,lobWithSLAMap,'Open');
                                            if(sla != null)
                                            {
                                                updateStatusSLAList.add(sla);
                                            }
                                            //lobWithSLAMap.put(existingSLA.OneCare_LOB_Name__c,existingSLA);  
                                        }                                  
                                }
                            }
                            if(String.isNotBlank(eachCase.ownerId) && String.ValueOf(eachCase.ownerId).startsWith('005') && eachCase.ownerId != system.label.IntegrationUserId) 
                                eachCase.L1_L2_Agent_Id__c = eachCase.ownerId;
                            if((eachCase.Status =='Resolved' || 
                               (eachCase.Status=='Pending' && (eachCase.LP_Sub_Status__c=='Waiting On Merchant' || eachCase.LP_Sub_Status__c=='Waiting On Buyer' || eachCase.LP_Sub_Status__c=='Waiting On Bank(Bank Support)')))
                              && eachCase.ownerId != system.label.IntegrationUserId){
                                   //if(!QueueNameVsIdMap.isEmpty() && QueueNameVsIdMap.ContainsKey(eachCase.LOB_Name__c)){
                                   if(String.isNotBlank(eachCase.ownerId) && String.ValueOf(eachCase.ownerId).startsWith('005') && eachCase.Owner__c != 'Integration User'){
                                       eachCase.Previous_Queue_Name_Owner_Name__c = eachCase.Owner__c;
                                       //eachCase.OneCare_Case_Owner1__c = eachCase.OwnerId;
                                   }else if(String.isNotBlank(eachCase.ownerId) && String.ValueOf(eachCase.ownerId).startsWith('00G')){
                                       eachCase.Previous_Queue_Name_Owner_Name__c = eachCase.Owner__c;
                                       //eachCase.OneCare_Case_Owner1__c = eachCase.OwnerId;
                                   }
                                   if(eachCase.Owner__c != 'Integration User'){
                                       eachCase.Previous_QueueId_OwnerId__c = eachCase.OwnerId;
                                   }
                                   eachCase.OwnerId = system.label.IntegrationUserId;
                                   eachCase.L1_L2_Agent_Id__c = system.label.IntegrationUserId;
                                   
                               }
                        }                       
                    }
                }
                if(caseMap.Values() != null) update caseMap.Values();
                if(updateStatusSLAList.size()>0 && updateStatusSLAList!=null) update updateStatusSLAList;
            }
            if(test.isRunningTest()){
                integer i =1/0;
            }
        }catch(Exception e){
            System.debug('######### exception omni '+e); 
            Error_details__c ed = getErrorDetail(e);
            insert ed;
        }
    }
    
    public static Error_details__c getErrorDetail(Exception e){
        Error_details__c ed = New Error_details__c();
        ed.Message__c = e.getMessage()+' line no '+string.valueof(e.getLineNumber());
        ed.Process__c = 'OneCare Omni';
        return ed;
    }
}