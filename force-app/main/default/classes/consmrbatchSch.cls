global class consmrbatchSch implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        
        for(Batch_Setting__mdt cmdt : [SELECT DeveloperName, MasterLabel, Email_Recipients__c 
            from Batch_Setting__mdt
            where Re_Run_Apex_Job__c = true]){
            
            validateJob(cmdt.DeveloperName, cmdt.Email_Recipients__c);
            
        }
    }
    
    public static void validateJob(string apexBatchName, string recipientEmail){ 
        
        list<AsyncApexJob> lstFailedJobs = [SELECT CreatedDate, ExtendedStatus, Status
            FROM AsyncApexJob 
            WHERE ApexClass.Name = : apexBatchName
            AND JobType = 'BatchApex'
            and (Status IN ('Aborted', 'Failed') or (Status = 'Completed' and ExtendedStatus like 'First error:%')) 
            and CreatedDate > :dateTime.now().addDays(-1)
        Order by CreatedDate DESC Limit 1];
        
        if(lstFailedJobs != null && lstFailedJobs.size() > 0){
            list<AsyncApexJob> lstRunningJobs = [SELECT CreatedDate, ExtendedStatus, Status                
                FROM AsyncApexJob 
                WHERE ApexClass.Name =  : apexBatchName
                AND JobType = 'BatchApex'
                and (Status IN ('Processing', 'Queued', 'Preparing', 'Holding') OR (Status = 'Completed' AND ExtendedStatus = null))
            and CreatedDate > : lstFailedJobs[0].CreatedDate];
            
            if(lstRunningJobs != null && lstRunningJobs.size() > 0){
                System.debug(apexBatchName + ' Batches are running : ');
                System.debug(lstRunningJobs);
            }
            else {
                
                Type classType = Type.forName(apexBatchName);
                Database.executeBatch((Database.Batchable<sObject>) classType.newInstance());
                
                if(recipientEmail != null){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = recipientEmail.split(',');
                    
                    message.subject = apexBatchName + ' : Apex Job restarted';
                    message.plainTextBody = ' Hi,\n\n Apex Job has been restarted, as the job was stopped due to below given reason :';
                    message.plainTextBody += '\n\n Apex Class Name : ' +  apexBatchName;
                    message.plainTextBody += '\n Status : ' +  lstFailedJobs[0].Status;
                    message.plainTextBody += '\n Status Detail : ' +  lstFailedJobs[0].ExtendedStatus;
                    
                    message.plainTextBody += '\n\n\nThanks,\n Salesforce Consumer Batch Handler';
                    
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    if(!test.isRunningTest()){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        if (results[0].success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: '
                                         + results[0].errors[0].message);
                        }
                    }
                    
                }
            }
        }
    }
}