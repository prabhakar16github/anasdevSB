public class lazyPayPublish {
    
    static list<LP_HTTP_Publisher__c> lstPublishTrack = new list<LP_HTTP_Publisher__c>();
    static Map<string,LP_HTTP_Publisher__c> mapPublishTrack = new  Map<string,LP_HTTP_Publisher__c>();
    static map<Id,Case> mapOfContactIdVsCase = new map<Id,Case>();
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       call out for Contact when document information get updated
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/    
    public static void sendPayLoaddata(list<sobject> triggerNew,map<ID,sobject> maptriggerold,string objectName,map<Id,list<LP_KYC_Document__c>> mapOfCaseIdVslistOfKYCDoc)
    { 
        boolean sendPayLoad;
        boolean sendPayLoadForCaseStatus;
        boolean sendPayLoadForCaseState;
        List<PayloadActMap__mdt> queriedList;
        List<PayloadActMap__mdt> queriedListForCaseStatus;
        List<PayloadActMap__mdt> queriedListForCaseState;
        
        if (objectName =='Case'){
            queriedListForCaseStatus = SystemUtility.getAllFieldsOfObject('updateKYCcasestatus','PayloadActMap__mdt','DeveloperName');
            queriedListForCaseState = SystemUtility.getAllFieldsOfObject('UpdateKYCcasestate','PayloadActMap__mdt','DeveloperName');
        }
        else if (objectName =='Contact'){
            queriedList = systemutility.getAllFieldsOfObject('updateKYCcontactdetail','PayloadActMap__mdt','DeveloperName');
            //get the KYC case details
            mapOfContactIdVsCase = getCaseInfo(triggerNew);
        }
        
        
        for (sobject eachObj:triggerNew)
        {
            sendPayLoad=false;
            sendPayLoadForCaseStatus=false;
            sendPayLoadForCaseState=false;
            
            sobject oldEachObj = maptriggerold.get(eachObj.Id);  
            if (objectName =='Case'){
                if ((oldEachObj.get('Status') !=  eachObj.get('Status') || oldEachObj.get('LP_Sub_Status__c') !=  eachObj.get('LP_Sub_Status__c'))
                    && eachObj.get('Status') =='Pending' && eachObj.get('LP_Sub_Status__c') =='Additional Documents Requested'){
                        sendPayLoadForCaseStatus=True;  
                    }
                if (oldEachObj.get('Status') !=  eachObj.get('Status')
                    && (eachObj.get('Status') =='Approved' || eachObj.get('Status') =='Rejected')){
                        sendPayLoadForCaseState=True;
                        system.debug('help');
                    }
            }
            else if (objectName =='Contact'){
                for(String eachStr : queriedList[0].FieldsCheck__c.split(',')){  
                    if(eachObj.get(eachStr) != oldEachObj.get(eachStr)){
                        if (objectName =='Contact'){
                            sendPayLoad = true;
                            break;
                        }
                    }
                }
            }    

            if (sendPayLoad == True || sendPayLoadForCaseStatus == True || sendPayLoadForCaseState == True){
                list<sobject> lstsObject = new list<sobject>();
                lstsObject.add(eachObj);
                if (sendPayLoad){
                    lazyPayPublish.PublishPayLoad(lstsObject,eachObj,queriedList,objectName,True);
                }
                if (sendPayLoadForCaseStatus){
                    lazyPayPublish.PublishPayLoad(lstsObject,eachObj,queriedListForCaseStatus,objectName,True);
                }
                if (sendPayLoadForCaseState){
                    if(mapOfCaseIdVslistOfKYCDoc != null && mapOfCaseIdVslistOfKYCDoc.size()>0){
                        list<PayloadActMap__mdt> thePayLoadMap = SystemUtility.getAllFieldsOfObject('updateKYCcasedetails','PayloadActMap__mdt','DeveloperName');
						list<LP_KYC_Document__c> lstKycDocument = mapOfCaseIdVslistOfKYCDoc.get(eachObj.Id);
                        LazyPayPublish.PublishPayLoad(lstKycDocument,lstKycDocument[0],thePayLoadMap,'Case',True);
                    }
                    
                }
                
            }
        }
        CreateHTTPPublisher();
       
    }   
    
   
     /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       Used to publish the payload date
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static void PublishPayLoad(list<sobject> lstsObject,sobject eachObj,List<PayloadActMap__mdt> queriedList,string objectName,Boolean isTriggerFlag)
    {
        String thePayLoad = '';
        
        clspayLoadGenerator objclspayload = new clspayLoadGenerator();
        objclspayLoad.lstsObject = lstsObject;
        objclspayLoad.thePayLoadMap=queriedList[0];
        objclspayLoad.objsobject = eachObj;
        objclspayLoad.objectName  = objectName;
        objclspayLoad.Uniqueid = lazypaypublish.GenerateUniqueID();
        
        thePayLoad = lazyPayPublish.payLoadGenerator(objclspayload);
        
        system.debug('<<thePayLoad>>'+ thePayLoad);
        
        if (!string.isblank(thePayLoad) && thePayLoad != null)
            lazyPayPublish.PublishData(thePayLoad); 
    }
    
    public Static Void CreateHTTPPublisher()
    {
        list<LP_HTTP_Publisher__c> lstLPPublishTrackRecords  = mapPublishTrack.values(); 
        if (!lstLPPublishTrackRecords.isempty())
        upsert lstLPPublishTrackRecords;
        system.debug('lstLPPublishTrackRecords========='+lstLPPublishTrackRecords);
    }

     /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       call out for Case when document information get updated 
    @future(callout=true)
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/ 
    public static void SendPayloadCaseData(set<id> KycDocIds)
    {
        String thePayLoad = '';
        list<PayloadActMap__mdt> thePayLoadMap = SystemUtility.getAllFieldsOfObject('updateKYCcasedetails','PayloadActMap__mdt','DeveloperName');
        list<LP_KYC_Document__c> lstkycDoc = GetObjectData('LP_KYC_Document__c',thePayLoadMap,KycDocIds);
        map<ID,list<LP_KYC_Document__c>> mapKYCDocbyCaseId = new map<ID,list<LP_KYC_Document__c>>();
       
        for ( LP_KYC_Document__c objKYCDoc:lstkycDoc){
            if (!mapKYCDocbyCaseId.containskey(objKYCDoc.LP_Case__c)){
                list<LP_KYC_Document__c> lstKycDocument = new list<LP_KYC_Document__c>();
                lstKycDocument.add(objKYCDoc);
                mapKYCDocbyCaseId.put(objKYCDoc.LP_Case__c,lstKycDocument);
            }
            else
            {
                mapKYCDocbyCaseId.get(objKYCDoc.LP_Case__c).add(objKYCDoc);
            }
        }
        
        for (string strCaseid : mapKYCDocbyCaseId.keyset()){
            lstKycDoc = mapKYCDocbyCaseId.get(strCaseid);
            LazyPayPublish.PublishPayLoad(lstKycDoc,lstKycdoc[0],thePayLoadMap,'Case',false);
        }
        CreateHTTPPublisher();
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       get all fields of Object using Custom metadataType
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/
    public static list<sobject> GetObjectData(string ObjectName,list<PayloadActMap__mdt> lstMetadata,set<id> ids){
        
        string strquery = 'select ';
        if (!lstmetadata.isempty())
        {
            strquery += lstMetadata[0].Field_To_Query__c;
            strquery += ' from ' + ObjectName + ' where ID IN:ids' ;
        }
system.debug('strquery===='+strquery);
        return database.query(strquery);
    } 
    
     /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       To generate the payload structure
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/  
    public static String payLoadGenerator(clspayLoadGenerator clsPayLoad){ 
        system.debug('clsPayLoad======'+clsPayLoad);
        string returnPayLoad;
        string strFieldValue;
        string strField;
        string Uniqueid;
        object uuid;
        Map<String, Object> payLoadMap = new Map<String, Object>();
        Map<String, Object> finalPayLoadMap = new Map<String, Object>();
        Map<String, String> jsonFieldMap;
        
        if(String.isNotBlank(clsPayLoad.thePayLoadMap.JSONMapPub__c)){
            if (clsPayLoad.thePayLoadMap.JSONMapPub__c != null && string.isNotBlank(clsPayLoad.thePayLoadMap.JSONMapPub__c)){
                jsonFieldMap = (Map<String, String>)JSON.deserialize(clsPayLoad.thePayLoadMap.JSONMapPub__c, Map<String, String>.class);
            }
            if(jsonFieldMap != null && !jsonFieldMap.isEmpty()){ 
                
                for(String each : jsonFieldMap.keySet()){ 
                    system.debug('each========='+each);
                    for(String eachStr : jsonFieldMap.get(each).split(';')){
                        if(String.isNotBlank(eachStr.subStringBefore(','))){
                            
                            if (eachStr.subStringBefore(',').contains('.')){
                                
                                strField = eachStr.subStringBefore(',');
                                strFieldValue = eachStr.subStringBefore(',').replace('.','@');
                                string[] lstStrFieldValue = strFieldValue.split('@');
                                
                                switch on lstStrFieldValue.size() {
                                    when 2 {        // when block 1
                                        if (lstStrFieldValue[1] =='status' && clsPayLoad.objectName == 'Case'){
                                            payLoadMap.put(each, string.valueof(clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).get(lstStrFieldValue[1])).toUppercase());
                                        }
                                        else
                                        {
                                            if (string.valueof(lstStrFieldValue[0]).contains('__r'))
                                            {
                                                system.debug('each======'+each);
                                                system.debug('lstStrFieldValue[1]======'+lstStrFieldValue[1]);
                                                system.debug('clsPayLoad.objsobject======'+clsPayLoad.objsobject);
                                                system.debug('objectVal======'+clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]));
                                                system.debug('fieldVal======'+clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).get(lstStrFieldValue[1]));
                                                if(each == 'uuid')
                                                    uuid = clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).get(lstStrFieldValue[1]);
                                                if(each == 'product' && clsPayLoad.objectName == 'Case'){
                                                    payLoadMap.put(each, valueFormatToUpperCase(String.ValueOf(clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).get(lstStrFieldValue[1]))));
                                                }
                                                 else if (each == 'kycstate' && clsPayLoad.objectName == 'Case') 
                                                {
                                                    payLoadMap.put(each, valueFormatToUpperCase(string.valueof(clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).get(lstStrFieldValue[1]))));    
                                                }
                                                else{
                                                    payLoadMap.put(each, clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).get(lstStrFieldValue[1]));
                                                }
                                            }
                                            else
                                            {
                                                if(each == 'product' && clsPayLoad.objectName == 'Case'){
                                                    payLoadMap.put(each, valueFormatToUpperCase(String.ValueOf(clsPayLoad.objsobject.get(strField))));
                                                }
                                                else if (each == 'kycstate' && clsPayLoad.objectName == 'Case') 
                                                {
                                                    payLoadMap.put(each, valueFormatToUpperCase(string.valueof(clsPayLoad.objsobject.get(strField))));    
                                                }
                                                else{
                                                    payLoadMap.put(each, clsPayLoad.objsobject.get(strField));
                                                }
                                            }
                                        }    
                                        
                                    }   
                                    when 3 {        // when block 2
                                        if(each == 'product' && clsPayLoad.objectName == 'Case'){
                                            payLoadMap.put(each, valueFormatToUpperCase(String.ValueOf(clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).getsobject(lstStrFieldValue[1]).get(lstStrFieldValue[2]))));
                                         }
                                          else if (each == 'kycstate' && clsPayLoad.objectName == 'Case') 
                                        {
                                            payLoadMap.put(each, valueFormatToUpperCase(string.valueof(clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).getsobject(lstStrFieldValue[1]).get(lstStrFieldValue[2]))));    
                                        }
                                         else{
                                            payLoadMap.put(each, clsPayLoad.objsobject.getsobject(lstStrFieldValue[0]).getsobject(lstStrFieldValue[1]).get(lstStrFieldValue[2]));
                                         }
                                    }
                                }
                            }
                            else
                            {  
                                if (clsPayLoad.objectName == 'Case' && eachStr.subStringbefore(',') == 'LP_Sub_Status__c') 
                                {
                                    payLoadMap.put(each, valueFormatToUpperCase(string.valueof(clsPayLoad.objsobject.get(eachStr.subStringbefore(',')))));    
                                }
                                else if (clsPayLoad.objectName == 'Case' && eachStr.subStringbefore(',') == 'LP_KYC_State__c') 
                                {
                                    payLoadMap.put(each, valueFormatToUpperCase(string.valueof(clsPayLoad.objsobject.get(eachStr.subStringbefore(',')))));    
                                }
                                else
                                {
                                    if(each == 'uuid'){
                                        uuid = clsPayLoad.objsobject.get(eachStr.subStringbefore(','));
                                        payLoadMap.put(each, clsPayLoad.objsobject.get(eachStr.subStringbefore(','))); 
                                    }
                                    else if(clsPayLoad.objectName =='Contact' && each == 'kycCaseId' && mapOfContactIdVsCase!= NULL){
                                        payLoadMap.put('kycCaseId',mapOfContactIdVsCase.get(String.ValueOf(clsPayLoad.objsobject.get(eachStr.subStringbefore(',')))).Identifier__c);
                                    }
                                    else if(clsPayLoad.objectName =='Contact' && each == 'product' && mapOfContactIdVsCase!= NULL){
                                        payLoadMap.put('product',valueFormatToUpperCase(mapOfContactIdVsCase.get(String.ValueOf(clsPayLoad.objsobject.get(eachStr.subStringbefore(',')))).LP_Product__c));
                                    }
                                    else if(each == 'product' && clsPayLoad.objectName == 'Case'){
                                        payLoadMap.put(each, valueFormatToUpperCase(String.ValueOf(clsPayLoad.objsobject.get(eachStr.subStringbefore(',')))));
                                    }
                                    else{
                                        payLoadMap.put(each, clsPayLoad.objsobject.get(eachStr.subStringbefore(',')));
                                    }
                                }
                                
                            }
                            break;                            
                        } 
                        else
                        {
                            
                            //traversing for the blank value
                            if (clsPayLoad.thePayLoadMap.ArrayNodes__c.contains(each))  
                            {
                                payLoadMap.put(each, getObjectDataforArray(clsPayLoad.lstsobject, clsPayLoad.thePayLoadMap,each));   
                            }
                        }
                    }                                              
                }
            }
        }
        system.debug('clsPayLoad.objectName=========='+clsPayLoad.objectName);
        
        if(clsPayLoad.objectName =='Contact'){
            payLoadMap.put('caseStatus','EDIT_AADHAAR_FORM');
        }
        system.debug('payLoadMap=========='+payLoadMap);
        payLoadMap.put('username',userInfo.getName());
        payLoadMap.put('payloadId',clsPayLoad.Uniqueid);
        //payLoadMap.put('timestamp', System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));    
        payloadMap.put('overrideExistingData','false');
              
        //prepare final payload
        finalPayLoadMap.put('business_object',clsPayLoad.thePayLoadMap.Business_Object__c);
        finalPayLoadMap.put('action',clsPayLoad.thePayLoadMap.Action__c);
        finalPayLoadMap.put('producer','Salesforce');
        finalPayLoadMap.put('product','LazyPay');
        finalPayLoadMap.put('identifier',uuid);
        finalPayLoadMap.put('current_data',payLoadMap);
        finalPayLoadMap.put('timestamp', System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));
        returnPayLoad = JSON.serialize(finalPayLoadMap);
        system.debug('<<json>>'+returnPayLoad);
        lazypaypublish.Createpublishtrackdata(clsPayLoad,returnPayLoad);
        return returnPayLoad; 
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       To track the payload data which we are publishing(insert publish in LP_HTTP_Publisher__c object)
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/ 
    public static void Createpublishtrackdata(clspayLoadGenerator clsPayLoad,string returnPayLoad){
        
        LP_HTTP_Publisher__c objHTTPPublisher = new LP_HTTP_Publisher__c();
        objHTTPPublisher.LP_UniqueID__c = clsPayLoad.Uniqueid;
        objHTTPPublisher.LP_Request_body__c = returnPayLoad;
        objHTTPPublisher.Related_Object__c = clsPayLoad.objectName;
        lstPublishtrack.add(objHTTPPublisher);
        
        mapPublishTrack.put(objHTTPPublisher.LP_UniqueID__c,objHTTPPublisher);
    }
    
     /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       To prepare the data for kyc document and pass this info as an array in payload
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/ 
    public static list<map<string,object>> getObjectDataforArray(list<sobject> theData, PayloadActMap__mdt thePayLoadMap,string NodeName){
        map<string,object> complexDataMap= new map<string,object>();
        list<map<String,object>> lstmaparrayfield = new list<map<String,object>>();
        Map<String, String> complexNodeMap;
        Map<String, String> subcomplexNodeMap;
        if(thePayLoadMap != null && theData != null){
            if(String.isNotBlank(thePayLoadMap.JsonMapComp__c)){
                if (thePayLoadMap.JsonMapComp__c != null && string.isnotblank(thePayLoadMap.JsonMapComp__c)){
                    complexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JsonMapComp__c, Map<String, String>.class);
                }
                if (thePayLoadMap.JSON_Map_sub_key_complex__c != null && string.isnotblank(thePayLoadMap.JSON_Map_sub_key_complex__c)){
                    subcomplexNodeMap = (Map<String, String>)JSON.deserialize(thePayLoadMap.JSON_Map_sub_key_complex__c, Map<String, String>.class);                
                }
                
                string strValue;
                if(complexNodeMap != null && complexNodeMap.size() > 0 ){
                    for (sobject eachObject:theData){
                        map<String,object> arrayField = new map<string,object>();
                        
                        for(String eachStr : complexNodeMap.get(NodeName).split(';')){   
                            if(String.isNotBlank(eachStr.subStringAfter(':'))){
                                if (eachStr.subStringAfter(':').contains('.')){
                                    strValue = eachStr.subStringAfter(':');
                                    arrayField.put(eachStr.subStringBefore(':'), eachObject.getsobject(strValue.substringbefore('.')).get(strValue.subStringAfter(':').subStringafter('.')));
                                }
                                else{
                                    arrayField.put(eachStr.subStringBefore(':'), eachObject.get(eachStr.subStringAfter(':').subStringBefore(',')));    
                                }  
                            }
                            else{
                                if (subcomplexNodeMap != null && subcomplexNodeMap.size()> 0){
                                    Map<String, Object> innercomplexDatamap = new Map<String, Object>();
                                    for(String eachSubStr : subcomplexNodeMap.get(eachStr.subStringBefore(':')).split(';')){                            
                                        if(String.isNotBlank(eachSubStr.subStringAfter(':'))){
                                            if (eachSubStr.subStringAfter(':').substringafter(',') == 'string'){
                                                innercomplexDatamap.put(eachSubStr.subStringBefore(':'), eachObject.get(eachSubStr.subStringAfter(':').subStringBefore(',')));
                                            }
                                            else{
                                                
                                                integer i=0;
                                                if (eachObject.get(eachSubStr.subStringAfter(':').substringbefore(',')) != null)
                                                for(String eachInnerSubStr : string.valueof(eachObject.get(eachSubStr.subStringAfter(':').substringbefore(','))).split(';')){
                                                    if ( eachInnerSubStr != null ){
                                                        innercomplexDatamap.put(string.valueof(i),eachInnerSubStr);
                                                        i++;
                                                    }    
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                    arrayField.put(eachStr.subStringBefore(':'),innercomplexDatamap);
                                }
                            }
                        }
                        if (arrayField.size() > 0)
                        lstmaparrayfield.add(arrayField);       
                    }
                }
            }
        }
        return lstmaparrayfield;
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       Generate autonumber
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/   
    public static string GenerateUniqueID()
    {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        return hexDigest;
    }
    
   /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       publish the data to lazypaydb via a esb q
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/ 
    @future(callout = true)
    public static void PublishData(String thePayLoad){
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>'+thePayLoad);
        HttpResponse response = LazyPayConsumerUtility.getAWSData('SendLazyPay',Null,Null,thePayload,Null);
        System.debug(response.getStatusCode() + '_____>>>>>>>>>>______________?>>>>>>>>' + response.getBody()); 
    }  
    
     @future(callout = true)
    public static void PublishDataToLPDB(String thePayLoad,string processName){
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>'+thePayLoad);
        HttpResponse response = LazyPayConsumerUtility.getAWSData('SendLazyPay',Null,Null,thePayload,Null);
        System.debug(response.getStatusCode() + '_____>>>>>>>>>>______________?>>>>>>>>' + response.getBody()); 
        LP_HTTP_Publisher__c objHTTP = SystemUtility.createHTTPPublisher(thePayLoad,'Case',response.getBody(),processName);
        insert objHTTP;
    }  
    
    public class clspayLoadGenerator{
        public list<sobject> lstsObject;
        public PayloadActMap__mdt thePayLoadMap;
        public sobject objsObject;
        public string objectName;
        public string uniqueId;
    }
    
     /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to format the value from lower case to uper case
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-Sep-18              Eitika Verma               created
    **/ 
     public static String valueFormatToUpperCase(String status) {
        String result = '';
        if (status != null && status != '') 
        {      
           for(string eachStr : status.split(' '))           
           {   
                if (eachStr.length() > 1) {  
                    result += eachStr.substring(0,eachStr.length()).toUpperCase() + '_';
                }
                else {
                    result += eachStr.substring(0,1).toUpperCase() + '_';
                }           
                    
           }
            result = result.substring(0, result.length() - 1);
        }
         if(String.isNotBlank(result) && result.contains('_AND_')){
             result = result.replace('_AND_',' , ');
         }
        return result;
    }
    
    public static map<Id,Case> getCaseInfo(list<sObject> triggerNew){
        map<Id,Case> mapOfContactIdVsCase = new map<Id,Case>();
        
        for(Case eachCase : [SELECT Identifier__c,LP_Product__c,contactId FROM Case WHERE recordType.Name = 'KYC' AND contactId IN:triggerNew]){
            mapOfContactIdVsCase.put(eachCase.contactId,eachCase);
        }
        
        return mapOfContactIdVsCase;
    }
    
    
     /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       used to prepare the payload of knowlarity response
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    03-Jan-19              Eitika Verma               created
    **/ 
    public static String prepareKnowlarityResponsePayload(list<Case> lstCase,string actionName,string typeOfCall) {
        
        list<Map<String, Object>> lstOfpayloads = new list<Map<String, Object>>();
        Map<String, Object> finalPayLoadMap = new Map<String, Object>();
        string agentPh;
        
        if(typeOfCall == 'Manual'){
            //get the phone number of agent or logged in user
        	agentPh = [SELECT MobilePhone FROM User WHERE id=:userinfo.getUserId()].MobilePhone;
        }
        system.debug('lstCase'+lstCase);
        if(lstCase != NULL && lstCase.size()>0){
            if(String.isNotBlank(typeOfCall) && typeOfCall == 'IVR'){
                for(Case eachCase : lstCase){
                    Map<String, string> payLoadMap = new Map<String, string>();
                    payLoadMap = (Map<String, string>)JSON.deserialize(eachCase.LP_IVR_Call_Response__c, Map<String, string>.class);
                    payLoadMap.put('Identifier',eachCase.Identifier__c);
                    lstOfpayloads.add(payLoadMap);
                }
            }
            else if(String.isNotBlank(typeOfCall) && typeOfCall == 'Manual'){
                Map<String, string> mapOfManualCustomMdt;
                
                list<knowlarityPayload__mdt> manualCustomMdt = SystemUtility.getAllFieldsOfObject('Manual_Call','knowlarityPayload__mdt','DeveloperName');
                system.debug('manualCustomMdt'+manualCustomMdt);
                if(manualCustomMdt != NULL && manualCustomMdt.size()>0){
                    mapOfManualCustomMdt = (Map<String, string>)JSON.deserialize(manualCustomMdt[0].jsonESB_pub__c, Map<String, string>.class);
                }
                system.debug('mapOfManualCustomMdt'+mapOfManualCustomMdt);
                for(Case eachCase : lstCase){
                    Map<String, Object> payLoadMap = new Map<String, Object>();
                    if(mapOfManualCustomMdt != NULL && mapOfManualCustomMdt.size()>0){
                        for(string eachKeyNode : mapOfManualCustomMdt.keyset()){
                            if(mapOfManualCustomMdt.get(eachKeyNode) != NULL && mapOfManualCustomMdt.get(eachKeyNode).contains(':')){
                                string value = mapOfManualCustomMdt.get(eachKeyNode);
                                system.debug('value'+value);
                                   system.debug('eachKeyNode'+eachKeyNode);
                                   system.debug('eachCase'+eachCase.Contact.MobilePhone);
                                
                            	payLoadMap.put(eachKeyNode,eachCase.getSobject(value.substringBefore(':')).get(value.substringAfter(':')));
                        	}
                            else if(mapOfManualCustomMdt.get(eachKeyNode) != NULL && mapOfManualCustomMdt.get(eachKeyNode) != ''){
                                string value = mapOfManualCustomMdt.get(eachKeyNode);
                                system.debug('value======'+value);
                                payLoadMap.put(eachKeyNode,eachCase.get(value));
                            }
                            else if(eachKeyNode == 'agent_number' && (mapOfManualCustomMdt.get(eachKeyNode) =='' || mapOfManualCustomMdt.get(eachKeyNode) == NULL)){
                                payLoadMap.put(eachKeyNode,(Object)agentPh);
                            }
                        }
                    }
                    lstOfpayloads.add(payLoadMap);
                }
            }
            if(lstOfpayloads != NULL && lstOfpayloads.size()>0){
                finalPayLoadMap.put('business_object','Customer');
                finalPayLoadMap.put('action',actionName);
                finalPayLoadMap.put('producer','Salesforce');
                finalPayLoadMap.put('product','Collection');
                finalPayLoadMap.put('identifier','null');
                if(typeOfCall == 'Manual'){
                   finalPayLoadMap.put('current_data',lstOfpayloads[0]);
                }
                else{
                    finalPayLoadMap.put('current_data',lstOfpayloads);
                }
                finalPayLoadMap.put('timestamp', System.now().formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));
            }
        }
        
        return JSON.serialize(finalPayLoadMap);
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       send the knowlarity response to lazy pay db and create the records in http publisher
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    03-Jan-19              Eitika Verma               created
    **/ 
    public static void sendknowlarityResponse(map<String,list<Case>> mapOfCases){
        
        for(string eachKey : mapOfCases.keyset()){
            if(String.isNotBlank(eachKey) && eachKey == 'KYC_IVR'){
                sendDataToKnowlarity(mapOfCases.get(eachKey),'upsert_kyc_ivr_call','IVR');
            }
            else if(String.isNotBlank(eachKey) && eachKey == 'Collection_IVR'){
                sendDataToKnowlarity(mapOfCases.get(eachKey),'upsert_collection_ivr_call','IVR');
            }
            else if(String.isNotBlank(eachKey) && eachKey == 'KYC_Manual'){
                sendDataToKnowlarity(mapOfCases.get(eachKey),'upsert_kyc_manual_call','Manual');
            }
            else if(String.isNotBlank(eachKey) && eachKey == 'Collection_Manual'){
                sendDataToKnowlarity(mapOfCases.get(eachKey),'upsert_collection_manual_call','Manual');
            }
        }
        
        CreateHTTPPublisher();
    }
    
    public static void sendDataToKnowlarity(list<Case> lstCases,string actionName,string typeOfCall){
        //set the values in wrapper class
        clspayLoadGenerator objclspayload = new clspayLoadGenerator();
        objclspayLoad.lstsObject = lstCases;
        objclspayLoad.objectName  = 'Case';
        objclspayLoad.Uniqueid = GenerateUniqueID();
        
        //prepare the payload
        string strpayload = prepareKnowlarityResponsePayload(lstCases,actionName,typeOfCall);
        system.debug('strpayload======'+strpayload);
        
        //publish the payload in ESB queue
        if (String.isNotblank(strpayload))
            PublishData(strpayload);
        
        //create HTTP publisher records
        Createpublishtrackdata(objclspayLoad,strpayload);
    }
}