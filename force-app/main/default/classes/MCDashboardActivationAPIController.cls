@RestResource(urlMapping='/MCDashboardActivationAPI/*')
global class MCDashboardActivationAPIController {
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
    public static Integer merchant_id;
    public static string product_name = '';
    public static string proSell_name = '';
    public static DateTime proSell_activationDate ;
    public static string product_type = '';
    public static string addendum_status = '';
    public static Map<String, Object> failureResponseMap = new Map<String, Object>();
    public static Map<String, Object> successResponseMap = new Map<String, Object>();
    public static Map<String, String> returnDetail = new Map<String, String>();
    
    @HttpPost
    global static void activateCrossSellProduct(){
        
        try{
            String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
            
            returnDetail = (Map<String, String>)JSON.deserialize(strJson, Map<String, String>.class);
            
            merchant_id = Integer.ValueOf(returnDetail.get('merchant_id'));
            
            product_name = returnDetail.get('product_name');
            
            proSell_name = returnDetail.get('sellProduct_name');
            
            proSell_activationDate = DateTime.valueOfGMT(returnDetail.get('activation_date'));
            
            product_type = returnDetail.get('product_type');
            
            addendum_status = returnDetail.get('addendum_status');
            List<Opportunity> oppDetails = New List<Opportunity>();
            List<Cross_Sell__c> csObjList = New List<Cross_Sell__c>();
            List<Contract> contractObjList = New List<Contract>();
            
            if(merchant_id != null && String.isNotBlank(product_name)){
                oppDetails = [Select Id,AccountId,Identifier__c,Product__r.Identifier__c,Prod_Merchant_Id__c,RecordTypeId
                              from Opportunity where Prod_Merchant_Id__c =:merchant_id
                              AND ProductLabel__c=:product_name ORDER BY LastModifiedDate Desc LIMIT 1];
            }else{
                failedResponseList.add('No Merchant Id found in SF Database.');
                MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                
            }
            
            if(!oppDetails.isEmpty() && oppDetails.size()>0){
                if(String.isNotBlank(proSell_name) || String.isNotBlank(product_type)){
                    string oppId = oppDetails[0].Id;
                    String oppAccountId = oppDetails[0].AccountId;
                    string query = 'SELECT Id, Name, Type__c, AccountId, Account_UUID__c, E_Stamp_Number__c,URL__c,Document_Category_UUID__c,Document_Type_UUID__c,Document_Content_Type__c,Document_Category_Name__c,Document_Type_Name__c,Active__c,Contract_Type__c, Status FROM Contract WHERE AccountId =: oppAccountId AND Type__c =\'Final\' AND Active__c = True AND Contract_Type__c = \'Addendum\' AND Opportunity__c != null AND Status =\'Pending\'';
                    query += String.isNotBlank(oppDetails[0].Id) ? ' AND Opportunity__c =: oppId' : '';
                    query += String.isNotBlank(proSell_name) ? ' AND Name =: proSell_name' : String.isNotBlank(product_type) ? ' AND Name =: product_type' : '';
                    query += ' ORDER BY LastmodifiedDate Desc';
                    contractObjList = Database.query(query);
                }
                if(String.isNotBlank(proSell_name) && proSell_activationDate != null){
                    
                    csObjList = [Select Id, Enable_Date__c,Risk_Zone__c,Custom_Product__r.Name  
                                 from Cross_Sell__c Where Opportunity__c =:oppDetails[0].Id
                                 AND Custom_Product__r.Name=:proSell_name AND ProductLabel__c =:product_name];
                }
                /*contractObjList = [Select Id,Status From Contract Where AccountId =: oppDetails[0].AccountId AND Opportunity__c =: oppDetails[0].Id
AND Contract_Type__c = 'Addendum' AND KYC_Documentable_Type__c = 'Merchant' AND Active__c =True AND Name=: proSell_name
AND Status IN ('Pending')];
*/
                if(!csObjList.isEmpty() && csObjList.size()>0){
                    csObjList[0].Enable_Date__c = proSell_activationDate;
                    csObjList[0].Risk_Status__c = 'Approved';
                    csObjList[0].KAM_Status__c = 'Merchant Accepted';
                    
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    
                    gen.writeStringField('response','SUCCESS');
                    gen.writeStringField('sellProduct_name',csObjList[0].Custom_Product__r.Name==null ? proSell_name : csObjList[0].Custom_Product__r.Name);
                    gen.writeDateTimeField('enable_Date',csObjList[0].Enable_Date__c ==null ? proSell_activationDate : csObjList[0].Enable_Date__c );
                    gen.writeEndObject();
                    retrnJson = gen.getAsString();
                    
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(retrnJson);
                    
                    if(!csObjList.isEmpty()) update csObjList;
                    
                    if(!contractObjList.isEmpty()){
                        if(contractObjList[0].Status != 'Approved' || contractObjList[0].Status != 'Approved Activate') 
                            contractObjList[0].Status = 'Approved';
                        update contractObjList[0];
                    }
                }else if(csObjList.isEmpty() && csObjList.size() == 0 && String.isNotBlank(proSell_name) && proSell_activationDate != null){
                    List<CrossSell_Creation_crit__mdt> crossSellCreationMetadataList = [SELECT Active__c,Creation_Criteria__c,Product_Name__c,
                                                                                        ProductNameVsIdMap__c,ProductVsRecordTypeMap__c  
                                                                                        FROM CrossSell_Creation_crit__mdt Where
                                                                                        Product_name__c =:proSell_name];
                    
                    if(crossSellCreationMetadataList.size()>0){
                        for(CrossSell_Creation_crit__mdt mtd: crossSellCreationMetadataList){
                            Cross_Sell__c csObj = Batch_CrossSellCreationForOpportunity.createCSObject(oppDetails[0],mtd);
                            csObj.Enable_Date__c = proSell_activationDate;
                            csObj.Risk_Status__c = 'Approved';
                            csObj.KAM_Status__c = 'Merchant Accepted';
                            csObjList.add(csObj);
                        }
                        
                        JSONGenerator gen = JSON.createGenerator(true);
                        gen.writeStartObject();
                        
                        gen.writeStringField('response','SUCCESS');
                        gen.writeStringField('sellProduct_name',csObjList[0].Custom_Product__r.Name==null ? proSell_name : csObjList[0].Custom_Product__r.Name);
                        gen.writeDateTimeField('enable_Date',csObjList[0].Enable_Date__c ==null ? proSell_activationDate : csObjList[0].Enable_Date__c );
                        gen.writeEndObject();
                        retrnJson = gen.getAsString();
                        
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.responseBody = Blob.valueOf(retrnJson);
                        
                        if(!csObjList.isEmpty()) upsert csObjList;
                        
                        
                    }else{
                        failedResponseList.add('Cross Sell product no configured in SF Metadata.');
                        MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                        
                    }
                }
                
                if(String.isNotBlank(product_type) && String.isNotBlank(addendum_status)){
                    if(!contractObjList.isEmpty()){
                        JSONGenerator gen = JSON.createGenerator(true);
                        gen.writeStartObject();
                        
                        gen.writeStringField('response','SUCCESS');
                        gen.writeStringField('product_type',product_type);
                        gen.writeStringField('addendum_status',addendum_status);
                        gen.writeEndObject();
                        retrnJson = gen.getAsString();
                        
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.responseBody = Blob.valueOf(retrnJson);
                        
                        if(contractObjList[0].Status != 'Approved' || contractObjList[0].Status != 'Approved Activate') 
                            contractObjList[0].Status = addendum_status;
                        update contractObjList[0];
                    }else{
                        failedResponseList.add('No Addendum found in SF Database.');
                        MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                    }
                }
            }
            
            
        }catch(Exception ex){
            failedResponseList.add(ex.getMessage());
            failedResponseList.add(ex.getStackTraceString());
            MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
            
        }
    }
}