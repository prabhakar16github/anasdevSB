public class COCalloutLWC implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    /**Added to cater the LWC Component */
    private Id leadId;

    public COCalloutLWC(Id leadId) {
        //public COCalloutToGetMIDBatch(List<Lead> leads) {
            this.leadId = leadId;
            
        }
    /**End******************************** */  
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        if(leadId != null){
            return Database.getQueryLocator([
            SELECT Id, Name, Email, MobilePhone, FirstName, Product__c, Select_Product__c
            FROM Lead
            WHERE Id=:leadId
        ]);
        }
        else {
           return null; 
        }
    }
    
    public void execute(Database.BatchableContext context, List<Lead> leads) {
        String enterpriseMIDAccessToken = Test.isRunningTest()
            ? 'b74acb75e87f93aa9db8073d570753474e58702aa9e91af4054478bba98af38e'
            : IntegrationUtility.getAuthToken('EnterpriseMIDAuthentication');

        String endpoint = 'https://test10-onboarding.payu.in/api/v3/sf_product_accounts/';
        String httpMethod = 'POST';
        List<Lead> updateMIDList = new List<Lead>();
        //List<Lead> insertMIDList = new List<Lead>();

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
            HttpResponse response = http.send(request);
            System.debug('response>>>> '+response);

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('responseObj : '+responseObj);
                Map<String, Object> prdAccountObj = (Map<String, Object>) responseObj.get('product_account');
                System.debug('prdAccountObj : '+prdAccountObj);
                Integer midExtract = (Integer) prdAccountObj.get('identifier');
                String merchantAccountIdExtract = (String) prdAccountObj.get('merchant_account_uuid');
                String identifierExtract = (String) prdAccountObj.get('uuid');
                Lead leadRec = new Lead(Id = lead.Id, Prod_Merchant_Id__c = midExtract, Merchant_Account_Id__c = merchantAccountIdExtract, Identifier__c = identifierExtract);
                updateMIDList.add(leadRec);
                System.debug('updateMIDList::::' + updateMIDList);
            } else {
                System.debug('HTTP callout failed with status code ' + response.getStatusCode() + ' and message ' + response.getStatus());
            }
        }

        update updateMIDList;
       //insert insertMIDList;
    }
    
    public void finish(Database.BatchableContext context) {
        // Implement any post-processing logic if needed. In this case we dont have anything.
    }

}