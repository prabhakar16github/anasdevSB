/**
* @Name         DormancyAndReKYCReminder 
* @Author       Saksham Rohilla
* @Description  This is a batch class to send the Alert to Merchant contact if either condition is satisfied:
				1. 30/60/90 days left for Dormancy (Dormancy_Date__c)
				2. 30/60/90 days left for ReKYC (Next_ReKYC_Date__c)
				3. ReKYC Overdue (Current Date = Next_ReKYC_Date__c+1)
* @Schedulers.  SchedulerForReKYCOverdueReminder, SchedulerForReKYCReminder and SchedulerForDormancyReminder
*/
public class DormancyAndReKYCReminder implements Database.Batchable<sObject>,Database.Stateful {
    private String mailTemplateName;
    private List<EmailTemplate> emailTemplate;
    private String REKYC_REMINDER = System.Label.ReKYC_In_N_Days;
    private String REKYC_OVERDUE = System.Label.ReKYC_Overdue_Mail;
    private String DORMANCY_REMINDER = System.Label.Dormancy_in_N_days_Mail;
    private String BFL_UUID = System.Label.BFL_Aggregator_UUID;
    private static String FROM_ADDRESS_FOR_Email = 'no_reply@payu.in';
    private Date currDatePlus30Days = System.Today().addDays(30);
    private Date currDatePlus60Days = System.Today().addDays(60);
    private Date currDatePlus90Days = System.Today().addDays(90);
    private Date currDateMinus1Day = System.Today().addDays(-1);
    List<Date> dateList = new List<Date>{currDatePlus30Days,currDatePlus60Days,currDatePlus90Days};
    public DormancyAndReKYCReminder(String mailType){
        if(mailType == 'REKYC_REMINDER'){
            this.mailTemplateName = REKYC_REMINDER;
        }
        else if(mailType == 'REKYC_OVERDUE'){
            this.mailTemplateName = REKYC_OVERDUE;
        }
        else if(mailType == 'DORMANCY_REMINDER'){
            this.mailTemplateName = DORMANCY_REMINDER;
        }
        else this.mailTemplateName = null;
        this.emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName = :mailTemplateName
                                                 LIMIT 1];
    }
    private static List<OrgWideEmailAddress> orgAddressList = [SELECT Id, Address, DisplayName, IsAllowAllProfiles 
                                                        FROM OrgWideEmailAddress 
                                                        WHERE Address = :FROM_ADDRESS_FOR_Email 
                                                        LIMIT 1];
	public Database.QueryLocator start(Database.BatchableContext info){
        if(mailTemplateName == REKYC_REMINDER){
            return Database.getQueryLocator('SELECT Id,AccountId FROM Opportunity WHERE Next_ReKYC_Date__c IN :dateList AND Aggregator_UUID__c != :BFL_UUID');
        }
        else if(mailTemplateName == DORMANCY_REMINDER){
            return Database.getQueryLocator('SELECT Id,AccountId FROM Opportunity WHERE Dormancy_Date__c IN :dateList AND Aggregator_UUID__c != :BFL_UUID');
        }
        else if(mailTemplateName == REKYC_OVERDUE){
            return Database.getQueryLocator('SELECT Id,AccountId FROM Opportunity WHERE Next_ReKYC_Date__c = :currDateMinus1Day AND Aggregator_UUID__c != :BFL_UUID');
        }
        else return NULL;
   } 
   public void execute(Database.BatchableContext BC, List<Opportunity> oppRecords){
        Map<Id,Id> accToOppIdMap= new Map<Id,Id>();
                for(Opportunity opp : oppRecords){
                    if(opp.AccountId != null){
                        accToOppIdMap.put(opp.AccountId,opp.Id);
                    }
                }  
       if(!accToOppIdMap.keySet().isEmpty()){
            this.sendEmailToMerchant(accToOppIdMap);
        }
   }
    public void finish(Database.BatchableContext BC){
        
    }
    private void sendEmailToMerchant(Map<Id,Id> accToOppIdMap){
        Map<Id,Id> conToOppId = new Map<Id,Id>();
        for(Contact con : [SELECT Id,Name,Email,AccountId FROM Contact 
                           WHERE AccountId IN :accToOppIdMap.keySet() 
                           AND Active__c = true 
                           AND Authorised_Signatory__c = true 
                           AND Email != NULL]){
                               conToOppId.put(con.Id,accToOppIdMap.get(con.AccountId));
                           }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Id conId : conToOppId.keySet()){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(orgAddressList[0].Id); 
            email.setTargetObjectId(conId); 
            email.setSaveAsActivity(true); 
            email.setTemplateID(emailTemplate[0].Id);
            email.setWhatid(conToOppId.get(conId));
            mails.add(email);
        }
        if(!test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
    }
}