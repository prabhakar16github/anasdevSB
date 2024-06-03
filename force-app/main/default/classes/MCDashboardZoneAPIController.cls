@RestResource(urlMapping='/MCDashboardZoneAPI/*')
global class MCDashboardZoneAPIController {
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
    public static Integer merchant_id;
    public static string product_name='';
    public static string crossSellProdName ='';
    public static Map<String, Object> failureResponseMap = new Map<String, Object>();
    public static Map<String, Object> successResponseMap = new Map<String, Object>();
    public static Map<String, String> returnDetail = new Map<String, String>();
    
    @HttpPOST
    global static void getRiskZoneStatus(){
        try{
            
            system.debug('RestContext.request '+RestContext.request);
            system.debug('RestContext.request.requestBody '+RestContext.request.requestBody);
            
            String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
            system.debug('strJson'+strJson);
            returnDetail = (Map<String, String>)JSON.deserialize(strJson, Map<String, String>.class);
            system.debug('returnDetail'+returnDetail);
            merchant_id = Integer.ValueOf(returnDetail.get('merchant_id'));
            product_name = returnDetail.get('product_name');
            crossSellProdName = returnDetail.get('sellProduct_name').replaceAll('\\s+', '');
            
            List<String> prodSellNameList = crossSellProdName.split(',');
            Map<string,String> prodNameVsZoneMap = New Map<String,String>();
            
            if(merchant_id != null){
                if(String.isNotBlank(product_name) && product_name !=''){
                    if(String.isNotBlank(crossSellProdName) && !prodSellNameList.isEmpty() && prodSellNameList.size()>0){
                        
                        Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
                        
                        List<Opportunity> oppDetails = [Select Id,AccountId,Identifier__c,Product__r.Identifier__c,Prod_Merchant_Id__c,MCC_Code__c,Enable_MCP__c,
                                                        Enable_EMI__c ,Enable_T_0__c ,Payout_Activation_Status__c ,
                                                        RecordTypeId,ProductLabel__c,BusinessCategory__r.Name,Website_Status__c,Settlement_Status__c,Aging__c,
                                                        CB_Ratio__c,Last_6_months_GMV__c,Business_Category__c,Sub_Category__r.Name,Account.SubCategoryName__c
                                                        from Opportunity where Prod_Merchant_Id__c =:merchant_id
                                                        AND ProductLabel__c=:product_name ORDER BY LastModifiedDate Desc LIMIT 1];
                        System.debug('###### oppDetails '+oppDetails);
                        
                        If(oppDetails.Size()>0 && !oppDetails.isEmpty()){
                            List<Cross_Sell__c> csObjList = [Select Id, Risk_Zone__c,Custom_Product__r.Name from Cross_Sell__c Where ProductLabel__c=:product_name AND
                                                             Opportunity__c=: oppDetails[0].Id AND Custom_Product__r.Name IN:prodSellNameList];
                            
                            if(csObjList.size()>0){
                                for(Cross_Sell__c csObj : csObjList){
                                    prodNameVsZoneMap.put(csObj.Custom_Product__r.Name,csObj.Risk_Zone__c);
                                }
                            }
                            System.debug('###### prodNameVsZoneMap '+prodNameVsZoneMap);
                            if(csObjList.size()>0 && !csObjList.isEmpty() && !prodNameVsZoneMap.isEmpty() && prodNameVsZoneMap.keySet().size() == prodSellNameList.Size()){
                                System.debug('###### prodNameVsZoneMap ss '+prodNameVsZoneMap.keySet().size());
                                JSONGenerator gen = JSON.createGenerator(true);
                                gen.writeStartObject();
                                //gen.writeStringField('status','SUCCESS');
                                gen.writeStringField('response','SUCCESS');
                                gen.writeStringField('merchant_id',String.valueOf(oppDetails[0].Prod_Merchant_Id__c));
                                gen.writeStringField('product_name',(oppDetails[0].ProductLabel__c!=null && oppDetails[0].ProductLabel__c !='') ? oppDetails[0].ProductLabel__c :'');
                                for(string eachProd : prodNameVsZoneMap.keySet()){
                                    gen.writeFieldName(eachProd);
                                    gen.writeStartObject();
                                    gen.writeStringField('sellProduct_name',eachProd);
                                    If(eachProd == 'EMI') gen.writeStringField('Zone_Status',prodNameVsZoneMap.get(eachProd) != null ? prodNameVsZoneMap.get(eachProd) : prodNameVsZoneMap.get(eachProd) == null && String.isNotBLANK(oppDetails[0].MCC_Code__c) ? 'Green Zone' : prodNameVsZoneMap.get(eachProd) == null && String.isBLANK(oppDetails[0].MCC_Code__c) ? 'Red Zone' : 'Red Zone');
                                    else gen.writeStringField('Zone_Status',prodNameVsZoneMap.get(eachProd) == null ? 'Red Zone' : prodNameVsZoneMap.get(eachProd));
                                    If(eachProd == 'MCP') gen.writeBooleanField('product_Enable',oppDetails[0].Enable_MCP__c);
                                    else If(eachProd == 'T+0') gen.writeBooleanField('product_Enable',oppDetails[0].Enable_T_0__c);
                                    else If(eachProd == 'EMI') gen.writeBooleanField('product_Enable',oppDetails[0].Enable_EMI__c);
                                    else If (eachProd == 'Payout') gen.writeBooleanField('product_Enable',oppDetails[0].Payout_Activation_Status__c == 'approved' ? True : False);
                                    gen.writeEndObject();
                                }
                                gen.writeEndObject();
                                retrnJson = gen.getAsString();
                                
                                RestContext.response.addHeader('Content-Type', 'application/json');
                                RestContext.response.responseBody = Blob.valueOf(retrnJson);
                                
                                Batch_CrossSellCreationForOpportunity csCreationBatch = new Batch_CrossSellCreationForOpportunity(true,oppDetails[0]);
                                database.executeBatch(csCreationBatch);
                            }else{
                                Boolean zoneCriteria = true;
                                Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentMCPMap = New Map<string,CrossSell_Risk_Zone_Assignment__mdt>();
    							Map<string,CrossSell_Risk_Zone_Assignment__mdt> zoneAssignmentEMIMap = New Map<string,CrossSell_Risk_Zone_Assignment__mdt>();
                                for(CrossSell_Risk_Zone_Assignment__mdt assMDT : [Select Id,Business_Category__c,Product_Name__c,Sub_Category_Vs_Risk_Zone__c,
                                                                                  MCC_Code__c from CrossSell_Risk_Zone_Assignment__mdt]){
                                                                                      If(String.isNotBlank(assMDT.Business_Category__c) && assMDT.Product_Name__c == 'MCP'){
                                                                  zoneAssignmentMCPMap.put(assMDT.Business_Category__c,assMDT);
                                                              }
                                                              If(String.isNotBlank(assMDT.Business_Category__c) && assMDT.Product_Name__c == 'EMI'){
                                                                  zoneAssignmentEMIMap.put(assMDT.Business_Category__c,assMDT);
                                                              }
                                                                                  }
                                
                                List<CrossSell_Creation_crit__mdt> crossSellCreationMetadataList = [SELECT Active__c,Creation_Criteria__c,Product_Name__c,
                                                                                                    ProductNameVsIdMap__c,ProductVsRecordTypeMap__c  
                                                                                                    FROM CrossSell_Creation_crit__mdt Where
                                                                                                    Product_name__c IN:prodSellNameList];
                                system.debug('@@@@@@@ crossSellCreationMetadataList '+crossSellCreationMetadataList);
                                if(crossSellCreationMetadataList.size()>0){
                                    for(CrossSell_Creation_crit__mdt mtd: crossSellCreationMetadataList){
                                        If(!prodNameVsZoneMap.containsKey(mtd.Product_Name__c)){
                                            Cross_Sell__c csObjBatch = Batch_CrossSellCreationForOpportunity.createCSObject(oppDetails[0],mtd);
                                            if(mtd.Product_Name__c == 'T+0'){
                                                csObjBatch = Batch_CrossSellCreationForOpportunity.getISCrossSellZone(csObjBatch,oppDetails[0],mtd,zoneCriteria);
                                                prodNameVsZoneMap.put('T+0',csObjBatch.Risk_Zone__c);
                                            }
                                            if(mtd.Product_Name__c == 'MCP'){
                                                csObjBatch = Batch_CrossSellCreationForOpportunity.getMCPCrossSellZone(csObjBatch,oppDetails[0],mtd,zoneAssignmentMCPMap);
                                                prodNameVsZoneMap.put('MCP',csObjBatch.Risk_Zone__c);
                                            }
                                            if(mtd.Product_Name__c == 'EMI'){
                                                csObjBatch = Batch_CrossSellCreationForOpportunity.getEMICrossSellZone(csObjBatch,oppDetails[0],mtd,zoneAssignmentEMIMap);
                                                system.debug('@@@@@@@ csObjBatchnn '+csObjBatch);
                                                prodNameVsZoneMap.put('EMI', csObjBatch.Risk_Zone__c);
                                            }
                                            csObjList.add(csObjBatch);
                                        }
                                    }
                                    
                                    system.debug('@@@@@@@ prodNameVsZoneMap '+prodNameVsZoneMap);
                                    
                                    JSONGenerator gen = JSON.createGenerator(true);
                                    gen.writeStartObject();
                                    gen.writeStringField('response','Success');
                                    gen.writeStringField('merchant_id',String.valueOf(oppDetails[0].Prod_Merchant_Id__c));
                                    gen.writeStringField('product_name',(oppDetails[0].ProductLabel__c!=null && oppDetails[0].ProductLabel__c !='') ? oppDetails[0].ProductLabel__c :'');
                                    for(string eachProd : prodNameVsZoneMap.keySet()){
                                        gen.writeFieldName(eachProd);
                                        gen.writeStartObject();
                                        gen.writeStringField('sellProduct_name',eachProd);
                                        If(eachProd == 'EMI') gen.writeStringField('Zone_Status',prodNameVsZoneMap.get(eachProd) != null ? prodNameVsZoneMap.get(eachProd) : prodNameVsZoneMap.get(eachProd) == null && String.isNotBLANK(oppDetails[0].MCC_Code__c) ? 'Green Zone' : prodNameVsZoneMap.get(eachProd) == null && String.isBLANK(oppDetails[0].MCC_Code__c) ? 'Red Zone' : 'Red Zone');
                                        else gen.writeStringField('Zone_Status',prodNameVsZoneMap.get(eachProd) == null ? 'Amber Zone' : prodNameVsZoneMap.get(eachProd));
                                        If(eachProd == 'MCP') gen.writeBooleanField('product_Enable',oppDetails[0].Enable_MCP__c);
                                        else If(eachProd == 'T+0') gen.writeBooleanField('product_Enable',oppDetails[0].Enable_T_0__c);
                                        //else If(eachProd == 'EMI') gen.writeBooleanField('product_Enable',oppDetails[0].Enable_EMI__c);
                                       // else If(eachProd == 'EMI') gen.writePicklistField('product_Enable',oppDetails[0].Enable_EMI__c);
                                        else If (eachProd == 'Payout') gen.writeBooleanField('product_Enable',oppDetails[0].Payout_Activation_Status__c == 'approved' ? True : False);
                                        gen.writeEndObject();
                                    }
                                    gen.writeEndObject();
                                    retrnJson = gen.getAsString();
                                    
                                    RestContext.response.addHeader('Content-Type', 'application/json');
                                    RestContext.response.responseBody = Blob.valueOf(retrnJson);
                                    //upsert csObjList;
                                    
                                    Batch_CrossSellCreationForOpportunity csCreationBatch = new Batch_CrossSellCreationForOpportunity(true,oppDetails[0]);
                                    database.executeBatch(csCreationBatch);
                                }else{
                                    failedResponseList.add('Cross Sell product no configured in SF Metadata.');
                                    MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                                    
                                }
                            }
                        }else{
                            failedResponseList.add('No merchant Id found in SF database.');
                            MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                        }
                    }else{
                        failedResponseList.add('Cross Sell Prod Name is missing.');
                        MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                    }
                }else{
                    failedResponseList.add('Product name is missing.');
                    MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                }
            }else{
                failedResponseList.add('Merchant Id is missing.');
                MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
            }
        }catch(Exception ex){
            failedResponseList.add(ex.getMessage());
            failedResponseList.add(ex.getStackTraceString());
            MCareDashboardAPIController.jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
        }
        
    }
}