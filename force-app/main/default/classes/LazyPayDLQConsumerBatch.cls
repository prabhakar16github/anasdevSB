/**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       Apex class that consumes the lazy pay KYC payload and create records in database
@history
<Date>        <Authors Name>        <Brief Description of Change>
04-Sep-18     Eitika Verma          created
**/
public with sharing class LazyPayDLQConsumerBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.stateful{
    
    public Map<String, String> receiptHandleMap;
    Payload_Log__c timeTrackingPayload = new Payload_Log__c(Process__c = 'LazyPayDLQTimeTracker',Payload_ID__c='');
    public list<LazyPayExceptionHandling.ErrorLogWrapper> lstException;
    public list<Map<String, String>> receiptHandleList = new list<Map<String, String>>();
    public Map<string, Id> mapOfUUIDVsContactId = new map<string,Id>();
    public Map<string, Case> mapOfUUIDVsCase = new map<string, Case>();
    Map<string, Id> MapQueuebyID = new Map<string, Id>();
    
    static Map<String, Schema.SObjectType> globalDescribe;
    public Map<string,map<string,LP_KYC_Document__c>> mapOfUUIDVsMapOfDocNameVsDocument = new Map<string,map<string,LP_KYC_Document__c>>();
    public boolean isRecordCreate;
    public string messageBody;
    public map<String,String> mapOfDocNameVsDocId;
    public Integer maxIterations;
    
    public LazyPayDLQConsumerBatch(){
        lstException = new list<LazyPayExceptionHandling.ErrorLogWrapper>();
        mapOfDocNameVsDocId = new map<String,String>();
        list<String> lstQueue = new list<string>();
        lstQueue.add('L1_KYC_Queue');
        lstQueue.add('LP_Outbound_IVR_Queue_KYC');
        MapQueuebyID = systemutility.getQueuesInfo(lstQueue);
        
    }
    
    public Iterable<String> start(Database.BatchableContext BC){
        AWSUtility awsIns = new AWSUtility();
        maxIterations = awsIns.getIterationCount('LazyPayDLQConsumerBatch');
        
        List<String> StrList = new List<String>();        
        for(Integer i = 1; i <= maxIterations; i++){
            StrList.add(String.valueOf(i));
        }
        return StrList;
        
    }
 
    public void execute(Database.BatchableContext info, List<String> strings){
        timeTrackingPayload.put('ExecuteStartTime__c',Datetime.now());
        receiptHandleMap = new Map<String, String>();
        HttpResponse messageRes = LazyPayConsumerUtility.getAWSData('GetMessageDLQLazyPay', null, null, '', null); 
        //System.debug(messageRes.getStatusCode() + '>>>>>>>>>>_____________>>>>>>>>>>>___________'+ messageRes.getBody());
        if(messageRes != null && messageRes.getStatusCode() == 200){ 
            messageBody = messageRes.getBody();
            parseXML(messageRes.getBody());
        }
       timeTrackingPayload.put('ExecuteEndTime__c',Datetime.now());
    }
 
    public void finish(Database.BatchableContext info){
        list<LazyPayExceptionHandling.ErrorLogWrapper> lstDelException = new list<LazyPayExceptionHandling.ErrorLogWrapper>();
        timeTrackingPayload.put('FinishStartTime__c',Datetime.now());
        //to delete the message from queue
        if(!receiptHandleList.isEmpty()){
            for(Map<String, String> eachMap : receiptHandleList){
                Integer i = 1;
                list<String> lstOrder = new list<String>();
                list<String> lstReceiptHandles = new list<String>();
                lstOrder.addAll(eachMap.keySet());
                lstOrder.sort();
                for(String each : lstOrder){
                    String tempStr = 'DeleteMessageBatchRequestEntry.' + each + '.Id=msg'+ each + '&DeleteMessageBatchRequestEntry.' + each + '.ReceiptHandle=' + eachMap.get(each);                            
                    lstReceiptHandles.add(tempStr);
                    i++;                
                }
                
                if(!Test.isRunningTest()){
                HttpResponse deleteRes = LazyPayConsumerUtility.getAWSData('DeleteMessageBatchDLQLazyPay', new List<String>{String.join(lstReceiptHandles, '&')}, null, '', null);
                
                System.debug(deleteRes.getStatusCode() + '>>>>>>>>>>_____________>>>>>>>>>>>___________'+ deleteRes.getBody());
                
                if(deleteRes.getStatusCode() != 200){
                    LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
                    objWrapper.message = deleteRes.getBody();
                    objWrapper.process = 'Delete LazyPay Consumer Batch';
                    objWrapper.response = String.join(lstReceiptHandles, ',');
                    lstDelException.add(objWrapper);
                }
                
                } 
            }    
        }
        
        if(!Test.isRunningTest()) 
            Database.executeBatch(new LazyPayDLQConsumerBatch(),1);
        
        timeTrackingPayload.put('FinishEndTime__c',Datetime.now());
        insert timeTrackingPayload;
        
        if(lstDelException != NULL && lstDelException.size()>0)
            LazyPayExceptionHandling.insertErrorLog(lstDelException);
    }
    
    
   
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       parse message XML and pass the body into parse JSON method
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    
    public void parseXML(String xml){
        List<Payload_Log__c> logList = new List<Payload_Log__c>();
        Dom.Document doc = new Dom.Document();
        doc.load(xml);  
        
        Dom.XmlNode rootNode = doc.getRootElement();
        if(rootNode != null){
            
            String nameSpace = rootNode.getNamespace(); 
            Dom.XmlNode msgResult = rootNode.getChildElement('ReceiveMessageResult', nameSpace); 
            
            if(msgResult != null){
                integer j = 1;
                for(Dom.XmlNode each : msgResult.getChildElements()){
                    String body = each.getChildElement('Body', nameSpace).getText();
                    String receiptHandle = each.getChildElement('ReceiptHandle', nameSpace).getText();
                    
                    Payload_Log__c theLog = parseJSON(body);
                    theLog.Process__c = 'Salesforce LazyPayDLQConsumer';
                    theLog.Receipt_Handle__c = receiptHandle;
                    theLog.Payload__c = body;
                    system.debug('body======='+body);
                    if(theLog.Status__c == 'SUCCESS'){
                        if(String.isNotBlank(receiptHandle)){                        
                            receiptHandle = LazyPayConsumerUtility.encodeForConsumedMessages(receiptHandle);
                            receiptHandleMap.put(String.ValueOf(j), receiptHandle); 
                            j++;
                        }
                    } 
                    
                    logList.add(theLog); 
                } 
                if(!receiptHandleMap.isEmpty())
                    receiptHandleList.add(receiptHandleMap);
            }
        } 
        if(!logList.isEmpty()) Database.insert(logList, false);
        string payloadId = '';
        for(Payload_Log__c eachlog : logList){
            payloadId += eachlog.id +',';
        }
         timeTrackingPayload.Payload_ID__c += payloadId;
        if(!lstException.isEmpty()) LazyPayExceptionHandling.insertErrorLog(lstException);
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       to parse the json and update the values in respective objects
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    04-Sep-18     Eitika Verma          created
    **/
    
    public Payload_Log__c parseJSON(String jsonStr){
        //declare variables
        Payload_Log__c theLog = new Payload_Log__c();
        map<string,Contact> mapOfUUIDVsContact = new map<string,Contact>();
        Map<String, Object> jsonChildRootMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        Case sobCaseToUpsert;
        
        //create logs of consumer
        theLog.Producer__c = String.valueOf(jsonChildRootMap.get('producer'));
        theLog.Business_Object__c = String.ValueOf(jsonChildRootMap.get('business_object'));  
        theLog.Action__c = String.valueOf(jsonChildRootMap.get('action'));
        
        if(jsonChildRootMap != NULL && jsonChildRootMap.size() > 0){
            if(String.valueOf(jsonChildRootMap.get('producer')) == 'LazyPay' && String.ValueOf(jsonChildRootMap.get('business_object')) == 'Customer')
            {
                 
                Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jsonChildRootMap.get('current_data')));    
                Map<String,PayloadActMap__mdt> mapOfSobjectVsPayloadMdt = new Map<String,PayloadActMap__mdt>();
                    Map<String, String> arrayNodeMap;
                    Map<String, String> complexNodeMap;
                    list<LP_KYC_Document__c> lstKYCDocSObject = new list<LP_KYC_Document__c>();
                    isRecordCreate = false;
                    try{
                        if(jsonRootMap.containsKey('recordTypeName') && jsonRootMap.get('recordTypeName') != NULL){
                            for(PayloadActMap__mdt thePayLoadMap : IntegrationUtility.getPayLoadMap(String.ValueOf(jsonRootMap.get('recordTypeName')),'','')){
                                mapOfSobjectVsPayloadMdt.put(thePayLoadMap.Sobject__c,thePayLoadMap);
                            }
                        }
                        
                        system.debug('mapOfSobjectVsPayloadMdt=========='+mapOfSobjectVsPayloadMdt);
                        if(mapOfSobjectVsPayloadMdt != null && mapOfSobjectVsPayloadMdt.containsKey('Contact')){
                            PayloadActMap__mdt thePayLoadMap = mapOfSobjectVsPayloadMdt.get('Contact');
                            if(String.isNotBlank(thePayLoadMap.JSONMapkeyArray__c)){
                                arrayNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSONMapkeyArray__c, Map<String, String>.class);
                            }
                            
                            if(String.isNotBlank(thePayLoadMap.JsonMapComp__c)){
                                complexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMapComp__c, Map<String, String>.class);
                            }
                            SObject sobToUpsert;
                            if(mapOfUUIDVsContact != NULL && jsonRootMap.containsKey('uuid') && 
                               jsonRootMap.get('uuid') != NULL && !mapOfUUIDVsContact.containsKey(String.ValueOf(jsonRootMap.get('uuid')))){
                                 sobToUpsert = populateDirectFields(thePayLoadMap,jsonRootMap,'',arrayNodeMap,complexNodeMap);
                            }
                            System.debug('isRecordCreate======='+isRecordCreate);  
                            
                            if(isRecordCreate){
                                if(thePayLoadMap.Related_Object__c != NULL){
                                    PayloadActMap__mdt thePayLoadCaseMap = mapOfSobjectVsPayloadMdt.get(thePayLoadMap.Related_Object__c);
                                    if(String.isNotBlank(thePayLoadCaseMap.JSONMapkeyArray__c)){
                                        arrayNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadCaseMap.JSONMapkeyArray__c, Map<String, String>.class);
                                    }
                                    
                                    if(String.isNotBlank(thePayLoadCaseMap.JsonMapComp__c)){
                                        complexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadCaseMap.JsonMapComp__c, Map<String, String>.class);
                                    }
                                    sobCaseToUpsert = (Case)populateDirectFields(thePayLoadCaseMap,jsonRootMap,'',arrayNodeMap,complexNodeMap);
                                    
                                }
                                
                                
                                //collect the data of array in list
                                if(thePayLoadMap.ArrayNodes__c != NULL){
                                    list<string> lstArrayNodes = new list<string>();
                                    if(thePayLoadMap.ArrayNodes__c.contains(';')){
                                        lstArrayNodes = thePayLoadMap.ArrayNodes__c.split(';');
                                    }
                                    else{
                                        lstArrayNodes.add(thePayLoadMap.ArrayNodes__c);
                                    }
                                    List<Map<String, Object>> listOfArrayNodes = new List<Map<String, Object>>();
                                    for(string eachArrayNode : lstArrayNodes){
                                        if(jsonRootMap.containskey(eachArrayNode) && jsonRootMap.get(eachArrayNode)!= NULL){
                                            List<Object> myMapObjects = (List<Object>) jsonRootMap.get(eachArrayNode);
                                            for (Object obj : myMapObjects) {
                                                listOfArrayNodes.add((Map<String, Object>)obj);
                                            }
                                        }
                                    }
                                    
                                    system.debug('listOfArrayNodes========'+listOfArrayNodes);
                                    //iterate over array components and update/insert record
                                    if(listOfArrayNodes!= NULL && listOfArrayNodes.size()>0){
                                        for(Map<String, Object> eachMap : listOfArrayNodes){
                                            if(arrayNodeMap!= NULL && arrayNodeMap.size() > 0){
                                                for(String eachNode : arrayNodeMap.keyset()){
                                                    list<string> lstNodeVal = arrayNodeMap.get(eachNode).split(';');
                                                    set<string> setOfNodeVal = new set<string>();
                                                    setOfNodeVal.addAll(lstNodeVal);
                                                    
                                                    if(eachMap != NULL && eachMap.size()>0 && eachMap.containsKey(eachNode) && setOfNodeVal!= NULL && setOfNodeVal.size()>0 && setOfNodeVal.contains(String.ValueOf(eachMap.get(eachNode)))){
                                                        if(complexNodeMap != NULL && complexNodeMap.size()>0 && complexNodeMap.containsKey(String.ValueOf(eachMap.get(eachNode)))){
                                                            Object theCompNode = eachMap.get('value');
                                                            system.debug('theCompNode======'+theCompNode);
                                                            if(theCompNode != null){ 
                                                                Map<String,Object> complexDataMap;
                                                                if(!Test.isRunningTest())
                                                                    complexDataMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(theCompNode));
                                                                else
                                                                   complexDataMap = (Map<String,Object>)theCompNode; 
                                                                //Map<String, Object> complexDataMap = (Map<String, Object>)theCompNode;
                                                                Map<String, String> complexKeyFieldMap = new Map<String, String>();
                                                                
                                                                for(String eachStr : complexNodeMap.get(String.ValueOf(eachMap.get(eachNode))).split(';')){
                                                                    complexKeyFieldMap.put(eachStr.subStringBefore(':'), eachStr.subStringAfter(':'));
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
                                                        if(mapOfSobjectVsPayloadMdt != null && mapOfSobjectVsPayloadMdt.containsKey('LP_KYC_Document__c')){
                                                            PayloadActMap__mdt theDocPayLoadMap = mapOfSobjectVsPayloadMdt.get('LP_KYC_Document__c');
                                                            if(String.isNotBlank(theDocPayLoadMap.JSONMapkeyArray__c)){
                                                                arrayNodeMap = (Map<String, String>)JSON.deserialize(theDocPayLoadMap.JSONMapkeyArray__c, Map<String, String>.class);
                                                            }
                                                            
                                                            if(String.isNotBlank(theDocPayLoadMap.JsonMapComp__c)){
                                                                complexNodeMap = (Map<String, String>)JSON.deserialize(theDocPayLoadMap.JsonMapComp__c, Map<String, String>.class);
                                                            }
                                                            LP_KYC_Document__c sobKYCDocToUpsert = (LP_KYC_Document__c)populateDirectFields(theDocPayLoadMap,eachMap,String.ValueOf(jsonRootMap.get('uuid')),arrayNodeMap,complexNodeMap);
                                                            lstKYCDocSObject.add(sobKYCDocToUpsert);
                                                            system.debug('lstKYCDocSObject========'+lstKYCDocSObject);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    //check that lastname is blank or not.
                                    //if last name is blank then populate the mobile number value in lastname
                                    //in case of wallet product 
                                    if(sobToUpsert.get('LastName') == NULL && sobToUpsert.get('MobilePhone') != NULL)
                                        sobToUpsert.put('LastName',sobToUpsert.get('MobilePhone'));
                                    system.debug('sobToUpsert========='+sobToUpsert);
                                    upsert sobToUpsert;
                                    Id ContactId = (Id)sobToUpsert.get('Id');
                                    
                                    //upsert the case record
                                    sobCaseToUpsert.ContactId = ContactId;
                                    system.debug('sobCaseToUpsert========='+sobCaseToUpsert);
                                    upsert sobCaseToUpsert;
                                }
                            }
                        }
                        if(lstKYCDocSObject != NULL && lstKYCDocSObject.size() >0 && sobCaseToUpsert != NULL && sobCaseToUpsert.ID != NULL){
                           list<LP_KYC_Document__c> lstKYCDocument = new list<LP_KYC_Document__c>();
                            for(LP_KYC_Document__c eachDoc : lstKYCDocSObject){
                                eachDoc.LP_Case__c = sobCaseToUpsert.Id;
                                lstKYCDocument.add(eachDoc);
                            }
                            if(lstKYCDocument != NULL && lstKYCDocument.size()>0)
                                upsert lstKYCDocument;
                        }
                         
                        if(sobCaseToUpsert!= null)
                            theLog.SalesforceRecordId__c = sobCaseToUpsert.Id; 
                        
                        theLog.Status__c = 'SUCCESS'; 
                        return theLog;
                    }
                    catch(Exception ex){
                        LazyPayExceptionHandling.ErrorLogWrapper objWrapper = new LazyPayExceptionHandling.ErrorLogWrapper();
                        objWrapper.message = ex.getMessage();
                        objWrapper.process = 'LazyPay Consumer Batch';
                        objWrapper.response = jsonStr;
                        objWrapper.stackTrace = ex.getStackTraceString();
                        lstException.add(objWrapper);
                        theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); theLog.Status__c = 'SUCCESS';
                        return theLog;

                    }
               }
            else{
                theLog.Status__c = 'SUCCESS'; 
                return theLog;
            }
        }
        else{ 
            theLog.Status__c = 'SUCCESS'; return theLog; 
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
    public void populateField(SObject sobToUpsert,String node,String fieldApi,String data,String SObjectName){
        
        
        if(String.isNotBlank(fieldApi) && String.isNotBlank(data)){
            
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
                    /*if(data == 'DECLINED')
                        sobToUpsert.put(fieldAPI.subStringBefore(','),data);
                    else*/
                       sobToUpsert.put(fieldAPI.subStringBefore(','),valueFormatToLowerCase(data)); 
                }
                else{
                    system.debug('mapOfDocNameVsDocId========='+mapOfDocNameVsDocId);
                    if(fieldAPI.subStringBefore(',') == 'recordTypeName')
                        sobToUpsert.put('recordTypeId',SystemUtility.getRecordTypeId(SObjectName,data));
                    else if(mapOfDocNameVsDocId != NULL && mapOfDocNameVsDocId.size()>0 && String.isNotBlank(node) && node == 'documentTypeId'){
                        sobToUpsert.put(fieldAPI.subStringBefore(','), mapOfDocNameVsDocId.get(data));
                        system.debug('fieldAPI==========='+fieldAPI);
                        system.debug('sobToUpsert==========='+sobToUpsert);
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
    public SObject populateDirectFields(PayloadActMap__mdt thePayLoadMap,Map<String, Object> jsonRootMap,string uuid,
                                        Map<String, String> arrayNodeMap,Map<String, String> complexNodeMap){
                                       
        system.debug('<<Case++>>' + arrayNodeMap);
        system.debug('jsonRootMap========' + jsonRootMap);
        system.debug('kycTypeId========' + jsonRootMap.get('kycTypeId'));
        Map<String, String> jsonFieldMap;
        SObject sobToUpsert;
        if(String.isNotBlank(thePayLoadMap.JsonMap__c)){
            jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMap__c, Map<String, String>.class);
        }
        globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
        sobToUpsert = globalDescribe.get(thePayLoadMap.Sobject__c).newSObject(); 
        
        //prepare document map to fill the documsnt master field lookup value on kyc document
        if(mapOfDocNameVsDocId!= NULL && mapOfDocNameVsDocId.size() == 0){
           fillDocumentMap(thePayLoadMap,jsonRootMap);
        }
        
        if(jsonRootMap != NULL && jsonRootMap.containsKey('uuid') && thePayLoadMap.Sobject__c == 'Contact'){
            String queryStr = 'SELECT Id,LP_Timestamp__c,LP_DateStamp__c,lastname FROM ' + thePayLoadMap.Sobject__c + ' WHERE Identifier__c = \'' + jsonRootMap.get('uuid') + '\'';
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
                            (objWrap.dateStamp == existingDate && objWrap.timestamp < existingTime && jsonRootMap.get('overrideExistingData') == true)
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
                            System.debug('newDate========'+objWrap.dateStamp);
                            System.debug('newTime========'+objWrap.timestamp);
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
            String queryStr = 'SELECT Id,OwnerId FROM ' + thePayLoadMap.Sobject__c + ' WHERE LP_UUID__c = \'' + jsonRootMap.get('uuid') + '\' AND recordtype.Name = \''+jsonRootMap.get('recordTypeName') + '\'';

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
                system.debug('combo========'+combo);
                String queryStr = 'SELECT Id FROM ' + thePayLoadMap.Sobject__c + ' WHERE LP_Unique_Key__c = \'' + combo + '\'';
                system.debug('queryStr========'+queryStr);
                List<Sobject> getIdList = Database.query(queryStr);
                system.debug('getIdList========'+getIdList);
                if(!getIdList.isEmpty()){
                    sobToUpsert.put('Id', getIdList[0].Id);
                }
            }
            
        }
        if(jsonFieldMap!= NULL && jsonFieldMap.size()>0){
            for(String eachKey : jsonFieldMap.keyset()){
                populateField(sobToUpsert,eachKey,jsonFieldMap.get(eachKey),String.valueOf(jsonRootMap.get(eachKey)),thePayLoadMap.Sobject__c);
            }
        }
       System.debug('sobToUpsert========='+sobToUpsert);                                     
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
    public void fillDocumentMap(PayloadActMap__mdt thePayLoadMap,Map<String, Object> jsonRootMap){
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
                        }
                        system.debug('mapOfDocNameVsDocId  111========='+mapOfDocNameVsDocId);
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
        System.debug('status=========='+status);
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
        system.debug('result========='+result);
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
}