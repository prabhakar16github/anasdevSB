public with sharing class AWSConsumerBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.stateful{
    
    //public List<Map<String, String>> receiptHandleList = new List<Map<String, String>>();
    public Map<String, String> receiptHandleMap = new Map<String, String>();
    public Set<String> leadIdSet = new Set<String>();
    public Set<String> bankAccountIdSet = new Set<String>(); 
    public Set<String> bankAccountIdSetUpdate = new Set<String>();
    public Set<String> addressIdSetUpdate = new Set<String>();    
    public static Boolean isFinishExecuted = false;
    public List<String> contractAccIds = new List<String>();
    public Set<string> websiteURLoppIds = new Set<String>();
    public Set<String> contractIds = new Set<String>();
    public Map<Id,Contract> triggerOldMap = new Map<Id,Contract>();
    public Set<String> merchantDocAccIds = new Set<string>();
    public set<string> setproducername = new set<string>();
    public Set<string> updatedWebsiteURLoppIds = new Set<String>();
    public Set<string> updatedWebsiteDetailsIds = new Set<String>();
    public Set<String> updWebsiteAddendumOppId = new Set<String>();
    
    public static Boolean consumerFlag = isBatchEnabled();
    
    public static Boolean isBatchEnabled() {
        List<Publisher_Flag_for_Payload__mdt> listConsumerFlags = [SELECT Prevent_AwsConsumer_Batch__c  FROM Publisher_Flag_for_Payload__mdt WHERE Label = 'Prevent AwsConsumer Batch'];
        
        if(listConsumerFlags != NULL && listConsumerFlags.size() > 0) {
            if(listConsumerFlags[0].Prevent_AwsConsumer_Batch__c) return true;
            else return false; 
        }
        else return true;
    }
    
    public Iterable<String> start(Database.BatchableContext BC){
        return new List<String> {'1'};
            }
    
    public void execute(Database.BatchableContext info, List<String> strings){
        if(!consumerFlag){
            HttpResponse messageRes = AWSUtility.getAWSData('GetMessageSQS', null, null, '', null); 
            System.debug(messageRes.getStatusCode() + '>>>>>>>>>>_____________>>>>>>>>>>>___________'+ messageRes.getBody());
            
            if(messageRes != null && messageRes.getStatusCode() == 200){                
                parseXML(messageRes.getBody());
            }    
        }                   
    }
    
    public void finish(Database.BatchableContext info){
        isFinishExecuted = true;
        System.debug('>>>>>>>>>>_______IN FINISH______>>>>>>>>>>>___________');
        
        processDeleteList('DeleteMessageBatchSQS');                
        System.debug('leadIdSet>>>>>>>>>>_______IN FINISH______>>>>>>>>>>>___________ '+leadIdSet);
        if(!leadIdSet.isEmpty()){
            List<String> oppIds = new List<String>();
            List<String> accIds = new List<String>();
            
            for(Lead each : Database.query('SELECT Id, IsConverted, Penny_Verification_Required__c,ConvertedAccountId, ConvertedOpportunityId FROM Lead WHERE Id IN (\'' + String.join(new List<String>(leadIdSet), '\',\'') + '\')')){
                
                if(each.isConverted){
                    if(String.isNotBlank(each.ConvertedOpportunityId)) oppIds.add(each.ConvertedOpportunityId);                   
                    
                    if(String.isNotBlank(each.ConvertedAccountId)) accIds.add(each.ConvertedAccountId);                    
                }
                
            }
            
            if(!accIds.isEmpty()){
                for(Account each : Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Account')), ',') + ' FROM Account WHERE Id IN (\'' + String.join(new List<String>(accIds), '\',\'') + '\')')){                    
                    IntegrationUtility.sendPayLoadData(each, null, 'Account', 'Account');                    
                }
            }
            //Inside If added some logic for nb eligible by Rohit Gupta
            if(!oppIds.isEmpty()){
                String s ='SELECT ' + String.join(new List<String>(getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\')'; 
                System.debug('s::::::::::'+s);
                for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\')')){                    
                    SYstem.debug('each:::::123::'+each);
                    IntegrationUtility.oppConvertedSet.add(each.Id);
                    SYstem.debug(' OppId::'+each.Id+' each.nbEligible::::'+each.NB_Eligible__c +' each:partnerSou::'+each.Partner_Source__c);
                    if(each.NB_Eligible__c==True && each.Partner_Source__c=='Bulk Referral' ){
                        System.debug('each.id::Inside If::'+each.Id );
                        IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Opportunity');   
                    }
                    else{
                        each.NB_Eligible__c = true;
                        each.Partner_Source__c = 'Bulk Referral';
                        System.debug('inside Else::::'+each.NB_Eligible__c);
                        System.debug('Insdie Else Opp Id:::'+each.id);
                        
                        System.debug('Inside Else :: each.Partner_Source__c:::::'+ each.Partner_Source__c);
                        IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Opportunity'); 
                    }
                    
                }
            }
            
            if(!IntegrationUtility.logList.isEmpty()) Database.insert(IntegrationUtility.logList, false);
        }
        
        if(!websiteURLoppIds.isEmpty()){
            string sObjectName = 'Opportunity';
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(websiteURLoppIds,sObjectName,setproducerName);
            Database.executeBatch(oppPublisherBatch);
        }
        //=============Commenting due to onboarding Revamp as no need to send the account status=========
        /*
if(!merchantDocAccIds.isEmpty()){
string accountSObjectName = 'Account';
PublishExistingOppotunityWebsiteBatch accountPublisherBatch = new PublishExistingOppotunityWebsiteBatch(merchantDocAccIds,accountSObjectName,setproducerName);
Database.executeBatch(accountPublisherBatch);
}
*/
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
        
        //==============Update Opportunity After Website Change Addendum is accepted===
        if(!updWebsiteAddendumOppId.isEmpty()){
            string sObjectName = 'WebsiteAddendumOpportunity';
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(updWebsiteAddendumOppId,sObjectName,setproducerName);
            Database.executeBatch(oppPublisherBatch);
        }
        
        //=============Commenting due to onboarding Revamp as no need to send the account status=========
        // ============ Send agreement change account payload==============
        /*if(!contractIds.isEmpty()){
string sObjectName = 'Contract';
PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(contractIds,sObjectName,setproducerName);
Database.executeBatch(oppPublisherBatch);
}*/
        
        //================== Used to send the Website Details payload, if website is OK================
        if(!updatedWebsiteDetailsIds.isEmpty() && updatedWebsiteDetailsIds.size() > 0){
            string sObjectName = 'Website_Details__c';
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(updatedWebsiteDetailsIds,sObjectName,setproducerName);
            Database.executeBatch(oppPublisherBatch);
        }
        
        if(!bankAccountIdSet.isEmpty()) BankDetailTriggerHandler.afterInsertHandler(Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Detail__c WHERE Id IN (\'' + String.join(new List<String>(bankAccountIdSet), '\',\'') + '\')'));        
        //if(!bankAccountIdSetUpdate.isEmpty()) BankDetailTriggerHandler.updateagreementinOnlineCaseWithnewURL(bankAccountIdSetUpdate);
        if(!addressIdSetUpdate.isEmpty()) System.enqueueJob(new generateAgreementFromAddressUpdate(addressIdSetUpdate));
        //if(!contractAccIds.isEmpty() && !contractIds.isEmpty()) ContractTriggerHandler.update_Status(contractIds, contractAccIds, triggerOldMap);
        /*
List<AsyncApexJob> lstFailedJobs = [SELECT CreatedDate, ExtendedStatus, Status
FROM AsyncApexJob 
WHERE ApexClass.Name = : 'PublishExistingOppotunityWebsiteBatch'
AND JobType = 'BatchApex'
AND (Status IN ('Holding', 'Queued','Preparing','Processing'))
Order by CreatedDate DESC Limit 1];*/
        
        Batch_Setting__mdt bsMDT = [Select Id,Record_Limit__c,Re_Run_Apex_Job__c,Where_Clause__c from Batch_Setting__mdt 
                                    where DeveloperName=:'AWSConsumerBatch' LIMIT 1];
        if(!Test.isRunningTest()) {
            if(bsMDT.Re_Run_Apex_Job__c) Database.executeBatch(new AWSConsumerBatch());
        }       
    }
    
    public void processDeleteList(String metaName){
        deleteMessages(receiptHandleMap, metaName);       
    }
    
    public void deleteMessages(Map<String, String> theReceiptHandleMap, String metaName){
        if(!theReceiptHandleMap.isEmpty()){
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
                HttpResponse deleteRes = AWSUtility.getAWSData(metaName, new List<String>{String.join(mapValues, '&')}, null, '', null);
                System.debug(deleteRes.getStatusCode() + '>>>>>>>>>>_______IN FINISH______>>>>>>>>>>>___________'+ deleteRes.getBody());
            }
        }
    }
    
    public void parseXML(String xml){
        List<Payload_Log__c> logList = new List<Payload_Log__c>();
        
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
                    
                    Payload_Log__c theLog = parseJSON(body);
                    theLog.Process__c = 'Salesforce Consumer';
                    theLog.Receipt_Handle__c = receiptHandle;
                    theLog.Payload__c = body;
                    
                    if('SUCCESS'.equals(theLog.Status__c)){                                                
                        if(String.isNotBlank(receiptHandle)){                        
                            receiptHandle = AWSUtility.encode(receiptHandle);
                            receiptHandleMap.put(receiptHandle, null);                                                    
                        }
                    } 
                    
                    logList.add(theLog);                 
                } 
            }
        } 
        
        if(!logList.isEmpty()) Database.insert(logList, false);                                       
    }        
    
    static Map<String, Schema.SObjectType> globalDescribe;
    static Map<String, String> midMap = new Map<String, String>{'mid' => 'Prod_Merchant_Id__c', 'test_mid' => 'Merchant_Id__c'};
        static Set<String> midObjs = new Set<String>{'Lead', 'Opportunity'};
            static Map<String, String> businessObjs = new Map<String, String>{'Lead' => 'Lead_Type__c'};
                static Map<String, Set<String>> sobFieldMap = new Map<String, Set<String>>();
    static Map<string, String> leadTypeMap = new Map<string, String>{'merchant_type' => 'Merchant_Type__c'};
        
        public static Set<String> getFieldSet(String sobType){
            SYstem.debug('sobType:::::::'+sobType);
            Set<String> setToReturn = new Set<String>();
            if(sobType !=null){
                
                if(sobFieldMap.containsKey(sobType)) setToReturn = sobFieldMap.get(sobType);        
                else{
                    Map<String, Schema.SObjectField> fieldMap;
                    globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;   
                    SYstem.debug('globalDescribe:::::::'+globalDescribe);
                    SYstem.debug('globalDescribe.get(sobType):::::::'+globalDescribe.get(sobType));
                    if(globalDescribe !=null && sobType !=null){
                        fieldMap = globalDescribe.get(sobType).getDescribe().fields.getMap();
                    }         
                    
                    
                    for(Schema.SObjectField each : fieldMap.Values()){
                        schema.describefieldresult dfield = each.getDescribe();
                        setToReturn.add(dfield.getName());
                    }            
                    sobFieldMap.put(sobType, setToReturn);
                }
            }
            
            
            return setToReturn;
        }    
    
    /** Commented for SFI-1229 */
    //static Map<String, String> actionMap = (Map<String, String>)JSON.deserialize(Label.ObjectActionMap, Map<String, String>.class);
    
    /** Added for change the object to action mapping from custom label to custom metadata.*/
    /** SFI-1229 */
    static Map<String, String> actionMap = getActionMapping();
    /** Private method to get the Sobject & payload action mapping from custom meta data. */
    private static Map<String,String> getActionMapping(){
        Map<String,String> sobjectToActionMap = new Map<String,String>();
        for(Sobject_to_payload_action_mapping__mdt mapping : [SELECT Id,DeveloperName,Mapping_JSON__c
                                                              FROM Sobject_to_payload_action_mapping__mdt 
                                                              WHERE DeveloperName = 'Object_Action_Map'
                                                              LIMIT 1]){
                                                                  if(String.isNotBlank(mapping.Mapping_JSON__c)){
                                                                      sobjectToActionMap = (Map<String,String>)JSON.deserialize(mapping.Mapping_JSON__c,Map<String,String>.class);
                                                                  }
                                                              }
        return sobjectToActionMap;
    }/** END */
    /** END SFI-1229 */
    
    public Payload_Log__c parseJSON(String jsonStr){ 
        Payload_Log__c theLog = new Payload_Log__c();
        String theSobjectrForTesting;
        
        Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        
        String action = String.valueOf(jsonRootMap.get('action'));        
        String product = String.valueOf(jsonRootMap.get('product'));        
        String businessObj = String.valueOf(jsonRootMap.get('business_object'));        
        String producer = String.valueOf(jsonRootMap.get('producer'));
        Integer mid ;
        if(jsonRootMap.containsKey('mid')) mid = Integer.valueOf(jsonRootMap.get('mid'));
        theLog.Producer__c = producer;
        theLog.Business_Object__c = businessObj;  
        theLog.Action__c = action;  
        
        if(String.isNotBlank(action) && !'Salesforce'.equals(producer)){  
            setproducerName.add(producer);
            globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
            List<PayloadActMap__mdt> payloadActList = IntegrationUtility.getPayLoadMap(action, '', businessObj);    
            
            
            if(!payloadActList.isEmpty()){   
                
                PayloadActMap__mdt thePayLoadMap = payloadActList[0];                                                                 
                try{                    
                    Map<String, String> jsonFieldMap;
                    if(String.isNotBlank(thePayLoadMap.JsonMap__c)) jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMap__c, Map<String, String>.class);
                    
                    Map<String, String> jsonFieldPubMap;
                    if(String.isNotBlank(thePayLoadMap.JSONMapPub__c)) jsonFieldPubMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSONMapPub__c, Map<String, String>.class);
                    
                    Map<String, String> jsonMap;
                    if(String.isNotBlank(thePayLoadMap.JSONfieldMap__c)) jsonMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSONfieldMap__c, Map<String, String>.class);
                    
                    Map<String, String> lookUpNodeMap;
                    if(String.isNotBlank(thePayLoadMap.LookUpField__c)) lookUpNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.LookUpField__c, Map<String, String>.class);                    
                    
                    Map<String, String> complexNodeMap;
                    if(String.isNotBlank(thePayLoadMap.JsonMapComp__c)) complexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMapComp__c, Map<String, String>.class);                    
                    
                    Map<String, Object> secCondMap;
                    if(String.isNotBlank(thePayLoadMap.SecondaryCond__c) && String.isNotBlank(thePayLoadMap.SecondaryObject__c)) secCondMap = (Map<String, Object>)JSON.deserializeUntyped(thePayLoadMap.SecondaryCond__c);                    
                    
                    Map<String, Object> subComplexNodeMap;
                    if(String.isNotBlank(thePayLoadMap.JSON_Map_sub_key_complex__c)) subComplexNodeMap = (Map<String, Object>)JSON.deserializeUntyped(thePayLoadMap.JSON_Map_sub_key_complex__c );                    
                    
                    //Map<String, ObjectActionMap__c> CSObjectActionMap = ObjectActionMap__c.getAll();
                    
                    Map<String, Object> currentDataMap;
                    Map<String, Object> oldDataMap;
                    
                    if(jsonRootMap.containsKey('current_data')) currentDataMap = (Map<String, Object>)jsonRootMap.get('current_data');                       
                    
                    if(jsonRootMap.containsKey('old_data')) oldDataMap = (Map<String, Object>)jsonRootMap.get('old_data');                    
                    
                    Sobject sobToUpsert;
                    String theSobject = thePayLoadMap.Sobject__c;
                    System.debug('theSobject::::::'+theSobject);
                    theSobjectrForTesting =  theSobject;
                    Set<String> theFields = getFieldSet(theSobject);                    
                    sobToUpsert = globalDescribe.get(theSobject).newSObject();
                    
                    Sobject oldSobToUpsert;                   
                    oldSobToUpsert = globalDescribe.get(theSobject).newSObject();
                    //sobToUpsertTesting = (String)sobToUpsert.get('Status');  // added by rohit
                    //OldsobToUpsertTesting = (String)oldSobToUpsert.get('Status');  // added by rohit
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
                            theLog.Payload_ID__c = String.valueOf(currentDataMap.get('uuid'));                            
                            String queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Identifier__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                            List<SObject> getIdList = Database.query(queryStr);
                            
                            Boolean queryOpp = false;                                                        
                            
                            if(!getIdList.isEmpty()){
                                if(theSobject == 'Lead' && getIdList[0].get('IsConverted') == true){ queryOpp = true; }
                                else{ sobToUpsert = getIdList[0]; }                               
                            }
                            
                            if(theSobject == 'Lead' && String.isNotBlank(thePayLoadMap.SecondaryObject__c) && (getIdList.isEmpty() || queryOpp)){
                                
                                String queryStrOpp = 'SELECT '+  String.join(new List<String>(getFieldSet(thePayLoadMap.SecondaryObject__c)), ',') + ' FROM ' + thePayLoadMap.SecondaryObject__c + ' WHERE Identifier__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                List<Sobject> getIdListOpp = Database.query(queryStrOpp);
                                
                                if(!getIdListOpp.isEmpty()){ 
                                    theSobject = thePayLoadMap.SecondaryObject__c; 
                                    theFields = getFieldSet(theSobject);                                                                      
                                    sobToUpsert = getIdListOpp[0];                                                                                                                                       
                                }
                            }
                            
                            if(String.isNotBlank(thePayLoadMap.Delete_Action__c) && thePayLoadMap.Delete_Action__c == action && sobToUpsert.get('Id') != null){
                                system.debug('######### deleted sobject '+theSobject);  
                                //=============Commenting due to onboarding Revamp as no need to send the account status=========
                                /*if(theSobject == 'Merchant_Document__c' && sobToUpsert.get('Account__c') != null){
merchantDocAccIds.add(string.valueOf(sobToUpsert.get('Account__c')));
}*/
                                
                                delete sobToUpsert; theLog.Status__c = 'SUCCESS'; return theLog;
                            }
                        }
                        if(currentDataMap.containsKey('product_uuid') && !currentDataMap.containsKey('uuid')
                           && mid != null && string.isNotBlank(product) && product=='PayUbiz'){
                               theLog.Payload_ID__c = string.valueOf(mid); 
                               system.debug('###### else if mid '+mid);
                               system.debug('###### else if product '+product);
                               String queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Prod_Merchant_Id__c = ' + mid + '  AND ProductLabel__c = \'' +product+ '\'  ORDER BY CreatedDate ASC LIMIT 1';
                               List<SObject> getIdList = Database.query(queryStr);
                               
                               Boolean queryOpp = false;                                                        
                               
                               if(!getIdList.isEmpty()){
                                   if(theSobject == 'Lead' && getIdList[0].get('IsConverted') == true){ queryOpp = true; }
                                   else{ sobToUpsert = getIdList[0]; }                               
                               }
                               
                               if(theSobject == 'Lead' && String.isNotBlank(thePayLoadMap.SecondaryObject__c) && (getIdList.isEmpty() || queryOpp)){
                                   
                                   String queryStrOpp = 'SELECT '+  String.join(new List<String>(getFieldSet(thePayLoadMap.SecondaryObject__c)), ',') + ' FROM ' + thePayLoadMap.SecondaryObject__c + ' WHERE Prod_Merchant_Id__c = ' + mid + ' AND ProductLabel__c = \'' +product+ '\'  ORDER BY CreatedDate ASC LIMIT 1';
                                   List<Sobject> getIdListOpp = Database.query(queryStrOpp);
                                   
                                   if(!getIdListOpp.isEmpty()){ 
                                       theSobject = thePayLoadMap.SecondaryObject__c; 
                                       theFields = getFieldSet(theSobject);                                                                      
                                       sobToUpsert = getIdListOpp[0];                                                                                                                                       
                                   }
                               }
                               
                               if(action == 'update_bank_detail' && businessObj == 'Merchant'){
                                   String queryStrBankOpp = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Active__c = true AND Opportunity__r.Prod_Merchant_Id__c = ' + mid + '  AND ProductLabel__c = \'' +product+ '\'  ORDER BY CreatedDate ASC LIMIT 1';
                                   List<SObject> getIdListBankOpp = Database.query(queryStrBankOpp);
                                   if(!getIdListBankOpp.isEmpty()){                                                                      
                                       sobToUpsert = getIdListBankOpp[0];                                                                                                                                       
                                   }
                                   else{
                                       String queryStrBankLead = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Active__c = true AND Lead__r.Prod_Merchant_Id__c = ' + mid + '  AND ProductLabel__c = \'' +product+ '\'  ORDER BY CreatedDate ASC LIMIT 1';
                                       List<SObject> getIdListBankLead = Database.query(queryStrBankLead);
                                       if(!getIdListBankLead.isEmpty()){                                                                      
                                           sobToUpsert = getIdListBankLead[0];                                                                                                                                       
                                       }
                                   }
                               }
                               if(String.isNotBlank(thePayLoadMap.Delete_Action__c) && thePayLoadMap.Delete_Action__c == action && sobToUpsert.get('Id') != null){
                                   delete sobToUpsert; theLog.Status__c = 'SUCCESS'; return theLog;
                               }
                           }
                        if(currentDataMap.containsKey('product_name') && !currentDataMap.containsKey('uuid')
                           && mid != null && string.isNotBlank(product) && (action == 'update_product' || action == 'create_product') 
                           && businessObj == 'Merchant'){
                               theLog.Payload_ID__c = string.valueOf(mid);
                               String queryStrCrossSellOpp = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Active__c = true AND Opportunity__r.Prod_Merchant_Id__c = ' + mid + ' AND ProductLabel__c = \'' +product+ '\'  AND Custom_Product__r.Name = \''+ currentDataMap.get('product_name') +'\'  ORDER BY CreatedDate ASC LIMIT 1';
                               List<SObject> getIdListCrossSellOpp = Database.query(queryStrCrossSellOpp);
                               if(!getIdListCrossSellOpp.isEmpty()){                                                                      
                                   sobToUpsert = getIdListCrossSellOpp[0];                                                                                                                                       
                               }
                           }
                        
                        List<String> theReadOnlySet = String.isBlank(thePayLoadMap.ReadOnly__c) ? null : thePayLoadMap.ReadOnly__c.split(',');
                        for(String each : currentDataMap.keySet()){                        
                            if(sobToUpsert != null){
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
                                                populateField(sobToUpsert, lookUpNodeMap, eachCompStr, complexDataMap.get(eachCompStr), complexKeyFieldMap.get(eachCompStr), theReadOnlySet, theFields);                                 
                                            } 
                                        } 
                                    }                  
                                }else{
                                    
                                    if(jsonFieldMap != null && jsonFieldMap.containsKey(each)){
                                        for(String eachJsonStr : jsonFieldMap.get(each).split(';')){
                                            system.debug('%%%%%%%% '+currentDataMap.get(each));
                                            system.debug('%%%%%%%% sobToUpsert '+sobToUpsert);
                                            //if(!currentDataMap.containsKey('config'))
                                            populateField(sobToUpsert, lookUpNodeMap, each, currentDataMap.get(each), eachJsonStr, theReadOnlySet, theFields); 
                                        }                               
                                    }
                                    if(lookUpNodeMap != null && lookUpNodeMap.containsKey(each)){                                    
                                        if(jsonFieldPubMap == null || (jsonFieldPubMap != null && (!jsonFieldPubMap.containsKey(each)) || (jsonFieldPubMap.containsKey(each) && actionMap.containsKey(theSobject) && action == actionMap.get(theSobject).split(',')[0]))){                                        
                                            populateField(sobToUpsert, lookUpNodeMap, each, currentDataMap.get(each), lookUpNodeMap.get(each), theReadOnlySet, theFields);   
                                        }else if(jsonFieldPubMap != null && jsonFieldPubMap.containsKey(each) && actionMap.containsKey(theSobject) && action == actionMap.get(theSobject).split(',')[1]){                                        
                                            String formulaFieldValue = jsonFieldPubMap.get(each);
                                            if(String.isNotBlank(formulaFieldValue) && theFields.contains(formulaFieldValue.subStringBefore(',')) && sobToUpsert.get(formulaFieldValue.subStringBefore(',')) != currentDataMap.get(each)){
                                                populateField(sobToUpsert, lookUpNodeMap, each, currentDataMap.get(each), lookUpNodeMap.get(each), theReadOnlySet, theFields);  
                                            } 
                                        }                             
                                    }
                                    if(jsonMap != null && jsonMap.containsKey(each)){
                                        system.debug('each --> '+each);
                                        for(String eachJsonStr : jsonMap.get(each).split(';')){
                                            //if(! payloadActList[0].JSONfieldMap__c.contains(each)){
                                            populateField(sobToUpsert, lookUpNodeMap, each, getJsonStr(currentDataMap.get(each)), eachJsonStr, theReadOnlySet, theFields); 
                                            //}
                                        }
                                    }
                                    if(subComplexNodeMap != null && subComplexNodeMap.containsKey(each)){
                                        Object theSubCompNode = currentDataMap.get(each);
                                        if(theSubCompNode != null){
                                            Map<String, String> complexKeyFieldMap = new Map<String, String>();
                                            object metaObject = subComplexNodeMap.get(each);
                                            
                                            String allFields = JSON.serializePretty(metaObject).remove('"');
                                            String finalAllFields = allFields.remove(' ');
                                            
                                            if(String.isNotBlank(finalAllFields)){
                                                for(String eachStr : finalAllFields.split(';')){
                                                    complexKeyFieldMap.put(eachStr.subStringBefore('-'), eachStr.subStringAfter('-'));
                                                }
                                                
                                            }
                                            
                                            if(currentDataMap.containsKey('name') && currentDataMap.get('name') == 'onboarding_config'){
                                                
                                                if(currentDataMap.containsKey(each) == subComplexNodeMap.containsKey(each)){
                                                    Map<String, Object> subComplexDataMap = (Map<String, Object>)theSubCompNode;
                                                    string firstparam = complexKeyFieldMap.get('onboarding_config').subStringBefore('__');
                                                    object bankDetailObj = subComplexDataMap.get(firstparam);
                                                    
                                                    Map<String,Object> configChildObjMap = (Map<String,Object>)bankDetailObj;
                                                    
                                                    string secondParam_1 = complexKeyFieldMap.get('onboarding_config').subStringAfter('__');
                                                    string secondParam_2 = secondParam_1.subStringBefore(':');
                                                    
                                                    String fieldAPI_1 = complexKeyFieldMap.get('onboarding_config').subStringAfter(':');
                                                    populateField(sobToUpsert, lookUpNodeMap, each, configChildObjMap.get(secondParam_2), fieldAPI_1, theReadOnlySet, theFields);
                                                }
                                            } else if(currentDataMap.containsKey('name') && currentDataMap.get('name') == 'login_config'){
                                                if(currentDataMap.containsKey(each) == subComplexNodeMap.containsKey(each)){
                                                    Map<String, Object> subComplexDataMap = (Map<String, Object>)theSubCompNode;
                                                    
                                                    if(subComplexDataMap != null){
                                                        string param = complexKeyFieldMap.get('login_config').subStringBefore(':');
                                                        String fieldAPI = complexKeyFieldMap.get('login_config').subStringAfter(':');
                                                        populateField(sobToUpsert, lookUpNodeMap, each, subComplexDataMap.get(param), fieldAPI, theReadOnlySet, theFields);
                                                    }
                                                }
                                            } else if(currentDataMap.containsKey('name') && currentDataMap.get('name') == 'bank_detail_config'){
                                                if(currentDataMap.containsKey(each) == subComplexNodeMap.containsKey(each)){
                                                    Map<String, Object> subComplexDataMap = (Map<String, Object>)theSubCompNode;
                                                    if(subComplexDataMap != null){
                                                        string param = complexKeyFieldMap.get('bank_detail_config').subStringBefore(':');
                                                        String fieldAPI = complexKeyFieldMap.get('bank_detail_config').subStringAfter(':');
                                                        populateField(sobToUpsert, lookUpNodeMap, each, subComplexDataMap.get(param), fieldAPI, theReadOnlySet, theFields);
                                                    }
                                                }
                                            }   
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if(oldDataMap != null && !oldDataMap.isEmpty() && businessObj =='Merchant' && action == 'update' && producer == 'MerchantOnboarding' && (complexNodeMap != null && !complexNodeMap.isEmpty() || jsonFieldMap != null && !jsonFieldMap.isEmpty())){ 
                        if(oldDataMap.containsKey('uuid')){                           
                            String queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Identifier__c = \'' + oldDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                            List<SObject> getIdList = Database.query(queryStr);
                            
                            Boolean queryOpp = false;                                                        
                            
                            if(!getIdList.isEmpty()){
                                if(theSobject == 'Lead' && getIdList[0].get('IsConverted') == true){ queryOpp = true; }
                                else{ oldSobToUpsert = getIdList[0]; }                               
                            }
                            
                            if(theSobject == 'Lead' && String.isNotBlank(thePayLoadMap.SecondaryObject__c) && (getIdList.isEmpty() || queryOpp)){
                                
                                String queryStrOpp = 'SELECT '+  String.join(new List<String>(getFieldSet(thePayLoadMap.SecondaryObject__c)), ',') + ' FROM ' + thePayLoadMap.SecondaryObject__c + ' WHERE Identifier__c = \'' + oldDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                List<Sobject> getIdListOpp = Database.query(queryStrOpp);
                                
                                if(!getIdListOpp.isEmpty()){ 
                                    theSobject = thePayLoadMap.SecondaryObject__c; 
                                    theFields = getFieldSet(theSobject);                                                                      
                                    oldSobToUpsert = getIdListOpp[0];                                                                                                                                       
                                }
                            }
                            
                            List<String> theReadOnlySet = String.isBlank(thePayLoadMap.ReadOnly__c) ? null : thePayLoadMap.ReadOnly__c.split(',');
                            for(String each : oldDataMap.keySet()){                        
                                if(oldSobToUpsert != null){
                                    if(complexNodeMap != null && complexNodeMap.containsKey(each)){                                        
                                        Object theCompNode = oldDataMap.get(each);
                                        
                                        if(theCompNode != null){
                                            Map<String, Object> complexDataMap = (Map<String, Object>)theCompNode;
                                            Map<String, String> complexKeyFieldMap = new Map<String, String>();
                                            
                                            for(String eachStr : complexNodeMap.get(each).split(';')){
                                                complexKeyFieldMap.put(eachStr.subStringBefore(':'), eachStr.subStringAfter(':'));
                                            }
                                            
                                            if(!complexKeyFieldMap.isEmpty()){
                                                for(String eachCompStr : complexDataMap.keySet()){  
                                                    populateField(oldSobToUpsert, lookUpNodeMap, eachCompStr, complexDataMap.get(eachCompStr), complexKeyFieldMap.get(eachCompStr), theReadOnlySet, theFields);                                 
                                                } 
                                            } 
                                        }                  
                                    }
                                }
                            }
                        }
                    }
                    
                    Boolean checkLeadType = false;                
                    if(midObjs.contains(theSobject)){
                        for(String each : jsonRootMap.keySet()){
                            if(midMap.containsKey(each)){
                                sobToUpsert.put(midMap.get(each), jsonRootMap.get(each));
                                break;
                            }
                            if(leadTypeMap.containsKey(each)){
                                system.debug('########## jsonroot '+jsonRootMap.get(each));
                                sobToUpsert.put(leadTypeMap.get(each), jsonRootMap.get(each));
                                checkLeadType = true;
                                break;
                            }
                        }
                    }
                    
                    //if(businessObjs.containsKey(theSobject)) sobToUpsert.put(businessObjs.get(theSobject), businessObj);                    
                    if(businessObjs.containsKey(theSobject) && checkLeadType==false){ 
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
                    
                    //========= Adding Business Entity check for Onboarding Revamp-JIRA-SFPI-997============
                    if(theSobject == 'Lead' && businessObj != 'Partner' && String.valueOf(sobToUpsert.get('Business_Entity__c')) != null && String.valueOf(sobToUpsert.get('PAN_Holder_Name__c')) != null && String.valueOf(sobToUpsert.get('PAN_Number__c')) != null) 
                        leadIdSet.add(String.valueOf(sobToUpsert.get('Id')));
                    
                    //=============Commenting due to onboarding Revamp as no need to send the account status=========
                    /*if(theSobject == 'Contract' && (action == 'create_kyc_doc' || action == 'update_kyc_doc') && sobToUpsert.get('AccountId') != null 
&& sobToUpsert.get('URL__c') != null && sobToUpsert.get('Contract_Type__c') == 'Agreement'){
contractAccIds.add(string.valueOf(sobToUpsert.get('AccountId')));
contractIds.add(string.valueOf(sobToUpsert.get('Id')));
} */
                    
                    // update opportunity on addendum approval
                    if(theSobject == 'Contract' && (action == 'update_kyc_doc') && sobToUpsert.get('AccountId') != null 
                       && sobToUpsert.get('URL__c') != null && sobToUpsert.get('Contract_Type__c') == 'Addendum' 
                       && sobToUpsert.get('Status') == 'Approved'
                       /*&& oldSobToUpsert.get('Status') != null*/
                       /*&& sobToUpsert.get('Status') != oldSobToUpsert.get('Status')*/){
                           updWebsiteAddendumOppId.add(string.valueOf(sobToUpsert.get('Opportunity__c')));
                       }
                    
                    if(theSobject == 'Opportunity' && action == 'update' && Producer!= 'PayUmoney' 
                       && (sobToUpsert.get('Website_Status__c') == 'Pending' || sobToUpsert.get('Website_Status__c')=='Verification in Process')
                       && (sobToUpsert.get('Website__c') != null || sobToUpsert.get('IOS_URL__c') != null || sobToUpsert.get('Android_URL__c') != null)
                       && sobToUpsert.get('Integration_Type__c')=='Thirdparty'){
                           
                           websiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                       }
                    
                    //============updated for onboarding Revamp -JIRA-SFPI-1157=================
                    if(theSobject == 'Merchant_Status_Details__c' && action == 'update_merchant_account_status' && Producer == 'MerchantOnboarding' 
                       && sobToUpsert.get('Opportunity__c') != null && sobToUpsert.get('Status_Value__c') != null &&
                       sobToUpsert.get('Status_Type__c') != null && sobToUpsert.get('Status_Value__c') == 'Approved' && sobToUpsert.get('Status_Type__c') == 'Agreement'){
                           
                           websiteURLoppIds.add(string.valueOf(sobToUpsert.get('Opportunity__c')));
                       }
                    if(theSobject == 'Merchant_Status_Details__c' && action == 'update_merchant_account_status' && Producer == 'MerchantOnboarding' 
                       && sobToUpsert.get('Opportunity__c') != null && sobToUpsert.get('Status_Value__c') != null &&
                       sobToUpsert.get('Status_Type__c') != null && sobToUpsert.get('Status_Value__c') == 'Docs Approved' && sobToUpsert.get('Status_Type__c') == 'KYC_DOCUMENTS'){
                           
                           websiteURLoppIds.add(string.valueOf(sobToUpsert.get('Opportunity__c')));
                       }
                    
                    //=============Commenting due to onboarding Revamp as no need to send the account status=========
                    /*if(theSobject == 'Merchant_Document__c' && ((sobToUpsert.get('Account__c') != null 
&& sobToUpsert.get('URL__c') != null && sobToUpsert.get('KYC_Documentable_Type__c') =='Account') || 
action=='delete_kyc_doc')){
merchantDocAccIds.add(string.valueOf(sobToUpsert.get('Account__c')));
}*/
                    
                    if(theSobject == 'Opportunity' && action == 'update' && Producer == 'PayUmoney' &&
                       (sobToUpsert.get('Settlement_Status__c')=='Thirdparty Hold' || sobToUpsert.get('Settlement_Status__c')==null)
                       && businessObj=='Merchant' && string.isNotBlank(product) && product=='PayUmoney'){
                           websiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                       }
                    
                    if(theSobject == 'Opportunity' && action == 'update' && Producer == 'MerchantOnboarding' 
                       && (sobToUpsert.get('Website_Status__c') == 'Pending' || sobToUpsert.get('Website_Status__c')=='Verification in Process')
                       && (sobToUpsert.get('Website__c') != null || sobToUpsert.get('IOS_URL__c') != null || sobToUpsert.get('Android_URL__c') != null)
                       && sobToUpsert.get('Integration_Type__c') == 'Thirdparty' 
                       && ((oldSobToUpsert.get('Website__c') != null && sobToUpsert.get('Website__c') != null && sobToUpsert.get('Website__c') != oldSobToUpsert.get('Website__c')) || (oldSobToUpsert.get('IOS_URL__c') != null && sobToUpsert.get('IOS_URL__c') != null && sobToUpsert.get('IOS_URL__c') != oldSobToUpsert.get('IOS_URL__c')) || (oldSobToUpsert.get('Android_URL__c') != null && sobToUpsert.get('Android_URL__c') != null && sobToUpsert.get('Android_URL__c') != oldSobToUpsert.get('Android_URL__c')))){
                           
                           updatedWebsiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                       }
                    
                    //===========Onboarding Revamp Changes================
                    if(theSobject == 'Website_Details__c' && action == 'update_website_detail' && Producer == 'MerchantOnboarding' && sobToUpsert.get('Website_Status__c') == 'Verification in Process' && sobToUpsert.get('Active__c') == true
                       && (sobToUpsert.get('Website_URL__c') != null || sobToUpsert.get('IOS_URL__c') != null || sobToUpsert.get('Android_URL__c') != null)){
                           updatedWebsiteDetailsIds.add(string.valueOf(sobToUpsert.get('Id')));
                       }
                    system.debug('######## updatedWebsiteDetailsIds '+updatedWebsiteDetailsIds);
                    theLog.SalesforceRecordId__c = sobToUpsert.Id; theLog.Status__c = 'SUCCESS'; return theLog;
                    
                }catch(exception ex){ theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); theLog.Status__c = 'SUCCESS'; return theLog; }             
            }          
        }
        
        theLog.Status__c = 'ERROR'; return theLog;        
    }        
    
    public static void populateField(Sobject sobToUpsert, Map<String, String> lookUpNodeMap, String theNode, Object theData, String fieldAPI, List<String> theReadOnlySet, Set<String> fields){
        
        if(lookUpNodeMap != null && lookUpNodeMap.containsKey(theNode) && String.isNotBlank(lookUpNodeMap.get(theNode))){            
            for(String each : lookUpNodeMap.get(theNode).split(';')){
                String lookUpQueryStr = each.subStringAfter(',');
                String lookUpFieldAPI = each.subStringBefore(',');                
                if(String.isNotBlank(lookUpFieldAPI) && fields.contains(lookUpFieldAPI)){
                    String queryStr = 'SELECT Id FROM ' + lookUpQueryStr.subStringBefore(':') + ' WHERE ' + lookUpQueryStr.subStringAfter(':') + ' = \'' + theData + '\'';          
                    
                    List<Sobject> queriedList = Database.query(queryStr);
                    if(!queriedList.isEmpty()){
                        sobToUpsert.put(lookUpFieldAPI, queriedList[0].Id); 
                        system.debug('sobToUpsert=='+sobToUpsert);
                        break;                   
                    }
                }
            }
        }else{
            if(String.isNotBlank(fieldAPI)){
                String theAPI = fieldAPI.subStringBefore(',');
                String fieldType = fieldAPI.subStringAfter(',');
                system.debug('---->TheData1 --> '+theData+' ---fieldType1 '+fieldType+' --- theAPI1 '+theAPI);
                if(fields.contains(theAPI) || theAPI.equalsIgnoreCase('Penny_Verification_Required__c')){
                    system.debug('---->TheData2 --> '+theData+' ---fieldType2 '+fieldType+' --- theAPI2 '+theAPI);
                    if(theReadOnlySet == null || !theReadOnlySet.contains(theAPI)) sobToUpsert.put(theAPI, getformattedData(theData, fieldType));                                        
                }  
            }                                         
        }
    }
    
    //Added By Pooja
    public static Object getformattedData(Object theData, String dataType){
        System.debug('theData::::::'+theData);
        System.debug('dataType:::::::'+dataType);
        if(theData != null) {
            if('datetime'.equalsIgnoreCase(dataType)) {
                return Datetime.valueOf(String.valueOf(theData));
            } else if('string'.equalsIgnoreCase(dataType)) {
                return String.valueOf(theData);
            }
        }
        return theData;
    }
    //Ended By Pooja
    
    /*public static String getJsonStr(Object theJsonObj){
String theJsonValue = '';
if(theJsonObj != null){
Map<String, Object> tempMap = (Map<String, Object>)theJsonObj;
theJsonValue = JSON.serialize(tempMap);
}
return theJsonValue;
}*/
    
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
    }
    
    
}