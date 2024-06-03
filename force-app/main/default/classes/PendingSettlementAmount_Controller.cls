/* Written by Rohit Gupta
 Description : When Opportunity Settlement Ststus on risk hold then we need HIT the API and  send MID to Payubiz and get the 
 totalPendingSettlementAmount and update on Settlement Amount on Hold field*/
public class PendingSettlementAmount_Controller {
    public static String getAccessToken(String apiSettingName){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        SettelementAPI_Setting__mdt  tokenSetting = SettelementAPI_Setting__mdt.getInstance(apiSettingName);
        req.setMethod(tokenSetting.Method__c);
        req.setEndpoint(tokenSetting.EndPointURL__c);
        for(String header : tokenSetting.Headers__c.split(',')){
            req.setHeader(header.split(':')[0],header.split(':')[1]);
        }
        req.setBody(tokenSetting.Body__c);
        HttpResponse response = new HttpResponse();
        if(!test.isRunningTest()){
            response = http.send(req);
        }
        else{
            String testBody = '{"access_token": "1168daddf26657f7ee50cfe7c36624e94a8d5a8e4d7704dae6a4161f906a87bb","token_type": "Bearer","expires_in": 5718,"scope": "check_settlement_balance","created_at": 1690184691}'; // Sample response from the external API
            response.setStatusCode(200);
            response.setBody(testBody);
         }
         if(response.getStatusCode() == 200 && String.isNotBlank(response.getBody())){
            Map<String,Object> tokenMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            return String.valueOf(tokenMap.get('access_token'));
        }
        return null;
    }
    @auraEnabled
    public static String updatePendingAmount(Id oppId){
        String access_Token = getAccessToken('Get_Access_Token');// Calling the getAccessToken method to get the Access token
        List<Opportunity> oppList = [SELECT Id,Settlement_Amount_on_Hold__c,Prod_Merchant_Id__c FROM Opportunity WHERE Id=:oppId];
        HttpRequest request = new HttpRequest();
        SettelementAPI_Setting__mdt setllementCalloutDetails = SettelementAPI_Setting__mdt.getInstance('AmountApi_Callout');
        request.SetEndpoint(setllementCalloutDetails.EndPointURL__c);
        request.setMethod(setllementCalloutDetails.Method__c);
        String bodyJosn ='{"merchantId":['+String.valueOf( oppList[0].Prod_Merchant_Id__c)+']}';
        for(String header : setllementCalloutDetails.Headers__c.split(',')){
            if(header.contains('<access_token>')){
                header = header.replace('<access_token>',access_Token);
            }
            request.setHeader(header.split(':')[0],header.split(':')[1]);
        }
        request.setBody(bodyJosn);
        try{
            Http http = new Http();
            HttpResponse response = new HttpResponse();
			response = http.send(request);
            Decimal pendingAmount;
            String statusForPendingAmount='';
            if(response.getStatusCode()==200){
                String responseJson = response.getBody();
                pendingAmount = parsePendingAmountFromJSON(responseJson);
                statusForPendingAmount = 'Pending settlement amount found :'+pendingAmount+' INR';
                List<Opportunity> oppUpdateList = new List<Opportunity>();
                for(Opportunity opp : oppList){
                     opp.Settlement_Amount_on_Hold__c =pendingAmount; 
                    oppUpdateList.add(opp);
                }
                if(oppUpdateList !=null && oppUpdateList.size()>0){
                    update oppUpdateList;
                }
                return statusForPendingAmount;
            }
            else{
                System.debug('API call failed with status code :'+response.getStatusCode());
                statusForPendingAmount = 'No pending settlement amount found ';
                return statusForPendingAmount;
            }
        }
        catch(Exception e){
            System.debug('Exception occurred :'+e.getMessage());
        }
        return null;
    }
    public static Decimal parsePendingAmountFromJSON(String responseJson){
        Decimal settelementPendingAmount=0;
        Map<String,Object> jsonResponse = (Map<String,Object>)JSON.deserializeUntyped(responseJson);
        Map<String,Object> result = (Map<String,Object>) jsonResponse.get('result');
       
        for(String key : result.keySet()){
            settelementPendingAmount = (Decimal)result.get(key);
            break;
        }
        return settelementPendingAmount;
    }
}