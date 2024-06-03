@RestResource(urlMapping='/MCareRiskEngineAPI/*')

global with sharing class MCareRiskEngineAPIController {

    public static List<String> failedResponseList = new List<String>();
    public static Map<String, Object> failureResponseMap = new Map<String, Object>();
    public static Map<String, Object> issueObjMap = new Map<String, Object>();
    public static Integer merchant_id;

    @HttpPost
    global static void getRiskEngineTickets(){
        Payload_Log__c payloadObj = New Payload_Log__c();
        try{
            String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
            system.debug('strJson'+strJson);

            issueObjMap = (Map<string,object>)JSON.deserializeUntyped(strJson);
            system.debug('@@@@@@@ issueObjMap '+issueObjMap);
            Map<string,MCare_Panel_Mapping__mdt> mcarePanelProjectMap = New Map<string,MCare_Panel_Mapping__mdt>();
            Map<string,MCare_Panel_Mapping__mdt> mcarePanelTrackerMap = New Map<string,MCare_Panel_Mapping__mdt>();
            Map<string,MCare_Panel_Mapping__mdt> mcarePanelCustomFieldMap = New Map<string,MCare_Panel_Mapping__mdt>();
            Map<string,MCare_Panel_Mapping__mdt> mcarePanelVariableValueMap = New Map<string,MCare_Panel_Mapping__mdt>();
            for(MCare_Panel_Mapping__mdt mdtObj : [Select Id,Field_API_Name__c,Field_Name__c,Type__c,MasterLabel,Field_Type__c from MCare_Panel_Mapping__mdt]){
                if(String.isNotBlank(mdtObj.Type__c) && mdtObj.Type__c == 'Project') mcarePanelProjectMap.put(mdtObj.MasterLabel,mdtObj);
                if(String.isNotBlank(mdtObj.Type__c) && mdtObj.Type__c == 'Tracker') mcarePanelTrackerMap.put(mdtObj.MasterLabel,mdtObj);
                if(String.isNotBlank(mdtObj.Type__c) && mdtObj.Type__c == 'CustomField') mcarePanelCustomFieldMap.put(mdtObj.MasterLabel,mdtObj);
                if(String.isNotBlank(mdtObj.Type__c) && mdtObj.Type__c == 'OuterColumn') mcarePanelVariableValueMap.put(mdtObj.Field_Name__c,mdtObj);
            }
			
             
            payloadObj.Payload__c =  strJson;
            payloadObj.Process__c = 'Risk Engine API';
            payloadObj.Status__c = 'SUCCESS';
            
            Sobject sobToUpsert = Schema.getGlobalDescribe().get('MCare_Dashboard_Case__c').newSObject();
            
            string issueObjMapValues = JSON.serialize(issueObjMap.values());
            system.debug('@@@@@@@ issueObjMap2 '+(List<object>)JSON.deserializeUntyped(issueObjMapValues));
            for(Object obj : (List<object>)JSON.deserializeUntyped(issueObjMapValues)){
                Map<String, Object> projectIdMap = (Map<String, Object>)obj;
                system.debug('@@@@@@@ projectIdMap '+projectIdMap);
                if(!projectIdMap.isEmpty()){
                    sobToUpsert.put('Status__c','New');
                    
        			List<Group> lstGroup = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) FROM Group WHERE DeveloperName =: 'MCare_PO_Risk_Team' AND Type =: 'Queue' LIMIT 1];
        			if(lstGroup != null && lstGroup.size() > 0){
                        sobToUpsert.put('OwnerId',lstGroup[0].Id); 
                    }
                    for(string str : projectIdMap.keySet()){
                        if(String.isNotBlank(String.valueOf(projectIdMap.get(str))) && !String.valueOf(projectIdMap.get(str)).equalsIgnoreCase('None') && !String.valueOf(projectIdMap.get(str)).equalsIgnoreCase('Nan')){
                            if(!mcarePanelVariableValueMap.isEmpty() && mcarePanelVariableValueMap.containsKey(str) && mcarePanelVariableValueMap.get(str).Field_Type__c == 'Date'){
                                sobToUpsert.put(string.valueOf(mcarePanelVariableValueMap.get(str).Field_API_Name__c),Date.valueOf(string.valueOf(projectIdMap.get(str))));
                            }
                            else if(!mcarePanelVariableValueMap.isEmpty() && mcarePanelVariableValueMap.containsKey(str) && mcarePanelVariableValueMap.get(str).Field_Type__c == 'Date/Time'){
                                sobToUpsert.put(string.valueOf(mcarePanelVariableValueMap.get(str).Field_API_Name__c),DateTime.valueOf(string.valueOf(projectIdMap.get(str))));
                            }
                            else if(!mcarePanelVariableValueMap.isEmpty() && mcarePanelVariableValueMap.containsKey(str) && mcarePanelVariableValueMap.get(str).Field_Type__c == 'Integer'){
                                sobToUpsert.put(string.valueOf(mcarePanelVariableValueMap.get(str).Field_API_Name__c),Integer.valueOf(projectIdMap.get(str)));
                            }
                            else if(!mcarePanelVariableValueMap.isEmpty() && mcarePanelVariableValueMap.containsKey(str) && (mcarePanelVariableValueMap.get(str).Field_Type__c == 'Decimal' || mcarePanelVariableValueMap.get(str).Field_Type__c == 'Double')){
                                sobToUpsert.put(string.valueOf(mcarePanelVariableValueMap.get(str).Field_API_Name__c),Double.valueOf(projectIdMap.get(str)));
                            }
                            else if(!mcarePanelVariableValueMap.isEmpty() && mcarePanelVariableValueMap.containsKey(str) && mcarePanelVariableValueMap.get(str).Field_Type__c == 'Boolean'){
                                sobToUpsert.put(string.valueOf(mcarePanelVariableValueMap.get(str).Field_API_Name__c),Boolean.valueOf(projectIdMap.get(str)));
                            }
                            else if(!mcarePanelVariableValueMap.isEmpty() && mcarePanelVariableValueMap.containsKey(str) && mcarePanelVariableValueMap.get(str).Field_Type__c == 'String'){
                                sobToUpsert.put(string.valueOf(mcarePanelVariableValueMap.get(str).Field_API_Name__c),String.valueOf(projectIdMap.get(str)));
                            }
                        }
                        
                    }
                    
                    if(projectIdMap.containsKey('project_id')){
                        string projectIdValue = string.valueOf(projectIdMap.get('project_id'));
                        if(!mcarePanelProjectMap.isEmpty() && mcarePanelProjectMap.containsKey(projectIdValue)){ 
                            string projectIdName = string.valueOf(mcarePanelProjectMap.get(projectIdValue).Field_Name__c);
                            system.debug('@@@@@@@ projectIdName '+projectIdName);
                            string fieldAPIName = mcarePanelProjectMap.get(projectIdValue).Field_API_Name__c;
                            sobToUpsert.put(fieldAPIName,projectIdName);
                            Id mCareRecordTypeId = Schema.SObjectType.MCare_Dashboard_Case__c.getRecordTypeInfosByName().get(projectIdName).getRecordTypeId();
                            sobToUpsert.put('RecordTypeId',mCareRecordTypeId);
                        }
                    }
                    if(projectIdMap.containsKey('tracker_id')){
                        string trackerIdValue = string.valueOf(projectIdMap.get('tracker_id'));
                        if(!mcarePanelTrackerMap.isEmpty() && mcarePanelTrackerMap.containsKey(trackerIdValue)){ 
                            string trackerIdName = string.valueOf(mcarePanelTrackerMap.get(trackerIdValue).Field_Name__c);
                            system.debug('@@@@@@@ trackerIdName '+trackerIdName);
                            string fieldAPIName = mcarePanelTrackerMap.get(trackerIdValue).Field_API_Name__c;
                            sobToUpsert.put(fieldAPIName,trackerIdName);
                        }
                    }
                    if(projectIdMap.containsKey('custom_fields')){
                        string customFieldValues = JSON.serialize(projectIdMap.get('custom_fields'));
                        system.debug('@@@@@@@ customFieldValues '+customFieldValues);
                        for(Object cField : (List<object>)JSON.deserializeUntyped(customFieldValues)){
                            Map<String, Object> customFieldMap = (Map<String, Object>)cField;
                            system.debug('@@@@@@@ tempMap '+customFieldMap);
                            system.debug('@@@@@@@ tempMapId '+customFieldMap.get('id'));
                            system.debug('@@@@@@@ tempMapValue '+customFieldMap.get('value'));
                            string customFieldId = string.valueOf(customFieldMap.get('id'));
                            string customFieldValue = string.valueOf(customFieldMap.get('value'));
                            if(!mcarePanelCustomFieldMap.isEmpty() && mcarePanelCustomFieldMap.containsKey(customFieldId)){
                                string fieldAPIName = mcarePanelCustomFieldMap.get(customFieldId).Field_API_Name__c;
                                string fieldType = mcarePanelCustomFieldMap.get(customFieldId).Field_Type__c;
                                if(String.isNotBlank(customFieldValue) && !customFieldValue.equalsIgnoreCase('None') && !customFieldValue.equalsIgnoreCase('Nan')){
                                    if(fieldType == 'Integer') sobToUpsert.put(fieldAPIName,Integer.valueOf(customFieldValue));
                                    else if(fieldType == 'Decimal' || fieldType == 'Double') sobToUpsert.put(fieldAPIName,Double.valueOf(customFieldValue));
                                    else if(fieldType == 'Date') sobToUpsert.put(fieldAPIName,Date.valueOf(customFieldValue));
                                    else if(fieldType == 'Date/Time') sobToUpsert.put(fieldAPIName,DateTime.valueOf(customFieldValue));
                                    else if(fieldType == 'Boolean') sobToUpsert.put(fieldAPIName,Boolean.valueOf(customFieldValue));
                                    else if(fieldType == 'String') {
                                        sobToUpsert.put(fieldAPIName,customFieldValue);
                                        if(fieldAPIName == 'merchant_Id__c') payloadObj.Prod_MID__c = Integer.valueOf(customFieldValue);
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status','SUCCESS');
            gen.writeEndObject();
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(gen.getAsString()));
            
            System.debug('######### sobToUpsert '+sobToUpsert);
            upsert sobToUpsert;
            
            upsert payloadObj;
            
        }catch(Exception ex){
            payloadObj.Exception__c = ex.getMessage()+' at line no. '+string.valueOf(ex.getLineNumber());
            payloadObj.Status__c = 'ERROR';
            upsert payloadObj;
            failedResponseList.add(ex.getMessage()+' at line no. '+string.valueOf(ex.getLineNumber()));
            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, issueObjMap, string.valueOf(merchant_id));
        }
    }

    public static void jsonFailResponse(String strStatus, List<String> strMessage, Map<String, Object> failureResponseMap, Map<String, Object> requestJson, String uuid){
        
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Message__c', String.valueOf(strMessage));
        messages.put('Process__c', 'MCare Agreement API');        
        if(!requestJson.isEmpty()) messages.put('Request__c', JSON.serialize(requestJson));
        if(String.isNotBlank(uuid)) messages.put('Identifier__c', uuid);
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);        
        SystemUtility.errorHandler(null, messages);
        
        Error_Details__c errorDetailsObj = new Error_Details__c();
        errorDetailsObj.Severity__c = 'High';
        errorDetailsObj.Message__c = String.valueOf(strMessage);
        errorDetailsObj.Process__c = 'MCare Risk Engine API';
        if(!requestJson.isEmpty())  errorDetailsObj.Request__c = JSON.serialize(requestJson);
        if(String.isNotBlank(uuid)) errorDetailsObj.Identifier__c = uuid;
        if(!userId.isEmpty() && userId.size()>0)    errorDetailsObj.OwnerId = userId[0].Id;
        insert errorDetailsObj;
        
        failureResponseMap.put('status', strStatus);  
        failureResponseMap.put('response', strMessage);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(failureResponseMap));
        RestContext.response.statusCode = 400;
    }
}