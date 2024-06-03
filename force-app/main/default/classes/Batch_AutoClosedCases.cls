/*
* Created Date: 4 oct 2019
* Created By: Akash Pandey
* Description: This Batch class will Closed the cases for which AutoClosedBatch__c is true.
* AutoClosedBatch__c will true current date match with Auto_Close_Date__c(AutoClosedBatch__c is a formula field).
* Auto_Close_Date__c will be populated when case status is resoled OR subStatus is waiting on merchant/buyer.
* it will populated by the process builder.
* 
* */
global class Batch_AutoClosedCases implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    public Batch_Setting__mdt batchSetting;
    public Boolean isCloseCaseUpdate;
    public Boolean isPublishReminder;
    public Boolean isPublishCloseCase;
    public List<String> casesToClosedIds = New List<String>(); 
    
    public Integer totalDays = 0;
    public static Integer totalDays_ForTestClass;/** test variable calling from test class only to increase the coverage. */
    
    public Map<string,string> panelRecordTypeIdNameMap = (Map<string,string>)JSON.deserialize(label.LP_Merchant_Care_Record_Type , Map<String,String>.class);
    public Map<string,string> EmailRecordTypeIdNameMap = (Map<string,string>)JSON.deserialize(label.ETC_RecordType , Map<String,String>.class);
    public List<String> subStatusList = new list<String> {'Waiting On Buyer','Waiting On Merchant'};    
        public List<String> statusList = new list<String> {'Pending','Resolved'};
            
            global Batch_AutoClosedCases(Boolean isCaseUpdate, Boolean isPublishToPanel, Boolean isPublishClosedCases, Set<String> closedCaseIds){
                this.isCloseCaseUpdate = isCaseUpdate;
                this.isPublishReminder = isPublishToPanel;
                this.isPublishCloseCase = isPublishClosedCases;
                this.casesToClosedIds = New List<String>(closedCaseIds);
                
                batchSetting = [SELECT MasterLabel, Iteration_Count__c,Auto_Close_Old_Cases__c, 
                                                   Record_Limit__c, Where_Clause__c,Send_Reminder_Of_Autoclosed_After_1_day__c,
                                                   Send_Reminder_Of_Autoclosed_After_2_day__c,Auto_Close_Case_After_3_Days__c 
                                                   FROM Batch_Setting__mdt WHERE MasterLabel = 'OneCareCaseAutoClose'
                                                   LIMIT 1];
                
            }
    //public static List<Case> caseListToUpdate = new List<case>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String strQuery = '';
        List<String> allRecordTypeIds = New List<String>(panelRecordTypeIdNameMap.keySet());
        if(isPublishReminder && !isCloseCaseUpdate && !isPublishCloseCase){
            strQuery = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Case')), ',');
            strQuery += ' From Case WHERE RecordTypeId IN (\'' + String.join(new List<String>(allRecordTypeIds), '\',\'') + '\')';
            strQuery += String.isNotBlank(batchSetting.Where_Clause__c) ? ' AND '+batchSetting.Where_Clause__c : '';
        }else if(!isPublishReminder && (isCloseCaseUpdate || isPublishCloseCase) && !casesToClosedIds.isEmpty()){
            strQuery = 'SELECT ' + String.join(new List<String>(AWSConsumerBatch.getFieldSet('Case')), ',');
            strQuery += ' From Case Where Id IN (\'' + String.join(new List<String>(casesToClosedIds), '\',\'') + '\')';
        }
        system.debug('>>>>>>>>>>strQuery>>>>>>>>>>'+strQuery);
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bc, List<Case> caseList){
        System.debug('>>>>>>>>>>caseList>>>>>>>>>>'+caseList);
        System.debug('>>>>>>>>>>caseList>>>>>>>>>>'+caseList.size());
        try{
            String strNotify = 'INFORMATION_REQUIRED_REMINDER';
            String devName = 'OneCareBulkUpdateForCase';
            Date startDate = Date.today();
            List<Case> casesToSendReminder = New List<Case>();
            List<Case> closeCasesToSendPanel = New List<Case>();
            List<Case> CasesToClosed = New List<Case>();
            
            if(caseList.size() >0){
                System.debug('>>>caseList'+caseList);
                for(Case eachCase: caseList){
                    System.debug('>>>eachCase'+eachCase);
                    if(!Test.isRunningTest()){ totalDays = Date.valueOf(eachCase.LastModifiedDate).daysBetween(startDate);} 
                    else{
                        totalDays = totalDays_ForTestCLass;
                    }
                    System.debug('>>>>>>totalDays>>>>>>'+totalDays);
                    System.debug('>>>>>>daysBetween System.today>>>>>>'+Date.valueOf(eachCase.LastModifiedDate).daysBetween(System.today()));
                    System.debug('>>>>>>System.Today>>>>>>'+System.today());
                    System.debug('>>>>>>date.Today>>>>>>'+Date.today());
                    if(totalDays >0 && totalDays == batchSetting.Send_Reminder_Of_Autoclosed_After_1_day__c
                       && panelRecordTypeIdNameMap.containsKey(eachCase.RecordTypeId)){
                           System.debug('>>>>>>under 1 day>>>>>>');
                           if(eachCase.Status =='Pending' && subStatusList.contains(eachCase.LP_Sub_Status__c)){
                               casesToSendReminder.add(eachCase);
                           }
                       }else if(totalDays >0 && totalDays == batchSetting.Send_Reminder_Of_Autoclosed_After_2_day__c 
                                && panelRecordTypeIdNameMap.containsKey(eachCase.RecordTypeId)){
                                    System.debug('>>>>>>under 2 day>>>>>>');
                                    if(eachCase.Status =='Pending' && subStatusList.contains(eachCase.LP_Sub_Status__c)){
                                        casesToSendReminder.add(eachCase);
                                    }
                                }else if(totalDays >0 && totalDays >= batchSetting.Auto_Close_Case_After_3_Days__c
                                         && panelRecordTypeIdNameMap.containsKey(eachCase.RecordTypeId)){
                                             System.debug('>>>>>>under auto close 3 days>>>>>>');
                                             if(eachCase.status == 'Resolved' || (eachCase.status == 'Pending' && subStatusList.contains(eachCase.LP_Sub_Status__c))){
                                                 System.debug('>>>>>>under resolved or pending>>>>>>');
                                                 if(eachCase.status == 'Pending'){
                                                     eachCase.Agent_Comments__c = 'Auto-closed due to no reply';
                                                     eachCase.Comments = 'Auto-closed due to no reply';
                                                 }
                                                 else if(eachCase.status == 'Resolved'){
                                                     eachCase.Agent_Comments__c = 'Auto-closed after resolution';
                                                     eachCase.Comments = 'Auto-closed after resolution';
                                                 } 
                                                 eachCase.Status = 'Closed';
                                                 eachCase.LP_Sub_Status__c = '';
                                                 casesToClosedIds.add(eachCase.Id);
                                                 //if(!isCloseCaseUpdate && !isPublishReminder && isPublishCloseCase) closeCasesToSendPanel.add(eachCase);
                                                 if(isCloseCaseUpdate && !isPublishReminder && !isPublishCloseCase){
                                                     System.debug('>>>>>>under close case added>>>>>>');
                                                     CasesToClosed.add(eachCase);
                                                     closeCasesToSendPanel.add(eachCase);
                                                 } 
                                             }
                                         }
                }              
            }
            if(casesToSendReminder.size() >0) preparepayload(casesToSendReminder,devName,strNotify);
            
            
            System.debug('>>>>>>>>>>closeCasesToSendPanel>>>>>>>>>>'+CasesToClosed);
            if(!closeCasesToSendPanel.isEmpty()){
                List<LP_HTTP_Publisher__c> listPublisher = preparepayload(closeCasesToSendPanel,devName,'');
            } 
            System.debug('>>>>>>>>>>CasesToClosed>>>>>>>>>>'+CasesToClosed);
            if(!CasesToClosed.isEmpty()) update CasesToClosed;
        }catch(Exception ex){
            sendExceptionEmail(ex,'Execute');
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
        }
    } 
      
    public static List<LP_HTTP_Publisher__c> preparepayload(List<Case> caseListToUpdate,string devName,string strNotify){
        try{
            List<Case> caseList = new List<Case>();
            //declare variables
            PayloadActMap__mdt objPayload;
            list<LP_HTTP_Publisher__c> lstPub = new list<LP_HTTP_Publisher__c>();
            
            //get payload data from custom metadata which needs to be publish
            map<string,PayloadActMap__mdt> mapOfObjectVsPayload = CareUtility.getPayloadData('OneCareCaseAutoClose');
            if(mapOfObjectVsPayload != NULL && mapOfObjectVsPayload.size()>0 && mapOfObjectVsPayload.containsKey('Case'))
                objPayload = mapOfObjectVsPayload.get('Case');
            //get Integration settings from custom metadata
            List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c 
                                                      FROM Integration_Setting__mdt 
                                                      WHERE DeveloperName =:devName];
            
            //get AccessToken to publish the data in care panel
            string strAccessToken;
            If(!Test.isRunningTest())
                strAccessToken = CarePanelUtility.getAccessToken();
            else
                strAccessToken = '544555';
            system.debug('strAccessToken======='+strAccessToken);
            
            //get Case Data
            if(objPayload != NULL ){
                //string strquery = 'SELECT id,'+objPayload.Field_To_Query__c+' FROM Case WHERE ID IN:lstCaseId';
                Map<String, String> mapOfPayloadStructure = (Map<String, String>)JSON.deserialize(objPayload.JSONMapPub__c, Map<String, String>.class);
                //caseList = Database.query(strquery);
                
                string strPayload = prepareRequestBody(caseListToUpdate,mapOfPayloadStructure,strNotify);
                //String strPayload = JSON.serialize(strPayloadList);
                LP_HTTP_Publisher__c objPub = sendDataToCarePanel(strPayload,caseListToUpdate,strAccessToken,insList);
                lstPub.add(objPub);
                
            }
            system.debug('lstPub======='+lstPub);
            insert lstPub;
            System.debug('>>>>>>lstPub>>>>>>'+lstPub);
            return lstPub;
        }catch(Exception ex){
            sendExceptionEmail(ex,'preparepayload');
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
            return null;
        }
        
    }
    
    public static string prepareRequestBody(List<Case> caseList, Map<String, String> mapOfPayload,string strNotify){
        try{
            system.JSONGenerator gen = JSON.createGenerator(true);
            map<string,object> mapOfPublishPayload = new map<string,object>();
            List<string> strList = new List<string>();
            
            if(caseList.size() > 0){
                for(Case eachCase: caseList){
                    if(mapOfPayload != NULL && mapOfPayload.size()>0){
                        for(string eachKey : mapOfPayload.keyset()){
                            if(mapOfPayload.get(eachKey).contains('.'))
                                mapOfPublishPayload.put(eachKey,eachCase.getSObject(mapOfPayload.get(eachKey).substringBefore('.')).get(mapOfPayload.get(eachKey).substringAfter('.')));
                            else{
                                if(eachKey == 'expectedClosureDate'){
                                    if(eachCase.get(mapOfPayload.get(eachKey)) != NULL){
                                        DateTime dt = DateTime.ValueOf(eachCase.get(mapOfPayload.get(eachKey)));
                                        string strDtime = dt.format('yyyy-MM-dd HH:mm:ss','Asia/Kolkata');
                                        mapOfPublishPayload.put(eachKey,(Object)strDtime);
                                    }
                                    mapOfPublishPayload.put(eachKey,eachCase.get(mapOfPayload.get(eachKey)));
                                }
                                else
                                    mapOfPublishPayload.put(eachKey,eachCase.get(mapOfPayload.get(eachKey)));
                            }
                            
                        }
                        if(String.isNotBlank(strNotify))
                            mapOfPublishPayload.put('notify',strNotify); //'TAT_EXCEEDED'
                        
                        strList.add(JSON.serialize(mapOfPublishPayload));
                    }
                    
                }
                
                gen.writeStartObject();
                gen.writeFieldName('tickets');
                gen.writeStartArray();
                for(String str:strList){
                    gen.writeObject(JSON.deserializeUntyped(str));
                }
                
                gen.writeEndArray();
                gen.writeEndObject();
            }
            return gen.getAsString();
        }catch(Exception ex){
            sendExceptionEmail(ex,'prepareRequestBody');
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
            return null;
        }
        
    }
    
    public static LP_HTTP_Publisher__c sendDataToCarePanel(string strPayload,List<Case> caseList,string strAccessToken,list<Integration_Setting__mdt> insList){
        try{
            
            LP_HTTP_Publisher__c objHTTP;
            Map<String,String> attachmetDataMap = new Map<String,String>();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            
            if(insList!= null && insList.size()>0){
                string strEndPointURL = '';
                HttpRequest req = new HttpRequest();
                req.setMethod(insList[0].Method__c);
                strEndPointURL = insList[0].EndPointUrl__c;
                
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
                
                //Object obj = json.deserializeUntyped(strPayload);
                req.setBody(strPayload);
                
                if(!Test.isRunningTest())
                    resp = http.send(req);
            }
            
            //create http publisher records
            objHTTP = CarePanelUtility.createHTTPPublisher(strPayload,'Case',resp.getBody(), null,'Batch_AutoClosedCases');
            
            return objHTTP;
        }catch(Exception ex){
            sendExceptionEmail(ex,'sendDataToCarePanel');
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
            return null;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        if(isPublishReminder && !isCloseCaseUpdate && !isPublishCloseCase && !casesToClosedIds.isEmpty()){
            Database.executeBatch(New Batch_AutoClosedCases(true,false,false,New Set<String>(casesToClosedIds)),10);
        }else if(!isPublishReminder && isCloseCaseUpdate && !isPublishCloseCase && !casesToClosedIds.isEmpty()){
            //Database.executeBatch(New Batch_AutoClosedCases(false,false,true,New Set<String>(casesToClosedIds)));
        }
    }    
    
    /** Private method to send the email with details for any exception in the process.
	* @param 1 : Instance of Exception.
	* @param 2 : Name of the method which will produce the exception.
	*/
     @TestVisible 
    private static void sendExceptionEmail(Exception ex,String methodName){
        List<User> userList = [SELECT Id,Email FROM User WHERE Email = 'david.simon@payu.in' LIMIT 1];
        if(!userList.isEmpty()){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Batch_AutoClosedCases Exception Notification.');
            String emailBody = 'Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber()+' method:: '+methodName;
            email.setPlainTextBody(emailBody);
            email.setTargetObjectId(userList[0].Id);
            email.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }/** END */
    
}