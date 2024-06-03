Public class SystemUtility{
    /*----------------------------------------------------------------------
Description:    method to send the mail with dynamic body
-------------------------------------------------------------------------*/
    public static List<Messaging.SendEmailResult> sendEmailWithUpdateBody(string name, string email, EmailTemplate emailTemplateObj, list<Attachment> listAttachment, String ownerName, String ownerEmail, String acntOwnerEmail, Id OrgWideEmailAddId, Boolean isSendAgreement){
        List<Messaging.EmailFileAttachment> listEmailFileAttachment = new List<Messaging.EmailFileAttachment>();
        
        if(listAttachment != null && !listAttachment.isEmpty()){
            for(Attachment attachObj : listAttachment){
                system.debug('attachObj ::::::::'+attachObj);
                Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
                emailFileAttachment.setContentType(attachObj.ContentType);
                emailFileAttachment.setFileName(attachObj.Name);
                emailFileAttachment.setInline(false);
                emailFileAttachment.Body = attachObj.Body;
                listEmailFileAttachment.add(emailFileAttachment);
            }
        }
        system.debug(listEmailFileAttachment.size()+' :::::::: listEmailFileAttachment ::::::::'+listEmailFileAttachment);
        system.debug('emailTemplateObj ::::::::'+emailTemplateObj);
        system.debug('name +++ '+name+' ++ email +++ '+email);
        
        if(String.isNotBlank(name) && String.isNotBlank(email) && emailTemplateObj != null && emailTemplateObj.id != null){
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
            
            emailTemplateObj.HtmlValue = emailTemplateObj.HtmlValue.contains('ContactName') ? emailTemplateObj.HtmlValue.replace('ContactName', name) : emailTemplateObj.HtmlValue;
            emailTemplateObj.HtmlValue = emailTemplateObj.HtmlValue.contains('OwnerName') ? emailTemplateObj.HtmlValue.replace('OwnerName', ownerName) : emailTemplateObj.HtmlValue;
            emailTemplateObj.HtmlValue = emailTemplateObj.HtmlValue.contains('{!Contact.Name}') ? emailTemplateObj.HtmlValue.replace('{!Contact.Name}', name) : emailTemplateObj.HtmlValue;
            
            singleEmailMsg.setReplyTo(ownerEmail);            
            singleEmailMsg.setToAddresses(new String[] { email });
            singleEmailMsg.setCcAddresses(new String[] { acntOwnerEmail });            
            singleEmailMsg.setSubject(emailTemplateObj.Subject);
            singleEmailMsg.setHtmlBody(emailTemplateObj.HtmlValue);
            
            if(isSendAgreement){
                if(String.isNotBlank(OrgWideEmailAddId)) singleEmailMsg.setOrgWideEmailAddressId(OrgWideEmailAddId);    
            }else{
                if(String.isNotBlank(ownerName)) singleEmailMsg.setSenderDisplayName(ownerName);     
            }
            
            if(!listEmailFileAttachment.isEmpty())
                singleEmailMsg.setFileAttachments(listEmailFileAttachment);
            
            List<Messaging.SendEmailResult> listSendEmailResult = Messaging.sendEmail(new Messaging.Singleemailmessage[] { singleEmailMsg });
            
            system.debug(listSendEmailResult.size()+' :::::::: listSendEmailResult ::::::::'+listSendEmailResult);
            
            return listSendEmailResult;
        }
        return null;
    }
    
    /*----------------------------------------------------------------------------------------
Description:    method to get the list of picklist values of given object and field 
----------------------------------------------------------------------------------------*/
    public static List<String> getPicklistValue(String objType, String fieldName) {
        List<String> lstPickvals = new List<String>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objType);//From the Object Api name retrieving the SObject
        
        Sobject Object_name = targetType.newSObject();
        
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        
        for (Schema.PicklistEntry a : pick_list_values){  //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        
        return lstPickvals;
    }
    
    /*----------------------------------------------------------------------------------------
Description:    method to get all active record from Document Category master object
----------------------------------------------------------------------------------------*/
    public static List<Document_Category_Master__c> getDocumentCategory() {
        return [SELECT Id, Name, Active__c, Identifier__c FROM Document_Category_Master__c WHERE Active__c =: true AND Consumer_Category__c =: false];
    }
    
    public static Map<Id, Document_Category_Master__c> getDocCategMapping(){
        return new Map<Id, Document_Category_Master__c>([SELECT Id, (SELECT Id, Name, Document_Category__c, Document_Type__c, Document_Type__r.Name FROM Category_Type_Mappings__r) FROM Document_Category_Master__c]);
    }
    
    public static Map<Id, List<Category_Type_Mapping__c>> getMapDocCateVsLstTypeMapping() {
        
        Map<Id, List<Category_Type_Mapping__c>> mapDocCateIdVsLstTypeMapping = new Map<Id, List<Category_Type_Mapping__c>>();
        for(Category_Type_Mapping__c cateTypeMapping : [SELECT Id, Name, Document_Category__c, Document_Type__c, Document_Type__r.Name 
                                                        FROM Category_Type_Mapping__c])
        {
            if(!mapDocCateIdVsLstTypeMapping.isEmpty() && mapDocCateIdVsLstTypeMapping.containsKey(cateTypeMapping.Document_Category__c)){
                mapDocCateIdVsLstTypeMapping.get(cateTypeMapping.Document_Category__c).add(cateTypeMapping);
            }
            else {
                mapDocCateIdVsLstTypeMapping.put(cateTypeMapping.Document_Category__c, new List<Category_Type_Mapping__c> { cateTypeMapping });
            }
        }
        return mapDocCateIdVsLstTypeMapping;
    }
    
    /*----------------------------------------------------------------------------------------
Description:    method to get the record type id 
----------------------------------------------------------------------------------------*/
    public static String getRecordTypeId(String sObjectName, String recordTypeName){
        //Generate a map of tokens for the sObjects in your organization
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        //Retrieve the describe result for the desired object
        DescribeSObjectResult result = gd.get(sObjectName).getDescribe();
        
        //Generate a map of tokens for all the Record Types for the desired object
        Map<string,Schema.RecordTypeInfo> recordTypeInfo = result.getRecordTypeInfosByName();
        
        //Retrieve the record type id by name
        Id recTypeId = recordTypeInfo.get(recordTypeName).getRecordTypeId();
        
        return recTypeId;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    
    public static void getIdentifierUUID(Sobject theSob, String fieldApiName, Enable_UUID_Objects__c enableUUIDObj){
        if(enableUUIDObj != null && enableUUIDObj.Enable__c && theSob.get(fieldApiName) == null){
            Blob blobObj = Crypto.GenerateAESKey(128);
            String strEncodingUtil = EncodingUtil.ConvertTohex(blobObj);
            String strUUID = strEncodingUtil.SubString(0,4)+ '-' + strEncodingUtil.SubString(4,8) + '-' + strEncodingUtil.SubString(8,16) + '-' + strEncodingUtil.SubString(16,20) + '-' + strEncodingUtil.substring(20);
            theSob.put(fieldApiName, strUUID);
        }
    }
    
    public static string BlobToString(Blob input, String inCharset){
        system.debug(input + '===blob===' + inCharset);
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
    
    // method for dynamic query builder for any sobject
    public static List<sobject> getAllFieldsOfObject(string action,string sobjectname,string fieldname)
    {       
        string query = 'select ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().fields.getMap();
        if (objectFields.size() > 0){
            for(string sfield:objectfields.keyset()){
                if (query == 'select '){
                    query +=  sfield ;    
                }
                else
                {
                    query += ',' + sfield ;
                }                
            }
            if (query != 'select ')
            {
                query += ' from ' + sobjectname  ;
                if (!string.isblank(fieldname) && fieldname != null)
                    query = query + ' where ' + fieldname + ' = \'' + action + '\'';
            }
            
            system.debug('<<>>'+ query);
            list<sobject> lstobject;
        }
        return  Database.query(query);
    }
    
    //update owner on case
    public static map<string,Id> getQueuesInfo(list<string> lstOfQueuesDevloperName){
        map<string,Id> mapOfQueueNameVsQueueId = new map<string,Id>();
        for(Group eachGroup : [SELECT Id,
                               DeveloperName,
                               Name 
                               FROM Group 
                               WHERE type ='queue' 
                               AND 
                               DeveloperName IN :lstOfQueuesDevloperName]){
                                   mapOfQueueNameVsQueueId.put(eachGroup.DeveloperName,eachGroup.Id);
                               }
        return mapOfQueueNameVsQueueId;
    }
    
    // ============== Create th Error Details Records ==================================
    public static void errorHandler(Exception ex, Map<String, String> messages){
        Error_Details__c theError = new Error_Details__c();
        theError.Message__c = '';
        
        if(messages != null && !messages.isEmpty()){
            Set<String> errorFields = AWSConsumerBatch.getFieldSet('Error_Details__c');
            
            for(String each : messages.keySet()){
                if(errorFields.contains(each)){
                    theError.put(each, messages.get(each));
                }else{
                    theError.Message__c += each + ': ' + messages.get(each) + '\n\n';
                }    
            }            
        }
        
        if(ex != null){            
            theError.Message__c += 'MESSAGE: '+ ex.getMessage() + '\n\n';
            theError.Message__c += 'STACK TRACE: '+ ex.getStackTraceString();           
        }
        
        Database.insert(new List<Error_Details__c>{theError}, false);
    }
    
    public static void getAllErrors(List<Database.Error> allErrors, List<String> lstErrors){
        for(Database.Error errorObj : allErrors){
            String strMsg = '';
            if(!errorObj.getFields().isEmpty()) strMsg += 'Fields: '+String.join(errorObj.getFields(), ',') +'\n';
            if(String.isNotBlank(errorObj.getMessage())) strMsg += 'Message: '+errorObj.getMessage() +'\n';
            if(errorObj.getStatusCode() != null) strMsg += 'StatusCode: '+String.valueOf(errorObj.getStatusCode());
            lstErrors.add(strMsg);            
        }
    }
    
    public static LP_HTTP_Publisher__c createHTTPPublisher(string reqbody,string ObjectName,string response, string strProcessName){		
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();		
        objHTTPPublisher.LP_Request_body__c = reqbody;		
        objHTTPPublisher.Related_Object__c = ObjectName;		
        objHTTPPublisher.LP_Response__c = response;		
        objHTTPPublisher.LP_ProcessName__c = strProcessName;		
        return objHTTPPublisher;		
    }
    
    public static void insertErrorLog(ErrorLogWrapper errorWrap){
        Error_Details__c objErrorLog = new Error_Details__c();
        objErrorLog.Message__c = errorWrap.message;
        objErrorLog.Response__c = errorWrap.response;
        objErrorLog.Request__c = errorWrap.request;
        objErrorLog.Process__c = errorWrap.process;
        objErrorLog.StackTrace__c = errorWrap.stackTrace;
        insert objErrorLog;
    }
    
    public static Map<String, String> getPLvaluesbyRT(String objectType, String recordTypeId, String fieldName) {
        
        String endpoint; 
        endpoint = '{0}/picklist-values/{1}/{2}';
        endpoint = String.format(endpoint, new String[]{ objectType, recordTypeId, fieldName });
        EncodingUtil.urlEncode(endpoint,'UTF-8');
        
        //HTTP Request send
        HttpRequest req = new HttpRequest();
        HTTPResponse res = New HTTPResponse();
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); 
        req.setEndpoint(URL.getOrgDomainUrl()+'services/data/v49.0/ui-api/object-info/'+endpoint);
        req.setMethod('GET');
        Http http = new Http();
        
        //Parse response
        Map<String,String> result = new Map<String,String>();
        If(!Test.isRunningTest()) {
            res = http.send(req);
            System.debug('@@@@res '+res);
           
            Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('@@@@@root '+root);
            if(!root.containsKey('values')){ 
                return result; 
            }
            List<Object> pValues = (List<Object>)root.get('values');
            for(Object pValue : pValues){
                Map<String,Object> pValueMap = (Map<String,Object>)pValue;
                result.put((String)pValueMap.get('value'), (String)pValueMap.get('label'));
                System.debug('@@@@@@@@' +result);
            }
        }
        return result;
    }
    
    public static void createTask(List<Task> taskList, Date activityDate, string description, Boolean isReminder, Id merchantPlanId, Id ownerId, string priority, DateTime reminderSetTime, string subject, string status, Id whatId){
        Task objTask = New Task();
        if(activityDate != null) objTask.ActivityDate = activityDate;
        if(String.isNotBlank(subject)) objTask.Subject = subject;  
        if(String.isNotBlank(whatId)) objTask.WhatId = whatId;  
        if(String.isNotBlank(status)) objTask.Status = status;  
        if(String.isNotBlank(status)) objTask.Priority = status;
        if(String.isNotBlank(ownerId)) objTask.OwnerId = ownerId;
        if(String.isNotBlank(description)) objTask.Description = description;
        objTask.IsReminderSet = isReminder;
        if(String.isNotBlank(merchantPlanId)) objTask.Merchant_Plan__c = merchantPlanId;
        if(reminderSetTime != null) objTask.ReminderDateTime = reminderSetTime;
        taskList.add(objTask);
    }
    
    public static map<string,List<GroupMember>> getQueuesNameMembers(list<string> lstOfQueuesDevloperName){
        map<string,List<GroupMember>> mapOfQueueNameVsMembers = new map<string,List<GroupMember>>();
        for(Group eachGroup : [SELECT Id,DeveloperName,Name,(SELECT Id, UserOrGroupId, GroupId FROM GroupMembers)
                               FROM Group WHERE type ='queue' AND DeveloperName IN :lstOfQueuesDevloperName]){
                                   if(mapOfQueueNameVsMembers.containsKey(eachGroup.DeveloperName)){
                                       List<GroupMember> groupMembers = mapOfQueueNameVsMembers.get(eachGroup.DeveloperName);
                                       groupMembers.addAll(eachGroup.GroupMembers);
                                       mapOfQueueNameVsMembers.put(eachGroup.DeveloperName,groupMembers);
                                   }else{
                                       List<GroupMember> groupMembers = New List<GroupMember>();
                                       groupMembers = eachGroup.GroupMembers;
                                       mapOfQueueNameVsMembers.put(eachGroup.DeveloperName,groupMembers);
                                   }
                               }
        return mapOfQueueNameVsMembers;
    }
    
    public static string MaskString(string inString, List<string> inPatterns, string inMask, integer inVisibleCharacters) {
       // validate the passed in variables
       if (inString == null || instring.length() < 1 || inPatterns == null || inPatterns.size() < 1 || inMask == null) 
           return inString;
       if (inVisibleCharacters < 0) inVisibleCharacters = 0;
        
       // prime the internal variables to be used during processing
       string stringToMask = inString;
       string maskedString = inString;
       // iterate through each pattern and mask any matches leaving the last visible characters
       for(string regEx : inPatterns) {
           Pattern p = Pattern.compile(regEx);
           Matcher m = p.matcher(stringToMask);
           while(m.find()) {
               // find the start and end indexes of the match
               integer startIdx = m.start();
               integer endIdx = m.end();
               // extract the matched string
               string patternMatch = stringToMask.substring(startIdx, endIdx);                   

               // mask the string leaving any visible characters
               string partToBeMasked = patternMatch.substring(0, patternMatch.length() - inVisibleCharacters);                                                            
               string mask = '';                                         
               for(integer i = 0; i < partToBeMasked.length(); i++) {
                   mask += inMask;
               }   
                
               // concatenate mask string with the last visible characters              
               string maskedNumber = mask + patternMatch.substring(patternMatch.length() - inVisibleCharacters);                  
                
               // replace the the card number with masked number
               maskedString = maskedString.replace(patternMatch, maskedNumber);
           }              
       }      
       return maskedString;    
   }
    
    public class ErrorLogWrapper{
        public string message;
        public string process;
        public string request;
        public string response;
        public string stackTrace;
    }
}