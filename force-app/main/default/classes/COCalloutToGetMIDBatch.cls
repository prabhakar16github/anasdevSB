/********************************************************************************************************
 ** Batch Class : COCalloutToGetMIDBatch
 * 
 ** Purpose : To fetch MID, Identifier, MerchantAccount Id and Business Origin field for Offline Leads.
 * 
 ** Author : Kunal Raj
 * 
 ********************************************************************************************************/ 

public class COCalloutToGetMIDBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    /****Private member variables of the Batch Class********************************************************/
    //private Set<Id> leadIds;
    private List<Id> leadIds;
    private Integer batchSize;
    private String errorMessage;
    private Boolean isBatchProcessed;
    private Map<Id, Lead> leadsToUpdate;
    private List<Lead> updateMIDList;
    /*END***Private member variables of the Batch Class****************************************************/
    
    /******Constructor of the Batch Class to Initialize the member variables and to set other variables to initial values*****/
   	public COCalloutToGetMIDBatch(/*Set<Id> leadIds,*/List<Id> leadIds, Integer batchSize) {
    //public COCalloutToGetMIDBatch(List<Lead> leads) {
        this.leadIds = leadIds;
        //this.leads = leads;
        this.batchSize = batchSize;
        this.isBatchProcessed = false;
        this.leadsToUpdate = new Map<Id, Lead>();
        this.updateMIDList = new List<Lead>();
    }
    /******END********Constructor of the Batch Class ********************************************************/
     
	public Database.QueryLocator start(Database.BatchableContext context) {
        /******If leadIds are provided, query the leads based on those Ids
.        If no leadIds are provided, return a query locator with no results********/
        if(leadIds != null && !leadIds.isEmpty()){
            return Database.getQueryLocator([
            SELECT Id, Name, Email, MobilePhone, FirstName, Product__c, Select_Product__c, Prod_Merchant_Id__c, Lead_Type__c, Integration_Type__c, Offline_Lead__c, Merchant_Account_Id__c, Website__c
            FROM Lead
            WHERE Id IN :leadIds
        ]);
        }
        
        else {
           return Database.getQueryLocator([SELECT Id FROM Lead WHERE Id = '']); 
        }
    }

    public void execute(Database.BatchableContext context, List<Lead> leads) {
        /**** Getting the Access Token and Endpoint URL****************************/
        
        String enterpriseMIDAccessToken = Test.isRunningTest()
            ? 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e'
            : IntegrationUtility.getAuthToken('EnterpriseMIDAuthentication');
        
        Integration_Setting__mdt theIntIns = IntegrationUtility.getIntSetting('EnterpriseMIDGetter');
        String endpoint = (String)theIntIns.EndPointUrl__c;
        String httpMethod = (String)theIntIns.Method__c;

        //String endpoint = 'https://test10-onboarding.payu.in/api/v3/sf_product_accounts/';
        //String httpMethod = 'POST';
        
		for (Lead lead : leads) {
            String productSent;
            if (lead.Select_Product__c == 'PayU Biz') {
                productSent = 'PayUbiz';
            }
            
            Map<String, Object> productAccount = new Map<String, Object>();
            productAccount.put('email', lead.Email);
            productAccount.put('first_name', lead.FirstName);
            productAccount.put('mobile', lead.MobilePhone);
            productAccount.put('product', productSent);

            String requestBody = JSON.serialize(new Map<String, Object>{
                'product_account' => productAccount
            });
            System.debug('requestBody>>>>> '+requestBody);

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(httpMethod);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + enterpriseMIDAccessToken);
            request.setTimeout(120000);
            request.setBody(requestBody);

            Http http = new Http();
            HttpResponse response = new HttpResponse();
            if(!test.isRunningTest()){
                response = http.send(request);
            }else{
                String testResponseBody = '{"product_account":{"id":19480,"uuid":"11ee-1bcd-3ddc7592-802b-02053299bzxy","identifier":12340002,"product_id":1,"type":"PayUbizAccount","merchant_account_id":"19297","active":true,"status":null,"business_entity_id":null,"business_category_id":null,"business_sub_category_id":null,"business_name":null,"pancard_name":null,"pancard_number":null,"gst_number":null,"notification_email":"kspartan233test@gmail.com","flag":16,"settlement_status":null,"merchant_type":null,"onboarding_status":"Profile Completion in progress","account_id":null,"pan_verification_status":"Pending","admin_user_id":15513,"terms_and_condition_accepted_at":null,"created_at":"2023-07-06T07:18:02.000Z","updated_at":"2023-07-06T07:18:02.000Z","partner_uuid":null,"business_origin":"SMB-ENT","shop_number":null,"area_code":null,"gst_verification_status":"Pending","cin_number":null,"mid":12340002,"name":"kspartan233","email":"kspartan233test@gmail.com","first_name":"","last_name":"kspartan233","business_type":"LongTail","bank_update_attempt_count":0,"merchant_vertical":null,"partner_source":null,"android_url":null,"ios_url":null,"integration_type":"Not Selected","integration_status":"Not Integrated","monthly_expected_volume":null,"gmv_amount":null,"website_approval_status":null,"website_url":null,"website_remarks":null,"registered_mobile":"8880898999","product":"PayUbiz","bank_update_attempt_left":11,"is_service_agreement_accepted":false,"is_service_agreement_esigned":false,"is_sbqr_addendum_accepted":true,"acl_role_name":null,"is_authorisation_letter_required":true,"saved_kyc_address":null,"kyc_status":{"status":"LOCKED","kyc_status":"LOCKED"},"document_status":"Pending","service_intent":"default","nb_eligible":false,"lending_eligible":false,"offer_engine_enabled":false,"revamp_merchant":true,"is_cs_eligible":true,"onboarding_completed":false,"re_kyc_required":false,"dashboard_preference":"one_dashboard","migration_status":0,"next_bank_update_time":"2023-07-06T12:48:02.845+05:30","business_pan_name_match":false,"mfa_enabled":false,"team_mfa_enabled":false,"business_category_name":null,"business_sub_category_name":null,"device":"Desktop","display_name":"kspartan233","campaign_name":null,"campaign_medium":null,"campaign_source":null,"campaign_term":null,"source_url":null,"source_type":null,"sub_source":null,"source_details":null,"ubo_exist":false,"mobile":"8880898999","new_settlement_embargo":false,"lending_interest":false,"opgsp_export_enabled":false,"ie_code":null,"purpose_code":null,"business_entity_uuid":null,"business_category_uuid":null,"business_sub_category_uuid":null,"account_uuid":null,"merchant_account_uuid":"11ee-1bcd-3e163944-802b-02053299xyza","product_uuid":"a12c-f114-ce1bac7d-058c-0f95d535aca3","admin_user_uuid":"11ee-0a8f-7db1617c-952a-02c123f54272","bank_detail":null,"operating_address":null,"registration_address":null,"business_entity":null,"product_account_statuses":[{"status_type":"WEBSITE","status_value":null,"updated_at":"2023-07-06T07:18:02.000Z"},{"status_type":"KYC_DOCUMENTS","status_value":"Pending","updated_at":"2023-07-06T07:18:02.000Z"},{"status_type":"Agreement","status_value":"Not Generated","updated_at":"2023-07-06T07:18:02.000Z"}],"website_detail":null,"attached_configs":[],"kyc_documents":[],"cs_plan":null,"product_account_detail":{"id":19400,"merchant_id":null,"dob":null,"pep":null,"aml_flag":false,"created_at":"2023-07-06T07:18:02.000Z","updated_at":"2023-07-06T07:18:02.000Z","uuid":"11ee-1bcd-3e8d7c3e-802b-02053299b2da","gst_addendum_status":null,"sign_up_ip":null,"max_same_day_settlement_amt":null,"emi_approval_status":null,"mcp_approval_status":null,"product_account_id":19480,"integration_type":"Not Selected","integration_status":"Not Integrated","monthly_expected_volume":null,"gmv_amount":null,"average_delivery_time":null,"next_rekyc_date":null,"industry_type":null,"annual_turnover":null,"lead_id":null,"city_of_incorporation":null,"country_of_incorporation":null,"purpose_of_payouts":null,"team_mfa_enabled":false,"team":null,"pg_key":"7hnjgX","flag":0,"priority_settlement_plan":null,"mcp_ticket_id":null,"uat_merchant_detail":null,"ie_code":null,"purpose_code":null},"custom_parameters":[],"ultimate_beneficiaries":[],"consents":[],"signatory_contact_details":[]}}';
                response.setBody(testResponseBody);
                response.setStatusCode(200);
            }
            System.debug('response>>>> '+response.getBody());

            if (response != NULL && response.getStatusCode() == 200) {
                Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('responseObj : '+responseObj);
                Map<String, Object> prdAccountObj = (Map<String, Object>) responseObj.get('product_account');
                System.debug('prdAccountObj : '+prdAccountObj);
                Integer midExtract = (Integer) prdAccountObj.get('identifier');
                String merchantAccountIdExtract = (String) prdAccountObj.get('merchant_account_uuid');
                String identifierExtract = (String) prdAccountObj.get('uuid');
                String businessOriginExtract = (String) prdAccountObj.get('business_origin');
                /*Lead leadRec = new Lead(Id = lead.Id, Prod_Merchant_Id__c = midExtract, Merchant_Account_Id__c = merchantAccountIdExtract, 
                                        Identifier__c = identifierExtract, Lead_Type__c = 'ProductAccount', 
                                        Offline_Lead__c = True, Business_Origin__c = businessOriginExtract,
                                       Integration_Type__c = (lead.Website__c != null) ? 'ThirdParty' : 'Tools');*/
                lead.Prod_Merchant_Id__c= midExtract;
                lead.Merchant_Account_Id__c= merchantAccountIdExtract;
                lead.Identifier__c= identifierExtract;
                lead.Lead_Type__c='ProductAccount';
                lead.Offline_Lead__c=True;
                lead.Business_Origin__c= businessOriginExtract;
                lead.Integration_Type__c=  lead.Website__c != null ? 'ThirdParty' : 'Tools';
                lead.Merchant_Business_Type__c = 'Enterprise';
                
                //leadRec.Integration_Type__c = (leadRec.Website__c != null) ? 'ThirdParty' : 'Tools';
                System.debug('lead::::' + lead);
                //updateMIDList.add(leadRec);
                  updateMIDList.add(lead);
                
            } else {
                Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String errorMessage = getErrorMessage(responseObj);
                
                Lead leadRec = new Lead(Id = lead.Id, Error_Message__c = errorMessage);
                updateMIDList.add(leadRec);
                System.debug('HTTP callout failed with status code ' + response.getStatusCode() + ' and error message ' + errorMessage);

                
            }
        }
        isBatchProcessed = true;
        
        if(!updateMIDList.isEmpty()){
            System.debug('updateMIDList DEBUGG::::' + updateMIDList);
            if(!test.isRunningTest()) update updateMIDList;
        }
    }

    public void finish(Database.BatchableContext context) {
        /** post-processing logic if needed.****/ 
        /*****If there are leads to update, performs the update operation*******/
        if(!test.isRunningTest()){
           if(!updateMIDList.isEmpty()){
            System.debug('updateMIDList LOG >>>> '+updateMIDList);
            update updateMIDList; 
        }
         
        }
        /*****If Batch Class is not called, it update the leads with an error message*****************/
        if(!isBatchProcessed){
            for(Lead lead : leadsToUpdate.values()){
                lead.Error_Message__c = 'Batch class not called';
            }
            update leadsToUpdate.values();
        }
        
    }
    
    /********Method to extract the error message from the response************/
	public static String getErrorMessage(Map<String, Object> responseObj) {
        String errorMessage = '';
        try{
            Map<String, Object> errors = (Map<String, Object>) responseObj.get('errors');
            for (String field : errors.keySet()) {
                List<Object> errorList = (List<Object>) errors.get(field);
                for(Object error : errorList){
                    errorMessage += String.valueOf(error) + '\n';
                }
            }
        } catch(Exception e){
                System.debug('Error occurred while parsing error message: '+e.getMessage());
            }
            return errorMessage;
        }
    /*******END*********Method to extract the error message from the response************/
}