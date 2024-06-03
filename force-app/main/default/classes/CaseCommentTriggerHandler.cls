public class CaseCommentTriggerHandler {
    
    
    public static void beforeInsertHandler(list<CaseComment> triggerNew){
        //KYC, COLLECTION,Care: before insert actions
        beforeInsertActions(triggerNew);
    }
    public static void afterInsertHandler(list<CaseComment> triggerNew){
        
        set<id> commentparentId = new set<id>();
        list<case> updatedCaseList = new list<case>();
        for(caseComment eachComment : triggerNew ){
            if(eachComment.CreatedById == Label.IntegrationUserId){
                commentparentId.add(eachComment.ParentId);
            }
        }
        //list<string> statusList = new list<string>{'New','Pending'};
        /*list<case> caseList = [select id, Merchant_Contacted__c,status,IsStopped,LP_Sub_Status__c,Counter__c, Priority  from case where id in :commentparentId];
for(case eachcase : caseList){
if(eachcase.Status != 'New'){
// if(eachCase.Status == 'Pending' ){
if(eachCase.IsStopped == false && (eachCase.LP_Sub_Status__c != 'Waiting On Merchant' || eachCase.LP_Sub_Status__c != 'Waiting On Buyer')){
eachcase.Merchant_Contacted__c = 'Merchant commented on Case';
if(eachCase.Counter__c != null){
eachCase.Counter__c = eachCase.Counter__c +1;}
updatedCaseList.add(eachcase);
}
// }

}
}
system.debug('updatedCaseList==='+updatedCaseList);
upsert updatedCaseList;*/
        OneCareUpdateCaseField(triggerNew);
    }
    public static void beforeUpdateHandler(list<CaseComment> triggerNew, map<Id,CaseComment> TriggeroldMap){}
    public static void afterUpdateHandler(list<CaseComment> triggerNew, map<Id,CaseComment> TriggeroldMap){}
    
    
    public static void beforeInsertActions(list<CaseComment> triggerNew){
        //declare variables
        list<Id> lstcaseId = new list<Id>();
        
        //collect case Id from CaseComment
        for(CaseComment eachComment : triggerNew){
            if(eachComment.parentId != NULL){
                lstcaseId.add(eachComment.parentId);
            }
        } 
        
        if(lstcaseId != NULL && lstcaseId.size()>0){
            //get the recordtype Id of Case
            Id KYCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
            Id CollectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
            Id CareRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
            
            //For KYC And Collection
            //declare local variables
            list<Id> listOfRecordTypeId = new list<Id>();
            listOfRecordTypeId.add(KYCRecordTypeId);
            listOfRecordTypeId.add(CollectionRecordTypeId);
            
            /* list<Case> lstKYCAndCollectionCase = [SELECT id,
ContactId,
LP_Manual_Call_Status__c,
LP_Manual_Call_Sub_Status__c,
LP_Next_Scheduled_Call__c
FROM Case 
WHERE id IN:lstcaseId 
AND recordtypeID IN:listOfRecordTypeId];

if(lstKYCAndCollectionCase != NULL){
createTaskForManualCall(lstKYCAndCollectionCase);
}*/
            
            //For Care
            
        }
    }
    
    public static void OneCareUpdateCaseField(List<CaseComment> triggerNew){
        String integrationUserId = Label.IntegrationUserId;
        List<Status_SLA__c> statusSlaList = new List<Status_SLA__c>();
        List<CaseComment> caseCmtList = new List<CaseComment>();
        List<Case> caseList = new List<Case>();
        Set<string> caseIds = New Set<string>();
        Map<string,Status_SLA__c> lobWithSLAMap = New Map<String,Status_SLA__c>();
        
        for(CaseComment eachCmt: triggerNew){
            if(string.isNotBlank(eachCmt.ParentId)){
                caseIds.add(eachCmt.ParentId);
            }
        }
        
        Map<string,string> merchantRecordTypeMap = (Map<string,string>) JSON.deserialize(system.label.LP_Merchant_Care_Record_Type, Map<string,string>.class);
        
        if(caseIds.size()>0){            
            for(Status_SLA__c existingSLA : [Select Id,OneCare_LOB_Name__c,OneCare_First_Comment_Time__c,Active__c,Case__c,
                                             Overall_OneCare_First_Agent_Res__c,P2P_Transferred__c,
                                             OneCare_New_Time__c,OneCare_New_Open_Time__c,
                                             OneCare_First_Agent_Res__c
                                             from Status_SLA__c where Case__c IN: caseIds 
                                             AND Active__c=true AND Case__r.RecordTypeId IN: merchantRecordTypeMap.keySet()]){
                                                 //system.debug('existingSLA.OneCare_LOB_Name__c=='+existingSLA.OneCare_LOB_Name__c);
                                                 if(string.isNotBlank(existingSLA.OneCare_LOB_Name__c)){
                                                     lobWithSLAMap.put(existingSLA.Case__c,existingSLA);
                                                 }
                                             }
        }
        if(!lobWithSLAMap.isEmpty()){
            List<BusinessHours> bsnessHours = [SELECT Id FROM BusinessHours where Name IN ('OneCare Business Hour', 'PayU OneCare Child') ORDER BY Name ASC];
            for(CaseComment eachComment: triggerNew){
                if(lobWithSLAMap.containskey(eachComment.ParentId) && eachComment.CreatedById != integrationUserId && eachComment.CommentBody.startsWith('Agent: ')){
                    
                    if(lobWithSLAMap.get(eachComment.ParentId).Active__c == true && lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Comment_Time__c ==null){
                        lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Comment_Time__c = system.now();
                        if(lobWithSLAMap.get(eachComment.ParentId).OneCare_LOB_Name__c == 'PayU Money' && lobWithSLAMap.get(eachComment.ParentId).OneCare_New_Open_Time__c !=null && lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Comment_Time__c !=null){
                            lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachComment.ParentId).OneCare_New_Open_Time__c,bsnessHours[0]);
                            lobWithSLAMap.get(eachComment.ParentId).Overall_OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachComment.ParentId).OneCare_New_Time__c,bsnessHours[0]);
                        }else{
                            lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachComment.ParentId).OneCare_New_Open_Time__c,bsnessHours[1]);
                            lobWithSLAMap.get(eachComment.ParentId).Overall_OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachComment.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachComment.ParentId).OneCare_New_Time__c,bsnessHours[1]);
                        }
                    }
                }            
            }
        }
        system.debug('@@@@@ '+lobWithSLAMap);
        if(!lobWithSLAMap.isEmpty() ){
            update lobWithSLAMap.values(); 
        }
    }
    public static Decimal getDurationbetween(Datetime date1, Datetime date2, BusinessHours busnHrs){
        if(date2 != null && date1 != null){
            Long timeDiff = BusinessHours.diff(busnHrs.Id, date2, date1);   
            Long resultInMinutes = timeDiff/60000;
            return resultInMinutes;
        }
        else{
            return 0;
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to create task for manual call
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-FEB-19              Eitika Verma               created
**/ 
    /* public static void createTaskForManualCall(list<Case> listCase){
//declare variables
list<Task> lstTask = new list<Task>();

if(listCase != NULL && listCase.size()>0){
list<string> lstQueue = Label.LP_QueueNames.split(',');
list<GroupMember> lstGrpMember = [Select UserOrGroupId,
GroupId 
From GroupMember 
WHERE UserOrGroupId=:userinfo.getUserId() 
AND GroupId IN (SELECT id 
FROM Group 
WHERE type = 'Queue' 
AND developerName IN:lstQueue)];
if(lstGrpMember != NULL && lstGrpMember.size()>0){
for(Case eachCase : listCase){
Task objTask = new Task();
objTask.OwnerId = userInfo.getUserId();
objTask.WhatId = eachCase.Id;
objTask.WhoId = eachCase.ContactId;
if(eachCase.LP_Next_Scheduled_Call__c != NULL){
objTask.IsReminderSet = true;
objTask.ReminderDateTime = eachCase.LP_Next_Scheduled_Call__c;
objTask.ActivityDate = date.newinstance(eachCase.LP_Next_Scheduled_Call__c.year(), eachCase.LP_Next_Scheduled_Call__c.month(), eachCase.LP_Next_Scheduled_Call__c.day());
objTask.Subject = 'Next Manual Call';
}
else
objTask.Subject = 'Manual Call';
objTask.LP_Next_Scheduled_Call__c = eachCase.LP_Next_Scheduled_Call__c;
objTask.LP_Manual_Call_Status__c = eachCase.LP_Manual_Call_Status__c;
objTask.LP_Manual_Call_Sub_Status__c = eachCase.LP_Manual_Call_Sub_Status__c;
lstTask.add(objTask);
}
}
}

if(lstTask != NULL && lstTask.size()>0)
insert lstTask;
}*/
    
}