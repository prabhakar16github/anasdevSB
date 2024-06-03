public class EventFieldContainerController {
    
    @AuraEnabled(cacheable=true)
    public static List<Event> getEventFields(List<Id> eventId){
        return [SELECT Id, Sub__c, Topic_of_Discussion__c
                FROM Event 
                WHERE Id  IN: eventId LIMIT 1];
    }
    

}