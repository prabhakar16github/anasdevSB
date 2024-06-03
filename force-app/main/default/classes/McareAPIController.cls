@RestResource(urlMapping='/api/McareApi/*')
global class McareAPIController {
    static Id CaseId;
    static string strEmail;
    static string strMobile;
    static string strUUID;
    static map<string,string> mapOfResponse;
    public static string strRecordType;
    public static boolean contactExistFlag = false ;
    public static string productLabel;
    
    @HttpPost
    global static void createCaseAndContact() {
        //string currentData;
        Case objCase;
        Account objAcc;
        Contact objCon;
        string strRepsone;
        Id entitlementId;
        list<Attachment> lstAttachment;
        Payload_Log__c theLog = new Payload_Log__c();
        list<Case> lstOfUpsertCase = new list<Case>();        
        List<Opportunity> oppList = New List<Opportunity>();
        List<Lead> leadList = New List<Lead>();
        RestResponse res = RestContext.response;
        Boolean errorResponse = false;
        
        String currentData = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
        System.debug('$$$$$$$$$ '+currentData);
        if(String.isNotBlank(currentData)){
            try{ 
                //get the mappings from custom metadata
                map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload = CareUtility.getPayloadData('MCareApiCase');
                system.debug('@@@@ mapOfObjectNameVsPayload '+mapOfObjectNameVsPayload);
                //deserialize the json string
                Map<String, Object> jsonRequestDataMap = (Map<String, Object>)JSON.deserializeUntyped(currentData);
                
                Id queueId = [Select Id from Group where type='Queue' and DeveloperName='payu_Money'].Id;
                
                if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('RecordTypeName')){
                    strRecordType = String.ValueOf(jsonRequestDataMap.get('RecordTypeName'));
                    system.debug('strRecordType!!!'+strRecordType);
                    //create logs of consumer
                    theLog = new Payload_Log__c(Producer__c = 'AppFeedbackCare',Business_Object__c = 'Case',Action__c = 'AppFeedbackCare',Process__c = 'AppFeedbackCare',Payload__c = currentData);
                }else{
                    errorResponse = true;
                    mapOfResponse = new map<string,string>();
                    mapOfResponse.put('State','Error');
                    mapOfResponse.put('message','RecordTypeName is missing.');
                    res = getResponse(Blob.valueOf(JSON.serialize(mapOfResponse)),500);
                }
                
                if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('ProductName')){
                    productLabel = String.ValueOf(jsonRequestDataMap.get('ProductName'));
                }else{
                    errorResponse = true;
                    mapOfResponse = new map<string,string>();
                    mapOfResponse.put('State','Error');
                    mapOfResponse.put('message','ProductName is missing.');
                    res = getResponse(Blob.valueOf(JSON.serialize(mapOfResponse)),500);
                }
                
                if(mapOfObjectNameVsPayload != NULL && mapOfObjectNameVsPayload.size()>0){
                    
                    //upsert account records
                    if(mapOfObjectNameVsPayload.containsKey('Account')){
                        objAcc = (Account)populateObjectData('Account',mapOfObjectNameVsPayload,jsonRequestDataMap);
                        system.debug('##### objAcc '+objAcc);
                    }
                    
                    //upsert contact records
                    if(mapOfObjectNameVsPayload.containsKey('Contact')){
                        objCon = (Contact)populateObjectData('Contact',mapOfObjectNameVsPayload,jsonRequestDataMap);
                        system.debug('##### objCon '+objCon);
                        system.debug('##### objConAccountID '+objCon.AccountId);
                        if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('phone') && !contactExistFlag){
                            objCon.MobilePhone = String.ValueOf(jsonRequestDataMap.get('phone'));
                        }
                        if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('Email') && !contactExistFlag){
                            objCon.Email = String.ValueOf(jsonRequestDataMap.get('Email'));
                        }
                    }                   
                    
                    //upsert Case records
                    if(mapOfObjectNameVsPayload.containsKey('Case')){
                        objCase = (Case)populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                        objCase.status = 'New';
                        
                        System.debug('>>>>>>>>>>>>>>>>>'+objCase.RecordTypeId);
                        objCase.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordType).getRecordTypeId();
                        system.debug('RecordTypeId@@@@'+objCase.RecordTypeId);
                        objCase.Comments = objCase.LP_Issue_description__c;
                        
                        if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('phone')){
                            objCase.Mobile__c = String.ValueOf(jsonRequestDataMap.get('phone'));
                        }
                        if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('Email')){
                            objCase.SuppliedEmail = String.ValueOf(jsonRequestDataMap.get('Email'));
                        }
                        if(jsonRequestDataMap != NULL && jsonRequestDataMap.containsKey('Subject')){
                            objCase.Subject = String.ValueOf(jsonRequestDataMap.get('Subject'));
                            system.debug('#### objCase get subject '+String.ValueOf(jsonRequestDataMap.get('Subject')));
                        }
                        system.debug('#### objCase subject '+objCase.Subject);
                    }
                    
                    //perform DML operations
                    system.debug('#### objCase '+objCase);
                    if(objCase != NULL){
                        List<Case> caseListUpsert = New List<Case>();
                        Case eachCase = objCase;
                        
                        if(String.isNotBlank(eachCase.Merchant_Id__c)){ //&& String.isNotBlank(productLabel)){
                            leadList = getLeads(eachCase.Merchant_Id__c,productLabel);
                            
                            If(!leadList.isEmpty() && leadList.size()>0){
                                eachCase.Lead__c = leadList[0].Id;
                                if(String.isNotBlank(eachCase.SuppliedEmail)){
                                    system.debug('suppliedmail'+eachCase.SuppliedEmail);
                                    if(contactExistFlag/*objCon != null && objCon.AccountId != NULL*/){
                                        objAcc.Id = objCon.AccountId;
                                        eachCase.AccountId = objCon.AccountId;
                                    }else{
                                        upsert objAcc;
                                        eachCase.AccountId = objAcc.Id;
                                    }
                                    
                                    if(contactExistFlag/*objCon != null && objCon.Id != null*/){
                                        eachCase.ContactId = objCon.Id;
                                        eachCase.AccountId = objCon.AccountId;
                                    }else{
                                        objCon.AccountId = objAcc.Id;
                                        upsert objCon;
                                        eachCase.ContactId = objCon.Id;
                                    }                                        
                                }
                            }
                            else if(String.isNotBlank(eachCase.Merchant_Id__c) /*&& String.isNotBlank(productLabel)*/ && leadList.isEmpty()){
                                oppList = getOpportunity(eachCase.Merchant_Id__c,productLabel);
                                
                                If(!oppList.isEmpty() && oppList.size()>0){
                                    eachCase.Opportunity__c = oppList[0].Id;
                                    eachCase.AccountId = oppList[0].AccountId;
                                    eachCase.ContactId = [Select Id from Contact Where AccountId =:oppList[0].AccountId][0].Id;
                                }
                            }
                            else{
                                system.debug('#### else eachCase '+eachCase);
                                if(String.isNotBlank(eachCase.SuppliedEmail)){
                                    system.debug('##### objCon 222'+objCon);
                                    system.debug('##### objAcc 222'+objAcc);
                                    if(objCon != null && objCon.AccountId != NULL){
                                        objAcc.Id = objCon.AccountId;
                                        eachCase.AccountId = objCon.AccountId;
                                        upsert objAcc;
                                    }else if(objCon != null && objCon.AccountId == NULL){
                                        upsert objAcc;
                                        objCon.AccountId = objAcc.Id;
                                        eachCase.AccountId = objAcc.Id;
                                    }
                                    
                                    if(objCon != null && objCon.Id != null){
                                        eachCase.ContactId = objCon.Id;
                                        eachCase.AccountId = objAcc.Id;
                                        
                                        objCon.AccountId = objAcc.Id;
                                        upsert objCon;
                                    }else{
                                        objCon.AccountId = objAcc.Id;
                                        upsert objCon;
                                        eachCase.ContactId = objCon.Id;
                                        eachCase.AccountId = objAcc.Id;
                                    }                                        
                                }
                            }
                        }
                        
                        if(oppList.isEmpty() && leadList.isEmpty()){
                            if(String.isNotBlank(eachCase.SuppliedEmail)){
                                system.debug('##### objCon 222'+objCon);
                                system.debug('##### objAcc 222'+objAcc);
                                if(objCon != null && objCon.AccountId != NULL){
                                    objAcc.Id = objCon.AccountId;
                                    eachCase.AccountId = objCon.AccountId;
                                    upsert objAcc;
                                }else if(objCon != null && objCon.AccountId == NULL){
                                    upsert objAcc;
                                    objCon.AccountId = objAcc.Id;
                                    eachCase.AccountId = objAcc.Id;
                                }
                                
                                if(objCon != null && objCon.Id != null){
                                    eachCase.ContactId = objCon.Id;
                                    eachCase.AccountId = objAcc.Id;
                                    
                                    objCon.AccountId = objAcc.Id;
                                    upsert objCon;
                                }else{
                                    objCon.AccountId = objAcc.Id;
                                    upsert objCon;
                                    eachCase.ContactId = objCon.Id;
                                    eachCase.AccountId = objAcc.Id;
                                }                                        
                            }
                        }
                        
                        //if(String.isNotBlank(eachCase.ContactId) && String.isNotBlank(eachCase.AccountId)){
                            eachCase.OwnerId = queueId;
                            upsert eachCase;                       
                        //}
                        system.debug('####### eachCase '+eachCase);
                        if(eachCase != null && eachCase.Id != null){
                            CaseId = eachCase.Id;
                        }
                    }
                }
                if(!errorResponse){
                    system.debug('####### CaseId '+CaseId);
                    theLog.Status__c = 'SUCCESS'; 
                    //CareUtility.populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                    
                    
                    if(CaseId != Null){
                        
                        list<Case> lstFetchedCase = [SELECT casenumber,status,Identifier__c,Expected_Closure_Date__c FROM Case WHERE id=:CaseId]; 
                        //system.debug('lstFetchedCase==='+lstFetchedCase);
                        //prepare return response
                        mapOfResponse = new map<string,string>();
                        mapOfResponse.put('State','Success');
                        if(lstFetchedCase!= NULL && lstFetchedCase.size()>0){
                            mapOfResponse.put('caseNumber',lstFetchedCase[0].casenumber);
                            mapOfResponse.put('caseStatus',lstFetchedCase[0].status);
                            mapOfResponse.put('identifier',lstFetchedCase[0].Identifier__c);
                            
                        }
                        
                        res = getResponse(Blob.valueOf(JSON.serialize(mapOfResponse)),200);
                        /* //RestResponse res = RestContext.response; 
if(Test.isRunningTest()){res = new RestResponse();}
res.addHeader('Content-Type', 'Application/json');
res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
res.statusCode = 200;*/
                    }
                    
                    
                }else{
                    theLog.Status__c = 'ERROR'; 
                    //CareUtility.populateObjectData('Case',mapOfObjectNameVsPayload,jsonRequestDataMap);
                    system.debug('####### errr CaseId '+CaseId);
                    
                }
                
            }
            catch(Exception ex){
                system.debug('@@@@@ Catch error '+ex);
                theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); 
                theLog.Status__c = 'Error';
                System.debug('ERROR: '+ex.getMessage());
                System.debug('ERROR: '+ex.getLineNumber());
                map<string,string> mapOfResponse = new map<string,string>();
                mapOfResponse.put('State','Error');
                mapOfResponse.put('message',ex.getMessage());
                mapOfResponse.put('Stack Trace',ex.getStackTraceString());
                mapOfResponse.put('Line No',string.valueOf(ex.getLineNumber()));
                //RestResponse res = RestContext.response; 
                if(Test.isRunningTest())
                    res = new RestResponse();
                /*res.addHeader('Content-Type', 'Application/json');                
res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
res.statusCode = 500; */
                res = getResponse(Blob.valueOf(JSON.serialize(mapOfResponse)),500);
            }
            if(strRecordType != null)
                insert theLog;            
        }        
    } 
    
    public static void populateField(SObject sobToUpsert,String node,String fieldApi,String data){
        
        if(String.isNotBlank(fieldApi) && String.isNotBlank(data)){
            if(node == 'MerchantName'){
                if(data.length() > 79 ){
                    system.debug('data.substring(0, 79)'+data.substring(0, 79));
                    data=data.substring(0, 79);}
            }
            if(fieldAPI.subStringAfter(',') == 'Date'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Date.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'DateTime'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),DateTime.valueOf(data));
            }
            else if(fieldAPI.subStringAfter(',') == 'Decimal'){
                sobToUpsert.put(fieldAPI.subStringBefore(','),Decimal.valueOf(data));
            }
            else{
                if(node == 'phone'){
                    strmobile = data;
                    if(!strmobile.startsWith('+91')){
                        strmobile = '+91'+ data;
                    }
                }
                else if(node == 'Email')
                    strEmail = data; 
                else if(node == 'UUID')
                    strUUID = data;
                else{
                    sobToUpsert.put(fieldAPI.subStringBefore(','),data);
                }                
            }
        }
    }    
    
    public static SObject populateObjectData(string sObjectName,map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload,Map<String, Object> jsonRequestDataMap){
        
        sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject() ;                                  
        string accmapVal = mapOfObjectNameVsPayload.get(sObjectName).JsonMap__c;
        map<string,string> mapOfAccountmapping = (Map<String, String>)JSON.deserialize(accmapVal, Map<String, String>.class);
        if(mapOfAccountmapping != NULL && mapOfAccountmapping.size()>0){
            for(string strNode : mapOfAccountmapping.keyset()){
                if(jsonRequestDataMap!= NULL && jsonRequestDataMap.size()>0 && jsonRequestDataMap.containsKey(strNode)){
                    populateField(sObj,strNode,mapOfAccountmapping.get(strNode),String.valueOf(jsonRequestDataMap.get(strNode)));
                }
            }
        }
        
        if(sObjectName == 'Contact'){
            System.debug('Check for existing contact information : email ' + strEmail + 'UUID : ' + strUUID + 'strMobile:' +strMobile + 'sObj' + sObj);
            
            sObj = checkExistingContact(strEmail,strUUID,strMobile,sObj);
        }
        system.debug('sObj=========='+sObj);
        return sObj;
    }
    
    private static SObject checkExistingContact(string strEmail, string strUUID, string strMobile, SObject sobj){
        
        if(String.isNotBlank(strEmail)){
            string strQuery = 'SELECT id,accountid,MobilePhone,Identifier__c,email FROM Contact';
            if(String.isNotBlank(strUUID)){               
                strQuery += ' WHERE Identifier__c=:strUUID';
            }
            else{
                if(String.isNotBlank(strMobile)){
                    strQuery += ' WHERE MobilePhone=:strMobile OR Email=:strEmail';
                }
                else{
                    strQuery += ' WHERE Email=:strEmail';
                }
            }
            list<Contact> lstCon = Database.query(strQuery);
            system.debug('lstCon.size!!!'+lstCon.size());
            system.debug('lstCon!!!'+lstCon);
            if(lstCon != NULL && lstCon.size()>0){
                for(Contact eachCon : lstCon){
                    if(eachCon.Identifier__c == strUUID){                        
                        if(String.isNotBlank(strUUID)){
                            sobj.put('Id',lstCon[0].id);
                            sobj.put('AccountId',lstCon[0].AccountId);
                            contactExistFlag = true;
                        }
                        sobj.put('accountid',lstCon[0].accountid);
                        sobj.put('mobilephone',strMobile);
                    }else if (eachCon.email == strEmail){
                        if(String.isNotBlank(strEmail)){
                            sobj.put('Id',lstCon[0].id);
                            sobj.put('AccountId',lstCon[0].AccountId);
                            contactExistFlag = true;
                        }
                    }else if(eachCon.mobilephone == strMobile){
                        if(String.isNotBlank(strMobile)){
                            sobj.put('Id',lstCon[0].id);
                            sobj.put('AccountId',lstCon[0].AccountId);
                            contactExistFlag = true;
                        }
                    }
                }
            }           
        }
        return sobj;
    }
    /*
public static list<Attachment> prepareAttachments(Map<String, Object> jsonRequestDataMap,map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload,list<Attachment> lstAttachment){

if(jsonRequestDataMap!= NULL && jsonRequestDataMap.size()>0 && 
jsonRequestDataMap.containsKey('Attachment') && jsonRequestDataMap.get('Attachment')!= NULL){
lstAttachment = new list<Attachment>();
List<Map<String, Object>> listOfAttachmentMap = new List<Map<String, Object>>();
List<Object> attachmentList = (List<Object>) jsonRequestDataMap.get('Attachment');
for (Object obj : attachmentList) {
listOfAttachmentMap.add((Map<String, Object>)obj);
} 
if(listOfAttachmentMap != NULL && listOfAttachmentMap.size()>0){
for(Map<String, Object> eachAttachmentData : listOfAttachmentMap){
if(eachAttachmentData != NULL && eachAttachmentData.size()>0){
Attachment objAttach = (Attachment)populateObjectData('Attachment',mapOfObjectNameVsPayload,eachAttachmentData);
//get body of attachment

objAttach.body = CareUtility.getAttachmentBody(objAttach,String.valueOf(eachAttachmentData.get('url')));
if(objAttach.body != NULL){
lstAttachment.add(objAttach);     
} 
}
}
}
}       
return lstAttachment;
}
*/
    /*
public static Id createEntitlement(Account acc,Case cs, string recordtype){
try{

//get business hours id 
Id bHIdChild;
Id bhIdParent;

map<string,Entitlement> mapOfNameVsEntitlement = new map<string,Entitlement>();
List<BusinessHours> bHoursList = [SELECT Id,Name FROM BusinessHours where name IN ('PayU OneCare Child','OneCare Business Hour')];

for(BusinessHours bh : bHoursList){
if(bh.Name == 'OneCare Business Hour')
bhIdParent = bh.Id;
if(bh.Name == 'PayU OneCare Child')
bHIdChild = bh.Id;
}

for(SlaProcess eachProcess : [SELECT id,Name from SlaProcess where Name IN('Parent Ticket Entitlement Process V2','Child Ticket Entitlement Process V2','OneCare Ticket Entitlement Process') AND IsActive = true]){
Entitlement objentitlement = new Entitlement();
objentitlement.AccountId = acc.Id;

if(eachProcess.Name.contains('Parent') && string.isNotBlank(bhIdParent)){
objentitlement.BusinessHoursId = bhIdParent;
objentitlement.Name = 'PayUMoney Parent Entitlement';
objentitlement.SlaProcessId = eachProcess.id;
objentitlement.StartDate = Date.today();
mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);

}else if(eachProcess.name.contains('OneCare') && string.isNotBlank(bHIdChild)){
objentitlement.BusinessHoursId = bHIdChild;
objentitlement.Name = 'Other Parent Entitlement';
objentitlement.SlaProcessId = eachProcess.id;
objentitlement.StartDate = Date.today();
mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);

}
else if(eachProcess.name.contains('Child') && string.isNotBlank(bHIdChild)){
objentitlement.BusinessHoursId = bHIdChild;
objentitlement.Name = 'Child Entitlement';
objentitlement.SlaProcessId = eachProcess.id;
objentitlement.StartDate = Date.today();
mapOfNameVsEntitlement.put(objentitlement.Name,objentitlement);

}

}

if(mapOfNameVsEntitlement!=NULL && mapOfNameVsEntitlement.size()>0){

insert mapOfNameVsEntitlement.values();
if(mapOfNameVsEntitlement.containsKey('PayUMoney Parent Entitlement')){
return mapOfNameVsEntitlement.get('PayUMoney Parent Entitlement').Id;
}else if (mapOfNameVsEntitlement.containsKey('Child Entitlement')){
return mapOfNameVsEntitlement.get('Child Entitlement').Id;
}else if(mapOfNameVsEntitlement.containsKey('Other Parent Entitlement'))
return mapOfNameVsEntitlement.get('Other Parent Entitlement').Id;
else
return null;
}
else
return null;
}catch(Exception ex){

return null;
}        
}   
*/
    public static List<Opportunity> getOpportunity(string MID, String productLabel){
        return [Select Id,AccountId from Opportunity Where prod_merchant_id__c =: Integer.ValueOf(MID) 
                //AND productLabel__c =: productLabel 
                LIMIT 1];
    }
    
    public static List<Lead> getLeads(string MID, String productLabel){
        return [Select Id from Lead Where prod_merchant_id__c =: Integer.ValueOf(MID) 
                //AND productLabel__c =: productLabel 
                AND IsConverted = False LIMIT 1];
    }
    
    private static RestResponse getResponse(blob body, Integer statusCode){
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'Application/json');                
        res.responseBody = body;
        res.statusCode = statusCode;
        return res;
    }
}