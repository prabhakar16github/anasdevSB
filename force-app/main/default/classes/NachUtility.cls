public class NachUtility {
    public static void processNachPayload(Payload_Log__c theLog,Map<String, Object> jsonRequestDataMap){
        //variables
        map<string,string> mapOfResponse = new map<string,string>();
        
        //get the mappings from custom metadata
        map<string,PayloadActMap__mdt> mapOfObjectNameVsPayload = CareUtility.getPayloadData('updateNach');
        
        try{
            sObject objSobject = CareUtility.populateObjectData('Nach_Data__c',mapOfObjectNameVsPayload,jsonRequestDataMap);
            system.debug('objSobject'+ objSobject);
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
            theLog.Status__c = 'SUCCESS';
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