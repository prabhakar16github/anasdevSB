/*
* Created Date: 02 Nov 2020
* Created By: Sneha Sahi
* Description: Send daily updates regarding Neo Banking Account Status from RBL to Dashboard
*/
global class Batch_updateNeoBankingAccounts implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    
    public string batchSettingName = '';
    public Batch_Setting__mdt batchSetting;
    Map<string,string> statusValueLabelMap = new Map<string,string>();
    Map<string,string> subStatusValueLabelMap = New Map<string,string>();
    list<case> caseListToUpdate = new list<case>();
        
    global Batch_updateNeoBankingAccounts(string batchName){
        this.batchSettingName = batchName;
        batchSetting = [SELECT MasterLabel, Iteration_Count__c, Where_Clause__c,Re_Run_Apex_Job__c FROM Batch_Setting__mdt WHERE MasterLabel =:this.batchSettingName LIMIT 1];
        Schema.DescribeFieldResult fieldStatusResult = Schema.SObjectType.Case.fields.Status.getSobjectField().getDescribe();
        Schema.DescribeFieldResult fieldSubStResult = Schema.SObjectType.Case.fields.LP_Sub_Status__c.getSobjectField().getDescribe();
       
        for(PickListEntry ent : fieldStatusResult.getPicklistValues()){
            if(ent.getLabel() != ent.getValue())
            	statusValueLabelMap.put(ent.getValue(),ent.getLabel());
        }
        for(PickListEntry each : fieldSubStResult.getPicklistValues()){
            if(each.getLabel() != each.getValue())
            	subStatusValueLabelMap.put(each.getValue(),each.getLabel());            
        }
       
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        PayloadActMap__mdt objPayload;
        map<string,PayloadActMap__mdt> mapOfObjectVsPayload = CareUtility.getPayloadData('updateNeoBanking');
        if(mapOfObjectVsPayload != NULL && mapOfObjectVsPayload.size()>0 && mapOfObjectVsPayload.containsKey('Case'))
            objPayload = mapOfObjectVsPayload.get('Case');
        
        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NeoBanking').getRecordTypeId();
        list<string> statusList = new list<string>{'New','Closed'};
        System.debug('batchSetting:::'+batchSetting);
        String strQuery = 'SELECT Id, '+objPayload.Field_To_Query__c+ ' FROM Case ' ;
        strQuery += String.isNotBlank(batchSetting.Where_Clause__c) ?  batchSetting.Where_Clause__c : '';
         
        system.debug('strQuery=='+strQuery);
        //list<Case> caseList = Database.query(strQuery);
        //system.debug('query output=='+caseList.size());
        return Database.getQueryLocator(strQuery);
    }
    
    
    global void execute(Database.BatchableContext bc, List<Case> caseList){
        try{
        
        String devName = 'NeoBankingBulkUpdate';
        for(case eachCase : caseList){
            if(eachCase.Status != null && eachCase.Merchant_Id__c != null){
                eachCase.isBulkUpdateSent__c = true;
                caseListToUpdate.add(eachCase);
            }
        }
        
            if(caseListToUpdate != null && caseListToUpdate.size()>0){ 
                preparepayload(caseListToUpdate,devName,statusValueLabelMap,subStatusValueLabelMap);
                update caseListToUpdate;
            }
        }catch(Exception ex){
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
        }
    }
    
    public static List<LP_HTTP_Publisher__c> preparepayload(List<Case> caseListToUpdate,string devName,Map<string,string> statusValueLabelMap,Map<string,string> subStatusValueLabelMap){
        
        try{
        list<LP_HTTP_Publisher__c> lstPub = new list<LP_HTTP_Publisher__c>();
        //get Integration settings from custom metadata
        List<Integration_Setting__mdt> insList = [SELECT Id, Body__c, EndPointUrl__c, Headers__c, Method__c 
                                                      FROM Integration_Setting__mdt 
                                                      WHERE DeveloperName =:devName];
        
        //get AccessToken to publish the data in care panel
        string strAccessToken;
        If(!Test.isRunningTest())
            strAccessToken = getAccessToken();
        else
            strAccessToken = '544555';
        system.debug('strAccessToken======='+strAccessToken);
        
        
        //Prepare Request Body
         string strPayload = prepareRequestBody(caseListToUpdate,statusValueLabelMap,subStatusValueLabelMap);
        
        LP_HTTP_Publisher__c objPub = sendDataToDashboard(strPayload,caseListToUpdate,strAccessToken,insList);
        lstPub.add(objPub);
        system.debug('lstPub======='+lstPub);
            //if(!test.isRunningTest())
        		insert lstPub;
        return lstPub;
        }catch(Exception ex){
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
            return null;
        }
       
    }
    
    Public Static String getAccessToken(){
        
        Http http = new Http();
        HttpResponse resp = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(Label.NeoBankingAuthToken);
        If(!Test.isRunningTest()){
        	resp = http.send(req);
            system.debug('resp======'+resp.getStatus());
            map<string,Object> mapOfResponse = (map<string,Object>)JSON.deserializeUntyped(resp.getBody());
            system.debug('mapOfResponse======'+mapOfResponse);
            return String.ValueOf(mapOfResponse.get('access_token'));
        }         
        else return '3456789';
   }
    

    Public Static String prepareRequestBody(List<case> caseListToUpdate,Map<string,string> statusValueLabelMap,Map<string,string> subStatusValueLabelMap){
        
        try{
            
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('data');
            gen.writeStartArray();
            for(case eachCase : caseListToUpdate){
                String StatusLabel = statusValueLabelMap.get(eachCase.Status);
                String subStatusLabel = subStatusValueLabelMap.get(eachCase.LP_Sub_Status__c);
                String AccLoginDate = eachCase.Account_Login_Date__c != null ? formatDate(eachCase.Account_Login_Date__c) : '';
                String AccOpeningDate = eachCase.Account_Opening_Date__c !=null ? formatDate(eachCase.Account_Opening_Date__c) : '';
            system.debug('StatusLabel=='+StatusLabel);
            system.debug('subStatusLabel=='+subStatusLabel);
            // Write data to the JSON string.
            gen.writeStartObject();
            gen.writeFieldName(eachCase.Merchant_Id__c);
            gen.writeStartObject();
            gen.writeFieldName('status');
            gen.writeStartObject();
            gen.writeStringField('value',StatusLabel);
            gen.writeStringField('description',eachCase.Status);
            gen.writeFieldName('subStatus');
            gen.writeStartObject();
            gen.writeStringField('value',eachCase.LP_Sub_Status__c);
            gen.writeStringField('description',subStatusLabel);
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeStringField('ownership',eachCase.OwnerShip__c);
            gen.writeStringField('rmPhone',eachCase.RBL_RM_Contact_Number__c);
            gen.writeStringField('rmName',eachCase.RBL_Relationship_Manager_Name__c);
            gen.writeStringField('accLoginDate',AccLoginDate);
            gen.writeStringField('accOpeningDate',AccOpeningDate);
            gen.writeStringField('TicketId',eachCase.Identifier__c);
            gen.writeEndObject();
            gen.writeEndObject();
            
            }
            gen.writeEndArray();
            gen.writeEndObject();
            system.debug('gen.getAsString=='+gen.getAsString());
            return gen.getAsString();
        }
       	catch(Exception ex){
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
            return null;
        }
        
    }
    
    Public Static LP_HTTP_Publisher__c sendDataToDashboard(string strPayload,List<Case> caseList,string strAccessToken,list<Integration_Setting__mdt> insList){
        try{
            
            LP_HTTP_Publisher__c objHTTP;
            
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            
            if(insList!= null && insList.size()>0){
                string strEndPointURL = '';
                HttpRequest req = new HttpRequest();
                req.setMethod(insList[0].Method__c);
                strEndPointURL = insList[0].EndPointUrl__c;
                
                
                req.setEndPoint(strEndPointURL);
                System.debug('Headers::'+insList[0].Headers__c);
                System.debug('strEndPointURL::'+strEndPointURL);
                
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
                    System.debug('req 1>>>'+req.getBody());
                if(!Test.isRunningTest())
                    resp = http.send(req);
            }
            System.debug('resp 1>>>'+resp.getStatusCode());
            System.debug('resp 1>>>'+resp.getBody());
            
            //create http publisher records
            objHTTP = CarePanelUtility.createHTTPPublisher(strPayload,'Case',resp.getBody(), null);
            return objHTTP;
        }catch(Exception ex){
            System.debug('Error Message:: '+ex.getMessage()+' Line No:: '+ex.getLineNumber());
            return null;
        }
        
    }
    
    private static string formatDate(date dateToFormat){
        String ReturnString = dateToFormat.day()+'-'+dateToFormat.month()+'-'+dateToFormat.year();
        system.debug('ReturnString=='+ReturnString);
        return ReturnString;
    }
    
    global void finish(Database.BatchableContext bc){
        
    } 
    
    
}