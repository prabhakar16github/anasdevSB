public class MerchantStatusDetailsTriggerHandler {

    public static Boolean publisherFlag = getFlagValue();
    
    public static Boolean getFlagValue() {
        List<Publisher_Flag_for_Payload__mdt> listPublisherFlags = [SELECT Prevent_Payload__c FROM Publisher_Flag_for_Payload__mdt WHERE Label = 'Merchant_Status_Details__c'];
        if(listPublisherFlags != NULL && listPublisherFlags.size() > 0) {
       		if(listPublisherFlags[0].Prevent_Payload__c) return true;
            else return false; 
        }
        else return true;
    }
    // ******************(SFI-1179 START) By Saksham ********************
    private static String FROM_ADDRESS_FOR_Email = 'no_reply@payu.in';
    private static string SUBJECT_FOR_ONBOARDING_DOCS_ERROR = 'Alert: KYC documents verification failed for PayU MID ';
    private static string SUBJECT_FOR_REKYC_DOCS_ERROR = 'Alert: Re-KYC documents verification failed for PayU MID ';
    private static string SUBJECT_FOR_DORMANT_DOCS_ERROR = 'Account activation verification failed for PayU MID ';
    private static List<OrgWideEmailAddress> orgAddressList = [SELECT Id, Address, DisplayName, IsAllowAllProfiles 
                                                        FROM OrgWideEmailAddress 
                                                        WHERE Address = :FROM_ADDRESS_FOR_Email 
                                                        LIMIT 1];
    public static string addBodyInMail(String contactName) {
        string emailBody = '';
        emailBody += '<!doctype html<html><head><meta charset="utf-8"><title>PayU</title></head>';
        emailBody += '<body style="margin: 0; padding: 0; font-size: 100%; background: #f5f5f7;font-family: Arial">';
        emailBody += '<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" style="border: #cccccc solid 1px; background: #f5f5f5;border-spacing: 0;">';
        emailBody += '<tbody><tr><td>&nbsp;</td></tr><tr>';
        emailBody += '<td align="center" valign="top">';
        emailBody += '<table width="90%" cellpadding="0" cellspacing="0" border="0" align="center" style="background: #ffffff;box-shadow: 0 4px 14px 0 rgba(224, 224, 224, 0.47); padding: 0 28px 0 28px;">';
        emailBody += '<tbody><tr>';
        emailBody += '<td align="left" valign="top">';
        emailBody += '<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" style="padding: 28px 0 28px 0;">';
        emailBody += '<tbody><tr>';
        emailBody += '<td align="left" valign="top" style="border-bottom:#e9e9e9 solid 1px; padding: 0 0 18px 0;color: #000000;">';
        emailBody += '<p style="width: 100%;float: left; margin: 0; padding: 0;">';
        emailBody += '<span style="float: left;text-align: left;"><img src="https://i.imgur.com/7tmZI2W.png" width="68" alt="PayU logo"></span>';
        emailBody += '<span style="font-family: Arial;color:#000000;font-size:13px;letter-spacing:0.26px;float: right;text-align: right;padding: 10px 0 0 0;">Need help? <small style="border-bottom: #18af8b solid 2px;font-size: 13px;padding:0 0 3px 0;color: #000000;">';
        emailBody += '<a href="https://help.payu.in/" target="_blank" style="font-weight: bold;text-decoration: none;color: #000000;">Contact us</a>';
        emailBody += '</small></span></p>';
        emailBody += '<img src="https://payuin.secure.force.com/emailStatustracking/?emailTrackingId=" alt="PayU Logo" border="0" style="display: none;" id="salesforceIMGid"/>';
        emailBody += '</td></tr><tr>';
        emailBody += '<td align="left" valign="top">';
        emailBody += '<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" style="padding:30px 0 0 0;">';
        emailBody += '<tbody><tr><td align="left" valign="middle">';
        emailBody += '<p style="font-family: Arial;color:#1c1c1c;font-size:32px;vertical-align: middle; line-height: 36px;padding: 10px 0 10px 0; margin: 0;">Docs <br> Verification <br>Failed';
        emailBody += '</p></td>';
        emailBody += '<td align="right" valign="top">';
        emailBody += '<img src="https://i.imgur.com/JUDkooS.png" width="220" alt="infographic image">';
        emailBody += '</td></tr></tbody></table></td></tr><tr>';
        emailBody += '<td align="left" valign="top" style="font-family: Arial;color:#333333;font-size:18px;vertical-align: middle;line-height: 24px;letter-spacing: 0.28px;font-weight: bold;padding: 30px 0 8px 0;">Dear ';
        emailBody += contactName + '</td>';
        emailBody += '</tr><tr>';
        emailBody += '<td align="left" valign="top" style="font-family: Arial;color:#333333;font-size:16px;vertical-align: middle;line-height: 26px;letter-spacing: 0.32px;padding: 0;">Unfortunately, we could not verify your documents. Please check the below table with rejected document along with reason.</td>';
        emailBody += '</tr>';
        return emailBody;
    }
    public static string addTableInMail(List<Merchant_Document__c> merchantDocs) {
        String emailBody='';
        emailBody += '<table width="100%" border="1px black solid" cellspacing="0" cellpadding="0">';
        emailBody += '<tbody>';
        emailBody += '<tr>';
        emailBody += '<th style="padding: 5px; vertical-align: top;font-family: Arial">Document Name</th>';
        emailBody += '<th style="padding: 5px; vertical-align: top;font-family: Arial">Rejection Reason</td></th>';
        for (Merchant_Document__c doc : merchantDocs) {
            // adding merchant category and remarks to be sent in mail to merchant
             emailBody += '<tr><td style="padding: 5px">' + doc.Document_Category__r.Name + '</td><td style="padding: 5px">' ;
            if(doc.Error__c!=null && doc.Error__c.length()>0){
                String docError = doc.Error__c.removeEnd(';');
             	emailBody += docError;
            }
            else emailBody += ' ';
            emailBody +=  '</td></tr>';
        }
        emailBody += '<table><tr><td align="left" valign="top" style="font-family: Arial;color:#333333;font-size:16px;vertical-align: middle;line-height: 26px;letter-spacing: 0.32px;padding: 0 0 0px 0;">';
        emailBody += '<br>Please login to Dashboard using below button to see more details & upload the corrected documents.</td></tr><table>';
        emailBody += '<table width="128" border="0" cellspacing="0" cellpadding="0" align="left" style="background: #18af8b; border:#18af8b solid 1px;height: 38px;border-radius: 2px;padding:11px 0 0px 0">';
        emailBody += '<tbody><tr><td valign="top" width="128" style="text-align: center;color:#ffffff">';
        emailBody += '<a href="https://www.payu.in/" target="_blank" style="font-family: Arial; align:center; font-size:14px; color:#ffffff; line-height: normal;font-weight: normal;display: block; text-decoration: none;text-align: center; letter-spacing: 0.56px;text-align: center">Go to Dashboard </a></td>';
        emailBody += '<br><br></tr></tbody></table>';
        emailBody += '<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" style="padding: 20px 0 20px 0;">';
        emailBody += '<tbody><tr>';
        emailBody += '<td valign="top" style="font-family: Arial;color:#616069;font-size:13px;vertical-align: middle;line-height: 18px;padding: 0 0 16px 0;">';
        emailBody += 'For any queries, please connect with us at <a href="https://help.payu.in/" style="color:#18af8b;text-decoration:none;">help.payu.in</a></td>';
        emailBody += '</tr><tr>';
        emailBody += '<td align="center" valign="top" style="font-family: Arial;color:#616069;font-size:12px;vertical-align: middle;line-height: 16px;padding: 0 0 16px 0;font-style: italic;">Since this is an automated email, replying to this will not connect you with us.</td>';
        emailBody += '</tr></tbody></table>';
        emailBody += '</tbody></table></td></tr></tbody></table></td></tr></tbody></table></body></html>';
        return emailBody;
    }
    /********* Function to get contact details and merchant documents related to each opportunity ***********/
    public static void getMerchantDocListAndContactDetails(List<Merchant_Document__c> allMerchantDocsRejected,Map<Id, List<Merchant_Document__c>> merchantDocsMap,
                                                           Map<Id,Id> accountIdsMap,Map<Id,Id> conToOppId,Map<Id,Opportunity> opportunityMap,Map<Id,String> conToNameMap) {
        for (Merchant_Document__c doc : allMerchantDocsRejected) {
            if (!merchantDocsMap.containsKey(doc.Opportunity__c)) {
                merchantDocsMap.put(doc.Opportunity__c, new List<Merchant_Document__c>());
            }
            merchantDocsMap.get(doc.Opportunity__c).add(doc);
        }
        if(!opportunityMap.isEmpty()){
            for(Id oppId : opportunityMap.keySet()){
                accountIdsMap.put(opportunityMap.get(oppId).accountId,oppId);            
            }
        }                                              
        for(Contact con : [SELECT Id,Name,Email,AccountId FROM Contact 
                           WHERE AccountId IN :accountIdsMap.keySet() 
                           AND Active__c = true 
                           AND Authorised_Signatory__c = true 
                           AND Email != NULL]){
                               conToOppId.put(con.Id,accountIdsMap.get(con.AccountId));
                               if(con.Name!=null && con.Name.length()>0)
                               	conToNameMap.put(con.Id,con.Name);
                               else 
                                conToNameMap.put(con.Id,'Merchant');
                           }                                                                                                                     
    }
    public static void setMailParametersAndSend(Messaging.SingleEmailMessage mail,String emailContent,Id conId,Map<Id,Id>conToOppId) {
        mail.setTargetObjectId(conId);  
        mail.setOrgWideEmailAddressId(orgAddressList[0].Id);
        mail.setSaveAsActivity(true);
        mail.setHTMLBody(emailContent);
        mail.setWhatId(conToOppId.get(conId));
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
    /***** Method to send 1 mail to merchant such that if any onboarding doc is declined ******/
    /***** send all docs related to onboarding (active flag = true) which are declined in that mail ******/
    public static void sendMailToMerchantOnDocRejectOnboarding(Map<Id,Opportunity> opportunityMap){
        List<Merchant_Document__c> allMerchantDocsRejected = [SELECT Id, Document_Category__r.Name,Error__c, Onboarding_Status__c,Opportunity__c 
                                              FROM Merchant_Document__c 
                                              WHERE (Opportunity__c IN :opportunityMap.keySet() AND Onboarding_Status__c = 'Declined' AND Active__c = true AND reKYC_Doc__c = false)];
        Map<Id, List<Merchant_Document__c>> merchantDocsMap = new Map<Id, List<Merchant_Document__c>>();
        Map<Id,Id> accountIdsMap = new Map<Id,Id>();
        Map<Id,Id> conToOppId = new Map<Id,Id>();
        Map<Id,String> conToNameMap = new Map<Id,String>();
        getMerchantDocListAndContactDetails(allMerchantDocsRejected,merchantDocsMap,accountIdsMap,conToOppId,opportunityMap,conToNameMap);
          for(Id conId : conToOppId.keySet()){
          	Opportunity opportunity = opportunityMap.get(conToOppId.get(conId));
            List<Merchant_Document__c> merchantDocs = merchantDocsMap.get(conToOppId.get(conId));
            if (merchantDocs != null && !merchantDocs.isEmpty() ) {
                String emailContent = '';
                String emailSubject = SUBJECT_FOR_ONBOARDING_DOCS_ERROR+opportunity.Prod_MID__c;
                String contactName = conToNameMap.get(conId);
                emailContent += addBodyInMail(contactName);
                emailContent += addTableInMail(merchantDocs);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(emailSubject);
                setMailParametersAndSend(mail,emailContent,conId,conToOppId);
            }
        }
    }
    /***** Method to send 1 mail to merchant such that if any ReKYC doc is declined ******/
    /***** send all docs related to ReKYC(rekyc flag=true) which are declined in that mail ******/
    public static void sendMailToMerchantOnDocRejectReKYC(Map<Id,Opportunity> opportunityMap){
        List<Merchant_Document__c> allMerchantDocsRejected = [SELECT Id, Document_Category__r.Name, Error__c, Onboarding_Status__c,Opportunity__c 
                                              FROM Merchant_Document__c 
                                              WHERE (Opportunity__c IN :opportunityMap.keySet() AND Onboarding_Status__c = 'Declined' AND reKYC_Doc__c = true)];
        Map<Id, List<Merchant_Document__c>> merchantDocsMap = new Map<Id, List<Merchant_Document__c>>();
        Map<Id,Id> accountIdsMap = new Map<Id,Id>();
        Map<Id,Id> conToOppId = new Map<Id,Id>();
        Map<Id,String> conToNameMap = new Map<Id,String>();
        getMerchantDocListAndContactDetails(allMerchantDocsRejected,merchantDocsMap,accountIdsMap,conToOppId,opportunityMap,conToNameMap);
          for(Id conId : conToOppId.keySet()){
            Opportunity opportunity = opportunityMap.get(conToOppId.get(conId));
            List<Merchant_Document__c> merchantDocs = merchantDocsMap.get(conToOppId.get(conId));
            if (merchantDocs != null && !merchantDocs.isEmpty()) {
                String emailContent = '';
                String emailSubject = SUBJECT_FOR_REKYC_DOCS_ERROR+opportunity.Prod_MID__c;
                String contactName = conToNameMap.get(conId);
                emailContent += addBodyInMail(contactName);
                emailContent += addTableInMail(merchantDocs);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(emailSubject);
                setMailParametersAndSend(mail,emailContent,conId,conToOppId);
            }
        }
    }
    /***** Method to send 1 mail to merchant such that if any dormancy related doc is declined ******/
    /***** send all docs related to dormancy(is_merchant_dormant__c=true & rekyc flag=true) which are declined in that mail ******/
    public static void sendMailToMerchantOnDocRejectDormancy(Map<Id,Opportunity> opportunityMap){
        List<Merchant_Document__c> allMerchantDocsRejected = [SELECT Id, Document_Category__r.Name, Error__c, Onboarding_Status__c,Opportunity__c 
                                              FROM Merchant_Document__c 
                                              WHERE (Opportunity__c IN :opportunityMap.keySet() AND Onboarding_Status__c = 'Declined' AND reKYC_Doc__c = true)];
        Map<Id, List<Merchant_Document__c>> merchantDocsMap = new Map<Id, List<Merchant_Document__c>>();
        Map<Id,Id> conToOppId = new Map<Id,Id>();
        Map<Id,Id> accountIdsMap = new Map<Id,Id>();
        Map<Id,String> conToNameMap = new Map<Id,String>();
        getMerchantDocListAndContactDetails(allMerchantDocsRejected,merchantDocsMap,accountIdsMap,conToOppId,opportunityMap,conToNameMap);
          for(Id conId : conToOppId.keySet()){
            Opportunity opportunity = opportunityMap.get(conToOppId.get(conId));
            List<Merchant_Document__c> merchantDocs = merchantDocsMap.get(conToOppId.get(conId));
            if (merchantDocs != null && !merchantDocs.isEmpty()) {
                String emailContent = '<html><body>';
                String emailSubject = SUBJECT_FOR_DORMANT_DOCS_ERROR+opportunity.Prod_MID__c;
                emailContent += addBodyInMail(conToNameMap.get(conId));
                emailContent += addTableInMail(merchantDocs);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(emailSubject);
                setMailParametersAndSend(mail,emailContent,conId,conToOppId);
            }
        }
    }
    // ******************(SFI-1179 END) By Saksham ********************
    public static void beforeInsertHandler(List<Merchant_Status_Details__c> triggerNew){
        Enable_UUID_Objects__c enableUUIDObj = Enable_UUID_Objects__c.getValues('Merchant_Status_Details__c');
        
        for(Merchant_Status_Details__c each : triggerNew){
            // call this method to get the identifier field value if not exist                    
            SystemUtility.getIdentifierUUID(each, 'Identifier__c', enableUUIDObj);
            
            if(String.isNotBlank(each.Status_Type__c)){
                each.RecordTypeId = SObjectType.Merchant_Status_Details__c.getRecordTypeInfosByDeveloperName().get(each.Status_Type__c).getRecordTypeId();
            }
            
            //=============== Mandate Lead/Opportunity Id before insert the data========
            if(String.isBlank(each.Lead__c) && String.isBlank(each.Opportunity__c)){
                each.addError('Lead or Opportunity Id is required.');
            }
        }
    }
    
    public static void beforeUpdateHandler(List<Merchant_Status_Details__c> triggerNew, Map<Id,Merchant_Status_Details__c> triggerOldMap){
        for(Merchant_Status_Details__c each : triggerNew){
            Merchant_Status_Details__c oldEach = triggerOldMap.get(each.Id);
            if(String.isNotBlank(each.Status_Type__c) && each.Status_Type__c != oldEach.Status_Type__c){
                each.RecordTypeId = SObjectType.Merchant_Status_Details__c.getRecordTypeInfosByDeveloperName().get(each.Status_Type__c).getRecordTypeId();
            }
            
            //=============== Mandate Lead/Opportunity Id before insert the data========
            if(String.isBlank(each.Lead__c) && String.isBlank(each.Opportunity__c)){
                each.addError('Lead or Opportunity Id is required.');
            }
        }
    }
    
    public static void afterInsertHandler(List<Merchant_Status_Details__c> triggerNew){
        Map<Id, Opportunity> opportunityDataMap = New Map<Id, Opportunity>();
        Map<String, String> statusTypeVsStatusValueMap = New Map<String, String>();
        for(Merchant_Status_Details__c each : triggerNew){
            if(!system.isBatch() && each.Data_need_to_be_publish__c && !publisherFlag){ 
                IntegrationUtility.sendPayLoadData(each, null, 'Merchant_Status_Details__c', 'Merchant_Status_Details__c');
            }
            if(String.isNotBlank(each.Opportunity__c) && String.isNotBlank(each.Status_Value__c) && String.isNotBlank(each.Status_type__c)){
                opportunityDataMap.put(each.Opportunity__c, null);
                statusTypeVsStatusValueMap.put(each.Opportunity__c+'##'+each.Status_Type__c, each.Status_Value__c);
            }
        }
        
        if(!opportunityDataMap.isEmpty()) getOpportunityData(opportunityDataMap);
        
        if(!opportunityDataMap.isEmpty() && opportunityDataMap.values().size() > 0 && !statusTypeVsStatusValueMap.isEmpty()) 
            updateParentObjStatus(triggerNew, opportunityDataMap, statusTypeVsStatusValueMap);
    }
    
    public static void afterUpdateHandler(List<Merchant_Status_Details__c> triggerNew, Map<Id,Merchant_Status_Details__c> triggerOldMap){
        Map<Id, Opportunity> opportunityDataMap = New Map<Id, Opportunity>();
        Map<String, String> statusTypeVsStatusValueMap = New Map<String, String>();
        // ************** SFI-1179 [start]**********************
        Set<Id> setOpportunityIdOnboarding = new Set<Id>();
        Set<Id> setOpportunityIdReKYC = new Set<Id>();
        Set<Id> setOpportunityIdDormancy = new Set<Id>();
        for(Merchant_Status_Details__c each : triggerNew){
            Merchant_Status_Details__c oldEach = triggerOldMap.get(each.Id);
            if(String.isNotBlank(each.Opportunity__c) && each.Status_Value__c == 'Docs Error' 
               && each.Status_Value__c != triggerOldMap.get(each.Id).Status_Value__c) {
                   if(each.Status_Type__c == 'KYC_DOCUMENTS' && !each.Is_Onboarding_Completed__c) {
                       setOpportunityIdOnboarding.add(each.Opportunity__c);
                   }
                   if(each.Status_Type__c == 'RE_KYC_DOCUMENTS' && !each.Is_Merchant_Dormant__c) {
                       setOpportunityIdReKYC.add(each.Opportunity__c);
                   }
                   if(each.Status_Type__c == 'RE_KYC_DOCUMENTS' && each.Is_Merchant_Dormant__c) {
                       setOpportunityIdDormancy.add(each.Opportunity__c);
                   }
            }
            // ************** SFI-1179 [end]**********************
            if(!system.isBatch() && each.Data_need_to_be_publish__c && !publisherFlag){
                IntegrationUtility.sendPayLoadData(each, oldEach, 'Merchant_Status_Details__c', 'Merchant_Status_Details__c'); 
            }
            if(String.isNotBlank(each.Opportunity__c) && String.isNotBlank(each.Status_Value__c) && String.isNotBlank(each.Status_type__c) && (each.Status_Value__c != oldEach.Status_Value__c || (each.Status_Value__c == 'Approved' || each.Status_Value__c == 'Docs Approved' || each.Status_Value__c == 'Website OK' ))){
                opportunityDataMap.put(each.Opportunity__c, null);
                statusTypeVsStatusValueMap.put(each.Opportunity__c+'##'+each.Status_Type__c, each.Status_Value__c);
            }
        }
        System.debug('########## statusTypeVsStatusValueMap '+statusTypeVsStatusValueMap);
        if(!opportunityDataMap.isEmpty()) getOpportunityData(opportunityDataMap);
        
        if(!opportunityDataMap.isEmpty() && opportunityDataMap.values().size() > 0 && !statusTypeVsStatusValueMap.isEmpty()) 
            updateParentObjStatus(triggerNew, opportunityDataMap, statusTypeVsStatusValueMap);
        // *********** SFI-1179 [start]*********
        if(setOpportunityIdOnboarding.size() > 0) {
            Map<Id,Opportunity> mapOpportunityIdToOpportunityOnboarding = new Map<Id,Opportunity>([SELECT Id,AccountId,Prod_MID__c FROM Opportunity WHERE Id IN :setOpportunityIdOnboarding AND AccountId != NULL]);
            if(!mapOpportunityIdToOpportunityOnboarding.isEmpty())
            	sendMailToMerchantOnDocRejectOnboarding(mapOpportunityIdToOpportunityOnboarding);
        }
        if(setOpportunityIdReKYC.size() > 0) {
            Map<Id,Opportunity> mapOpportunityIdToOpportunityReKYC = new Map<Id,Opportunity>([SELECT Id,AccountId,Prod_MID__c FROM Opportunity WHERE Id IN :setOpportunityIdReKYC AND AccountId != NULL]);
            if(!mapOpportunityIdToOpportunityReKYC.isEmpty())
            	sendMailToMerchantOnDocRejectReKYC(mapOpportunityIdToOpportunityReKYC);
        }
        if(setOpportunityIdDormancy.size() > 0) {
            Map<Id,Opportunity> mapOpportunityIdToOpportunityDormancy = new Map<Id,Opportunity>([SELECT Id,AccountId,Prod_MID__c FROM Opportunity WHERE Id IN :setOpportunityIdDormancy AND AccountId != NULL]);
            if(!mapOpportunityIdToOpportunityDormancy.isEmpty())
            	sendMailToMerchantOnDocRejectDormancy(mapOpportunityIdToOpportunityDormancy);
        }
        // *********** SFI-1179 [end]***********
    }
    
    public static void updateParentObjStatus(List<Merchant_Status_Details__c> triggerNew, Map<Id, Opportunity> opportunityDataMap, Map<String, String> statusTypeVsStatusValueMap){
        Map<Id,Opportunity> opportunityMap = New Map<Id,Opportunity>();
        for(Merchant_Status_Details__c each : triggerNew){
            if(String.isNotBlank(each.Opportunity__c)){
                if(opportunityDataMap.containsKey(each.Opportunity__c) && opportunityDataMap.get(each.Opportunity__c) != null){
                    Opportunity eachOpp = opportunityDataMap.get(each.Opportunity__c);
                    Boolean updateCheck = false;
                    String documentStatus = each.Opportunity__c+'##KYC_DOCUMENTS';
                    String agreementStatus = each.Opportunity__c+'##Agreement';
                    String websiteStatus = each.Opportunity__c+'##WEBSITE';
                    System.debug('########## statusTypeVsStatusValueMap22 '+statusTypeVsStatusValueMap);
                    if(statusTypeVsStatusValueMap.containsKey(documentStatus) && statusTypeVsStatusValueMap.get(documentStatus) != null){ 
                        eachOpp.Document_Status_Document_Issue__c = statusTypeVsStatusValueMap.get(documentStatus);
                        updateCheck = true;
                    }
                    if(statusTypeVsStatusValueMap.containsKey(agreementStatus) && statusTypeVsStatusValueMap.get(agreementStatus) != null){
                        if(statusTypeVsStatusValueMap.get(agreementStatus) == 'accepted') eachOpp.Agreement_Status__c = 'Approved';
                        else eachOpp.Agreement_Status__c = statusTypeVsStatusValueMap.get(agreementStatus);
                        updateCheck = true;
                    }
                    if(statusTypeVsStatusValueMap.containsKey(websiteStatus) && statusTypeVsStatusValueMap.get(websiteStatus) != null){
                        if(eachOpp.Website_Status__c != 'Website OK') eachOpp.Website_Status__c = statusTypeVsStatusValueMap.get(websiteStatus);
                        updateCheck = true;
                    }
                    if(updateCheck) opportunityMap.put(eachOpp.Id,eachOpp);
                }
            }
        }
        if(!opportunityMap.isEmpty() && opportunityMap.size() > 0) update opportunityMap.values();
    }
    
    public static void getOpportunityData(Map<Id, Opportunity> opportunityDataMap){
        opportunityDataMap.putAll([Select Id,Agreement_Status__c,Document_Status_Document_Issue__c,Website_Status__c From opportunity Where Id IN: opportunityDataMap.keySet()]);
    }
}