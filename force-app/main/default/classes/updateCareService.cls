@RestResource(urlMapping='/api/updatecare/*')
global class updateCareService {
    static map<string,string> mapOfResponse;
        
    @HttpPost
    global static void createCaseAndContact(string currentData) {
        //system.debug('currentData========='+currentData);
        list<Case> lstCase = new list<Case>();
        Case objCase;
        Contact objCon;
        list<Attachment> lstAttachment;
        Payload_Log__c theLog = new Payload_Log__c();
        List<Case> childParentCaseList = New List<case>();
        List<Case> lstParentCaseToUpdate = new List<Case>();
        
        
        if(String.isNotBlank(currentData)){
            try{ 
                //get the mappings from custom metadata
                map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload = CareUtility.getPayloadData('MerchantCare');
                
                //deserialize the json string
                Map<String, Object> jsonRequestDataMap = (Map<String, Object>)JSON.deserializeUntyped(currentData);
                
                //system.debug('jsonRequestDataMap======='+jsonRequestDataMap);
                
                //create logs of consumer
                theLog = new Payload_Log__c(Producer__c = 'MerchantCare',Business_Object__c = 'Customer',Action__c = 'Update_MerchantCare_Case',Process__c = 'Merchant Care',Payload__c=currentData);
               
                if(mapOfObjectNameVsPayload != NULL && mapOfObjectNameVsPayload.size()>0){
                    //upsert contact records
                    /*if(mapOfObjectNameVsPayload.containsKey('Contact')){
                       objCon = (Contact)CareUtility.populateObjectData('Contact',mapOfObjectNameVsPayload,jsonRequestDataMap);
                    }*/
                    
                    //upsert Case records
                    if(mapOfObjectNameVsPayload.containsKey('Case')){
                        objCase = (Case)CareUtility.populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                        //system.debug('#### '+objCase.get('Status'));
                        //System.debug('objCase:: '+objCase);
                        //if(objCase.get('Comments') != NULL)
                        //    objCase.put('Comments','Merchant: '+objCase.get('Comments'));
                       
                        /*if(objCase.get('Status') != NULL && objCase.get('Status')=='IN_PROGRESS')
                            objCase.put('Status','Pending');*/
                        if(objCase.get('Status') != NULL && objCase.get('Status')=='REOPENED')
                            objCase.put('Status','Re-Open');
                        if(objCase.get('Status') != NULL && objCase.get('Status')=='REOPEN')
                            objCase.put('Status','Re-Open');
                    }
                    
                    //create attachment records
                    if(mapOfObjectNameVsPayload.containsKey('Attachment')){
                        lstAttachment = OnecareService.prepareAttachments(jsonRequestDataMap,mapOfObjectNameVsPayload,lstAttachment);
                    }
                    //System.debug('objCase2:: '+objCase);
                    //update comments on child case. If child case sub status is waiting on merchant
                    if(objCase.Id != NULL){
                        if(objCase.status == 'Re-Open'){
                            objCase.IsStopped = false;
                            objCase.Priority = 'High';
                        }
                        if(objCase.LP_Rating__c != NULL){
                            String milestoneName = '';
                            String caseId = objCase.Id;
                            String strQuery = 'SELECT Id,Merchant_Contacted__c,Parent_Case_Owner_Change__c,Start_Parent_Ticket_Milestone__c,Start_L2_Ticket_Milestone__c,Start_L3_Ticket_Milestone__c,Is_Parent_Owner_Change__c FROM Case Where Id =\''+caseId+'\'';
                            List<Case> caseList = Database.query(strQuery);
                            for(Case eachCase: caseList){
                                if(eachCase.Is_Parent_Owner_Change__c == true){
                                    milestoneName = 'Parent Case Owner Change';
                                    
                                } 
                                if(eachCase.Start_Parent_Ticket_Milestone__c == true){
                                    milestoneName = 'Parent Ticket Milestone';
                                    
                                }
                                if(eachCase.Start_L2_Ticket_Milestone__c == true){
                                    milestoneName = 'L2 merchant Care Milestone';
                                    
                                }
                                if(eachCase.Start_L3_Ticket_Milestone__c == true){
                                    milestoneName = 'L3 Merchant Care Milestone';                                    
                                }
                            }
                            DateTime completionDate = System.now();
                            MilestoneUtils.completeMilestone(new list<Case>{objCase}, milestoneName, completionDate);
                            objCase.status = 'Closed';
                            //objCase.Is_Violated__c = false;
                            //objCase.Is_L2_Violated__c = false;
                            //objCase.Is_L3_Violated__c = false;
                            
                            objCase.Comments='Ticket Closed Successfully.';
                            
                        }
                        //To avoid IN_PROGRESS status(Created by:- Akash Pandey).
                        if(objCase.Id != null){                            
                            List<Case> lstParentCase1 = [SELECT id,status,LP_sub_status__c,Merchant_Contacted__c,Counter__c,(Select id,First_Customer_Response_Time__c FROM Status_SLAs__r),
                                                         (SELECT id,LP_Sub_Status__c from cases where Parent_Case__c =:objCase.Id AND status != 'Closed')
                                                         FROM Case WHERE id=:objCase.Id
                                                         AND (RecordType.Name=:'BuyerCare' OR RecordType.Name=:'MerchantCare')];
                            
                            if(lstParentCase1[0].Status == 'New' && objCase.Status == 'IN_PROGRESS' && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'New';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Response received from merchant' && objCase.Status == 'IN_PROGRESS' && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'Response received from merchant';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Response received from buyer' && objCase.Status == 'IN_PROGRESS' && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'Response received from buyer';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Resolved' && objCase.Status == 'IN_PROGRESS' && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'Resolved';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Re-Open' && (objCase.Status == 'IN_PROGRESS' || objCase.Status == 'Re-Open') && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                //objCase.Status = 'Re-Open';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Open' && objCase.Status == 'IN_PROGRESS'  && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'Open';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Transferred from other teams' && objCase.Status == 'IN_PROGRESS' && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'Transferred from other teams';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                                
                            }
                            if(lstParentCase1[0].Status == 'No Resolution From Other Teams' && (objCase.Status == 'IN_PROGRESS' || objCase.Status == 'ASSIGNED_TO_EXPERT' ) && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'No Resolution From Other Teams';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Tat Exceeded' && objCase.Status == 'IN_PROGRESS' && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'Tat Exceeded';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            
                            if(lstParentCase1[0].Status == 'Response Received from Other Teams' && objCase.Status == 'IN_PROGRESS' && string.isBlank(lstParentCase1[0].LP_sub_status__c)){
                                objCase.Status = 'Response Received from Other Teams';
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                if(objCase.Counter__c != null){
                                    objCase.Counter__c = objCase.Counter__c +1;}
                            }
                            if(lstParentCase1[0].Status == 'Pending' && (objCase.Status == 'IN_PROGRESS' || objCase.Status == 'ASSIGNED_TO_EXPERT')  &&
                               (lstParentCase1[0].LP_sub_status__c != 'Waiting On Buyer' && lstParentCase1[0].LP_sub_status__c != 'Waiting On Merchant') && 
                               lstParentCase1[0].cases.size()>0){
                                   if(lstParentCase1[0].cases[0].LP_sub_status__c != 'Waiting On Buyer' && lstParentCase1[0].cases[0].LP_sub_status__c != 'Waiting On Merchant' ){
                                       objCase.Status = 'Pending';
                                       objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                       if(objCase.Counter__c != null){
                                           objCase.Counter__c = objCase.Counter__c +1;}
                                   }
                               }
                            if(lstParentCase1[0].LP_Sub_Status__c == 'Waiting On Merchant' || lstParentCase1[0].LP_Sub_Status__c == 'Waiting On Buyer'){
                                objCase.IsStopped = false;
                                objCase.Response_Received__c = true;
                                if(lstParentCase1[0].LP_Sub_Status__c == 'Waiting On Merchant'){
                                    objCase.Status = 'Response received from merchant';
                                    if(objCase.get('Comments') != NULL){
                                        objCase.put('Comments','Merchant: '+objCase.get('Comments'));
                                        system.debug('comments==='+objCase.get('Comments'));
                                    }
                                }
                                else if(lstParentCase1[0].LP_Sub_Status__c=='Waiting On Buyer'){
                                    objCase.Status = 'Response received from buyer';
                                    if(objCase.get('Comments') != NULL)
                                        objCase.put('Comments','Buyer: '+objCase.get('Comments'));
                                }
                                objCase.LP_Sub_Status__c = '';
                                if(lstParentCase1[0].Status_SLAs__r != NULL && lstParentCase1[0].Status_SLAs__r.size()>0 ){
                                    Status_SLA__c objSLA = lstParentCase1[0].Status_SLAs__r[0];
                                    if(objSLA.First_Customer_Response_Time__c == NULL){
                                        objSLA.First_Customer_Response_Time__c = Datetime.Now();
                                        update objSLA;
                                    }                                
                                }
                            }									
                            lstParentCaseToUpdate.add(objCase); 
                        }
                        
                       //get the substatus value of parent case
                       /*list<Case> lstParentCase = [SELECT id,status,LP_sub_status__c,Merchant_Contacted__c,(Select id,First_Customer_Response_Time__c FROM Status_SLAs__r) 
                                                    FROM Case WHERE id=:objCase.Id 
                                                   AND (LP_Sub_Status__c = 'Waiting On Merchant' OR LP_Sub_Status__c='Waiting On Buyer')
                                                   AND (RecordType.Name=:'BuyerCare' OR RecordType.Name=:'MerchantCare')];
                        if(lstParentCase != NULL && lstParentCase.size()>0){                           
                           objCase.IsStopped = false;
                           objCase.Response_Received__c = true;
                            if(lstParentCase[0].LP_Sub_Status__c == 'Waiting On Merchant'){
                                objCase.Status = 'Response received from merchant';
                                if(objCase.get('Comments') != NULL){
                                    objCase.put('Comments','Merchant: '+objCase.get('Comments'));
                                	system.debug('comments==='+objCase.get('Comments'));
                                }
                            } 
                            else if(lstParentCase[0].LP_Sub_Status__c=='Waiting On Buyer'){
                                objCase.Status = 'Response received from buyer';
                                if(objCase.get('Comments') != NULL)
                                    objCase.put('Comments','Buyer: '+objCase.get('Comments'));
                            }else{
                                objCase.Merchant_Contacted__c = 'Merchant commented on Case';
                            }
                            objCase.LP_Sub_Status__c = '';
                            if(lstParentCase[0].Status_SLAs__r != NULL && lstParentCase[0].Status_SLAs__r.size()>0 ){
                                Status_SLA__c objSLA = lstParentCase[0].Status_SLAs__r[0];
                                if(objSLA.First_Customer_Response_Time__c == NULL){
                                    objSLA.First_Customer_Response_Time__c = Datetime.Now();
                                    update objSLA;
                                }                                
                            }
                               
                        }
						*/
                        //lstCase.add(objCase);
                        //system.debug('objCase ==='+objCase);
                        
                            list<Case> lstChildCase =  [SELECT id,Parent_Case__c,comments,LP_sub_status__c,status,Merchant_Contacted__c FROM Case 
                                                        WHERE (recordtype.name ='MerchantChildCase' OR RecordType.Name='BuyerCareChild')
                                                        AND Parent_Case__c != NULL
                                                        AND Parent_Case__c =:objCase.Id
                                                        AND status != 'Closed'
                                                        AND (LP_sub_status__c = 'Waiting On Merchant' OR LP_sub_status__c = 'Waiting On Buyer')
                                                       ];
                            if(lstChildCase != NULL && lstChildCase.size()>0){
                                Case objchildCase = lstChildCase[0];
                                objchildCase.Comments = objCase.Comments;                            
                                objchildCase.IsStopped = false;
                                objchildCase.Response_Received__c = true;
                                system.debug('####### sub status '+objchildCase.LP_sub_status__c);
                                if(objchildCase.LP_sub_status__c == 'Waiting On Merchant'){
                                    objchildCase.Status = 'Response received from merchant';
                                } 
                                else if(objchildCase.LP_sub_status__c == 'Waiting On Buyer') {
                                    objchildCase.Status = 'Response received from buyer';
                                }else{
                                    objchildCase.Merchant_Contacted__c = 'Merchant commented on Case';
                                }
                                
                                objchildCase.LP_Sub_Status__c = '';
                                lstCase.add(objchildCase);
                                
                                Case childParentCase = New Case(Id=objchildCase.Parent_Case__c,status='Pending');
                                lstParentCaseToUpdate.add(childParentCase);
                            }
                        }
                        
                        //upsert case
                        if(lstCase != null && lstCase.size()>0) upsert lstCase;
                        if(lstParentCaseToUpdate.size()>0) update lstParentCaseToUpdate;
                    
                    //upsert attachment
                    list<attachment> lstAttach = new list<attachment>();
                    if(lstAttachment != NULL && lstAttachment.size()>0){
                        for(Attachment eachAttachment: lstAttachment){
                            //update parentId
                            //System.debug('Parent Id:: '+objCase.Id);
                            if(objCase != NULL && objCase.Id != NULL)
                                eachAttachment.parentId = objCase.Id;
                            lstAttach.add(eachAttachment);
                        }
                        //system.debug('lstAttach===='+lstAttach);
                        if(lstAttach != null && lstAttach.size()>0)
                            upsert lstAttach; 
                    }
                                       
               }
                
                if(objCase.Id != Null){
                    
                    
                    list<Case> lstFetchedCase = [SELECT casenumber,status,Identifier__c,Expected_Closure_Date__c FROM Case WHERE id=:objCase.Id]; 
                    
                    //prepare return response
                    mapOfResponse = new map<string,string>();
                    mapOfResponse.put('State','Success');
                    if(lstFetchedCase!= NULL && lstFetchedCase.size()>0){
                        mapOfResponse.put('caseNumber',lstFetchedCase[0].casenumber);
                        mapOfResponse.put('caseStatus',lstFetchedCase[0].status);
                        mapOfResponse.put('identifier',lstFetchedCase[0].Identifier__c);
                        mapOfResponse.put('Expected Closure Date',String.ValueOf(lstFetchedCase[0].Expected_Closure_Date__c));
                    }
                    
                    RestResponse res = RestContext.response; 
                    if(!Test.isRunningTest()){
                        res.addHeader('Content-Type', 'Application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                        res.statusCode = 200;
                    }
                }
             theLog.Status__c = 'SUCCESS';    
            }catch(Exception ex){
                System.debug('ERROR::'+ex.getMessage());
                System.debug('ERROR::'+ex.getLineNumber());
                theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); theLog.Status__c = 'Error';

                map<string,string> mapOfResponse = new map<string,string>();
                mapOfResponse.put('State','Error');
                mapOfResponse.put('message',ex.getMessage());
                mapOfResponse.put('Stack Trace',ex.getStackTraceString());
                mapOfResponse.put('Line No',string.valueOf(ex.getLineNumber()));
                
                if(!Test.isRunningTest()){
                    RestResponse res = RestContext.response;                
                    res.addHeader('Content-Type', 'Application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                    res.statusCode = 500;
                }
            }
            
            insert theLog;            
        }
        
    }
}