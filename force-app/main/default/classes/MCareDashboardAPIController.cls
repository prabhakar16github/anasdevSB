@RestResource(urlMapping='/MCareDashboardController/*')
global class MCareDashboardAPIController {
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
    public static string docFilepath = '';
    public static Integer merchant_id;
    public static string ticket_id='';
    public static string product_name='';
    public static Map<String, Object> failureResponseMap = new Map<String, Object>();
    public static Map<String, Object> successResponseMap = new Map<String, Object>();
    public static Map<String, String> returnDetail = new Map<String, String>();
    
    @HttpPost
    global static void createActivationDocument(){
        
        blob docBody;
        string transaction_id;
        string content_Type;
        Boolean noDocAvailable=false;
        try{
            RestRequest req = RestContext.request;
            RestResponse res = Restcontext.response;
            System.debug('---!!!'+req);
            System.debug('---!!!'+res);
            
            if(String.isNotBlank(req.params.get('merchant_id')) && req.params.get('merchant_id')!='' && req.params.get('merchant_id')!=null){
                if(String.isNotBlank(req.params.get('ticket_id')) && req.params.get('ticket_id')!='' && req.params.get('ticket_id')!=null){
                    if(String.isNotBlank(req.params.get('product_name')) && req.params.get('product_name')!='' && req.params.get('product_name')!=null){
                        merchant_id = Integer.ValueOf(req.params.get('merchant_id'));
                        System.debug('###### merchant_id '+merchant_id);
                        ticket_id = req.params.get('ticket_id');
                        System.debug('###### ticket_id '+ticket_id);
                        product_name = req.params.get('product_name');
                        System.debug('###### product_name '+product_name);
                        //System.debug('########1 body size '+req.requestBody.size());
						
						List<Opportunity> oppDetails = New List<Opportunity>();
						List<Case> csObjList = New List<Case>();
						List<Case> csObjFinalList = New List<Case>();
						Case csObj;
						List<Merchant_Document__c> mDocList = new List<Merchant_Document__c>();
						List<Merchant_Document__c> mDocListToUpdate = new List<Merchant_Document__c>();
						Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
						Id postRiskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
						
						System.debug('###### merchantRecordTypeId '+merchantRecordTypeId);
						System.debug('###### postRiskRecordTypeId '+postRiskRecordTypeId);
						  
						oppDetails = [Select Id,AccountId,Identifier__c,Product__r.Identifier__c,Prod_Merchant_Id__c,RecordTypeId
										from Opportunity where Prod_Merchant_Id__c =:merchant_id
										AND ProductLabel__c=:product_name ORDER BY LastModifiedDate Desc LIMIT 1];
						
						System.debug('###### oppDetails '+oppDetails);
						  
						If(oppDetails.size()>0 && !oppDetails.isEmpty()){
                            csObjList = [Select Id,Identifier__c,MCare_Document_Status__c from Case Where TicketId__c =: ticket_id AND Opportunity__c=: oppDetails[0].Id
                                         AND RecordTypeId=: postRiskRecordTypeId ORDER BY LastModifiedDate Desc LIMIT 1];
                        
							System.debug('###### csObjList '+csObjList);
								  
							if(csObjList.size()==0 && csObjList.isEmpty()){               
                                createCaseRecords(csObjFinalList, oppDetails[0],ticket_id, postRiskRecordTypeId);
                                Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Case');         
                                      
                                // call this method to get the identifier field value if not exist                    
                                SystemUtility.getIdentifierUUID(csObjFinalList[0], 'Identifier__c', enableUUIDObj);
									  
								//If(!csObjFinalList.isEmpty() && csObjFinalList.size()>0) upsert csObjFinalList;
									  
							}else If(csObjList.size()>0 && !csObjList.isEmpty()){
									csObjFinalList = csObjList;
							}
							System.debug('###### csObjFinalList '+csObjFinalList);		  
							if(!csObjFinalList.isEmpty() && csObjFinalList.size()>0){
									  
							    if((String.isBlank(req.params.get('transaction_id')) || req.params.get('transaction_id')=='' || req.params.get('transaction_id')==null)
									&& (req.requestBody == null || (req.requestBody != null && req.requestBody.Size()>5))){
										
										failedResponseList.add('Transaction Id is missing.');
										jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
								}else if((String.isNotBlank(req.params.get('transaction_id')) && req.params.get('transaction_id')!='' && req.params.get('transaction_id')!=null)){
									transaction_id = req.params.get('transaction_id');
									System.debug('###### transaction_id '+transaction_id);
									
									if(req.requestBody != null && req.requestBody.Size()>5 &&
										(String.isNotBlank(req.params.get('content_type')) && req.params.get('content_type')!='' && req.params.get('content_type')!=null)) {
											
                                            //docBody = req.requestBody;
                                            
											String base64Content = ( String ) JSON.deserialize( req.requestBody.toString(), String.class );                                            
                                            //string base64string = EncodingUtil.Base64Encode(jsonStr);
                                            docBody = EncodingUtil.base64Decode(base64Content);
											System.debug('######## body size '+docBody.size());
											content_type = req.params.get('content_type');
									
									}else if(req.requestBody != null && req.requestBody.Size()>5 &&
                                          (String.isBlank(req.params.get('content_type')) || req.params.get('content_type')=='' || req.params.get('content_type')==null)){
                                            failedResponseList.add('Content type is required with file body.');
                                            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                                          }else if(req.requestBody == null || req.requestBody.Size()<5 &&
                                          (String.isNotBlank(req.params.get('content_type')) && req.params.get('content_type')!='' && req.params.get('content_type')!=null)){
                                              failedResponseList.add('File body is required with content type.');
                                            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                                          }else if(req.requestBody == null || req.requestBody.Size()<5 &&
                                          (String.isBlank(req.params.get('content_type')) || req.params.get('content_type')=='' || req.params.get('content_type')==null)){
                                              failedResponseList.add('File body,content type is required with transaction id.');
                                            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                                          }
									}
									
                                If((String.isNotBlank(transaction_id) && transaction_id !='' && transaction_id !=null) &&
                                   (req.requestBody != null && req.requestBody.Size()>5) &&
                                   (String.isNotBlank(req.params.get('content_type')) && req.params.get('content_type')!='' && req.params.get('content_type')!=null)){
                                       System.debug('###### under trnsaction ');
                                       mDocList = [Select Id,URL__c,Document_Type_Name__c,Document_Category_Name__c,Document_Content_Type__c,
                                                   Case_site__c from Merchant_Document__c Where Case_site__c =:csObjFinalList[0].Id 
                                                   AND Transaction_Id__c=:transaction_id AND KYC_Documentable_Type__c = 'CaseWebsiteDetails' 
                                                   ORDER BY LastModifiedDate LIMIT 1];
                                       
                                       If(mDocList.size()>0 && !mDocList.isEmpty() && String.isNotBlank(transaction_id)){                                           
                                               Merchant_Document__c mDoc = New Merchant_Document__c(Id=mDocList[0].Id);
                                               mDoc.Document_Category_Name__c = 'MCare Dashboard Category';
                                               mDoc.Document_Type_Name__c = 'MCare Dashboard Type';										
                                               mDoc.Case_site__c = csObjFinalList[0].Id;
                                               
                                               If(docBody != null && String.isNotBlank(Content_Type)){
                                                   mDoc.Document_Content_Type__c = Content_Type;
                                                   if(Test.isRunningTest()){
                                                       docFilepath = 'https://bdnqfip6ci.execute-api.ap-south-1.amazonaws.com/test/accounts/c5f4-795d-241bbef8-083d-17a874dffc15/documents/fd7270870b79a426ec2aa98618cc4c73';
                                                   }else{
                                                       docFilepath = AWSUtility.uploadAndGetDocUrlS3(mDoc, csObjFinalList[0].Identifier__c, docBody);
                                                   }
                                                   
                                                   if(string.isNotBlank(docFilepath)){                            
                                                       mDoc.URL__c = docFilepath;
                                                       mDocListToUpdate.add(mDoc);
                                                   }
                                               }
                                           //Added by Animesh - Start
                                           if(mDocList[0].Case_site__c != NULL){ 
                                               RestContext.response.addHeader('Content-Type', 'application/json');
                                               RestContext.response.responseBody = Blob.valueOf(JSON.serialize(mDocList[0].Case_site__c)); 
                                           }else{
                                              csObjList = [Select Id,LP_Issue__c,Status,Identifier__c,MCare_Document_Status__c,TicketId__c,CreatedDate, LP_Category__c, LP_Transaction_Reason__c, Payment_Id__c from Case Where Opportunity__c=: oppDetails[0].Id
                                                                    AND RecordTypeId =: postRiskRecordTypeId ORDER BY LastModifiedDate LIMIT 1];
                                            System.debug('###### csObjList '+csObjList);
                                            if(csObjList.size()>0 && !csObjList.isEmpty()){
                                                JSONGenerator gen = JSON.createGenerator(true);
                                                gen.writeStartObject();
                                                gen.writeStringField('merchant_id',String.valueOf(merchant_id));
                                                gen.writeStringField('product_name',product_name);
                                                gen.writeStringField('hold_reason',csObjList[0].LP_Transaction_Reason__c);
                                                gen.writeStringField('ticket_id',csObjList[0].TicketId__c==null ?'' : csObjList[0].TicketId__c);
                                                gen.writeStringField('l1_disposition',csObjList[0].LP_Issue__c);
                                                gen.writeStringField('payment_ids',csObjList[0].Payment_Id__c);
                                                gen.writeStringField('created_on',String.valueOf(csObjList[0].CreatedDate));
                                                gen.writeStringField('case_status',String.valueOf(csObjList[0].Status));
                                                gen.writeEndObject();
                                                retrnJson = gen.getAsString();
                                                RestContext.response.addHeader('Content-Type', 'application/json');
                                                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(retrnJson));
                                            }else{
                                                failedResponseList.add('No ticket Id found in SF database.');
                                                failureResponseMap.put('ticket_Id_Present',False);
                                                jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, Null);
                                            }
                                           }
                                           //-End
                                       }else if(mDocList.size()==0 && mDocList.isEmpty() && (String.isNotEmpty(transaction_id) 
                                                                                            && transaction_id !=null
                                                                                            && transaction_id != '' && transaction_id != NULL 
                                                                                            && String.isNotBlank(transaction_id))){
                                                                                                
																								Merchant_Document__c mDoc = New Merchant_Document__c();
                                                                                                mDoc.Document_Category_Name__c = 'MCare Dashboard Category';
                                                                                                mDoc.Document_Type_Name__c = 'MCare Dashboard Type';
                                                                                                
                                                                                                If(docBody != null && String.isNotBlank(Content_Type)){
																									mDoc.Document_Content_Type__c = Content_Type;
                                                                                                    
																									if(Test.isRunningTest()){
																										docFilepath = 'https://bdnqfip6ci.execute-api.ap-south-1.amazonaws.com/test/accounts/c5f4-795d-241bbef8-083d-17a874dffc15/documents/fd7270870b79a426ec2aa98618cc4c73';
                                                                                                    }else{
                                                                                                        docFilepath = AWSUtility.uploadAndGetDocUrlS3(mDoc, csObjFinalList[0].Identifier__c, docBody);
                                                                                                    }
                                                                                                    if(string.isNotBlank(docFilepath)){
                                                                                                        createMerchantDocument(mDoc,mDocListToUpdate,oppDetails[0],csObjFinalList[0],docFilepath,transaction_id);
                                                                                                    }
                                                                                                }
                                                                                                
										}
										 
                                            JSONGenerator gen = JSON.createGenerator(true);
                                            gen.writeStartObject();
                                            gen.writeStringField('status','SUCCESS');
                                            gen.writeStringField('response','');
                                            gen.writeStringField('Ticket Id',ticket_id);
                                            gen.writeEndObject();
                                            retrnJson = gen.getAsString();
                                            successResponseMap.put('status','SUCCESS');
                                            successResponseMap.put('response',failedResponseList.add(''));
                                            successResponseMap.put('Ticket Id',ticket_id);
                                            RestContext.response.addHeader('Content-Type', 'application/json');
                                            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponseMap));
										  	
                                            If(!csObjFinalList.isEmpty() && csObjFinalList.size()>0) upsert csObjFinalList;
                                            If(mDocListToUpdate.size()>0 && !mDocListToUpdate.isEmpty()){
                                                mDocListToUpdate[0].Case_site__c = csObjFinalList[0].Id;                                                
												upsert mDocListToUpdate;
                                                
                                                csObjFinalList[0].RiskHold_Document_Available__c = True;                                                
                                                update csObjFinalList[0];
											}
                                            
                                    }else if((String.isBlank(req.params.get('transaction_id')) || req.params.get('transaction_id')=='' || req.params.get('transaction_id')==null)
											//&& (String.isBlank(req.params.get('Content_Type')) || req.params.get('Content_Type')=='' || req.params.get('Content_Type')==null)
											//&& ((req.requestBody == null) || ( req.requestBody != null && req.requestBody.Size()<5)))
											){
											
												csObjFinalList[0].MCare_Document_Status__c = 'Received';
												csObjFinalList[0].OwnerId = [Select Id from Group Where Type=:'Queue' AND DeveloperName=:'Waiting_On_Post_Onboarding_Risk' LIMIT 1].Id;
												
                                                oppDetails[0].RiskHold_Case_Available__c = True;
                                                update oppDetails[0];
                                                
                                                JSONGenerator gen = JSON.createGenerator(true);
												gen.writeStartObject();
												gen.writeStringField('status','SUCCESS');
												gen.writeStringField('response','');
												gen.writeStringField('Ticket Id',ticket_id);
												gen.writeEndObject();
												retrnJson = gen.getAsString();
												successResponseMap.put('status','SUCCESS');
												successResponseMap.put('response',failedResponseList.add(''));
												successResponseMap.put('Ticket Id',ticket_id);
												RestContext.response.addHeader('Content-Type', 'application/json');
												RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponseMap));
												  
												  If(!csObjFinalList.isEmpty() && csObjFinalList.size()>0) upsert csObjFinalList;
												  
                                            }else{
                                                csObjFinalList[0].MCare_Document_Status__c = 'Received';
												//csObjFinalList[0].OwnerId = [Select Id from Group Where Type=:'Queue' AND DeveloperName=:'Waiting_On_Post_Onboarding_Risk' LIMIT 1].Id;
                                                
                                                JSONGenerator gen = JSON.createGenerator(true);
												gen.writeStartObject();
												gen.writeStringField('status','SUCCESS');
												gen.writeStringField('response','');
												gen.writeStringField('Ticket Id',ticket_id);
												gen.writeEndObject();
												retrnJson = gen.getAsString();
												successResponseMap.put('status','SUCCESS');
												successResponseMap.put('response',failedResponseList.add(''));
												successResponseMap.put('Ticket Id',ticket_id);
												RestContext.response.addHeader('Content-Type', 'application/json');
												RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponseMap));
                                                
                                                upsert csObjFinalList;
                                            }									  
								
							}      
                        }else{
                                  failedResponseList.add('No merchant Id found in SF database.');
                                  jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                            }
                        
                    }else{
                        failedResponseList.add('Product name is missing.');
                        jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                    }
                }else{
                    failedResponseList.add('Ticket Id is missing.');
                    jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                }
            }else{
                failedResponseList.add('Merchant Id is missing.');
                jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
                
            }            
        }catch(Exception ex){
            System.debug('exceptv '+ex);
            failedResponseList.add(ex.getMessage());
            failedResponseList.add(ex.getStackTraceString());
            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
        }
    }
    
    @HttpGet
    global static void getDocumentStatus(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        try{
			if(String.isNotBlank(req.params.get('merchant_id')) && req.params.get('merchant_id')!='' && req.params.get('merchant_id')!=null){
				if(String.isNotBlank(req.params.get('ticket_id')) && req.params.get('ticket_id')!='' && req.params.get('ticket_id')!=null){
					if(String.isNotBlank(req.params.get('product_name')) && req.params.get('product_name')!='' && req.params.get('product_name')!=null){
						merchant_id = Integer.ValueOf(req.params.get('merchant_id'));
						System.debug('###### merchant_id '+merchant_id);
						ticket_id = req.params.get('ticket_id');
						System.debug('###### ticket_id '+ticket_id);
						product_name = req.params.get('product_name');
						System.debug('###### product_name '+product_name);
						
						Id merchantRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
						Id postRiskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ETC Risk Opertaion').getRecordTypeId();
						System.debug('###### merchantRecordTypeId '+merchantRecordTypeId);
						System.debug('###### postRiskRecordTypeId '+postRiskRecordTypeId);
						
						List<Opportunity> oppDetails = [Select Id,AccountId,Identifier__c,Product__r.Identifier__c,Prod_Merchant_Id__c,
                                                        RecordTypeId,ProductLabel__c
														from Opportunity where Prod_Merchant_Id__c =:merchant_id AND RecordTypeId=:merchantRecordTypeId
														AND ProductLabel__c=:product_name ORDER BY LastModifiedDate LIMIT 1];
						System.debug('###### oppDetails '+oppDetails);
						
						If(oppDetails.Size()>0 && !oppDetails.isEmpty()){
							List<Case> csObjList = [Select Id,Identifier__c,MCare_Document_Status__c,TicketId__c from Case Where TicketId__c =: ticket_id 
													AND Opportunity__c=: oppDetails[0].Id
													AND RecordTypeId =: postRiskRecordTypeId ORDER BY LastModifiedDate LIMIT 1];
							System.debug('###### csObjList '+csObjList);
							if(csObjList.size()>0 && !csObjList.isEmpty()){
								JSONGenerator gen = JSON.createGenerator(true);
								gen.writeStartObject();
								gen.writeStringField('status','SUCCESS');
								gen.writeStringField('response','');
								gen.writeStringField('merchant_id',String.valueOf(oppDetails[0].Prod_Merchant_Id__c));
								gen.writeStringField('product_name',(oppDetails[0].ProductLabel__c!=null && oppDetails[0].ProductLabel__c !='') ? oppDetails[0].ProductLabel__c :'');
								gen.writeStringField('Document_Status',csObjList[0].MCare_Document_Status__c==null ?'Pending' : csObjList[0].MCare_Document_Status__c);
								gen.writeStringField('ticket_id',csObjList[0].TicketId__c==null ?'' : csObjList[0].TicketId__c);
								gen.writeEndObject();
								retrnJson = gen.getAsString();
								successResponseMap.put('status','SUCCESS');
								successResponseMap.put('response',failedResponseList.add(''));                
								successResponseMap.put('merchant_id',String.valueOf(oppDetails[0].Prod_Merchant_Id__c));
								successResponseMap.put('product_name',oppDetails[0].ProductLabel__c);
								successResponseMap.put('Document_Status',csObjList[0].MCare_Document_Status__c==null ?'Pending' : csObjList[0].MCare_Document_Status__c);
								successResponseMap.put('Ticket Id',csObjList[0].TicketId__c==null ?'' : csObjList[0].TicketId__c);
								successResponseMap.put('ticket_Id_Present',(csObjList[0].TicketId__c==null || csObjList[0].TicketId__c=='') ? False : True);
								RestContext.response.addHeader('Content-Type', 'application/json');
								RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponseMap));
								// RestContext.response.addHeader('Content-Type', 'application/json');
								//RestContext.response.responseBody = Blob.valueOf(retrnJson);
							}else{
								failedResponseList.add('No ticket Id found in SF database.');
								failureResponseMap.put('ticket_Id_Present',False);
								jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
							}
						}else{
							failedResponseList.add('No merchant Id found in SF database.');
							jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
						}
					}else{
						failedResponseList.add('Product name is missing.');
						jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
					}
				}else{
					failedResponseList.add('Ticket Id is missing.');
					jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
				}
			}else{
				failedResponseList.add('Merchant Id is missing.');
				jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
			}
		}catch(Exception ex){
			failedResponseList.add(ex.getMessage());
            failedResponseList.add(ex.getStackTraceString());
            jsonFailResponse('ERROR', failedResponseList, failureResponseMap, returnDetail, string.valueOf(merchant_id));
		}
    }
    
    public static void createCaseRecords(List<Case> csObjList, Opportunity oppDetails,string ticket_id, Id postRiskRecordTypeId){
        Case csObj = New Case();
        csObj.Opportunity__c = oppDetails.Id;
        csObj.AccountId = oppDetails.AccountId;
        OpportunityContactRole oppConRole = [Select OpportunityId,ContactId From OpportunityContactRole 
                                             Where OpportunityId=:oppDetails.Id ORDER BY LastModifiedDate LIMIT 1];
        
        If(oppConRole != null) csObj.ContactId = oppConRole.ContactId;
        else csObj.ContactId = [Select Id from Contact Where AccountId =: oppDetails.AccountId ORDER BY LastModifiedDate LIMIT 1].Id;
        
        csObj.TicketId__c = ticket_id;
        csObj.RecordTypeId = postRiskRecordTypeId;
        csObj.OwnerId = [Select Id from Group Where Type=:'Queue' AND DeveloperName=:'Waiting_On_Post_Onboarding_Risk' LIMIT 1].Id;
        csObj.Origin = 'MCare Dashboard';
        csObj.Status = 'New';
        csObj.Subject = 'Document Verification for Settlement from Dashboard';
        csObj.MCare_Document_Status__c = 'Pending';
        csObjList.add(csObj);
    }
    
    public static void createMerchantDocument(Merchant_Document__c mDoc,List<Merchant_Document__c> mDocListToUpdate, Opportunity oppDetails,Case csObj,String docFilepath,String transaction_id){
        mDoc.Case_site__c = csObj.Id;
        mDoc.Transaction_Id__c = transaction_id;
        mDoc.KYC_Documentable_Type__c = 'CaseWebsiteDetails';
        mDoc.URL__c = docFilepath;
        mDoc.Account__c = oppDetails.AccountId;
        mDoc.Opportunity__c = oppDetails.Id;
        mDoc.Active__c = True;
        mDoc.Onboarding_Status__c = 'Received';                            
        mDocListToUpdate.add(mDoc);
    }
    
    public static void jsonFailResponse(String strStatus, List<String> strMessage, Map<String, Object> failureResponseMap, Map<String, String> requestJson, String uuid){
        
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Message__c', String.valueOf(strMessage));
        messages.put('Process__c', 'MCare Agreement API');        
        if(!requestJson.isEmpty()) messages.put('Request__c', JSON.serialize(requestJson));
        if(String.isNotBlank(uuid)) messages.put('Identifier__c', uuid);
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);        
        SystemUtility.errorHandler(null, messages);
        
        Error_Details__c errorDetailsObj = new Error_Details__c();
        errorDetailsObj.Severity__c = 'High';
        errorDetailsObj.Message__c = String.valueOf(strMessage);
        errorDetailsObj.Process__c = 'MCare Agreement API';
        if(!requestJson.isEmpty())  errorDetailsObj.Request__c = JSON.serialize(requestJson);
        if(String.isNotBlank(uuid)) errorDetailsObj.Identifier__c = uuid;
        if(!userId.isEmpty() && userId.size()>0)    errorDetailsObj.OwnerId = userId[0].Id;
        insert errorDetailsObj;
        
        failureResponseMap.put('status', strStatus);  
        failureResponseMap.put('response', strMessage);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(failureResponseMap));
        RestContext.response.statusCode = 200;
    }
}