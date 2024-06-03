public class FileUploaderClass {
    
    @AuraEnabled
    public static list<ContentVersion> returnFiles(list<String> lstFileIds){
        return [SELECT Id, Title FROM ContentVersion WHERE Id IN :lstFileIds];
    }
    
    @AuraEnabled
    public static list<Id> saveFiles(list<Object> filesToInsert,String caseId){
        
        list<Id> lstCntVerIds = new list<Id>();
        FileInfo fileData = new FileInfo();
        
        
        List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
        Map<String,String> mapConVerIdCaseID = new Map<String,String>();
        for (Object file : filesToInsert) {
            fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
            system.debug('fileData== '+fileData.fileType);
            system.debug('fileData.Title=='+fileData.Title);
            system.debug('caseId== '+caseId);
            ContentVersion objCntVersion = new ContentVersion();
            objCntVersion.PathOnClient = fileData.Title;
            objCntVersion.Title = fileData.Title;
            objCntVersion.VersionData = EncodingUtil.base64Decode(fileData.VersionData);
            lstVersionsToInsert.add(objCntVersion);
            //mapConVerIdCaseID.put(fileData.Title, fileData.fileType);
            
        }
        GuestUserUtilityHelper.upsertSObjectList(lstVersionsToInsert);
		system.debug('@@@@@@@@@ lstVersionsToInsert '+lstVersionsToInsert);
        if(!lstVersionsToInsert.isEmpty()){
            for(ContentVersion contVersObj : lstVersionsToInsert){
                //mapConVerIdCaseID.put(contVersObj.Title, contVersObj.fileType);
                lstCntVerIds.add(contVersObj.Id);
                system.debug('@@@@@@@@@ for loop ');
            }
        }
        system.debug('@@@@@@@@@ lstCntVerIds '+lstCntVerIds);
        if(!lstCntVerIds.isEmpty()){
            getS3URL(lstCntVerIds, caseId);
        }
        return lstCntVerIds;
    }
    
    @future(callout = true)
    public static void getS3URL(List<Id> contentIds, String caseId){
        List<Merchant_Document__c> mdList = new List<Merchant_Document__c>();
        Map<String,String> fileTypeVsS3TypeMap = (Map<String,String>) JSON.deserialize(Label.ContentTypeBasedOnFileType, Map<String,String>.class);
        List<case> caseObj = [select id,identifier__c,accountId from case where Id = :caseId];
        for(ContentVersion each : [Select Id,FileType,FileExtension,Title,VersionData from ContentVersion Where Id IN: contentIds]){
            Merchant_Document__c merchantDoc = new Merchant_Document__c();
            merchantDoc.Document_Category__c = 'a080p00000Lz9dqAAB';
            merchantDoc.Document_Type__c = 'a0A0p000000j2yvEAA';
            merchantDoc.Document_Category_Name__c = 'Onecare Attachment';
            merchantDoc.Document_Type_Name__c = 'ChatBot';
            merchantDoc.Document_Content_Type__c = fileTypeVsS3TypeMap.get(each.FileExtension);
            merchantDoc.File_Name__c = each.Title;
            merchantDoc.Account__c = caseObj[0].AccountId;
            merchantDoc.Active__c = True;
            merchantDoc.KYC_Documentable_Type__c = 'OneCare';
            merchantDoc.case__c = caseobj[0].id;
            //insert merchantDoc;
            string strEndPoint = AWSUtility.uploadAndGetDocUrlS3Type(merchantDoc, caseObj[0].Identifier__c, each.VersionData, 'onecare');
            system.debug('##########n strEndPoint=='+strEndPoint);
            merchantDoc.URL__c = strEndPoint;
            
            postfeedItemViaRESTAPI(caseObj[0],strEndPoint);
            mdList.add(merchantDoc);
        }
        if(mdList.size()>0 && mdList != null) GuestUserUtilityHelper.upsertSObjectList(mdList);
    }
    
    @AuraEnabled
    public static string updateEmail(String emailId,string ContactId){
        String message = '';
        system.debug('ContactId=='+ContactId);
        if(String.isNotBlank(emailId) && String.isNotBlank(ContactId) 
           && emailId != null && ContactId != null){
               try{
                   List<Contact> conList = GuestUserUtilityHelper.querySobject('Contact','id = \''+ ContactId + '\'');
                   if(conList != null && conList.size() >0){
                       system.debug('conList=='+conList[0]);
                       Contact conObj = conList[0];
                       conObj.email = emailId ;
                       GuestUserUtilityHelper.upsertSObjectList(new list<Contact>{conObj});
                       message = 'Email updated successfully, Our team will reach you shortly at the contact address '+emailId;
                   }else{
                       message = 'Contact not found';
                   }
                   
               }catch(exception exp){
                   message = 'exception occured on line=='+exp.getLineNumber()+'message=='+exp.getMessage();
                   system.debug('exception occured on line=='+exp.getLineNumber()+'message=='+exp.getMessage());
               }
               
           }
        return message;
    }
    
    @AuraEnabled
    public static string createCase(Object caseToInsert){
        
        caseInfo caseData = (caseInfo)JSON.deserialize(JSON.serialize(caseToInsert), caseInfo.class);
        Map<string,string> ProductNameVsProductLabel = (map<string,string>)JSON.deserialize(System.Label.ProductNameVsProductLabel,map<string,string>.class);
        list<Case> lstOfUpsertCase = new list<Case>(); 
        
        Map<string,Contact> mapCaseNumCon = checkExistingContact(caseData);
        
        Contact Con = new Contact();
        Contact existingCon = new Contact();
        string retrunStr ='';
        
        String casenumber = '';
        if(mapCaseNumCon != null && !mapCaseNumCon.isEmpty()){
            for(String str : mapCaseNumCon.keySet()){
                if(str== ''){
                    Con = mapCaseNumCon.get('');
                }
                else{
                    Con = null;
                    casenumber = str;
                    existingCon = mapCaseNumCon.get(str);
                }
            }
        if(Con != null){
            String recordtype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
            system.debug('create new case');
            case newCase = new Case();
            newCase.LP_Issue__c = caseData.Issue;
            newCase.LP_Sub_Issue__c = caseData.SubIssue;
            newCase.Comments = caseData.Comment;
            newCase.recordTypeId = recordtype;
            newCase.Origin = 'Chat';
            newCase.LP_Issue_description__c = caseData.Comment;
            newCase.LP_Secondary_MobilePhone__c = caseData.Mobile;
            newCase.Customer_Email__c = 'Less than 50,000';
            newCase.Website__c = 'https://www.test.com';
            newCase.ContactId = Con.Id;
            newCase.AccountId = Con.AccountId;
            newCase.Subject = caseData.Issue;
            newCase.Merchant_Type__c = caseData.MerchantType;
            if(caseData.mid != null && caseData.Product != null &&
               caseData.mid != '{!MID}' && caseData.Product != '{!Product}'){
                   newCase.Merchant_Id__c = caseData.mid;
                   newCase.LP_Business_Vertical__c = ProductNameVsProductLabel.get(caseData.Product); 
               }
            else newCase.LP_Business_Vertical__c = 'PayU Money'; 
            newCase.LP_Category__c = newCase.LP_Business_Vertical__c;
            
            List<case> csList = new List<Case>{newCase};
                GuestUserUtilityHelper.upsertSObjectList(csList);
            
            //handle null later
            system.debug('casenumber==='+csList[0].id);
            id caseId = csList[0].id;
            List<Case> queriedCaseList = GuestUserUtilityHelper.querySobject('Case','id = \''+ caseId + '\'');
            
            system.debug('caseData.ChatTranscriptId =='+caseData.ChatTranscriptId );
            
            if(caseData.ChatTranscriptId != null && caseData.ChatTranscriptId != '{!$Context.RoutableId}'){
                String ChatTranscriptId = caseData.ChatTranscriptId;
                List<LiveChatTranscript> queriedChatList = GuestUserUtilityHelper.querySobject('LiveChatTranscript','id = \''+ ChatTranscriptId + '\'');
                system.debug('queriedChatList=='+queriedChatList[0]);
                
                if(queriedChatList.size() > 0 && queriedChatList != null) {
                    LiveChatTranscript updChatRec = queriedChatList[0];
                    updChatRec.CaseId = csList[0].id;
                    GuestUserUtilityHelper.updateObject(updChatRec);
                }
            }
            
            updateCaseOwner(String.valueOf(newCase.Id) ,String.valueOf(con.Id),recordtype);
            
            
            system.debug('Con.Id==='+Con.Id);
            retrunStr = 'Thanks for raising your concern with us. Your ticket ID for Issue:<b>' +caseData.Issue +'</b> & Sub-issue:<b>'+caseData.SubIssue+'</b>  is <b>'+String.valueOf(queriedCaseList[0].CaseNumber)+'</b>.;'+queriedCaseList[0].id+';'+Con.Email+';'+String.valueOf(queriedCaseList[0].CaseNumber)+';'+Con.Id;
            return retrunStr;
        }else{
            system.debug('existingCon.id='+existingCon.id);
            retrunStr = '<b>'+casenumber+'</b> for same issue already exists and is in-progress.; ;'+caseData.Email+';'+existingCon.id;
            return retrunStr;
        }
    }
        return retrunStr;
        
    }
    
    private static Map<String,Contact> checkExistingContact(caseInfo ticketData){
        String Mobile = '+91'+ticketData.Mobile;
        
        String accId = '';
        List<Contact> existingCon = new List<Contact>();
        Map<String,Contact> caseNumConMap = new Map<String,Contact>();
        
        if(ticketData.mid != null && ticketData.Product != null && ticketData.mid != '{!MID}' && ticketData.Product != '{!Product}'){
            system.debug('enter logged in flow');
            system.debug('ticketData.Product=='+ticketData.Product);
            system.debug('ticketData.mid=='+ticketData.mid);
            
            Decimal mid = Decimal.valueOf(ticketData.mid); 
            String Product = ticketData.Product;
            List<Opportunity> oppList = GuestUserUtilityHelper.querySobject('Opportunity', 'Prod_Merchant_Id__c = '+mid+' AND RecordType.Name=\'Merchant\' AND ProductLabel__c=\''+Product+'\''+' LIMIT 1');
            
            system.debug('oppList.size'+oppList.size());
            
            if(oppList.size() > 0 && oppList != null){ 
                accId = oppList[0].accountId;
                existingCon = [Select email,MobilePhone,id,accountId from Contact where AccountId = :accId limit 1];
                ticketData.Mobile = existingCon[0].MobilePhone;
                ticketdata.Email = existingCon[0].Email;
            }else{
                List<Lead> leadList = GuestUserUtilityHelper.querySobject('Lead', 'Prod_Merchant_Id__c = '+mid+' AND RecordType.Name!=\'Wibmo\' AND ProductLabel__c=\''+Product+'\''+' LIMIT 1');
                system.debug('leadList.size'+leadList.size());
                if(leadList.size() > 0 && leadList != null){
                    system.debug('leadList[0].MobilePhone=='+leadList[0].MobilePhone);
                    ticketData.Name = leadList[0].Name;
                    ticketData.Mobile = '+91' +leadList[0].MobilePhone;
                    ticketdata.Email = leadList[0].Email;
                    ticketData.MerchantType = 'Potential Lead';
                    system.debug('ticketData.Email=='+ticketData.Email+'....');
                    system.debug('ticketData.Mobile='+ticketData.Mobile+'.......');
                    existingCon = [SELECT id,mobilePhone,email,accountId from contact where email = :ticketData.Email  And mobilePhone = :ticketData.Mobile];
                }
            }
        }else{
            existingCon = [SELECT id,mobilePhone,email,accountId from contact where email = :ticketData.Email And mobilePhone = :Mobile];
        }
        
        
        if(existingCon != null && existingCon.size() >0){
            if(existingCon[0].AccountId != null) {
                String caseNumber = checkDuplicateCreation(ticketData,existingCon[0]);
                if(caseNumber != '') {
                    caseNumConMap.put(caseNumber,existingCon[0]);
                }    
                else {
                    caseNumConMap.put('',existingCon[0]);
                }
            }else{
                existingCon[0].AccountId = createAccount(ticketData.Name);
                GuestUserUtilityHelper.upsertSObjectList(new List<Contact>{existingCon[0]});
                caseNumConMap.put('',existingCon[0]);
            }
            return caseNumConMap;
        } 
        else{
            Contact con = createContact(ticketData);
            caseNumConMap.put('',con);
            return caseNumConMap ;
        }
        
    }
    
    private static String checkDuplicateCreation(caseInfo ticketData,Contact existingCon){
        
        List<case> existingCase = [Select id,contactId,accountID,casenumber from Case where contactId = :existingCon.Id and 
                                   LP_Issue__c = :ticketData.Issue and LP_Sub_Issue__c = :ticketData.SubIssue Limit 1];
        
        string casenumber = '';
        if(existingCase != null && existingCase.size() > 0) {
            casenumber = String.valueOf(existingCase[0].casenumber);
            return casenumber;
                
        }
        else return casenumber;
        
    }
    
    private static Contact createContact(caseInfo ticketData){
        Contact newContact = new Contact();
        newContact.Email = ticketData.Email;
        newContact.MobilePhone = ticketData.Mobile;
        newContact.AccountId = createAccount(ticketData.Name);
        newContact.LastName = ticketData.Name;
        ticketData.MerchantType = 'Potential Lead';
        GuestUserUtilityHelper.upsertSObjectList(new List<Contact>{newContact});
        return newContact;
    }
    
    private static string createAccount(String Name){
        Account newAccount = new Account();
        //=======Please fix this, getting error, workaround test use====
        if(String.isNotBlank(Name)) newAccount.Name = Name;
        //else newAccount.Name = 'ChatBot Account';
        insert newAccount;
        return newAccount.id;
    }
    
    @future
    public static void updateCaseOwner(String CaseId,String ContactId,String recordtype){
        system.debug('enter update owner');
        list<Case> lstOfUpsertCase = new list<Case>(); 
        
        if(CaseId != null && !String.isBlank(CaseId) && ContactId != null && !String.isBlank(ContactId) ){
            list<Case> caseList = GuestUserUtilityHelper.querySobject('Case','id = \''+ CaseId + '\'');
            List<Contact> contactList = GuestUserUtilityHelper.querySobject('Contact','id = \''+ ContactId + '\'');
            Case objCase = caseList[0];
            CareUtility.OwnerAndDedupeWrapper objWrap;
            OneCareProcessHelper.OwnerAndDedupeWrapper oneCareObjWrap;
            
            oneCareObjWrap = OneCareProcessHelper.getDuplicacyAndOwnership(objCase.Merchant_Type__c, objCase.LP_Issue__c , objCase.LP_Sub_Issue__c, objCase.LP_Business_Vertical__c,objCase.LP_Category__c,'MerchantCare');
            if(oneCareObjWrap != NULL && oneCareObjWrap.ownerId != NULL){
                
                objCase.ownerId = oneCareObjWrap.ownerId;
                objCase.TicketId__c = objCase.CaseNumber;
                GuestUserUtilityHelper.upsertSObjectList(caseList);
                
                System.debug('oneCareObjWrap.ownerId'+oneCareObjWrap.ownerId);
            }
            
        }
        
    }
    
    
    public static void postfeedItemViaRESTAPI(sObject sObj,String strEndPoint){
        HttpResponse response = New HttpResponse();
        HttpRequest req = new HttpRequest();
        List<string> bodyParams = New List<string>();
        String CLIENT_ID = '3MVG9aWdXtdHRrI3D9obQdrAEgQQiGCwc69UtQslKdS78oKDTE3tleaZoGCvB9uiSe2_1UAkc4WN2JjJpNYm9';
        String CLIENT_SECRET = '074E500633842F0118220C089526D6624CE4FEB651D83CB1BFF679B223E4D050';
        
        req.setEndpoint('https://payuin--onepayudev.my.salesforce.com/services/oauth2/token?');
        req.setMethod('POST');
        bodyParams.add('client_id' + '=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8'));
        bodyParams.add('client_secret' + '=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8'));
        bodyParams.add('username' + '=' + 'integration.user@payu.in.prod.onepayudev');
        bodyParams.add('password' + '=' + 'Integration@2');
        bodyParams.add('grant_type' + '=' + 'password');
        if(!bodyParams.isEmpty()){
            req.setBody(String.join(bodyParams, '&'));
        }
         response = new Http().send(req);  
        system.debug('######## response '+response.getbody());
        
        string token = '';
        
        Map<String, Object> theResMap = (Map<String, Object>)JSON.deserializeUntyped(response.getbody());
                    
                    if(theResMap.containsKey('access_token')){
                         token  = String.valueOf(theResMap.get('access_token'));
                    }
        system.debug('######## token '+token);
        
        if(String.isNotBlank(token)){
            HttpRequest request = new HttpRequest();
            HttpResponse resp = New HttpResponse();
            string linkurl = strEndPoint;
            String caseId = String.valueOf(sObj.get('Id'));
            request.setEndpoint('https://payuin--onepayudev.my.salesforce.com/services/data/v52.0/chatter/feed-elements');
        	request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setHeader('Content-Type' , 'application/json');
            string body = '{"body" : {"messageSegments" : [{"type" : "Text","text" : "'+linkurl+'"}]},"feedElementType" : "FeedItem","subjectId" : "'+caseId+'" ,"visibility" : "AllUsers"}';
            request.setBody(body);
            
            resp = new Http().send(request);
            system.debug('######## resp '+resp.getBody());
        }
    }
    
    
    public class FileInfo {
        public String Title;
        public String VersionData;
        public String fileType;
        public string fileName;
        public string CaseId;
    }
    
    public class caseInfo {
        public String Name;
        public String Mobile;
        public string Email;
        public string Comment;
        public String Issue;
        public string SubIssue;
        public string mid;
        public string Product;
        public string ChatTranscriptId;
        public string merchantType;
    }
}