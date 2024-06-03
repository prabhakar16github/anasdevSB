@RestResource(urlMapping='/api/nachProcess/*')
global with sharing class NachService {
    
    @HttpPost
    global static void updateContact(string nachData) {
        Payload_Log__c theLog = new Payload_Log__c();
        map<string,string> mapOfResponse = new map<string,string>();
         if(String.isNotBlank(nachData)){
             try{
                 //create logs of consumer
                 theLog = new Payload_Log__c(Producer__c = 'NachProcess',Business_Object__c = 'Customer',Action__c = 'Upsert_Nach',Process__c = 'Nach Process');
                 theLog.Payload__c = nachData;
                 //get the mappings from custom metadata
                 map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload = CareUtility.getPayloadData('updateNach');
                 system.debug('nachData'+ nachData);
                 //deserialize the json string
                 Map<String, Object> jsonbaseMap = (Map<String, Object>)JSON.deserializeUntyped(nachData); 
                 system.debug('jsonbaseMap' + jsonbaseMap);
                 Map<String, Object> jsonRequestDataMap = (Map<String, Object>)jsonbaseMap.get('current_data'); 
                 system.debug('jsonRequestDataMap======='+jsonRequestDataMap);
                 
                 
                 sObject objSobject = CareUtility.populateObjectData('Contact',mapOfObjectNameVsPayload,jsonRequestDataMap);
                 system.debug('objSobject'+ objSobject);
                 if(objSobject.get('LastName') == NULL)
                     objSobject.put('LastName','Nach_'+objSobject.get('Identifier__c'));
                 upsert objSobject;
                 
                 //prepare return response
                 mapOfResponse = new map<string,string>();
                 mapOfResponse.put('State','Success');
                 RestResponse res = RestContext.response; 
                 //if(Test.isRunningTest())
                 //	res = new RestResponse();
                 
                 res.addHeader('Content-Type', 'Application/json');
                 res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                 res.statusCode = 200;
             }
             catch(Exception ex){
                 theLog.Exception__c = 'MESSAGE: '+ ex.getMessage() + '\n\n' + 'STACK TRACE: '+ ex.getStackTraceString(); theLog.Status__c = 'Error';
                 
                 mapOfResponse.put('State','Error');
                 mapOfResponse.put('message',ex.getMessage());
                 mapOfResponse.put('Stack Trace',ex.getStackTraceString());
                 RestResponse res = RestContext.response; 
                 if(Test.isRunningTest())
                 	res = new RestResponse();
                 res.addHeader('Content-Type', 'Application/json');
                 res.responseBody = Blob.valueOf(JSON.serialize(mapOfResponse));
                 res.statusCode = 500;
             }
             insert theLog; 
         }
    }
}