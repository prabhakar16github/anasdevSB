public class KnowlarityUtility {
    
     /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     prepare the list of IVR call payload
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    2-Jan-19       Eitika Verma          created
    */
    public static string prepareIVRPayload(string callType,list<Case> lstCase,string recordtype){
        //declare variables
        Map<String, String> jsonFieldMap;
        Map<String, String> jsonComplexMap;
        Map<String,String> jsonESBPub;
        Map<String, Object> payLoadMap = new Map<String, Object>();
        //list<Map<String, Object>> lstOfIVRCalls = new list<Map<String, Object>>();
        
        //get the payload info from custom metadata
        List<knowlarityPayload__mdt> lstpayload = KnowlarityUtility.getPayLoadMap(callType); 
        
        if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].json_Pub__c != null && string.isNotBlank(lstpayload[0].json_Pub__c)){
            jsonFieldMap = (Map<String, String>)JSON.deserialize(lstpayload[0].json_Pub__c, Map<String, String>.class);
        }
        if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].jsonComplex__c != null && string.isNotBlank(lstpayload[0].jsonComplex__c)){
            jsonComplexMap = (Map<String, String>)JSON.deserialize(lstpayload[0].jsonComplex__c, Map<String, String>.class);
        }
        if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].jsonESB_pub__c != null && string.isNotBlank(lstpayload[0].jsonESB_pub__c)){
            jsonESBPub = (Map<String, String>)JSON.deserialize(lstpayload[0].jsonESB_pub__c, Map<String, String>.class);
        }

        
            if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){ 
                for(String each : jsonFieldMap.keySet()){
                    if(each == 'start_time'){
                        DateTime now = DateTime.now().addMinutes(15);
                        string startDateTime = Date.today().year()+'-'+ Date.today().month()+'-'+Date.today().day()+' '+now.hour() +':'+now.minute();  //2018-11-18 12:16
                        payLoadMap.put(each,(Object)startDateTime);
                    }
                    else if(each == 'end_time'){
                        string endDateTime = Date.today().year()+'-'+ Date.today().month()+'-'+Date.today().day()+' '+'23:00';  //2018-11-18 12:16
                        payLoadMap.put(each,(Object)endDateTime);
                    }    
                    else{
                        if(jsonFieldMap.get(each) != NULL){
                            payLoadMap.put(each,(Object)jsonFieldMap.get(each));
                        }
                        else{
                            payLoadMap.put(each,'None');
                        }
                    }
                        
                }
            }
            // passing metadata fields 
           String metadataNode = '';
           String metadatafields = ''; 
           if(jsonESBPub != null && jsonESBPub.size() >0){
              for(String key : jsonESBPub.keySet()){
                  metadataNode =  key;
                  if(jsonESBPub.get(key) != ''){
                    metadatafields = jsonESBPub.get(key);
                  } 
               } 
           }
          if(metadataNode !=  '' && metadatafields != '') {
             payLoadMap.put(metadataNode , (Object)metadatafields);
          }
            //for additional information
            string strAdditional = '';
            string strAdditionalNode = '';
            if(jsonComplexMap != NULL && jsonComplexMap.size()>0){        
                for(Case eachCase : lstCase){
                    for(string eachStr : jsonComplexMap.keyset()){
                        strAdditionalNode = eachStr;
                        if(jsonComplexMap.get(eachStr) != '' && jsonComplexMap.get(eachStr).contains(',')){
                            for(string eachInnerStr : jsonComplexMap.get(eachStr).split(',')){
                                if(eachInnerStr.contains(':')){
                                    system.debug('eachInnerStr'+eachInnerStr);
                                    strAdditional += eachCase.getSobject(eachInnerStr.substringBefore(':')).get(eachInnerStr.substringAfter(':')) + ',';
                                }
                                else{
                                    if(recordtype == 'Collection' && eachInnerStr == 'LP_Type_of_IVR__c'){
                                        strAdditional += eachCase.get('LP_Communication_Sub_Type__c') + ',';
                                    }
                                    else
                                       strAdditional += eachCase.get(eachInnerStr) + ',';
                                }
                            }
                           // if(String.isNotBlank(strAdditional)){
                           //     strAdditional += lstpayload[0].Base_URL__c;
                           //     strAdditional +=';';
                           // }
                            
                            if(String.isNotBlank(strAdditional) && strAdditional.endsWith(',') ){
                              strAdditional = strAdditional.substring(0 , strAdditional.length()-1);
                              strAdditional += ';';   
                            }
                        }
                    }
                    
                }
                
                if(String.isNotBlank(strAdditional)){
                    strAdditional = strAdditional.removeEnd(';');
                }
                system.debug('strAdditional======'+strAdditional);
                payLoadMap.put(strAdditionalNode,(Object)strAdditional);
            }
            //lstOfIVRCalls.add(payLoadMap);
        
        return JSON.serialize(payLoadMap);
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     prepare the list of Manual call payload
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    2-Jan-19       Eitika Verma          created
    */
   public static string prepareManualCallPayload(string callType,Case objCase,string recordtype){
        //declare variables
        Map<String, String> jsonFieldMap;
        Map<String, Object> payLoadMap = new Map<String, Object>();
        
        //get the phone number of agent or logged in user
        string agentPh = [SELECT Phone FROM User WHERE id=:userinfo.getUserId()].Phone;
         
        //get the payload info from custom metadata
        List<knowlarityPayload__mdt> lstpayload = KnowlarityUtility.getPayLoadMap(callType); 
        system.debug('lstpayload'+lstpayload);
        if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].json_Pub__c != null && string.isNotBlank(lstpayload[0].json_Pub__c)){
            jsonFieldMap = (Map<String, String>)JSON.deserialize(lstpayload[0].json_Pub__c, Map<String, String>.class);
        }
        if(objCase != null){
            if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){ 
                for(String each : jsonFieldMap.keySet()){
                    if(String.isNotBlank(each) && jsonFieldMap.get(each) != NULL && jsonFieldMap.get(each).contains(':')){
                        string strValue = jsonFieldMap.get(each);
                        if(objCase.getSobject(strValue.substringBefore(':')).get(strValue.substringAfter(':')) != NULL)
                            payLoadMap.put(each,objCase.getSobject(strValue.substringBefore(':')).get(strValue.substringAfter(':')));
                        else
                           payLoadMap.put(each,'None'); 
                    }
                    else if(String.isNotBlank(each) && jsonFieldMap.get(each) != NULL && jsonFieldMap.get(each).contains('__c')){
                        string strValue = jsonFieldMap.get(each);
                        if(objCase.get(strValue) != NULL){
                            if(recordtype == 'Collection' && strValue == 'LP_Type_of_IVR__c'){
                                payLoadMap.put(each,String.valueOf(objCase.get('LP_Communication_Sub_Type__c')));
                            }
                            else
                                payLoadMap.put(each,String.valueOf(objCase.get(strValue)));
                        }
                        else
                            payLoadMap.put(each,'None');
                    }
                    else if(jsonFieldMap.get(each) == '' && each == 'Agent_Mobile_Number'){
                        if(String.isNotBlank(agentPh) && !agentPh.startsWith('+91')){
                            agentPh = '+91'+agentPh;
                            payLoadMap.put(each,(Object)agentPh);
                        }
                        else if(String.isNotBlank(agentPh) && agentPh.startsWith('+91')){
                            payLoadMap.put(each,(Object)agentPh);
                        }
                    }
                    else if(each == 'Id'  && String.isNotBlank(jsonFieldMap.get(each))){
                        payLoadMap.put(each, objCase.get(jsonFieldMap.get(each)));
                    }
                    else if(each == 'authorization_key' && String.isNotBlank(jsonFieldMap.get(each))){
                        payLoadMap.put(each , jsonFieldMap.get(each));
                    }
                }
            }
            if(lstpayload.size()>0 && lstpayload[0].Base_URL__c != NULL){
                payLoadMap.put('Callback_URL',(Object)lstpayload[0].Base_URL__c);
           }
        }
        system.debug('Payload for manual call : ' + JSON.serialize(payLoadMap));
        return JSON.serialize(payLoadMap);
    }    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     get the payload information from custom metadata
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    2-Jan-19       Eitika Verma          created
    */
    public static List<knowlarityPayload__mdt> getPayLoadMap(String developeName){        
        String queryStr = 'SELECT FieldsToQuery__c,Base_URL__c,json_Pub__c, jsonComplex__c,jsonESB_pub__c, SObject__c FROM knowlarityPayload__mdt WHERE ';        
        queryStr += 'DeveloperName = \'' + developeName + '\'';
        
        List<knowlarityPayload__mdt> payloadList = Database.query(queryStr);        
        return payloadList;                
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     send the request to knowlarity
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    2-Jan-19       Eitika Verma          created
    */
    public static HttpResponse sendRequest(string jsonstr,string devname){
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c 
                                                    FROM Integration_Setting__mdt 
                                                    WHERE DeveloperName =:devName];
        
        if(insList!= null && insList.size()>0){
            HttpRequest req = new HttpRequest();
            req.setMethod(insList[0].Method__c);
            req.setEndPoint(insList[0].EndPointUrl__c);
            if(String.isNotBlank(insList[0].Headers__c)){
                for(String each : insList[0].Headers__c.split(',')){
                    req.setHeader(each.subStringBefore(':'), each.subStringAfter(':'));
                }
            }
            req.setBody(jsonstr);
            system.debug('req1============'+req.getBody());
            resp = http.send(req);
            
            //insert http publisher records
            createHTTPPublisher(jsonstr,'Case',resp.getBody());
            return resp;
        }
        else 
            return null;
        
    }
    
    public static void createHTTPPublisher(string reqbody,string ObjectName,string response){
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();
        objHTTPPublisher.LP_Request_body__c = reqbody;
        objHTTPPublisher.Related_Object__c = ObjectName;
        objHTTPPublisher.LP_Response__c = response;
        insert objHTTPPublisher;
        
    }
}