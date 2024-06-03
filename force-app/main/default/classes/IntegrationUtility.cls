public class IntegrationUtility{
    //public static boolean runningFromConsumerAPI = false;
    static String CLIENT_ID;
    static String CLIENT_SECRET;
    public static void defineCredentials(String metaDevName){
        CLIENT_ID = '';
        CLIENT_SECRET = '';
        
        if(String.isBlank(CLIENT_ID) && String.isBlank(CLIENT_SECRET)){
            
            Map<String, List<String>> sandbox_Cred_Map = (Map<String, List<String>>)JSON.deserialize(Label.Sandbox_Cred_Map, Map<String, List<String>>.class);            
            String baseUrl = URL.getSalesforceBaseUrl().getHost(); 
            Credentials__c cred = Credentials__c.getInstance();
            
            for(String each : sandbox_Cred_Map.keySet()){                
                if(baseUrl.contains(each)){
                    Boolean contains = sandbox_Cred_Map.get(each).contains(metaDevName); 
                    CLIENT_ID = contains ? cred.OnboardingClientIdProd__c : cred.OnboardingClientIdSB__c;
                    CLIENT_SECRET = contains ? cred.OnboardingClientSecProd__c : cred.OnboardingClientSecSB__c;
                    break;
                }
            } 
            
            if(String.isBlank(CLIENT_ID) && String.isBlank(CLIENT_SECRET)){
                CLIENT_ID = cred.OnboardingClientIdProd__c;// PRODUCTION CREDENTIALS
                CLIENT_SECRET = cred.OnboardingClientSecProd__c;
            }
        } 
    }
    
    public static Integration_Setting__mdt getIntSetting(String metaName){
        System.debug('===========int setting metaname ' + metaName);
        List<Integration_Setting__mdt> insList = [SELECT Id, DeveloperName, Body__c, SetCompressed__c, EndPointUrl__c, 
                                                  Headers__c, Method__c,Custom_Header__c,Custom_Body__c, User_Name__c, Password__c,Encoded_Data__c
                                                  FROM Integration_Setting__mdt WHERE DeveloperName =: metaName]; 
        
        if(!insList.isEmpty()){
            return insList[0];
        }
        
        return null;               
    }
    
    public static String getAuthToken(String metaName){        
        Integration_Setting__mdt theIntIns = getIntSetting(metaName);
        SYstem.debug('theIntIns::46:::'+theIntIns);
        if(theIntIns != null){            
            HttpResponse response = requestUtility(theIntIns, true, null, null, null, null); 
            System.debug('response:::49::::'+response.getbody());
            if(!test.isRunningTest()){
                if(response.getStatusCode() == 200){
                    Map<String, Object> theResMap = (Map<String, Object>)JSON.deserializeUntyped(response.getbody());
                    SYstem.debug('theResMap:53:::'+theResMap);
                    if(theResMap.containsKey('access_token')){
                        return String.valueOf(theResMap.get('access_token'));
                    }
                } 
            }
        }
        
        return '';
    }
    
    public static HttpResponse requestUtility(Integration_Setting__mdt theIntIns, Boolean isAuth, String authToken, Sobject sob, List<String> urlFormatStr, String theBody){
        HttpRequest req = new HttpRequest();
        
        String endPointStr = urlFormatStr == null || urlFormatStr.isEmpty() ? theIntIns.EndPointUrl__c : String.format(theIntIns.EndPointUrl__c, urlFormatStr);        
        // below if condition added by rohit for Consume Treasury New API - Login Delays
        if(theIntIns.DeveloperName == 'UpdateSettlementStatusFromSFNewAPI'){
           endPointStr += '?hold_settlement='+urlFormatStr[0]+'&timeStamp='+sob.get('TimeInMillis__c');
        }
        System.debug('timeStamp:::72::'+sob.get('TimeInMillis__c'));
        System.debug('endPointStr::::::::'+endPointStr);
        req.setEndpoint(endPointStr);
        req.setMethod(theIntIns.Method__c);
        req.setCompressed(theIntIns.SetCompressed__c);
        System.debug('req:::::75::::'+req);
        List<String> bodyParams = new List<String>();
        
        if(String.isNotBlank(theIntIns.Custom_Body__c) && !isAuth){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            for(String each : theIntIns.Custom_Body__c.split(',')){
                String bodayParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));
                if(String.isNotBlank(bodayParamVal)){
                    if(!theIntIns.Encoded_Data__c){
                        if(each.subStringBefore(':') == 'nbEnabled'){
                            gen.writeBooleanField(each.subStringBefore(':'), String.valueOf(sob.get(each.subStringAfter(':'))).equals('true') ? true : false);
                        }else{
                            gen.writeStringField(each.subStringBefore(':'),bodayParamVal);
                        }
                    }else{
                        //gen.writeStringField(each.subStringBefore(':'),EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));
                        bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));
                    }
                }
            }
            gen.writeEndObject(); 
            req.setBody(gen.getAsString());
        }
        
        if(String.isNotBlank(theIntIns.Body__c)){
            for(String each : theIntIns.Body__c.split(',')){                     
                String bodayParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));                
                if(String.isNotBlank(bodayParamVal)){
                    bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));  
                }                     
            }
        }
        
        if(String.isNotBlank(theIntIns.Headers__c)){
            for(String each : theIntIns.Headers__c.split(',')){
                req.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
            }
        }
        
        if(String.isNotBlank(authToken)){
            req.setHeader('Authorization', 'Bearer ' + authToken);
        }
        
        if(isAuth){  
            if(String.isNotBlank(theIntIns.Custom_Body__c)){
                for(String each : theIntIns.Custom_Body__c.split(',')){
                    bodyParams.add(each);
                }
            }else{
                defineCredentials(theIntIns.DeveloperName);       
                
                bodyParams.add('client_id' + '=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8'));
                bodyParams.add('client_secret' + '=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8'));
            }
        }                
        
        if(String.isNotBlank(theIntIns.User_Name__c) && String.isNotBlank(theIntIns.Password__c)){
            Blob headerValue = Blob.valueOf(theIntIns.User_Name__c  + ':' + theIntIns.Password__c);
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(headerValue));
        }
        
        
        if(!bodyParams.isEmpty()){
            System.debug('req::::::139:::'+req);
            req.setBody(String.join(bodyParams, '&')); 
        }else if(String.isNotBlank(theBody)){
            req.setBody(theBody); 
        }
        
        if(String.isNotBlank(theIntIns.Custom_Header__c)){
            for(String each : theIntIns.Custom_Header__c.split(',')){
                String headerParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));
                if(String.isNotBlank(headerParamVal)) req.setHeader(each.subStringBefore(':'), EncodingUtil.urlEncode(headerParamVal, 'UTF-8'));
            }
        }
        System.debug('req::::::'+req);
        system.debug('####### '+req.getBody());
        req.setTimeout(120000);
        if(!test.isRunningTest())   return new Http().send(req);
        else    return null;
    } 
    
    
    
    public static HTTPWrapper sendHTTPRequest(Integration_Setting__mdt theIntIns, Boolean isAuth, String authToken, Sobject sob, List<String> urlFormatStr, String theBody){
        
        HTTPWrapper wrpCls = new HTTPWrapper();
        HttpRequest req = new HttpRequest();
        
        String endPointStr = urlFormatStr == null || urlFormatStr.isEmpty() ? theIntIns.EndPointUrl__c : String.format(theIntIns.EndPointUrl__c, urlFormatStr);        
        req.setEndpoint(endPointStr);
        req.setMethod(theIntIns.Method__c);
        req.setCompressed(theIntIns.SetCompressed__c);
        
        List<String> bodyParams = new List<String>();
        
        if(String.isNotBlank(theIntIns.Custom_Body__c) && !isAuth){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            for(String each : theIntIns.Custom_Body__c.split(',')){
                String bodayParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));
                if(String.isNotBlank(bodayParamVal)){
                    if(!theIntIns.Encoded_Data__c){
                        if(each.subStringBefore(':') == 'nbEnabled'){
                            gen.writeBooleanField(each.subStringBefore(':'), String.valueOf(sob.get(each.subStringAfter(':'))).equals('true') ? true : false);
                        }else{
                            gen.writeStringField(each.subStringBefore(':'),bodayParamVal);
                        }
                    }else{
                        //gen.writeStringField(each.subStringBefore(':'),EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));
                        bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));
                    }
                }
            }
            gen.writeEndObject(); 
            req.setBody(gen.getAsString());
        }
        
        if(String.isNotBlank(theIntIns.Body__c)){
            for(String each : theIntIns.Body__c.split(',')){                     
                String bodayParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));                
                if(String.isNotBlank(bodayParamVal)){
                    bodyParams.add(each.subStringBefore(':') + '=' + EncodingUtil.urlEncode(bodayParamVal, 'UTF-8'));  
                }                     
            }
        }
        
        if(String.isNotBlank(theIntIns.Headers__c)){
            for(String each : theIntIns.Headers__c.split(',')){
                req.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
            }
        }
        
        if(String.isNotBlank(authToken)){
            req.setHeader('Authorization', 'Bearer ' + authToken);
        }
        
        if(isAuth){  
            if(String.isNotBlank(theIntIns.Custom_Body__c)){
                for(String each : theIntIns.Custom_Body__c.split(',')){
                    bodyParams.add(each);
                }
            }else{
                defineCredentials(theIntIns.DeveloperName);       
                
                bodyParams.add('client_id' + '=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8'));
                bodyParams.add('client_secret' + '=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8'));
            }
        }                
        
        if(String.isNotBlank(theIntIns.User_Name__c) && String.isNotBlank(theIntIns.Password__c)){
            Blob headerValue = Blob.valueOf(theIntIns.User_Name__c  + ':' + theIntIns.Password__c);
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(headerValue));
        }
        
        
        if(!bodyParams.isEmpty()){
            req.setBody(String.join(bodyParams, '&')); 
        }else if(String.isNotBlank(theBody)){
            req.setBody(theBody); 
        }
        
        if(String.isNotBlank(theIntIns.Custom_Header__c)){
            for(String each : theIntIns.Custom_Header__c.split(',')){
                String headerParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));
                if(String.isNotBlank(headerParamVal)) req.setHeader(each.subStringBefore(':'), EncodingUtil.urlEncode(headerParamVal, 'UTF-8'));
            }
        }
        system.debug('####### '+req.getBody());
        req.setTimeout(120000);
        wrpCls.request = req.getBody();
        if(!test.isRunningTest())  {
        	 Wrpcls.response = new Http().send(req); 
            	return wrpCls;
        } 
        else    return null;
    } 
    
    public class HTTPWrapper {
    	public HttpResponse response;
        public String request = '';
    }
    
    
    
    public static HttpResponse requestUtilityWithJSONBody(Integration_Setting__mdt theIntIns, Boolean isAuth, String authToken, Sobject sob, List<String> urlFormatStr, String theBody){
        HttpRequest req = new HttpRequest();
        
        String endPointStr = urlFormatStr == null || urlFormatStr.isEmpty() ? theIntIns.EndPointUrl__c : String.format(theIntIns.EndPointUrl__c, urlFormatStr);        
        req.setEndpoint(endPointStr);
        req.setMethod(theIntIns.Method__c);
        req.setCompressed(theIntIns.SetCompressed__c);
        
        List<String> bodyParams = new List<String>();

        List<String> upperCaseParams = new List<String> {'businessUseCase', 'lob', 'accountType', 'onboardingType', 'category'};
        
        if(String.isNotBlank(theIntIns.Custom_Body__c) && !isAuth){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            for(String each : theIntIns.Custom_Body__c.split(',')){
                String bodayParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));
                if(each.subStringBefore(':') == 'nbEnabled' || each.subStringBefore(':') == 'limitedCapability' ){
                    gen.writeBooleanField(each.subStringBefore(':'), bodayParamVal.equals('true') ? true : false);
                } else if(upperCaseParams.contains(each.subStringBefore(':'))){
                    bodayParamVal = bodayParamVal.toUpperCase();
                    gen.writeStringField(each.subStringBefore(':'),bodayParamVal);
                } else{
                    gen.writeStringField(each.subStringBefore(':'),bodayParamVal);
                }
            }
            // START - Write Limit Param values
            gen.writeFieldName('limitParams');
            gen.writeStartObject();            
            gen.writeStringField('txnCountLimit',String.valueOf(sob.get('Transaction_Count_Limit__c')));            
            gen.writeStringField('amountLimit',String.valueOf(sob.get('Amount_Limit__c')));
            gen.writeStringField('timeLimit',String.valueOf(sob.get('Time_Limit__c')));
            gen.writeEndObject();
            // End - Write Limit Param values
            gen.writeEndObject();
            req.setBody(gen.getAsString());
            System.debug('REQUEST BODY: '+gen.getAsString());
        }
        
        if(String.isNotBlank(theIntIns.Headers__c)){
            for(String each : theIntIns.Headers__c.split(',')){
                req.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
            }
        }
        
        if(String.isNotBlank(authToken)){
            req.setHeader('Authorization', 'Bearer ' + authToken);
        }                
        
        if(String.isNotBlank(theIntIns.Custom_Header__c)){
            for(String each : theIntIns.Custom_Header__c.split(',')){
                String headerParamVal = (sob == null) ? each.subStringAfter(':') : String.valueOf(sob.get(each.subStringAfter(':')));
                if(String.isNotBlank(headerParamVal)) req.setHeader(each.subStringBefore(':'), EncodingUtil.urlEncode(headerParamVal, 'UTF-8'));
            }
        }
        req.setTimeout(120000);
        if(!test.isRunningTest())   return new Http().send(req);
        else    return null;
    }
    
    public static Map<String, PayloadActMap__mdt> payLoadUtilMap = new Map<String, PayloadActMap__mdt>();
    
    public static List<PayloadActMap__mdt> getPayLoadMap(String action, String sobName, String businessObjName){  
        System.debug('action::156 action::'+action);
        System.debug('action::156 businessObjName::'+businessObjName);
        System.debug('action::156 sobName::'+sobName);
        String queryStr = 'SELECT Action__c, Delete_Action__c,Business_Object__c, JSONfieldMap__c, JSON_map_Comp_2__c,JsonMapComp__c, JSONMapkeyArray2__c,SecondaryCond__c, SecondaryObject__c, JSONMapkeyArray__c, Related_Object__c, ArrayNodes__c, JSONMapPub__c, FieldsCheck__c, ReadOnly__c, JsonMap__c, Sobject__c, LookUpField__c ,Secondary_Object_Query_Fields__c,JSON_Map_sub_key_complex__c FROM PayloadActMap__mdt WHERE ';        
        queryStr += 'Action__c = \'' + action + '\'';
        queryStr += String.isNotBlank(sobName) ? 'AND Allowed__c =false AND Sobject__c = \'' + sobName + '\'' : '';   //Added for MultiProduct//     
        //queryStr += String.isNotBlank(businessObjName) ? ' AND Business_Object__c LIKE \'%' + businessObjName + '%\'' : '';
        queryStr += String.isNotBlank(businessObjName) ? ' AND Business_Object__c ='+'\''+ businessObjName + '\'': '';
        
        List<PayloadActMap__mdt> payloadList = Database.query(queryStr);    
        System.debug('>>>>>>>>>queryStr>>>>>>>>>>'+queryStr);
        System.debug('queryStr::::::::226:::'+payloadList);
        payloadList = !payloadList.isEmpty() ? payloadList : Database.query(queryStr.replace('Action__c = \'' + action + '\'', 'Delete_Action__c = \'' + action + '\''));                
        System.debug('payloadList::::::::226:::'+payloadList);
        return payloadList;                
    }
    
    public static Boolean isInsert = false;
    public static Boolean isUpdate = false;
    public static Boolean isDelete = false;
    public static Boolean isTriggerExecuting = false;
    
    /** Commented for SFI-1229 */
    //static Map<String, String> actionMap = (Map<String, String>)JSON.deserialize(Label.ObjectActionMap, Map<String, String>.class);
    
    /** Added for change the object to action mapping from custom label to custom metadata.*/
    /** SFI-1229 */
    public static Map<String, String> actionMap = getActionMapping();
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
    
    
    
    public static Set<Id> oppConvertedSet = new Set<Id>();
    public static Set<Id> contractAccountIds = new Set<Id>();
    public static Set<Id> websiteOppIds = new Set<Id>();
    public static Boolean isFutureUpdate = false;
    public static Payload_log__c awsConsumerPayload = new Payload_log__c();// added by rohit for BFL 
    
     public static void checkMaintenance(Sobject newData, Sobject oldData, String sobName, String payLoadSobName){
        system.debug('awsConsumerPayload in checkMaintenance::::::'+awsConsumerPayload);
        system.debug('::newData::::'+newData);
        String mainStatus = String.valueOf(newData.get('Maintenance_Status__c'));
        if(String.isBlank(mainStatus) || ('Opportunity'.equals(sobName) && 'NEW MID'.equals(mainStatus)) /*&& !runningFromConsumerAPI*/){
            sendPayLoadData(newData, oldData, sobName, payLoadSobName);
        }
    }
    public static String getActionName(Sobject newData, String sobName){
        String action = '';
        SYstem.debug('sobName:::::::'+sobName);
        if(actionMap != null){
            if(actionMap.containsKey(sobName)){                    
                String actionMapStr = actionMap.get(sobName);
                System.debug('actionMapStr::::::'+actionMapStr);
                if(String.isNotBlank(actionMapStr)){
                    List<String> actionList = actionMapStr.split(',');                
                    
                    if((isTriggerExecuting && isInsert) || (Trigger.isExecuting && Trigger.isInsert) || AWSConsumerBatch.isFinishExecuted || LeadConvertBatch.isLeadConversionBatch || SettlementStatusSyncBatch.isSettlementActivationBatch || PublishExistingOppotunityWebsiteBatch.isExecutionFinished || isFutureUpdate){
                        action = (contractAccountIds.contains(String.valueOf(newData.get('Id'))) || oppConvertedSet.contains(String.valueOf(newData.get('Id'))) || websiteOppIds.contains(String.valueOf(newData.get('Id')))) ? actionList[1] : actionList[0];
                        system.debug('#### action '+action);
                    }else if((isTriggerExecuting && isUpdate) || (Trigger.isExecuting && Trigger.isUpdate)){
                        action = actionList[1];
                        system.debug('#### action '+action);
                    }else if((Trigger.isExecuting && Trigger.isDelete) || (isTriggerExecuting && isDelete)){
                        if(actionList.size() > 2) action = actionList[2]; 
                        system.debug('#### action '+action);
                    }                        
                    
                }                
            }
        }
        system.debug('#### action '+action);
        return action;
    }
    
   //------------------------- /* Start - multi product change*/-----------------------------//
    
    public static void sendPayLoadData(Sobject newData, Sobject oldData, String sobName, String payLoadSobName){ 
        if(System.Label.StopSendingPayloadtoESB =='True') return;

        if(System.Label.SwitchoffMultiProduct=='False'){
            // oldSendPayLoadData(newData, oldData, sobName, payLoadSobName,'');
            oldSendPayLoadData(newData, oldData, sobName, payLoadSobName, true);
            System.debug('after ist condition:::::');
        }
        else{
            oldSendPayLoadData(newData, oldData, sobName, payLoadSobName, false);
        }
    }
    
    
    public static void SendPayLoadDataForMultiProduct(Sobject newData, Sobject oldData, PayloadActMap__mdt merchantpayLoadMap, PayloadActMap__mdt productPayLoadMap,PayloadActMap__mdt payloadActionMap, Set<String> theFields, boolean validateForUpdate){
        String thePayLoad = '';
        String objName = newData.getSobjectType().getDescribe().getName();
        Boolean bflAggregatorFlag = false;
        Boolean coProducerFlag = false; 
        Boolean stopSendPayLoadDataForBFL = false;
        String aggUUId = null;
        
        System.debug('::-newData::'+newData+'  ::-oldData::'+oldData+'  ::-merchantpayLoadMap::'+merchantpayLoadMap+'  ::-productPayLoadMap::'+productPayLoadMap+'  ::-payloadActionMap::'+payloadActionMap+'  ::-theFields::'+theFields+'  ::-validateForUpdate::'+validateForUpdate);
        try{
			aggUUId = (String) newData.get('Aggregator_UUID__c') ;            
        }catch (SObjectException ex){
            System.debug('Aggregator_UUID__c fetch exception ::::' +ex);
        }

        //List<String> aggregatorsList = new List<String>();
		//aggregator =
        if(objName=='Opportunity' && aggUUId !=null && aggUUId =='11ed-e4ea-b74b48aa-929c-02e708f88ebc'){
            bflAggregatorFlag = true;
        }
        if(awsConsumerPayload != NULL &&  awsConsumerPayload.Producer__c =='MerchantOnboarding'){
            coProducerFlag = true;
        }
        
        if((bflAggregatorFlag && coProducerFlag) && System.Label.StopSendPayLoadDataForBFL == 'True'){
            stopSendPayLoadDataForBFL = true;
        }
        // added by rohit gupta: this criteria to stop the payload for BFL in case of merchant 
        // System.Label.StopSendPayLoadDataForBFL  == String.ValueOf(aggregatorFlag)&& System.Label.StopSendPayLoadDataForBFL  == String.ValueOf(producerFlag)
        if(merchantpayLoadMap != NULL && System.Label.StopSendPayLoadDataForMerchant =='False'  
           && !isPartnerMerchant(newData) && !stopSendPayLoadDataForBFL){
               if((validateForUpdate && isPublishRequiredForUpdate(newData, oldData, merchantpayLoadMap, theFields)) || !validateForUpdate ){
                    thePayLoad = payLoadGenerator(newData, oldData, merchantpayLoadMap, theFields, 'Merchant');// added String businessObjectName
                    if(String.isNotBlank(thePayLoad)) getAWSData(thePayLoad, Trigger.isExecuting);                  
               }  
        }
        if(productPayLoadMap !=NULL && System.Label.StopSendPayLoadDataForProductAccount =='False' 
           && !isPartnerMerchant(newData)){
              if((validateForUpdate && isPublishRequiredForUpdate(newData, oldData, productPayLoadMap, theFields)) || !validateForUpdate ){
                    thePayLoad = payLoadGenerator(newData, oldData, productPayLoadMap, theFields, 'ProductAccount');// added String businessObjectName
                    if(String.isNotBlank(thePayLoad)) getAWSData(thePayLoad, Trigger.isExecuting);   
              }
               System.debug('Here we go :::::::: productPayLoadMap : '+productPayLoadMap+' validateForUpdate : '+validateForUpdate+' newData : '+newData+' oldData : '+oldData+' productPayLoadMap : '+productPayLoadMap+' theFields :'+theFields+' +thePayLoad : '+thePayLoad);
        }
        if(payloadActionMap !=NULL && payloadActionMap !=merchantpayLoadMap && payloadActionMap !=productPayLoadMap ){
            System.debug('::::payloadActionMap' +payloadActionMap);
            System.debug('::::merchantpayLoadMap' +merchantpayLoadMap);
            System.debug('::::productPayLoadMap' +productPayLoadMap);
            
            if((validateForUpdate && isPublishRequiredForUpdate(newData, oldData, payloadActionMap, theFields)) || !validateForUpdate ){
                thePayLoad = payLoadGenerator(newData, oldData, payloadActionMap, theFields, '');// added String businessObjectName
                System.debug('::-thePayLoad::'+thePayLoad);
                if(String.isNotBlank(thePayLoad)) getAWSData(thePayLoad, Trigger.isExecuting);  
            }
        } 
    }
    
    public static boolean isPublishRequiredForUpdate(Sobject newData, Sobject oldData,PayloadActMap__mdt payloadActionMap, Set<String> theFields){
        Boolean sendPayLoad = false;
        
        /** Added for SFI-1060 - Coding Challenge - Currently not working */
        String payloadBody = awsConsumerPayload.Payload__c;
		System.debug('>>>>>>>payloadBody>>>>>>'+payloadBody);        
        if(String.isNotBlank(payloadBody)){
            /** Map to store the payload coming from ESB */
            Map<String, Object> payLoadMap = (Map<String,Object>)JSON.deserializeUntyped(payloadBody);
            
            /** Map to store field mapping comming from custom metadata */
            Map<String,Object> JSONFieldMap = (Map<String,Object>)JSON.deserializeUntyped(payloadActionMap.JsonMap__c);
            
            /** Map to store the payload key & Object API Name */
            Map<String,String> sfFieldMapping = new Map<String,String>();
            for(String key : JSONFieldMap.keySet()){
                sfFieldMapping.put(key,((String)JSONFieldMap.get(key)).split(',')[0]);
            }
            
            /** Map to store the current_Data coming from ESB */
            Map<String, Object> currentDataMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(payLoadMap.get('current_data')));
            for(String currentDataKey : currentDataMap.keySet()){
                //System.debug('>>>>>>>currentDataKey>>>>>>'+currentDataKey);
                //System.debug('>>>>>>>(String)currentDataMap.get(currentDataKey)>>>>>>'+(String)currentDataMap.get(currentDataKey));
                
                //System.debug('>>>>>>>sfFieldMapping.get(currentDataKey)>>>>>>'+sfFieldMapping.get(currentDataKey));
                //System.debug('>>>>>>>newData.get(sfFieldMapping.get(currentDataKey))>>>>>>'+newData.get(sfFieldMapping.get(currentDataKey)));
                if((String)currentDataMap.get(currentDataKey) != newData.get(sfFieldMapping.get(currentDataKey))){
                    sendPayLoad = true;
                    //return sendPayLoad;
                    //break;
                }
            }
            //JsonMap__c 
        }
        
        /** END SFI-1060 */
        
        
        
        System.debug('payloadActionMap.FieldsCheck__::::'+payloadActionMap.FieldsCheck__c.split(','));
        for(String each : payloadActionMap.FieldsCheck__c.split(',')){ 
            if(String.isNotBlank(each) && theFields.contains(each)){ 
                SYstem.debug(' theFields.contains(each):::::'+ theFields.contains(each));
                SYstem.debug('oldData.get(each)::::'+oldData.get(each));
                SYstem.debug('new.get(each)::::'+newData.get(each));
               if(newData.get(each) != oldData.get(each)){
                    sendPayLoad = true;
                    break;
                }
            }
        } 
        return sendPayLoad;
    }
    
    //------------------------- /* End - multi product change*/ -----------------------------//
    
    /*added string parameter in oldSendPayLoadData - businessObjectName*/
    public static void oldSendPayLoadData(Sobject newData, Sobject oldData, String sobName, String payLoadSobName,boolean multiproductEnabled){ 
        Trigger_Switch__c IntSwitchObj = Trigger_Switch__c.getValues(sobName);
        system.debug('@@@@@@@@@@@@@@@@@@ int '+System.isBatch() +' kkk '+ isTriggerExecuting);
        if(IntSwitchObj != null && IntSwitchObj.Publisher_Call__c){
            System.debug('System.isBatch() ****** '+System.isBatch());
            System.debug('System.isFuture() ****** '+System.isFuture());
            System.debug('Trigger.isExecuting ****** '+Trigger.isExecuting);
            if(/** Added for testing from batch */System.isBatch() || /** */(System.isBatch() && isTriggerExecuting) || AWSConsumerBatch.isFinishExecuted 
               || (!System.isBatch() && ((Trigger.isExecuting && !System.isFuture()) || (!Trigger.isExecuting && System.isFuture()))) || LeadConvertBatch.isLeadConversionBatch || SettlementStatusSyncBatch.isSettlementActivationBatch || PublishExistingOppotunityWebsiteBatch.isExecutionFinished || isFutureUpdate){
                   system.debug('###### send data entry ');
                   Set<String> theFields = AWSConsumerBatch.getFieldSet(sobName);
                   SYstem.debug('theFields:::123::'+theFields);
                   String action = getActionName(newData, sobName);
                   System.debug('action ::line::222::'+ action);
                   if(String.isNotBlank(action)){
                       
                       List<PayloadActMap__mdt> queriedList = null;
                       PayloadActMap__mdt payloadActionMap=NULL;
                       //queriedList = IntegrationUtility.getPayLoadMap(action, payLoadSobName, '');
                       
                       queriedList = IntegrationUtility.getPayLoadMap(action, payLoadSobName, '');
                       System.debug('queriedList '+queriedList);
                       PayloadActMap__mdt merchantpayLoadMap;
                       PayloadActMap__mdt productPayLoadMap;
                       if(queriedList.size() > 0 && queriedList !=NULL){
                           for(PayloadActMap__mdt payloadMeta : queriedList){
                               if((payloadMeta.Business_Object__c == 'ProductAccount' && payloadMeta.Business_Object__c !=NULL) ){//|| payloadMeta.Business_Object__c.contains('ProductAccount')
                                   productPayLoadMap = payloadMeta;
                               }
                               else if(payloadMeta.Business_Object__c == 'Merchant' ){//|| payloadMeta.Business_Object__c.contains('Merchant')
                                   merchantpayLoadMap = payloadMeta;
                               }else if (payloadMeta.Business_Object__c != 'Merchant' && payloadMeta.Business_Object__c != 'ProductAccount'){
                                   payloadActionMap = payloadMeta;
                               }
                           }
                       }else{
                           payloadActionMap = queriedList[0];
                       }
                       if(!queriedList.isEmpty()){
                           IntegrationUtility.payLoadUtilMap.put(queriedList[0].Action__c, queriedList[0]);
                           System.debug('IntegrationUtility.payLoadUtilMap-->'+IntegrationUtility.payLoadUtilMap);
                           String thePayLoad = '';
                           
                           if((isTriggerExecuting && isInsert) || (Trigger.isExecuting && Trigger.isInsert) || AWSConsumerBatch.isFinishExecuted || LeadConvertBatch.isLeadConversionBatch || SettlementStatusSyncBatch.isSettlementActivationBatch || PublishExistingOppotunityWebsiteBatch.isExecutionFinished || isFutureUpdate){
                               system.debug('###### send data action batch '+merchantpayLoadMap);
                               /******* checking for bug Saksham*******/
                                //if(action == 'create' && payLoadSobName == 'Lead') return;
                               /***** checking for bug *******/
                               SendPayLoadDataForMultiProduct(newData,oldData,merchantpayLoadMap,productPayLoadMap,payloadActionMap,theFields, false);
                           }else if(((Trigger.isExecuting && Trigger.isUpdate) || (isTriggerExecuting && isUpdate)) && newData != null && oldData != null){
                               System.debug('merchantpayLoadMap-->'+merchantpayLoadMap);
                               System.debug('productPayLoadMap-->'+productPayLoadMap);
                               System.debug('payloadActionMap-->'+payloadActionMap);
                               System.debug('theFields-->'+theFields);
                               SendPayLoadDataForMultiProduct(newData,oldData,merchantpayLoadMap,productPayLoadMap,payloadActionMap,theFields, true);
                           }else if((Trigger.isExecuting && Trigger.isDelete) || (isTriggerExecuting && isDelete)){
                               SendPayLoadDataForMultiProduct(newData,oldData,merchantpayLoadMap,productPayLoadMap,payloadActionMap,theFields, false);
                               
                           }
                       }                       
                   }
               }
        }
    }
    
    public static boolean isPartnerMerchant(Sobject newData){
        for(String each : String.valueOf(newData.get('Payload_Header__c')).split(',')){
                String theStr = each.subStringAfter(':'); 
                String headerAttrKey = each.subStringBefore(':');
                Object headerAttrValue = theStr.startsWith('static;') ? theStr.subStringAfter('static;'): newData.get(theStr);
            System.debug('theStr-->'+theStr);
            System.debug('headerAttrKey-->'+headerAttrKey);
            System.debug('headerAttrValue-->'+headerAttrValue);
                 if(headerAttrKey =='business_object' && headerAttrValue =='Partner') return true;
        }
        return false;
    }
    
    
    public static String payLoadGenerator(Sobject newData, Sobject oldData, PayloadActMap__mdt thePayLoadMap, Set<String> theFields, string businessObjectName){        
        SYstem.debug('payloadName>>>>>>>>'+businessObjectName+'_'+thePayLoadMap.Action__c);
        
        Map<String, Object> payLoadMap = new Map<String, Object>();
        payLoadMap.put('producer', 'Salesforce');   
        
        payLoadMap.put('action', (Trigger.isExecuting && Trigger.isDelete) || (isTriggerExecuting && isDelete) ? thePayLoadMap.Delete_Action__c : thePayLoadMap.Action__c);                              
        
        payLoadMap.put('current_data', getObjectData(newData, thePayLoadMap, theFields));
        payLoadMap.put('old_data', getObjectData(oldData, thePayLoadMap, theFields));
        payLoadMap.put('timestamp', System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));
        
        
        String test_mid=null;
        String prod_mid=null;
        if(newData != null && theFields.contains('Payload_Header__c') && newData.get('Payload_Header__c') != null){   
            for(String each : String.valueOf(newData.get('Payload_Header__c')).split(',')){
                String theStr = each.subStringAfter(':'); 
                SYstem.debug('theStr:::::'+theStr);
                String headerAttrKey = each.subStringBefore(':');
                Object headerAttrValue = theStr.startsWith('static;') ? theStr.subStringAfter('static;'): newData.get(theStr);
                System.debug('headerAttrKey::::headerAttrValue'+headerAttrKey +':'+headerAttrValue);
                System.debug('headerAttrValue::::'+headerAttrValue);
                if(headerAttrKey == 'identifier' && businessObjectName =='Merchant'){
                 //   Do no Add identifier for Merchant Payloads. 
                }
                else{
                  payLoadMap.put(headerAttrKey, headerAttrValue);  
                }
                if(headerAttrKey=='test_mid')test_mid=String.ValueOf(headerAttrValue);
                if(headerAttrKey=='mid')prod_mid=String.ValueOf(headerAttrValue);
                System.debug('businessObjName:::Line615'+businessObjectName);

                if(headerAttrKey =='business_object' && 
                   ((headerAttrValue =='Merchant' && businessObjectName =='ProductAccount') 
                    || (headerAttrValue =='ProductAccount' && businessObjectName =='Merchant'))){
                        payLoadMap.put(headerAttrKey, businessObjectName );
                         /*if(businessObjectName =='Merchant'){
                            if(newData.get('Merchant_Id__c')  !=null ) payLoadMap.put('test_mid', newData.get('Merchant_Id__c') );
                            if(newData.get('Prod_Merchant_Id__c') !=null) payLoadMap.put('mid', newData.get('Prod_Merchant_Id__c') );
                        }*/
                        System.debug('Overriding Business Object as Product. Account for Merchant LEadtype'+headerAttrKey + ' : '+businessObjectName);
                } else if(headerAttrKey =='business_object' && ((headerAttrValue =='Merchant' || headerAttrValue =='ProductAccount') && businessObjectName ==''))
                {
                    //System.debug(':::: On Line 627::::'+headerAttrKey+'::'+headerAttrValue+'::'+businessObjectName);
                    //payLoadMap.put(headerAttrKey, headerAttrValue );
                    return null;// Kunal : 11th Oct ::commented this line and added above line for Testing purpose.
                    } // To handle sending of Payload for Merchant OR ProductAccount.
                    
            }
            if(businessObjectName =='ProductAccount'){
                //Do not publish MID information in ProductAccount Payload.
                if(payLoadMap.containskey('test_mid'))  payLoadMap.remove('test_mid');
                if(payLoadMap.containskey('mid'))  payLoadMap.remove('mid');
            }else if(businessObjectName =='Merchant'){ //|| businessObjectName =='Partner'){
                //Add MID/TestMID information in Merchant Payload if its missing
                //Ideally this should not be executed unless this is missed adding in payload_header__C in each object. 
                //if(!payLoadMap.containskey('test_mid'))  payLoadMap.put('test_mid', test_mid);
               // if(!payLoadMap.containskey('mid'))  payLoadMap.put('mid', prod_mid);
                
                if(payLoadMap.containskey('merchant_account_identifier'))  payLoadMap.remove('merchant_account_identifier');
                if(!payLoadMap.containskey('test_mid'))  payLoadMap.put('test_mid',  newData.get('Merchant_Id__c'));
                if(!payLoadMap.containskey('mid'))  payLoadMap.put('mid', newData.get('Prod_Merchant_Id__c'));
            }


        }   
        if((Trigger.isExecuting && Trigger.isDelete) || (isTriggerExecuting && isDelete)){
            payLoadMap.put('action',thePayLoadMap.Delete_Action__c);
        }
        system.debug('##### payload gen payLoadMap2 '+payLoadMap);
        return JSON.serialize(payLoadMap);                  
    }
    
    public static Map<String, Object> getObjectData(Sobject theData, PayloadActMap__mdt thePayLoadMap, Set<String> theFields){
        Map<String, Object> fieldMapToReturn = new Map<String, Object>();
        system.debug('######## theData '+theData);
        if(thePayLoadMap != null && theData != null){
            
            if(String.isNotBlank(thePayLoadMap.JSONMapPub__c)){
                 SYstem.debug('thePayLoadMap.JSONMapPub__c:::741::'+thePayLoadMap.JSONMapPub__c);
                Map<String, String> jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSONMapPub__c, Map<String, String>.class);
                
                if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){                    
                    for(String each : jsonFieldMap.keySet()){ 
                        String jsonFieldValue = jsonFieldMap.get(each);
                        if(String.isNotBlank(jsonFieldValue)){
                            for(String eachStr : jsonFieldValue.split(';')){
                                String fieldAPI = eachStr.subStringBefore(',');
                                if(String.isNotBlank(fieldAPI)){ 
                                    if(theFields.contains(fieldAPI)){                       
                                        fieldMapToReturn.put(each, theData.get(fieldAPI));
                                        break;
                                    }                                    
                                }
                            }
                        }else{
                            fieldMapToReturn.put(each, null);
                        }                                              
                    }
                }
            }
            
            if(String.isNotBlank(thePayLoadMap.JSONfieldMap__c)){
                
                Map<String, String> jsonFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSONfieldMap__c, Map<String, String>.class);
                
                if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){                    
                    for(String each : jsonFieldMap.keySet()){ 
                        String jsonFieldValue = jsonFieldMap.get(each);
                        if(String.isNotBlank(jsonFieldValue)){
                            for(String eachStr : jsonFieldValue.split(';')){
                                String fieldAPI = eachStr.subStringBefore(',');
                                system.debug('--> JSON Field Map -->  '+theData+' --  '+fieldAPI);
                                system.debug('--> JSON Field Map -->  '+theFields+' --  '+theFields);
                                if(String.isNotBlank(fieldAPI)){ 
                                    if(theFields.contains(fieldAPI) && theData.get(fieldAPI) != null){                       
                                        system.debug('--> JSON Field Map -->  '+theData+' --  '+fieldAPI);
                                        String strData = String.valueOf(theData.get(fieldAPI));                                        
                                        system.debug('--> JSON Field Map fieldAPI --> '+fieldAPI);
                                        map<string,List<object>> newSetMap = new map<string,List<object>>();
                                        if(fieldAPI=='Page_Details__c'){
                                            system.debug('--> JSON Field string --> '+string.valueOf(theData.get(fieldAPI)));
                                            //List<Map<string,object>> objMapList = (List<Map<string,object>>)JSON.deserializeUntyped(string.valueOf(theData.get(fieldAPI)));
                                            //system.debug('--> fieldAPI data dmapList   --> '+objMapList);
                                            List<object> objList = (List<object>)JSON.deserializeUntyped(string.valueOf(theData.get(fieldAPI)));
                                            system.debug('--> fieldAPI data deserialize  --> '+objList);                                            
                                            newSetMap.put(fieldAPI,objList);
                                            system.debug('--> fieldAPI new data deserialize  --> '+newSetMap.get(fieldAPI));
                                            
                                        }
                                        if(!newSetMap.isEmpty()){
                                            fieldMapToReturn.put(each,newSetMap.get(fieldAPI));
                                            system.debug('--> JSO joinerMap -->  '+fieldMapToReturn);
                                            break;
                                        }else{                                        
                                            fieldMapToReturn.put(each, (Map<String, Object>)JSON.deserializeUntyped(strData));
                                            system.debug('--> fieldMapToReturn -->  '+fieldMapToReturn);
                                            break;
                                        }
                                    }                                    
                                }
                            }
                        }else{
                            fieldMapToReturn.put(each, null);
                        }                                              
                    }
                }
            }
            
            if(String.isNotBlank(thePayLoadMap.LookUpField__c)){
                
                Map<String, String> lookUpFieldMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.LookUpField__c, Map<String, String>.class);
                SYstem.debug('lookUpFieldMap:::741::'+lookUpFieldMap);
                if(lookUpFieldMap != null && !lookUpFieldMap.isEmpty()){                    
                    for(String each : lookUpFieldMap.keySet()){
                        if(!fieldMapToReturn.containsKey(each)){ 
                            String lookUpField = lookUpFieldMap.get(each);
                            if(String.isNotBlank(lookUpField)){
                                
                                for(String eachStr : lookUpField.split(';')){
                                    String lookUpQueryStr = eachStr.subStringAfter(',');
                                    String lookUpFieldAPI = eachStr.subStringBefore(',');  
                                    
                                    if(theFields.contains(lookUpFieldAPI)){                                              
                                        if(theData.get(lookUpFieldAPI) != null){
                                            String queryStr = 'SELECT Id, ' + lookUpQueryStr.subStringAfter(':') + ' FROM ' + lookUpQueryStr.subStringBefore(':') + ' WHERE Id =\'' + theData.get(lookUpFieldAPI) + '\'';
                                            List<Sobject> queriedList =Database.query(queryStr);
                                            if(!queriedList.isEmpty()){
                                                fieldMapToReturn.put(each, queriedList[0].get(lookUpQueryStr.subStringAfter(':')));
                                                break;                                
                                            }                                                      
                                        }else{
                                            fieldMapToReturn.put(each, null);
                                        }
                                    }else{
                                        fieldMapToReturn.put(each, null);
                                    }
                                } 
                            }
                        }                                                        
                    }
                }
            }
            
            if(String.isNotBlank(thePayLoadMap.JsonMapComp__c)){
                
                Map<String, String> complexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMapComp__c, Map<String, String>.class);
                System.debug('complexNodeMap:::::::'+complexNodeMap);
                if(complexNodeMap != null && !complexNodeMap.isEmpty()){
                    
                    for(String each : complexNodeMap.keySet()){   
                        System.debug('each::::::::'+each);
                        Map<String, Object> complexDataMap = new Map<String, Object>();
                        String complexNodeField = complexNodeMap.get(each);
                        if(String.isNotBlank(complexNodeField)){
                            for(String eachStr : complexNodeField.split(';')){                            
                                if(String.isNotBlank(eachStr.subStringAfter(':')) ){
                                    SYstem.debug('eachStr.subStringAfter:::::::'+eachStr.subStringBefore(':'));
                                    complexDataMap.put(eachStr.subStringBefore(':'), theData.get(eachStr.subStringAfter(':').subStringBefore(',')));
                                    System.debug('complexDataMap::::::::::'+complexDataMap.keySet());
                                    System.debug('complexDataMap::::::::::'+complexDataMap);   
                                }
                            } 
                        }                       
                        fieldMapToReturn.put(each, complexDataMap);                    
                    }
                }
            }
            
            if(String.isNotBlank(thePayLoadMap.JSON_Map_sub_key_complex__c)){
                Map<String, Object> subComplexNodeMap = (Map<String, Object>)JSON.deserializeUntyped(thePayLoadMap.JSON_Map_sub_key_complex__c);
                if(subComplexNodeMap != null && !subComplexNodeMap.isEmpty()){
                    for(String each : subComplexNodeMap.keySet()){
                        Map<String, String> complexKeyFieldMap = new Map<String, String>();
                        object metaObject = subComplexNodeMap.get(each);
                        String allFields = JSON.serializePretty(metaObject).remove('"');
                        String finalAllFields = allFields.remove(' ');
                        system.debug('######### finalAllFields '+finalAllFields);
                        if(String.isNotBlank(finalAllFields)){
                            for(String eachStr : finalAllFields.split(';')){
                                complexKeyFieldMap.put(eachStr.subStringBefore('-'), eachStr.subStringAfter('-'));
                            }
                            system.debug('######### complexKeyFieldMap '+complexKeyFieldMap);
                        }
                        if(theData.get('Name') == 'onboarding_config'){
                            
                            Map<String,Map<String,Object>> configObjMap = New Map<String,Map<String,Object>>();
                            string firstparam = complexKeyFieldMap.get('onboarding_config').subStringBefore('__');
                            system.debug('######### firstparam '+firstparam);
                            Map<String,Object> configChildObjMap = New Map<String,Object>();
                            string secondParam_1 = complexKeyFieldMap.get('onboarding_config').subStringAfter('__');
                            string secondParam_2 = secondParam_1.subStringBefore(':');
                            String fieldAPI_1 = complexKeyFieldMap.get('onboarding_config').subStringAfter(':');
                            String fieldAPI_2 = fieldAPI_1.subStringBefore(',');
                            configChildObjMap.put(secondParam_2,theData.get(fieldAPI_2));
                            system.debug('######### configChildObjMap '+configChildObjMap);
                            configObjMap.put(firstparam,configChildObjMap);
                            system.debug('######### configObjMap '+configObjMap);
                            fieldMapToReturn.put('config',configObjMap);
                            system.debug('######### fieldMapToReturn '+fieldMapToReturn);
                        }if(theData.get('Name') == 'bank_detail_config'){
                            
                            Map<String,Object> configObjMap = New Map<String,Object>();
                            
                            string param = complexKeyFieldMap.get('bank_detail_config').subStringBefore(':');
                            String fieldAPI = complexKeyFieldMap.get('bank_detail_config').subStringAfter(':');
                            String fieldAPI_2 = fieldAPI.subStringBefore(',');
                            
                            configObjMap.put(param,theData.get(fieldAPI_2));
                            system.debug('######### configObjMap2 '+configObjMap);
                            fieldMapToReturn.put('config',configObjMap);
                            system.debug('######### fieldMapToReturn2 '+fieldMapToReturn);
                        }if(theData.get('Name') == 'login_config'){
                            
                            Map<String,Object> configObjMap = New Map<String,Object>();
                            
                            string param = complexKeyFieldMap.get('login_config').subStringBefore(':');
                            String fieldAPI = complexKeyFieldMap.get('login_config').subStringAfter(':');
                            String fieldAPI_2 = fieldAPI.subStringBefore(',');
                            
                            configObjMap.put(param,theData.get(fieldAPI_2));
                            system.debug('######### configObjMap3 '+configObjMap);
                            fieldMapToReturn.put('config',configObjMap);
                            system.debug('######### fieldMapToReturn 3 '+fieldMapToReturn);
                        }
                        
                    }
                }
            }
        }  
        
        return fieldMapToReturn;
    } 
    public static void getAWSData(String thePayLoad, Boolean isTriggerExecuting){
        System.debug('lineno635:::::'+thePayLoad);
        if(!isTriggerExecuting){  
            if(!test.isRunningTest()){
                HttpResponse response = AWSUtility.getAWSData('SendMessage', null, Blob.valueOf(thePayLoad), '', null);            
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>' + response.getStatusCode() + '_____>>>>>>>>>>______________?>>>>>>>>' + response.getBody() + '---->>>>>>>>---------' + thePayLoad);
                insertPayloadLog(response, thePayLoad);
            }
        }else{
            System.debug('future limit'+Limits.getLimitFutureCalls());
            
            getAWSData(thePayLoad);
        }
    }  
    
    @future(callout = true)
    public static void getAWSData(String thePayLoad){ 
        System.debug('lineno645:::::'+thePayLoad);
        if(!test.isRunningTest()){
            HttpResponse response = AWSUtility.getAWSData('SendMessage', null, Blob.valueOf(thePayLoad), '', null);
            System.debug('>>>>>>>>>>>>>>>>>>>>>>>' + response.getStatusCode() + '_____>>>>>>>>>>______________?>>>>>>>>' + response.getBody() + '---->>>>>>>>---------' + thePayLoad);
            insertPayloadLog(response, thePayLoad);
        }
    }
    
    public static List<Payload_Log__c> logList = new List<Payload_Log__c>();
    
    public static void insertPayloadLog(HttpResponse response, String thePayload){  
        
        System.debug('response:::12::'+response);
        Payload_Log__c theLog = new Payload_Log__c();
        theLog.Process__c = 'Salesforce Publisher';
        theLog.Payload__c = thePayload; 
        theLog.Producer__c = 'Salesforce';
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(thePayload);
        Map<String,Object> currentDataMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(dataMap.get('current_data')));
        //theLog.Prod_MID__c = (Integer)currentDataMap.get('identifier');
        //theLog.Business_Object__c ='qwert';
        if(response != null){
            theLog.Status__c = response.getStatusCode() == 200 ? 'SUCCESS' : 'ERROR';
            theLog.Exception__c = response.getStatusCode() + '\n\n' + response.getBody(); 
        }else{
            theLog.Status__c = null;
            theLog.Exception__c = null;
        }
        logList.add(theLog);
        if(!System.isBatch() && !logList.isEmpty() && logList.size() == 1) Database.insert(logList, false);
    } 
}