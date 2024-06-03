public class CarePanelUtility {
    
    @Future(Callout=true)
    public static void preparepayload(list<Id> lstCaseId,string devName,string strNotify){
        System.debug('>>>>>>>>>>lstCaseId>>>>>>>>>>'+lstCaseId);
        //declare variables
        PayloadActMap__mdt objPayload;
        list<LP_HTTP_Publisher__c> lstPub = new list<LP_HTTP_Publisher__c>();
        
        //get payload data from custom metadata which needs to be publish
        map<string,PayloadActMap__mdt> mapOfObjectVsPayload = CareUtility.getPayloadData('MerchantCare');
        if(mapOfObjectVsPayload != NULL && mapOfObjectVsPayload.size()>0 && mapOfObjectVsPayload.containsKey('Case'))
            objPayload = mapOfObjectVsPayload.get('Case');
        //get Integration settings from custom metadata
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c 
                                                    FROM Integration_Setting__mdt 
                                                    WHERE DeveloperName =:devName];
        
        //get AccessToken to publish the data in care panel
        string strAccessToken;
        //If(!Test.isRunningTest())
            strAccessToken = getAccessToken();
        //else
        //    strAccessToken = '544555';
        system.debug('strAccessToken======='+strAccessToken);
        
        //get Case Data
        if(objPayload != NULL && objPayload.Field_To_Query__c != NULL){
            string strquery = 'SELECT id,'+objPayload.Field_To_Query__c+' FROM Case WHERE ID IN:lstCaseId';
            Map<String, String> mapOfPayloadStructure = (Map<String, String>)JSON.deserialize(objPayload.JSONMapPub__c, Map<String, String>.class);
        
            for(Case eachCase : Database.query(strquery)){
                 system.debug('eachCase======='+eachCase);
                string strPayload = prepareRequestBody(eachCase,mapOfPayloadStructure,strNotify);
                LP_HTTP_Publisher__c objPub = sendDataToCarePanel(strPayload,eachCase,strAccessToken,insList);
                lstPub.add(objPub);
                //system.debug('Each case ticket Id======='+objPub.CaseTicketId__c);
            }            
        }
        system.debug('lstPub======='+lstPub);
        if(lstPub != NULL && lstPub.size()>0)
           insert lstPub;
    }
    public static string prepareRequestBody(Case objCase, Map<String, String> mapOfPayload,string strNotify){
        map<string,object> mapOfPublishPayload = new map<string,object>();
        System.debug('mapOfPayload========'+mapOfPayload);
        System.debug('objCase========'+objCase);
        if(objCase != null){
            if(mapOfPayload != NULL && mapOfPayload.size()>0){
                for(string eachKey : mapOfPayload.keyset()){
                    if(mapOfPayload.get(eachKey).contains('.'))
                        mapOfPublishPayload.put(eachKey,objCase.getSObject(mapOfPayload.get(eachKey).substringBefore('.')).get(mapOfPayload.get(eachKey).substringAfter('.')));
                    else{
                        if(eachKey == 'expectedClosureDate'){
                            if(objCase.get(mapOfPayload.get(eachKey)) != NULL){
                                DateTime dt = DateTime.ValueOf(objCase.get(mapOfPayload.get(eachKey)));
                                string strDtime = dt.format('yyyy-MM-dd HH:mm:ss','Asia/Kolkata');
                                mapOfPublishPayload.put(eachKey,(Object)strDtime);
                            }
                            mapOfPublishPayload.put(eachKey,objCase.get(mapOfPayload.get(eachKey)));
                        }
                        else
                            mapOfPublishPayload.put(eachKey,objCase.get(mapOfPayload.get(eachKey)));
                    }
                    
                }
                if(String.isNotBlank(strNotify))
                    mapOfPublishPayload.put('notify',strNotify); //'TAT_EXCEEDED'
                System.debug('mapOfPublishPayload:: '+mapOfPublishPayload);
            }
        }
        return JSON.serialize(mapOfPublishPayload);
    }
    
    
    public static string getAccessToken(){
        
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(Label.CarePanelAuthToken);
        System.debug('>>>>>>>>>>Label.CarePanelAuthToken>>>>>>>>>>'+Label.CarePanelAuthToken);
        If(!Test.isRunningTest()){
        	resp = http.send(req);
            System.debug('>>>>>>>>>>resp>>>>>>>>>>'+resp.getBody());
            //system.debug('resp======'+resp.getStatus());
            map<string,Object> mapOfResponse = (map<string,Object>)JSON.deserializeUntyped(resp.getBody());
            system.debug('mapOfResponse======'+mapOfResponse);
            return String.ValueOf(mapOfResponse.get('access_token'));
        }         
        else return '3456789';
   }
    
    
    public static LP_HTTP_Publisher__c sendDataToCarePanel(string strPayload,Case objCase,string strAccessToken,
                                                           list<Integration_Setting__mdt> insList){
        
        system.debug('>>>>>>>>>>strPayload>>>>>>>>>>'+strPayload);  
        system.debug('>>>>>>>>>>objCase>>>>>>>>>>'+objCase);  
        system.debug('>>>>>>>>>>strAccessToken>>>>>>>>>>'+strAccessToken);  
        system.debug('>>>>>>>>>>insList>>>>>>>>>>'+insList);                                                       
        LP_HTTP_Publisher__c objHTTP;
        Map<String,String> attachmetDataMap = new Map<String,String>();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        if(insList!= null && insList.size()>0){
            string strEndPointURL = '';
            HttpRequest req = new HttpRequest();
            req.setMethod(insList[0].Method__c);
            if(objCase.TicketId__c != NULL)
                strEndPointURL = insList[0].EndPointUrl__c + objCase.TicketId__c;
            else if(objCase.Parent_Case__c != NULL && objCase.Parent_Case__r.TicketId__c != NULL)
                strEndPointURL = insList[0].EndPointUrl__c + objCase.Parent_Case__r.TicketId__c;
                System.debug('>>>>>>>>>>strEndPointURL>>>>>>>>>>'+strEndPointURL);
            req.setEndPoint(strEndPointURL);
            if(String.isNotBlank(insList[0].Headers__c)){
                for(String each : insList[0].Headers__c.split(',')){
                    if(each.subStringBefore(':') == 'authorization'){
                        string value = each.subStringAfter(':') + ' '+strAccessToken;
                        req.setHeader(each.subStringBefore(':'),value);
                    }
                    else
                        req.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
                }
            }
            
            req.setBody(strPayload);
            System.debug('req 1>>>'+req);
            if(!Test.isRunningTest())
                resp = http.send(req);
        }
        System.debug('>>>>>>>>>>resp API Call>>>>>>>>>>'+resp.getBody());
        //System.debug('resp 2>>>'+resp.getBodyDocument());
        if(strPayload.contains('document')){
            Map<String, Object> attachmentdataMap = (Map<String, Object>)JSON.deserializeUntyped(strPayload);
            String s = JSON.serialize(attachmentdataMap.get('document'));
            system.debug('s=='+s);
            Map<String, Object> obj = (Map<String, Object>)JSON.deserializeUntyped(s);
            List<Case> caseList = [SELECT Id,Failed_Attachment_Count__c,Attachment_Name__c FROM Case where Id=:objCase.Id];
            system.debug('caseList===='+caseList);
            system.debug('objCase============'+objCase);
            if(obj!=null){
            if(resp.getStatusCode() == 200){
                if(String.valueOf(obj.get('name')) != null){
                    caseList[0].Attachment_Name__c = String.valueOf(obj.get('name'));
                }
                
                //caseList[0].Failed_Attachment_Count__c = integer.valueOf(objCase.Failed_Attachment_Count__c)+1;
            }else{
                caseList[0].Attachment_Name__c = String.valueOf(obj.get('name'));
                caseList[0].Failed_Attachment_Count__c = integer.valueOf(objCase.Failed_Attachment_Count__c)+1;
                List<ContentDocument> ContentDocuments = [SELECT Id FROM ContentDocument WHERE Id =: String.valueOf(obj.get('id'))];
                System.debug('ContentDocuments::'+ContentDocuments);
                if(ContentDocuments.size() > 0){
                    delete ContentDocuments;
                }
            }
        }
            system.debug('caseList============'+caseList);
            update caseList;
        }
        //create http publisher records
        SalesforceDebugLogInitiator__c  logIntiator = SalesforceDebugLogInitiator__c.getValues('Onecare Publisher Log');
        if(logIntiator.IsActive__c){
            objHTTP = createHTTPPublisher(strPayload,'Case',resp.getBody(), objCase.Id);
        } 
        return objHTTP;
    } 
    
    public static LP_HTTP_Publisher__c createHTTPPublisher(string reqbody,string ObjectName,string response, Id caseId){
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();
        objHTTPPublisher.LP_Request_body__c = reqbody;
        objHTTPPublisher.Related_Object__c = ObjectName;
        objHTTPPublisher.LP_Response__c = response;
        objHTTPPublisher.case__c = caseId;
        
        return objHTTPPublisher;
        
    }
    
    public static LP_HTTP_Publisher__c createHTTPPublisher(string reqbody,string ObjectName,string response, Id caseId,String processName){
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();
        objHTTPPublisher.LP_Request_body__c = reqbody;
        objHTTPPublisher.Related_Object__c = ObjectName;
        objHTTPPublisher.LP_Response__c = response;
        objHTTPPublisher.case__c = caseId;
        objHTTPPublisher.LP_ProcessName__c  = processName;
        return objHTTPPublisher;
        
    }
}