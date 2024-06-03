@RestResource(urlMapping='/api/Onecare/*')
global class OneCareService {
    static Id CaseId;
    static string strEmail;
    static string strMobile;
    static string strUUID;
    static map<string,string> mapOfResponse;
    public static string strRecordType;
    public static boolean contactExistFlag = false ;
    
    @HttpPost
    global static void createCaseAndContact(string currentData) {
        //custom setting to hide and show the debug log 
        //SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        //if(logIntiator.IsShow_Debug_Logs__c){
         //   system.debug('currentData========='+currentData);}
        Case objCase;
        Account objAcc;
        Contact objCon;
        string strRepsone;
        Id entitlementId;
        list<Attachment> lstAttachment;
        Payload_Log__c theLog = new Payload_Log__c();
        list<Case> lstOfUpsertCase = new list<Case>();        
        
        if(String.isNotBlank(currentData)){
            try{ 
                //get the mappings from custom metadata
                map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload = CareUtility.getPayloadData('MerchantCareCreate');
                
                //deserialize the json string
                Map<String, Object> jsonRequestDataMap = (Map<String, Object>)JSON.deserializeUntyped(currentData);
               /* if(logIntiator.IsShow_Debug_Logs__c){
                    system.debug('jsonRequestDataMap======='+jsonRequestDataMap);
                    system.debug('jsonRequestDataMap======='+jsonRequestDataMap.keyset());
                }*/
                //get the recordtype name
                
                if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('RecordTypeName')){
                    strRecordType = String.ValueOf(jsonRequestDataMap.get('RecordTypeName'));
                    //create logs of consumer
                    theLog = new Payload_Log__c(Producer__c = 'MerchantCare',Business_Object__c = 'Customer',Action__c = 'Upsert_MerchantCare_Case',Process__c = 'Merchant Care',Payload__c = currentData);
                }
                
                if(mapOfObjectNameVsPayload != NULL && mapOfObjectNameVsPayload.size()>0){
                    //upsert account records
                    if(mapOfObjectNameVsPayload.containsKey('Account')){
                        objAcc = (Account)populateObjectData('Account',mapOfObjectNameVsPayload,jsonRequestDataMap);
                    }
                    
                    //upsert contact records
                    if(mapOfObjectNameVsPayload.containsKey('Contact')){
                        objCon = (Contact)populateObjectData('Contact',mapOfObjectNameVsPayload,jsonRequestDataMap);
                        /*if(logIntiator.IsShow_Debug_Logs__c){
                            System.debug('Contact To Insert : ' + objCon); }
                        */
                    }                   
                    
                    //upsert Case records
                    if(mapOfObjectNameVsPayload.containsKey('Case')){
                        objCase = (Case)populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                        objCase.status = 'New';
                        objCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordType).getRecordTypeId();
                        objCase.Comments = objCase.LP_Issue_description__c;
                        lstOfUpsertCase = checkExistingCase(objCase,objCon,lstOfUpsertCase,strRecordType);                        
                    }
                    
                    //create attachment records
                    if(mapOfObjectNameVsPayload.containsKey('Attachment')){
                        lstAttachment = prepareAttachments(jsonRequestDataMap,mapOfObjectNameVsPayload,lstAttachment);
                    }
                   /* if(logIntiator.IsShow_Debug_Logs__c){
                        system.debug('lstOfUpsertCase======='+lstOfUpsertCase);  
                        system.debug('lstOfUpsertCase.size()====='+lstOfUpsertCase.size());
                    }
                    */
                    
                    //perform DML operations
                    
                    if(lstOfUpsertCase != NULL && lstOfUpsertCase.size()>1){
                        List<Case> caseListToUpsert = new List<Case>();
                        Case oCase;
                        
                        for(Case caseObj : lstOfUpsertCase){
                            if(caseObj.Status != 'Closed'){
                                oCase =  caseObj;
                                System.debug('NOt Closed case **' + oCase);  
                            }else{
                                System.debug('Closed Cases **' + caseObj); 
                                caseListToUpsert.add(caseObj); 
                            }
                        }                        
                        //System.debug('There is already a existing case , that why list size is > 1' + lstOfUpsertCase.size());
                        
                        if(oCase.AccountId != NULL){
                            objAcc.id = oCase.AccountId;
                        }
                        
                        if(objCon.AccountId != NULL){
                            objAcc.id = objCon.AccountId;
                        }
                        
                        //system.debug('objAcc======='+objAcc);
                        upsert objAcc;
                        
                        //create entitlement record
                        entitlementId = createEntitlement(objAcc,oCase,strRecordType); 
                        
                        objCon.accountId = objAcc.Id;
                        upsert objCon;
                        if(oCase.ContactId != null){
                            oCase.ContactId = objCon.Id;
                        } 
                        caseListToUpsert.add(oCase);
                        
                        list<Case> lstCase = new list<Case>();
                        lstCase.addAll(caseListToUpsert);
                        caseListToUpsert.clear();
                        for(Case eachCase : lstCase){
                            if(eachCase.EntitlementId != NULL && entitlementId != NULL)
                                eachCase.EntitlementId = entitlementId;
                            caseListToUpsert.add(eachCase);
                        }                        
                        upsert caseListToUpsert;     
                    }
                    
                    else if(lstOfUpsertCase != NULL && lstOfUpsertCase.size() == 1){
                        Case oCase = lstOfUpsertCase[0];
                        //upsert account
                        if(objCon.accountid != NULL) 
                            objAcc.id = objCon.accountid;
                        upsert objAcc;
                        
                        //create entitlement record
                        entitlementId = createEntitlement(objAcc,oCase,strRecordType); 
                        
                        //upsert contact
                        objCon.accountId = objAcc.Id;
                        if(objCon.LastName == NULL)
                            objCon.LastName = objCon.MobilePhone; 
                        /*if(logIntiator.IsShow_Debug_Logs__c){
                            System.debug('Upsert Contact : ' + objCon);}*/
                        upsert objCon  ;
                        
                        //upsert case
                        oCase.ContactId = objCon.Id;
                        oCase.AccountId = objAcc.Id;
                        
                        //case EntitlementCase = lstOfUpsertCase[0];
                        //system.debug('oCase.EntitlementId===='+oCase.EntitlementId);
                        if(string.isBlank(oCase.EntitlementId)) oCase.EntitlementId = entitlementId;
                        upsert oCase;
                        //system.debug('oCase========'+oCase);
                        CaseId = oCase.id;
                    }
                    //upsert attachment
                    list<attachment> lstAttach = new list<attachment>();
                    for(Attachment eachAttachment: lstAttachment){
                        //update parentId
                        if(lstOfUpsertCase != NULL && lstOfUpsertCase.size() > 1)
                            eachAttachment.parentId = lstOfUpsertCase[0].id;
                        else
                            eachAttachment.parentId = CaseId;
                        lstAttach.add(eachAttachment);
                    }
                    
                    if(lstAttach != null && lstAttach.size()>0)
                        upsert lstAttach;                                    
                    
                    //system.debug('Test Case id@@'+CaseId);
                    if(CaseId != Null){
                        
                        list<Case> lstFetchedCase = [SELECT casenumber,status,Identifier__c,Expected_Closure_Date__c FROM Case WHERE id=:CaseId]; 
                        //system.debug('lstFetchedCase==='+lstFetchedCase);
                        //prepare return response
                        mapOfResponse = new map<string,string>();
                        mapOfResponse.put('State','Success');
                        if(lstFetchedCase!= NULL && lstFetchedCase.size()>0){
                            mapOfResponse.put('caseNumber',lstFetchedCase[0].casenumber);
                            mapOfResponse.put('caseStatus',lstFetchedCase[0].status);
                            mapOfResponse.put('identifier',lstFetchedCase[0].Identifier__c);
                            if(String.isNotBlank(strRecordType)){
                                /*if(logIntiator.IsShow_Debug_Logs__c){
                                    system.debug('Expected_Closure_Date__c========'+lstFetchedCase[0].Expected_Closure_Date__c);}
								*/
                                if(lstFetchedCase[0].Expected_Closure_Date__c != NULL){
                                    DateTime dt = lstFetchedCase[0].Expected_Closure_Date__c;
                                    string strDtime = dt.formatGMT('yyyy-MM-dd HH:mm:ss');
                                    mapOfResponse.put('Expected Closure Date',strDtime);
                                }else{
                                    String tempDate = String.valueOf(System.now()+3);
                                    mapOfResponse.put('Expected Closure Date',tempDate);
                                }                               
                            }                           
                        }
                        
                        RestResponse res = RestContext.response; 
                        if(Test.isRunningTest()){res = new RestResponse();}
                        res.addHeader('Content-Type', 'Application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                        res.statusCode = 200;
                    }
                    theLog.Status__c = 'SUCCESS';    
                    //if(Test.isRunningTest()){
                        CareUtility.populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                    //}
                }
            }
            
            catch(Exception ex){
                theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); 
                theLog.Status__c = 'Error';
                
                map<string,string> mapOfResponse = new map<string,string>();
                mapOfResponse.put('State','Error');
                mapOfResponse.put('message',ex.getMessage());
                mapOfResponse.put('Stack Trace',ex.getStackTraceString());
                mapOfResponse.put('Line No',string.valueOf(ex.getLineNumber()));
                RestResponse res = RestContext.response; 
                if(Test.isRunningTest())
                    res = new RestResponse();
                res.addHeader('Content-Type', 'Application/json');                
                res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                res.statusCode = 500;                
            }
            if(strRecordType != null)
                insert theLog;            
        }        
    } 
    
    public static void populateField(SObject sobToUpsert,String node,String fieldApi,String data){
        //custom setting to hide and show the debug log 
       /* SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        if(logIntiator.IsShow_Debug_Logs__c){*/
            System.debug('node========='+node);
        if(String.isNotBlank(fieldApi) && String.isNotBlank(data)){
            
            if(node == 'MerchantName'){
                if(data.length() > 79 ){
                system.debug('data.substring(0, 79)'+data.substring(0, 79));
                    data=data.substring(0, 79);}
           }
            if(fieldAPI.subStringAfter(',') == 'Date'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Date.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'DateTime'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),DateTime.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'Decimal'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Decimal.valueOf(data));
            }
            else{
                if(node == 'Issue')
                    sobToUpsert.put('Subject',data);
                else if(node == 'Mobile'){
                    strmobile = data;
                    if(!strmobile.startsWith('+91')){
                        strmobile = '+91'+ data;
                    }
                }
                else if(node == 'Email')
                    strEmail = data;
                else if(node == 'UUID')
                    strUUID = data;
                
                if(node == 'body'){
                    blob attachBody = EncodingUtil.base64Decode(data);
                    sobToUpsert.put(fieldAPI.subStringBefore(','),attachBody);
                }
                else{
                    sobToUpsert.put(fieldAPI.subStringBefore(','),data);
                }                
            }
        }
    }    
    
    public static SObject populateObjectData(string sObjectName,map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload,Map<String, Object> jsonRequestDataMap){
        //custom setting to hide and show the debug log 
        //SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject() ;                                  
        string accmapVal = mapOfObjectNameVsPayload.get(sObjectName).JsonMap__c;
        map<string,string> mapOfAccountmapping = (Map<String, String>)JSON.deserialize(accmapVal, Map<String, String>.class);
        if(mapOfAccountmapping != NULL && mapOfAccountmapping.size()>0){
            for(string strNode : mapOfAccountmapping.keyset()){
                if(jsonRequestDataMap!= NULL && jsonRequestDataMap.size()>0 && jsonRequestDataMap.containsKey(strNode)){
                    populateField(sObj,strNode,mapOfAccountmapping.get(strNode),String.valueOf(jsonRequestDataMap.get(strNode)));
                }
            }
        }
        
        if(sObjectName == 'Contact'){
            /*if(logIntiator.IsShow_Debug_Logs__c){*/
                System.debug('Check for existing contact information : email ' + strEmail + 'UUID : ' + strUUID + 'strMobile:' +strMobile + 'sObj' + sObj);
            
sObj = checkExistingContact(strEmail,strUUID,strMobile,sObj);
        }
        /*if(logIntiator.IsShow_Debug_Logs__c){*/
            system.debug('sObj=========='+sObj);
        return sObj;
    }
    
    private static SObject checkExistingContact(string strEmail, string strUUID, string strMobile, SObject sobj){
        //custom setting to hide and show the debug log 
        //SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        if(String.isNotBlank(strEmail)){
            string strQuery = 'SELECT id,accountid,MobilePhone,Identifier__c,email FROM Contact';
            if(String.isNotBlank(strUUID)){
               /* if(logIntiator.IsShow_Debug_Logs__c){
                    System.debug('strUUID'+ strUUID);}*/
                strQuery += ' WHERE Identifier__c=:strUUID';
            }
            else{
                if(String.isNotBlank(strMobile)){
                   /* if(logIntiator.IsShow_Debug_Logs__c){
                        System.debug('strMobile : ' + strMobile);}*/
                    strQuery += ' WHERE MobilePhone=:strMobile OR Email=:strEmail';
                }
                else{
                    /*if(logIntiator.IsShow_Debug_Logs__c){
                        System.debug('strEmail ; ' + strEmail);}*/
                    strQuery += ' WHERE Email=:strEmail';
                }
            }
            list<Contact> lstCon = Database.query(strQuery);
            /*if(logIntiator.IsShow_Debug_Logs__c){
                system.debug('lstCon======'+lstCon);}*/
            
            if(lstCon != NULL && lstCon.size()>0){
                for(Contact eachCon : lstCon){
                    if(eachCon.Identifier__c == strUUID){
                        //system.debug('strUUID==='+strUUID);
                        if(String.isNotBlank(strUUID)){
                            sobj.put('Id',lstCon[0].id);
                            contactExistFlag = true;
                        }
                        sobj.put('accountid',lstCon[0].accountid);
                        sobj.put('mobilephone',strMobile);
                    }else if (eachCon.email == strEmail){
                        //system.debug('strEmail==='+strEmail);
                        if(String.isNotBlank(strEmail)){
                            sobj.put('Id',lstCon[0].id); 
                            contactExistFlag = true;
                        }
                    }else if(eachCon.mobilephone == strMobile){
                        //system.debug('strMobile==='+strMobile);
                        if(String.isNotBlank(strMobile)){
                            sobj.put('Id',lstCon[0].id); 
                            contactExistFlag = true;
                        }
                    }
                }
            }           
        }
        /*if(logIntiator.IsShow_Debug_Logs__c){
            System.debug('sobj : ' + sobj);}*/
        return sobj;
    }
    
    private static list<Case> checkExistingCase(Case objCase,Contact objCon,list<Case> lstOfUpsertCase,string recordtype){
        //custom setting to hide and show the debug log 
        //SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        //check case is existing or not
        CareUtility.OwnerAndDedupeWrapper objWrap;
        OneCareProcessHelper.OwnerAndDedupeWrapper oneCareObjWrap;
        
        oneCareObjWrap = OneCareProcessHelper.getDuplicacyAndOwnership(objCase.Merchant_Type__c, objCase.LP_Issue__c , objCase.LP_Sub_Issue__c, objCase.LP_Business_Vertical__c,objCase.LP_Category__c,recordtype);
        if(oneCareObjWrap != NULL && oneCareObjWrap.ownerId != NULL){
            
            objCase.ownerId = oneCareObjWrap.ownerId;
            objCase.L2_Queue_Id__c = oneCareObjWrap.mdtVal.L2_Queue_Id__c;
            objCase.L3_Queue_Id__c = oneCareObjWrap.mdtVal.L3_Queue_Id__c;
        }
        
        
        //system.debug('oneCareObjWrap.mapOfFieldMapping===='+oneCareObjWrap.mapOfFieldMapping);
        string strquery = 'SELECT id,status,accountid,contactid,priority,EntitlementId FROM Case WHERE recordtypeId='+'\''+objCase.RecordTypeId +'\' and status != \'Closed\' and ';            
        if(oneCareObjWrap != NULL && oneCareObjWrap.mapOfFieldMapping != NULL){
            for(string eachFieldAPI : oneCareObjWrap.mapOfFieldMapping.keyset()){
                //system.debug('oneCareObjWrap.mapOfFieldMapping===='+oneCareObjWrap.mapOfFieldMapping.get(eachFieldAPI));
                if(oneCareObjWrap.mapOfFieldMapping.get(eachFieldAPI).substringBefore('.') == 'Case')
                    strquery += eachFieldAPI + '= \''+ objCase.get(eachFieldAPI)+'\' ';
                else if(oneCareObjWrap.mapOfFieldMapping.get(eachFieldAPI).substringBefore('.') == 'Contact')
                    strquery += eachFieldAPI + '= \''+ objCon.get(eachFieldAPI.substringAfter('.'))+'\' ';
                
                strquery += 'and ';
            }
        }
        strquery = strquery.removeEnd('and ');
        
        list<Case> lstCase = Database.query(strquery);
        if(lstCase!= NULL && lstCase.size()>0){
            Case existingCase = lstCase[0];
            CaseId = existingCase.id;
            objCase.ContactId = existingCase.contactId;
            objCase.AccountId = existingCase.accountId;
            objCase.status = 'Closed';
            objCase.Is_Duplicate__c = true;
            objCase.Parent_Case__c = existingCase.id;
            existingCase.priority = 'High';
            
            if(existingCase.status == 'Resolved'){
                existingCase.status = 'Re-Open';
            }
            lstOfUpsertCase.add(existingCase);
        }
        else{
            lstOfUpsertCase.add(objCase); 
        }
        return lstOfUpsertCase;
    }
    
    public static list<Attachment> prepareAttachments(Map<String, Object> jsonRequestDataMap,map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload,list<Attachment> lstAttachment){
        //custom setting to hide and show the debug log 
       // SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('DebugLog Initiator');
        if(jsonRequestDataMap!= NULL && jsonRequestDataMap.size()>0 && 
           jsonRequestDataMap.containsKey('Attachment') && jsonRequestDataMap.get('Attachment')!= NULL){
               lstAttachment = new list<Attachment>();
               List<Map<String, Object>> listOfAttachmentMap = new List<Map<String, Object>>();
               List<Object> attachmentList = (List<Object>) jsonRequestDataMap.get('Attachment');
               for (Object obj : attachmentList) {
                   listOfAttachmentMap.add((Map<String, Object>)obj);
               } 
               /*if(logIntiator.IsShow_Debug_Logs__c){
                   system.debug('listOfAttachmentMap======'+listOfAttachmentMap);}*/
               if(listOfAttachmentMap != NULL && listOfAttachmentMap.size()>0){
                   for(Map<String, Object> eachAttachmentData : listOfAttachmentMap){
                       if(eachAttachmentData != NULL && eachAttachmentData.size()>0){
                           Attachment objAttach = (Attachment)populateObjectData('Attachment',mapOfObjectNameVsPayload,eachAttachmentData);
                           //get body of attachment
                           
                           /*if(logIntiator.IsShow_Debug_Logs__c){
                               System.debug('Record Type NOt Care');}*/
                           objAttach.body = CareUtility.getAttachmentBody(objAttach,String.valueOf(eachAttachmentData.get('url')));
                           if(objAttach.body != NULL){
                               lstAttachment.add(objAttach);     
                           } 
                       }
                   }
               }
           }       
        return lstAttachment;
    }
    
    public static Id createEntitlement(Account acc,Case cs, string recordtype){
        try{
            /*System.debug('Inside createEntitlement::');
            System.debug('Account::'+acc);
            System.debug('Case::'+cs);
            System.debug('recordtype::'+recordtype);*/
            //get business hours id 
            Id bHIdChild;
            Id bhIdParent;
            
            map<string,Entitlement> mapOfNameVsEntitlement = new map<string,Entitlement>();
            List<BusinessHours> bHoursList = [SELECT Id,Name FROM BusinessHours where name IN ('PayU OneCare Child','OneCare Business Hour')];
            //list<BusinessHours> lstBHParent = [SELECT Id FROM BusinessHours where name='PayU Onecare Parent'];
            //list<BusinessHours> lstBHChild = [SELECT Id FROM BusinessHours where name='PayU OneCare Child'];
            
            for(BusinessHours bh : bHoursList){
                if(bh.Name == 'OneCare Business Hour')
                    bhIdParent = bh.Id;
                if(bh.Name == 'PayU OneCare Child')
                    bHIdChild = bh.Id;
            }
            /*if(lstBHParent != NULL && lstBHParent.size()>0)
bhIdParent = lstBHParent[0].id;
if(lstBHChild != NULL && lstBHChild.size()>0)
bHIdChild = lstBHChild[0].id;
*/    
            //System.debug('>>>>>>>>>OwnerId>>'+cs.OwnerId);
            for(SlaProcess eachProcess : [SELECT id,Name from SlaProcess where Name IN('Parent Ticket Entitlement Process V2','Child Ticket Entitlement Process V2','OneCare Ticket Entitlement Process') AND IsActive = true]){
                Entitlement objentitlement = new Entitlement();
                objentitlement.AccountId = acc.Id;
                //objentitlement.Name = eachProcess.Name;
                //objentitlement.BusinessHoursId = bHId;
                
                if(eachProcess.Name.contains('Parent') && string.isNotBlank(bhIdParent)){
                    objentitlement.BusinessHoursId = bhIdParent;
                    objentitlement.Name = 'PayUMoney Parent Entitlement';
                    objentitlement.SlaProcessId = eachProcess.id;
                    objentitlement.StartDate = Date.today();
                    mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
                    //system.debug('########### first');
                }else if(eachProcess.name.contains('OneCare') && string.isNotBlank(bHIdChild)){
                    objentitlement.BusinessHoursId = bHIdChild;
                    objentitlement.Name = 'Other Parent Entitlement';
                    objentitlement.SlaProcessId = eachProcess.id;
                    objentitlement.StartDate = Date.today();
                    mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
                    //system.debug('########### second');
                }
                else if(eachProcess.name.contains('Child') && string.isNotBlank(bHIdChild)){
                    objentitlement.BusinessHoursId = bHIdChild;
                    objentitlement.Name = 'Child Entitlement';
                    objentitlement.SlaProcessId = eachProcess.id;
                    objentitlement.StartDate = Date.today();
                    mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
                    //system.debug('########### third');
                }
                
                //objentitlement.SlaProcessId = eachProcess.id;
                //objentitlement.StartDate = Date.today();
                //mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
            }
            
            if(mapOfNameVsEntitlement!=NULL && mapOfNameVsEntitlement.size()>0){
                //system.debug('########### mapOfNameVsEntitlement '+mapOfNameVsEntitlement.values());
                insert mapOfNameVsEntitlement.values();
                if(mapOfNameVsEntitlement.containsKey('PayUMoney Parent Entitlement')){
                    return mapOfNameVsEntitlement.get('PayUMoney Parent Entitlement').Id;
                }else if (mapOfNameVsEntitlement.containsKey('Child Entitlement')){
                    return mapOfNameVsEntitlement.get('Child Entitlement').Id;
                }else if(mapOfNameVsEntitlement.containsKey('Other Parent Entitlement'))
                    return mapOfNameVsEntitlement.get('Other Parent Entitlement').Id;
                else
                    return null;
            }
            else
                return null;
        }catch(Exception ex){
            //System.debug('ERROR::'+ex.getMessage()+' >>'+ex.getLineNumber());  
            return null;
        }        
    }   
}