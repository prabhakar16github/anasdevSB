public with sharing class DLQConsumerBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.stateful{
        
    public List<Map<String, String>> receiptHandleMapList = new List<Map<String, String>>();
    public Set<String> leadIdSet = new Set<String>();
    public Set<String> bankAccountIdSet = new Set<String>();
    public String thePayloadName = '';
    public String deleteMessageName = '';
    public Boolean isStatDLQ = false;
    public Boolean deleteMessage = false;
    public Integer executeCount = 1;
    
    public static Boolean isFinishExecuted = false;
    
    public DLQConsumerBatch(){ thePayloadName = 'GetMessageSQS'; deleteMessageName = 'DeleteMessageBatchSQS'; }
    
    public DLQConsumerBatch(Boolean isDLQ, Boolean markSuccess, Integer theCount){
        if(isDLQ){
            thePayloadName = 'GetMessageDLQ'; deleteMessageName = 'DeleteMessageBatchDLQ';
            isStatDLQ = isDLQ; deleteMessage = markSuccess;
        }else{thePayloadName = 'GetMessageSQS'; deleteMessageName = 'DeleteMessageBatchSQS';}
        
        if(theCount != null && theCount > 1) executeCount = theCount;
    }
    
    public Iterable<String> start(Database.BatchableContext BC){
        List<String> theCountList = new List<String>();        
        for(Integer i = 0; i < executeCount; i++){ theCountList.add(String.valueOf(i)); }
        return theCountList;
    }
 
    public void execute(Database.BatchableContext info, List<String> strings){
        
        HttpResponse messageRes = AWSUtility.getAWSData(thePayloadName, null, null, '', null); 
        System.debug(messageRes.getStatusCode() + '>>>>>>>>>>_____________>>>>>>>>>>>___________'+ messageRes.getBody());
        if(messageRes != null && messageRes.getStatusCode() == 200){                
            parseXML(messageRes.getBody());
        }                       
    }
 
    public void finish(Database.BatchableContext info){
        Organization org = [SELECT Id, IsSandbox FROM Organization];
        
        if(!receiptHandleMapList.isEmpty() && (!org.IsSandbox || (org.IsSandbox && deleteMessage))){
            for(Map<String, String> eachMap : receiptHandleMapList){
                Integer i = 1;
                Map<String, String> tempMap = new Map<String, String>();
                
                for(String each : eachMap.keySet()){
                    String tempStr = 'DeleteMessageBatchRequestEntry.' + i + '.Id=msg'+ i + '&DeleteMessageBatchRequestEntry.' + i + '.ReceiptHandle=' + each;                            
                    tempMap.put(String.valueOf(i), tempStr);
                    i++;                
                }
                
                List<String> mapKeys = new List<String>(tempMap.keyset()); mapKeys.sort();
                List<String> mapValues = new List<String>();
                for(String each : mapKeys){ mapValues.add(tempMap.get(each)); }
                
                HttpResponse deleteRes = AWSUtility.getAWSData(deleteMessageName, new List<String>{String.join(mapValues, '&')}, null, '', null);
                System.debug(deleteRes.getStatusCode() + '>>>>>>>>>>_____________>>>>>>>>>>>___________'+ deleteRes.getBody());
            }
        }
        
        if(!bankAccountIdSet.isEmpty()) BankDetailTriggerHandler.afterInsertHandler(Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Detail__c WHERE Id IN (\'' + String.join(new List<String>(bankAccountIdSet), '\',\'') + '\')'));        
        
        if(!leadIdSet.isEmpty()){
            isFinishExecuted = true;
            
            List<String> accIds = new List<String>();
            List<String> oppIds = new List<String>();
            
            for(Lead each : Database.query('SELECT Id, IsConverted, ConvertedAccountId, ConvertedOpportunityId FROM Lead WHERE Id IN (\'' + String.join(new List<String>(leadIdSet), '\',\'') + '\')')){
                
                if(each.isConverted){
                    if(String.isNotBlank(each.ConvertedOpportunityId)){
                        oppIds.add(each.ConvertedOpportunityId);
                    }
                    
                    if(String.isNotBlank(each.ConvertedAccountId)){
                        accIds.add(each.ConvertedAccountId);
                    }
                }
            }
            
            if(!accIds.isEmpty()){
                for(Account each : Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(accIds), '\',\'') + '\')')){                    
                    IntegrationUtility.sendPayLoadData(each, null, 'Account', 'Account');                    
                }
            }
            
            if(!oppIds.isEmpty()){
                for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\')')){                    
                    IntegrationUtility.oppConvertedSet.add(each.Id);
                    IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Lead'); 
                                       
                }
            }
        }
        
        if(!Test.isRunningTest() && Label.repeatDLQExecution == 'YES') Database.executeBatch(new DLQConsumerBatch(true, true, executeCount), 1);
    }
   
    public void parseXML(String xml){
        Map<String, String> receiptHandleMap = new Map<String, String>();
        List<PayLoad_Log__c> logsToInsert = new List<PayLoad_Log__c>();
        
        Dom.Document doc = new Dom.Document();
        doc.load(xml);  
        
        Dom.XmlNode rootNode = doc.getRootElement();
        if(rootNode != null){
            
            String nameSpace = rootNode.getNamespace(); 
            Dom.XmlNode msgResult = rootNode.getChildElement('ReceiveMessageResult', nameSpace); 
            
            if(msgResult != null){
                for(Dom.XmlNode each : msgResult.getChildElements()){
                    String body = each.getChildElement('Body', nameSpace).getText();
                    String receiptHandle = each.getChildElement('ReceiptHandle', nameSpace).getText();
                    
                    if(parseJSON(body)){ 
                        insertLog(body, logsToInsert);                                                                       
                        if(String.isNotBlank(receiptHandle)){                        
                            receiptHandle = AWSUtility.encode(receiptHandle);
                            receiptHandleMap.put(receiptHandle, null);                                                    
                        }
                    }else{SystemUtility.errorHandler(null, new Map<String, String>{'Process__c' => (isStatDLQ ? 'DLQ Consumer Batch' : 'AWS Consumer Batch'), 'Severity__c' => 'High', 'Exception Details' => exceptionMessage, 'PayLoad' => body, 'receiptHandle' => receiptHandle});}                  
                } 
            }
        } 
        
        if(!receiptHandleMap.isEmpty()){ receiptHandleMapList.add(receiptHandleMap); }
        if(!logsToInsert.isEmpty()){ Database.insert(logsToInsert, false); }                                                 
    }        
    
    public void insertLog(String theBody, List<PayLoad_Log__c> logsToInsert){
        logsToInsert.add(new PayLoad_Log__c(Payload__c = theBody));    
    }
        
    static Map<String, Schema.SObjectType> globalDescribe;
    static Map<String, String> midMap = new Map<String, String>{'mid' => 'Prod_Merchant_Id__c', 'test_mid' => 'Merchant_Id__c'};
    static Set<String> midObjs = new Set<String>{'Lead', 'Opportunity'};
    static Map<String, String> businessObjs = new Map<String, String>{'Lead' => 'Lead_Type__c', 'Account' => 'Type__c'};
    static Map<String, Set<String>> sobFieldMap = new Map<String, Set<String>>();
    public static String exceptionMessage = '';
    
    public static Set<String> getFieldSet(String sobType){
        
        Set<String> setToReturn = new Set<String>();
        
        if(sobFieldMap.containsKey(sobType)) setToReturn = sobFieldMap.get(sobType);        
        else{
            globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;            
            Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(sobType).getDescribe().fields.getMap();
            
            for(Schema.SObjectField each : fieldMap.Values()){
                schema.describefieldresult dfield = each.getDescribe();
                setToReturn.add(dfield.getName());
            }            
            sobFieldMap.put(sobType, setToReturn);
        }
        
        return setToReturn;
    }    
    
    public Boolean parseJSON(String jsonStr){ 
        exceptionMessage = '';       
        Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                        
        String action = String.valueOf(jsonRootMap.get('action'));        
        String product = String.valueOf(jsonRootMap.get('product'));        
        String businessObj = String.valueOf(jsonRootMap.get('business_object'));        
        String producer = String.valueOf(jsonRootMap.get('producer'));         
        if(String.isNotBlank(action) && !'Salesforce'.equals(producer)){  
            
            globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
                                 
            for(PayloadActMap__mdt thePayLoadMap : IntegrationUtility.getPayLoadMap(action, '', businessObj)){  
                String recentKey = '';
                try{                    
                    Map<String, String> jsonFieldMap;
                    if(String.isNotBlank(thePayLoadMap.JsonMap__c)) jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMap__c, Map<String, String>.class);
                                        
                    Map<String, String> lookUpNodeMap;
                    if(String.isNotBlank(thePayLoadMap.LookUpField__c)) lookUpNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.LookUpField__c, Map<String, String>.class);                    
                    
                    Map<String, String> complexNodeMap;
                    if(String.isNotBlank(thePayLoadMap.JsonMapComp__c)) complexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMapComp__c, Map<String, String>.class);                    
                    
                    Map<String, Object> secCondMap;
                    if(String.isNotBlank(thePayLoadMap.SecondaryCond__c) && String.isNotBlank(thePayLoadMap.SecondaryObject__c)) secCondMap = (Map<String, Object>)JSON.deserializeUntyped(thePayLoadMap.SecondaryCond__c);                    
                                    
                    Map<String, Object> currentDataMap;
                    Map<String, Object> oldDataMap;
                    
                    if(jsonRootMap.containsKey('current_data')) currentDataMap = (Map<String, Object>)jsonRootMap.get('current_data');                       
                    
                    if(jsonRootMap.containsKey('old_data')) oldDataMap = (Map<String, Object>)jsonRootMap.get('old_data');                    
                               
                    Sobject sobToUpsert;
                    String theSobject = thePayLoadMap.Sobject__c;
                    Set<String> theFields = getFieldSet(theSobject);                    
                    sobToUpsert = globalDescribe.get(theSobject).newSObject();
                    
                    if(currentDataMap != null && !currentDataMap.isEmpty() && (complexNodeMap != null && !complexNodeMap.isEmpty() || jsonFieldMap != null && !jsonFieldMap.isEmpty())){                                                                                                       
                        
                        if(secCondMap != null && !secCondMap.isEmpty()){
                            
                            Boolean createSecObj = false;
                            
                            for(String eachSecKey : secCondMap.keySet()){
                                if(currentDataMap.containsKey(eachSecKey) && secCondMap.get(eachSecKey) != null && currentDataMap.get(eachSecKey) != null){
                                    createSecObj = String.valueOf(secCondMap.get(eachSecKey)).contains(String.valueOf(currentDataMap.get(eachSecKey)));                                 
                                }
                            }
                            
                            if(createSecObj){ theSobject = thePayLoadMap.SecondaryObject__c; theFields = getFieldSet(theSobject); sobToUpsert = globalDescribe.get(theSobject).newSObject(); }
                        }
                        
                        if(currentDataMap.containsKey('uuid')){
                            String isConvertedStr = (theSobject == 'Lead') ? ', isConverted' : '';
                            String queryStr = 'SELECT Id '+ isConvertedStr + ' FROM ' + theSobject + ' WHERE Identifier__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                            List<Sobject> getIdList = Database.query(queryStr);
                            
                            Boolean queryOpp = false;                                                        
                            
                            if(!getIdList.isEmpty()){
                                if(theSobject == 'Lead' && getIdList[0].get('isConverted') == true) queryOpp = true;
                                else sobToUpsert.put('Id', getIdList[0].Id);                                
                            }
                            
                            if(theSobject == 'Lead' && String.isNotBlank(thePayLoadMap.SecondaryObject__c) && (getIdList.isEmpty() || queryOpp)){
                                
                                String queryStrOpp = 'SELECT Id FROM ' + thePayLoadMap.SecondaryObject__c + ' WHERE Identifier__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                List<Sobject> getIdListOpp = Database.query(queryStrOpp);
                                
                                if(!getIdListOpp.isEmpty()){ 
                                    theSobject = thePayLoadMap.SecondaryObject__c; 
                                    theFields = getFieldSet(theSobject);                                                                      
                                    sobToUpsert = globalDescribe.get(theSobject).newSObject();                                    
                                    sobToUpsert.put('Id', getIdListOpp[0].Id);                                                                
                                }
                            }
                            
                            if(String.isNotBlank(thePayLoadMap.Delete_Action__c) && thePayLoadMap.Delete_Action__c == action && sobToUpsert.get('Id') != null){delete sobToUpsert; return true;}
                        }
                        
                        for(String each : currentDataMap.keySet()){                        
                            recentKey = each;
                            if(complexNodeMap != null && complexNodeMap.containsKey(each)){                                        
                                Object theCompNode = currentDataMap.get(each);
                                
                                if(theCompNode != null){
                                    Map<String, Object> complexDataMap = (Map<String, Object>)theCompNode;
                                    Map<String, String> complexKeyFieldMap = new Map<String, String>();
                                    
                                    for(String eachStr : complexNodeMap.get(each).split(';')){
                                        complexKeyFieldMap.put(eachStr.subStringBefore(':'), eachStr.subStringAfter(':'));
                                    }
                                                        
                                    if(!complexKeyFieldMap.isEmpty()){
                                        for(String eachCompStr : complexDataMap.keySet()){  
                                            populateField(sobToUpsert, lookUpNodeMap, eachCompStr, complexDataMap.get(eachCompStr), complexKeyFieldMap.get(eachCompStr), thePayLoadMap.ReadOnly__c, theFields);                                 
                                        } 
                                    } 
                                }                  
                            }else{
                                
                                if(jsonFieldMap != null && jsonFieldMap.containsKey(each)){
                                    for(String eachJsonStr : jsonFieldMap.get(each).split(';')){
                                        populateField(sobToUpsert, lookUpNodeMap, each, currentDataMap.get(each), eachJsonStr, thePayLoadMap.ReadOnly__c, theFields); 
                                    }                               
                                }
                                else if(lookUpNodeMap != null && lookUpNodeMap.containsKey(each)){
                                    populateField(sobToUpsert, lookUpNodeMap, each, currentDataMap.get(each), lookUpNodeMap.get(each), thePayLoadMap.ReadOnly__c, theFields);                                
                                }
                            }
                        }
                    }
                                    
                    if(midObjs.contains(theSobject)){
                        for(String each : jsonRootMap.keySet()){
                            if(midMap.containsKey(each)){
                                sobToUpsert.put(midMap.get(each), jsonRootMap.get(each));
                                break;
                            }
                        }
                    }
                    
                    
                    System.debug(businessObjs.containsKey(theSobject) + '------------------>>>>>>>>>>>> ' + theSobject);
                    System.debug('------------------>>>>>>>>>>>> ' + sobToUpsert);
                    
                    if(businessObjs.containsKey(theSobject)){                    
                        sobToUpsert.put(businessObjs.get(theSobject), businessObj);
                    }
                                                                    
                    System.debug('------------------>>>>>>>>>>>> ' + jsonStr);
                    System.debug('------------------>>>>>>>>>>>> ' + sobToUpsert);
                    
                    upsert sobToUpsert;
                    
                    if(theSobject == 'Bank_Account_Detail__c' && sobToUpsert.get('Lead__c') != null && String.valueOf(sobToUpsert.get('Verification_Status__c')) == 'Success'){
                        leadIdSet.add(String.valueOf(sobToUpsert.get('Lead__c')));
                        if(action == 'create_bank_detail') bankAccountIdSet.add(String.valueOf(sobToUpsert.get('Id')));                        
                    }
                    
                    return true;      
                    
                }catch(exception ex){exceptionMessage = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString();return false;}             
            }}else if('Salesforce'.equals(producer)){ return true; }
        
        return false;        
    }
        
    public static void populateField(Sobject sobToUpsert, Map<String, String> lookUpNodeMap, String theNode, Object theData, String fieldAPI, String readOnlyFields, Set<String> fields){
        
        if(lookUpNodeMap != null && lookUpNodeMap.containsKey(theNode) && String.isNotBlank(lookUpNodeMap.get(theNode))){
            for(String each : lookUpNodeMap.get(theNode).split(';')){
                String lookUpQueryStr = each.subStringAfter(',');
                String lookUpFieldAPI = each.subStringBefore(',');
                
                if(String.isNotBlank(lookUpFieldAPI) && fields.contains(lookUpFieldAPI)){
                    String queryStr = 'SELECT Id FROM ' + lookUpQueryStr.subStringBefore(':') + ' WHERE ' + lookUpQueryStr.subStringAfter(':') + ' = \'' + theData + '\'';          
                    
                    List<Sobject> queriedList = Database.query(queryStr);
                    if(!queriedList.isEmpty()){ sobToUpsert.put(lookUpFieldAPI, queriedList[0].Id); break; }
                }
            }
        }else{
            if(String.isNotBlank(fieldAPI)){
                String theAPI = fieldAPI.subStringBefore(',');
                if(fields.contains(theAPI)){
                    if(String.isBlank(readOnlyFields) || !readOnlyFields.contains(theAPI)) sobToUpsert.put(theAPI, theData);                                        
                }  
            }                                         
        }
    }
}