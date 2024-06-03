public class CaseTriggerHandler{
    public static boolean isTriggerExecuted = false; 
    public static Boolean isFirstTime = true;
    
    private static Id FRAUD_RECORDTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ETC_Fraud_Team').getRecordTypeId();
    private static Id TRANSACTION_STATUS_RECORDTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transaction_Status').getRecordTypeId();
    
    public static void beforeInsertHandler(list<Case> triggerNew){
        System.debug('Case Trigger handler Called in Before Insert ');
        
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Case');         
        for(Case each : triggerNew){
            // this line used for update Tat picklist value in tAt text field.
            each.TATValue__c = each.LP_TAT__c != Null ? integer.valueOf(each.LP_TAT__c) : 0 ;
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);            
        }
        
        Id collectionRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        Id careRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
           //COLLECTION : update recordtypeId and ownerid on case
            updateRecordTypeAndOwnerOnCase(triggerNew);
           // COLLECTION : Close the cases with outstanding zero
             CloseCasesWithOutstandingZero(triggerNew);
          // Collection : Use to update "IVR-Id" based on "Communication Sub Type" 
             updateIvrIdWithType(triggerNew , null); 

           //Care : create contact in email to case if does not exists
           createContactInEmailToCase(triggerNew);  
           
          // Email -to-Case Requirements
           LazyPayEmailTocase.beforeInsertHandler(triggerNew);
    }
    public static void afterInsertHandler(list<Case> triggerNew){
        
    }
    
    /* Added Pooja START Email Duplicate */
    public static void caseDuplicateMerge(List<Case> triggerNew){
        List<Case> emailCase = new List<Case>();
        
        for(Case cs : triggerNew){
            if(cs.SuppliedEmail != NULL /* && cs.Origin == 'Email'*/ && (FRAUD_RECORDTYPE_ID == cs.RecordTypeId || TRANSACTION_STATUS_RECORDTYPE_ID == cs.RecordTypeId)){
                emailCase.add(cs);
            }
        }
        
        if(!emailCase.isEmpty()){ 
            //enque job
            System.debug(LoggingLevel.DEBUG, 'emailCase Size '+emailCase.size());
            ID jobID = System.enqueueJob(new CaseMerge(emailCase));
            System.debug(LoggingLevel.INFO, 'jobID '+jobID); 
        }
    }
    /* Added Pooja END Email Duplicate */
    
    public static void beforeUpdateHandler(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        Id kycRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        Id collectionRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        Id careRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        System.debug('Before UPdate Called !');
        
          //KYC : before update method for KYC Process  
          beforeUpdateForKYC(triggerNew,TriggeroldMap);
          //KYC : update KYC state on case
          updateKYCState(triggerNew,TriggeroldMap);  

            //COLLECTION : move case to terminate queue if outstanding amount is zero
           closeCaseAndMoveToTerminateQueue(triggerNew,TriggeroldMap);
           beforeUpdatecollectionProcess(triggerNew,TriggeroldMap);
        
           //Collection : Update the IVR Id corresponding to IVR Type 
            updateIvrIdWithTYpe(triggerNew,TriggeroldMap);  

        
           //Care Process
            beforeUpdateCareProcess(triggerNew,TriggeroldMap); 
           //This method is used to restrict the agents to resolve the case if newest incoming email is unread 
            StopMarkingCaseAsResolved(triggerNew,TriggeroldMap);

        
        //Merchant Child Case Process
        //beforeUpdateChildCaseProcess(triggerNew,TriggeroldMap);
        
        //Merchant Care Process
        //beforeUpdateMerchantCareProcess(triggerNew,TriggeroldMap);  
          
        
        System.debug('before---triggerNew======'+triggerNew[0].Comments);
        
        if(isFirstTime){
            isFirstTime = false;
        CreateManualCallresponce(triggerNew,TriggeroldMap);
        }
    }
    
    public static void afterUpdateHandler(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        // Set of Ids for new trigger
        
        //KYC : assign case to L2 queue if all docs are verified by L1 agent
        if(Label.Assign_L1_Verified_Case_to_L2 == 'True')
            assignCaseToL2Queue(triggerNew,TriggeroldMap);
        
        //KYC : publish KYC case changes to LazyPay DB
        if (isTriggerExecuted == false){
            System.debug('Publish data to lazyPay');
            KYCCasePublish(triggerNew,TriggeroldMap);
            
            isTriggerExecuted = True;
        }
        //KYC, COLLECTION : send knowlarity response to LazyPayDB
        sendKnowlarityResponse(triggerNew,TriggeroldMap);
        
        //CARE : Create child case
        afterUpdateCareProcess(triggerNew,TriggeroldMap);
        System.debug('after---triggerNew======'+triggerNew[0].Comments);
                
    }
    
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method calls from before update for KYC
@history
<Date>                <Authors Name>              <Brief Description of Change>
5-Apr-19              Eitika Verma               created
**/
    public static void beforeUpdateForKYC(list<Case> triggerNew,map<Id,Case> TriggeroldMap){
        Id KYCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        Id CollectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        set<Id> setOfVerifiedCase = new set<Id>();
        list<Case> lstOfAdditionalDocL1 = new list<Case>();
        list<Case> lstOfCaseByL2 = new list<Case>();
        list<Case> lstOfPendingCase = new list<Case>();
        list<case> listOfcaseRecordForPayload = new list<case>(); // add by surender for payload
        list<Task> lstTask = new list<Task>();
        string strSubject = '';
        string action = '';
        map<string,PayloadActMap__mdt> mapOfObjNameVsPayload = CareUtility.getPayloadData('create_Manual_IVR_Response');
        
        for(Case eachCase : triggerNew){
            if(eachCase.recordTypeId == KYCRecordTypeId){                
            Case oldCase = TriggeroldMap.get(eachCase.Id);
            
            // this line used for update Tat picklist value in tAt text field.
            eachCase.TATValue__c = eachCase.LP_TAT__c != Null ? integer.valueOf(eachCase.LP_TAT__c) : 0 ;
            
            //KYC : validate case is verified or not
            if(eachCase.RecordTypeId == KYCRecordTypeId && eachCase.status != oldCase.status && eachCase.status == 'Verified'){
                setOfVerifiedCase.add(eachCase.Id);
            }
            
            //KYC : restrict L1 user to choose Additional Documents Requested
            if(eachCase.RecordTypeId == KYCRecordTypeId && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c && eachCase.LP_Sub_Status__c == 'Additional Documents Requested'){ //loggedInUserL1Agent && 
                lstOfAdditionalDocL1.add(eachCase);
                
            }
            else if(eachCase.RecordTypeId == KYCRecordTypeId && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c 
                    //&& (eachCase.LP_Sub_Status__c == 'Assign to checker'  || eachCase.LP_Sub_Status__c == 'Additional docs required_L1')){  //loggedInUserL2Agent && 
                        && (eachCase.LP_Sub_Status__c == 'Assign to checker' )){  //loggedInUserL2Agent &&
                        lstOfCaseByL2.add(eachCase);
                    }
            
            //KYC : assign case back to L1 agent by L2 agent
            if(eachCase.RecordTypeId == KYCRecordTypeId && eachCase.status != oldCase.status && eachCase.status == 'Pending' && oldCase.status == 'Verified'){
                lstOfPendingCase.add(eachCase);
            }
            
            //KYC : update sub status on Case
            if(eachCase.RecordTypeId == KYCRecordTypeId && eachCase.LP_KYC_State__c != NULL 
               && eachCase.LP_KYC_State__c =='Under Manual Verification' 
               && oldCase.LP_KYC_State__c =='Add Doc Requested Manually'){ 
                   eachCase.LP_Sub_Status__c = ''; 
               }
            
            //KYC,COLLECTION : update manual count on case
            if((eachCase.RecordTypeId == KYCRecordTypeId || eachCase.RecordTypeId == CollectionRecordTypeId) 
               && eachCase.LP_Manual_Call_Response__c != NULL && 
               oldCase.LP_Manual_Call_Response__c != eachCase.LP_Manual_Call_Response__c){
                   // this added by surender for update manual call response on task.
                   strSubject = 'Manual call Response';
                   eachCase.LP_Manual_Call_Count__c = eachCase.LP_Manual_Call_Count__c!=NULL?eachCase.LP_Manual_Call_Count__c + 1:1;
                   lstTask.add(updateManualCallResponseOnTask(strSubject,eachCase.LP_Manual_Call_Response__c , eachCase.id, mapOfObjNameVsPayload.get('Task')));
               }            
            // this line code added by surender on 23-05-2019 /// start from here
            if((eachCase.RecordTypeId == KYCRecordTypeId || eachCase.RecordTypeId == CollectionRecordTypeId) 
               && eachCase.LP_IVR_Call_Response__c != NULL && 
               oldCase.LP_IVR_Call_Response__c != eachCase.LP_IVR_Call_Response__c){
                   // this added by ssurender for update manual call response on task.
                   strSubject = 'IVR Call Response';
                   lstTask.add(updateManualCallResponseOnTask(strSubject,eachCase.LP_IVR_Call_Response__c , eachCase.id, mapOfObjNameVsPayload.get('Task')));
               }
            //KYC : add record in list for Kyc payload
            if(eachCase.RecordTypeId == KYCRecordTypeId && (eachCase.LP_Manual_Call_Status__c != oldCase.LP_Manual_Call_Status__c 
                                                            || eachCase.LP_Manual_Call_Sub_Status__c  != oldCase.LP_Manual_Call_Sub_Status__c
                                                            || eachCase.LP_Next_Scheduled_Call__c  != oldCase.LP_Next_Scheduled_Call__c
                                                            || eachCase.status  != oldCase.status
                                                            || eachCase.LP_Audit_Status__c  != oldCase.LP_Audit_Status__c)){ 
                                                                listOfcaseRecordForPayload.add(eachCase);  
                                                            }
        }  
            
        }
        
        //publish manual call actions of KYC to LazyPayDb via AWS
        if(listOfcaseRecordForPayload != NULL && listOfcaseRecordForPayload.size()>0){
            action = 'upsert_Call_Response_KYC';
            uploadPayload(listOfcaseRecordForPayload,action );
        }     
        
        //KYC : validate case is verified or not
        if(setOfVerifiedCase != NULL && setOfVerifiedCase.size()>0){
            validateVerfiedCase(triggerNew,setOfVerifiedCase);
        }
        
        //KYC : restrict L1 user to choose Additional Documents Requested
        if((lstOfAdditionalDocL1!= NULL && lstOfAdditionalDocL1.size()>0) || 
           (lstOfCaseByL2!= NULL && lstOfCaseByL2.size()>0) ){
               restrictL1User(lstOfAdditionalDocL1,lstOfCaseByL2);
           }
        
        //KYC : assign case back to L1 agent by L2 agent
        if(lstOfPendingCase != NULL && lstOfPendingCase.size()>0){
            assignBackToL1Agent(lstOfPendingCase);
        }
        if(!Test.isRunningTest()){
        if(lstTask != NULL && lstTask.size()>0)
            insert lstTask;
        }
    }
    

    

    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method updates the recordtypeid and owner on case
@history
<Date>                <Authors Name>              <Brief Description of Change>
02-Jan-19              Eitika Verma               created
**/
    
    public static void updateRecordTypeAndOwnerOnCase(list<Case> triggerNew){
        //declare variables
        map<string,Case> mapOfUUIdVsCase = new map<string,Case>();
        map<string,Contact> mapOfUUIdVsContact = new map<string,Contact>();
        Id QueueID;
        //fetch the collection recordtypeId
        if(!Test.isRunningTest()){
            //QueueID = [SELECT id FROM Group WHERE type='Queue' AND developerName = 'LP_Collection_Queue' LIMIT 1].Id;
			Map<String,String> mapofQueueDevNameVsId = new Map<String,String>();           
			mapofQueueDevNameVsId = (Map<String, String>)JSON.deserialize(label.LP_QueueDevNameVsID, Map<String, String>.class);
			QueueID = (Id)mapofQueueDevNameVsId.get('LP_Collection_Queue');
			System.debug('QueueID****'+ QueueID);
        }
        String strRecordTypeId = SystemUtility.getRecordTypeId('Case','Collection');
        
        //get the Collection queue id
        
        
        //iterate the case and update owner and recordtype id
        for(Case eachCase : triggerNew){
            if(eachCase.LP_RecordTypeName__c != '' && eachCase.LP_RecordTypeName__c == 'Collection'){ 
                if(!Test.isRunningTest()){
                  eachCase.ownerId = QueueID;  
                }
                eachCase.RecordTypeId = strRecordTypeId;
                
                if(eachCase.LP_UUID_For_Collection__c != null){
                    mapOfUUIdVsCase.put(eachCase.LP_UUID_For_Collection__c,eachCase);
                }
            }
        }
        
        //update contact lookup value on case
        if(mapOfUUIdVsCase != NULL && mapOfUUIdVsCase.size()>0){
            for(Contact eachCon : [SELECT id,
                                   Identifier__c,
                                   (Select id from Cases where status != 'closed' and recordtypeId = :strRecordTypeId)
                                   FROM Contact 
                                   WHERE Identifier__c IN:mapOfUUIdVsCase.keyset()]){
                                       mapOfUUIdVsContact.put(eachCon.Identifier__c,eachCon); 
                                   }
        }
        
        for(string eachUUID : mapOfUUIdVsCase.keyset()){
            if(mapOfUUIdVsContact != NULL && mapOfUUIdVsContact.containsKey(eachUUID)){
                if(mapOfUUIdVsContact.get(eachUUID).Cases != NULL && mapOfUUIdVsContact.get(eachUUID).Cases.size() > 0)
                    mapOfUUIdVsCase.get(eachUUID).addError(Label.LP_Multiple_Collection_Case_exists);
                else
                    mapOfUUIdVsCase.get(eachUUID).ContactId = mapOfUUIdVsContact.get(eachUUID).Id;
            }
            else{
                mapOfUUIdVsCase.get(eachUUID).addError(Label.LP_Contact_is_not_existing);
            }
        }
    }
    
    
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to restrict the L1/L2 agent to select sub status values 
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/ 
    public static void restrictL1User(list<Case> lstOfAdditionalDocL1,list<Case> lstOfCaseByL2){
        
        if(lstOfAdditionalDocL1.size() > 0){
            boolean loggedInUserL1Agent = isOwnerLieInQueue('L1_KYC_Queue');
            for(Case eachCase : lstOfAdditionalDocL1){
                if(loggedInUserL1Agent && !Test.isRunningTest()) eachCase.addError(Label.LP_Additional_Document_Requested_Not_For_L1); 
            }
        }
        
        if(lstOfCaseByL2.size() > 0){
            boolean loggedInUserL2Agent = isOwnerLieInQueue('L2_KYC_Queue');
            for(Case eachCase : lstOfCaseByL2){
                if(loggedInUserL2Agent && !Test.isRunningTest()) eachCase.addError(Label.LP_Substatus_not_allowed_for_L2); 
            }
        }
    }
    
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to restrict the agent to mark case status as verfied if document status is pending/rejected
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/ 
    public static void validateVerfiedCase(list<Case> triggerNew,set<Id> setOfCaseID){
        
        //collect the kyc document count as per status and case is in map
        map<Id,map<string,integer>> mapOFCaseIdVsMapOfStatusVsCount = new map<Id,map<string,integer>>();
        
        if(setOfCaseID != NULL && setOfCaseID.size()>0)
        {
            for(AggregateResult eachAgr : [SELECT 
                                           count(id) num,
                                           LP_Status__c,
                                           LP_Case__c
                                           FROM LP_KYC_Document__c
                                           where LP_Case__c IN:setOfCaseID  and LP_Show_On_Component__c =true                                      
                                           Group BY LP_Case__c,LP_Status__c
                                            ]){
                                               if(mapOFCaseIdVsMapOfStatusVsCount != NULL && !mapOFCaseIdVsMapOfStatusVsCount.containsKey(Id.valueOf(String.ValueOf(eachAgr.get('LP_Case__c')))))
                                                   mapOFCaseIdVsMapOfStatusVsCount.put(Id.valueOf(String.ValueOf(eachAgr.get('LP_Case__c'))),new map<string,integer>());
                                               mapOFCaseIdVsMapOfStatusVsCount.get(Id.valueOf(String.ValueOf(eachAgr.get('LP_Case__c')))).put(String.ValueOf(eachAgr.get('LP_Status__c')),Integer.valueOf(String.ValueOf(eachAgr.get('num'))));
                                           }
        }
        
        //show error message on case detail page to agent
        if(mapOFCaseIdVsMapOfStatusVsCount != NULL && mapOFCaseIdVsMapOfStatusVsCount.size()>0){
            for(Case eachCase : triggerNew){
                if(setOfCaseID != NULL && setOfCaseID.size()>0 && setOfCaseID.contains(eachCase.Id)){
                    if(mapOFCaseIdVsMapOfStatusVsCount.get(eachCase.ID).containsKey('Pending') || mapOFCaseIdVsMapOfStatusVsCount.get(eachCase.ID).containsKey('Declined')){
                        If(!Test.isRunningTest())  eachCase.addError(System.Label.LP_Case_status_cannot_be_verfied);
                    }
                }
            }
        }
    }
    
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to assign case to L1 agent
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
    public static void assignBackToL1Agent(list<Case> lstCase){
        
        //if status of case change from verified to pending and owner is l2 agent then case back assign to L1 agent
        if(lstCase!= NULL && lstCase.size()>0){
            //check that logged in user is L2 agent or not
            boolean loggedInUserL2Agent = isOwnerLieInQueue('L2_KYC_Queue');
            system.debug('aaa'+loggedInUserL2Agent);
            
            if(loggedInUserL2Agent){        
                for(Case eachprocessedCase : lstCase){
                    if(eachprocessedCase.LP_L1_Agent_Id__c != NULL)
                        eachprocessedCase.ownerID = eachprocessedCase.LP_L1_Agent_Id__c;
                    eachprocessedCase.Priority = 'High';
                    eachprocessedCase.LP_L1_Agent_Id__c = '';
                    
                    system.debug('eachprocessedCase====='+eachprocessedCase);
                }
            }
            
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       find the L2 KYC queue id
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
    private static boolean isOwnerLieInQueue(string queuename){
        
        
      /*  Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name =:queuename].Id;    //L2 KYC Queue
        system.debug('q id '+queueId);
     */
        
        Map<String,String> mapofQueueDevNameVsId = new Map<String,String>();           
	    mapofQueueDevNameVsId = (Map<String, String>)JSON.deserialize(label.LP_QueueDevNameVsID, Map<String, String>.class);
		
        Id queueId = (Id)mapofQueueDevNameVsId.get(queuename);
		
        
        //check logged in user lie in queue or not
        list<GroupMember> lstgm = [Select UserOrGroupId 
                                   From GroupMember 
                                   WHERE GroupId =: queueId 
                                   AND UserOrGroupId =: userinfo.getUserId()];
        system.debug('GroupMember'+lstgm);
        
        if(lstgm != NULL && lstgm.size()>0 && lstgm[0].UserOrGroupId != NULL){
            return true;
        }else{
            return false;
        }
        
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       check that logged in user is L2 agent or not

@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
    public static void assignCaseToL2Queue(list<Case> triggerNew,map<Id,Case> TriggeroldMap){
        list<Case> lstCase = new list<Case>();
        boolean loggedInUserL2Agent = isOwnerLieInQueue('L2_KYC_Queue');
        //find the L2 KYC queue id
      /*  Id queueId = [SELECT id 
                      FROM Group 
                      WHERE type = 'Queue' 
                      AND Name = 'L2 KYC Queue'].Id;
      */
        
        Map<String,String> mapofQueueDevNameVsId = new Map<String,String>();           
	    mapofQueueDevNameVsId = (Map<String, String>)JSON.deserialize(label.LP_QueueDevNameVsID, Map<String, String>.class);		
        Id queueId = (Id)mapofQueueDevNameVsId.get('L2_KYC_Queue');
        
        for(Case eachCase : triggerNew){
            if(eachCase.Status != TriggeroldMap.get(eachCase.ID).status && eachCase.Status == 'Verified' && !loggedInUserL2Agent){
                Case objCase = new Case(Id=eachCase.Id,ownerId=queueId,LP_L1_Agent_Id__c=userInfo.getUserId());
                lstCase.add(objCase);
            }
        }       
        if(lstCase!= NULL && lstCase.size()>0)
            update lstCase;
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       used to publish the case event to lazypaydb
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
    public static void KYCCasePublish(list<Case> triggerNew,map<Id,Case> TriggeroldMap){
        list<Case> lstpublishNewCase = new list<Case>();
        map<Id,Case> mapOfOldCase = new map<Id,Case>();
        Id KYCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        for(Case eachCase :triggerNew)
        {
            case oldeach = TriggeroldMap.get(eachCase.Id); 
            Case objnewCase = new Case();
            if(eachCase.RecordTypeId == KYCRecordTypeId){
                if (eachCase.status != oldeach.status || eachCase.LP_Sub_Status__c != oldeach.LP_Sub_Status__c) {
                    system.debug('@@@@@>>'+ eachCase);
                    if(eachCase.status == 'Pending' && eachCase.LP_Sub_Status__c == 'Additional Documents Requested'){
                        lstpublishNewCase.add(eachCase);
                        mapOfOldCase.put(eachCase.Id,oldeach);
                    }
                }
                if (eachCase.status != oldeach.status && eachCase.status == 'Approved'){
                    system.debug('Case Approved @@@@@>>'+ eachCase);
                    lstpublishNewCase.add(eachCase);
                    mapOfOldCase.put(eachCase.Id,oldeach);
                }
                else if (eachCase.status != oldeach.status && eachCase.status == 'Rejected'){
                    lstpublishNewCase.add(eachCase);
                    mapOfOldCase.put(eachCase.Id,oldeach);
                }
            }
            
        }
        
        if(lstpublishNewCase != NULL && lstpublishNewCase.size()>0 && mapOfOldCase != NULL && mapOfOldCase.size()>0){
            //get the KYC documentID
            map<Id,list<LP_KYC_Document__c>> mapOfCaseIdVslistOfKYCDoc = new map<Id,list<LP_KYC_Document__c>>();
            list<PayloadActMap__mdt> thePayLoadMap = SystemUtility.getAllFieldsOfObject('updateKYCcasedetails','PayloadActMap__mdt','DeveloperName');
            string strquery = 'SELECT id,(SELECT ';
            if (!thePayLoadMap.isempty())
            {
                strquery += thePayLoadMap[0].Field_To_Query__c;
                strquery += ' FROM KYC_Document__r  where LP_Show_On_Component__c = true) FROM Case where id IN:lstpublishNewCase';
            }
            for(Case eachCase : Database.query(strquery)){
                if(mapOfCaseIdVslistOfKYCDoc != NULL && !mapOfCaseIdVslistOfKYCDoc.containsKey(eachCase.Id))
                    mapOfCaseIdVslistOfKYCDoc.put(eachCase.Id,new list<LP_KYC_Document__c>());
                    System.debug('eachCase.KYC_Document__r.size @@@@@@' + eachCase.KYC_Document__r.size());
                mapOfCaseIdVslistOfKYCDoc.get(eachCase.Id).addall(eachCase.KYC_Document__r);
            }
            lazyPayPublish.sendPayLoaddata(lstpublishNewCase,mapOfOldCase,'Case',mapOfCaseIdVslistOfKYCDoc);
            
            
        }
        
        
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       used to update the KYC state and modified date on case
@history
<Date>                <Authors Name>              <Brief Description of Change>
04-Sep-18              Eitika Verma               created
**/
    public static void updateKYCState(list<Case> triggerNew,map<Id,Case> TriggeroldMap){
        Id KYCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('KYC').getRecordTypeId();
        for(Case eachCase :triggerNew)
        {
            case oldeach = TriggeroldMap.get(eachCase.Id); 
            Case objnewCase = new Case();
            if (eachCase.recordTypeId == KYCRecordTypeId && (eachCase.status != oldeach.status || 
                                                             eachCase.LP_Sub_Status__c != oldeach.LP_Sub_Status__c)) {
                                                                 if(eachCase.status == 'Pending' && eachCase.LP_Sub_Status__c == 'Additional Documents Requested'){
                                                                     eachCase.LP_KYC_State__c ='Add Doc Requested Manually';
                                                                     eachCase.LP_KYC_Last_Modified_Date__c = System.now();
                                                                     
                                                                 }
                                                                 else if(eachCase.status == 'Pending' && eachCase.LP_Sub_Status__c == 'Cannot Resolve'){ 
                                                                     eachCase.LP_KYC_State__c ='Under Manual Verification';
                                                                     eachCase.LP_KYC_Last_Modified_Date__c = System.now();
                                                                     
                                                                 }
                                                             }
            
            if (eachCase.recordTypeId == KYCRecordTypeId && eachCase.status != oldeach.status 
                && eachCase.status == 'Approved'){
                    eachCase.LP_KYC_State__c = 'Manual Marked Success';
                    eachCase.LP_KYC_Last_Modified_Date__c = System.now();
                    
                }
            else if (eachCase.recordTypeId == KYCRecordTypeId && eachCase.status != oldeach.status 
                     && eachCase.status == 'Rejected'){
                         eachCase.LP_KYC_State__c = 'Manual Documents Declined';
                         eachCase.LP_KYC_Last_Modified_Date__c = System.now();
                         
                     }
        }
    }
    
    public static void CloseCasesWithOutstandingZero(list<Case> triggerNew){
            //fetch the collection recordtypeId
        String strRecordTypeId = SystemUtility.getRecordTypeId('Case','Collection'); 
        for(Case eachCase: triggerNew){
            if(eachCase.LP_Outstanding_Amount__c <= 0 && eachCase.recordtypeID == strRecordTypeId){
                eachCase.status = 'Closed';
                System.debug('Inside Outstanding : ' + eachCase.LP_Outstanding_Amount__c);
            }   
        }  
    }
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to close the case and move it to terminate queue 
@history
<Date>                <Authors Name>              <Brief Description of Change>
24-DEC-18              Eitika Verma               created
**/ 
    public static void closeCaseAndMoveToTerminateQueue(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        id terminateQueueId;
        //get the terminate queue id
        if(!Test.isRunningTest()){
           // terminateQueueId = [SELECT id FROM Group WHERE Type = 'Queue' and developerName = 'LP_Terminate_Queue'].id;
                     Map<String,String> mapofQueueDevNameVsId = new Map<String,String>();           
	    mapofQueueDevNameVsId = (Map<String, String>)JSON.deserialize(label.LP_QueueDevNameVsID, Map<String, String>.class);		
        terminateQueueId = (Id)mapofQueueDevNameVsId.get('LP_Terminate_Queue');
        }
        
        //fetch the collection recordtypeId
        String strRecordTypeId = SystemUtility.getRecordTypeId('Case','Collection');
        //update the status to close if principle due amount is zero on case
        for(Case eachCase : triggerNew){
            if(eachCase.LP_Outstanding_Amount__c != TriggeroldMap.get(eachCase.Id).LP_Outstanding_Amount__c 
                 && eachCase.LP_Outstanding_Amount__c <= 0 && eachCase.recordtypeID == strRecordTypeId){
                   eachCase.status = 'Closed';
                   System.debug('Inside Outstanding : ' + eachCase.LP_Outstanding_Amount__c);
                   if(!Test.isRunningTest()){
                       eachCase.ownerId = terminateQueueId;
                   }
                   
               }
        }
    }
    
    
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to send the knowlarity response in lazy pay DB
@history
<Date>                <Authors Name>              <Brief Description of Change>
03-JAN-19              Eitika Verma               created
**/ 
    public static void sendKnowlarityResponse(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        Id KYCRecordTypeId = SystemUtility.getRecordTypeId('Case','KYC');
        Id CollectionRecordtypeId = SystemUtility.getRecordTypeId('Case','Collection');
        map<String,list<Case>> mapOfCallandRecordTypeVsListOfCase = new map<String,list<Case>>();
        list<Case> lstKYCIVRCase = new list<Case>();
        
        list<Case> lstManualCallCase = new list<Case>();
        for(Case eachCase : triggerNew){
            system.debug('eachCase.LP_IVR_Call_Response__c '+eachCase.LP_IVR_Call_Response__c);
            if(eachCase.LP_IVR_Call_Response__c != TriggeroldMap.get(eachCase.Id).LP_IVR_Call_Response__c 
               && eachCase.LP_IVR_Call_Response__c != NULL){
                   if(eachCase.recordtypeID == KYCRecordTypeId){
                       if(mapOfCallandRecordTypeVsListOfCase!= NULL && !mapOfCallandRecordTypeVsListOfCase.containsKey('KYC_IVR'))
                           mapOfCallandRecordTypeVsListOfCase.put('KYC_IVR',new list<Case>());
                       mapOfCallandRecordTypeVsListOfCase.get('KYC_IVR').add(eachCase);
                   }
                   else if(eachCase.recordtypeID == CollectionRecordtypeId){
                       if(mapOfCallandRecordTypeVsListOfCase!= NULL && !mapOfCallandRecordTypeVsListOfCase.containsKey('Collection_IVR'))
                           mapOfCallandRecordTypeVsListOfCase.put('Collection_IVR',new list<Case>());
                       mapOfCallandRecordTypeVsListOfCase.get('Collection_IVR').add(eachCase);
                   }
                   //lstIVRCase.add(eachCase);
               }
            else if(eachCase.LP_Manual_Call_Response__c != TriggeroldMap.get(eachCase.Id).LP_Manual_Call_Response__c){
                if(eachCase.recordtypeID == KYCRecordTypeId){
                    if(mapOfCallandRecordTypeVsListOfCase!= NULL && !mapOfCallandRecordTypeVsListOfCase.containsKey('KYC_Manual'))
                        mapOfCallandRecordTypeVsListOfCase.put('KYC_Manual',new list<Case>());
                    mapOfCallandRecordTypeVsListOfCase.get('KYC_Manual').add(eachCase);
                } else if(eachCase.recordtypeID == CollectionRecordtypeId){
                    if(mapOfCallandRecordTypeVsListOfCase!= NULL && !mapOfCallandRecordTypeVsListOfCase.containsKey('Collection_Manual'))
                        mapOfCallandRecordTypeVsListOfCase.put('Collection_Manual',new list<Case>());
                    mapOfCallandRecordTypeVsListOfCase.get('Collection_Manual').add(eachCase);
                }
                //lstManualCallCase.add(eachCase);
            }
        }
        
        if(mapOfCallandRecordTypeVsListOfCase != NULL && mapOfCallandRecordTypeVsListOfCase.size()>0){
            list<knowlarityPayload__mdt> manualCustomMdt = SystemUtility.getAllFieldsOfObject('Manual_Call','knowlarityPayload__mdt','DeveloperName');
            string strquery = 'SELECT '+ manualCustomMdt[0].FieldsToQuery__c; 
            if(mapOfCallandRecordTypeVsListOfCase.containsKey('KYC_Manual') && mapOfCallandRecordTypeVsListOfCase.get('KYC_Manual') != NULL && mapOfCallandRecordTypeVsListOfCase.get('KYC_Manual').size()>0){
                list<Case> lstKYCCase = mapOfCallandRecordTypeVsListOfCase.get('KYC_Manual');
                strquery += ' FROM Case WHERE Id IN:lstKYCCase';
                list<Case> lstCase = Database.query(strquery);
                mapOfCallandRecordTypeVsListOfCase.put('KYC_Manual',lstCase);
            }
            if(mapOfCallandRecordTypeVsListOfCase.containsKey('Collection_Manual') && mapOfCallandRecordTypeVsListOfCase.get('Collection_Manual') != NULL  && mapOfCallandRecordTypeVsListOfCase.get('Collection_Manual').size()>0){
                list<Case> lstCollectionCase = mapOfCallandRecordTypeVsListOfCase.get('Collection_Manual');
                strquery += ' FROM Case WHERE Id IN:lstCollectionCase';
                system.debug('strquery======='+strquery);
                list<Case> lstCase = Database.query(strquery);
                mapOfCallandRecordTypeVsListOfCase.put('Collection_Manual',lstCase);
            }
        }
        
        if(mapOfCallandRecordTypeVsListOfCase != NULL && mapOfCallandRecordTypeVsListOfCase.size()>0)
            LazyPayPublish.sendknowlarityResponse(mapOfCallandRecordTypeVsListOfCase);
        
    }
    
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method calls the care and child case methods
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void beforeUpdateCareProcess(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        map<Id,Case> mapOfCaseIDVsCase = new map<Id,Case>();
        list<Case> lstCase = new list<Case>();
        list<case> listOfcaseRecordForPayload = new list<case>(); // add by surender for payload
        map<Id,Case> mapOfCareCaseIDVsCase = new map<Id,Case>();
        
        Id CareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        string action = '';
        for(Case eachCase : triggerNew){
            if(eachCase.RecordTypeId == CareRecordTypeId){
                
                Case oldCase = TriggeroldMap.get(eachCase.Id);
                if((eachCase.Status =='Pending' && eachCase.Status == oldCase.Status && 
                    eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c) 
                   || 
                   (eachCase.Status != oldCase.Status && eachCase.Status == 'Resolved')){ 
                       mapOfCaseIDVsCase.put(eachCase.Id,eachCase);
                   }
                if(eachCase.Status =='Pending' && eachCase.Comments == NULL && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c
                   && eachCase.LP_Sub_Status__c != NULL &&
                   eachCase.LP_Sub_Status__c != 'Waiting On Customer' && eachCase.LP_Sub_Status__c != 'Waiting On Merchant'){ 
                       eachCase.addError(Label.LP_Please_Enter_Comments);
                   }
                
                //to update owner on case when category changes
                if(eachCase.LP_Category__c != oldCase.LP_Category__c && eachCase.LP_Category__c != NULL && eachCase.LP_Category__c != ''){
                    lstCase.add(eachCase);
                }
                // upload payload for Care    
                if(eachCase.RecordTypeId == CareRecordTypeId && (eachCase.LP_Manual_Call_Status__c != oldCase.LP_Manual_Call_Status__c     
                                                                 || eachCase.LP_Sub_Status__c  != oldCase.LP_Sub_Status__c    
                                                                 || eachCase.OwnerId  != oldCase.OwnerId    
                                                                 || eachCase.LP_Details__c  != oldCase.LP_Details__c    
                                                                 || eachCase.LP_Rating__c  != oldCase.LP_Rating__c    
                                                                 || eachCase.LP_Customer_Feedback__c  != oldCase.LP_Customer_Feedback__c    
                                                                 || eachCase.LP_Customer_Sub_Feedback__c  != oldCase.LP_Customer_Sub_Feedback__c    
                                                                 || eachCase.LP_Customer_Comments__c  != oldCase.LP_Customer_Comments__c    
                                                                 || eachCase.status  != oldCase.status    
                                                                 || eachCase.LP_Audit_Status__c  != oldCase.LP_Audit_Status__c)){     
                                                                     listOfcaseRecordForPayload.add(eachCase);      
                                                                 }
            }
        }
        
        //publish values of CareCase to LazyPayDb via AWS    
        if(listOfcaseRecordForPayload != NULL && listOfcaseRecordForPayload.size()>0){    
            action = 'Upsert_Care_Values';    
            uploadPayload(listOfcaseRecordForPayload,action );    
        }
        
        //restrict agents to update Sub status
        restrictUserToTakeActionOnCase(mapOfCaseIDVsCase);
        
        if(lstCase != NULL && lstCase.size()>0){
            // Updated By Kapil 
           //  updateOwnerOnCareCase(lstCase); 
        }
          
        
    }
    
    /**    
@author:            Surender kumar    
@company:           SaaSFocus    
@description:       this method calls the collection and child case methods    
@history    
<Date>                <Authors Name>              <Brief Description of Change>    
04-Jun-19              Surender kumar               created    
**/    
    public static void beforeUpdatecollectionProcess(list<Case> triggerNew, map<Id,Case> TriggeroldMap){    
        list<case> listOfcaseRecordForPayload = new list<case>(); // add by surender for payload    
        Id CollectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();    
        string action = '';    
        for(Case eachCase : triggerNew){    
            Case oldCase = TriggeroldMap.get(eachCase.Id);    
            if(eachCase.RecordTypeId == CollectionRecordTypeId && (eachCase.LP_Manual_Call_Status__c != oldCase.LP_Manual_Call_Status__c     
                                                                   || eachCase.LP_Manual_Call_Sub_Status__c  != oldCase.LP_Manual_Call_Sub_Status__c    
                                                                   || eachCase.Reason_for_Product_intervention__c  != oldCase.Reason_for_Product_intervention__c    
                                                                   || eachCase.LP_Last_Manual_Call_Agent__c  != oldCase.LP_Last_Manual_Call_Agent__c    
                                                                   || eachCase.LP_IVR_Call_Response__c  != oldCase.LP_IVR_Call_Response__c    
                                                                   || eachCase.LP_Manual_Call_Response__c  != oldCase.LP_Manual_Call_Response__c    
                                                                   || eachCase.LP_Next_Scheduled_Call__c  != oldCase.LP_Next_Scheduled_Call__c    
                                                                   || eachCase.LP_Audit_Status__c  != oldCase.LP_Audit_Status__c)){     
                                                                       listOfcaseRecordForPayload.add(eachCase);      
                                                                   }    
        }    
        //publish manual call actions of Collection to LazyPayDb via AWS    
        
        if(listOfcaseRecordForPayload != NULL && listOfcaseRecordForPayload.size()>0){    
            action = 'upsert_Call_Response_Collection';    
            uploadPayload(listOfcaseRecordForPayload,action );    
        }    
    } 
    
    public static void updateOwnerOnCareCase(list<Case> lstCase){
        //get the data from custom metatdata
        map<string,string> mapOfVerticalAndCategoryComboVsQueueId = new map<string,string>();
        String queryStr = 'SELECT Business_Vertical__c,QueueId__c,Duplicate_Criteria__c, Queue_Name__c, Sub_Vertical__c FROM Duplicacy_And_Ownership__mdt';        
        for(Duplicacy_And_Ownership__mdt eachMdt : Database.query(queryStr)){
            mapOfVerticalAndCategoryComboVsQueueId.put(eachMdt.Business_Vertical__c+'_'+eachMdt.Sub_Vertical__c,eachMdt.QueueId__c);
        }
        
        for(Case eachCase : lstCase){
            eachCase.ownerId = mapOfVerticalAndCategoryComboVsQueueId.get(eachCase.LP_Business_Vertical__c+'_'+eachCase.LP_Category__c);
        }
        
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method show error on record if already child case is open/pending 
and agent is going to create another child case or child case is open and agent is going to mark 
resolve the case
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void restrictUserToTakeActionOnCase(map<Id,Case> mapOfCase){
        if(mapOfCase != NULL && mapOfCase.size()>0){
            Set<string> statusValueSet = new Set<string>{'Closed','Tat Exceeded','Resolved'}; //Added by Pooja as per the requirement SFI-932 to give access to mark Resolve to the parent case when child case not closed
            for(Case eachCase : [SELECT id,(SELECT id,status FROM Cases__r WHERE Status Not In :statusValueSet) FROM Case WHERE Id IN:mapOfCase.Keyset()]){
                //for(Case eachCase : [SELECT id,(SELECT id,status FROM Cases__r WHERE status != 'Closed' AND status != 'Tat Exceeded') FROM Case WHERE Id IN:mapOfCase.Keyset()]){
                    if(eachCase.Cases__r != NULL && eachCase.Cases__r.size()>0){
                    if(UserInfo.getUserId()!=Label.systemAdminId && mapOfCase.get(eachCase.Id).status == 'Pending'){
                        mapOfCase.get(eachCase.Id).addError(Label.restrictToUpdateSubStatus);
                    }
                    else if(UserInfo.getUserId()!=Label.systemAdminId && mapOfCase.get(eachCase.Id).status == 'Resolved'){
                        mapOfCase.get(eachCase.Id).addError(Label.RestrictUserToMarkResolve);
                    }
                } 
                
            }
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method calls the care and child case methods
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void afterUpdateCareProcess(list<Case> triggerNew, map<Id,Case> TriggeroldMap){
        set<Id> setOfAccountId = new set<Id>();
        list<Case> lstCareCase = new list<Case>();
        list<Case> lstMerchantCareCase = new list<Case>();
        list<Case> lstBuyerCareCase = new list<Case>();
        list<Case> lstChildCase = new list<Case>();
        
        Id CareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        //Id MCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        Id childCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('ChildCase').getRecordTypeId();
        //Id MerchantchildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
        //Id BuyerCareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
        //Id BuyerCareChildRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCareChild').getRecordTypeId();
        
        for(Case eachCase : triggerNew){
            Case oldCase = TriggeroldMap.get(eachCase.Id);
            if(eachCase.Status =='Pending' && eachCase.LP_Sub_Status__c != oldCase.LP_Sub_Status__c 
               && eachCase.LP_Sub_Status__c != NULL
               && (eachCase.LP_Sub_Status__c != 'Waiting On Customer' && eachCase.LP_Sub_Status__c != 'Waiting On Merchant') && 
               (eachCase.RecordTypeId == CareRecordTypeId)){
                   if(eachCase.RecordTypeId == CareRecordTypeId)
                       lstCareCase.add(eachCase);
                   /*if(eachCase.RecordTypeId == MCRecordTypeId)
                       lstMerchantCareCase.add(eachCase);
                   if(eachCase.RecordTypeId == BuyerCareRecordTypeId)
                       lstBuyerCareCase.add(eachCase);*/
                   if(eachCase.accountId != NULL)
                       setOfAccountId.add(eachCase.accountId);
               }
            
           /* if((eachCase.RecordTypeId == MerchantchildCaseRecordTypeId 
                || eachCase.RecordTypeId == BuyerCareChildRecordTypeId) && eachCase.status=='Closed'){
                   lstChildCase.add(eachCase);
               }
            */
            if(eachCase.RecordTypeId == childCaseRecordTypeId && eachCase.status=='Closed'){
                   lstChildCase.add(eachCase);
               }
            
        }
        //create child case
        if(lstCareCase != NULL && lstCareCase.size()>0){
            createChildCase(lstCareCase,setOfAccountId,'ChildCase');
        }
        //create merchant child case
        /*if(lstMerchantCareCase != NULL && lstMerchantCareCase.size()>0){
            createChildCase(lstMerchantCareCase,setOfAccountId,'MerchantChildCase');
        }
        
        //create buyer child case
        if(!lstBuyerCareCase.isEmpty()){
            createChildCase(lstBuyerCareCase,setOfAccountId,'BuyerCareChild');
        }
        */
        //update child case closed comments on parent case
        if(lstChildCase != NULL && lstChildCase.size()>0){
            updateCaseCommentsOnParent(lstChildCase);
        }
    }
    
    
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to update the case comments and status of parent case 
when child case is closed by agent
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void updateCaseCommentsOnParent(list<Case> lstChildCase){
        system.debug('lstChildCase======'+lstChildCase);
        if(lstChildCase != NULL && lstChildCase.size()>0){
            list<Case> lstParentCase = new list<Case>();
            for(Case eachCase : lstChildCase){
                if(eachCase.Parent_Case__c != NULL && eachCase.Comments != NULL){
                    if(eachCase.isAutoClosed__c){
                        Case objCase = new Case(Id=eachCase.Parent_Case__c,Comments='Child:'+eachCase.Comments,status='Closed',LP_sub_status__c='',IsStopped=false,isSystemEdit__c=true);
                        lstParentCase.add(objCase); 
                    }
                    else if(eachCase.Status=='Closed'){
                        Case objCase = new Case(Id=eachCase.Parent_Case__c,Comments='Child:'+eachCase.Comments,status='Response Received from Other Teams',LP_sub_status__c='',IsStopped=false,isSystemEdit__c=true);
                        lstParentCase.add(objCase);
                    }                    
                }
            }
            system.debug('lstParentCase======'+lstParentCase);
            if(lstParentCase != NULL && lstParentCase.size()>0){
                update lstParentCase;
            }
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to create child case in care process
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void createChildCase(list<Case> lstCareCase,set<Id> setOfAccountId,string recordtype){
        
        list<Case> lstChildCase = new list<Case>();
        
        if(lstCareCase != NULL && lstCareCase.size()>0){
            map<string,string> mapOfSubStatusVsQueueId = new map<string,string>();
            map<string,Child_Case_Queue__mdt> mapOfSubStatusVsQueueMtdt = new map<string,Child_Case_Queue__mdt>();
            map<Id,Id> mapOfAccountIdVsEntitlementId = new map<Id,Id>();
            //get the child entitlement
            if(setOfAccountId != NULL && setOfAccountId.size()>0){
                for(Entitlement eachEntitlement : [SELECT id,accountId FROM Entitlement WHERE accountID IN:setOfAccountId AND Name='Child Entitlement']){
                    mapOfAccountIdVsEntitlementId.put(eachEntitlement.accountId,eachEntitlement.Id);
                }
            }
            
            //get the metadata value to assign case to queue
            for(Child_Case_Queue__mdt eachMdt : [Select id,MasterLabel,SubStatus__c,QueueId__c,Queue_Manager_Id__c FROM Child_Case_Queue__mdt]){
                mapOfSubStatusVsQueueMtdt.put(eachMdt.SubStatus__c,eachMdt);
            }
            System.debug('mapOfSubStatusVsQueueMtdt======'+mapOfSubStatusVsQueueMtdt);
            if(mapOfSubStatusVsQueueMtdt != NULL && mapOfSubStatusVsQueueMtdt.size()>0){
                Id ChildCaseRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
                
                for(Case eachCase : lstCareCase){
                    Case objChildCase = new Case();
                    Child_Case_Queue__mdt objMtdt = mapOfSubStatusVsQueueMtdt.get(eachCase.LP_Sub_Status__c);
                    if(!Test.isRunningTest()){
                    objChildCase.ownerId = objMtdt.QueueId__c;
                    
                    if(objMtdt.Queue_Manager_Id__c != NULL)
                        objChildCase.Queue_Manager__c = objMtdt.Queue_Manager_Id__c;
                    }
                    objChildCase.recordtypeID = ChildCaseRecordTypeId;
                    objChildCase.Subject = eachCase.Subject;
                    objChildCase.Origin = eachCase.Origin;
                    objChildCase.Comments = eachCase.Comments;
                    objChildCase.LP_Category__c = eachCase.LP_Category__c;
                    objChildCase.LP_Business_Vertical__c = eachCase.LP_Business_Vertical__c;
                    objChildCase.ContactId = eachCase.ContactId;
                    if(eachCase.AccountId != NULL)
                        objChildCase.EntitlementId = mapOfAccountIdVsEntitlementId.get(eachCase.AccountId);
                    //objChildCase.LP_Details__c = eachCase.LP_Details__c;
                    //objChildCase.LP_Sub_Details__c = eachCase.LP_Sub_Details__c;
                    objChildCase.Parent_Case__c = eachCase.id;
                    objChildCase.ParentId = eachCase.id;
                    if(!Test.isRunningTest()){
                    objChildCase.LOB_Name__c = objMtdt.MasterLabel.removeStart('Waiting On ');
                    }
                    lstChildCase.add(objChildCase);
                }
            }
        }
        if(!Test.isRunningTest()){
        if(lstChildCase != null && lstChildCase.size()>0){
            insert lstChildCase;
        }
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to create contact in email to case
@history
<Date>                <Authors Name>              <Brief Description of Change>
26-FEB-19              Eitika Verma               created
**/
    public static void createContactInEmailToCase(list<Case> Triggernew){
        List<String> emailAddresses = new List<String>();
        Set<String> takenEmails = new Set<String>();
        map<string,list<Id>> mapOfEmailVsListOfContact = new map<string,list<Id>>();
        
        //First exclude any cases where the contact is set
        Id CareRecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Care').getRecordTypeId();
        system.debug('Triggernew======='+Triggernew);
        for (Case caseObj:Triggernew) {
            if (caseObj.recordtypeID!= null && caseObj.recordtypeID == CareRecordTypeId && caseObj.ContactId==null && caseObj.SuppliedEmail != NULL)
            {
                emailAddresses.add(caseObj.SuppliedEmail);
            }
        }
        system.debug('emailAddresses======='+emailAddresses);
        //collect contact email address in email
        if(emailAddresses != NULL && emailAddresses.size()>0){
            List<Contact> listContacts = [Select Id,Email From Contact Where Email in :emailAddresses limit 50000];
            for (Contact c:listContacts) {
                mapOfEmailVsListOfContact.put(c.Email,new list<Id>());
                mapOfEmailVsListOfContact.get(c.Email).add(c.Id);
                takenEmails.add(c.Email);
            }
        }
        
        System.debug('takenEmails======'+takenEmails);
        Map<String,Contact> emailToContactMap = new Map<String,Contact>();
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case caseObj:Triggernew) {
            if (caseObj.recordtypeID!= null && caseObj.recordtypeID == CareRecordTypeId && caseObj.ContactId==null &&
                caseObj.SuppliedName!=null &&
                caseObj.SuppliedEmail!=null &&
                caseObj.SuppliedName!='' &&
                !caseObj.SuppliedName.contains('@') &&
                caseObj.SuppliedEmail!='' &&
                !takenEmails.contains(caseObj.SuppliedEmail)){
                    //The case was created with a null contact
                    //Let's make a contact for it
                    String[] nameParts = caseObj.SuppliedName.split(' ',2);
                    if (nameParts.size() == 2)
                    {
                        Contact cont = new Contact(FirstName=nameParts[0],
                                                   LastName=nameParts[1],
                                                   Email=caseObj.SuppliedEmail
                                                  );
                        emailToContactMap.put(caseObj.SuppliedEmail,cont);
                        casesToUpdate.add(caseObj);
                    }
                }
            else if (caseObj.recordtypeID!= null && caseObj.recordtypeID == CareRecordTypeId && caseObj.ContactId==null &&
                     caseObj.SuppliedPhone != ''&&
                     caseObj.SuppliedEmail!='' &&
                     !takenEmails.contains(caseObj.SuppliedEmail)){
                         //The case was created with a null contact
                         //Let's make a contact for it
                         Contact cont = new Contact(LastName=caseObj.SuppliedPhone,
                                                    Email=caseObj.SuppliedEmail
                                                   );
                         emailToContactMap.put(caseObj.SuppliedEmail,cont);
                         casesToUpdate.add(caseObj);
                         
                     }
            
            else if(caseObj.recordtypeID!= null && caseObj.recordtypeID == CareRecordTypeId && caseObj.ContactId==null &&
                    caseObj.SuppliedName!=null &&
                    caseObj.SuppliedEmail!=null &&
                    caseObj.SuppliedName!='' &&
                    !caseObj.SuppliedName.contains('@') &&
                    caseObj.SuppliedEmail!='' &&
                    takenEmails.contains(caseObj.SuppliedEmail) &&
                    mapOfEmailVsListOfContact != NULL &&
                    mapOfEmailVsListOfContact.size()>0 &&
                    mapOfEmailVsListOfContact.get(caseObj.SuppliedEmail) != NULL && 
                    mapOfEmailVsListOfContact.get(caseObj.SuppliedEmail).size()>0){
                        caseObj.ContactId = mapOfEmailVsListOfContact.get(caseObj.SuppliedEmail)[0];
                    }
        }
        
        List<Contact> newContacts = emailToContactMap.values();
        insert newContacts;
        System.debug('newContacts======'+newContacts);
        for (Case caseObj:casesToUpdate) {
            Contact newContact = emailToContactMap.get(caseObj.SuppliedEmail);
            
            caseObj.ContactId = newContact.Id;
        }
    }
    
    /**
@author:            Surender Kumar
@company:           SaaSFocus
@description:       this method calls from before update for KYC line number 101 
@history
<Date>                <Authors Name>              <Brief Description of Change>
15-may-19              Surender Kumar               created
**/
    public static Task updateManualCallResponseOnTask(string subject, string Manualcallresponse , Id caseID, PayloadActMap__mdt Payloadcustomrecordvalue){    
        task objtask = new task ();
        Objtask.WhatId = caseID;
        Objtask.Subject = subject;
        
        System.debug('Manual Call Reponse : ' + Manualcallresponse );
        map<string,string> mapOfManualCallResponse = (Map<String, String>)JSON.deserialize(Manualcallresponse, Map<String, String>.class);
        
        map<string , string> mapOfPayloadValue = (Map<String, String>)JSON.deserialize(Payloadcustomrecordvalue.JsonMap__c, Map<String, String>.class);
        system.debug('mapOFpayloadvalue'+mapOFpayloadvalue);
        for( string eachRespValue : mapOfManualCallResponse.keySet()){
            CareUtility.populateField(objtask,eachRespValue,mapOfPayloadValue.get(eachRespValue),
                                      mapOfManualCallResponse.get(eachRespValue),'Task');
        }
        system.debug('task=========='+objtask);
        return objtask;
        
    }
    /**
@author:            Surender Kumar
@company:           SaaSFocus
@description:       this method calls from before update record  
@history
<Date>                <Authors Name>              <Brief Description of Change>
15-may-19              Surender Kumar               created
**/
    
    public static void uploadPayload(list<case> caselist, string actionName)
    {
        system.debug('actionName***'+ actionName);
        list<PayloadActMap__mdt> lstOfPayloadMtdt = SystemUtility.getAllFieldsOfObject(actionName,'PayloadActMap__mdt','DeveloperName');
        map<string,string> mapOfPayloadKeyValue = (Map<String,String>)JSON.deserialize(lstOfPayloadMtdt[0].JsonMap__c, Map<String,String>.class);
        for(case eachcase : caselist){
            map<string,string> mapOfPayloadValue = new map<string,string>();
            Map<String, Object> finalPayLoadMap = new Map<String, Object>();
         /*   for (string payloadvalue :mapOfPayloadKeyValue.keyset()){
                string fieldAPIName = mapOfPayloadKeyValue.get(payloadvalue).SubStringBefore(',');
                if(eachcase.get(fieldAPIName)!= null ){
                    system.debug('apiname**'+ payloadvalue);  
                    system.debug('value**'+ eachcase.get(fieldAPIName));
                    string Fieldvalue = String.valueOf(eachcase.get(fieldAPIName));
                    mapOfPayloadValue.put(fieldAPIName,Fieldvalue);
                }
            } 
         */
            // Changed BY kapil Chauhan 11-10-2019  
            for (string payloadvalue :mapOfPayloadKeyValue.keyset()){
                string fieldAPIName = mapOfPayloadKeyValue.get(payloadvalue).SubStringBefore(',');
                if(eachcase.get(fieldAPIName)!= null ){
                    system.debug('apiname**'+ payloadvalue);  
                    system.debug('value**'+ eachcase.get(fieldAPIName));
                    string Fieldvalue = String.valueOf(eachcase.get(fieldAPIName));
                    mapOfPayloadValue.put(String.valueOf(payloadvalue),Fieldvalue);
                }
            } 
            
            finalPayLoadMap.put('business_object','Customer');
            finalPayLoadMap.put('action',actionName);
            finalPayLoadMap.put('producer','Salesforce');
            finalPayLoadMap.put('product','Collection');
            finalPayLoadMap.put('identifier','null');
            finalPayLoadMap.put('current_data',mapOfPayloadValue);
            finalPayLoadMap.put('timestamp', System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));
            string payloaddata = JSON.serialize(finalPayLoadMap);
            system.debug('payloaddata' + payloaddata);
            if(!Test.isRunningTest()){
            lazyPayPublish.PublishDataToLPDB(payloaddata,actionName);
            }
            
            
        }
    }
    
    /*public static List<Case> updateLOBname(List<Case> triggerNew){
        Id MCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        Id BCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
        Map<Id,String> case_userQueueIdMap = New Map<Id,String>();
        List<Case> updatedCase = New List<case>();
        getCurrentQueueName(case_userQueueIdMap);
        for(Case newCase : triggerNew){
            if(newCase.RecordTypeId == MCRecordTypeId || newCase.RecordTypeId == BCRecordTypeId){
                if(string.isNotBlank(newCase.OwnerId) && String.isBlank(newCase.ParentId)){                
                    Case cs = New Case(Id=newCase.Id);
                    if(!case_userQueueIdMap.isEmpty() && case_userQueueIdMap.containsKey(newCase.OwnerId) &&
                       string.valueOf(newCase.OwnerId).startswith('005')){                           
                           cs.LOB_Name__c = case_userQueueIdMap.get(newCase.OwnerId);
                       }else if(string.valueOf(newCase.OwnerId).startswith('00G')){
                           cs.LOB_Name__c = newCase.Owner__c;
                       } 
                    updatedCase.add(cs);
                }
            }
        }
        return updatedCase;
    }*/
    
   /* public static Map<Id,String> getCurrentQueueName(Map<Id,String> case_userQueueIdMap){
        Set<Id> caseGroupIds = New Set<Id>();
        List<QueueSobject> qsObject = [Select Id,QueueId from QueueSobject where sObjectType=:'Case'];
        for(QueueSobject qs : qsObject){
            if(string.isNotBlank(qs.QueueId)) caseGroupIds.add(qs.QueueId);
        }
        For(GroupMember gm : [SELECT Id, GroupId,group.name, UserOrGroupId FROM GroupMember where GroupId IN: caseGroupIds]){
            if(String.isNotBlank(gm.UserOrGroupId)){
                case_userQueueIdMap.put(gm.UserOrGroupId,gm.Group.Name);
            }
        } 
        system.debug('#### case queue map '+case_userQueueIdMap);
        return case_userQueueIdMap;
    }
    */
    // get ownerId with managerId
    /*public static void getCurrentUserManagerId(List<Case> triggerNew, Map<Id,Id> ownerwithManagerIdMap){
        Set<string> userIds = New Set<String>();
        for(Case cs : triggerNew){
            if(string.isNotBlank(cs.OwnerId) && string.valueOf(cs.OwnerId).startsWith('005')){
                userIds.add(cs.OwnerId);
            }
        }
        List<User> users = [Select Id, ManagerId from user where Id IN: userIds];
        for(User u : users){
            ownerwithManagerIdMap.put(u.Id,u.ManagerId); 
        }
        system.debug('##### owner with manager id '+ownerwithManagerIdMap);
    }*/

    
    /*
  this method is used to create manual call responce if outstanding <= 0 ; 
  
   */   
    
    Public static void CreateManualCallresponce(list<Case> triggerNew,map<Id,Case> TriggeroldMap){
        Id CollectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
        list<Manual_Call_Detail__c> listofmanualcalldetail = new list<Manual_Call_Detail__c>();
        Map<string, Id> MapQueuebyID = new Map<string, Id>();
        list<String> lstQueue = new list<string>();
        lstQueue.add('LP_Manual_Call_Queue_Collection');
        MapQueuebyID = systemutility.getQueuesInfo(lstQueue);
        Id queueID = MapQueuebyID.get('LP_Manual_Call_Queue_Collection');
        system.debug('id'+ queueID);
     map<string , string> mapOfAgencynamewithCode = new map<string , string>();
     map<string , string> mapOfAgencynamewithOpsPanelKey = new map<string , string>();
     Map<Id,Agency__c> mapOfAgencyIdVsAgency = new Map<Id,Agency__c>();  
     //list<Agency__c> listOfAgency = [select id,Name,Agency__c,Agency_Code__c,Ops_Panel_Key__c from Agency__c];
       list<Agency__c> listOfAgency = [select id,Name,Agency_Code__c,Ops_Panel_Key__c ,Agency_Owner__c from Agency__c];  
       system.debug('listOfAgency'+ listOfAgency);
     for(Agency__c eachAgency: listOfAgency){
        mapOfAgencynamewithCode.put(eachAgency.name, eachAgency.Agency_Code__c);
        mapOfAgencynamewithOpsPanelKey.put(eachAgency.name, eachAgency.Ops_Panel_Key__c);
        mapOfAgencyIdVsAgency.put(eachAgency.Id, eachAgency); 
        
    }
        for(Case eachCase : triggerNew){
            Case oldCase = TriggeroldMap.get(eachCase.Id);
            System.debug('string.isNotBlank(eachCase.Agency__c)****' + string.isNotBlank(eachCase.Agency__c));
            if((eachCase.LP_Outstanding_Amount__c == 0 ||eachCase.LP_Outstanding_Amount__c < 0) && eachCase.LP_Outstanding_Amount__c !=  oldCase.LP_Outstanding_Amount__c
               && eachCase.RecordTypeId == CollectionRecordTypeId && eachCase.Status == 'Closed'  && (eachCase.Agency__c != null  || string.isNotBlank(eachCase.Agency__c) )) {
               System.debug('Create Manual call Details');   
               //if((eachCase.LP_Outstanding_Amount__c == 0 ||eachCase.LP_Outstanding_Amount__c < 0) && eachCase.LP_Outstanding_Amount__c !=  oldCase.LP_Outstanding_Amount__c
               //&& eachCase.RecordTypeId == CollectionRecordTypeId && eachCase.Status == 'Closed'  ) {    
                   Manual_Call_Detail__c objmanualcall = new Manual_Call_Detail__c();
                  // objmanualcall.Outstanding_Amount__c = eachCase.LP_Outstanding_Amount__c;
                  // objmanualcall.AGENCY_CODE__c =  mapOfAgencynamewithCode.get(eachCase.Agency__c);
                  //  objmanualcall.OPS_Panel_Key__c = mapOfAgencynamewithOpsPanelKey.get(eachCase.Agency__c);
                  // objmanualcall.Agency__c = eachCase.Agency__c;                 
                   objmanualcall.Case__c   =  eachCase.id;
                   //objmanualcalldeatil.Due_Date__c     =
                   //objmanualcall.Due_Since__c    =  string.valueOf(eachCase.LP_Due_Since__c) ;
                  // objmanualcall.Contact_Name__c = eachCase.Contact.Name;
                  //objmanualcall.Contact_Name__c = eachCase.Contact_Name__c;                    
                   //objmanualcall.Email__c        =  eachCase.contact.Email;
                   //objmanualcall.Email__c        =  eachCase.ContactEmail;
                   objmanualcall.ApiStatus__c      =  true;
                  // objmanualcall.InQueue__c    = true;
                   //objmanualcall.Late_Fee_Amount__c =  string.valueOf(eachCase.LP_Late_fee_amount__c);
                   //objmanualcall.mobile__c = eachCase.ContactMobile;
                   //objmanualcall.OPS_Panel_Key__c =
                   //objmanualcall.Outstanding_Amount__c =  eachCase.LP_Outstanding_Amount__c;
                   //objmanualcall.Payment_Link__c = eachCase.LP_Mobile_Pay_URL__c;
                    //objmanualcall.Case_status__c = eachCase.Status;
                   //objmanualcall.LP_Total_Late_Fee__c = eachCase.LP_Total_Late_Fee__c;
                   objmanualcall.RevokeQueue__c = true;
                   if(eachCase.LP_Agency__c != null && mapOfAgencyIdVsAgency.containsKey(eachCase.LP_Agency__c) && mapOfAgencyIdVsAgency.get(eachCase.LP_Agency__c) != null &&
                     mapOfAgencyIdVsAgency.get(eachCase.LP_Agency__c).Agency_Owner__c != null ){
                       System.debug('OwnerId >>>>>>>' + eachCase.LP_Agency__r.Agency_Owner__c);
                     objmanualcall.OwnerId = mapOfAgencyIdVsAgency.get(eachCase.LP_Agency__c).Agency_Owner__c;  
                   }                   
                   //objmanualcall.UUID__c = eachCase.LP_UUID_For_Collection__c; 
                   listofmanualcalldetail.add(objmanualcall);
               }
            
        }
        if (listofmanualcalldetail.size() > 0){
            system.debug('!!!!@@'+ listofmanualcalldetail);
            if(label.LP_Create_Manual_Call_Detail == 'Y'){
              insert listofmanualcalldetail;   
            }
                       
        }
      }   
       /**    
        @author:            Kapil Chauhan   
        @company:           SaaSFocus    
        @description:       this method is used to update "IVR-Id" based on "Communication Sub-Type"    
        @history    
        <Date>                <Authors Name>              <Brief Description of Change>    
        19-09-19              Kapil Chauhan               created    
      **/   
      public static void updateIvrIdWithType(List<Case> newList , Map<Id,Case> oldMap){
         Id CollectionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
          //System.debug('REcord Type Id : ' + CollectionRecordTypeId);
          for(Case caseObj : newList){
              if(caseObj.RecordTypeId == CollectionRecordTypeId && Trigger.IsInsert && caseObj.LP_Communication_Sub_Type__c != null && IVR_Type_To_IVR_Id__c.getValues(caseObj.LP_Communication_Sub_Type__c) != null && String.isNotBlank(IVR_Type_To_IVR_Id__c.getValues(caseObj.LP_Communication_Sub_Type__c).IVR_Id__c)){
                 caseObj.LP_IVR_Id__c = IVR_Type_To_IVR_Id__c.getValues(caseObj.LP_Communication_Sub_Type__c).IVR_Id__c;
              }
              //else if( Trigger.IsInsert && String.isBlank(caseObj.LP_Communication_Sub_Type__c)  && caseObj.RecordTypeId == CollectionRecordTypeId && IVR_Type_To_IVR_Id__c.getValues(label.Default_Communication_Sub_Type) != null  && String.isNotBlank(IVR_Type_To_IVR_Id__c.getValues(label.Default_Communication_Sub_Type).IVR_Id__c)){
              //   caseObj.LP_IVR_Id__c = IVR_Type_To_IVR_Id__c.getValues(label.Default_Communication_Sub_Type).IVR_Id__c; 
              //}
              if(caseObj.RecordTypeId == CollectionRecordTypeId && Trigger.IsUpdate &&  caseObj.LP_Communication_Sub_Type__c != oldMap.get(caseObj.Id).LP_Communication_Sub_Type__c && IVR_Type_To_IVR_Id__c.getValues(caseObj.LP_Communication_Sub_Type__c) != null && String.isNotBlank(IVR_Type_To_IVR_Id__c.getValues(caseObj.LP_Communication_Sub_Type__c).IVR_Id__c)){                 
                 System.debug('Update IVr Id : ' + IVR_Type_To_IVR_Id__c.getValues(caseObj.LP_Communication_Sub_Type__c).IVR_Id__c );
                 caseObj.LP_IVR_Id__c = IVR_Type_To_IVR_Id__c.getValues(caseObj.LP_Communication_Sub_Type__c).IVR_Id__c ; 
              } 
          }
     }
    
      /**    
        @author:            Kapil Chauhan   
        @company:           SaaSFocus    
        @description:       This method is used to restrict the agents to resolve the case if newest incoming email is unread    
        @history    
        <Date>                <Authors Name>              <Brief Description of Change>    
        26-01-2020              Kapil Chauhan               created    
      **/
    
        public static void StopMarkingCaseAsResolved(List<Case> newList , Map<Id,Case> oldMap){
        Set<Id> caseSet = new Set<Id>();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMap = new Map<Id,Case>();    
        for(Case caseObj : newList){
            System.debug('REcord Type check >>>' + label.LP_CAN_NOT_MARK_RESOLVE_VALIDATION_RECORD_TYPE.split(';').contains(caseObj.Record_Type__c));
            if(caseObj.status == 'Resolved' && caseObj.status != oldMap.get(caseObj.Id).status && label.LP_CAN_NOT_MARK_RESOLVE_VALIDATION_RECORD_TYPE.split(';').contains(caseObj.Record_Type__c)){
               caseSet.add(caseObj.Id); 
               caseList.add(caseObj); 
            }
        }      
            for(Case caseObj : [select id , Is_Duplicate__c,(select id , status , Incoming , parentId, messagedate FRom EmailMessages where Incoming = true order by messagedate desc) from Case where Is_Duplicate__c = false and id IN : caseSet]){
               caseMap.put(caseObj.Id , caseObj); 
            }  
       for(Case CaseObj : caseList){
           if(caseMap.get(CaseObj.Id).EmailMessages.size() > 0){
               System.debug('Message list size >>' +  caseMap.get(CaseObj.Id).EmailMessages.size());
               System.debug('LatestEmail Message >>' + caseMap.get(CaseObj.Id).EmailMessages[0]);
               if(caseMap.get(CaseObj.Id).EmailMessages[0].status == '0'){
                 CaseObj.addError(Label.LP_CAN_NOT_MARKED_RESOLVED);    
               } 
           }
       } 
    }
    
      /**    
        @author:            Kapil Chauhan   
        @company:           SaaSFocus    
        @description:       This method is used to restrict the agents to resolve the case if any of the incoming email is unread    
        @history    
        <Date>                <Authors Name>              <Brief Description of Change>    
        26-01-2020              Kapil Chauhan               created    
      **/
    
   /*     public static void StopMarkingCaseAsResolved2(List<Case> newList , Map<Id,Case> oldMap){
        Set<Id> caseSet = new Set<Id>();
        List<Case> caseList = new List<Case>();
        for(Case caseObj : newList){
            System.debug('REcord Type check >>>' + label.LP_CAN_NOT_MARK_RESOLVE_VALIDATION_RECORD_TYPE.split(';').contains(caseObj.Record_Type__c));
            if(caseObj.status == 'Resolved' && caseObj.status != oldMap.get(caseObj.Id).status && label.LP_CAN_NOT_MARK_RESOLVE_VALIDATION_RECORD_TYPE.split(';').contains(caseObj.Record_Type__c)){
               caseSet.add(caseObj.Id); 
            }
        }      
       caseList =  [select id ,(select id , status , Incoming , parentId, messagedate FRom EmailMessages where Incoming = true and status = '0' ) from Case where id IN : caseSet];
       for(Case CaseObj : caseList){
           if(CaseObj.EmailMessages.size() > 0){
              CaseObj.addError(Label.LP_CAN_NOT_MARKED_RESOLVED);    
           }
       } 
    }
   */
    
    
}