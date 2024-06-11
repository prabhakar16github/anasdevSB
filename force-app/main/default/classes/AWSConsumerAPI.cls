@RestResource(urlMapping='/AWSConsumer/*')
global class AWSConsumerAPI{

    public static Map<String, String> receiptHandleMap = new Map<String, String>();
    public static Set<String> leadIdSet = new Set<String>();
    public static Set<String> bankAccountIdSet = new Set<String>();
    public static Set<String> bankAccountIdSetUpdate = new Set<String>();
    public static Set<String> addressIdSetUpdate = new Set<String>();
    public static List<String> contractAccIds = new List<String>();
    public static Set<string> websiteURLoppIds = new Set<String>();
    public static Set<String> contractIds = new Set<String>();
    public static Set<String> merchantDocAccIds = new Set<string>();
    public static set<string> setproducername = new set<string>();
    public static Set<string> updatedWebsiteURLoppIds = new Set<String>();
    /*
    @HttpGet
    global static string start(){
        HttpResponse messageRes = AWSUtility.getAWSData('GetMessageSQS', null, null, '', null); 
        
        System.debug(messageRes.getStatusCode() + '>>>>>>>>>>_____________>>>>>>>>>>>___________'+ messageRes.getBody());
        
        if(messageRes != null && messageRes.getStatusCode() == 200){                
            parseXML(messageRes.getBody());
        }
        
        finish(receiptHandleMap, leadIdSet, bankAccountIdSet);
        
        if(!receiptHandleMap.isEmpty()){
            return 'success';
        }
        else {
            return 'Finished';
        }
    }
    
    @future (Callout=true)
    global static void finish(Map<String, String> receiptHandleMap, Set<String> leadIdSet, Set<String> bankAccountIdSet){
        //----- Batch Finish Method ----- //
        if(!receiptHandleMap.isEmpty()){
            Integer i = 1;
            Map<String, String> tempMap = new Map<String, String>();
            
            for(String each : receiptHandleMap.keySet()){
                String tempStr = 'DeleteMessageBatchRequestEntry.' + i + '.Id=msg'+ i + '&DeleteMessageBatchRequestEntry.' + i + '.ReceiptHandle=' + each;                            
                tempMap.put(String.valueOf(i), tempStr);
                i++;                
            }
            
            List<String> mapKeys = new List<String>(tempMap.keyset()); mapKeys.sort();
            List<String> mapValues = new List<String>();
            for(String each : mapKeys){ mapValues.add(tempMap.get(each)); }
            
            HttpResponse deleteRes = AWSUtility.getAWSData('DeleteMessageBatchSQS', new List<String>{String.join(mapValues, '&')}, null, '', null);
            System.debug(deleteRes.getStatusCode() + '>>>>>>>>>>_____________>>>>>>>>>>>___________'+ deleteRes.getBody());
        }
        
        if(!bankAccountIdSet.isEmpty()) BankDetailTriggerHandler.afterInsertHandler(Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Detail__c WHERE Id IN (\'' + String.join(new List<String>(bankAccountIdSet), '\',\'') + '\')'));        
        
        if(!leadIdSet.isEmpty()){
            
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
        
        if(!websiteURLoppIds.isEmpty()){
            string sObjectName = 'Opportunity';
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(websiteURLoppIds,sObjectName,setproducerName);
            Database.executeBatch(oppPublisherBatch);
        }
        
        if(!merchantDocAccIds.isEmpty()){
            string accountSObjectName = 'Account';
            PublishExistingOppotunityWebsiteBatch accountPublisherBatch = new PublishExistingOppotunityWebsiteBatch(merchantDocAccIds,accountSObjectName,setproducerName);
            Database.executeBatch(accountPublisherBatch);
        }
        //--Added to remeove agreement issue--//
        if(!bankAccountIdSetUpdate.isEmpty()){
            string agreementSObjectName = 'Bank_Account_Detail__c';
            PublishExistingOppotunityWebsiteBatch updateAgreementBatch = new PublishExistingOppotunityWebsiteBatch(bankAccountIdSetUpdate,agreementSObjectName,setproducerName);
            Database.executeBatch(updateAgreementBatch);
        }
        //---// 
        
        // ============ Refresh Agreement After website Change==============
        if(!updatedWebsiteURLoppIds.isEmpty()){
            string sObjectName = 'WebsiteOpportunity';
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(updatedWebsiteURLoppIds,sObjectName,setproducerName);
            Database.executeBatch(oppPublisherBatch);
        }
        
        // ============ Send agreement change account payload==============
        if(!contractIds.isEmpty()){
            string sObjectName = 'Contract';
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(contractIds,sObjectName,setproducerName);
            Database.executeBatch(oppPublisherBatch);
        }
        
        if(!bankAccountIdSet.isEmpty()) BankDetailTriggerHandler.afterInsertHandler(Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Detail__c WHERE Id IN (\'' + String.join(new List<String>(bankAccountIdSet), '\',\'') + '\')'));        
        //if(!bankAccountIdSetUpdate.isEmpty()) BankDetailTriggerHandler.updateagreementinOnlineCaseWithnewURL(bankAccountIdSetUpdate);
        if(!addressIdSetUpdate.isEmpty()) System.enqueueJob(new generateAgreementFromAddressUpdate(addressIdSetUpdate));
        
        //-----/Batch Finish Method ----- //
    }
   
    public static void parseXML(String xml){
    
        Dom.Document doc = new Dom.Document();
        doc.load(xml);  
        
        Dom.XmlNode rootNode = doc.getRootElement();
        if(rootNode != null){
            
            String nameSpace = rootNode.getNamespace(); 
            Dom.XmlNode msgResult = rootNode.getChildElement('ReceiveMessageResult', nameSpace); 
            
            if(msgResult != null){
                for(Dom.XmlNode each : msgResult.getChildElements()){
                    String body = each.getChildElement('Body', nameSpace).getText();
                    if(parseJSON(body)){
                        String receiptHandle = each.getChildElement('ReceiptHandle', nameSpace).getText();
                        
                        if(String.isNotBlank(receiptHandle)){                        
                            receiptHandle = AWSUtility.encode(receiptHandle);
                            receiptHandleMap.put(receiptHandle, null);                                                    
                        }
                    }                  
                } 
            }
        }                                        
    }        
        
    static Map<String, Schema.SObjectType> globalDescribe;
    static Map<String, String> midMap = new Map<String, String>{'mid' => 'Prod_Merchant_Id__c', 'test_mid' => 'Merchant_Id__c'};
    static Set<String> midObjs = new Set<String>{'Lead', 'Opportunity'};
    static Map<String, String> businessObjs = new Map<String, String>{'Lead' => 'Lead_Type__c'};
    static Map<String, Set<String>> sobFieldMap = new Map<String, Set<String>>();
    
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
    
    public static Boolean parseJSON(String jsonStr){        
        Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                        
        String action = String.valueOf(jsonRootMap.get('action'));        
        String product = String.valueOf(jsonRootMap.get('product'));        
        String businessObj = String.valueOf(jsonRootMap.get('business_object'));        
        String producer = String.valueOf(jsonRootMap.get('producer'));         
        if(String.isNotBlank(action) && !'Salesforce'.equals(producer)){  
            
            globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
                                 
            for(PayloadActMap__mdt thePayLoadMap : IntegrationUtility.getPayLoadMap(action, '', businessObj)){                                                                   
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
                            
                            if(createSecObj){        
                                theSobject = thePayLoadMap.SecondaryObject__c;  
                                theFields = getFieldSet(theSobject);                  
                                sobToUpsert = globalDescribe.get(theSobject).newSObject();                                                                
                            }
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
                            
                            if(String.isNotBlank(thePayLoadMap.Delete_Action__c) && thePayLoadMap.Delete_Action__c == action && sobToUpsert.get('Id') != null){
                                delete sobToUpsert; return true;
                            }
                        }
                        
                        for(String each : currentDataMap.keySet()){                        
                            
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
                    
                    if(theSobject == 'Bank_Account_Detail__c' && sobToUpsert.get('Lead__c') != null){
                        if(sobToUpsert.get('Opportunity__c') == null && sobToUpsert.get('Active__c')==true){
                            leadIdSet.add(String.valueOf(sobToUpsert.get('Lead__c')));
                        }
                        if(action == 'create_bank_detail') bankAccountIdSet.add(String.valueOf(sobToUpsert.get('Id')));
                    } 
                    if(action == 'update_bank_detail'&& sobToUpsert.get('Lead__c') == null && sobToUpsert.get('Opportunity__c') != null
                       && sobToUpsert.get('Active__c')==true && String.valueOf(sobToUpsert.get('Verification_Status__c')) == 'Success'){
                           bankAccountIdSetUpdate.add(String.valueOf(sobToUpsert.get('Id')));
                       } 
                    if(action == 'update_address') addressIdSetUpdate.add(String.valueOf(sobToUpsert.get('Id')));                    
                    if(theSobject == 'Lead' && businessObj == 'Partner' && action == 'create') leadIdSet.add(String.valueOf(sobToUpsert.get('Id')));
                    //===========Changes for UTM_Campaign JIRA=====================
                    if(theSobject == 'Opportunity' && businessObj == 'Partner' && action == 'update' && sobToUpsert.get('Queue_Name__c') != null) 
                        websiteURLoppIds.add(String.valueOf(sobToUpsert.get('Id')));
                    if(theSobject == 'Contract' && (action == 'create_kyc_doc' || action == 'update_kyc_doc') && sobToUpsert.get('AccountId') != null 
                       && sobToUpsert.get('URL__c') != null && sobToUpsert.get('Contract_Type__c') == 'Agreement'){
                           contractAccIds.add(string.valueOf(sobToUpsert.get('AccountId')));
                           contractIds.add(string.valueOf(sobToUpsert.get('Id')));
                       } 
                    
                    if(theSobject == 'Opportunity' && action == 'update' && Producer!= 'PayUmoney' 
                       && (sobToUpsert.get('Website_Status__c') == 'Pending' || sobToUpsert.get('Website_Status__c')=='Verification in Process')
                       && (sobToUpsert.get('Website__c') != null || sobToUpsert.get('IOS_URL__c') != null || sobToUpsert.get('Android_URL__c') != null)
                       && sobToUpsert.get('Integration_Type__c')=='Thirdparty'){
                           
                           websiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                       }   
                    if(theSobject == 'Merchant_Document__c' && ((sobToUpsert.get('Account__c') != null 
                                                                 && sobToUpsert.get('URL__c') != null && sobToUpsert.get('KYC_Documentable_Type__c') =='Account') || 
                                                                action=='delete_kyc_doc')){
                                                                    merchantDocAccIds.add(string.valueOf(sobToUpsert.get('Account__c')));
                                                                }
                    
                    if(theSobject == 'Opportunity' && action == 'update' && Producer == 'PayUmoney' &&
                       (sobToUpsert.get('Settlement_Status__c')=='Thirdparty Hold' || sobToUpsert.get('Settlement_Status__c')==null)
                       && businessObj=='Merchant' && string.isNotBlank(product) && product=='PayUmoney'){
                           websiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                       }
                    /*
                    if(theSobject == 'Opportunity' && action == 'update' && Producer!= 'PayUmoney' 
                       && (sobToUpsert.get('Website_Status__c') == 'Pending' || sobToUpsert.get('Website_Status__c')=='Verification in Process')
                       && (sobToUpsert.get('Website__c') != null || sobToUpsert.get('IOS_URL__c') != null || sobToUpsert.get('Android_URL__c') != null)
                       && sobToUpsert.get('Integration_Type__c')=='Thirdparty' 
                       && ((oldSobToUpsert.get('Website__c') != null && sobToUpsert.get('Website__c') != null && sobToUpsert.get('Website__c') != oldSobToUpsert.get('Website__c')) || (oldSobToUpsert.get('IOS_URL__c') != null && sobToUpsert.get('IOS_URL__c') != null && sobToUpsert.get('IOS_URL__c') != oldSobToUpsert.get('IOS_URL__c')) || (oldSobToUpsert.get('Android_URL__c') != null && sobToUpsert.get('Android_URL__c') != null && sobToUpsert.get('Android_URL__c') != oldSobToUpsert.get('Android_URL__c')))){
                           
                           updatedWebsiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                       }*/
                    
                /*    return true;      
                    
                }catch(exception e){return false;}             
            }          
        }
        
        return false;        
    }
        
    public static void populateField(Sobject sobToUpsert, Map<String, String> lookUpNodeMap, String theNode, Object theData, String fieldAPI, String readOnlyFields, Set<String> fields){
        List<String> theReadOnlySet = String.isBlank(readOnlyFields) ? null : readOnlyFields.split(',');
    
        if(lookUpNodeMap != null && lookUpNodeMap.containsKey(theNode) && String.isNotBlank(lookUpNodeMap.get(theNode))){
            for(String each : lookUpNodeMap.get(theNode).split(';')){
                String lookUpQueryStr = each.subStringAfter(',');
                String lookUpFieldAPI = each.subStringBefore(',');
                
                if(String.isNotBlank(lookUpFieldAPI) && fields.contains(lookUpFieldAPI)){
                    String queryStr = 'SELECT Id FROM ' + lookUpQueryStr.subStringBefore(':') + ' WHERE ' + lookUpQueryStr.subStringAfter(':') + ' = \'' + theData + '\'';          
                    
                    List<Sobject> queriedList = Database.query(queryStr);
                    if(!queriedList.isEmpty()){
                        sobToUpsert.put(lookUpFieldAPI, queriedList[0].Id); 
                        break;                   
                    }
                }
            }
        }else{
            if(String.isNotBlank(fieldAPI)){
                String theAPI = fieldAPI.subStringBefore(',');
                String fieldType = fieldAPI.subStringAfter(',');
                if(fields.contains(theAPI) || theAPI.equalsIgnoreCase('Penny_Verification_Required__c')){
                    if(theReadOnlySet == null || !theReadOnlySet.contains(theAPI)) sobToUpsert.put(theAPI, getformattedData(theData, fieldType));                                        
                }  
            }                                         
        }
    }
    
    public static Object getformattedData(Object theData, String dataType){
        return (theData != null && 'datetime'.equals(dataType)) ? Datetime.valueOf(String.valueOf(theData)) : theData;
    }
    
    public static String getJsonStr(Object theJsonObj){
        String theJsonValue = '';
        List<String> strList = new List<String>();
        if(theJsonObj != null){
            List<Object> objList = (List<Object>)theJsonObj;
            if(objlist != null){
                for(Object js : objlist){
                    //strList = new List<String>();
                    Map<String, Object> tempMap = (Map<String, Object>)js;
                    String str = JSON.serialize(tempMap);
                    strList.add(str);
                }
                system.debug('@@@@@@@@---- '+strList);
                //theJsonValue = JSON.serialize(strList);
                theJsonValue = String.join(strList, ', ');
            }else{
                Map<String, Object> tempMap = (Map<String, Object>)theJsonObj;
                theJsonValue = JSON.serialize(tempMap);
                //strList.add(theJsonValue);
            }
        }
        return theJsonValue;
    }*/
    
    @HTTPGET
    global static string start(){
       /* String hashAlgo = 'HmacSHA256';  
        String endPointUrl = 'https://sqs.ap-south-1.amazonaws.com/837630141694/prod-esb-saas-focus.fifo?Action=ReceiveMessage&MaxNumberOfMessages=10&Version=2012-11-05';                         
        List<String> paramValue = New List<String>();
        Blob blobBody = null;
        String strBody = '';
        Sobject headParamSob = null;
        string body = '';
        String SECRET_KEY = 'GqiVBiYTRDrBRHzwjaNy840qw/AjZ7NXoiUSp+Kz';
        String ACCESS_KEY = 'AKIA4GBVFUT7FJAVP7CN';
        Url theUrl = new Url(endPointUrl);
        String host = theUrl.getHost();
        String path = theUrl.getPath();
        String canonicalQueryString = theUrl.getQuery();
        HttpRequest req = new HttpRequest();
        String headers = 'content-type:application/x-www-form-urlencoded';            
        String payloadHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', blobBody != null ? blobBody : (Blob.valueOf(String.isNotBlank(body) ? body : strBody))));               
        
        String currentDate = System.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
        String currentDateOnly = System.now().formatGMT('yyyyMMdd');                         
        Map<String, String> canonicalHeaderMap = new Map<String, String>{'host' => host, 'x-amz-date' => currentDate}; 
            canonicalHeaderMap.put('x-amz-content-sha256', payloadHash);
        
        if(String.isNotBlank(headers)){
            for(String each : headers.split(',')){                     
                String theParam = headParamSob == null ? each.subStringAfter(':') : String.valueOf(headParamSob.get(each.subStringAfter(':')));                     
                req.setHeader(each.subStringBefore(':'), theParam);                
                canonicalHeaderMap.put(each.subStringBefore(':'), theParam);                                                            
            }
        }
        
        List<String> signedHeaderList = new List<String>(canonicalHeaderMap.keySet());   
        
        signedHeaderList.sort();
        
        String signedHeaders = String.join(signedHeaderList, ';');   
        
        List<String> canonicalHeaderList = new List<String>();  
        
        for(String eachStr : signedHeaderList){
            canonicalHeaderList.add(eachStr + ':' + canonicalHeaderMap.get(eachStr));
        }   
        
        String canonicalHeaders = String.join(canonicalHeaderList, '\n') +  '\n';                               
        
        String canonicalRequest = String.join(new List<String>{'GET', path, canonicalQueryString, canonicalHeaders, signedHeaders, payloadHash}, '\n');            
        String credScope = String.join(new List<String>{currentDateOnly, 'ap-south-1', 'sqs', 'aws4_request'}, '/');
        String canonicalHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(canonicalRequest)));
        String stringToSign = String.join(new List<String>{'AWS4-HMAC-SHA256', currentDate, credScope, canonicalHash}, '\n');
        System.debug(canonicalRequest+'>>>>>>>>>>>>>>-------------'+stringToSign);
        String kSecret = 'AWS4' + SECRET_KEY;
        Blob kDate = Crypto.generateMac(hashAlgo, Blob.valueOf(currentDateOnly), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac(hashAlgo, Blob.valueOf('ap-south-1'), kDate);
        Blob kService = Crypto.generateMac(hashAlgo, Blob.valueOf('sqs'), kRegion);
        Blob kSigning = Crypto.generateMac(hashAlgo, Blob.valueOf('aws4_request'), kService);
        String signature = EncodingUtil.convertToHex(Crypto.generateMac(hashAlgo, Blob.valueOf(stringToSign), kSigning));
        
        String authHeader = 'AWS4-HMAC-SHA256 ';
        authHeader += 'Credential=' + String.join(new List<String>{ACCESS_KEY, currentDateOnly, 'ap-south-1', 'sqs', 'aws4_request'}, '/') + ', ';
        authHeader += 'SignedHeaders=' + signedHeaders + ', ';
        authHeader += 'Signature=' + signature;       
        
        req.setEndPoint(endPointUrl);                    
        req.setHeader('x-amz-content-sha256', payloadHash);
        req.setHeader('x-amz-date', currentDate);
        req.setHeader('host', host);        
        req.setHeader('authorization', authHeader);             
        req.setMethod('GET');
        
        System.debug('req >>>>>>>>>>>>>>-------------'+req);
        //HttpResponse messageRes =  new Http().send(req);
       // System.debug('messageRes >>>>>>>>>>>>>>-------------'+messageRes.getBody());
        
        Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(messageRes.getBody());
                        
        String action = String.valueOf(jsonRootMap.get('action'));        
        String product = String.valueOf(jsonRootMap.get('product'));        
        String businessObj = String.valueOf(jsonRootMap.get('business_object'));        
        String producer = String.valueOf(jsonRootMap.get('producer'));  
        Map<String, Schema.SObjectType> globalDescribe;
        Map<String, Object> currentDataMap ;
        if(String.isNotBlank(action) && !'Salesforce'.equals(producer)){  
            
         globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
            
            if(jsonRootMap.containsKey('current_data')) currentDataMap = (Map<String, Object>)jsonRootMap.get('current_data');                       
                    
        }                     
        */
        Map<String, String> theReceiptHandleMap = New Map<String, String>();
        theReceiptHandleMap.put('AQEBZwOO8SQFHOU35dmkIlpT4YQ5M+zbldAmj7Puwv4m6IuHdbyzuOdHKuh5BpbHMgdbvWPxZdc7p/xSdOvPaC6zUglfSvZAIdpAxSYSHCPovc5WKLpp39Smybeo1ZHfKW5/feO8IVEy4ncAsXTuWikgF0kJikgwKl0atdCZTjio1j5g8siq+ia+muAMknZCh8GwhXJV0qybhZum4Lwy2D0Z1YICgcFw+IUM9vjDU73mnEhLLuH0oooqkHCYYhnZ/kgLZqMyzJSksZHpqNJqGarTdnonA9Uiyot/E9CNg2wMGII=',null);
        deleteMessages(theReceiptHandleMap, 'DeleteMessageBatchSQS');
        
        return null;
    }
    
    public static void deleteMessages(Map<String, String> theReceiptHandleMap, String metaName){
        if(!theReceiptHandleMap.isEmpty()){
            
       // System.debug('messageRes >>>>>>>>>>>>>>-------------'+messageRes.getBody());
            Integer i = 1;
            Map<String, String> tempMap = new Map<String, String>();
            
            for(String each : theReceiptHandleMap.keySet()){
                String tempStr = 'DeleteMessageBatchRequestEntry.' + i + '.Id=msg'+ i + '&DeleteMessageBatchRequestEntry.' + i + '.ReceiptHandle=' + each;                            
                tempMap.put(String.valueOf(i), tempStr);
                i++;                
            }
            
            List<String> mapKeys = new List<String>(tempMap.keyset()); mapKeys.sort();
            List<String> mapValues = new List<String>();
            for(String each : mapKeys){ mapValues.add(tempMap.get(each)); }
            if(!Test.isRunningTest()){
                String hashAlgo = 'HmacSHA256';  
        String endPointUrl = 'https://sqs.ap-south-1.amazonaws.com/837630141694/prod-esb-saas-focus.fifo?Action=DeleteMessageBatch&{0}';                         
            List<String> paramValue = New List<String>{String.join(mapValues, '&')};
        Blob blobBody = null;
        String strBody = '';
        Sobject headParamSob = null;
        string body = '';
        String SECRET_KEY = 'GqiVBiYTRDrBRHzwjaNy840qw/AjZ7NXoiUSp+Kz';
        String ACCESS_KEY = 'AKIA4GBVFUT7FJAVP7CN';
            string theEndPoint = '';
            if(paramValue != null && !paramValue.isEmpty()){
                endPointUrl = String.format(endPointUrl, paramValue);
                if(blobBody != null) theEndPoint = endPointUrl;           
            }
        Url theUrl = new Url(endPointUrl);
        String host = theUrl.getHost();
        String path = theUrl.getPath();
        String canonicalQueryString = theUrl.getQuery();
        HttpRequest req = new HttpRequest();
        String headers = 'content-type:application/x-www-form-urlencoded';            
        String payloadHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', blobBody != null ? blobBody : (Blob.valueOf(String.isNotBlank(body) ? body : strBody))));               
        
        String currentDate = System.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
        String currentDateOnly = System.now().formatGMT('yyyyMMdd');                         
        Map<String, String> canonicalHeaderMap = new Map<String, String>{'host' => host, 'x-amz-date' => currentDate}; 
            canonicalHeaderMap.put('x-amz-content-sha256', payloadHash);
        
        if(String.isNotBlank(headers)){
            for(String each : headers.split(',')){                     
                String theParam = headParamSob == null ? each.subStringAfter(':') : String.valueOf(headParamSob.get(each.subStringAfter(':')));                     
                req.setHeader(each.subStringBefore(':'), theParam);                
                canonicalHeaderMap.put(each.subStringBefore(':'), theParam);                                                            
            }
        }
        
        List<String> signedHeaderList = new List<String>(canonicalHeaderMap.keySet());   
        
        signedHeaderList.sort();
        
        String signedHeaders = String.join(signedHeaderList, ';');   
        
        List<String> canonicalHeaderList = new List<String>();  
        
        for(String eachStr : signedHeaderList){
            canonicalHeaderList.add(eachStr + ':' + canonicalHeaderMap.get(eachStr));
        }   
        
        String canonicalHeaders = String.join(canonicalHeaderList, '\n') +  '\n';                               
        
        String canonicalRequest = String.join(new List<String>{'GET', path, canonicalQueryString, canonicalHeaders, signedHeaders, payloadHash}, '\n');            
        String credScope = String.join(new List<String>{currentDateOnly, 'ap-south-1', 'sqs', 'aws4_request'}, '/');
        String canonicalHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(canonicalRequest)));
        String stringToSign = String.join(new List<String>{'AWS4-HMAC-SHA256', currentDate, credScope, canonicalHash}, '\n');
        System.debug(canonicalRequest+'>>>>>>>>>>>>>>-------------'+stringToSign);
        String kSecret = 'AWS4' + SECRET_KEY;
        Blob kDate = Crypto.generateMac(hashAlgo, Blob.valueOf(currentDateOnly), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac(hashAlgo, Blob.valueOf('ap-south-1'), kDate);
        Blob kService = Crypto.generateMac(hashAlgo, Blob.valueOf('sqs'), kRegion);
        Blob kSigning = Crypto.generateMac(hashAlgo, Blob.valueOf('aws4_request'), kService);
        String signature = EncodingUtil.convertToHex(Crypto.generateMac(hashAlgo, Blob.valueOf(stringToSign), kSigning));
        
        String authHeader = 'AWS4-HMAC-SHA256 ';
        authHeader += 'Credential=' + String.join(new List<String>{ACCESS_KEY, currentDateOnly, 'ap-south-1', 'sqs', 'aws4_request'}, '/') + ', ';
        authHeader += 'SignedHeaders=' + signedHeaders + ', ';
        authHeader += 'Signature=' + signature;       
        
        req.setEndPoint(endPointUrl);                    
        req.setHeader('x-amz-content-sha256', payloadHash);
        req.setHeader('x-amz-date', currentDate);
        req.setHeader('host', host);        
        req.setHeader('authorization', authHeader);             
        req.setMethod('GET');
        
        System.debug('req >>>>>>>>>>>>>>-------------'+req);
        HttpResponse deleteRes =  new Http().send(req);
                //HttpResponse deleteRes = AWSUtility.getAWSData(metaName, new List<String>{String.join(mapValues, '&')}, null, '', null);
                System.debug(deleteRes.getStatusCode() + '>>>>>>>>>>_______IN FINISH______>>>>>>>>>>>___________'+ deleteRes.getBody());
            }
        }
    }
}