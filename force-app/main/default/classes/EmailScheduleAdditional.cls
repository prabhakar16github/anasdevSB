/*
    @author: Surender Kumar
    @company: Saasfocus
    @date : 17/09/019
    @description: This schedule class is used to schedule the email rule engine fOR additional.
*/
public class EmailScheduleAdditional implements Schedulable{
    public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        database.executebatch(new CollectionRuleEngineBatch('Send Email Addional'),100);
     }

}