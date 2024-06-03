/*
    @author: Surender Kumar
    @company: Saasfocus
    @date : 17/9/2019
    @description: This schedule class is used to schedule the sms rule engine for future ref. 
*/

global class SMSScheduleAdditional implements Schedulable {
    global void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        database.executebatch(new CollectionRuleEngineBatch('Send SMS Additional'),20);
        
     }

}