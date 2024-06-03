/*
* Name of the class : RemovePricingFromTreasuryNew
* Author's Name     : Anas Yar Khan  
* Created Date      : 18th March, 2024
* Description       : Apex Class to remove Pricing from Treasury
* Version.          : 1   
*/ 
public class RemovePricingFromTreasuryNew {
    private static FINAL String PROCESS_NAME = 'Remove Pricing From Main Table';
    public static void deletePricing(String ruleIdsNeedToDeactivated,String commercialId,String opportunityId) {
        DateTime currentDateTimeUTCFormat = PublishPricingUtility.getUTCDateTime(DateTime.now());
        String currentDateTimeUTCFormatString = currentDateTimeUTCFormat.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        String requestId = EncodingUtil.convertToHex(Blob.valueOf(commercialId+currentDateTimeUTCFormatString));
        String userToken = UserInfo.getUserId();
        String requestBody = '{"userToken":"'+userToken+'","requestId":"'+requestId+'","source":"Salesforce","idDeactivated":'+ruleIdsNeedToDeactivated+',"addedBy":"'+UserInfo.getName()+'"}';
        try {
            Publish_Pricing_Detail__c publishDetail = new Publish_Pricing_Detail__c();
            publishDetail.Commercial__c = commercialId;
            publishDetail.Process__c = PROCESS_NAME;
            publishDetail.Merchant__c = opportunityId;
            publishDetail.Type__c = 'TDR';
            publishDetail.Request_Id__c = requestId;
            publishDetail.Request_Body__c = requestBody;
            publishDetail.Request_Count__c = ruleIdsNeedToDeactivated.split(',').size();
            String accessToken = PricingIntegrationUtility.getAccessToken('Get_Access_Token_Remove');
            if(String.isNotBlank(accessToken)) {
                HttpResponse response = PricingIntegrationUtility.doCallout('API_Callout_Remove_New',accessToken,requestBody,PROCESS_NAME);
                if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                    publishDetail.Status__c = 'Success';
                    publishDetail.Sync_Status__c = 'Processing';
                }
                else {
                    publishDetail.Message__c = 'API Callout Error';
                    publishDetail.Status__c = 'Error';	      
                }
                publishDetail.Response_Body__c = response.getBody();
            }
            else {
                publishDetail.Message__c = 'Authorization Error';
                publishDetail.Status__c = 'Error';
                publishDetail.Response_Body__c = 'SF Error : System not able to authorize the treasury System. Facing issue while getting the access_token.';
            }
            insert publishDetail;    
        }
        catch(Exception e) {
            Error_Details__c errorDetails = new Error_Details__c(Request__c = requestBody,Process__c = PROCESS_NAME,Message__c = e.getMessage(),Severity__c = 'High', Identifier__c = String.valueOf(e.getLineNumber()));
            insert errorDetails;
        }
    }
}