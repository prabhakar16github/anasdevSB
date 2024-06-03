/*
    @author: jatin arora
    @company: Saasfocus
    @date : 4/01/2019
    @description: This schedule class is used to schedule the email rule engine 
*/
global class EmailSchedulePL implements Schedulable{
    public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        database.executebatch(new CollectionRuleEngineBatch('Send Email 2'),100);
     }
}