public class BusinessDays {
    public BusinessHours bHours;
    BusinessDays(){
        bHours = [SELECT Id FROM BusinessHours WHERE Name = 'PayU'];
    }
    
    public static list<Case> updateDateAccordingToBH(list<Case> lstCase){
        system.debug('lstCase'+ lstCase);
        //If no business hours name provided in paramaterized constructor, use deafault hours
       // BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE Name = 'PayU'];
        BusinessDays objBusinessDays =  new BusinessDays();
        list<case> listOfcase = new list<case>();
        for(Case eachCase : lstCase){
            Integer days =  eachCase.LP_TAT__c != Null ? integer.valueOf(eachCase.LP_TAT__c) : 0 ;
            eachCase.Expected_Closure_Date__c = objBusinessDays.addDays(eachCase.CreatedDate, days);
            listOfcase.add(eachCase);
        }
        return listOfcase;
    } 
    public Datetime addDays(Datetime startDate, Integer days)
    {
        system.debug('bHours' + bHours);
        system.debug('startDate' + startDate);
        
        
        //If startdate is not within working days, take next working day
        startDate = BusinessHours.nextStartDate(bHours.Id, startDate);
       for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Add 1 day
            startDate = startDate.addDays(1);
           //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate))
            { 
                //If new date is not within working days, get new working day
                startDate = BusinessHours.nextStartDate(bHours.Id, startDate);
            }
        }
        return startDate;
    }
}