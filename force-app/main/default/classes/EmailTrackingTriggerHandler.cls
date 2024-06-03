public class EmailTrackingTriggerHandler {
    public static List<OrgWideEmailAddress> orgWideIdList = [SELECT Id,DisplayName,Address 
                                                             FROM OrgWideEmailAddress 
                                                             WHERE Address = 'no_reply@payu.in' 
                                                             LIMIT 1];
    
    
    public static void beforeInsertHandler(List<Email_Status_Tracking__c> triggerNew){}
    
    public static void afterInsertHandler(List<Email_Status_Tracking__c> triggerNew){
        processTriggerNew(triggerNew);
    }
    
    /** Added for EmailTracker send email issue. */
    public static void processTriggerNew(List<Email_Status_Tracking__c> triggerNew){
        Map<Id,Email_Status_Tracking__c> oppIdToEmailTrackerMap = new Map<Id,Email_Status_Tracking__c>();
        
        Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
        
        for(Email_Status_Tracking__c estObj : triggerNew){
            if(validateNewRecord(estObj) && String.isNotBlank(estObj.Template_Name__c)){
                emailTemplateMap.put(estObj.Template_Name__c,NULL);
                
                Id recordId = String.isNotBlank(estObj.Opportunity__c) ? estObj.Opportunity__c : String.isNotBlank(estObj.Case__c) ? estObj.Case__c : estObj.Contact__c; 
                oppIdToEmailTrackerMap.put(recordId,estObj);
            }
        }
        
        if(emailTemplateMap.keySet().isEmpty()){
            return;
        }
        
        for(EmailTemplate eachTemplate : [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                          FROM EmailTemplate 
                                          WHERE DeveloperName In :emailTemplateMap.keySet()]){
                                              emailTemplateMap.put(eachTemplate.DeveloperName,eachTemplate);
                                          }
        
        if(oppIdToEmailTrackerMap.keySet().isEmpty()){
            return;
        }
        
        sendEmailToMerchant(oppIdToEmailTrackerMap,emailTemplateMap);
    }
    
    /** private method to send the email to merchants */
    private static void sendEmailToMerchant(Map<Id,Email_Status_Tracking__c> oppIdToEmailTrackerMap,Map<String,EmailTemplate> emailTemplateMap){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Id whatId : oppIdToEmailTrackerMap.keySet()){
            Email_Status_Tracking__c tempObj = oppIdToEmailTrackerMap.get(whatId);
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
            
            /** setting to-address */
            if(String.isBlank(tempObj.To_Addresses__c)){
                return;
            }
            
            if(tempObj.To_Addresses__c.contains(';')){
                singleEmailMsg.setToAddresses(new List<String>(tempObj.To_Addresses__c.split(';')));
            }else{
                singleEmailMsg.setToAddresses(new List<String>{tempObj.To_Addresses__c});
            }
            
            /** setting cc-address */
            if(String.isNotBlank(tempObj.CC_Addresses__c)) {
                if(tempObj.CC_Addresses__c.contains(';')){
                    singleEmailMsg.setCcAddresses(new List<String>(tempObj.CC_Addresses__c.split(';')));
                }else{
                    singleEmailMsg.setCcAddresses(new List<String>{tempObj.CC_Addresses__c});
                }
            }
            
            EmailTemplate emailTemp = emailTemplateMap.get(tempObj.Template_Name__c);
            if(emailTemp == NULL){
                return;
            }
            //singleEmailMsg.setTreatTargetObjectAsRecipient(false);
            singleEmailMsg.setWhatid(whatId);
            singleEmailMsg.setHtmlBody(emailTemp.HtmlValue);
            singleEmailMsg.setSubject(emailTemp.Subject);
            singleEmailMsg.setTreatBodiesAsTemplate(true);
            
            if(!orgWideIdList.isEmpty()){
                singleEmailMsg.setOrgWideEmailAddressId(orgWideIdList[0].Id);
            }
            
            mails.add(singleEmailMsg);
        }
        if(!test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
    }/** END */
    
    /** private method to validate new record */
    private static Boolean validateNewRecord(Email_Status_Tracking__c estObj){
        if(String.isNotBlank(estObj.Template_Name__c) && String.isNotBlank(estObj.To_Addresses__c) && 
           (String.isNotBlank(estObj.Opportunity__c) || String.isNotBlank(estObj.Contact__c) || String.isNotBlank(estObj.Case__c))){
               return true;
           }
        return false;
    }/** END */
    
    
    /** old logic - commented to resolve the emailTracking issue - Merchant was getting other merchant's email*/
    /** It was working for single record but not for bulk. */
    /*
    public static void processTriggerNewOld(List<Email_Status_Tracking__c> triggerNew){
        Map<String,EmailTemplate> emailTemplateMap = New Map<String,EmailTemplate>();
        Id orgEmailId = [SELECT DisplayName, Id, IsAllowAllProfiles FROM OrgWideEmailAddress LIMIT 1].Id;
        Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
        try{
            for(Email_Status_Tracking__c estObj : triggerNew){
                if(String.isNotBlank(estObj.Template_Name__c)){
                    //system.debug('template name =='+estObj.Template_Name__c+'&&&');
                    emailTemplateMap.put(estObj.Template_Name__c,null);
                }
            }
            
            if(!emailTemplateMap.isEmpty()){
                for(EmailTemplate eachTemplate : [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from 
                                                  EmailTemplate where DeveloperName IN: emailTemplateMap.keySet()]){
                                                      emailTemplateMap.put(eachTemplate.DeveloperName,eachTemplate);
                                                  }
                
                
                for(Email_Status_Tracking__c estObj : triggerNew){
                    if(String.isNotBlank(estObj.Template_Name__c) && String.isNotBlank(estObj.To_Addresses__c) && 
                       (String.isNotBlank(estObj.Opportunity__c) || String.isNotBlank(estObj.Contact__c) || String.isNotBlank(estObj.Case__c))){
                           Id recordId = String.isNotBlank(estObj.Opportunity__c) ? estObj.Opportunity__c : String.isNotBlank(estObj.Case__c) ? estObj.Case__c : estObj.Contact__c; 
                           System.debug('>>>>>>>recordId>>>>>>>'+recordId);
                           System.debug('>>>>>>>estObj.To_Addresses__c>>>>>>>'+estObj.To_Addresses__c);
                           singleEmailMsg = sendEmailCommonMethod(recordId,estObj.Id,estObj.CC_Addresses__c,estObj.To_Addresses__c,emailTemplateMap.get(estObj.Template_Name__c),orgEmailId);
                       }
                }
                
                if(singleEmailMsg != null && !singleEmailMsg.toaddresses.isEmpty()){
                    System.debug('>>>>>>>>>>singleEmailMsg>>>>>>>>>>'+JSON.serialize(singleEmailMsg));
                    List<Messaging.SendEmailResult> listSendEmailResult = Messaging.sendEmail(new Messaging.Singleemailmessage[] { singleEmailMsg });
                    //system.debug(listSendEmailResult.size()+' :::::::: listSendEmailResult ::::::::'+listSendEmailResult);
                }
            }
        }catch(Exception ex){
            Error_Details__c errorObj = oneCareProcessHandler.getExceptions(ex, 'Bank Detail - Email Status Tracking Failed'); 
            Insert errorObj;
        }
    }
    
    public static Messaging.SingleEmailMessage sendEmailCommonMethod(Id recordId, string emailTrackId, String ccEmails, String recipients, EmailTemplate emailTemplateObj,Id orgEmailId){
        
        Map<String,String> templateBodyMap = new Map<String,String>();
        List<String> recepientList = New List<String>{recipients};
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
        if(recepientList.size() >0 && !recepientList.isEmpty()){
            singleEmailMsg.setToAddresses(new list<string>{recipients});
            singleEmailMsg.setWhatId(recordId);
            system.debug('emailTemplateObj=='+emailTemplateObj);
            if(String.isNotBlank(ccEmails)) singleEmailMsg.setCcAddresses(New List<String>{ccEmails});
            
            if(emailTemplateObj != null){
                if(emailTemplateObj.HtmlValue != null) {
                    //system.debug('emailTemplateObj.HtmlValue=='+emailTemplateObj.HtmlValue);
                    templateBodyMap = EmailTrackingHelper.getPopulatedMergeFields(emailTemplateObj.HtmlValue, recordId,emailTrackId);
                    emailTemplateObj.HtmlValue = templateBodyMap.get(recordId);
                    singleEmailMsg.setHtmlBody(emailTemplateObj.HtmlValue);
                }
                if(emailTemplateObj.Body != null) {
                    templateBodyMap = EmailTrackingHelper.getPopulatedMergeFields(emailTemplateObj.Body, recordId,emailTrackId);
                    emailTemplateObj.Body = templateBodyMap.get(recordId);
                    singleEmailMsg.setPlainTextBody(emailTemplateObj.Body);
                }
                
                if(emailTemplateObj.Subject != null) {
                    templateBodyMap = EmailTrackingHelper.getPopulatedMergeFields(emailTemplateObj.Subject, recordId,emailTrackId);
                    emailTemplateObj.Subject = templateBodyMap.get(recordId);
                }
                System.debug('>>>>>>>>>templateBodyMap>>>>>>>>>'+templateBodyMap);
                System.debug('>>>>>>>>>emailTemplateObj.Subject>>>>>>>>>'+emailTemplateObj.Subject);
                
                singleEmailMsg.setTemplateId(emailTemplateObj.Id);
                singleEmailMsg.setSubject(emailTemplateObj.Subject);
            }
            if(String.isNotBlank(orgEmailId)) singleEmailMsg.setOrgWideEmailAddressId(orgEmailId);
        }
        return singleEmailMsg;
    }
    */
}