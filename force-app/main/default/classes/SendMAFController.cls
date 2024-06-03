public class SendMAFController {
    // ============ Used for "SendMAFCmp" Component ==================
    @AuraEnabled
    public static String sendMAFforOpp(Id recordId){
        String msg = '';
        
        try{
            if(String.isNotBlank(recordId)){
                Opportunity opportunityObj = [SELECT Id, First_Name__c, Last_Name__c, Email__c, AccountId, MAF_Status__c, Sub_Source__c, Product__c, 
                                              Product__r.MAF_Enable__c, Product__r.MAF_Template_Name__c, Owner.Name, Owner.Email, Account.Owner.Email
                                              FROM Opportunity 
                                              WHERE Id =: recordId
                                              LIMIT 1];
                if(!opportunityObj.Product__r.MAF_Enable__c){
                    return 'MAF_Not_Enable';
                }
                
                if(opportunityObj.Product__r.MAF_Template_Name__c == null){
                    return 'MAF_Template_Name_Blank';
                }
                
                if(opportunityObj.Email__c == null){
                    return 'No_Email';
                }
                
                if(opportunityObj.First_Name__c == null || opportunityObj.Last_Name__c == null){
                    return 'No_Name';
                }
                
                // ============ get the "Biz_Introduction_Template_With_MAF" email templates ==========
                List<EmailTemplate> listEmailTemplateObj = DatabaseUtility.getEmailTemplate(opportunityObj.Product__r.MAF_Template_Name__c);
                
                if(listEmailTemplateObj == null || listEmailTemplateObj.size() <= 0){
                    return 'No_Template';
                }
                
                // ============ get the list of attachment under the "Biz_Introduction_Template_With_MAF" email templates ==========
                list<Attachment> listAttachment = DatabaseUtility.getListAttachment(listEmailTemplateObj[0].Id);
                
                // ============ Sending Email ===========
                String optyName = opportunityObj.First_Name__c + ' ' + opportunityObj.Last_Name__c;
                List<Messaging.SendEmailResult> listSendEmailResult = SystemUtility.sendEmailWithUpdateBody(optyName, opportunityObj.Email__c, listEmailTemplateObj[0], listAttachment, opportunityObj.Owner.Name, opportunityObj.Owner.Email, opportunityObj.Account.Owner.Email, null, false);
                
                if(listSendEmailResult != null && !listSendEmailResult.isEmpty()){
                    
                    // ============= If email sent successfully than update the MAF_Status__c field on Opp otherwise send the error message ===================
                    if(listSendEmailResult[0].isSuccess())
                    {
                        Opportunity oppObj = new Opportunity(Id = recordId, MAF_Status__c = 'Sent');
                        update oppObj;
                        return 'MAF_Sent';
                    }
                    else
                    {
                        list<Messaging.SendEmailError> listSendEmailError = listSendEmailResult[0].getErrors();
                        return 'ERROR: '+listSendEmailError;
                        //return 'Status Code : '+ listSendEmailError[0].getStatusCode() +' and Error : '+ listSendEmailError[0].getMessage();
                    }
                }                     
            }
            return null;
        }
        
        catch(DmlException e){
            
            for (Integer i = 0; i < e.getNumDml(); i++) {
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string sendMAFforLead(Id recordId){
        String msg = '';
        
        try{
            if(String.isNotBlank(recordId)){
                Lead leadObj = [SELECT Id, Email, Name, LastName, MAF_Status__c, Product__c, Product__r.MAF_Enable__c,
                                Product__r.MAF_Template_Name__c, Owner.Name, Owner.Email
                                FROM Lead 
                                WHERE Id =: recordId
                                LIMIT 1];
                
                if(!leadObj.Product__r.MAF_Enable__c){
                    return 'MAF_Not_Enable';
                }
                
                if(leadObj.Product__r.MAF_Template_Name__c == null){
                    return 'MAF_Template_Name_Blank';
                }
                
                if(leadObj.Email == null){
                    return 'No_Email';
                }
                
                // ============ get the "Biz_Introduction_Template_With_MAF" email templates ==========
                List<EmailTemplate> listEmailTemplateObj = DatabaseUtility.getEmailTemplate(leadObj.Product__r.MAF_Template_Name__c);
                
                if(listEmailTemplateObj == null || listEmailTemplateObj.size() <= 0){
                    return 'No_Template';
                }
                
                // ============ get the list of attachment under the "Biz_Introduction_Template_With_MAF" email templates ==========
                list<Attachment> listAttachment = DatabaseUtility.getListAttachment(listEmailTemplateObj[0].Id);
                
                // ============ Sending Email ===========
                List<Messaging.SendEmailResult> listSendEmailResult = SystemUtility.sendEmailWithUpdateBody(leadObj.Name, leadObj.Email, listEmailTemplateObj[0], listAttachment, leadObj.Owner.Name, leadObj.Owner.Email, leadObj.Owner.Email, null, false);
                
                if(listSendEmailResult != null && !listSendEmailResult.isEmpty()) {
                    // ============= If email sent successfully than update the MAF_Status__c field on Lead otherwise send the error message ===================
                    if(listSendEmailResult[0].isSuccess()){
                        Lead leadSoB = new Lead(Id = recordId, MAF_Status__c = 'Sent');
                        update leadSoB;
                        return 'MAF_Sent';
                    }else{
                        list<Messaging.SendEmailError> listSendEmailError = listSendEmailResult[0].getErrors();
                        return 'ERROR: '+listSendEmailError;
                    }
                }                     
            }
            return null;
        }
        
        catch(DmlException e){
            
            for (Integer i = 0; i < e.getNumDml(); i++) {
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}