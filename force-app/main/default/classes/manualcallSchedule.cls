/*
    @author: Surender Kumar
    @company: Saasfocus
    @date : 19/8/2019
    @description: This schedule class is used to schedule the Manual call batch class
*/
global class manualcallSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        database.executebatch(new CollectionRuleEngineBatch('Manual Call'),100);
        
     }
}