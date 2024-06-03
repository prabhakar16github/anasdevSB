public class OneCare_kaleyraUtility {
    public static string prepareIVRPayload(string callType,list<Opportunity> lstOpp){
        try{
            //declare variables
            Map<String, String> jsonFieldMap;
            Map<String, String> jsonComplexMap;
            Map<String,String> jsonESBPub;
            Map<String, Object> payLoadMap = new Map<String, Object>();
            //list<Map<String, Object>> lstOfIVRCalls = new list<Map<String, Object>>();
            
            //get the payload info from custom metadata
            List<OneCare_Caleria_Payload__mdt> lstpayload = OneCare_kaleyraUtility.getPayLoadMap('IVR_Call'); 
            System.debug('lstpayload Kaleyria'+lstpayload);
            if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].JSON_PUB__c  != null && string.isNotBlank(lstpayload[0].JSON_PUB__c)){
                System.debug('lstpayload Kaleyria JSON_PUB__c:::'+lstpayload[0].JSON_PUB__c);
                jsonFieldMap = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_PUB__c, Map<String, String>.class);
            }
            if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].JSON_Complex__c!= null && string.isNotBlank(lstpayload[0].JSON_Complex__c)){
                jsonComplexMap = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_Complex__c, Map<String, String>.class);
                System.debug('jsonComplexMap Kaleyria'+jsonComplexMap); 
            }
            if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].JSON_ESB_PUB__c != null && string.isNotBlank(lstpayload[0].JSON_ESB_PUB__c)){
                jsonESBPub = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_ESB_PUB__c, Map<String, String>.class);
            }            
            if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){
                for(String each : jsonFieldMap.keySet()){
                    if(jsonFieldMap.get(each) != NULL){
                        payLoadMap.put(each,(Object)jsonFieldMap.get(each));
                    }
                    else{
                        payLoadMap.put(each,'None');
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
                for(Opportunity eachOpp : lstOpp){
                    for(string eachStr : jsonComplexMap.keyset()){
                        strAdditionalNode = eachStr;
                        if(jsonComplexMap.get(eachStr) != '' && jsonComplexMap.get(eachStr).contains(',')){
                            for(string eachInnerStr : jsonComplexMap.get(eachStr).split(',')){
                                system.debug('eachInnerStr'+eachInnerStr);
                                system.debug('substringBefore>>>'+eachInnerStr.substringBefore(':'));
                                system.debug('substringAfter>>>'+eachInnerStr.substringAfter(':'));
                                //system.debug('getSobject>>>'+eachOpp.getSobject(eachInnerStr.substringBefore(':')));
                                if(eachInnerStr == 'MobilePhone'){
                                    eachInnerStr = 'Mobile__c';
                                    system.debug('eachInnerStr Mobile__c'+eachInnerStr);
                                }
                                strAdditional += eachOpp.get(eachInnerStr) + ',';
                                system.debug('strAdditional>>>'+strAdditional);
                            }
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
            System.debug('Body:: '+JSON.serialize(payLoadMap));
            return JSON.serialize(payLoadMap);
        }catch(Exception ex){
            System.debug('ERROR:: '+ex.getMessage());
            System.debug('Line No:: '+ex.getLineNumber());
            return null;
        }
    }
    public static string prepareIVRPayloadforlead(string callType,list<Lead> objLead){
        try{
            //declare variables
            Map<String, String> jsonFieldMap;
            Map<String, String> jsonComplexMap;
            Map<String,String> jsonESBPub;
            Map<String, Object> payLoadMap = new Map<String, Object>();
            List<OneCare_Caleria_Payload__mdt> lstpayload = OneCare_kaleyraUtility.getPayLoadMap('IVR_Call'); 
            System.debug('lstpayload Kaleyria'+lstpayload);
            if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].JSON_PUB__c  != null && string.isNotBlank(lstpayload[0].JSON_PUB__c)){
                System.debug('lstpayload Kaleyria JSON_PUB__c:::'+lstpayload[0].JSON_PUB__c);
                jsonFieldMap = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_PUB__c, Map<String, String>.class);
            }
            if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].JSON_Complex__c!= null && string.isNotBlank(lstpayload[0].JSON_Complex__c)){
                jsonComplexMap = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_Complex__c, Map<String, String>.class);
                System.debug('jsonComplexMap Kaleyria'+jsonComplexMap); 
            }
            if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].JSON_ESB_PUB__c != null && string.isNotBlank(lstpayload[0].JSON_ESB_PUB__c)){
                jsonESBPub = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_ESB_PUB__c, Map<String, String>.class);
            }            
            if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){
                for(String each : jsonFieldMap.keySet()){
                    if(jsonFieldMap.get(each) != NULL){
                        payLoadMap.put(each,(Object)jsonFieldMap.get(each));
                    }
                    else{
                        payLoadMap.put(each,'None');
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
                for(Lead eachOpp : objLead){
                    for(string eachStr : jsonComplexMap.keyset()){
                        strAdditionalNode = eachStr;
                        if(jsonComplexMap.get(eachStr) != '' && jsonComplexMap.get(eachStr).contains(',')){
                            for(string eachInnerStr : jsonComplexMap.get(eachStr).split(',')){
                                system.debug('eachInnerStr'+eachInnerStr);
                                system.debug('substringBefore>>>'+eachInnerStr.substringBefore(':'));
                                system.debug('substringAfter>>>'+eachInnerStr.substringAfter(':'));
                                //system.debug('getSobject>>>'+eachOpp.getSobject(eachInnerStr.substringBefore(':')));
                                if(eachInnerStr == 'MobilePhone'){
                                    eachInnerStr = 'MobilePhone';
                                    system.debug('eachInnerStr Mobile__c'+eachInnerStr);
                                }
                                strAdditional += eachOpp.get(eachInnerStr) + ',';
                                system.debug('strAdditional>>>'+strAdditional);
                            }
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
            System.debug('Body:: '+JSON.serialize(payLoadMap));
            return JSON.serialize(payLoadMap);
        }catch(Exception ex){
            System.debug('ERROR:: '+ex.getMessage());
            System.debug('Line No:: '+ex.getLineNumber());
            return null;
        }
    }
    
    
    public static string prepareManualCallPayload(string callType,Opportunity objOpp,String customerNumber,Lead objlead){
        //declare variables
        Map<String, String> jsonFieldMap;
        Map<String, String> jsonComplexMap;
        Map<String, Object> payLoadMap = new Map<String, Object>();
        
        //get the phone number of agent or logged in user
        //string agentPh = [SELECT Phone FROM User WHERE id=:userinfo.getUserId()].Phone;
        
        //get the payload info from custom metadata
        system.debug('callType1'+callType);
        List<OneCare_Caleria_Payload__mdt> lstpayload = getPayLoadMap(callType); 
        system.debug('lstpayload'+lstpayload);
        if (!lstpayload.isEmpty() && lstpayload.size()>0 && lstpayload[0].JSON_PUB__c != null 
            && string.isNotBlank(lstpayload[0].JSON_PUB__c)){
                jsonFieldMap = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_PUB__c, Map<String, String>.class);
            }
        if (lstpayload!= NULL && lstpayload.size()>0 && lstpayload[0].JSON_Complex__c!= null && string.isNotBlank(lstpayload[0].JSON_Complex__c)){
            jsonComplexMap = (Map<String, String>)JSON.deserialize(lstpayload[0].JSON_Complex__c, Map<String, String>.class);
            
            
            System.debug('jsonComplexMap Kaleyria'+jsonComplexMap); 
        }
        if(objOpp != null){
            if(jsonComplexMap != null && !jsonComplexMap.isEmpty()){ 
                for(String each : jsonComplexMap.keySet()){
                    if(String.isNotBlank(each) && jsonComplexMap.get(each) != NULL){
                        string strValue = jsonComplexMap.get(each);
                        if(objOpp.get(strValue) != NULL)
                            payLoadMap.put(each,objOpp.get(strValue));
                        else
                            payLoadMap.put(each,''); 
                    }
                }
            }
        }
        else if(objLead != null){
            if(jsonComplexMap != null && !jsonComplexMap.isEmpty()){ 
                for(String each : jsonComplexMap.keySet()){
                    if(String.isNotBlank(each) && jsonComplexMap.get(each) != NULL){
                        string strValue = jsonComplexMap.get(each);
                        if(objlead.get(strValue) != NULL)
                            payLoadMap.put(each,objlead.get(strValue));
                        else
                            payLoadMap.put(each,''); 
                    }
                }
            }
        }
        //Prashant
        if(jsonComplexMap != null && !jsonComplexMap.isEmpty()){ 
            for(String each : jsonFieldMap.keySet()){
                payLoadMap.put(each , jsonFieldMap.get(each));                
            }
            system.debug('Payload for manual call payLoadMap: ' + JSON.serialize(payLoadMap));
            if(String.isNotBlank(customerNumber)){
                payLoadMap.put('Customer_Mobile_Number', customerNumber);
            }
        }
        system.debug('Payload for manual call : ' + JSON.serialize(payLoadMap));
        return JSON.serialize(payLoadMap);
    } 
    
    public static List<OneCare_Caleria_Payload__mdt> getPayLoadMap(String developeName){  
        
        String queryStr = 'SELECT Fields_To_Query__c,BaseURL__c,JSON_PUB__c, JSON_Complex__c,JSON_ESB_PUB__c, SObject__c FROM OneCare_Caleria_Payload__mdt WHERE ';        
        queryStr += 'DeveloperName = \'' + developeName + '\'';
        
        List<OneCare_Caleria_Payload__mdt> payloadList = Database.query(queryStr);
        return payloadList;                
    }
    
    public static HttpResponse sendRequest(string jsonstr,string devname){
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c,User_Name__c, Password__c  
                                                  FROM Integration_Setting__mdt 
                                                  WHERE DeveloperName =:devName];
        
        if(insList!= null && insList.size()>0){
            HttpRequest req = new HttpRequest();
            System.debug('Mtd Type:: '+insList[0].Method__c);
            req.setMethod(insList[0].Method__c);
            req.setEndPoint(insList[0].EndPointUrl__c);
            
            Blob headerValue = Blob.valueOf(insList[0].User_Name__c  + ':' + insList[0].Password__c);
            System.debug('headerValue:: '+headerValue);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            System.debug('authorizationHeader:: '+authorizationHeader);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
            req.setBody(jsonstr);
            system.debug('req1============'+req.getBody());
            if(!Test.isRunningTest()){
                resp = http.send(req);
            }
            
            //insert http publisher records
            //createHTTPPublisher(jsonstr,'Case',resp.getBody());
            return resp;
        }
        else 
            return null;
        
    }
    
    public static List<OneCare_Caleria_Payload__mdt> getPayLoadMap(String developeName, String sObjectName){  
        
        String queryStr = 'SELECT Fields_To_Query__c,BaseURL__c,JSON_PUB__c, JSON_Complex__c,JSON_ESB_PUB__c, SObject__c FROM OneCare_Caleria_Payload__mdt WHERE ';        
        queryStr += 'DeveloperName = \'' + developeName + '\'';
        queryStr += String.isNotBlank(sObjectName) ? ' AND SObject__c = \'' + sObjectName + '\'' : '';
        
        List<OneCare_Caleria_Payload__mdt> payloadList = Database.query(queryStr);
        return payloadList;                
    }
    
    public static string prepareManualCallPayload(List<OneCare_Caleria_Payload__mdt> kaleyraPayloadList, SObject sObjectData, String customerNumber){
        //declare variables
        Map<String, String> jsonFieldMap;
        Map<String, String> jsonComplexMap;
        Map<String, Object> payLoadMap = new Map<String, Object>();
        
        if(!kaleyraPayloadList.isEmpty() && kaleyraPayloadList.size()>0){
            if(String.isNotBlank(kaleyraPayloadList[0].JSON_PUB__c)){
                jsonFieldMap = (Map<String, String>)JSON.deserialize(kaleyraPayloadList[0].JSON_PUB__c, Map<String, String>.class);
            }
            if(string.isNotBlank(kaleyraPayloadList[0].JSON_Complex__c)){
                jsonComplexMap = (Map<String, String>)JSON.deserialize(kaleyraPayloadList[0].JSON_Complex__c, Map<String, String>.class);
            }
        }
        
        if(sObjectData != null){
            if(jsonComplexMap != null && !jsonComplexMap.isEmpty()){ 
                for(String each : jsonComplexMap.keySet()){
                    if(String.isNotBlank(each) && jsonComplexMap.get(each) != NULL){
                        string strValue = jsonComplexMap.get(each);
                        if(sObjectData.get(strValue) != NULL)
                            payLoadMap.put(each,sObjectData.get(strValue));
                        else
                            payLoadMap.put(each,''); 
                    }
                }
            }
            if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){ 
                for(String each : jsonFieldMap.keySet()){
                    if(String.isNotBlank(each) && jsonFieldMap.get(each) != NULL){
                        string strValue = jsonFieldMap.get(each);
                        if(sObjectData.get(strValue) != NULL)
                            payLoadMap.put(each,sObjectData.get(strValue));
                        else
                            payLoadMap.put(each,'');                 
                    }
                }
            }
            if(String.isNotBlank(customerNumber)){
                payLoadMap.put('Customer_Mobile_Number', customerNumber);
            }
        }
        system.debug('Payload for manual call : ' + JSON.serialize(payLoadMap));
        return JSON.serialize(payLoadMap);
    }
    
    public static string prepareIVRCallPayload(List<OneCare_Caleria_Payload__mdt> kaleyraPayloadList, SObject sObjectData, String sObjectName){
        try{
            //declare variables
            Map<String, String> jsonFieldMap;
            Map<String, String> jsonComplexMap;
            Map<String,String> jsonESBPub;
            Map<String, Object> payLoadMap = new Map<String, Object>();
            
            if(!kaleyraPayloadList.isEmpty() && kaleyraPayloadList.size()>0){
                if(String.isNotBlank(kaleyraPayloadList[0].JSON_PUB__c)){
                    jsonFieldMap = (Map<String, String>)JSON.deserialize(kaleyraPayloadList[0].JSON_PUB__c, Map<String, String>.class);
                }
                if(string.isNotBlank(kaleyraPayloadList[0].JSON_Complex__c)){
                    jsonComplexMap = (Map<String, String>)JSON.deserialize(kaleyraPayloadList[0].JSON_Complex__c, Map<String, String>.class);
                }
                if (string.isNotBlank(kaleyraPayloadList[0].JSON_ESB_PUB__c)){
                    jsonESBPub = (Map<String, String>)JSON.deserialize(kaleyraPayloadList[0].JSON_ESB_PUB__c, Map<String, String>.class);
                } 
            }
            
            if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){
                for(String each : jsonFieldMap.keySet()){
                    if(jsonFieldMap.get(each) != NULL){
                        payLoadMap.put(each,(Object)jsonFieldMap.get(each));
                    }
                    else{
                        payLoadMap.put(each,'None');
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
                for(string eachStr : jsonComplexMap.keyset()){
                    strAdditionalNode = eachStr;
                    if(jsonComplexMap.get(eachStr) != '' && jsonComplexMap.get(eachStr).contains(',')){
                        for(string eachInnerStr : jsonComplexMap.get(eachStr).split(',')){
                            strAdditional += sObjectData.get(eachInnerStr) + ',';
                            system.debug('strAdditional>>>'+strAdditional);
                        }
                        if(String.isNotBlank(strAdditional) && strAdditional.endsWith(',') ){
                            strAdditional = strAdditional.substring(0 , strAdditional.length()-1);
                            strAdditional += ';';   
                        }
                    }
                }
                if(String.isNotBlank(strAdditional)){
                    strAdditional = strAdditional.removeEnd(';');
                }
                system.debug('strAdditional======'+strAdditional);
                payLoadMap.put(strAdditionalNode,(Object)strAdditional);
            }
            System.debug('Body:: '+JSON.serialize(payLoadMap));
            return JSON.serialize(payLoadMap);
        }catch(Exception ex){
            System.debug('ERROR:: '+ex.getMessage());
            System.debug('Line No:: '+ex.getLineNumber());
            return null;
        }
    }
    
}