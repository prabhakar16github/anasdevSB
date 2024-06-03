@RestResource(urlMapping='/MCDashboardAddendumAPI/*')
global class MCDashboardAddendumAPIController {
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
    public static Integer merchant_id;
    public static string product_name = '';
    public static string crossSellProdName = '';
    public static string product_type = '';
    public static Map<String, Object> failureResponseMap = new Map<String, Object>();
    public static Map<String, Object> successResponseMap = new Map<String, Object>();
    public static Map<String, String> returnDetail = new Map<String, String>();
    public static String strEndPoint = '';
    public static Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType,Map<String, String>.class);
    
    @HttpPost
    global static void getCrossSellProductAddendum(){
        
        try{
            List<Contract> contractDetail = new List<Contract>();
            List<Document_Master__c> docDetail = new List<Document_Master__c>();
            String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
            system.debug('strJson'+strJson);
            returnDetail = (Map<String, String>)JSON.deserialize(strJson, Map<String, String>.class);
            system.debug('returnDetail'+returnDetail);
            merchant_id = Integer.ValueOf(returnDetail.get('merchant_id'));
            product_name = returnDetail.get('product_name');
            crossSellProdName = returnDetail.get('sellProduct_name');
            product_type = returnDetail.get('product_type');
            List<Cross_Sell__c> csObjList = New List<Cross_Sell__c>();
            Boolean checkContractUpsert = false;
            
            List<Opportunity> oppDetail = [Select Id, AccountId, Account.Identifier__c, Lead_Type__c, Account.Business_Entity__c, 
                                           Product__c, Account.Type__c, E_Stamp__c,Partner__r.Identifier__c,Partner_ID__c,Business_Entity__c,
                                           Customized_Agreement__c,Android_URL__c,iOS_URL__c,Website__c,Integration_Type__c, Identifier__c 
                                           FROM Opportunity WHERE Prod_Merchant_Id__c =: merchant_id AND ProductLabel__c=:product_name];
            
            if(!oppDetail.isEmpty() && String.isNotBlank(oppDetail[0].AccountId)){
                string oppId = oppDetail[0].Id;
                String oppAccountId = oppDetail[0].AccountId;
                string query = 'SELECT Id, Name, Type__c, AccountId, Account_UUID__c, E_Stamp_Number__c,URL__c,Document_Category_UUID__c,Document_Type_UUID__c,Document_Content_Type__c,Document_Category_Name__c,Document_Type_Name__c,Active__c,Contract_Type__c, Status FROM Contract WHERE AccountId =: oppAccountId AND Type__c =\'Final\' AND Active__c = True AND Contract_Type__c = \'Addendum\' AND Opportunity__c != null AND Status =\'Pending\'';
                query += String.isNotBlank(oppDetail[0].Id) ? ' AND Opportunity__c =: oppId' : '';
                query += String.isNotBlank(crossSellProdName) ? ' AND Name =: crossSellProdName' : '';
                query += String.isNotBlank(product_type) ? ' AND Name =: product_type' : '';
                query += ' ORDER BY LastmodifiedDate Desc';
                contractDetail = Database.query(query);
                
                if(String.isNotBlank(crossSellProdName)) csObjList = [Select Id from Cross_Sell__c Where Custom_Product__r.Name =: crossSellProdName AND Opportunity__c =:oppDetail[0].Id];
            }else{
                failedResponseList.add('No merchant Id found in SF database..');
                jsonFailResponse('FAILED', failedResponseList, failureResponseMap, returnDetail, string.ValueOf(merchant_id));
            }
            
            If(csObjList.isEmpty() && csObjList.size()==0 && String.isNotBlank(crossSellProdName)){
                List<CrossSell_Creation_crit__mdt> crossSellCreationMetadataList = [SELECT Active__c,Creation_Criteria__c,Product_Name__c,
                                                                                    ProductNameVsIdMap__c,ProductVsRecordTypeMap__c  
                                                                                    FROM CrossSell_Creation_crit__mdt Where
                                                                                    Product_name__c=: crossSellProdName];
                
                if(crossSellCreationMetadataList.size()>0){
                    for(CrossSell_Creation_crit__mdt mtd: crossSellCreationMetadataList){
                        Cross_Sell__c csObj = Batch_CrossSellCreationForOpportunity.createCSObject(oppDetail[0],mtd);
                        csObjList.add(csObj);
                    }
                    
                    Batch_CrossSellCreationForOpportunity csCreationBatch = new Batch_CrossSellCreationForOpportunity(true,oppDetail[0]);
                    database.executeBatch(csCreationBatch);
                }else{
                    failedResponseList.add('Cross Sell product no configured in SF Metadata.');
                    MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                    
                }
            }
            If(!csObjList.isEmpty() && csObjList.size()>0){
                docDetail = getDocMasterDetail(oppDetail[0], docDetail, crossSellProdName);
                getDocumentURL(oppDetail[0], crossSellProdName, docDetail, strEndPoint, contractDetail);
                system.debug('####### docDetail '+docDetail);
                if(!contractDetail.isEmpty()){
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('response','success');
                    gen.writeFieldName('data');
                    gen.writeStartObject();
                    gen.writeStringField('document_category_uuid', docDetail[0].Document_Category__r.Identifier__c == null ? '' : docDetail[0].Document_Category__r.Identifier__c);
                    gen.writeStringField('document_type_uuid', docDetail[0].Document_Type__r.Identifier__c == null ? '' : docDetail[0].Document_Type__r.Identifier__c);
                    gen.writeStringField('document_path', String.isNotBlank(contractDetail[0].URL__c) ? contractDetail[0].URL__c : '');
                    gen.writeStringField('account_uuid', oppDetail[0].Account.Identifier__c == null ? '' : oppDetail[0].Account.Identifier__c);
                    gen.writeStringField('kyc_document_type', 'Addendum');
                    gen.writeStringField('verification_status', String.isBlank(contractDetail[0].Status)?'': contractDetail[0].Status);
                    gen.writeBooleanField('active',contractDetail[0].Active__c);
                    gen.writeStringField('name',contractDetail[0].Name);
                    gen.writeStringField('merchant_uuid',oppDetail[0].Identifier__c == null ? '' : oppDetail[0].Identifier__c);
                    gen.writeEndObject();
                    gen.writeEndObject();
                    retrnJson = gen.getAsString();                           
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(retrnJson);
                }
                
                if(!contractDetail.isEmpty()) upsert contractDetail;
                
            }
            system.debug('####### product_type '+product_type);
            //================= Bank update addendum generation=====================
            if(String.isNotBlank(product_type)){
                docDetail = getDocMasterDetail(oppDetail[0], docDetail, product_type);
                getDocumentURL(oppDetail[0], product_type, docDetail, strEndPoint, contractDetail);
                if(!contractDetail.isEmpty()){
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('response','success');
                    gen.writeFieldName('data');
                    gen.writeStartObject();
                    gen.writeStringField('document_category_uuid', docDetail[0].Document_Category__r.Identifier__c == null ? '' : docDetail[0].Document_Category__r.Identifier__c);
                    gen.writeStringField('document_type_uuid', docDetail[0].Document_Type__r.Identifier__c == null ? '' : docDetail[0].Document_Type__r.Identifier__c);
                    gen.writeStringField('document_path', String.isNotBlank(contractDetail[0].URL__c) ? contractDetail[0].URL__c : '');
                    gen.writeStringField('account_uuid', oppDetail[0].Account.Identifier__c == null ? '' : oppDetail[0].Account.Identifier__c);
                    gen.writeStringField('kyc_document_type', 'Addendum');
                    gen.writeStringField('verification_status', String.isBlank(contractDetail[0].Status) ? '': contractDetail[0].Status);
                    gen.writeBooleanField('active',contractDetail[0].Active__c);
                    gen.writeStringField('name',contractDetail[0].Name);
                    gen.writeStringField('merchant_uuid',oppDetail[0].Identifier__c == null ? '' : oppDetail[0].Identifier__c);
                    gen.writeEndObject();
                    gen.writeEndObject();
                    retrnJson = gen.getAsString();                           
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(retrnJson);
                }
                if(!contractDetail.isEmpty()) upsert contractDetail;
            }
        }catch(Exception ex){
            failedResponseList.add(ex.getMessage());
            failedResponseList.add(ex.getStackTraceString());
            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
            
        }
    }
    
    public static List<Document_Master__c> getDocmasterDetail(Opportunity oppDetail, List<Document_Master__c> docDetail, string crossSellProdName){
        
        if((oppDetail.Lead_Type__c == 'Merchant' || oppDetail.Lead_Type__c == 'seller' || oppDetail.Lead_Type__c == 'aggregator')
           && String.isNotBlank(oppDetail.Product__c) && String.isNotBlank(crossSellProdName)){
               docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                            Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c,CS_Product_Name__c  
                            FROM Document_Master__c WHERE Entity__c =: oppDetail.Account.Business_Entity__c AND
                            Product__c =: oppDetail.Product__c AND RecordType.DeveloperName =: 'Addendum' AND Active__c = True
                            AND Document_For__c =: oppDetail.Lead_Type__c AND CS_Product_Name__c =: crossSellProdName Limit 1];
               
           }
        return docDetail;
    }
    
    public static void getDocumentURL(Opportunity oppObj, string addendumType, List<Document_Master__c> docDetail, string strEndPoint, List<Contract> contractDetail){
        
        if((String.isNotBlank(oppObj.Business_Entity__c) || String.isNotBlank(oppObj.Account.Business_Entity__c))
           && String.isNotBlank(oppObj.Lead_Type__c) && String.isNotBlank(oppObj.AccountId) 
           && String.isNotBlank(oppObj.Product__c)){
              
               if(docDetail != null && !docDetail.isEmpty() && docDetail.size() > 0 && String.isNotBlank(docDetail[0].Page_Association__c)){
                   Blob body;
                   PageReference pageRef = AgreementManagerController.getPageRef(oppObj,docDetail[0],body);
                   
                   if(!Test.isRunningTest()){
                       body = pageRef.getContentAsPDF();
                   }else{
                       body = Blob.valueOf('Test Attachment Body');
                   }
                   if(contractDetail.isEmpty() && contractDetail.size() == 0){
                       Contract eachCon = new Contract();
                       eachCon.Document_Content_Type__c = mapContentType.get('pdf');
                       eachCon.Document_Category_Name__c = (docDetail[0].Document_Category__r.Name != null) ? docDetail[0].Document_Category__r.Name : 'Service Agreement';
                       eachCon.Document_Type_Name__c = (docDetail[0].Document_Type__r.Name != null) ? docDetail[0].Document_Type__r.Name : 'Addendum';
                       
                       if(Test.isRunningTest()){
                           strEndPoint = 'https://bdnqfip6ci.execute-api.ap-south-1.amazonaws.com/test/accounts/c5f4-795d-241bbef8-083d-17a874dffc15/documents/fd7270870b79a426ec2aa98618cc4c73';
                       }else{
                           strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(eachCon, oppObj.Identifier__c, body, 'merchants');
                       }
                       system.debug('strEndPoint==' +strEndPoint);
                       If(String.isNotBlank(strEndPoint)){
                           eachCon.URL__c = strEndPoint;
                           eachCon.Name = addendumType;
                           eachCon.Opportunity__c = oppObj.Id;
                           eachCon.AccountId = oppObj.AccountId;
                           eachCon.Document_Category__c = docDetail[0].Document_Category__c;
                           eachCon.Document_Type__c = docDetail[0].Document_Type__c;
                           eachCon.Status = 'Pending';
                           eachCon.Contract_Type__c = 'Addendum';
                           eachCon.Active__c = True;
                           eachCon.KYC_Documentable_Type__c = 'Merchant';
                           contractDetail.add(eachCon);
                       }
                   }else{
                       contractDetail[0].Document_Content_Type__c = mapContentType.get('pdf');
                       contractDetail[0].Document_Category_Name__c = (docDetail[0].Document_Category__r.Name != null) ? docDetail[0].Document_Category__r.Name : 'Service Agreement';
                       contractDetail[0].Document_Type_Name__c = (docDetail[0].Document_Type__r.Name != null) ? docDetail[0].Document_Type__r.Name : 'Addendum';
                       
                       if(Test.isRunningTest()){
                           strEndPoint = 'https://bdnqfip6ci.execute-api.ap-south-1.amazonaws.com/test/accounts/c5f4-795d-241bbef8-083d-17a874dffc15/documents/fd7270870b79a426ec2aa98618cc4c73';
                       }else{
                           strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(contractDetail[0], oppObj.Identifier__c, body, 'merchants');
                       }
                       contractDetail[0].URL__c = strEndPoint;
                   }
               }else{
                   failedResponseList.add('Addendum is not configured correctly under Document Master for this Entity.');
                   jsonFailResponse('FAILED', failedResponseList, failureResponseMap, returnDetail, string.ValueOf(merchant_id));
               }
           }else{
               if(String.isBlank(oppObj.Business_Entity__c) && String.isBlank(oppObj.Account.Business_Entity__c)) failedResponseList.add('Addendum is not configured correctly under Document Master for this Entity.');
               if(String.isBlank(oppObj.Lead_Type__c)) failedResponseList.add('Lead is not Matching.');
               if(String.isBlank(oppObj.ProductLabel__c)) failedResponseList.add('Product is Missing.');
               jsonFailResponse('FAILED', failedResponseList, failureResponseMap, returnDetail, string.ValueOf(merchant_id));
           }
    }
    
    public static void jsonFailResponse(String strStatus, List<String> strMessage, Map<String, Object> failureResponseMap, Map<String, String> requestJson, String uuid){
        
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Message__c', String.valueOf(strMessage));
        messages.put('Process__c', 'Dashboard Addendum API');        
        if(!requestJson.isEmpty()) messages.put('Request__c', JSON.serialize(requestJson));
        if(String.isNotBlank(uuid)) messages.put('Identifier__c', uuid);
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);        
        SystemUtility.errorHandler(null, messages);
        
        //failureResponseMap.put('status', strStatus);  
        failureResponseMap.put('response', strMessage);     
        failureResponseMap.put('data', new Map<String, Object>());
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(failureResponseMap));
        RestContext.response.statusCode = 404;
    }
    
}