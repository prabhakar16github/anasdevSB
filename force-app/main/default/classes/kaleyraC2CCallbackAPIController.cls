@RestResource(urlMapping='/kaleyraC2CCallbackAPI/*')
global class kaleyraC2CCallbackAPIController {
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
    
    @HttpPost
    global static void updateCallbackOpportunity(){
        String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
        Map<String, Object> failureResponseMap = new Map<String, Object>();
        system.debug('strJson'+strJson);
        Map<String, String> returnDetail = (Map<String, String>)JSON.deserialize(strJson, Map<String, String>.class);
        system.debug('returnDetail'+returnDetail);
        
        string missedCallTime = '';
        string manualCall = '';
        string audioClip = '';
        string callType = '';
        string merchant_Identifier = returnDetail.get('identifier');
        string customer_Number = '';
        string Bill_Seconds ;
        string call_status ;
        if(returnDetail.containsKey('Missed_Call_Time__c')){
            missedCallTime = returnDetail.get('Missed_Call_Time__c');
        }else{  
            if(returnDetail.containsKey('Manual_Call_response')) manualCall = returnDetail.get('Manual_Call_response');
            if(returnDetail.containsKey('Audio_Clip')) audioClip = returnDetail.get('Audio_Clip');
            if(returnDetail.containsKey('Call_Type')) callType = returnDetail.get('Call_Type');
        }
        if(returnDetail.containsKey('customer_number')) customer_Number = returnDetail.get('customer_number');
        if(String.isNotBlank(manualCall)){
            for(String eachString : manualCall.split(',')){
                if(eachString.contains('CallStatus')) call_status =  eachString.substringAfter('CallStatus:');
                if(eachString.contains('Bill_Seconds')) Bill_Seconds = eachString.substringAfter('Bill_Seconds:');
            } 
        }
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Lead> leadList = new List<Lead>();
        List<MCare_Dashboard_Case__c> mCareDashboardList = new List<MCare_Dashboard_Case__c>();
        
        try{
            if(String.isNotBlank(merchant_Identifier)){
                oppList = Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Opportunity')), ',') + ' FROM Opportunity WHERE Identifier__c =\'' + merchant_Identifier + '\'');
                system.debug('oppList'+oppList);                
                if(oppList.size() > 0 && !oppList.isEmpty()){
                    if(manualCall != null){
                        oppList[0].Manual_Call_Response__c = manualCall;
                    }
                    if(callType != null){
                        oppList[0].Call_Type__c = callType;
                    }
                    if(audioClip != null){
                        oppList[0].Audio_Clip__c = audioClip;
                    }
                    if(missedCallTime != null){
                        oppList[0].Missed_Call_Time__c = missedCallTime;
                    }
                    system.debug('oppList2'+oppList); 
                    update oppList;
                }
                else if(oppList.size()==0 && oppList.isEmpty()){
                    leadList = Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Lead')), ',') + ' FROM Lead WHERE IsConverted=False AND Identifier__c =\'' + merchant_Identifier + '\'');
                    if(!leadList.isEmpty() && leadList.size() > 0){
                        if(manualCall != null){
                            leadList[0].Manual_Call_Response__c = manualCall;
                        }
                        if(callType != null){
                            leadList[0].Call_Type__c = callType;
                        }
                        if(audioClip != null){
                            leadList[0].Audio_Clip__c = audioClip;
                        }
                        if(missedCallTime != null){
                            leadList[0].Missed_Call_Time__c = missedCallTime;
                        }
                        update leadList;
                    }
                    else if(oppList.size() == 0 && oppList.isEmpty() && leadList.size() == 0 && leadList.isEmpty() && String.isNotBlank(customer_Number)){
                        mCareDashboardList = Database.query('SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('MCare_Dashboard_Case__c')), ',') + ' FROM MCare_Dashboard_Case__c WHERE Identifier__c =\'' + merchant_Identifier + '\'');
                        if(!mCareDashboardList.isEmpty() && mCareDashboardList.size() > 0){
                            createTask(mCareDashboardList[0], manualCall, callType, audioClip, missedCallTime, call_status, Bill_Seconds, customer_Number);
                        }
                    }
                }
                
                else{
                    failedResponseList.add('Identifier not found in Salesforce database.');
                    jsonFailResponse('FAILED','Kaleyra C2C API',failedResponseList, failureResponseMap, returnDetail, merchant_Identifier);
                }
            }else{
                failedResponseList.add('Identifier cannot be blank.');
                jsonFailResponse('FAILED','Kaleyra C2C API',failedResponseList, failureResponseMap, returnDetail, merchant_Identifier);
            }
        }catch(Exception ex){
            system.debug('-->> '+ex.getLineNumber()+' '+ex.getMessage());
            failedResponseList.add(ex.getMessage());
            failedResponseList.add(ex.getStackTraceString());
            jsonFailResponse('FAILED', 'Kaleyra C2C API',failedResponseList, failureResponseMap, returnDetail, merchant_identifier);
        }
    }
    
    public static void createTask(SObject each, String manualCall, String callType, String audioClip, String missedCallTime, string call_Status, string bill_Status, string customerNumber){
        Task objTask = New Task();  
        objTask.WhatId = String.valueOf(each.get('Id')); 
        if(String.isNotBlank(manualCall)){
            objTask.Subject = 'Click To Call Details';
        	objTask.Status = 'Closed';  
        	objTask.Description = 'Manual Call Responce:: '+manualCall+', '+'\n Audio Clip: '+audioClip;
            objTask.Call_Status__c = call_Status;
        	objTask.CallDurationInSeconds = String.isNotBlank(bill_Status) ? Integer.valueOf(bill_Status) : 0;
            objTask.LP_Recording_Url__c = audioClip;
            objTask.LP_Call_Type__c = callType;
        }else{
            objTask.Subject = 'Click To Call Missed Call Alert';
            objTask.Status = 'Open';
            objTask.LP_Call_Type__c = callType;
        }
        if(String.valueOf(each.get('Merchant_Mobile_Decrypt__c')) == customerNumber) objTask.Merchant_Mobile__c = String.valueOf(each.get('Merchant_Mobile__c'));
        else objTask.Merchant_Mobile__c = customerNumber;
        objTask.Agent_Details__c = String.valueOf(each.get('Agent_Details__c'));
        objTask.OwnerId = String.valueOf(each.get('OwnerId'));
        upsert objTask;
    }
    
    public static void jsonFailResponse(String strStatus, string process, List<String> strMessage, Map<String, Object> failureResponseMap, Map<String, String> requestJson, String uuid){
        
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Message__c', String.valueOf(strMessage));
        messages.put('Process__c', process);        
        if(!requestJson.isEmpty()) messages.put('Request__c', JSON.serialize(requestJson));
        if(String.isNotBlank(uuid)) messages.put('Identifier__c', uuid);
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);        
        SystemUtility.errorHandler(null, messages);
        
        Error_Details__c errorDetailsObj = new Error_Details__c();
        errorDetailsObj.Severity__c = 'High';
        errorDetailsObj.Message__c = String.valueOf(strMessage);
        errorDetailsObj.Process__c = process;
        if(!requestJson.isEmpty())  errorDetailsObj.Request__c = JSON.serialize(requestJson);
        if(String.isNotBlank(uuid)) errorDetailsObj.Identifier__c = uuid;
        if(!userId.isEmpty() && userId.size()>0)    errorDetailsObj.OwnerId = userId[0].Id;
        //insert errorDetailsObj;
        
        failureResponseMap.put('status', strStatus);  
        failureResponseMap.put('response', strMessage);     
        failureResponseMap.put('data', new Map<String, Object>());
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(failureResponseMap));
        RestContext.response.statusCode = 404;
    }
    
}