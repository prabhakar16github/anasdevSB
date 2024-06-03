@RestResource(urlMapping='/updateProduct/*')
global class ProductUpdateAPIController {
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
   
    //  Prod Product Identifier
    public static Map<string,string> productNameWithIdentifierMap = New Map<string,string>{
        'PayUbiz' => 'a12c-f114-ce1bac7d-058c-0f95d535aca3', 
        'PayUmoney' => 'c10c-09ed-2a4d1e54-5bde-2ae0ed54ea8a', 
        'PayUnow' => '7318-c204-87737a95-13e3-eaf3d52cd3a4'};
         
            // OnePayUDev product Identifier
            /*public static Map<string,string> productNameWithIdentifierMap = New Map<string,string>{'PayUbiz' => '11e8-a536-37eb8fa0-ad17-f45c89c91a7b', 
        'PayUmoney' => '11e8-a536-37ea0c3e-ad17-f45c89c91a7b', 
        'PayUnow' => '11e8-a536-37ed592a-ad17-f45c89c91a7b'};*/
            
            @HttpPost
            //Update Product for Merchant
            global static void getMerchantsProduct(){
                
                Map<String, Object> failureResponseMap = new Map<String, Object>();
                List<Object> returnDetails = new List<Object>();
                List<String> merchant_uuids = New List<String>();
                Map<String,String> IdentifierWithProductMap = New Map<String,String>();
                List<Opportunity> opportunities = New List<Opportunity>();
                List<Lead> leads = New List<Lead>();
                
                List<Opportunity> updateOpportunities = New List<Opportunity>();
                List<Lead> updatedLeads = New List<Lead>();
                
                try{
                    String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
                    system.debug('strJson'+strJson);
                    returnDetails = (List<Object>)JSON.deserializeUntyped(strJson);
                    system.debug('returnDetail '+returnDetails);
                    
                    for(Object eachReturnDetailObj : returnDetails){
                        Map<String, Object> jsonRootMap = (Map<String, Object>)eachReturnDetailObj;
                        
                        if(jsonRootMap.containsKey('merchant_uuids')) {
                            List<Object> objList = (List<Object>)jsonRootMap.get('merchant_uuids');
                            
                            for(Object obj : objList){
                                String str = (String) obj;
                                string prod = (String)jsonRootMap.get('product');
                                merchant_uuids.add(str);
                                IdentifierWithProductMap.put(str,prod);
                            }
                        }
                    }
                    
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('status','success');
                    gen.writeStringField('response','success');
                    gen.writeFieldName('data');
                    gen.writeStartObject();
                    
                    if(!merchant_uuids.isEmpty() && merchant_uuids.size()>0){
                        opportunities = [Select Id,Product__c,Identifier__c,Business_Origin__c from Opportunity Where Identifier__c IN: merchant_uuids];
                        
                        if(!opportunities.isEmpty()){
                            for(Opportunity eachOpp : opportunities){
                                if(IdentifierWithProductMap.containsKey(eachOpp.Identifier__c)){
                                    eachOpp.Product__c = [Select Id from Product__c Where Identifier__c =: productNameWithIdentifierMap.get(IdentifierWithProductMap.get(eachOpp.Identifier__c)) LIMIT 1].Id;
                                    if(IdentifierWithProductMap.containsKey(eachOpp.Identifier__c) && IdentifierWithProductMap.get(eachOpp.Identifier__c) == 'PayUbiz') eachOpp.Business_Origin__c = 'SMB-ENT';
                                    else if(IdentifierWithProductMap.containsKey(eachOpp.Identifier__c) && IdentifierWithProductMap.get(eachOpp.Identifier__c) == 'PayUmoney') eachOpp.Business_Origin__c = 'PayUmoney';
                                    else if(IdentifierWithProductMap.containsKey(eachOpp.Identifier__c) && IdentifierWithProductMap.get(eachOpp.Identifier__c) == 'PayUnow') eachOpp.Business_Origin__c = 'PayUnow';
                                    updateOpportunities.add(eachOpp);
                                    gen.writeStringField('merchant_uuids',eachOpp.Identifier__c);
                                }  
                            }
                        }
                        
                        if(opportunities.size() <> merchant_uuids.size()){
                            leads = [Select Id,Product__c,Identifier__c,Business_Origin__c from Lead Where Identifier__c IN: merchant_uuids AND isConverted = False];
                            
                            if(!leads.isEmpty()){
                                for(Lead eachLead : leads){
                                    if(IdentifierWithProductMap.containsKey(eachLead.Identifier__c)){
                                        eachLead.Product__c = [Select Id from Product__c Where Identifier__c =: productNameWithIdentifierMap.get(IdentifierWithProductMap.get(eachLead.Identifier__c)) LIMIT 1].Id;
                                        if(IdentifierWithProductMap.containsKey(eachLead.Identifier__c) && IdentifierWithProductMap.get(eachLead.Identifier__c) == 'PayUbiz') eachLead.Business_Origin__c = 'SMB-ENT';
                                    	else if(IdentifierWithProductMap.containsKey(eachLead.Identifier__c) && IdentifierWithProductMap.get(eachLead.Identifier__c) == 'PayUmoney') eachLead.Business_Origin__c = 'PayUmoney';
                                    	else if(IdentifierWithProductMap.containsKey(eachLead.Identifier__c) && IdentifierWithProductMap.get(eachLead.Identifier__c) == 'PayUnow') eachLead.Business_Origin__c = 'PayUnow';
                                        updatedLeads.add(eachLead);
                                        gen.writeStringField('merchant_uuids',eachLead.Identifier__c);
                                    }
                                }
                            }
                        }
                        
                        gen.writeEndObject();
                        gen.writeEndObject();
                        retrnJson = gen.getAsString();
                        
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.responseBody = Blob.valueOf(retrnJson);
                    }else{
                        failedResponseList.add('No merchant UUID found in SF database.');
                        
                        jsonFailResponse('FAILED', failedResponseList, failureResponseMap, null, null);
                    }
                    
                    if(updateOpportunities.size() > 0){
                        OpportunityTriggerHandler.publishUpdateFromApex = false;
                        update updateOpportunities;
                    }
                    
                    if(updatedLeads.size() >0){
                        LeadTriggerHandler.publishUpdateFromApex = false;
                        update updatedLeads;
                    }
                    
                }catch(Exception ex){
                    failedResponseList.add(ex.getMessage());
                    failedResponseList.add(ex.getStackTraceString());
                    jsonFailResponse('FAILED', failedResponseList, failureResponseMap, null, null);
                }
            }
    
    public static void jsonFailResponse(String strStatus, List<String> strMessage, Map<String, Object> failureResponseMap, Map<String, String> requestJson, String uuid){
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Message__c', String.valueOf(strMessage));
        messages.put('Process__c', 'Product Update API');
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);
        SystemUtility.errorHandler(null, messages);
        
        failureResponseMap.put('status', strStatus);  
        failureResponseMap.put('response', strMessage);     
        failureResponseMap.put('data', new Map<String, Object>());
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(failureResponseMap));
        RestContext.response.statusCode = 404;
    }
}