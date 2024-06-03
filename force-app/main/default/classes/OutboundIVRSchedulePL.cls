/*
    @author: jatin arora
    @company: Saasfocus
    @date : 4/01/2019
    @description: This schedule class is used to schedule the IVR rule engine 
*/
global class OutboundIVRSchedulePL implements Schedulable{
    public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        database.executebatch(new CollectionRuleEngineBatch('IVR Call 2'),100);
     }
}