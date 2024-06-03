/*
* Name of the class : AwsConsumerAPI_CTRL
* Author's Name     : Rohit Gupta  
* Created Date      : 17th Sep, 2022
* Description       : Consume and publish all the payload which has been send by lambda through CO team.
* Version.          : 1   
*/ 
@RestResource(urlMapping='/AwsConsumerApi/*')
global class AwsConsumerAPI_CTRL {
    public static boolean runningFromConsumerAPIForOfflineFlow = false;
    public static Map<String, String> receiptHandleMap = new Map<String, String>();
    public static Set<String> leadIdSet = new Set<String>();
    public static Set<String> bankAccountIdSet = new Set<String>(); 
    public static List<Payload_Log__c> logListPassToIntUtility = new List<Payload_Log__c>();// added by rohit
    public static Set<String> bankAccountIdSetUpdate = new Set<String>();
    public static Set<String> addressIdSetUpdate = new Set<String>();    
    public static Boolean isFinishExecuted = false;
    global static Boolean isFlagForMO= false;
    public List<String> contractAccIds = new List<String>();
    public static Set<string> websiteURLoppIds = new Set<String>();
    public Set<String> contractIds = new Set<String>();
    public Map<Id,Contract> triggerOldMap = new Map<Id,Contract>();
    public Set<String> merchantDocAccIds = new Set<string>();
    public static set<string> setproducername = new set<string>();
    public static Set<string> updatedWebsiteURLoppIds = new Set<String>();
    public static Set<string> updatedWebsiteDetailsIds = new Set<String>();
    public static Set<String> updWebsiteAddendumOppId = new Set<String>();
    static Map<String, Schema.SObjectType> globalDescribe;
    static Map<String, String> midMap = new Map<String, String>{'mid' => 'Prod_Merchant_Id__c', 'test_mid' => 'Merchant_Id__c','idenitifier' =>'MID_Text_Field__c'};
    static Set<String> midObjs = new Set<String>{'Lead', 'Opportunity'};
    static Map<String, String> businessObjs = new Map<String, String>{'Lead' => 'Lead_Type__c' , 'Opportunity' => 'Lead_Type__c'};
    static Map<String, Set<String>> sobFieldMap = new Map<String, Set<String>>();
    static Map<string, String> leadTypeMap = new Map<string, String>{'merchant_type' => 'Merchant_Type__c'};
        
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
    
    
    @HttpPost
    global static List<AwsConsumerAPI_CTRL.Response> parseXML(){
        List<AwsConsumerAPI_CTRL.Response> responsePayloadList = new List<AwsConsumerAPI_CTRL.Response>() ;
        String requestBody = RestContext.request.requestBody.toString();
        SYstem.debug('requestBody:::::::'+requestBody);
        List<Payload_Log__c> payloadList = parseXML(requestBody);
        SYstem.debug('payloadList::::::'+payloadList);
        try{
            if(payloadList.size()>0 && payloadList !=null){
                for(Payload_Log__c payVar : payloadList){
                    if(String.isEmpty(payVar.Exception__c)){
                        AwsConsumerAPI_CTRL.Response awsResVar = new AwsConsumerAPI_CTRL.Response();
                        awsResVar.message = 'Payload Accepted';
                        awsResVar.success = true;
                        awsResVar.msgId = payVar.MessageId__c;
                        responsePayloadList.add(awsResVar); 
                    }
                    else if(String.isNotEmpty(payVar.Exception__c)){
                        AwsConsumerAPI_CTRL.Response awsResVar = new AwsConsumerAPI_CTRL.Response();
                        awsResVar.message = payVar.Exception__c;
                        awsResVar.success = false;
                        awsResVar.msgId = payVar.MessageId__c;
                        responsePayloadList.add(awsResVar); 
                    }
                }
            }
            return responsePayloadList;
        }
        catch(Exception e){
            throw new MyCustomException(e.getMessage());  
            
        } 
    }
    global class Response{
        global String message;
        global Boolean success;
        global String msgId;
    }  

    public static List<Payload_Log__c> parseXML(String xml){
        System.debug('xml::::::'+xml);
        List<Payload_Log__c> logList = new List<Payload_Log__c>();
        List<Object> jsonRootMapcDes = (List<Object>) JSON.deserializeUntyped(xml);
        System.debug('jsonRootMapcDes::::'+jsonRootMapcDes);
        Payload_Log__c theLog = new Payload_Log__c();
        try{
            for(Object obj : jsonRootMapcDes){
                Map<String,Object> jsonRoot = (Map<String,Object>)obj;
                SYstem.debug('a::::::::68'+obj);
                System.debug('jsonRoot:::::69:::'+jsonRoot);
                String receiptHandle = String.valueOf(jsonRoot.get('receiptHandle'));
                SYstem.debug('receiptHandle:::::123'+receiptHandle);
                String messageId = String.valueOf(jsonRoot.get('messageId'));
                String body = String.valueOf(jsonRoot.get('body'));
                System.debug('body::::84::'+body);
                String source = String.valueOf(jsonRoot.get('source'));
                System.debug('source>>>>>>'+source);
                /** SFI-1060 - Coding Challenge**/
                theLog.Payload__c = body;
                /** */
                theLog = parseJSON(body);
                if(theLog !=null){
                    theLog.Process__c = 'Salesforce Consumer';
                    theLog.Receipt_Handle__c = receiptHandle;
                    theLog.Payload__c = body;
                    theLog.MessageId__c  = messageId;
                    if(String.isNotBlank(source)){
                        theLog.Source__c = source;
                    }
                    
                    SYstem.debug('theLog::::::'+theLog.Exception__c );
                    if('SUCCESS'.equals(theLog.Status__c)){                                                
                        if(String.isNotBlank(receiptHandle)){                        
                            receiptHandle = AWSUtility.encode(receiptHandle);
                            receiptHandleMap.put(receiptHandle, null);                                                    
                        }
                    } 
                    logList.add(theLog); 
                    // logListPassToIntUtility.add(theLog);// added by rohit
                    
                    system.debug('logListPassToIntUtility:::108::'+logListPassToIntUtility);
                }
                if(!logList.isEmpty()){
                    Database.insert(logList, false);          
                }
            }
            return logList;
            
        }
        
        catch(Exception ex){
            //throw new MyCustomException(e.getMessage()); 
            theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString();
            theLog.Status__c = 'SUCCESS';
            logList.add(theLog);  
            return logList; 
        }        
    } 
    private class MyCustomException extends Exception{}
    @auraEnabled
    public static Payload_Log__c parseJSON(String jsonRoot){ 
        System.debug('jsonRoot:::::'+jsonRoot);
        Map<String, Object> jsonRootMap = (Map<String, Object>)JSON.deserializeUntyped(jsonRoot);
        System.debug('jsonRootMap:::132:::'+jsonRootMap);
        Payload_Log__c theLog = new Payload_Log__c();
        
        String action = String.valueOf(jsonRootMap.get('action'));   
        SYstem.debug('action:::::::'+action);
        String product = String.valueOf(jsonRootMap.get('product'));     
        SYstem.debug('product:::::::'+product);
        String businessObj = String.valueOf(jsonRootMap.get('business_object')); 
        SYstem.debug('businessObj:::::::'+businessObj);
        String producer = String.valueOf(jsonRootMap.get('producer'));
        if(producer=='MerchantOnboarding'){
            isFlagForMO = True;
        }
        SYstem.debug('producer:::::::'+producer);
        String source = String.valueOf(jsonRootMap.get('source'));
        SYstem.debug('source:::::::'+source);
        Integer mid ;
        if(jsonRootMap.containsKey('mid')) mid = Integer.valueOf(jsonRootMap.get('mid'));
        theLog.Producer__c = producer;
        theLog.Business_Object__c = businessObj;  
        theLog.Action__c = action;  
        // added by rohit if website url payload will come or update then this will true & this variable checking 
        // in opportunitytriggerhandler, do not send payload or create website details for offline if it is coming from CO
        runningFromConsumerAPIForOfflineFlow = true;//IntegrationUtility.runningFromConsumerAPI = true;
        
        if(action == 'create_bank_detail' || action == 'update_bank_detail' ){ //|| action == ''
            BankDetailTriggerHandler.runningFromConsumerAPI = true;
        }
        /** added to prevent the recursion of SeniorManagementDetailTrigger */
        if(action == 'create_business_member' || action == 'update_business_member'){
            SeniorManagementDetailTriggerHandler.runningFromConsumerAPI = true;
        }/** END */
        
        if(action == 'create_website_detail' || action == 'update_website_detail' ){ //|| action == ''
            WebsiteDetailsTriggerHandler.runningFromConsumerAPI = true;
        }
        
        if(action == 'create' || action == 'update' ){ //|| action == ''
            OpportunityTriggerHandler.runningFromConsumerAPI = true;
            LeadTriggerHandler.runningFromConsumerAPI = true;
        }
        
        /* if(System.Label.StopConsumingNodalCodesfromBiz == 'True' && action=='update_bank_detail' && producer=='PayUbizTreasury')
{theLog.Exception__c = 'Skipped';
return theLog;}*/
        
        
        if(System.Label.SwitchoffMultiProduct=='false' && (businessObj=='Account' || businessObj=='Merchant') && producer=='MerchantOnboarding'){return null;}
        else{
            if(String.isNotBlank(action) && !'Salesforce'.equals(producer)){  
                setproducerName.add(producer);
                SYstem.debug('setproducerName:::insideCTRL :::::'+setproducerName);
                globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;
                List<PayloadActMap__mdt> payloadActList = IntegrationUtility.getPayLoadMap(action, '', businessObj);    
                if(!payloadActList.isEmpty()){   
                    PayloadActMap__mdt thePayLoadMap = payloadActList[0];                                                                 
                    try{                    
                        Map<String, String> jsonFieldMap;
                        if(String.isNotBlank(thePayLoadMap.JsonMap__c)){
                            jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMap__c, Map<String, String>.class);
                        }
                        Map<String, String> jsonFieldPubMap;
                        if(String.isNotBlank(thePayLoadMap.JSONMapPub__c)){
                            jsonFieldPubMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSONMapPub__c, Map<String, String>.class);
                        }
                        
                        Map<String, String> jsonMap;
                        if(String.isNotBlank(thePayLoadMap.JSONfieldMap__c)){
                            jsonMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSONfieldMap__c, Map<String, String>.class);
                        }
                        
                        Map<String, String> lookUpNodeMap;
                        if(String.isNotBlank(thePayLoadMap.LookUpField__c)){
                            lookUpNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.LookUpField__c, Map<String, String>.class);                    
                        }
                        
                        Map<String, String> complexNodeMap;
                        if(String.isNotBlank(thePayLoadMap.JsonMapComp__c)){
                            complexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMapComp__c, Map<String, String>.class);                    
                        }
                        
                        Map<String, Object> secCondMap;
                        if(String.isNotBlank(thePayLoadMap.SecondaryCond__c) && String.isNotBlank(thePayLoadMap.SecondaryObject__c)){
                            secCondMap = (Map<String, Object>)JSON.deserializeUntyped(thePayLoadMap.SecondaryCond__c);      
                        }
                        Map<String, Object> subComplexNodeMap;
                        if(String.isNotBlank(thePayLoadMap.JSON_Map_sub_key_complex__c)){
                            subComplexNodeMap = (Map<String, Object>)JSON.deserializeUntyped(thePayLoadMap.JSON_Map_sub_key_complex__c );        
                        }             
                        
                        Map<String, Object> currentDataMap;
                        Map<String, Object> oldDataMap;
                        
                        if(jsonRootMap.containsKey('current_data')){
                            currentDataMap = (Map<String, Object>)jsonRootMap.get('current_data');  
                        }                      
                        
                        if(jsonRootMap.containsKey('old_data')){
                            oldDataMap = (Map<String, Object>)jsonRootMap.get('old_data');
                        }  
                        
                        
                        
                        Sobject sobToUpsert;String theSobject;Set<String> theFields =new Set<String>(); 
                        Sobject oldSobToUpsert;   
                        theSobject = thePayLoadMap.Sobject__c;
                        theFields= getFieldSet(theSobject);                    
                        sobToUpsert = globalDescribe.get(theSobject).newSObject();
                        
                        oldSobToUpsert = globalDescribe.get(theSobject).newSObject();
                        
                        if(currentDataMap != null && !currentDataMap.isEmpty() && (complexNodeMap != null && !complexNodeMap.isEmpty() || jsonFieldMap != null && !jsonFieldMap.isEmpty())){                                                                                                       
                            System.debug('insdie if test::::');
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
                                //theLog.Prod_MID__c = (Integer)currentDataMap.get('identifier');
                                theLog.Payload_ID__c = String.valueOf(currentDataMap.get('uuid'));                            
                                String queryStr ;
                                List<SObject> getIdList=null;
                                
                                if(theSobject=='Merchant_Status_Details__c'){
                                    queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Identifier__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                    system.debug('queryStr 0' +queryStr);
                                    getIdList = Database.query(queryStr);
                                }
                                if(businessObj=='MerchantAccount' && action=='update' && theSobject !='Lead'){// added by rohit  theSobject !='Lead' to skip the lead type update on lead after the pan verification step
                                    queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Merchant_Account_Id__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                    system.debug('queryStr 1 >>>>>>>>>>>> ' +queryStr);
                                    getIdList = Database.query(queryStr);
                                }
                                if(getIdList==null){
                                    /*For Multi Product - since 1st time when MerchantAccount payload come uuid is mapped with Merchant Account Id field, so that we can fetch the Lead*/
                                    if(System.Label.SwitchoffMultiProduct=='False' && currentDataMap.containsKey('merchant_account_uuid') && action!='update'){
                                        queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Merchant_Account_Id__c = \'' + currentDataMap.get('merchant_account_uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                        system.debug('queryStr  2' +queryStr);
                                        getIdList = Database.query(queryStr);
                                    }
                                    else{
                                        system.debug('Inside 3');
                                        queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Identifier__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                        getIdList = Database.query(queryStr);
                                    }
                                }
                                if(getIdList!=null && businessObj=='ProductAccount' && action=='create' && 
                                   !getIdList.isempty() && getIdList[0].get('Identifier__c')!=null && getIdList[0].get('Created__c')==true){
                                       //added pooja
                                       getIdList = null;
                                       system.debug('Inside 4');
                                       queryStr = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Merchant_Account_Id__c = \'' + currentDataMap.get('merchant_account_uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                       getIdList = Database.query(queryStr);
                                       currentDataMap.put('first_name',getIdList[0].get('firstName'));
                                       currentDataMap.put('last_name',getIdList[0].get('lastName'));
                                       getIdList = null;
                                   }
                                Boolean queryOpp = false;                                                        
                                
                                if(getIdList!=null && !getIdList.isEmpty()){
                                    if(theSobject == 'Lead' && getIdList[0].get('IsConverted') == true)
                                    { queryOpp = true; }
                                    else
                                    { sobToUpsert = getIdList[0]; } 
                                }
                                List<Sobject> getIdListOpp =null;
                                String queryStrOpp =null;
                                if(theSobject == 'Lead' && String.isNotBlank(thePayLoadMap.SecondaryObject__c) && 
                                   (getIdList.isEmpty() || queryOpp))
                                {
                                    if(businessObj=='MerchantAccount' && action=='update'){
                                        queryStrOpp = 'SELECT '+  String.join(new List<String>(getFieldSet(thePayLoadMap.SecondaryObject__c)), ',') + ' FROM ' + thePayLoadMap.SecondaryObject__c + ' WHERE Merchant_Account_Id__c  = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                        getIdListOpp = Database.query(queryStrOpp);
                                    }
                                    else{
                                        queryStrOpp = 'SELECT '+  String.join(new List<String>(getFieldSet(thePayLoadMap.SecondaryObject__c)), ',') + ' FROM ' + thePayLoadMap.SecondaryObject__c + ' WHERE Identifier__c = \'' + currentDataMap.get('uuid') + '\' ORDER BY CreatedDate ASC LIMIT 1';
                                        getIdListOpp = Database.query(queryStrOpp);
                                        
                                    }
                                    if(!getIdListOpp.isEmpty()){ 
                                        theSobject = thePayLoadMap.SecondaryObject__c; 
                                        theFields = getFieldSet(theSobject);                                                                      
                                        sobToUpsert = getIdListOpp[0];                                                                                                                                       
                                    }
                                }
                                
                                if(String.isNotBlank(thePayLoadMap.Delete_Action__c) && thePayLoadMap.Delete_Action__c == action && sobToUpsert.get('Id') != null){  
                                    delete sobToUpsert; theLog.Status__c = 'SUCCESS'; return theLog;
                                }
                            }
                            
                            if(currentDataMap.containsKey('product_uuid') && !currentDataMap.containsKey('uuid')
                               && mid != null && string.isNotBlank(product) /*&& product=='PayUbiz'*/){
                                   theLog.Payload_ID__c = string.valueOf(mid); 
                                   //theLog.Prod_MID__c = (Integer)currentDataMap.get('identifier');
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
                                   if(action == 'update_bank_detail' /*&& businessObj == 'Merchant'*/){
                                       // added by rohit : earlier we were filtiring using Opportunity__r.Prod_Merchant_Id__c taking more time to quering because of formula field so we removed and added  Opportunity__r.Prod_Merchant_Id__c number field
                                       String queryStrBankOpp = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Active__c = true AND Opportunity__r.Prod_Merchant_Id__c = ' + mid + '  AND ProductLabel__c = \'' +product+ '\'  ORDER BY CreatedDate ASC LIMIT 1';
                                       List<SObject> getIdListBankOpp = Database.query(queryStrBankOpp);
                                       if(!getIdListBankOpp.isEmpty()){                                                                      
                                           sobToUpsert = getIdListBankOpp[0];                                                                                                                                       
                                       }
                                       else{
                                           // added by rohit : earlier we were filtiring using Lead__r.Prod_Merchant_Id__c taking more time to quering because of formula field so we removed and added  Opportunity__r.Prod_Merchant_Id__c number field
                                           String queryStrBankLead = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Active__c = true AND Opportunity__r.Prod_Merchant_Id__c = ' + mid + '  AND ProductLabel__c = \'' +product+ '\'  ORDER BY CreatedDate ASC LIMIT 1';
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
                               /*&& mid != null */&& string.isNotBlank(product) && (action == 'update_product' || action == 'create_product') 
                               /*&& businessObj == 'Merchant'*/){
                                   theLog.Payload_ID__c = string.valueOf(mid);
                                   //theLog.Prod_MID__c = (Integer)currentDataMap.get('identifier');
                                   String queryStrCrossSellOpp = 'SELECT '+  String.join(new List<String>(theFields), ',') + ' FROM ' + theSobject + ' WHERE Active__c = true AND Opportunity__r.Prod_Merchant_Id__c = ' + mid + ' AND ProductLabel__c = \'' +product+ '\'  AND Custom_Product__r.Name = \''+ currentDataMap.get('product_name') +'\'  ORDER BY CreatedDate ASC LIMIT 1';
                                   List<SObject> getIdListCrossSellOpp = Database.query(queryStrCrossSellOpp);
                                   if(!getIdListCrossSellOpp.isEmpty()){                                                                      
                                       sobToUpsert = getIdListCrossSellOpp[0];                                                                                                                                       
                                   }
                               }
                            
                            List<String> theReadOnlySet = String.isBlank(thePayLoadMap.ReadOnly__c) ? null : thePayLoadMap.ReadOnly__c.split(',');
                            for(String each : currentDataMap.keySet()){ 
                                System.debug('each:::::::::::'+ each);
                                //checking for field values and sobj upserted
                                System.debug(sobToUpsert + '===== ');
                                System.debug(currentDataMap.get(each) + '===== ');
                                System.debug(jsonFieldMap + '===== ');
                                if(sobToUpsert != null){
                                    System.debug('check for first inside===== ');
                                    
                                    if(complexNodeMap != null && complexNodeMap.containsKey(each)){                                        
                                        System.debug('check for complex inside===== ');
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
                                    }
                                    else{
                                        System.debug('check for else inside===== ');
                                        if(jsonFieldMap != null && jsonFieldMap.containsKey(each)){
                                            System.debug('check for jsonfieldupdate inside===== ');
                                            for(String eachJsonStr : jsonFieldMap.get(each).split(';')){
                                                system.debug('%%%%%%%% eachJsonStr'+eachJsonStr);
                                                system.debug('%%%%%%%% '+currentDataMap.get(each));
                                                system.debug('%%%%%%%% sobToUpsert '+sobToUpsert);
                                                populateField(sobToUpsert, lookUpNodeMap, each, currentDataMap.get(each), eachJsonStr, theReadOnlySet, theFields); 
                                                System.debug('OUTSIDE POPULATE FIELD');
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
                                                populateField(sobToUpsert, lookUpNodeMap, each, getJsonStr(currentDataMap.get(each)), eachJsonStr, theReadOnlySet, theFields); 
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
                                                } 
                                                else if(currentDataMap.containsKey('name') && currentDataMap.get('name') == 'bank_detail_config'){
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
                        
                        if(oldDataMap != null && !oldDataMap.isEmpty() /*&& businessObj =='Merchant'*/ && action == 'update' && producer == 'MerchantOnboarding' && (complexNodeMap != null && !complexNodeMap.isEmpty() || jsonFieldMap != null && !jsonFieldMap.isEmpty())){ 
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
                                    sobToUpsert.put(midMap.get(each),jsonRootMap.get(each));
                                    break;
                                }
                                if(leadTypeMap.containsKey(each)){
                                    sobToUpsert.put(leadTypeMap.get(each), jsonRootMap.get(each));
                                    //checkLeadType = true;
                                    break;
                                }
                            }
                        }
                        
                        if(businessObjs.containsKey(theSobject) && (businessObj=='ProductAccount' || businessObj=='MerchantAccount' || businessObj=='Partner') && checkLeadType==false){ 
                            sobToUpsert.put(businessObjs.get(theSobject),businessObj);
                        }
                        /*else if(businessObjs.containsKey(theSobject) && (businessObj=='MerchantAccount' && action != 'update') && checkLeadType==false){ 
                            sobToUpsert.put(businessObjs.get(theSobject),businessObj);
                        }*/ 
                        System.debug('------------------>>>>>>>>>>>> ' + sobToUpsert);
                        System.debug('businessObj::123::'+businessObj);
                        /*PayloadHolder payloadHeader = new PayloadHOlder();
                        payloadHolder.payload = theLog ; */
                        System.debug('>>>>>>>>>theLog-->Payload__c >>>>>>>>'+theLog.Payload__c);
                        IntegrationUtility.awsConsumerPayload = theLog;//Setting payloadlog details to addPayloadFromAWS: added by rohit
                        //Database.UpsertResult SaveResultList = Database.upsert(sobToUpsert ,false);
                        
                        // KUNAL - Adding the Following if-clause to stop the create ProductAccount AND create MerchantAccount Payload from CO for OFFLINE LEAD  // action == create && theSObject == 'Lead' && Offline == TRUE
                        // 																																			action != create OR (theSObject == 'Lead' AND Offline == TRUE)
                        //System.debug('testing sobToUpsert'+sobToUpsert.get('Offline_Lead__c'));
                        //if(action == 'create' && theSobject == 'Lead' && sobToUpsert.get('Offline_Lead__c') == TRUE){}
                        //else{
                        
                            Database.UpsertResult SaveResultList = Database.upsert(sobToUpsert ,false);
                            
                            system.debug('SaveResultList' +SaveResultList);
                            if(SaveResultList.getId() !=null){
                                leadIdSet.add(SaveResultList.getId());
                            }
                            SYstem.debug('leadIdSet::::::::'+leadIdSet);
                            if(theSobject == 'Bank_Account_Detail__c' && sobToUpsert.get('Lead__c') != null){
                                if(sobToUpsert.get('Opportunity__c') == null && sobToUpsert.get('Active__c')==true){
                                    leadIdSet.add(String.valueOf(sobToUpsert.get('Lead__c')));
                                }
                                if(action == 'create_bank_detail') bankAccountIdSet.add(String.valueOf(sobToUpsert.get('Id')));
                            } 
                            if(action == 'update_bank_detail'&& sobToUpsert.get('Lead__c') == null 
                               && sobToUpsert.get('Opportunity__c') != null
                               && sobToUpsert.get('Active__c')==true && String.valueOf(sobToUpsert.get('Verification_Status__c'))
                               == 'Success'){
                                   bankAccountIdSetUpdate.add(String.valueOf(sobToUpsert.get('Id')));
                               } 
                            
                            if(action == 'update_address') addressIdSetUpdate.add(String.valueOf(sobToUpsert.get('Id')));  
                            
                            if(theSobject == 'Lead' && businessObj == 'Partner' && action == 'create') leadIdSet.add(String.valueOf(sobToUpsert.get('Id')));
                            
                            //========= Adding Business Entity check for Onboarding Revamp-JIRA-SFPI-997============
                            if(theSobject == 'Lead' && businessObj != 'Partner' && String.valueOf(sobToUpsert.get('Business_Entity__c')) != null && String.valueOf(sobToUpsert.get('PAN_Holder_Name__c')) != null && String.valueOf(sobToUpsert.get('PAN_Number__c')) != null) 
                                leadIdSet.add(String.valueOf(sobToUpsert.get('Id')));
                            
                            // update opportunity on addendum approval
                            if(theSobject == 'Contract' && (action == 'update_kyc_doc') && sobToUpsert.get('AccountId') != null 
                               && sobToUpsert.get('URL__c') != null && sobToUpsert.get('Contract_Type__c') == 'Addendum' 
                               && sobToUpsert.get('Onboarding_Status__c') == 'Approved' // field changed from Status to Onboarding_Status__c
                               && oldSobToUpsert.get('Status') != null
                               && sobToUpsert.get('Onboarding_Status__c') != oldSobToUpsert.get('Status')){
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
                            
                            if(theSobject == 'Opportunity' && action == 'update' && Producer == 'PayUmoney' &&
                               (sobToUpsert.get('Settlement_Status__c')=='Thirdparty Hold' || sobToUpsert.get('Settlement_Status__c')==null)
                               && businessObj=='Merchant' && string.isNotBlank(product) && product=='PayUmoney'){
                                   websiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                               }
                            
                            if(theSobject == 'Opportunity' && action == 'update' && Producer == 'MerchantOnboarding' 
                               && (sobToUpsert.get('Website_Status__c') == 'Pending' || sobToUpsert.get('Website_Status__c')=='Verification in Process')
                               && (sobToUpsert.get('Website__c') != null || sobToUpsert.get('IOS_URL__c') != null || sobToUpsert.get('Android_URL__c') != null)
                               && sobToUpsert.get('Integration_Type__c') == 'Thirdparty' 
                               && ((oldSobToUpsert.get('Website__c') != null && sobToUpsert.get('Website__c') != null &&
                                    sobToUpsert.get('Website__c') != oldSobToUpsert.get('Website__c')) || (oldSobToUpsert.get('IOS_URL__c') != null && sobToUpsert.get('IOS_URL__c') != null && sobToUpsert.get('IOS_URL__c') != oldSobToUpsert.get('IOS_URL__c')) || (oldSobToUpsert.get('Android_URL__c') != null && sobToUpsert.get('Android_URL__c') != null && sobToUpsert.get('Android_URL__c') != oldSobToUpsert.get('Android_URL__c')))){
                                        
                                        updatedWebsiteURLoppIds.add(string.valueOf(sobToUpsert.get('Id')));
                                    }
                            
                            //===========Onboarding Revamp Changes================
                            if(theSobject == 'Website_Details__c' && action == 'update_website_detail' && Producer == 'MerchantOnboarding' && sobToUpsert.get('Website_Status__c') == 'Verification in Process' && sobToUpsert.get('Active__c') == true
                               && (sobToUpsert.get('Website_URL__c') != null || sobToUpsert.get('IOS_URL__c') != null || sobToUpsert.get('Android_URL__c') != null)){
                                   updatedWebsiteDetailsIds.add(string.valueOf(sobToUpsert.get('Id')));
                               }
                            theLog.SalesforceRecordId__c = sobToUpsert.Id;
                            theLog.Status__c = 'SUCCESS';
                            
                            
                            return theLog;
                       // }
                        
                        
                        
                    }catch(exception ex){
                        theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); theLog.Status__c = 'SUCCESS'; return theLog;
                    }
                    
                }  
                finishFromApi();
            }
            theLog.Status__c = 'ERROR'; 
            return theLog;  
        }
        
    }
    public static void populateField(Sobject sobToUpsert, Map<String, String> lookUpNodeMap, String theNode, Object theData, String fieldAPI, List<String> theReadOnlySet, Set<String> fields){
        System.debug('INSIDE POPULATE FIELD: '+sobToUpsert+ ' - '+lookUpNodeMap+ ' - '+theNode+ ' - '+theData+ ' - '+fieldAPI+ ' - '+theReadOnlySet+ ' - '+fields);
        String lookUpQueryStr='';
        String lookUpFieldAPI ='';
        if(lookUpNodeMap != null && lookUpNodeMap.containsKey(theNode) && String.isNotBlank(lookUpNodeMap.get(theNode))){            
            /*for(String each : lookUpNodeMap.get(theNode).split(';')){
lookUpQueryStr = each.subStringAfter(',');
lookUpFieldAPI = each.subStringBefore(','); 
SYstem.debug('lookUpQueryStr::::::'+lookUpQueryStr);
SYstem.debug('lookUpFieldAPI::::::'+lookUpFieldAPI);
break;
}
if(String.isNotBlank(lookUpFieldAPI) && fields.contains(lookUpFieldAPI)){
String queryStr = 'SELECT Id FROM ' + lookUpQueryStr.subStringBefore(':') + ' WHERE ' + lookUpQueryStr.subStringAfter(':') + ' = \'' + theData + '\'';          
List<Sobject> queriedList = Database.query(queryStr);
if(!queriedList.isEmpty()){
sobToUpsert.put(lookUpFieldAPI, queriedList[0].Id); 
system.debug('sobToUpsert=='+sobToUpsert);

}
}*/
            for(String each : lookUpNodeMap.get(theNode).split(';')){
                lookUpQueryStr = each.subStringAfter(',');
                lookUpFieldAPI = each.subStringBefore(',');                
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
                system.debug('fieldAPI>>>>>>>>> --'+fieldAPI);
                String theAPI = fieldAPI.subStringBefore(',');
                String fieldType = fieldAPI.subStringAfter(',');
                if(fields.contains(theAPI) || theAPI.equalsIgnoreCase('Penny_Verification_Required__c')){
                    if(theReadOnlySet == null || !theReadOnlySet.contains(theAPI))
                        sobToUpsert.put(theAPI, getformattedData(theData, fieldType));    
                    system.debug('theAPI>>>>>>>>> --'+theAPI );	
                    system.debug('sobToUpsert>>>>>>>>> --'+sobToUpsert.get(theAPI));
                }  
            }                                         
        }
    }
    
    public static Object getformattedData(Object theData, String dataType){
        if(theData != null) {
            if('datetime'.equalsIgnoreCase(dataType)) {
                return Datetime.valueOf(String.valueOf(theData));
            } else if('date'.equalsIgnoreCase(dataType)) {//addedd
                return Date.valueOf(String.valueOf(theData));//added puja
            }else if('string'.equalsIgnoreCase(dataType)) {
                return String.valueOf(theData);
            }
        }
        return theData;
    }
    public static String getJsonStr(Object theJsonObj){
        String theJsonValue = '';
        List<String> strList = new List<String>();
        if(theJsonObj != null){
            List<Object> objList = (List<Object>)theJsonObj;
            if(objlist != null){
                for(Object js : objlist){
                    Map<String, Object> tempMap = (Map<String, Object>)js;
                    String str = JSON.serialize(tempMap);
                    strList.add(str);
                }
                theJsonValue = String.join(strList, ', ');
            }else{
                Map<String, Object> tempMap = (Map<String, Object>)theJsonObj;
                theJsonValue = JSON.serialize(tempMap);
            }
        }
        return theJsonValue;
    }
    public static Set<String> getFieldSet(String sobType){
        Set<String> setToReturn = new Set<String>();
        
        if(sobFieldMap.containsKey(sobType)) setToReturn = sobFieldMap.get(sobType);        
        else{
            SYstem.debug('inside if:::'+sobType);
            globalDescribe = globalDescribe == null ? Schema.getGlobalDescribe() : globalDescribe;            
            Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(sobType).getDescribe().fields.getMap();
            for(Schema.SObjectField each : fieldMap.Values()){
                schema.describefieldresult dfield = each.getDescribe();
                setToReturn.add(dfield.getName());
            }
            System.debug('setToReturn:::::'+setToReturn);            
            sobFieldMap.put(sobType, setToReturn);
        }
        
        return setToReturn;
    }   
    public static void finishFromApi(){
        System.debug('logListPassToIntUtility::::::'+logListPassToIntUtility);
        isFinishExecuted = true;
        processDeleteList('DeleteMessageBatchSQS');                
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
            if(!oppIds.isEmpty()){
                
                String s ='SELECT ' + String.join(new List<String>(getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\')'; 
                for(Opportunity each : Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Id IN (\'' + String.join(new List<String>(oppIds), '\',\'') + '\')')){                    
                    IntegrationUtility.oppConvertedSet.add(each.Id);
                    if(each.NB_Eligible__c==True && each.Partner_Source__c=='Bulk Referral' ){
                        System.debug('each.id::Inside If::'+each.Id );
                        IntegrationUtility.sendPayLoadData(each, null, 'Opportunity', 'Opportunity');   
                    }
                    else{
                        each.NB_Eligible__c = true;
                        each.Partner_Source__c = 'Bulk Referral';
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
        //--Added to remeove agreement issue--//
        if(!bankAccountIdSetUpdate.isEmpty()){
            string agreementSObjectName = 'Bank_Account_Detail__c';
            PublishExistingOppotunityWebsiteBatch updateAgreementBatch = new PublishExistingOppotunityWebsiteBatch(bankAccountIdSetUpdate,agreementSObjectName,setproducerName);
            Database.executeBatch(updateAgreementBatch);
        } 
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
        //================== Used to send the Website Details payload, if website is OK================
        if(!updatedWebsiteDetailsIds.isEmpty() && updatedWebsiteDetailsIds.size() > 0){
            string sObjectName = 'Website_Details__c';
            PublishExistingOppotunityWebsiteBatch oppPublisherBatch = new PublishExistingOppotunityWebsiteBatch(updatedWebsiteDetailsIds,sObjectName,setproducerName);
            Database.executeBatch(oppPublisherBatch);
        }
        if(!bankAccountIdSet.isEmpty()) BankDetailTriggerHandler.afterInsertHandler(Database.query('SELECT ' + String.join(new List<String>(getFieldSet('Bank_Account_Detail__c')), ',') + ' FROM Bank_Account_Detail__c WHERE Id IN (\'' + String.join(new List<String>(bankAccountIdSet), '\',\'') + '\')'));        
        if(!addressIdSetUpdate.isEmpty()) System.enqueueJob(new generateAgreementFromAddressUpdate(addressIdSetUpdate));
        Batch_Setting__mdt bsMDT = [Select Id,Record_Limit__c,Re_Run_Apex_Job__c,Where_Clause__c from Batch_Setting__mdt 
                                    where DeveloperName=:'AWSConsumerBatch' LIMIT 1];
    }
    public static void processDeleteList(String metaName){
        deleteMessages(receiptHandleMap, metaName);       
    }
    public static void deleteMessages(Map<String, String> theReceiptHandleMap, String metaName){
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
            }
        }
    }
}