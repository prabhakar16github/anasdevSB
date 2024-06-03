public class OneCareCaseReportBulkUpdate implements database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Batch_Setting__mdt batchSetting = [SELECT MasterLabel,Iteration_Count__c,Record_Limit__c, Where_Clause__c,DateFilter__c, 
                                           Re_Run_Apex_Job__c FROM Batch_Setting__mdt WHERE MasterLabel = 'OneCareCaseReportBulkUpdate'];
        //Schema.SObjectField filterDate = Batch_Setting__mdt.DateFilter__c;
        Map<String,String> OneCarerecordTypeMap =(Map<String, String>)JSON.deserialize(system.label.LP_Merchant_Care_Record_Type, Map<String, String>.class);
        //Map<String,String> ETCrecordTypeMap =(Map<String, String>)JSON.deserialize(system.label.ETC_RecordType, Map<String, String>.class);
        List<String> recordTypeList = new List<String>();
        for(String str: OneCarerecordTypeMap.keySet()){
            recordTypeList.add(str);
        }
        /*for(String str: ETCrecordTypeMap.keySet()){
            recordTypeList.add(str);
        }*/
        string query = 'Select Id,Case__r.RecordTypeId,Case__r.createdDate,Case__r.CaseNumber,Case__r.Id,Case__r.LOB_Name__c,Case__r.Status';
        for(Schema.FieldSetMember fsm :SObjectType.Status_SLA__c.FieldSets.OneCare_Report_Field.getFields()) {
            query += ', ' + fsm.getFieldPath();
        }
        query+= ' from Status_SLA__c ';
        query += String.isNotBlank(batchSetting.Where_Clause__c) ?  batchSetting.Where_Clause__c : '';
        System.debug('query>>>'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Status_SLA__c> slaStatusList){
        System.debug('execute>>>>'+slaStatusList);
        Set<Id> caseIdSet = new Set<Id>();//used
        String integrationUserId = Label.IntegrationUserId;//used
        List<CaseComment> caseCommentList = new List<CaseComment>();//used
        //Map<Id,Status_SLA__c> slaStatusWithCaseMap = New Map<Id,Status_SLA__c>();
        Map<Id,List<CaseHistory>> SlaWithcaseHistoryForStatus = New Map<Id,List<CaseHistory>>();//Used
        Map<Id,List<CaseHistory>> SlaWithcaseHistoryForLOB = New Map<Id,List<CaseHistory>>();//Used
        Map<Id,List<CaseComment>> SlaWithcaseComment = New Map<Id,List<CaseComment>>();//Used
        List<CaseHistory> CaseHistoryList = new List<CaseHistory>();
        List<BusinessHours> bsnessHours = [SELECT Id FROM BusinessHours where Name IN ('OneCare Business Hour', 'PayU OneCare Child') ORDER BY Name ASC];
        
        if(!slaStatusList.isEmpty()){
            for(Status_SLA__c sla : slaStatusList){
                if(string.isNotBlank(sla.Case__c))
                    caseIdSet.add(sla.Case__c);
            }
            if(!caseIdSet.isEmpty()){
                caseCommentList = [Select Id,createdDate,ParentId,CommentBody from CaseComment where ParentId IN:caseIdSet AND CreatedById !=: integrationUserId Order By createddate ASC];
                
                CaseHistoryList = [Select Id,CaseId,OldValue,NewValue,Field,Createddate from CaseHistory where 
                                   CaseId IN: caseIdSet AND (field=:'Status' OR Field =:'LOB_Name__c') ORDER By CreatedDate ASC];
                for(Status_SLA__c sla: slaStatusList){
                    List<CaseHistory> chListForStatus = new List<CaseHistory>();
                    List<CaseHistory> chListForLOB = new List<CaseHistory>();
                    List<CaseComment> cmList = new List<CaseComment>();
                    for(CaseHistory ch: CaseHistoryList){
                        if(sla.Case__r.Id == ch.CaseId){
                            if(ch.Field == 'Status'){
                                chListForStatus.add(ch);
                            }else if(ch.Field == 'LOB_Name__c'){
                                chListForLOB.add(ch);
                            }
                            SlaWithcaseHistoryForStatus.put(sla.Case__r.Id,chListForStatus);
                            SlaWithcaseHistoryForLOB.put(sla.Case__r.Id,chListForLOB);
                        }
                    }
                    for(CaseComment cm: caseCommentList){
                        Id caseId = sla.Case__c;
                        Id parentId = cm.ParentId;
                        if(caseId == parentId){
                            cmList.add(cm);
                            SlaWithcaseComment.put(sla.Case__c,cmList);
                        }
                    }
                }
            }
        }
        System.debug('SlaWithcaseComment>>>>'+SlaWithcaseComment);
        System.debug('SlaWithcaseHistoryForLOB>>>>'+SlaWithcaseHistoryForLOB);
        
        if(!SlaWithcaseHistoryForStatus.isEmpty()){
            System.debug('SlaWithcaseHistoryForStatus>>>>'+SlaWithcaseHistoryForStatus);
            for(Status_SLA__c sla:slaStatusList){
                DateTime dt;
                if(sla.OneCare_Related_Sla_Created_Date__c != null){
                    dt = sla.OneCare_Related_Sla_Created_Date__c;
                }else{
                    dt = System.now();
                }
                List<CaseHistory> case_HistoryForStatus = new List<CaseHistory>();
                if(SlaWithcaseHistoryForStatus.get(sla.Case__c) != null){
                    case_HistoryForStatus = SlaWithcaseHistoryForStatus.get(sla.Case__c);
                }
                
                List<CaseComment> CaseComment_List = new List<CaseComment>();
                if(!SlaWithcaseComment.isEmpty()){
                    if(SlaWithcaseComment.get(sla.Case__c) != null){
                        CaseComment_List = SlaWithcaseComment.get(sla.Case__c);
                    }
                    
                }
                List<CaseHistory> case_HistoryForLOB = new List<CaseHistory>();
                if(!SlaWithcaseHistoryForLOB.isEmpty()){
                    if(SlaWithcaseHistoryForLOB.get(sla.Case__c) != null){
                    case_HistoryForLOB = SlaWithcaseHistoryForLOB.get(sla.Case__c);
                    }
                }
                //System.debug('case_HistoryForStatus>>>>'+case_HistoryForStatus);
                if(case_HistoryForStatus.size() >0){
                    for(CaseHistory ch: case_HistoryForStatus){
                        if(ch.NewValue=='Open' && ch.OldValue=='New'  && (ch.CreatedDate >= sla.CreatedDate && ch.CreatedDate <= dt)){
                            if(sla.OneCare_New_Open_Time__c == null){
                                sla.OneCare_New_Open_Time__c = ch.CreatedDate; 
                            }
                        }
                        if(ch.NewValue=='Resolved' && (ch.CreatedDate >= sla.CreatedDate && ch.CreatedDate <= dt)){
                            sla.OneCare_Resolved_Time__c = ch.CreatedDate;
                            if(sla.OneCare_First_Resolved_TIme__c == null){
                                sla.OneCare_First_Resolved_TIme__c =ch.CreatedDate; 
                            }
                        }
                        if(ch.NewValue=='Closed' && (ch.CreatedDate >= sla.CreatedDate && ch.CreatedDate <= dt)){
                            if(sla.OneCare_Closed_Time__c == null){
                                sla.OneCare_Closed_Time__c =ch.CreatedDate; 
                            }
                        }
                        if(ch.NewValue=='Re-open' && ch.OldValue=='Resolved' && (ch.CreatedDate >= sla.CreatedDate && ch.CreatedDate <= dt)){
                            if(sla.OneCare_Resolved_Reopen_Time__c == null){
                                sla.OneCare_Closed_Time__c =ch.CreatedDate; 
                            }
                        }
                        if(ch.NewValue=='Transferred from other teams' && (ch.CreatedDate >= sla.CreatedDate && ch.CreatedDate <= dt)){
                            if(sla.Transferred_from_Other_Teams_Time__c == null){
                                //Because sla only have either Transfer from other team or new open time 
                                if(sla.OneCare_New_Open_Time__c != null){
                                    sla.Transferred_from_Other_Teams_Time__c = null;
                                }else{
                                    sla.Transferred_from_Other_Teams_Time__c = ch.CreatedDate;
                                }
                                
                            }
                        }
                    }
                }
                for(CaseHistory ch: case_HistoryForLOB){
                    if(ch.CreatedDate >= sla.CreatedDate && ch.CreatedDate <= dt){
                        sla.OneCare_LOB_Name__c = String.valueOf(ch.NewValue);
                    }
                }
                if(!CaseComment_List.isEmpty() ){
                    List<CaseComment> tempCmtList = new List<CaseComment>();
                    for(CaseComment cmt: CaseComment_List){
                        if(cmt.CreatedDate >= sla.CreatedDate && cmt.CreatedDate <= dt){
                            tempCmtList.add(cmt);
                            sla.OneCare_First_Comment_Time__c = tempCmtList[0].createdDate;
                        }
                    }
                }
                
                
                if(sla.Case__r.LOB_Name__c == 'PayU Money'){
                    if(sla.OneCare_New_Open_Time__c != null){
                        sla.OneCare_First_Agent_Res__c = getDurationbetween(sla.OneCare_First_Comment_Time__c, sla.OneCare_New_Open_Time__c, bsnessHours[0]);
                    }else{
                        sla.OneCare_First_Agent_Res__c = getDurationbetween(sla.OneCare_First_Comment_Time__c, sla.Transferred_from_Other_Teams_Time__c, bsnessHours[0]);
                    }
                    sla.Overall_OneCare_First_Agent_Res__c = getDurationbetween(sla.OneCare_First_Comment_Time__c, sla.createdDate, bsnessHours[0]);
                }else{
                    if(sla.OneCare_New_Open_Time__c != null){
                        sla.OneCare_First_Agent_Res__c = getDurationbetween(sla.OneCare_First_Comment_Time__c, sla.OneCare_New_Open_Time__c, bsnessHours[1]);
                    }else{
                        sla.OneCare_First_Agent_Res__c = getDurationbetween(sla.OneCare_First_Comment_Time__c, sla.Transferred_from_Other_Teams_Time__c, bsnessHours[1]);
                    }
                    sla.Overall_OneCare_First_Agent_Res__c = getDurationbetween(sla.OneCare_First_Comment_Time__c, sla.createdDate, bsnessHours[1]);
                }
                
                if(sla.Case__r.LOB_Name__c == 'PayU Money'){
                    if(sla.OneCare_New_Open_Time__c != null){
                        sla.OneCare_Open_Res__c = getDurationbetween(sla.OneCare_Resolved_Time__c, sla.OneCare_New_Open_Time__c, bsnessHours[0]);
                        sla.OneCare_First_Resolution__c = getDurationbetween(sla.OneCare_First_Resolved_TIme__c, sla.OneCare_New_Open_Time__c, bsnessHours[0]);
                    }else{
                        sla.OneCare_Open_Res__c = getDurationbetween(sla.OneCare_Resolved_Time__c, sla.Transferred_from_Other_Teams_Time__c, bsnessHours[0]);
                        sla.OneCare_First_Resolution__c = getDurationbetween(sla.OneCare_First_Resolved_TIme__c, sla.Transferred_from_Other_Teams_Time__c, bsnessHours[0]);
                    }
                    
                }
                else{
                    if(sla.OneCare_New_Open_Time__c != null){
                        sla.OneCare_Open_Res__c = getDurationbetween(sla.OneCare_Resolved_Time__c, sla.OneCare_New_Open_Time__c, bsnessHours[1]);
                        sla.OneCare_First_Resolution__c = getDurationbetween(sla.OneCare_First_Resolved_TIme__c, sla.OneCare_New_Open_Time__c, bsnessHours[1]);
                    }else{
                        sla.OneCare_Open_Res__c = getDurationbetween(sla.OneCare_Resolved_Time__c, sla.Transferred_from_Other_Teams_Time__c, bsnessHours[1]);
                        sla.OneCare_First_Resolution__c = getDurationbetween(sla.OneCare_First_Resolved_TIme__c, sla.Transferred_from_Other_Teams_Time__c, bsnessHours[1]); 
                    }
                    
                }
                System.debug('CaseNumber>>> '+sla.Case__r.CaseNumber);
            }
            update slaStatusList;
            System.debug('slaStatusList>> '+slaStatusList);
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
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}