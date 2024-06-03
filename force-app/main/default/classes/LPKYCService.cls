@RestResource(urlMapping='/api/kyc/*')
  global with sharing class LPKYCService {
    static boolean isRecordCreate;
    static Map<String, Schema.SObjectType> globalDescribe;
    static set<string> setOfNodeVal = new set<string>();
    static map<String,String> mapOfDocNameVsDocId = new map<String,String>();
    static map<String,String> mapOfDocIdVsDocName = new map<String,String>();
    static list<Map<String, Object>> listOfArrayNodes = new list<Map<String, Object>>();
    static Map<String,mapWrapper> mapOfSobjectVsPayloadMdtWrapper = new Map<String,mapWrapper>();
    static map<string,string> mapOfResponse;
    static list<string> lstOfDocumentCombo = new list<string>();
    static Payload_Log__c theLog = new Payload_Log__c();
    
    @HttpPost
    global static void createCaseAndContact(string currentData) {
        theLog =  storeProcessTime(theLog,'Process_Start_Time__c');
        
        parseJSON(currentData);
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       to get the data from custom metadata Payload Map and store the mapping of sobject in map
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    public static void fillMapFromCustomMdt(){
        for(PayloadActMap__mdt eachPayLoadMtdt : IntegrationUtility.getPayLoadMap('KYC','','')){
            
            mapOfSobjectVsPayloadMdtWrapper.put(eachPayLoadMtdt.Sobject__c,new mapWrapper());
            mapOfSobjectVsPayloadMdtWrapper.get(eachPayLoadMtdt.Sobject__c).objpayloadMapping = eachPayLoadMtdt;
            
            if(String.isNotBlank(eachPayLoadMtdt.JSONMapkeyArray__c)){
                mapOfSobjectVsPayloadMdtWrapper.get(eachPayLoadMtdt.Sobject__c).arrayNodeMap = (Map<String, String>)JSON.deserialize(eachPayLoadMtdt.JSONMapkeyArray__c, Map<String, String>.class);
                Map<String, String> arrayNodeMap = mapOfSobjectVsPayloadMdtWrapper.get('Contact').arrayNodeMap;
                for(String eachNode : arrayNodeMap.keyset()){
                    setOfNodeVal.addAll(arrayNodeMap.get(eachNode).split(';'));
                }
            }
            
            if(String.isNotBlank(eachPayLoadMtdt.JsonMapComp__c)){
                mapOfSobjectVsPayloadMdtWrapper.get(eachPayLoadMtdt.Sobject__c).complexNodeMap = (Map<String, String>)JSON.deserialize(eachPayLoadMtdt.JsonMapComp__c, Map<String, String>.class);
            }
        }
    }
    

    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       to parse the json and update the values in respective objects
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    
    global static void parseJSON(String jsonStr){
        
        //declare variables
        isRecordCreate = false;
        Case sobCaseToUpsert;
        SObject sobToUpsert;
    list<LP_KYC_Document__c> lstKYCDocSObject = new list<LP_KYC_Document__c>();
        
        system.debug('processStart=========='+Datetime.now());
        
        //deserialize json string into map
        Map<String, Object> jsonbaseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr); 
        Map<String, Object> jsonRootMap = (Map<String, Object>)jsonbaseMap.get('current_data'); 
        
        //create logs of KYC consumption
        theLog.Producer__c=String.valueOf(jsonbaseMap.get('producer'));
        theLog.Business_Object__c =String.ValueOf(jsonbaseMap.get('business_object'));
        theLog.Action__c =String.ValueOf(jsonbaseMap.get('action'));
        theLog.Payload__c = jsonStr;
        if(theLog.Action__c == 'Upsert_Nach'){
            theLog.Process__c = 'Nach Process';
            NachUtility.processNachPayload(theLog,jsonRootMap);
        }
        else{
            theLog.Process__c = 'KYC Process';
            fillMapFromCustomMdt();
            try{
                if(mapOfSobjectVsPayloadMdtWrapper != null && mapOfSobjectVsPayloadMdtWrapper.containsKey('Contact')){
                    
                    PayloadActMap__mdt thePayLoadMap = mapOfSobjectVsPayloadMdtWrapper.get('Contact').objpayloadMapping;
                    theLog =  storeProcessTime(theLog,'Contact_Process_Time__c');
                    system.debug('theLog=========='+theLog);
                    system.debug('jsonRootMap=========='+jsonRootMap);
                    
                    //create contact record
                    if(jsonRootMap.containsKey('uuid') && jsonRootMap.get('uuid') != NULL){
                        System.debug('Initial ***' + sobToUpsert);
                        sobToUpsert = populateDirectFields(thePayLoadMap,jsonRootMap,'',
                                                           mapOfSobjectVsPayloadMdtWrapper.get('Contact').arrayNodeMap,
                                                           mapOfSobjectVsPayloadMdtWrapper.get('Contact').complexNodeMap,null);
                    }
                    
                    system.debug('isRecordCreate======='+isRecordCreate);
                    
                    //if timestamp is greater or override flag is true then case and other records will create
                    if(isRecordCreate){
                        theLog =  storeProcessTime(theLog,'Case_Process_Time__c');
                        //prepare case records data
                        if(thePayLoadMap.Related_Object__c != NULL){
                            PayloadActMap__mdt thePayLoadCaseMap = mapOfSobjectVsPayloadMdtWrapper.get(thePayLoadMap.Related_Object__c).objpayloadMapping;
                            
                            sobCaseToUpsert = (Case)populateDirectFields(thePayLoadCaseMap,
                                                                         jsonRootMap,'',
                                                                         mapOfSobjectVsPayloadMdtWrapper.get(thePayLoadMap.Related_Object__c).arrayNodeMap,
                                                                         mapOfSobjectVsPayloadMdtWrapper.get(thePayLoadMap.Related_Object__c).complexNodeMap,null);
                            
                        }
                        
                        //get array nodes data from custom metadata and payload
                        if(listOfArrayNodes != NULL && listOfArrayNodes.size() == 0)   
                            prepareListOfArrayNodes(mapOfSobjectVsPayloadMdtWrapper.get('Contact'),jsonRootMap);
                            
                        system.debug('listOfArrayNodes========'+listOfArrayNodes);
                        
                        //iterate over array components and update/insert record
                        if(listOfArrayNodes!= NULL && listOfArrayNodes.size()>0){
                            Map<String, String> complexNodeMap = mapOfSobjectVsPayloadMdtWrapper.get('Contact').complexNodeMap;
                            system.debug('complexNodeMap========'+complexNodeMap);
                        
                            for(Map<String, Object> eachMap : listOfArrayNodes){
                                
                               //below if loop executes for onboarding documents and pan form details
                               if(eachMap != NULL && eachMap.size()>0 && setOfNodeVal!= NULL && setOfNodeVal.size()>0 
                                  && setOfNodeVal.contains(String.ValueOf(eachMap.get('documentTypeId')))){
                                      if(complexNodeMap != NULL && complexNodeMap.size()>0 && complexNodeMap.containsKey(String.ValueOf(eachMap.get('documentTypeId')))){
                                          Object theCompNode = eachMap.get('value');
                                          system.debug('theCompNode======'+theCompNode);
                                          if(theCompNode != null){ 
                                              Map<String,Object> complexDataMap;
                                              if(!Test.isRunningTest())
                                                  complexDataMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(theCompNode));
                                              else
                                                  complexDataMap = (Map<String,Object>)theCompNode; 
                                              
                                              Map<String, String> complexKeyFieldMap = new Map<String, String>();
                                              
                                              for(String eachStr : complexNodeMap.get(String.ValueOf(eachMap.get('documentTypeId'))).split(';')){
                                                  complexKeyFieldMap.put(eachStr.subStringBefore(':'), eachStr.subStringAfter(':'));
                                                   System.debug('complexKeyFieldMap*******'+ complexKeyFieldMap);
                                              }
                                              
                                              if(!complexKeyFieldMap.isEmpty()){
                                                  
                                                  for(String eachCompStr : complexDataMap.keySet()){  
                                                      populateField(sobToUpsert, eachCompStr,complexKeyFieldMap.get(eachCompStr),String.valueOf(complexDataMap.get(eachCompStr)),thePayLoadMap.sObject__c);                                 
                                                  } 
                                              } 
                                          }  
                                      }
                                  }
                                else{
                                    theLog =  storeProcessTime(theLog,'Document_Process_Time__c');
                                    Id sobjectCaseId;
                                    if(sobCaseToUpsert.Id != Null)
                                        sobjectCaseId = sobCaseToUpsert.Id;
                                                  
                                    //create KYC Document data
                                    if(mapOfSobjectVsPayloadMdtWrapper != null && mapOfSobjectVsPayloadMdtWrapper.containsKey('LP_KYC_Document__c')){
                                        
                                        PayloadActMap__mdt theDocPayLoadMap = mapOfSobjectVsPayloadMdtWrapper.get('LP_KYC_Document__c').objpayloadMapping;
                                        LP_KYC_Document__c sobKYCDocToUpsert = (LP_KYC_Document__c)populateDirectFields(theDocPayLoadMap,
                                                                                                                        eachMap,String.ValueOf(jsonRootMap.get('uuid')),
                                                                                                                        mapOfSobjectVsPayloadMdtWrapper.get('LP_KYC_Document__c').arrayNodeMap,
                                                                                                                        mapOfSobjectVsPayloadMdtWrapper.get('LP_KYC_Document__c').complexNodeMap,sobjectCaseId);
                                        sobKYCDocToUpsert.LP_Show_On_Component__c = true;
                                        lstKYCDocSObject.add(sobKYCDocToUpsert);
                                       
                                    }
                                }
                             
                            }
                        }
                        
                        //check that lastname is blank or not.
                        //if last name is blank then populate the mobile number value in lastname
                        //in case of wallet product 
                        System.debug('sobToUpsert** Before' + sobToUpsert);
                        if(sobToUpsert.get('LastName') == NULL && sobToUpsert.get('MobilePhone') != NULL)
                            sobToUpsert.put('LastName',sobToUpsert.get('MobilePhone'));
                        system.debug('sobToUpsert========='+sobToUpsert);
                        upsert sobToUpsert;
                         theLog =  storeProcessTime(theLog,'LP_Contact_End_Process_Time__c');
                       
                        
                        //upsert the case record
                        sobCaseToUpsert.ContactId = (Id)sobToUpsert.get('Id');
                        upsert sobCaseToUpsert;
                        theLog =  storeProcessTime(theLog,'LP_Case_End_Process_Time__c');
                        system.debug('sobCaseToUpsert========='+sobCaseToUpsert);
                        
                        
                    }
                }
                
                //update case id on kyc documents
                if(lstKYCDocSObject != NULL && lstKYCDocSObject.size() >0 && sobCaseToUpsert != NULL && sobCaseToUpsert.ID != NULL){
                    list<LP_KYC_Document__c> lstKYCDocument = new list<LP_KYC_Document__c>();
                     map<string,Id> mapOfcomboVsId = new map<string,Id>();
                //get the IDs of Existing Records
                system.debug('lstOfDocumentCombo======='+lstOfDocumentCombo);
                if(lstOfDocumentCombo != NULL && lstOfDocumentCombo.size()>0){
                    String queryStr = 'SELECT Id,LP_Unique_Key__c FROM LP_KYC_Document__c WHERE LP_Case__c= \'' + sobCaseToUpsert.ID + '\' AND';
                    queryStr+= ' LP_Unique_Key__c IN:lstOfDocumentCombo'+ ' FOR UPDATE';
                    system.debug('queryStr======='+queryStr);
                    for(LP_KYC_Document__c eachExistingDoc : Database.query(queryStr)){
                        mapOfcomboVsId.put(eachExistingDoc.LP_Unique_Key__c,eachExistingDoc.Id);
                    }
                }
                system.debug('mapOfcomboVsId======='+mapOfcomboVsId);
                system.debug('mapOfDocIdVsDocName======='+mapOfDocIdVsDocName);
                for(LP_KYC_Document__c eachDoc : lstKYCDocSObject){
                    string combo = String.ValueOf(jsonRootMap.get('uuid')) + mapOfDocIdVsDocName.get(eachDoc.LP_Document_Master__c);
                    system.debug('combo========'+combo);
                    if(mapOfcomboVsId != NULL && mapOfcomboVsId.size()>0 
                       && mapOfcomboVsId.containsKey(combo)){
                           
                           eachDoc.Id = mapOfcomboVsId.get(combo);
                       }
                    eachDoc.LP_Case__c = sobCaseToUpsert.Id;
                    lstKYCDocument.add(eachDoc);
                }
                    if(lstKYCDocument != NULL && lstKYCDocument.size()>0)
                        upsert lstKYCDocument;
                    theLog =  storeProcessTime(theLog,'LP_Document_End_Process_Time__c');
                }
                system.debug('DocumentEndTime=========='+Datetime.now());
                
                //insert logs in Salesforce
                if(sobCaseToUpsert!= null)
                    theLog.SalesforceRecordId__c = sobCaseToUpsert.Id; 
                theLog.Status__c = 'SUCCESS';
                theLog =  storeProcessTime(theLog,'LP_Process_End_Time__c');
                insert theLog;
                
                //prepare return response
                mapOfResponse = new map<string,string>();
                mapOfResponse.put('State','Success');
                if(theLog!= NULL && theLog.SalesforceRecordId__c != NULL)
                    mapOfResponse.put('caseId',theLog.SalesforceRecordId__c);
               
                RestResponse res = RestContext.response; 
                res.addHeader('Content-Type', 'Application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                res.statusCode = 200;
            }
            catch(Exception ex){
                //insert logs
                theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); 
                theLog.Status__c = 'Error';
                insert theLog;
                
                //prepare return response
                map<string,string> mapOfResponse = new map<string,string>();
                mapOfResponse.put('State','Error');
                mapOfResponse.put('message',ex.getMessage());
                
                RestResponse res = RestContext.response; 
                res.addHeader('Content-Type', 'Application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                res.statusCode = 500;
               
            }
        }
        
    }
    
        /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method prepare the list which contains array nodes
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    public static void prepareListOfArrayNodes(mapWrapper objWrapper,Map<String, Object> jsonRootMap){
        //declare local variables
        list<string> lstArrayNodes = new list<string>();
        
        //collect the data of array in list
        PayloadActMap__mdt thePayLoadMap = objWrapper.objpayloadMapping;
        if(thePayLoadMap.ArrayNodes__c != NULL){
            
            if(thePayLoadMap.ArrayNodes__c.contains(';')){
                lstArrayNodes = thePayLoadMap.ArrayNodes__c.split(';');
            }
            else{
                lstArrayNodes.add(thePayLoadMap.ArrayNodes__c);
            }
        }
        
        if(lstArrayNodes != NULL && lstArrayNodes.size() >0 ){
            for(string eachArrayNode : lstArrayNodes){
                if(jsonRootMap.containskey(eachArrayNode) && jsonRootMap.get(eachArrayNode)!= NULL){
                    List<Object> myMapObjects = (List<Object>) jsonRootMap.get(eachArrayNode);
                    for (Object obj : myMapObjects) {
                        listOfArrayNodes.add((Map<String, Object>)obj);
                    }
                }
            }
        }  
           
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to populate the data into objects
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    public static void populateField(SObject sobToUpsert,String node,String fieldApi,String data,String SObjectName){
        
        
        if(String.isNotBlank(fieldApi) && String.isNotBlank(data)){
            System.debug('sobToUpsert ***' + sobToUpsert);
            System.debug('node** '+ node + 'fieldApi ***  '+ fieldApi + 'data ***  '+ data);
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
                if(String.isNotBlank(node) && node == 'products'){
                    if(String.isNotBlank(data) && data.contains(',')){
                        if(data.contains(')'))
                            data = data.remove(')');
                        if(data.contains('('))
                            data = data.remove('(');
                        list<string>lstProducts = data.split(',');
                        string strProdValue ='';
                        for(string eachProd:lstProducts){
                            strProdValue += valueFormatToLowerCase(eachProd.trim()) + ' And ';
                        }
                        strProdValue = strProdValue.substringBeforeLast(' And');
                        sobToUpsert.put(fieldAPI.subStringBefore(','),strProdValue.trim());
                    }
                    else if(String.isNotBlank(data)){
                        if(data.contains(')'))
                            data = data.remove(')');
                        if(data.contains('('))
                            data = data.remove('(');
                        
                        sobToUpsert.put(fieldAPI.subStringBefore(','),valueFormatToLowerCase(data));
                    }
                }
                else if(String.isNotBlank(node) && node == 'status' && SObjectName == 'Case'){
                    sobToUpsert.put(fieldAPI.subStringBefore(','),valueFormatToLowerCase(data));
                }
                else if(String.isNotBlank(node) && node == 'kycState' && SObjectName == 'Case'){
                    sobToUpsert.put(fieldAPI.subStringBefore(','),valueFormatToLowerCase(data));
                }
                else if(String.isNotBlank(node) && node == 'status' && SObjectName == 'LP_KYC_Document__c'){
                    sobToUpsert.put(fieldAPI.subStringBefore(','),valueFormatToLowerCase(data)); 
                }
                else{
                    //system.debug('mapOfDocNameVsDocId========='+mapOfDocNameVsDocId);
                    if(fieldAPI.subStringBefore(',') == 'recordTypeName')
                        sobToUpsert.put('recordTypeId',SystemUtility.getRecordTypeId(SObjectName,data));
                    else if(mapOfDocNameVsDocId != NULL && mapOfDocNameVsDocId.size()>0 && String.isNotBlank(node) && node == 'documentTypeId'){
                        sobToUpsert.put(fieldAPI.subStringBefore(','), mapOfDocNameVsDocId.get(data));
                    }
                    else{
                        if(fieldAPI.subStringBefore(',') == 'MobilePhone'){
                            if(String.isNotBlank(data) && !data.startsWith('+91')){
                                data = '+91'+data;
                            }
                            sobToUpsert.put(fieldAPI.subStringBefore(','),data);
                        }
                        else{
                            sobToUpsert.put(fieldAPI.subStringBefore(','),data);
                        }
                    }
                    
                    
                }
            }
          System.debug('final sobToUpsert***' + sobToUpsert);  
            
        }
    }
    
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       the purpose of this method is to populate the fields value including lookups and child records
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    public static SObject populateDirectFields(PayloadActMap__mdt thePayLoadMap,Map<String, Object> jsonRootMap,string uuid,
                                               Map<String, String> arrayNodeMap,Map<String, String> complexNodeMap,Id caseId)
    {
                                                   
        Map<String, String> jsonFieldMap;
        SObject sobToUpsert;
        System.debug('In Populate Direct Fields Initial >>>>>>>>>>>>>>'+ sobToUpsert);
        System.debug('Metadata *****'+ thePayLoadMap);
        if(String.isNotBlank(thePayLoadMap.JsonMap__c)){
            jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMap__c, Map<String, String>.class);
            System.debug('Json map is not null >>>>>>>'+ jsonFieldMap);
        }
        globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
        sobToUpsert = globalDescribe.get(thePayLoadMap.Sobject__c).newSObject(); 
        
        //prepare document map to fill the documsnt master field lookup value on kyc document
        if(mapOfDocNameVsDocId!= NULL && mapOfDocNameVsDocId.size() == 0){
            fillDocumentMap(thePayLoadMap,jsonRootMap);
        }
        
        if(jsonRootMap != NULL && jsonRootMap.containsKey('uuid') && thePayLoadMap.Sobject__c == 'Contact'){
            String queryStr = 'SELECT Id,LP_Timestamp__c,LP_DateStamp__c,lastname FROM ' + thePayLoadMap.Sobject__c + ' WHERE Identifier__c = \'' + jsonRootMap.get('uuid') + '\' FOR UPDATE';
            List<Sobject> getIdList = Database.query(queryStr);
            
            if(jsonRootMap.containsKey('timestamp')){
                string strTimeValue = String.ValueOf(jsonRootMap.get('timestamp'));
                timeStampWrapper objWrap = getDateAndTime(strTimeValue);
                
                if(!getIdList.isEmpty()){
                    sobToUpsert.put('Id', getIdList[0].Id);
                    sobToUpsert.put('LastName', getIdList[0].get('lastname'));
                    system.debug('recordVal==============='+(getIdList[0].get('LP_Timestamp__c')));
                    
                    if(objWrap != NULL){
                        //check date and time value for existing records
                        if(getIdList[0].get('LP_Timestamp__c') != null && getIdList[0].get('LP_DateStamp__c') != null){
                            Date existingDate = (Date)getIdList[0].get('LP_DateStamp__c');
                            Time existingTime = (Time)getIdList[0].get('LP_Timestamp__c');
                            
                            System.debug('existingDate========'+existingDate);
                            System.debug('existingTime========'+existingTime);
                            
                            System.debug('newDate========'+objWrap.dateStamp);
                            System.debug('newTime========'+objWrap.timestamp);
                            
                            if((objWrap.dateStamp == existingDate && objWrap.timestamp > existingTime) 
                               || 
                               (objWrap.dateStamp == existingDate && objWrap.timestamp <= existingTime && jsonRootMap.get('overrideExistingData') == true)
                               ||
                               (objWrap.dateStamp > existingDate)
                               ||
                               (objWrap.dateStamp < existingDate&& jsonRootMap.get('overrideExistingData') == true)){
                                   isRecordCreate = true;
                                   sobToUpsert.put('LP_Timestamp__c', objWrap.timestamp);
                                   sobToUpsert.put('LP_DateStamp__c', objWrap.dateStamp);
                               }
                        }
                        else{
                            // on existing record either date or time is null
                            isRecordCreate = true;
                            sobToUpsert.put('LP_Timestamp__c', objWrap.timestamp);
                            sobToUpsert.put('LP_DateStamp__c', objWrap.dateStamp);
                        }
                    }
                }
                else{
                    // when new record is inserted in system
                    isRecordCreate = true;
                    sobToUpsert.put('LP_Timestamp__c', objWrap.timestamp);
                    sobToUpsert.put('LP_DateStamp__c', objWrap.dateStamp);
                }
            }
            
        }
        if(jsonRootMap != NULL && jsonRootMap.containsKey('uuid') && thePayLoadMap.Sobject__c == 'Case'){
            //String queryStr = 'SELECT Id,OwnerId FROM ' + thePayLoadMap.Sobject__c + ' WHERE recordtype.Name = \''+jsonRootMap.get('recordTypeName') + '\' AND ( LP_UUID__c = \'' + jsonRootMap.get('uuid') + '\' OR Identifier__c=\'' + jsonRootMap.get('kycCaseId')+'\')';
            String queryStr = 'SELECT Id,OwnerId FROM ' + thePayLoadMap.Sobject__c + ' WHERE LP_UUID__c = \'' + jsonRootMap.get('uuid') + '\' AND recordtype.Name = \''+jsonRootMap.get('recordTypeName') + '\' FOR UPDATE';
            
            system.debug('queryStr======'+queryStr);
            List<Sobject> getIdList = Database.query(queryStr);
            system.debug('getIdList====='+getIdList);
            if(!getIdList.isEmpty()){
                sobToUpsert.put('Id', getIdList[0].Id);
                sobToUpsert.put('OwnerId', getIdList[0].get('OwnerId'));
            }
        }
        
        if(jsonRootMap != NULL && jsonRootMap.containsKey('documentId')){
            if(String.isNotBlank(uuid)){
                string combo = uuid + jsonRootMap.get('documentTypeId');
                lstOfDocumentCombo.add(combo);
                /*String queryStr = 'SELECT Id FROM ' + thePayLoadMap.Sobject__c + ' WHERE';
                if(caseId != NULL)
                    queryStr += ' LP_Case__c= '+'\''+caseId +'\' AND';
                queryStr+= ' LP_Unique_Key__c = \'' + combo + '\' FOR UPDATE';
                system.debug('queryStr======='+queryStr);
                //String queryStr = 'SELECT Id FROM ' + thePayLoadMap.Sobject__c + ' WHERE LP_Unique_Key__c = \'' + combo + '\' FOR UPDATE';
                List<Sobject> getIdList = Database.query(queryStr);
                if(!getIdList.isEmpty()){
                    sobToUpsert.put('Id', getIdList[0].Id);
                }*/
            }
            
        }
        if(jsonFieldMap!= NULL && jsonFieldMap.size()>0){
            for(String eachKey : jsonFieldMap.keyset()){
                System.debug('In Populate fields >>>>>>>>>>>' + sobToUpsert);
                populateField(sobToUpsert,eachKey,jsonFieldMap.get(eachKey),String.valueOf(jsonRootMap.get(eachKey)),thePayLoadMap.Sobject__c);
            }
        }
        return sobToUpsert;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to prepare the map which contain the document name and its id and this map is usd to populate document master lookup on KYC documemnt record 
    
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    public static void fillDocumentMap(PayloadActMap__mdt thePayLoadMap,Map<String, Object> jsonRootMap){
        Map<String, String> lookupFieldMap;
        if(String.isNotBlank(thePayLoadMap.LookUpField__c)){
            lookupFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.LookUpField__c, Map<String, String>.class);
        }
        if(jsonRootMap != NULL && jsonRootMap.containsKey('kycTypeId') && jsonRootMap.get('kycTypeId') != NULL && lookupFieldMap != NULL && lookupFieldMap.containsKey('kycTypeId')){
            string value = lookupFieldMap.get('kycTypeId');
            if(String.isNotBlank(value)){
                string whereCond = value.substringBefore(';');
                string fieldAPI = value.substringAfter(';');
                if(String.isNotBlank(fieldAPI)){
                    if(fieldAPI.contains(',')){
                        string objectname = fieldAPI.substringBefore(',').substringBefore(':');
                        string fields = fieldAPI.substringBefore(',').substringAfter(':');
                        fields += ', '+fieldAPI.substringAfter(',').substringBefore(':')+'.' + fieldAPI.substringAfter(',').substringAfter(':');
                        
                        string strQuery = 'SELECT '+fields+' FROM '+ objectname + ' WHERE ' +whereCond.substringBefore(':')+'.'+whereCond.substringAfter(':') + '= \''+ jsonRootMap.get('kycTypeId') + '\'';
                        system.debug('strQuery=========='+strQuery);
                        for(Sobject eachSobject : Database.query(strQuery)){
                            mapOfDocNameVsDocId.put(String.valueOf((eachSobject.getSobject(fieldAPI.substringAfter(',').substringBefore(':')).get(fieldAPI.substringAfter(',').substringAfter(':')))),String.valueOf(eachSobject.get(fieldAPI.substringBefore(',').substringAfter(':'))));
                          mapOfDocIdVsDocName.put(String.valueOf(eachSobject.get(fieldAPI.substringBefore(',').substringAfter(':'))),String.valueOf((eachSobject.getSobject(fieldAPI.substringAfter(',').substringBefore(':')).get(fieldAPI.substringAfter(',').substringAfter(':')))));
                        }
                    }
                }
                
            }
        }    
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       convert the value in lower case for example : ADDITIONAL_Document convert it into Additional Document
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    
    public static String valueFormatToLowerCase(String status) {
       String result = '';
        if (status != null && status != '') 
        {      
            for(string eachStr : status.split('_'))           
            {   
                if (eachStr.length() > 1) {  
                    result += eachStr.substring(0,1).toUpperCase() + eachStr.substring(1,eachStr.length()).toLowerCase() + ' ';
                }
                else {
                    result += eachStr.substring(0,1).toUpperCase() + ' ';
                }           
                
            }
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       get the date and time value from timestamp string of payload
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    6-Mar-19      Eitika Verma          created
    **/
    public static timeStampWrapper getDateAndTime(string strDateTimestamp){
        if(String.isNotBlank(strDateTimestamp)){
            Datetime dt = datetime.valueOfGMT(strDateTimestamp);
            
            Date newDate = dt.dateGMT();
            string millsec = '';
            if(strDateTimestamp.contains('.'))
                millsec = strDateTimestamp.substringAfterLast('.');
            
            
            Time newTime = Time.newinstance(dt.hourGmt(),dt.minuteGmt(),dt.secondGmt(),dt.millisecondGmt());
            if(String.isNotBlank(millsec))
                newTime = newTime.addMilliseconds(Integer.valueOf(millsec));
            
            timeStampWrapper objWrapper = new timeStampWrapper();
            objWrapper.dateStamp = newDate;
            objWrapper.timestamp = newTime;
            
            return objWrapper;
        }
        else
            return null;
        
    }
    
    public static Payload_Log__c storeProcessTime(Payload_Log__c obj,string fieldName){
        Datetime dt = Datetime.now();
        Time timeValue = Time.newinstance(dt.hour(),dt.minute(),dt.second(),dt.millisecond());
        obj.put(fieldName,timeValue);
        return obj;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       wrapper class to store date and time value
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    6-Mar-19      Eitika Verma          created
    **/
    public class timeStampWrapper{
        public date dateStamp;
        public Time timestamp;
    }
    
    public class mapWrapper{
        public Map<String, String> arrayNodeMap;
        public Map<String, String> complexNodeMap;
        public PayloadActMap__mdt objpayloadMapping;
    }
}