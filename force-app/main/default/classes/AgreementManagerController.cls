/**************************************************************************************************************************************************************
@ Class:          AgreementManagerController
@ Author:         Shivdeep Yadav
@ Changes(Change1):   Adding Condition for not sending the agreement (08 Nov 2019 By Prashant Kulshrestha)
@ Purpose:        This Api class used to send the Aggrement through api
**************************************************************************************************************************************************************/

@RestResource(urlMapping='/generateAgreement/*')
global class AgreementManagerController{
    
    public static String retrnJson = '';
    public static List<String> failedResponseList = new List<String>();
    public static String strEndPoint = '';
    
    @HttpPost
    //Genrate Aggrement for Merchant
    global static void getAgreementUrl(){
        
        Map<String, Object> failureResponseMap = new Map<String, Object>();
        List<Contract> conDetail = new List<Contract>();
        List<E_Stamp_Master__c> lstEStampMaster = new List<E_Stamp_Master__c>();
        Map<String, String> returnDetail = new Map<String, String>();
        List<Document_Master__c> docDetail = new List<Document_Master__c>();
        String merchant_uuid;
        Boolean checkWebsiteAvailability;
        
        try{
            String strJson = SystemUtility.BlobToString(RestContext.request.requestBody, 'UTF-8');
            system.debug('strJson'+strJson);
            returnDetail = (Map<String, String>)JSON.deserialize(strJson, Map<String, String>.class);
            system.debug('returnDetail'+returnDetail);
            merchant_uuid = returnDetail.get('merchant_uuid');
            
            //Change1 Update Opportunity condition
            List<Opportunity> oppDetail = [Select Id, AccountId, Account.Identifier__c, Lead_Type__c, Account.Business_Entity__c, 
                                           Product__c, Account.Type__c, E_Stamp__c,Partner__r.Identifier__c,Partner_ID__c,
                                           Customized_Agreement__c,Android_URL__c,iOS_URL__c,Website__c,Integration_Type__c, 
                                           Fee_Model__c,New_MSA__c, Identifier__c,Business_Entity__c,Is_Partner_reffered_Merchant_Customized__c, Business_Entity__r.Name FROM Opportunity WHERE Identifier__c =: merchant_uuid];
            //Add Condition for check the value is null 
            //===========Commenting the code as we are now using to generate the agreement for tools merchants========== 
            /*if(!oppDetail.isEmpty()){                           
                if(String.isNotBlank(oppDetail[0].Integration_Type__c) && oppDetail[0].Integration_Type__c == 'Thirdparty' && (string.isNotBlank(oppDetail[0].Android_URL__c) || string.isNotBlank(oppDetail[0].iOS_URL__c) || string.isNotBlank(oppDetail[0].Website__c))){
                    checkWebsiteAvailability = false;
                }else if(String.isNotBlank(oppDetail[0].Integration_Type__c) && oppDetail[0].Integration_Type__c == 'Tools' && string.isBlank(oppDetail[0].Android_URL__c) && string.isBlank(oppDetail[0].iOS_URL__c) && string.isBlank(oppDetail[0].Website__c)){
                    checkWebsiteAvailability = false;
                }else{
                    checkWebsiteAvailability = true;
                }
            }  
            */
            if(!oppDetail.isEmpty() && String.isNotBlank(oppDetail[0].AccountId)){
                conDetail = [Select Id, Name, Type__c, AccountId, Account_UUID__c, E_Stamp_Number__c,URL__c,
                             Document_Category_UUID__c,Document_Type_UUID__c,Document_Content_Type__c,Document_Category_Name__c,
                             Document_Type_Name__c,Opportunity_UUID__c,Opportunity__c,
                             Active__c,Contract_Type__c, Status FROM Contract WHERE AccountId =: oppDetail[0].AccountId
                             AND Type__c = 'Final' AND Status=:'Pending' AND Contract_Type__c='Agreement' ORDER BY LastmodifiedDate Desc];
                /*conDetail = [Select Id, Name, Type__c, AccountId FROM Contract WHERE AccountId =: oppDetail[0].AccountId AND Type__c = 'Final'];*/
            }
            System.debug('######## conDetail '+conDetail);
            lstEStampMaster = [SELECT Id, EStamp_Number__c, Active__c, Used__c FROM E_Stamp_Master__c 
                               WHERE Active__c = true AND Used__c = false ORDER BY EStamp_Number__c ASC LIMIT 500];
            
            E_Stamp_Master__c randomEStampObj = new E_Stamp_Master__c();
            
            Map<String, String> mapContentType = (Map<String, String>) json.deserialize(Label.ContentTypeBasedOnFileType,Map<String, String>.class);
            
            if(oppDetail.size() > 0 && String.isNotBlank(oppDetail[0].Account.Business_Entity__c) && conDetail.isEmpty() &&
               !lstEStampMaster.isEmpty() && String.isNotBlank(oppDetail[0].Lead_Type__c) && lstEStampMaster != null
               && String.isNotBlank(oppDetail[0].AccountId) && String.isNotBlank(oppDetail[0].Product__c) /*&& checkWebsiteAvailability ==false*/){
                   
                   system.debug(lstEStampMaster.size()+' ******* lstEStampMaster ------------ '+lstEStampMaster); 
                   
                   Integer randomNumber = RandomUtility.generateRandomFromRange(0, lstEStampMaster.size());
                   system.debug('randomNumber ------------ '+randomNumber); 
                   
                   if(randomNumber != null){
                       if(randomNumber == 0)    randomEStampObj = lstEStampMaster[randomNumber];
                       else randomEStampObj = lstEStampMaster[randomNumber-1];
                   }
                   //String estampNum = lstEStampMaster[0].EStamp_Number__c;
                   docDetail = getDocMasterDetail(oppDetail[0]);
                   
                   system.debug('docDetail'+docDetail);
                   if(docDetail != null && !docDetail.isEmpty() && docDetail.size() > 0 && String.isNotBlank(docDetail[0].Page_Association__c)){
                       Blob body;
                       PageReference pageRef = getPageRef(oppDetail[0],docDetail[0],body);
                       
                       if(randomEStampObj != null && randomEStampObj.Id != null && randomEStampObj.EStamp_Number__c != null){
                           pageRef.getParameters().put('eStampNo', String.valueof(randomEStampObj.EStamp_Number__c));
                       }
                       
                       if(!Test.isRunningTest()){
                           body = pageRef.getContentAsPDF();
                       }else{
                           body = Blob.valueOf('Test Attachment Body');
                       }
                       
                       if(String.isNotBlank(oppDetail[0].AccountId)){
                                                                                 
                           Contract eachCon = new Contract();
                           
                           eachCon.Document_Content_Type__c = mapContentType.get('pdf');
                           eachCon.Document_Category_Name__c = (docDetail[0].Document_Category__r.Name != null) ? docDetail[0].Document_Category__r.Name : 'Service Agreement';
                           eachCon.Document_Type_Name__c = (docDetail[0].Document_Type__r.Name != null) ? docDetail[0].Document_Type__r.Name : 'Service Agreement';
                           system.debug('eachCon==' +eachCon);
                           eachCon.Opportunity__c = oppDetail[0].Id;
                           if(Test.isRunningTest()){
                               strEndPoint = 'https://bdnqfip6ci.execute-api.ap-south-1.amazonaws.com/test/accounts/c5f4-795d-241bbef8-083d-17a874dffc15/documents/fd7270870b79a426ec2aa98618cc4c73';
                           }else{
                               //strEndPoint = AWSUtility.uploadAndGetDocUrlS3(eachCon, oppDetail[0].Account.Identifier__c, body);
                               strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(eachCon, oppDetail[0].Identifier__c, body, 'merchants');
                           }
                           system.debug('strEndPoint==' +strEndPoint);
                           
                           if(String.isNotBlank(strEndPoint)){                               
                               JSONGenerator gen = JSON.createGenerator(true);
                               gen.writeStartObject();
                               gen.writeStringField('status','success');
                               gen.writeStringField('response','success');
                               gen.writeFieldName('data');
                               gen.writeStartObject();
                               gen.writeStringField('document_category_uuid', docDetail[0].Document_Category__r.Identifier__c == null ? '' : docDetail[0].Document_Category__r.Identifier__c);
                               gen.writeStringField('document_type_uuid', docDetail[0].Document_Type__r.Identifier__c == null ? '' : docDetail[0].Document_Type__r.Identifier__c);
                               gen.writeStringField('document_path', strEndPoint == null ? '' : strEndPoint);
                               gen.writeStringField('account_uuid', oppDetail[0].Account.Identifier__c == null ? '' : oppDetail[0].Account.Identifier__c);
                               gen.writeStringField('kyc_document_type', 'Agreement');
                               gen.writeStringField('verification_status', 'Pending');
                               gen.writeStringField('e_stamp_number', randomEStampObj == null || randomEStampObj.Id == null || randomEStampObj.EStamp_Number__c == null ? '' : randomEStampObj.EStamp_Number__c);
                               gen.writeBooleanField('active', false);
                               gen.writeStringField('merchant_uuid', merchant_uuid == null ? '' : merchant_uuid); 
                               gen.writeBooleanField('msa_flag', true);
                               gen.writeEndObject();
                               gen.writeEndObject();
                               retrnJson = gen.getAsString();
                               
                               RestContext.response.addHeader('Content-Type', 'application/json');
                               RestContext.response.responseBody = Blob.valueOf(retrnJson);
                               
                               system.debug('response@@@@'+retrnJson);
                               
                               if(randomEStampObj != null && randomEStampObj.Id != null && randomEStampObj.EStamp_Number__c != null){
                                   E_Stamp_Master__c eachEStamp = new E_Stamp_Master__c(Id=randomEStampObj.Id, Used__c=True);
                                   update eachEStamp;
                                   
                                   // ========== added by Uma Shankar at Apr.24, 2019 =============== 
                                   oppDetail[0].E_Stamp__c = randomEStampObj.Id;
                                   
                               }
                               oppDetail[0].New_MSA__c = true;
                               update oppDetail[0];
                               //updateEstamp(lstEStampMaster.isEmpty() ? null : lstEStampMaster[0].Id);
                               // Commenting out as per discussion with KD on 9/1/19    
                           }//else{
                           //failedResponseList.add('URL generation failed. Please connect with SF admin.');
                           
                           //jsonFailResponse('FAILED', failedResponseList, failureResponseMap, returnDetail, merchant_uuid);
                           //}
                       }
                   }
                   else{
                       
                       failedResponseList.add('Agreement is not configured correctly under Document Master for this Entity.');
                       
                       jsonFailResponse('FAILED', failedResponseList, failureResponseMap, returnDetail, merchant_uuid);
                   }
               }else{
                   if(conDetail.size() > 0 && !conDetail.isEmpty() /*&& checkWebsiteAvailability == false*/ && oppDetail.size()>0){
                       docDetail = getDocMasterDetail(oppDetail[0]);
                       if(!docDetail.isEmpty() && docDetail != null && docDetail.size() > 0 && String.isNotBlank(docDetail[0].Page_Association__c)){
                           Blob body;
                           PageReference pageRef = getPageRef(oppDetail[0],docDetail[0],body);
                           if(String.isNotBlank(conDetail[0].E_Stamp_Number__c) && conDetail[0].E_Stamp_Number__c != null){
                               pageRef.getParameters().put('eStampNo', String.valueof(conDetail[0].E_Stamp_Number__c));
                           }
                           else if(conDetail[0].E_Stamp_Number__c ==null  && randomEStampObj != null && randomEStampObj.Id != null && randomEStampObj.EStamp_Number__c != null){
                               pageRef.getParameters().put('eStampNo', String.valueof(randomEStampObj.EStamp_Number__c));
                           }
                           if(!Test.isRunningTest()){
                               body = pageRef.getContentAsPDF();
                           }else{
                               body = Blob.valueOf('Test Attachment Body');
                           }
                           
                           conDetail[0].Document_Content_Type__c = mapContentType.get('pdf');
                           conDetail[0].Document_Category_Name__c = (docDetail[0].Document_Category__r.Name != null) ? docDetail[0].Document_Category__r.Name : 'Service Agreement';
                           conDetail[0].Document_Type_Name__c = (docDetail[0].Document_Type__r.Name != null) ? docDetail[0].Document_Type__r.Name : 'Service Agreement';
                           conDetail[0].Opportunity__c = oppDetail[0].Id;
                           if(Test.isRunningTest()){
                               strEndPoint = 'https://bdnqfip6ci.execute-api.ap-south-1.amazonaws.com/test/accounts/c5f4-795d-241bbef8-083d-17a874dffc15/documents/fd7270870b79a426ec2aa98618cc4c73';
                           }else{
                               //strEndPoint = AWSUtility.uploadAndGetDocUrlS3(conDetail[0], oppDetail[0].Account.Identifier__c, body);
                               strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(conDetail[0], oppDetail[0].Identifier__c, body,'merchants');
                           }
                       }
                       
						if(String.isNotBlank(strEndPoint)) conDetail[0].URL__c = strEndPoint;                       
                       JSONGenerator gen = JSON.createGenerator(true);
                       gen.writeStartObject();
                       gen.writeStringField('status','success');
                       gen.writeStringField('response','success');
                       gen.writeFieldName('data');
                       gen.writeStartObject();
                       gen.writeStringField('document_category_uuid', conDetail[0].Document_Category_UUID__c == null ? '' : conDetail[0].Document_Category_UUID__c);
                       gen.writeStringField('document_type_uuid', conDetail[0].Document_Type_UUID__c == null ? '' : conDetail[0].Document_Type_UUID__c);
                       gen.writeStringField('document_path', strEndPoint != null ? strEndPoint : conDetail[0].URL__c);
                       gen.writeStringField('account_uuid', conDetail[0].Account_UUID__c == null ? '' : conDetail[0].Account_UUID__c);
                       gen.writeStringField('kyc_document_type', 'Agreement');
                       gen.writeStringField('verification_status', String.isBlank(conDetail[0].Status)?'': conDetail[0].Status);
                       gen.writeStringField('e_stamp_number', conDetail[0].E_Stamp_Number__c == null ? '' : conDetail[0].E_Stamp_Number__c);
                       gen.writeBooleanField('active',conDetail[0].Active__c);
                       gen.writeStringField('merchant_uuid', merchant_uuid == null ? '' : merchant_uuid);
                       gen.writeBooleanField('msa_flag', true);
                       gen.writeEndObject();
                       gen.writeEndObject();
                       retrnJson = gen.getAsString();                           
                       RestContext.response.addHeader('Content-Type', 'application/json');
                       RestContext.response.responseBody = Blob.valueOf(retrnJson);
                   }else{
                       if(lstEStampMaster.isEmpty() || lstEStampMaster.size()==0)     failedResponseList.add('EStamp not available');
                       if(String.isBlank(merchant_uuid))  failedResponseList.add('Merchant uuid is blank.');
                       if(oppDetail.isEmpty() || oppDetail.size() == 0)    failedResponseList.add('Merchant doesn\'t exist.');
                       else if(String.isBlank(oppDetail[0].AccountId))     failedResponseList.add('Account doesn\'t exist for the given Merchant');
                       else if(String.isBlank(oppDetail[0].Account.Business_Entity__c))    failedResponseList.add('Business Entity doesn\'t exist for the given merchant');
                       else if(oppDetail[0].Lead_Type__c == 'Merchant' && String.isBlank(oppDetail[0].Product__c))    failedResponseList.add('Product doesn\'t exist for the given merchant');
                       //Change1 Update condition for throw Error
                       /*else if(checkWebsiteAvailability == true ) failedResponseList.add('Website criteria doesnt meet');*/
                       jsonFailResponse('FAILED', failedResponseList, failureResponseMap, returnDetail, merchant_uuid);
                   }
               }
        }catch(exception e){
            system.debug('-->> '+e.getLineNumber()+' '+e.getMessage());
            failedResponseList.add(e.getMessage());
            failedResponseList.add(e.getStackTraceString());
            jsonFailResponse('FAILED', failedResponseList, failureResponseMap, returnDetail, merchant_uuid);
        }
    }
    
    public static void jsonFailResponse(String strStatus, List<String> strMessage, Map<String, Object> failureResponseMap, Map<String, String> requestJson, String uuid){
        
        List<User> userId = [SELECT id FROM User WHERE name = 'Integration User' AND alias = 'iuser' Limit 1];
        
        Map<String, String> messages = new Map<String, String>();
        messages.put('Severity__c', 'High');
        messages.put('Message__c', String.valueOf(strMessage));
        messages.put('Process__c', 'Agreement API');        
        if(!requestJson.isEmpty()) messages.put('Request__c', JSON.serialize(requestJson));
        if(String.isNotBlank(uuid)) messages.put('Identifier__c', uuid);
        if(!userId.isEmpty() && userId.size()>0) messages.put('OwnerId', userId[0].Id);        
        SystemUtility.errorHandler(null, messages);
        
        
        
        /*Error_Details__c errorDetailsObj = new Error_Details__c();
errorDetailsObj.Severity__c = 'High';
errorDetailsObj.Message__c = String.valueOf(strMessage);
errorDetailsObj.Process__c = 'Agreement API';
if(!requestJson.isEmpty())  errorDetailsObj.Request__c = JSON.serialize(requestJson);
if(String.isNotBlank(uuid)) errorDetailsObj.Identifier__c = uuid;
if(!userId.isEmpty() && userId.size()>0)    errorDetailsObj.OwnerId = userId[0].Id;
insert errorDetailsObj;*/
        
        failureResponseMap.put('status', strStatus);  
        failureResponseMap.put('response', strMessage);     
        failureResponseMap.put('data', new Map<String, Object>());
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(failureResponseMap));
        RestContext.response.statusCode = 404;
    }
    
    public static List<Document_Master__c> getDocMasterDetail(Opportunity oppDetail){
        List<Document_Master__c> docDetail = New List<Document_Master__c>();
        String customLabelEntity = Label.Entity_Label;
        if(oppDetail.Lead_Type__c == 'Merchant' && String.isNotBlank(oppDetail.Product__c) && oppDetail.Customized_Agreement__c == false && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c,Customized_Agreement__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         Product__c =: oppDetail.Product__c AND RecordType.DeveloperName = 'Agreement' AND Active__c = True
                         AND Document_For__c =: oppDetail.Lead_Type__c AND Customized_Agreement__c = false Limit 1];
            // return docDetail;
        }else if(oppDetail.Lead_Type__c == 'ProductAccount' && String.isNotBlank(oppDetail.Product__c) && oppDetail.Customized_Agreement__c == false && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c,Customized_Agreement__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         Product__c =: oppDetail.Product__c AND RecordType.DeveloperName = 'Agreement' AND Active__c = True
                         AND Document_For__c =: oppDetail.Lead_Type__c AND Customized_Agreement__c = false Limit 1];
            // return docDetail;
        }else if(oppDetail.Lead_Type__c == 'Partner' && (customLabelEntity.contains(oppDetail.Business_Entity__c)) && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         RecordType.DeveloperName = 'Agreement' AND Active__c = True
                         AND Document_For__c =: oppDetail.Lead_Type__c];
            // return docDetail;
        }else if(oppDetail.Lead_Type__c == 'Partner' && (!customLabelEntity.contains(oppDetail.Business_Entity__c)) && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         RecordType.DeveloperName = 'Agreement' AND Active__c = True
                         AND Document_For__c =: oppDetail.Lead_Type__c];
            // return docDetail;
        }
        else if(oppDetail.Lead_Type__c == 'Aggregator' && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
            if(oppDetail.Customized_Agreement__c && String.isNotBlank(oppDetail.Partner__r.Identifier__c)){
                docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                             Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c 
                             FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                             RecordType.DeveloperName = 'Agreement' AND Active__c = True AND Partner_Identifier__c=:oppDetail.Partner__r.Identifier__c 
                             AND Document_For__c =: oppDetail.Lead_Type__c Limit 1];
                // return docDetail;
            }else if(oppDetail.Customized_Agreement__c == false && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
                docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                             Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c 
                             FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                             RecordType.DeveloperName = 'Agreement' AND Active__c = True AND Partner_Identifier__c=''
                             AND Document_For__c =: oppDetail.Lead_Type__c Limit 1];
                //return docDetail;
            } 
        }
        else if(oppDetail.Lead_Type__c == 'ProductAccount' && String.isNotBlank(oppDetail.Product__c) && oppDetail.Customized_Agreement__c == true && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c,Customized_Agreement__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         Product__c =: oppDetail.Product__c AND RecordType.DeveloperName = 'Agreement' AND Active__c = True
                         AND Document_For__c =: oppDetail.Lead_Type__c AND Customized_Agreement__c = true AND 
                         Partner_Identifier__c=: oppDetail.Partner_ID__c Limit 1];
            //return docDetail;
        }
        else if(oppDetail.Lead_Type__c == 'ProductAccount' && String.isNotBlank(oppDetail.Product__c) && oppDetail.Is_Partner_reffered_Merchant_Customized__c == true){
            System.debug('On line 314');
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c,Customized_Agreement__c,Is_Partner_reffered_Merchant_Customized__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         (Product__c =: oppDetail.Product__c) AND (RecordType.DeveloperName = 'Agreement') AND (Active__c = true) AND (Is_Partner_reffered_Merchant_Customized__c = true)
                         AND (Document_For__c =: oppDetail.Lead_Type__c) Limit 1];
         }
        else if(oppDetail.Lead_Type__c == 'Merchant' && String.isNotBlank(oppDetail.Product__c) && oppDetail.Customized_Agreement__c == true && oppDetail.Is_Partner_reffered_Merchant_Customized__c == false){
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c,Customized_Agreement__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         Product__c =: oppDetail.Product__c AND RecordType.DeveloperName = 'Agreement' AND Active__c = True
                         AND Document_For__c =: oppDetail.Lead_Type__c AND Customized_Agreement__c = true AND 
                         Partner_Identifier__c=: oppDetail.Partner_ID__c Limit 1];
            //return docDetail;
        }
        else if(oppDetail.Lead_Type__c == 'Merchant' && String.isNotBlank(oppDetail.Product__c) && oppDetail.Is_Partner_reffered_Merchant_Customized__c == true){
            System.debug('On line 314');
            docDetail = [Select Id, Name, Document_Category__c, Document_Category__r.Name, Document_Category__r.Identifier__c, 
                         Document_Type__c, Document_Type__r.Name, Document_Type__r.Identifier__c, Page_Association__c,Customized_Agreement__c,Is_Partner_reffered_Merchant_Customized__c 
                         FROM Document_Master__c WHERE (Entity__c =: oppDetail.Account.Business_Entity__c OR Entity__c =: oppDetail.Business_Entity__c) AND
                         (Product__c =: oppDetail.Product__c) AND (RecordType.DeveloperName = 'Agreement') AND (Active__c = true) AND (Is_Partner_reffered_Merchant_Customized__c = true)
                         AND (Document_For__c =: oppDetail.Lead_Type__c) Limit 1];
         }
        System.debug('@@@ docDetail '+docDetail);
        if(docDetail.Size()>0){
            return docDetail;
        }else{
            return null;
        }
    }
    
    public static PageReference getPageRef(Opportunity oppDetail,Document_Master__c docDetail,Blob body){
        PageReference pageRef = new PageReference('/apex/' + docDetail.Page_Association__c);
        pageRef.getParameters().put('id', oppDetail.Id);     
        pageRef.getParameters().put('strIsFinal', 'True');
        
        return pageRef;
    }
    /*
@future
public static void updateEstamp(Id eStampId){
if(eStampId != null){
E_Stamp_Master__c eachEStamp = new E_Stamp_Master__c(Id = eStampId, Used__c = True);
update eachEStamp;
}
}*/
}