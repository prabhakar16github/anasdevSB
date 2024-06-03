/**
* @Name         SendAlertToMerchantAfter210DaysBatch 
* @Author       Prabhakar Joshi
* @Group        Risk
* @Description  This is a batch class to send the Alert to Merchant contact on 210th day from last transaction date.
*/

public class SendAlertToMerchantAfter210DaysBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    private String CSV_FILE_FOR_RISK_TEAM ='MID\n'; /** CSV File content for email for Risk Team. */
    private Boolean flagForRiskTeamAlert = FALSE; /** Flag for identify that we need to send the email to Risk Team or not */
    private FINAL String FROM_ADDRESS_FOR_Email = 'no_reply@payu.in'; /** From address for email notification */
    private FINAL String RISK_EMAIL = System.label.Risk_Team_Email_Address; /** Risk Team email Address */

    /** Only for testing in PROD to pass the Opportunity Ids for Merchants while calling Batch class. */
    /** Email testing was not working in dev env. */
    private Set<String> testOppIds = new Set<String>();
    /** */
    public SendAlertToMerchantAfter210DaysBatch(Set<String> testOppIds){
        this.testOppIds = testOppIds;
    }
    private List<EmailTemplate> emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName = 'Risk_Hold_Merchant_Notification_on_210th_day' 
                                                 LIMIT 1];
    
    private List<OrgWideEmailAddress> orgAddressList = [SELECT Id, Address, DisplayName, IsAllowAllProfiles 
                                                        FROM OrgWideEmailAddress 
                                                        WHERE Address = :FROM_ADDRESS_FOR_Email 
                                                        LIMIT 1];
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String RISK_HOLD_STATUS = 'Risk Hold';
        Integer ALERT_DAYS_FOR_MERCHANT = Integer.valueOf(System.label.Alert_Duration_For_Risk_Hold_Merchants); //  210;
        Integer ALERT_DAYS_FOR_RISK_TEAM = 270;
        String query = 'SELECT Id,Name,AccountId,Days_Since_Last_Transaction__c,Prod_MID__c  FROM Opportunity WHERE Settlement_Status__c = :RISK_HOLD_STATUS ';
        query += 'AND (Days_Since_Last_Transaction__c = :ALERT_DAYS_FOR_MERCHANT OR Days_Since_Last_Transaction__c = :ALERT_DAYS_FOR_RISK_TEAM) ';
        
        /** Only for testing purpose to pass the Opportunity Ids while calling Batch class. */
        if(!testOppIds.isEmpty()){
            query += 'AND Id In :testOppIds';
        }
        /** */
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppRecords){
        
        Map<Id,Id> accToOppIdMapForMerchantAlert = new Map<Id,Id>();
        for(Opportunity opp : oppRecords){
            if(opp.Days_Since_Last_Transaction__c == 210){
                accToOppIdMapForMerchantAlert.put(opp.AccountId,opp.Id);
            }else if(opp.Days_Since_Last_Transaction__c == 270){
                CSV_FILE_FOR_RISK_TEAM += opp.Prod_MID__c + '\n';
                flagForRiskTeamAlert = TRUE;
            }
        }
        
        if(!accToOppIdMapForMerchantAlert.keySet().isEmpty()){
            this.sendEmailToMerchant(accToOppIdMapForMerchantAlert);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(flagForRiskTeamAlert){
            this.sendEmailToRiskTeam();
        }
    }
    
    /**
     * Private method to send the email to active 'Authorized Signatory' associated with Merchant.
     * @param - Map of Account Id & Opportunity Id to get the Authorized Signatory.
     */
    private void sendEmailToMerchant(Map<Id,Id> accToOppIdMapForMerchantAlert){
        Map<Id,Id> conToOppId = new Map<Id,Id>();
        
        for(Contact con : [SELECT Id,Name,Email,AccountId FROM Contact 
                           WHERE AccountId IN :accToOppIdMapForMerchantAlert.keySet() 
                           AND Active__c = true 
                           AND Authorised_Signatory__c = true 
                           AND Email != NULL]){
                               conToOppId.put(con.Id,accToOppIdMapForMerchantAlert.get(con.AccountId));
                           }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Id conId : conToOppId.keySet()){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(orgAddressList[0].Id); 
            email.setTargetObjectId(conId); 
            email.setSaveAsActivity(false); 
            email.setTemplateID(emailTemplate[0].Id);
            email.setWhatid(conToOppId.get(conId));
            mails.add(email);
        }
        
        if(!test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
        
    }
    
    /**
     * Private method to send the email to Risk Team for the Risk Hold Merchant list reached 270 days from last transaction Date.
     */
    private void sendEmailToRiskTeam(){ //Set<Id> oppIdsForRiskTeamEmail
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        /** For CSV attachment with list of MIDs. */
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(CSV_FILE_FOR_RISK_TEAM);
        csvAttachment.setFileName('RiskHoldMerchants.csv');
        csvAttachment.setBody(csvBlob);
        csvAttachment.setContentType('text/csv');
        /** */
        
        email.setToAddresses(new List<String>{RISK_EMAIL}); //risk@payu.in
        email.setSubject('Reminder - Settlement is On Hold for Merchants ');
        email.setHtmlBody('<p>Dear Risk Team,</p><p>Following risk hold merchants have passed 270 days from last transaction date.</p><p>Please find the attached csv.</p><br/><p>Thanks</p>');
        email.setOrgWideEmailAddressId(orgAddressList[0].Id); 
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        mails.add(email);
        if(!test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
    }
}