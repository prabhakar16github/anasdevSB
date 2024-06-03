@RestResource(urlMapping='/MCareHoldTicketAPI/*')
global class MCareHoldTicketAPIController {
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
    public static Integer merchantId;
    public static string productName='';
    public static Map<String, Object> failureResponseMap = new Map<String, Object>();
    public static Map<String, String> returnDetail = new Map<String, String>();
    
    @HTTPPUT
    global static void getHoldTicketData(){
        try{
            RestRequest req = RestContext.request;
            RestResponse res = Restcontext.response;
            
            merchantId = Integer.valueOf(req.params.get('mid'));
            productName = req.params.get('product');
            
            if(String.isNotBlank(productName)){
                if(merchantId != null){
                    if(merchantId != null && String.isNotBlank(productName)){
                        
                        List<Opportunity> oppDetails = [Select Id,AccountId,Identifier__c,Product__r.Identifier__c,Prod_Merchant_Id__c,
                                                        RecordTypeId,ProductLabel__c
                                                        from Opportunity where Prod_Merchant_Id__c =:merchantId
                                                        AND ProductLabel__c=:productName ORDER BY LastModifiedDate LIMIT 1];
                        System.debug('###### oppDetails '+oppDetails);
                        //Added By Animesh - Start
                        Set<Id> caseId = new Set<Id>();                 
                        List<MCare_Dashboard_Case__c> mCareDashboardC = [SELECT Id, Desposition_L2__c, Status__c, Desposition_L1__c, Merchant_Id__c, Reason__c,Opportunity__c,Case__c FROM MCare_Dashboard_Case__c WHERE Product_Name__c=:productName and Merchant_Id__c=:req.params.get('mid') Limit 1];
                        caseId.add(mCareDashboardC[0].Case__c);
                        Id postRiskRecordTypeIdsOne = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
                        List<Case> csObjListOne = [Select Id,LP_Issue__c,Status,Identifier__c,MCare_Document_Status__c,TicketId__c,CreatedDate, LP_Category__c, LP_Transaction_Reason__c, Payment_Id__c from Case Where Opportunity__c=: oppDetails[0].Id
                                                   AND RecordTypeId =: postRiskRecordTypeIdsOne and Id=:caseId ORDER BY LastModifiedDate LIMIT 1];                        
                        if(mCareDashboardC[0].Status__c == 'Risk Hold'){
                            if(mCareDashboardC[0].Case__c != Null){
                                RestContext.response.addHeader('Content-Type', 'application/json');
                                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(mCareDashboardC[0].Case__c));
                                    
                                    }else{
                                        
                                        Id postRiskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
                                        
                                        If(oppDetails.Size()>0 && !oppDetails.isEmpty()){
                                            List<Case> csObjList = [Select Id,LP_Issue__c,Status,Identifier__c,MCare_Document_Status__c,TicketId__c,CreatedDate, LP_Category__c, LP_Transaction_Reason__c, Payment_Id__c from Case Where Opportunity__c=: oppDetails[0].Id
                                                                    AND RecordTypeId =: postRiskRecordTypeId ORDER BY LastModifiedDate LIMIT 1];
                                            System.debug('###### csObjList '+csObjList);
                                            if(csObjList.size()>0 && !csObjList.isEmpty()){
                                                JSONGenerator gen = JSON.createGenerator(true);
                                                gen.writeStartObject();
                                                gen.writeStringField('merchant_id',String.valueOf(merchantId));
                                                gen.writeStringField('product_name',productName);
                                                gen.writeStringField('hold_reason',csObjList[0].LP_Transaction_Reason__c);
                                                gen.writeStringField('ticket_id',csObjList[0].TicketId__c==null ?'' : csObjList[0].TicketId__c);
                                                gen.writeStringField('l1_disposition',csObjList[0].LP_Issue__c);
                                                gen.writeStringField('payment_ids',csObjList[0].Payment_Id__c);
                                                gen.writeStringField('created_on',String.valueOf(csObjList[0].CreatedDate));
                                                gen.writeStringField('case_status',String.valueOf(csObjList[0].Status));
                                                gen.writeEndObject();
                                                retrnJson = gen.getAsString();
                                                RestContext.response.addHeader('Content-Type', 'application/json');
                                                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(retrnJson));
                                            }else{
                                                failedResponseList.add('No ticket Id found in SF database.');
                                                failureResponseMap.put('ticket_Id_Present',False);
                                                jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchantId));
                                            }
                                        } 
                                    }
                        }
                        else{
                            failedResponseList.add('No ticket Id found in SF database.');
                            failureResponseMap.put('ticket_Id_Present',False);
                            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchantId));
                        }
                        
                        //-End    
                        Id postRiskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
                        
                        If(oppDetails.Size()>0 && !oppDetails.isEmpty()){
                            List<Case> csObjList = [Select Id,LP_Issue__c,Status,Identifier__c,MCare_Document_Status__c,TicketId__c,CreatedDate, LP_Category__c, LP_Transaction_Reason__c, Payment_Id__c from Case Where Opportunity__c=: oppDetails[0].Id
                                                    AND RecordTypeId =: postRiskRecordTypeId ORDER BY LastModifiedDate LIMIT 1];
                            System.debug('###### csObjList '+csObjList);
                            if(csObjList.size()>0 && !csObjList.isEmpty()){
                                JSONGenerator gen = JSON.createGenerator(true);
                                gen.writeStartObject();
                                gen.writeStringField('merchant_id',String.valueOf(merchantId));
                                gen.writeStringField('product_name',productName);
                                gen.writeStringField('hold_reason',csObjList[0].LP_Transaction_Reason__c);
                                gen.writeStringField('ticket_id',csObjList[0].TicketId__c==null ?'' : csObjList[0].TicketId__c);
                                gen.writeStringField('l1_disposition',csObjList[0].LP_Issue__c);
                                gen.writeStringField('payment_ids',csObjList[0].Payment_Id__c);
                                gen.writeStringField('created_on',String.valueOf(csObjList[0].CreatedDate));
                                gen.writeStringField('case_status',String.valueOf(csObjList[0].Status));
                                gen.writeEndObject();
                                retrnJson = gen.getAsString();
                                RestContext.response.addHeader('Content-Type', 'application/json');
                                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(retrnJson));
                            }else{
                                failedResponseList.add('No ticket Id found in SF database.');
                                failureResponseMap.put('ticket_Id_Present',False);
                                jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchantId));
                            }
                        }
                    }
                }else{
                    failedResponseList.add('merchant Id is Missing.');
                    jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchantId));
                }
            }else{
                failedResponseList.add('Product is missing.');
                jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchantId));
            }
        }catch(Exception ex){
            failedResponseList.add(ex.getMessage()+' at line No. '+String.valueOf(ex.getLineNumber()));
            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchantId));
        }
    }
    
    public static void jsonFailResponse(String strStatus, List<String> strMessage, Map<String, Object> failureResponseMap, Map<String, String> requestJson, String uuid){
        
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Message__c', String.valueOf(strMessage));
        messages.put('Process__c', 'MCare Hold Ticket API');        
        if(!requestJson.isEmpty()) messages.put('Request__c', JSON.serialize(requestJson));
        if(String.isNotBlank(uuid)) messages.put('Identifier__c', uuid);
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);        
        SystemUtility.errorHandler(null, messages);
        
        Error_Details__c errorDetailsObj = new Error_Details__c();
        errorDetailsObj.Severity__c = 'High';
        errorDetailsObj.Message__c = String.valueOf(strMessage);
        errorDetailsObj.Process__c = 'MCare Hold Ticket API';
        if(!requestJson.isEmpty())  errorDetailsObj.Request__c = JSON.serialize(requestJson);
        if(String.isNotBlank(uuid)) errorDetailsObj.Identifier__c = uuid;
        if(!userId.isEmpty() && userId.size()>0)    errorDetailsObj.OwnerId = userId[0].Id;
        insert errorDetailsObj;
        
        failureResponseMap.put('status', strStatus);  
        failureResponseMap.put('response', strMessage);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(failureResponseMap));
        RestContext.response.statusCode = 200;
    }
}