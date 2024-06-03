public class oneCareEmailToCaseTriggerHandler {
    
    public static void beforeInsertHandler(list<EmailMessage> triggerNew){
        Map<Id,emailMessage> MapOfIncomingCaseIdEmailMessage = New Map<Id,emailMessage>();
        Set<string> emailMsgSubject = New Set<string>();
        Map<string,EmailMessage> eMessageWithAddressMap = New Map<string,EmailMessage>();
        set<string> owdEmailIds = New Set<string>();
        Map<String,Case> caseWithSuppliedEmailMap = New Map<String,Case>();
        List<EmailMessage> eMessageList = New List<EmailMessage>();
        Map<Id,emailMessage>  eMessageWithId = new Map<Id,emailMessage> ();
        
        for(OrgWideEmailAddress owdAddress: [select id, Address from OrgWideEmailAddress]){
            owdEmailIds.add(owdAddress.Address);
        }
       
        for(EmailMessage eachMessage : triggerNew){
          
            if(eachMessage.ParentId != NULL && String.valueOf(eachMessage.ParentId).StartsWith('500')){
                if(eachMessage.Incoming && eachMessage.Subject != NULL && string.isNotBlank(eachMessage.ToAddress)
                   && !owdEmailIds.contains(eachMessage.FromAddress)){
                       MapOfIncomingCaseIdEmailMessage.put(eachMessage.ParentId,eachMessage); 
                       eMessageWithAddressMap.put(eachMessage.FromAddress,eachMessage);
                       //eMessageWithAddressMap.put(eachMessage.CcAddress,eachMessage);
                   }
            }
             
        }
       
        if(!MapOfIncomingCaseIdEmailMessage.isEmpty()) beforeInsertCheckDuplicateEmails(triggerNew,MapOfIncomingCaseIdEmailMessage,eMessageWithAddressMap);
        
        
    }
    
    public static void afterInsertHandler(List<EmailMessage> triggerNew){
        List<Case> updatedCaseList = New List<Case>();
        List<Case> newCaseList = New List<Case>();
        set<string> owdEmailIds = New Set<string>();
        Map<String,Case> caseWithSuppliedEmailMap = New Map<String,Case>();
        Map<string,EmailMessage> eMessageWithAddressMap = New Map<string,EmailMessage>();
        Map<string,EmailMessage> eMessageWithCcAddressMap = New Map<string,EmailMessage>();
        //Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
         //Prashant
         Map<String, String> etcRecIdVsRecTypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                etcRecIdVsRecTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        list<case> updatednewCaseList = new list<case>();
        List<Case> newClosedCaseList = new List<Case>();
        Map<string,EmailMessage> parentIdEmailMessagemap = new Map<string,EmailMessage>();   
        Map<string,EmailMessage> clonedEmailMessageMap = new Map<string,EmailMessage>();
        Map<string,emailMessage> caseIdEmailMsgMap = new map<string,emailMessage>();
        set<string> caseIdset = new set<string>();
        MAp<string,string> mapParentCaseEMsgId = new map<string,string>();
        
        
        for(OrgWideEmailAddress owdAddress: [select id, Address from OrgWideEmailAddress]){
            owdEmailIds.add(owdAddress.Address);
        }
        
        for(EmailMessage eachMessage : triggerNew){ 
            
            if(!owdEmailIds.contains(eachMessage.FromAddress) && eachMessage.Incoming 
               && string.isNotBlank(eachMessage.Subject) && string.isNotBlank(eachMessage.ToAddress)
               && (eachMessage.Subject.contains('Re: ') || eachMessage.Subject.contains('RE: ') || eachMessage.Subject.contains('FW: '))){
                   system.debug('@@@@@@ eachMessage after '+eachMessage.FromAddress);
                   eMessageWithAddressMap.put(eachMessage.FromAddress,eachMessage); 
                   caseIdEmailMsgMap.put(eachMessage.ParentId, eachMessage);
               }
            
            if(!owdEmailIds.contains(eachMessage.FromAddress) && eachMessage.Incoming 
               && string.isNotBlank(eachMessage.Subject) && string.isNotBlank(eachMessage.CCAddress) && string.isNotBlank(eachMessage.ParentId)){
                   system.debug('@@@@@@ eachMessage after '+eachMessage.FromAddress);
                   eMessageWithCcAddressMap.put(eachMessage.CcAddress,eachMessage);
                   caseIdEmailMsgMap.put(eachMessage.ParentId, eachMessage);
               }
            
            if(!owdEmailIds.contains(eachMessage.FromAddress) && !eachMessage.Incoming )
            {
                caseIdset.add(eachMessage.ParentId);
            }
            
        }
        
        /*List<Case> caseList = [Select Id,suppliedEmail,subject,status,platform_e__c from Case where (suppliedEmail IN:eMessageWithAddressMap.keySet() OR Email_Cc_Address__c IN:eMessageWithCcAddressMap.keySet() OR suppliedEmail IN:eMessageWithCcAddressMap.keySet())
AND RecordTypeId IN: etcRecIdVsRecTypeMap.keyset()];*/
        
        List<Case> ParentCaseList = [select Id,suppliedEmail,subject,status,platform_e__c from case where (id IN :caseIdEmailMsgMap.keySet() OR id IN :caseIdset) AND RecordTypeId IN: etcRecIdVsRecTypeMap.keyset()];
        
        
        for(EmailMessage eachMessage : triggerNew){
            if(!owdEmailIds.contains(eachMessage.FromAddress) && eachMessage.Incoming && string.isNotBlank(eachMessage.Subject) 
               && string.isNotBlank(eachMessage.ToAddress) && (eachMessage.Subject.contains('Re: ') || eachMessage.Subject.contains('RE: ') || eachMessage.Subject.contains('FW: '))){
                   string modifiedsubject = eachMessage.Subject.replaceAll('(?:\\[?(?:[Ff][Ww][Dd]?|[Rr][Ee])(?:\\s*[:;-]+\\s*\\]?))+', '');
                   
                   if(ParentCaseList.size() > 0 && ParentCaseList != null){
                       for(case closedcase : ParentCaseList){
                           if(eachMessage.ParentId == closedcase.Id && closedcase.platform_e__c != 'Email' && closedcase.status == 'Closed' && eachMessage.Incoming){
                               parentIdEmailMessagemap.put(closedcase.id,eachMessage);
                           }
                       } 
                   }               
               }
            
            for(emailMessage eachMsg : triggerNew){
                if(ParentCaseList.size() > 0 && ParentCaseList != null && !eachMsg.Incoming)
                    for(case outgoingEMsgCase : ParentCaseList){
                        if(eachMsg.ParentId == outgoingEMsgCase.Id){
                            mapParentCaseEMsgId.put(eachMsg.Id,outgoingEMsgCase.Status);
                        } 
                    }
            }
            
            if(!mapParentCaseEMsgId.isEmpty()){
                updateStatusSla(mapParentCaseEMsgId,triggerNew);
            }
            if(!owdEmailIds.contains(eachMessage.FromAddress) && eachMessage.Incoming && string.isNotBlank(eachMessage.Subject) 
               && string.isNotBlank(eachMessage.CcAddress) && string.isNotBlank(eachMessage.ParentId)){
                   
                   Case newCase = New Case();
                   newCase.Id = eachMessage.ParentId;
                   //newCase.Email_Cc_Address__c = eachMessage.CcAddress;
                   updatedCaseList.add(newCase);
                   system.debug('updatedCaseList in check=='+updatedCaseList);
                   
               }
            /*if(!owdEmailIds.contains(eachMessage.FromAddress) && eachMessage.Incoming && string.isNotBlank(eachMessage.Subject) 
&& string.isNotBlank(eachMessage.ToAddress) && string.isNotBlank(eachMessage.ParentId)){
newCaseList = updateBusinessVertical(eachMessage);
}*/
            
        }
        
        system.debug('parentIdEmailMessagemap==='+parentIdEmailMessagemap);
        if(!parentIdEmailMessagemap.isEmpty()){
            
            Etc_Queue_Membership__mdt etcQueueMembership = [SELECT Id, Queue_developer_Name_versus_Queue_Name__c, Queue_ID_Name_Map__c
                                                            FROM Etc_Queue_Membership__mdt ];
            Map<string,string> etcnewQueueNameWithId = (Map<string,string>)JSON.deserialize(etcQueueMembership.Queue_ID_Name_Map__c,Map<string,string>.class);
            Map<string,string> etcnewQueueNameWithIdold = (Map<string,string>)JSON.deserialize(system.label.ETC_Queue_Name_Id_Management,Map<string,string>.class);
            
            list<case> parentCaseLst  = [select Id,subject,SuppliedEmail,status,ContactId,Previous_QueueId_OwnerId__c,OwnerId,AccountId,Origin,RecordTypeId,platform_e__c from Case where Id IN :parentIdEmailMessagemap.keySet()];
            list<case> existingChildCase = [select id,parentID,status from case where parentID in :parentCaseLst and status != 'Closed'];
            
            if(existingChildCase.isEmpty()){
                for(EmailMessage em : parentIdEmailMessagemap.Values()){
                    for(case parentCase : parentCaseLst){
                        
                        case newCase = new Case();
                        newCase.ParentId = em.ParentId;
                        if(string.isNotBlank(etcnewQueueNameWithId.get(parentCase.platform_e__c))){
                            if(parentCase.platform_e__c == 'PayU_Care' || parentCase.platform_e__c == 'PayU Care'){
                                newCase.OwnerId = etcnewQueueNameWithId.get('ENT_Care_Team');
                            }
                            else{
                                newCase.OwnerId = etcnewQueueNameWithId.get(parentCase.platform_e__c);
                            }
                        }
                        else if(string.isNotBlank(etcnewQueueNameWithIdold.get(parentCase.platform_e__c))){
                            if(parentCase.platform_e__c == 'PayU_Care' || parentCase.platform_e__c == 'PayU Care'){
                                newCase.OwnerId = etcnewQueueNameWithIdold.get('ENT_Care_Team');
                            }
                            else{
                                newCase.OwnerId = etcnewQueueNameWithIdold.get(parentCase.platform_e__c);
                            }
                        }
                        newCase.Status = 'New';
                        //newCase.L1_L2_Agent_Id__c = parentCase.Previous_QueueId_OwnerId__c;
                        newCase.RecordTypeId = parentCase.RecordTypeId;
                        newCase.Subject = em.Subject;
                        newCase.SuppliedEmail = parentCase.SuppliedEmail;
                        if(parentCase.Platform_e__c == 'PayU_Care' || parentCase.platform_e__c == 'PayU Care') {newCase.Origin = 'ENT_Care_Team';}
                        else{
                            newCase.Origin = parentCase.Platform_e__c;}
                        newClosedCaseList.add(newCase);
                    }
                }
                
                if(!newClosedCaseList.isEmpty()) insert newClosedCaseList;
                for(EmailMessage emsg : parentIdEmailMessagemap.Values()){
                    for(case newCase1 : newClosedCaseList){
                        if(emsg.parentId == newCase1.parentId){
                            EmailMessage newEmaiMsg =  emsg.clone(false,true);
                            newEmaiMsg.ParentId = newCase1.id;
                            clonedEmailMessageMap.put(emsg.id,newEmaiMsg);
                        }
                    }
                }
            }
            else{
                for(EmailMessage em : parentIdEmailMessagemap.Values()){
                    for(case exchild : existingChildCase){
                        if(em.ParentId == exchild.ParentId){
                            EmailMessage newEmaiMsg =  em.clone(false,true);
                            newEmaiMsg.ParentId = exchild.id;
                            clonedEmailMessageMap.put(em.id,newEmaiMsg);
                        }
                    }
                }
            }
        }
        
        if(!clonedEmailMessageMap.isEmpty()) insert clonedEmailMessageMap.Values();
        
        
        if(updatedCaseList.size()>0) {
            system.debug('@@@@ updatedCaseList '+updatedCaseList);
            for(case updCase : updatedCaseList){
                if(updCase.Status == 'New'){
                    updatednewCaseList.add(updCase);
                }
            }
            update updatednewCaseList;
        }
        if(newCaseList.size()>0) update newCaseList;        
    }
    
    public static void updateCaseStatus(list<EmailMessage> triggerNew,Map<Id,emailMessage> MapOfIncomingCaseIdEmailMessage,Map<id,string> casesToBeClosed){
       // Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
        //Prashant
         Map<String, String> etcRecIdVsRecTypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                etcRecIdVsRecTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        List<Case> updatedCaseList = New List<Case>();
        string notCreateChildValue = Label.SubStatusNotCreateChild;
        List<string> subStatusValues = notCreateChildValue.split(',');
        Integer maxSize = 255; 
        string ccAddress;
        string toAddress;
        Id ETCBankSuptRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Bank Support').getRecordTypeId();
        
        System.debug('incoming parent Id '+MapOfIncomingCaseIdEmailMessage.keySet());
        if(!MapOfIncomingCaseIdEmailMessage.isEmpty()){
            for(Case eachCase : [SELECT id,status,ContactId,LP_Customer_Response_Count__c,IsStopped,Counter__c,ParentId,
                                 Contact.Email,Priority,LP_Sub_Status__c,Previous_QueueId_OwnerId__c,OwnerId,AccountId,Origin,RecordTypeId,Subject,
                                 Email_Cc_Address__c,toAddress__c,Merchant_Bank_Contacted__c,IsAutoResSent__c FROM Case WHERE Id IN:MapOfIncomingCaseIdEmailMessage.keySet()
                                 AND RecordTypeId IN: etcRecIdVsRecTypeMap.keySet()
                                ]){  
                                    emailMessage em = MapOfIncomingCaseIdEmailMessage.get(eachCase.Id);
                                    system.debug('em.fromaddress'+em.FromAddress);
                                    system.debug('eachCase.Contact.Email'+eachCase.Contact.Email);
                                    if(string.isNotBlank(em.CcAddress)){
                                        if(em.CcAddress.length() > maxSize )
                                        {
                                            ccAddress = em.CcAddress.substring(0, maxSize);
                                            eachCase.Email_Cc_Address__c = ccAddress;
                                        }
                                        else{
                                            eachCase.Email_Cc_Address__c = em.CcAddress;
                                        }
                                    }
                                    
                                    if(string.isNotBlank(em.ToAddress)){
                                        if(em.ToAddress.length() > maxSize )
                                        {
                                            toAddress = em.ToAddress.substring(0, maxSize);
                                            eachCase.toAddress__c = toAddress;
                                        }
                                        else{
                                            eachCase.toAddress__c = em.toAddress;
                                        }
                                    }
                                    
                                    if(eachCase.status == 'Resolved'){
                                        eachCase.status = 'Re-Open';
                                        if(string.isNotBlank(eachCase.Previous_QueueId_OwnerId__c)) {
                                            eachCase.OwnerId = eachCase.Previous_QueueId_OwnerId__c;
                                            eachCase.L1_L2_Agent_Id__c = eachCase.Previous_QueueId_OwnerId__c;
                                        }
                                    }
                                    
                                    else if(eachCase.status == 'Pending' && eachCase.LP_Sub_Status__c=='Waiting On Merchant' ){
                                        if(eachCase.IsAutoResSent__c != true)
                                            eachCase.IsAutoResSent__c = true;
                                        eachCase.status = 'Response received from merchant';
                                        eachcase.IsStopped=false;
                                        
                                        eachCase.LP_Sub_Status__c='';
                                        if(string.isNotBlank(eachCase.Previous_QueueId_OwnerId__c)) {
                                            eachCase.OwnerId = eachCase.Previous_QueueId_OwnerId__c;
                                            eachCase.L1_L2_Agent_Id__c = eachCase.Previous_QueueId_OwnerId__c;
                                        }
                                        
                                    } 
                                    else if(eachCase.status == 'Pending' && eachCase.LP_Sub_Status__c=='Waiting On Buyer' ){
                                        eachCase.status = 'Response received from buyer';
                                        eachcase.IsStopped=false;
                                        eachCase.LP_Sub_Status__c='';
                                        if(string.isNotBlank(eachCase.Previous_QueueId_OwnerId__c)){
                                            eachCase.OwnerId = eachCase.Previous_QueueId_OwnerId__c;
                                            eachCase.L1_L2_Agent_Id__c = eachCase.Previous_QueueId_OwnerId__c;
                                        }
                                    }
                                    
                                    else if(eachCase.status == 'Pending' && subStatusValues.contains(eachCase.LP_Sub_Status__c) ){
                                        eachCase.status = 'Response received';
                                        eachcase.IsStopped=false;
                                        eachCase.LP_Sub_Status__c='';
                                    }
                                    
                                    else if(eachCase.status == 'Pending' && eachCase.LP_Sub_Status__c == 'Waiting On PUM-Farming' && eachCase.RecordTypeId == ETCBankSuptRecordTypeId ){
                                        eachCase.Merchant_Bank_Contacted__c  = 'Merchant/Bank Contacted';
                                    }
                                    
                                    else if(eachCase.status == 'Pending' && eachCase.LP_Sub_Status__c=='Waiting On Bank(Bank Support)' && eachCase.RecordTypeId == ETCBankSuptRecordTypeId){
                                        eachCase.status = 'Response received';
                                        eachcase.IsStopped=false;
                                        eachCase.LP_Sub_Status__c='';
                                        if(string.isNotBlank(eachCase.Previous_QueueId_OwnerId__c)){
                                            eachCase.OwnerId = eachCase.Previous_QueueId_OwnerId__c;
                                            eachCase.L1_L2_Agent_Id__c = eachCase.Previous_QueueId_OwnerId__c;
                                        }
                                    }
                                    else if(eachCase.Status == 'New' && !casesToBeClosed.isEmpty() && em.Incoming){
                                        if(casesToBeClosed.containsKey(eachCase.Id))
                                        {
                                            eachCase.Status = 'Closed';
                                            eachCase.OwnerId = system.label.IntegrationUserId ;
                                            eachCase.ParentId = casesToBeClosed.get(eachCase.Id);
                                        }
                                        
                                    }
                                    
                                    system.debug('eachCase.status=='+eachCase.status);
                                    
                                    updatedCaseList.add(eachCase);
                                }
            
            System.debug('Case list updt '+updatedCaseList);
            if(updatedCaseList.size()>0) update updatedCaseList;
            
        }
    }
    
    //to update Status Sla fields
    public static void updateStatusSla(map<string,string> parentCases, list<emailMessage> triggerNew){
        
        String integrationUserId = Label.IntegrationUserId;
        List<Status_SLA__c> statusSlaList = new List<Status_SLA__c>();
        List<emailMessage> eMsgList = new List<emailMessage>();
        List<Case> caseList = new List<Case>();
        Set<string> caseIds = New Set<string>();
        Map<string,Status_SLA__c> lobWithSLAMap = New Map<String,Status_SLA__c>();
        
        //Map<string,string> ETCRecordTypeMap = (Map<string,string>) JSON.deserialize(system.label.ETC_RecordType, Map<string,string>.class);
         //Prashant
         Map<String, String> ETCRecordTypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                ETCRecordTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        
        for(emailMessage eachEmsg : triggerNew){
            caseIds.add(eachEmsg.parentId);
        }
        
        if(caseIds.size() >0){
            for(Status_SLA__c existingSLA : [Select Id,OneCare_LOB_Name__c,OneCare_First_Comment_Time__c,Active__c,Case__c,
                                             Overall_OneCare_First_Agent_Res__c,P2P_Transferred__c,
                                             OneCare_New_Time__c,OneCare_New_Open_Time__c,First_Agent_Response_Time__c,
                                             OneCare_First_Agent_Res__c,First_Customer_Response_Time__c, Transferred_from_Other_Teams_Time__c 
                                             from Status_SLA__c where Case__c IN: caseIds
                                             AND Active__c=true AND (Case__r.RecordTypeId IN: ETCRecordTypeMap.keySet())]){
                                                 system.debug('existingSLA.OneCare_LOB_Name__c=='+existingSLA.OneCare_LOB_Name__c);
                                                 if(string.isNotBlank(existingSLA.OneCare_LOB_Name__c)){
                                                     lobWithSLAMap.put(existingSLA.Case__c,existingSLA);
                                                 }
                                             }
        }
        
        if(!lobWithSLAMap.isEmpty()){
            system.debug('enter lob map');
            
            Map<string,string> businessHourNameIdmap = (map<string,string>)JSON.deserialize(System.Label.BusinessHourNameIdMap,map<string,string>.class);
            String onecareBHId = businessHourNameIdmap.get('OneCare Business Hour');
            String payuOnecareChildBHId = businessHourNameIdmap.get('PayU OneCare Child');
            
            list<string> listOneCareLobs = new list<string>{'PayU_Care','Key_Support','Biz_Airtel_Support','citrus_wallet','Bank_Support','Merchant_Support','PayU_Contact'};
                for(EmailMessage eachMessage: triggerNew){
                    if(lobWithSLAMap.containskey(eachMessage.ParentId) && !eachMessage.Incoming && eachMessage.Status != 'Draft'){
                        system.debug('enter email message loop');
                        if(lobWithSLAMap.get(eachMessage.ParentId).Active__c == true && lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c ==null && 
                           lobWithSLAMap.get(eachMessage.ParentId).First_Agent_Response_Time__c ==null){
                               
                               lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c = system.now();
                               lobWithSLAMap.get(eachMessage.ParentId).First_Agent_Response_Time__c =system.now();
                               
                               if(listOneCareLobs.contains(lobWithSLAMap.get(eachMessage.ParentId).OneCare_LOB_Name__c) && lobWithSLAMap.get(eachMessage.ParentId).OneCare_New_Open_Time__c !=null && lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c !=null){
                                   lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachMessage.ParentId).OneCare_New_Open_Time__c,onecareBHId);
                                   lobWithSLAMap.get(eachMessage.ParentId).Overall_OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachMessage.ParentId).OneCare_New_Time__c,onecareBHId);
                               }
                               else if(listOneCareLobs.contains(lobWithSLAMap.get(eachMessage.ParentId).OneCare_LOB_Name__c) && lobWithSLAMap.get(eachMessage.ParentId).Transferred_from_Other_Teams_Time__c !=null && lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c !=null){
                                   lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachMessage.ParentId).Transferred_from_Other_Teams_Time__c,onecareBHId);
                                   lobWithSLAMap.get(eachMessage.ParentId).Overall_OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachMessage.ParentId).Transferred_from_Other_Teams_Time__c,onecareBHId);
                               }
                               else{
                                   lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachMessage.ParentId).OneCare_New_Open_Time__c,payuOnecareChildBHId);
                                   lobWithSLAMap.get(eachMessage.ParentId).Overall_OneCare_First_Agent_Res__c = getDurationbetween(lobWithSLAMap.get(eachMessage.ParentId).OneCare_First_Comment_Time__c,lobWithSLAMap.get(eachMessage.ParentId).OneCare_New_Time__c,payuOnecareChildBHId);
                               }
                           }
                    }
                    else if(lobWithSLAMap.containskey(eachMessage.ParentId) && eachMessage.Incoming){
                        if(lobWithSLAMap.get(eachMessage.ParentId).Active__c == true && lobWithSLAMap.get(eachMessage.ParentId).First_Customer_Response_Time__c ==null 
                           && (parentCases.get(eachMessage.Id) == 'Response received from merchant' || parentCases.get(eachMessage.Id) == 'Response received from Buyer') ){
                               lobWithSLAMap.get(eachMessage.ParentId).First_Customer_Response_Time__c = system.now();
                           }
                    }
                }
        }
        system.debug('@@@@@ '+lobWithSLAMap);
        if(!lobWithSLAMap.isEmpty() ){
            update lobWithSLAMap.values(); 
        }     
    }
    
    public static Decimal getDurationbetween(Datetime date1, Datetime date2, string busnHrs){
        if(date2 != null && date1 != null){
            Long timeDiff = BusinessHours.diff(busnHrs, date2, date1);   
            Long resultInMinutes = timeDiff/60000;
            return resultInMinutes;
        }
        else{
            return 0;
        }
    }
    
    
    public static void beforeInsertCheckDuplicateEmails(list<emailMessage> triggerNew,Map<Id,EmailMessage> MapOfIncomingCaseIdEmailMessage, Map<string,EmailMessage> eMessageWithAddressMap){
        
        Map<Id,string> casesToBeClosed = new map<id,string>();
        Map<Id,case> mapNewCaseswithId = new map<id,case>();
        //Map<string,string> caseIdWithRecTypeId = new Map<string,string>();
        set<string> owdEmailIds = New Set<string>();
        //Map<string,string> etcRecIdVsRecTypeMap = (map<string,string>)JSON.deserialize(System.Label.ETC_RecordType,map<string,string>.class);
         //Prashant
         Map<String, String> etcRecIdVsRecTypeMap = new Map<string,string>(); 
         for(ETC_RecordType_Metadata__mdt  recordtypeMetadata : [Select id,Recordtype_Id_Name_Map__c FROM ETC_RecordType_Metadata__mdt order by label]){  
                etcRecIdVsRecTypeMap = (Map<String, String>)JSON.deserialize(recordtypeMetadata.Recordtype_Id_Name_Map__c, Map<String, String>.class);  
         }
        //List<Case> caseList = New List<Case>();
        List<Case> caseList = [Select Id,casenumber,suppliedEmail,subject,status,ContactId,LP_Customer_Response_Count__c,IsStopped,Counter__c,
                               Contact.Email,Priority,LP_Sub_Status__c,Previous_QueueId_OwnerId__c,OwnerId,AccountId,Origin,RecordTypeId,
                               Email_Cc_Address__c,toAddress__c,Merchant_Bank_Contacted__c from Case where (suppliedEmail IN:eMessageWithAddressMap.keySet()
                                                                                                            OR Email_Cc_Address__c IN :eMessageWithAddressMap.keySet() OR toAddress__c IN :eMessageWithAddressMap.keySet())
                               AND RecordTypeId IN: etcRecIdVsRecTypeMap.keyset() AND Status!='Closed' 
                               AND ParentId=null Order By LastmodifiedDate desc];
        
        system.debug('eMessageWithAddressMap.values()=='+eMessageWithAddressMap.values());
        
        for(EmailMessage eachMessage : eMessageWithAddressMap.values()){
            string modifiedsubject = string.isNotBlank(eachMessage.Subject) ? eachMessage.Subject.replaceAll('(?:\\[?(?:[Ff][Ww][Dd]?|[Rr][Ee])(?:\\s*[:;-]+\\s*\\]?))+', '') : '';
            
            if(caseList.size()>0){
                for(Case csObj : caseList){
                    //system.debug('csObj.Subject== '+ csObj.Subject +'csObj.suppliedEmail== '+ csObj.suppliedEmail+'csObj.Email_Cc_Address__c=='+csObj.Email_Cc_Address__c);
                     
                    string modifiedCSObjsubject = string.isNotBlank(csObj.Subject) ? csObj.Subject.replaceAll('(?:\\[?(?:[Ff][Ww][Dd]?|[Rr][Ee])(?:\\s*[:;-]+\\s*\\]?))+', '') : '';
                    if(eachMessage.FromAddress == csObj.SuppliedEmail || (string.isNotBlank(csObj.Email_Cc_Address__c) && csObj.Email_Cc_Address__c.contains(eachMessage.FromAddress))
                       || (string.isNotBlank(csObj.toAddress__c) && csObj.toAddress__c.contains(eachMessage.FromAddress))){
                           if(csObj.id == eachMessage.ParentId) {
                               mapNewCaseswithId.put(csObj.id,csObj);
                               if(!mapNewCaseswithId.isEmpty()) system.debug('mapNewCaseswithId='+mapNewCaseswithId);
                           }
                           
                           if(((String.isNotBlank(csObj.Subject) && String.isNotBlank(eachMessage.Subject) && eachMessage.Subject == csObj.Subject) || (String.isNotBlank(csObj.Subject) && String.isNotBlank(modifiedsubject) && modifiedsubject == csObj.Subject) || (String.isNotBlank(modifiedCSObjsubject) && String.isNotBlank(modifiedsubject) && modifiedsubject == modifiedCSObjsubject)) && !mapNewCaseswithId.isEmpty() && eachMessage.ParentId != csObj.Id && !string.valueOf(csObj.Subject).contains('[ ref:')){
                               if(mapNewCaseswithId.get(eachMessage.ParentId) != null)
                                   if(mapNewCaseswithId.get(eachMessage.ParentId).origin == csObj.origin){
                                       casesToBeClosed.put(eachMessage.ParentId,csObj.Id);
                                       eachMessage.ParentId = csObj.Id;
                                       MapOfIncomingCaseIdEmailMessage.put(csObj.Id,eachMessage);
                                   }
                           }
                       }
                }
            }
        }
        updateCaseStatus(triggerNew,MapOfIncomingCaseIdEmailMessage,casesToBeClosed);
    }
    
    public static void afterUpdateHandler(List<EmailMessage> triggerNew, map<id,EmailMessage> triggeroldMap){
        
    }
}