/**
* @Name         VKYCReminderTodayBatch 
* @Author       Saksham Rohilla
* @Description  This is a batch class to send the Alert to Merchant contact if:
				Start At Date (Video KYC Object) = Toady
*/
public class VKYCReminderTodayBatch implements Database.Batchable<sObject>,Database.Stateful{
    private static String FROM_ADDRESS_FOR_Email = 'no_reply@payu.in';
    private String BFL_UUID = System.Label.BFL_Aggregator_UUID;
    private List<EmailTemplate> emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                                 FROM EmailTemplate 
                                                 WHERE DeveloperName = 'VKYC_Reminder_For_Today' 
                                                 LIMIT 1];
    private static List<OrgWideEmailAddress> orgAddressList = [SELECT Id, Address, DisplayName, IsAllowAllProfiles 
                                                        FROM OrgWideEmailAddress 
                                                        WHERE Address = :FROM_ADDRESS_FOR_Email 
                                                        LIMIT 1];
	public Database.QueryLocator start(Database.BatchableContext info){
        String Approved = 'Approved';
        return Database.getQueryLocator('SELECT Id,Opportunity__c,Start_At__c,Status__c,Opportunity__r.AccountId,Opportunity__r.Aggregator_UUID__c FROM Video_KYC__c WHERE DAY_ONLY(Start_At__c) = TODAY AND Status__c != :Approved AND Opportunity__r.Aggregator_UUID__c != :BFL_UUID');
    }
    public void execute(Database.BatchableContext BC, List<Video_KYC__c> recs){
        Map<Id,Id> accToVKYCIdMap= new Map<Id,Id>();
                for(Video_KYC__c rec : recs){
                    if(rec.Opportunity__r.AccountId != null){
                        accToVKYCIdMap.put(rec.Opportunity__r.AccountId,rec.Id);
                    }
                }  
       if(!accToVKYCIdMap.keySet().isEmpty()){
            this.sendEmailToMerchant(accToVKYCIdMap);
        }
    }
    public void finish(Database.BatchableContext BC){
        
    }
    private void sendEmailToMerchant(Map<Id,Id> accToVKYCIdMap){
        Map<Id,Id> conToVKYCId = new Map<Id,Id>();
        for(Contact con : [SELECT Id,Name,Email,AccountId FROM Contact 
                           WHERE AccountId IN :accToVKYCIdMap.keySet() 
                           AND Active__c = true 
                           AND Authorised_Signatory__c = true 
                           AND Email != NULL]){
                               conToVKYCId.put(con.Id,accToVKYCIdMap.get(con.AccountId));
                           }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Id conId : conToVKYCId.keySet()){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(orgAddressList[0].Id); 
            email.setTargetObjectId(conId); 
            email.setSaveAsActivity(true); 
            email.setTemplateID(emailTemplate[0].Id);
            email.setWhatid(conToVKYCId.get(conId));
            mails.add(email);
        }
        if(!test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
    }
}