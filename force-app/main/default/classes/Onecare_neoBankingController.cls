@RestResource(urlMapping='/NeoBanking/*')
global class Onecare_neoBankingController {
    
    @HttpPost
    global static void createActivationDocument(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        system.debug('currentdata=='+req.requestBody.toString());
        //system.debug('currentData=='+currentData);
        //Map<string,Object> jsonRequestDataMap = (Map<String, Object>)JSON.deserializeUntyped(currentData);
        //system.debug('jsonRequestDataMap=='+jsonRequestDataMap);
    }
     
    global class CurrentPayload {

        global string currentData{get;set;}
        /*global String TicketId { get; set;}
        global String Category { get; set;}
        global string MerchantID { get; set;}
        global string MerchantType {get;set;}
        global string Issue {get;set;}
        global string SubIssue {get;set;}
        global string RecordTypeName {get;set;}*/
    }
            
}