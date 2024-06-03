/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 22/4/2019
    @description: collection utility contains the common method for notification
*/
public class CollectionNotificationUtility {
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     get the payload information from custom metadata
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    22-Apr-19       Eitika Verma          created
    */
    public static string getWhereConditionFromMtdt(String developeName){ 
        //declare variables
        Map<String, String> mapOfWhereCondition = new Map<String, String>();
        String strCondition = '';
        
        //declare string query
        String queryStr = 'SELECT Where_Condition__c,Batch_Class_Name__c FROM CollectionProcessMapping__mdt WHERE ';        
        queryStr += 'DeveloperName = \'' + developeName + '\'';
        
        //process query
        List<CollectionProcessMapping__mdt> mtdtList = Database.query(queryStr);
        System.debug(mtdtList+'-------------->>>'+queryStr);
        //check where conditions are present or not
        if(mtdtList != NULL && mtdtList.size()>0 && mtdtList[0].Where_Condition__c != NULL){
            mapOfWhereCondition = (Map<String, String>)JSON.deserialize(mtdtList[0].Where_Condition__c, Map<String, String>.class);
        }
        
        if(mapOfWhereCondition != NULL && mapOfWhereCondition.size()>0){
            for(string eachKey : mapOfWhereCondition.keyset()){
                if(strCondition == '')
                  strCondition = eachKey + ' ' +mapOfWhereCondition.get(eachKey).substringBefore(',') +' \'' + mapOfWhereCondition.get(eachKey).substringAfter(',') + '\'';
                else
                  strCondition += ' and ' + eachKey + ' ' + mapOfWhereCondition.get(eachKey).substringBefore(',') +' \'' + mapOfWhereCondition.get(eachKey).substringAfter(',') + '\'';
            }
        }
        System.debug('strCondition=========='+strCondition);
        return strCondition;                
    }
    
    
    
    
  /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     get the payload information from custom metadata
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    22-Apr-19       Eitika Verma          created
    */
    public static List<PayloadActMap__mdt> getPayLoadMap(String developeName){        
        String queryStr = 'SELECT Action__c,Sobject__c,JsonMap__c,Field_To_Query__c FROM PayloadActMap__mdt WHERE ';        
        queryStr += 'DeveloperName = \'' + developeName + '\'';
        
        List<PayloadActMap__mdt> payloadList = Database.query(queryStr);        
        return payloadList;                
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     prepare the payload for notification like sms,app, whatsapp
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    22-Apr-19       Eitika Verma          created
    * */ 
/*   public static string preparepayloadData(Case objCase,PayloadActMap__mdt objpayload,string notificationType,map<string,Id> mapOfEmailNameVsId){
        Map<String, Object> payLoadMap = new Map<String, Object>();
        Map<String, String> jsonFieldMap;
        
        if(objpayload.JsonMap__c != NULL)
          jsonFieldMap = (Map<String, String>)JSON.deserialize(objpayload.JsonMap__c, Map<String, String>.class);
        
        if(jsonFieldMap != NULL && jsonFieldMap.size()>0){
            for(string eachNode : jsonFieldMap.keyset()){
                
                if(jsonFieldMap.get(eachNode) != NULL && jsonFieldMap.get(eachNode).substringBefore(',').contains('.')){
                    string strValue = jsonFieldMap.get(eachNode).substringBefore(',');
                    if(notificationType == 'SMS' && eachNode == 'mobile'){
                        Object objMobile = objCase.getSobject(strValue.substringBefore('.')).get(strValue.substringAfter('.'));
                        if(objMobile != NULL){
                            string strMobile = String.ValueOf(objMobile);
                            if(strMobile.startsWith('+91')){
                                strMobile = strMobile.removeStart('+91');
                                payLoadMap.put(eachNode,strMobile);
                            }
                            else
                                payLoadMap.put(eachNode,objMobile);
                        }
                        else{
                            payLoadMap.put(eachNode,null);
                        }
                    }
                    else
                      payLoadMap.put(eachNode,objCase.getSobject(strValue.substringBefore('.')).get(strValue.substringAfter('.')));
                }
                else{
                    
                    String templateName = String.ValueOf(objCase.get('LP_Email_Template_Name__c'));
                    if(eachNode == 'body' && String.isNotBlank(templateName)){
                        Messaging.SingleEmailMessage objSM = getHTMLBodyContent(mapOfEmailNameVsId.get(templateName),String.ValueOf(objCase.get('ContactId')),String.ValueOf(objCase.get('Id')));
                        payLoadMap.put(eachNode,objSM.getHtmlBody());
                    }
                    else if(eachNode == 'subject' && String.isNotBlank(templateName)){
                        Messaging.SingleEmailMessage objSM = getHTMLBodyContent(mapOfEmailNameVsId.get(templateName),String.ValueOf(objCase.get('ContactId')),String.ValueOf(objCase.get('Id')));
                        payLoadMap.put(eachNode,objSM.getSubject());
                    }
                    else
                        payLoadMap.put(eachNode,objCase.get(jsonFieldMap.get(eachNode).substringBefore(',')));
                }
            }
            payLoadMap.put('notificationType',notificationType);
            payLoadMap.put('notificationRequestId',lazypaypublish.GenerateUniqueID());
            payLoadMap.put('notificationPriority','Regular');
    }
        return JSON.serialize(payLoadMap);
    }
*/    
    
    private static Messaging.SingleEmailMessage getHTMLBodyContent(Id templateId,string whoId,string whatId){
        Messaging.SingleEmailMessage objSM = Messaging.renderStoredEmailTemplate(templateId,whoId,whatId);
        return objSM;
    }

    
      /**
    @author:          Kapil Chauhan
    @company:         SaaSFocus
    @description:     prepare the bulk payload for notification like sms,app, whatsapp
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    22-Apr-19       Eitika Verma          created
    */
    public static string prepareBulkPayloadData(List<Case> caseList ,PayloadActMap__mdt objpayload,string notificationType,map<string,Id> mapOfEmailNameVsId){
         //Map<String, EmailTemplate> mapOfEmailTemplateVsDevName =  getMapOfEmailTemplateVsDevName();
         //System.debug('Template Map Size : ' + mapOfEmailTemplateVsDevName.size() );
         Map<String , List<Map<String , Object>>> finalPayload = new Map<String , List<Map<String , Object>>>();
         List<Map<String , Object>> listOfPayloadmap = new List<Map<String , Object>>();
         Map<String, String> jsonFieldMap;
        
        if(objpayload.JsonMap__c != NULL)
          jsonFieldMap = (Map<String, String>)JSON.deserialize(objpayload.JsonMap__c, Map<String, String>.class);
        
        if(jsonFieldMap != NULL && jsonFieldMap.size()>0){
            for(Case objCase : caseList){
                Map<String, Object> payLoadMap = new Map<String, Object>();
                for(string eachNode : jsonFieldMap.keyset()){               
                   if(jsonFieldMap.get(eachNode) != NULL && jsonFieldMap.get(eachNode).substringBefore(',').contains('.')){
                    string strValue = jsonFieldMap.get(eachNode).substringBefore(',');
                    if(notificationType == 'SMS' && eachNode == 'mobile'){
                        Object objMobile = objCase.getSobject(strValue.substringBefore('.')).get(strValue.substringAfter('.'));
                        if(objMobile != NULL){
                            string strMobile = String.ValueOf(objMobile);
                            if(strMobile.startsWith('+91')){
                                strMobile = strMobile.removeStart('+91');
                                payLoadMap.put(eachNode,strMobile);
                            }
                            else
                                payLoadMap.put(eachNode,objMobile);
                        }
                        else{
                            payLoadMap.put(eachNode,null);
                        }
                    }
                    else
                      payLoadMap.put(eachNode,objCase.getSobject(strValue.substringBefore('.')).get(strValue.substringAfter('.')));
                }
                else{
                    
                    String templateName = String.ValueOf(objCase.get('LP_Email_Template_Name__c'));
                    if(eachNode == 'body' && String.isNotBlank(templateName) && mapOfEmailNameVsId.get(templateName) != null){
                        Messaging.SingleEmailMessage objSM = getHTMLBodyContent(mapOfEmailNameVsId.get(templateName),String.ValueOf(objCase.get('ContactId')),String.ValueOf(objCase.get('Id')));
                        payLoadMap.put(eachNode,objSM.getHtmlBody());
                       //UPdated BY Kapil (07-10-2019)
                       //System.debug('Temp Name : ' + templateName);
                       //System.debug('Temp Obj' + mapOfEmailTemplateVsDevName.get(templateName));
                      /* if(mapOfEmailTemplateVsDevName.containsKey(templateName)){
                          payLoadMap.put(eachNode,(Object)(mapOfEmailTemplateVsDevName.get(templateName).HtmlValue));  
                       }else{
                          payLoadMap.put(eachNode,null); 
                       } 
                      */
                    }
                    else if(eachNode == 'subject' && String.isNotBlank(templateName)){
                        Messaging.SingleEmailMessage objSM = getHTMLBodyContent(mapOfEmailNameVsId.get(templateName),String.ValueOf(objCase.get('ContactId')),String.ValueOf(objCase.get('Id')));
                        payLoadMap.put(eachNode,objSM.getSubject());
                        //UPdated BY Kapil (07-10-2019)
                        //System.debug('Temp Name : ' + templateName);
                        //System.debug('Temp Obj' + mapOfEmailTemplateVsDevName.get(templateName));
                       /* if(mapOfEmailTemplateVsDevName.containsKey(templateName)){
                            payLoadMap.put(eachNode,(Object)(mapOfEmailTemplateVsDevName.get(templateName).Subject));  
                        }else{
                            payLoadMap.put(eachNode,null); 
                        } 
                       */ 
                    }
                    else if(jsonFieldMap.get(eachNode).substringBefore(',') != 'null'){
                        payLoadMap.put(eachNode,objCase.get(jsonFieldMap.get(eachNode).substringBefore(',')));
                    }                        
                }
            }
            payLoadMap.put('notificationType',notificationType);
            payLoadMap.put('notificationRequestId',lazypaypublish.GenerateUniqueID());
            payLoadMap.put('notificationPriority','Regular');
                
            listOfPayloadmap.add(payLoadMap);             
        }
         finalPayload.put(label.notificationRequestList ,listOfPayloadmap );   
    }
        
        return JSON.serialize(finalPayload);
    }
    
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     send the request to knowlarity
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    2-Jan-19       Eitika Verma          created
    */
    public static HttpResponse sendRequest(string jsonstr,string devname,string ProcessName){
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
            //system.debug('req1============'+req.getBody());
            if(!Test.isRunningTest()){
              resp = http.send(req);
              System.debug('Response : ' + resp.getBody());  
            } 
            
            //insert http publisher records
            LP_HTTP_Publisher__c objPub =  createHTTPPublisher(jsonstr,'Case',resp.getBody(),ProcessName);
            insert objPub;
            return resp;
        }
        else 
            return null;
        
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     send the request to knowlarity
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    2-Jan-19       Eitika Verma          created
    */
    public static LP_HTTP_Publisher__c sendRequestForSMS(string jsonstr,List<Integration_Setting__mdt> insList, string ProcessName){
        System.debug('Sending request for SMS');
        HttpResponse resp = new HttpResponse();
      Http http = new Http();
        
        
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
            
            System.debug('Response : ' + resp);
            
            //insert http publisher records (Changed By Kapil Chauhan for inserting long requests (08-10-2019	))
            //LP_HTTP_Publisher__c objPub = createHTTPPublisher(jsonstr,'Case',resp.getBody(),ProcessName);
            LP_HTTP_Publisher__c objPub = createHTTPPublisherForBulkData(jsonstr,'Case',resp.getBody(),ProcessName);
            return objPub;
        }
        else 
            return null;
        
    }
    
    public static List<Integration_Setting__mdt> getIntegrationDt(string devName){
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c 
                                                    FROM Integration_Setting__mdt 
                                                    WHERE DeveloperName =:devName];
        return insList;
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     create HTTP publisher records to store the request and response
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    22-April-19       Eitika Verma          created
    */
    public static LP_HTTP_Publisher__c createHTTPPublisher(string reqbody,string ObjectName,string response,string ProcessName){
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();
        objHTTPPublisher.LP_Request_body__c = reqbody;
        objHTTPPublisher.Related_Object__c = ObjectName;
        objHTTPPublisher.LP_Response__c = response;
        objHTTPPublisher.LP_ProcessName__c = ProcessName;
        return objHTTPPublisher;
        
    }
    
   /**
    @author:          Kapil Chauhan
    @company:         SaaSFocus
    @description:     create HTTP publisher records to store the request and response for Bulk Data
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    22-April-19       Eitika Verma          created
    */
    public static LP_HTTP_Publisher__c createHTTPPublisherForBulkData(string reqbody,string ObjectName,string response,string ProcessName){
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();
        System.debug('Length  of Long Text: ' + Schema.SObjectType.LP_HTTP_Publisher__c.fields.LP_Request_body__c.getLength());
        Integer longTextFieldLength = Schema.SObjectType.LP_HTTP_Publisher__c.fields.LP_Request_body__c.getLength();
        if(reqbody.length() >= longTextFieldLength){
          objHTTPPublisher.LP_Request_body__c   =  reqbody.substring(0, longTextFieldLength - 1);
          objHTTPPublisher.Full_Request_Not_Available__c = true ;  
        }else{
          objHTTPPublisher.LP_Request_body__c = reqbody ;
        }
        objHTTPPublisher.Related_Object__c = ObjectName;
        objHTTPPublisher.LP_Response__c = response;
        objHTTPPublisher.LP_ProcessName__c = ProcessName;
        return objHTTPPublisher;
        
    }
    public static map<string,Id> getSMSTemplateId(string folderName){
        map<string,Id> mapOfTemplateVsId = new map<string,Id>();
        for(EmailTemplate eachTemplate : [Select id,name from EmailTemplate Where folder.name = :folderName ]){
            System.debug('eachTemplate name : ' + eachTemplate.name  +  'eachTemplate Id : ' +  eachTemplate.Id);
            mapOfTemplateVsId.put(eachTemplate.name,eachTemplate.Id);
        }
        system.debug('mapOfTemplateVsId========='+mapOfTemplateVsId);
        return mapOfTemplateVsId;
    }
    public static map<string,Id> getEmailTemplateId(string folderName){
        map<string,Id> mapOfTemplateVsId = new map<string,Id>();
        for(EmailTemplate eachTemplate : [Select id,developerName from EmailTemplate Where folder.name = :folderName ]){
            System.debug('eachTemplate name : ' + eachTemplate.developerName  +  'eachTemplate Id : ' +  eachTemplate.Id);
            mapOfTemplateVsId.put(eachTemplate.developerName,eachTemplate.Id);
        }
        system.debug('mapOfTemplateVsId========='+mapOfTemplateVsId);
        return mapOfTemplateVsId;
    }
    /**
    @author:          Kapil Chauhan
    @company:         SaaSFocus
    @description:     Create Task for corresponding email sent 
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    22-April-19       Eitika Verma          created
    */ 
    public static void CreateTask(List<Case> listOfCasesToSend , String activity){
        List<Task> tasklistToUpload = new List<Task>();
         for(Case caseObj : listOfCasesToSend){
            if(caseObj.contactId !=null){
                  System.debug('Creating the task');
                   Task task = new Task();
                   task.WhatId = caseObj.id;
                   task.WhoId = caseObj.contactId;
                   task.Subject = activity; 
                   task.status = 'Completed';
                   tasklistToUpload.add(task); 
             }
        }  
        insert tasklistToUpload;
    }
/*    
    public static Map<String , String> getSubjectVsEmailTemplateName(String folderName){
        Map<String , String> mapOfEmailTemplateVsSubject = new Map<String , String>();
        for(EmailTemplate temp : [SELECT id,DeveloperName,Subject,folder.Name FROM EmailTemplate where folder.Name =: folderName]){
            System.debug('Putting Dev Name :' + temp.DeveloperName);
            mapOfEmailTemplateVsSubject.put(temp.DeveloperName, temp.Subject);
        }
        return mapOfEmailTemplateVsSubject;
    }
*/
}