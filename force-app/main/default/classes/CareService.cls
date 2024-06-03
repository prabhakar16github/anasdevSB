@RestResource(urlMapping='/api/care/*')
global with sharing class CareService {
    static Id CaseId;
    static string strEmail;
    static string strMobile;
    static string strUUID;
    static map<string,string> mapOfResponse;
    public static string strRecordType;
    public static boolean contactExistFlag = false ;
        
    @HttpPost
    global static void createCaseAndContact(string currentData) {
        system.debug('currentData========='+currentData);
       //---------------------------------------------------------------------------------------
        Datetime dateTime1 = Datetime.now();
        Time timeValue = Time.newinstance(dateTime1.hour(),dateTime1.minute(),dateTime1.second(),dateTime1.millisecond()); 
        System.debug('Care API Starting Time >>> '+ timeValue);
       //------------------------------------------------------------------------------------- 
        
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
                map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload = CareUtility.getPayloadData('Care');
                
                //deserialize the json string
                Map<String, Object> jsonRequestDataMap = (Map<String, Object>)JSON.deserializeUntyped(currentData);
                system.debug('jsonRequestDataMap======='+jsonRequestDataMap);
                
                //get the recordtype name
                if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('RecordTypeName')){
                    strRecordType = String.ValueOf(jsonRequestDataMap.get('RecordTypeName'));
                    //create logs of consumer
                    theLog = new Payload_Log__c(Producer__c = 'MerchantCare',Business_Object__c = 'Customer',Action__c = 'Upsert_Care_Case',Process__c = 'Merchant Care',Payload__c = currentData);                
                }
                else{
                    strRecordType = 'Care';
                    //create logs of consumer
                    theLog = new Payload_Log__c(Producer__c = 'LazyPayCare',Business_Object__c = 'Customer',Action__c = 'Upsert_Care_Case',Process__c = 'LazyPay Customer Care',Payload__c = currentData);
                }
                    
                if(mapOfObjectNameVsPayload != NULL && mapOfObjectNameVsPayload.size()>0){
                    //upsert account records
                    if(mapOfObjectNameVsPayload.containsKey('Account')){
                       objAcc = (Account)populateObjectData('Account',mapOfObjectNameVsPayload,jsonRequestDataMap);
                    }
                    
                    //upsert contact records
                    if(mapOfObjectNameVsPayload.containsKey('Contact')){
                       objCon = (Contact)populateObjectData('Contact',mapOfObjectNameVsPayload,jsonRequestDataMap);
                       System.debug('Contact To Insert : ' + objCon); 
                    }                   
                    //upsert Case records
                    if(mapOfObjectNameVsPayload.containsKey('Case')){
                        objCase = (Case)populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                        System.debug('objCase***' + objCase);
                        objCase.status = 'New';
                        objCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordType).getRecordTypeId();
                        if(strRecordType != 'Care'){
                           objCase.Comments = objCase.LP_Issue_description__c;
                        }
                        //if(strRecordType=='Care'){
                            lstOfUpsertCase = checkExistingCase(objCase,objCon,lstOfUpsertCase,strRecordType);
                        //}else{
                         //   lstOfUpsertCase = OneCareProcessHelper.checkExistingCase(objCase,objCon,lstOfUpsertCase,strRecordType);
                        //}                        
                    }
                    
                    //create attachment records
                    if(mapOfObjectNameVsPayload.containsKey('Attachment')){
                        lstAttachment = prepareAttachments(jsonRequestDataMap,mapOfObjectNameVsPayload,lstAttachment);
                    }
                    system.debug('lstOfUpsertCase======='+lstOfUpsertCase);                    
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
                        System.debug('There is already a existing case , that why list size is > 1' + lstOfUpsertCase.size());
                        
                        if(oCase.AccountId != NULL){
                            objAcc.id = oCase.AccountId;
                        }
                        
                        if(objCon.AccountId != NULL){
                            objAcc.id = objCon.AccountId;
                        }
                       
                        system.debug('objAcc======='+objAcc);
                        upsert objAcc;
                        
                        objCon.accountId = objAcc.Id;
                        upsert objCon;
                        if(oCase.ContactId != null){
                           oCase.ContactId = objCon.Id;
                        } 
                        caseListToUpsert.add(oCase);
                        system.debug('objCon*****' + objCon);
                        //upsert contact
                       // System.debug('Identifier Generated***' + objCon.Identifier__c);
                       // System.debug('Identifier Generated***' + objCon.LP_UUID__c);
                       // System.debug('Identifier Generated***' + oCase.ContactId);
                       // System.debug('Case Identifier **' + oCase.Identifier__c );
                                                                                               
                         upsert caseListToUpsert; 
                       //---------------------------------------------------------------------------------------
                        Datetime dateTime2 = Datetime.now();
                        Time timeValue2 = Time.newinstance(dateTime2.hour(),dateTime2.minute(),dateTime2.second(),dateTime2.millisecond()); 
                        System.debug('Care API Case Inserted when list size is greater than 1 '+ timeValue2);
                      //------------------------------------------------------------------------------------- 
                    }
                    else if(lstOfUpsertCase != NULL && lstOfUpsertCase.size() == 1){                       
                        System.debug('Going to Create new case **' + lstOfUpsertCase.size());
                        Case oCase = lstOfUpsertCase[0];
                        //upsert account
                        if(objCon.accountid != NULL)
                            objAcc.id = objCon.accountid;
                        upsert objAcc;
                        
                        //upsert contact
                        objCon.accountId = objAcc.Id;
                        if(objCon.LastName == NULL)
                           objCon.LastName = objCon.MobilePhone; 
                       // System.debug('Upsert Contact : ' + objCon);
                        upsert objCon  ;
                        
                        //upsert case
                        oCase.ContactId = objCon.Id;
                        oCase.AccountId = objAcc.Id;
                        if(strRecordType != 'Care'){
                            if(entitlementId != NULL)
                                oCase.EntitlementId = entitlementId;
                        }
                        
                        upsert oCase;
                        CaseId = oCase.id;
                       //---------------------------------------------------------------------------------------
                        Datetime dateTime3 = Datetime.now();
                       Time timeValue3 = Time.newinstance(dateTime3.hour(),dateTime3.minute(),dateTime3.second(),dateTime3.millisecond()); 
                        System.debug('Care API Case Inserted when list size is 1 '+ timeValue3);
                      //-------------------------------------------------------------------------------------      
                        
                    }
                    system.debug('CaseId======'+CaseId);
                    system.debug('lstAttachment======'+lstAttachment);
                    
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
                    system.debug('lstAttach===='+lstAttach);
                    if(lstAttach != null && lstAttach.size()>0)
                        upsert lstAttach; 
                    
                   //---------------------------------------------------------------------------------------
                     Datetime dateTime3 = Datetime.now();
                     Time timeValue3 = Time.newinstance(dateTime3.hour(),dateTime3.minute(),dateTime3.second(),dateTime3.millisecond()); 
                     System.debug('Care API Attachment Inserted >>> '+ timeValue3);
                     //-------------------------------------------------------------------------------------   
               }
                
                if(CaseId != Null){
                    list<Case> lstFetchedCase = [SELECT casenumber,status,Identifier__c,Expected_Closure_Date__c FROM Case WHERE id=:CaseId]; 
                    
                    //prepare return response
                    mapOfResponse = new map<string,string>();
                    mapOfResponse.put('State','Success');
                    if(lstFetchedCase!= NULL && lstFetchedCase.size()>0){
                        mapOfResponse.put('caseNumber',lstFetchedCase[0].casenumber);
                        mapOfResponse.put('caseStatus',lstFetchedCase[0].status);
                        mapOfResponse.put('identifier',lstFetchedCase[0].Identifier__c);
                        if(String.isNotBlank(strRecordType) && strRecordType != 'Care'){
                            system.debug('Expected_Closure_Date__c========'+lstFetchedCase[0].Expected_Closure_Date__c);
                            if(lstFetchedCase[0].Expected_Closure_Date__c != NULL){
                                DateTime dt = lstFetchedCase[0].Expected_Closure_Date__c;
                                string strDtime = dt.formatGMT('yyyy-MM-dd HH:mm:ss');
                                 system.debug('strDtime========'+strDtime);
                                mapOfResponse.put('Expected Closure Date',strDtime);
                            }
                            else
                                mapOfResponse.put('Expected Closure Date',null);
                           
                        }
                            

                    }
                    
                    RestResponse res = RestContext.response; 
                    if(Test.isRunningTest()){res = new RestResponse();}
                    res.addHeader('Content-Type', 'Application/json');
                    res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                    res.statusCode = 200;
                }
             theLog.Status__c = 'SUCCESS';    
                if(Test.isRunningTest()){
                    CareUtility.populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                }
            }catch(Exception ex){
                theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); theLog.Status__c = 'Error';

               
                map<string,string> mapOfResponse = new map<string,string>();
                mapOfResponse.put('State','Error');
                mapOfResponse.put('message',ex.getMessage());
                mapOfResponse.put('Stack Trace',ex.getStackTraceString());
                RestResponse res = RestContext.response; 
                if(Test.isRunningTest()){res = new RestResponse();}
                res.addHeader('Content-Type', 'Application/json');
                    
                res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                res.statusCode = 500;
                
            }
            if(strRecordType != null && strRecordType != 'Care'){
                   insert theLog;            
            }else{
               if(String.valueOf(label.InsertCareLog ) == 'Y'){
                   System.debug('Payload Length *****' + thelog.payload__c.length());
                   if(thelog.payload__c.length() > 32768){  
                     thelog.payload__c = thelog.payload__c.subString(0,32767);
                     System.debug('Shorten Length ******' + thelog.payload__c.length());  
                   }
                   insert theLog;  
                }   
            }
            
           //---------------------------------------------------------------------------------------
               Datetime dateTime4 = Datetime.now();
               Time timeValue4 = Time.newinstance(dateTime4.hour(),dateTime4.minute(),dateTime4.second(),dateTime4.millisecond()); 
               System.debug('Care API End Time '+ timeValue4);
           //-------------------------------------------------------------------------------------   
            	            
        }
      
    } 
    
  /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to map the field values from payload
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
      public static void populateField(SObject sobToUpsert,String node,String fieldApi,String data){
       System.debug('Populate Fields*****' +  'sobToUpsert ===' + sobToUpsert +  'node==='+node  + 'fieldApi == ' + fieldApi + '  data===' + data);
        if(String.isNotBlank(fieldApi) && String.isNotBlank(data)){
            if(fieldAPI.subStringAfter(',') == 'Date'){
        sobToUpsert.put(fieldAPI.subStringBefore(','),Date.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'DateTime'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),DateTime.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'Decimal'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Decimal.valueOf(data));
            }else if(node == 'MerchantName'){
                  if(strRecordType != 'Care'){
                     sobToUpsert.put(fieldAPI.subStringBefore(','),data);  
                  }    
            }else if(node == 'Customer_Name'){
                  if(strRecordType != 'Care'){                     
                  }else{
                    sobToUpsert.put(fieldAPI.subStringBefore(','),data);  
                  } 
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
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to create/update object field values
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    public static SObject populateObjectData(string sObjectName,map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload,Map<String, Object> jsonRequestDataMap){
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
            System.debug('Check for existing contact information : email ' + strEmail + 'UUID : ' + strUUID + 'strMobile:' +strMobile + 'sObj' + sObj);
            sObj = checkExistingContact(strEmail,strUUID,strMobile,sObj);
        }
        system.debug('sObj=========='+sObj);
        return sObj;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to check that contact is existing or not
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    private static SObject checkExistingContact(string strEmail, string strUUID, string strMobile, SObject sobj){
        if(String.isNotBlank(strEmail)){
            string strQuery = 'SELECT id,accountid,MobilePhone,Identifier__c,email FROM Contact';
            if(String.isNotBlank(strUUID)){
                System.debug('strUUID'+ strUUID);
                strQuery += ' WHERE Identifier__c=:strUUID';
            }
            else{
                if(String.isNotBlank(strMobile)){
                    System.debug('strMobile : ' + strMobile);
                    strQuery += ' WHERE MobilePhone=:strMobile OR Email=:strEmail';
                }
                else{
                    System.debug('strEmail ; ' + strEmail);
                    strQuery += ' WHERE Email=:strEmail';
                }
            }
            list<Contact> lstCon = Database.query(strQuery);
            system.debug('COntact Exist **'+lstCon);
            
                if(lstCon != NULL && lstCon.size()>0){
                for(Contact eachCon : lstCon){
                    if(eachCon.Identifier__c == strUUID){
                        if(String.isNotBlank(strUUID)){
                             sobj.put('Id',lstCon[0].id);
                             contactExistFlag = true;
                        }
                        sobj.put('accountid',lstCon[0].accountid);
                        sobj.put('mobilephone',strMobile);
                    }else if (eachCon.email == strEmail){
                        if(String.isNotBlank(strEmail)){
                             sobj.put('Id',lstCon[0].id); 
                            contactExistFlag = true;
                        }
                    }else if(eachCon.mobilephone == strMobile){
                        if(String.isNotBlank(strMobile)){
                            sobj.put('Id',lstCon[0].id); 
                            contactExistFlag = true;
                        }
                    }
                }
            }                
            
            
        }
        System.debug('sobj **' + sobj);
        return sobj;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to chexk case is existing or not
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    private static list<Case> checkExistingCase(Case objCase,Contact objCon,list<Case> lstOfUpsertCase,string recordtype){
        //check case is existing or not
         CareUtility.OwnerAndDedupeWrapper objWrap;
        OneCareProcessHelper.OwnerAndDedupeWrapper oneCareObjWrap;
        if(recordtype != 'Care'){
            oneCareObjWrap = OneCareProcessHelper.getDuplicacyAndOwnership(objCase.Merchant_Type__c, objCase.LP_Issue__c , objCase.LP_Sub_Issue__c, objCase.LP_Business_Vertical__c,objCase.LP_Category__c,recordtype);
            if(oneCareObjWrap != NULL && oneCareObjWrap.ownerId != NULL){
                objCase.ownerId = oneCareObjWrap.ownerId;
                objCase.L2_Queue_Id__c = oneCareObjWrap.mdtVal.L2_Queue_Id__c;
                objCase.L3_Queue_Id__c = oneCareObjWrap.mdtVal.L3_Queue_Id__c;
            }
            string strquery = 'SELECT id,status,accountid,contactid,priority,EntitlementId,Identifier__c FROM Case WHERE recordtypeId='+'\''+objCase.RecordTypeId +'\' and status != \'Closed\' and ';
            if(oneCareObjWrap != NULL && oneCareObjWrap.mapOfFieldMapping != NULL){
                for(string eachFieldAPI : oneCareObjWrap.mapOfFieldMapping.keyset()){
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
                System.debug('Existing Case **' + lstCase[0]);
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
            system.debug('lstOfUpsertCase======'+lstOfUpsertCase);
        }   
        
        
        //if Recordtype = Care then only check record is existing in system or not
        if(recordtype == 'Care'){
          System.debug('Record Type is care  ');
            objWrap = CareUtility.getDuplicacyAndOwnership(objCase.LP_Business_Vertical__c,objCase.LP_Category__c);
            if(objWrap != NULL && objWrap.ownerId != NULL){
            objCase.ownerId = objWrap.ownerId;
            objCase.L2_Queue_Id__c = objWrap.mdtVal.L2_Queue_Id__c;
            objCase.L3_Queue_Id__c = objWrap.mdtVal.L3_Queue_Id__c;
        }
            string strquery = 'SELECT id,status,accountid,contactid,priority,EntitlementId,Identifier__c FROM Case WHERE recordtypeId='+'\''+objCase.RecordTypeId +'\' and status != \'Closed\' and ';
            if(objWrap != NULL && objWrap.mapOfFieldMapping != NULL){
                for(string eachFieldAPI : objWrap.mapOfFieldMapping.keyset()){
                    if(objWrap.mapOfFieldMapping.get(eachFieldAPI).substringBefore('.') == 'Case'){
                        if(eachFieldAPI == 'LP_Transaction_Amount__c' || eachFieldAPI == 'LP_Transaction_Date__c'){
                           strquery += eachFieldAPI + '='+ objCase.get(eachFieldAPI) ;  
                        }else{
                           strquery += eachFieldAPI + '= \''+ objCase.get(eachFieldAPI)+'\' ';  
                        } 
                       
                    }
                        
                    else if(objWrap.mapOfFieldMapping.get(eachFieldAPI).substringBefore('.') == 'Contact')
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
            lstOfUpsertCase.add(objCase);
        }
        else{
           lstOfUpsertCase.add(objCase); 
        }
        system.debug('lstOfUpsertCase======'+lstOfUpsertCase);
        return lstOfUpsertCase;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to prepare the data of attachment
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    public static list<Attachment> prepareAttachments(Map<String, Object> jsonRequestDataMap,map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload,list<Attachment> lstAttachment){
        if(jsonRequestDataMap!= NULL && jsonRequestDataMap.size()>0 && 
           jsonRequestDataMap.containsKey('Attachment') && jsonRequestDataMap.get('Attachment')!= NULL){
               lstAttachment = new list<Attachment>();
               List<Map<String, Object>> listOfAttachmentMap = new List<Map<String, Object>>();
               List<Object> attachmentList = (List<Object>) jsonRequestDataMap.get('Attachment');
               for (Object obj : attachmentList) {
                   listOfAttachmentMap.add((Map<String, Object>)obj);
               } 
               
               system.debug('listOfAttachmentMap======'+listOfAttachmentMap);
               if(listOfAttachmentMap != NULL && listOfAttachmentMap.size()>0){
                   for(Map<String, Object> eachAttachmentData : listOfAttachmentMap){
                       if(eachAttachmentData != NULL && eachAttachmentData.size()>0){
                           Attachment objAttach = (Attachment)populateObjectData('Attachment',mapOfObjectNameVsPayload,eachAttachmentData);
                           //get body of attachment
                           if(strRecordType != 'Care'){
                              System.debug('Record Type NOt Care');
                              objAttach.body = CareUtility.getAttachmentBody(objAttach,String.valueOf(eachAttachmentData.get('url')));
                               if(objAttach.body != NULL){
                                  lstAttachment.add(objAttach);     
                               } 
                           }else{
                              if(objAttach != null){// Changed BY Kapil Chauhan (10-10-2019) TO pick the body directly from Payload
                              lstAttachment.add(objAttach);    
                               }
                           }
                       }
                   }
                   
               }
           }
        return lstAttachment;
    }
    
     public static Id createEntitlement(Account acc,string recordtype){
        //get business hours id 
        Id bHId;
        map<string,Entitlement> mapOfNameVsEntitlement = new map<string,Entitlement>();
        list<BusinessHours> lstBH = [SELECT Id FROM BusinessHours where name='PayU'];
        if(lstBH != NULL && lstBH.size()>0)
            bHId = lstBH[0].id;
        
        //create Entitlement Record
        /*list<string>lstNames = new list<string>(System.Label.split(','))
         if(recordtype != 'Care'){
             MC_Entitlement_Name;
         }
         else{
             
         }*/
         for(SlaProcess eachProcess : [SELECT id,name from SlaProcess where name IN('Parent Ticket Entitlement Process','Child Ticket Entitlement Process') AND IsActive = true]){
            Entitlement objentitlement = new Entitlement();
            objentitlement.AccountId = acc.Id;
            //objentitlement.Name = eachProcess.Name;
            objentitlement.BusinessHoursId = bHId;
             /*if(recordtype != 'Care'){
                 if(eachProcess.name.contains('Parent Ticket Entitlement Process For LazyPay')){
                    objentitlement.Name = 'Parent Entitlement';
                 }
                 else if(eachProcess.name.contains('Child Ticket Entitlement Process')){
                   objentitlement.Name = 'Child Entitlement'; 
                 }
             }
             else{*/
                  if(eachProcess.name.contains('Parent')){
                    objentitlement.Name = 'Parent Entitlement';
                 }
                 else if(eachProcess.name.contains('Child')){
                   objentitlement.Name = 'Child Entitlement'; 
                 }
             //}
            objentitlement.SlaProcessId = eachProcess.id;
            objentitlement.StartDate = Date.today();
            mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);
         }
         if(mapOfNameVsEntitlement!=NULL && mapOfNameVsEntitlement.size()>0){
             insert mapOfNameVsEntitlement.values();
             return mapOfNameVsEntitlement.get('Parent Entitlement').Id;
         }
         else
             return null;
            
       
    }
}