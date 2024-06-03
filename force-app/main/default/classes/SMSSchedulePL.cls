/*
    @author: Eitika Verma
    @company: Saasfocus
    @date : 24/5/2019
    @description: This schedule class is used to schedule the sms rule engine 
*/
global class SMSSchedulePL implements Schedulable{
    global void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        database.executebatch(new CollectionRuleEngineBatch('Send SMS 2'),20);
        
     }
}