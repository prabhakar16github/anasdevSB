/**
@company:           PayU 
@description:       This class is used in one care. it will calculate the business days and update expected closer date
@Created By: Akash Pandey
@history:           <Date>                             
14-Dec-19
**/
public class OneCareBusinessDays {
    public List<BusinessHours> bHours;
    OneCareBusinessDays(){
        bHours = [SELECT Id FROM BusinessHours where Name IN ('OneCare Business Hour', 'PayU OneCare Child') ORDER BY Name ASC];
    }
    
    public static DateTime updateDateAccordingToBH(list<Case> lstCase){
        system.debug('lstCase'+ lstCase);
        DateTime expectedClosureDate = System.now()+3;
        Id MCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantCare').getRecordTypeId();
        Id BCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('BuyerCare').getRecordTypeId();
        OneCareBusinessDays objBusinessDays =  new OneCareBusinessDays();
        list<case> listOfcase = new list<case>();
        for(Case eachCase : lstCase){
            if((eachCase.recordTypeId == MCRecordTypeId || eachCase.recordTypeId == BCRecordTypeId) && eachCase.LP_TAT__c != NULL){
                Integer days =  eachCase.LP_TAT__c != Null ? integer.valueOf(eachCase.LP_TAT__c) : 0 ;
                System.debug('days >>>>'+days);
                expectedClosureDate = objBusinessDays.addDays(System.now(), days,eachCase.Owner__c);
                listOfcase.add(eachCase);
            }
        }
        System.debug('expectedClosureDate >>>>'+expectedClosureDate);
        return expectedClosureDate;
    } 
    public Datetime addDays(Datetime startDate, Integer days,String case_Owner)
    {
        //If startdate is not within working days, take next working day
        if(case_Owner == 'PayU Money'){
            startDate = BusinessHours.nextStartDate(bHours[1].Id, startDate);
            for (Integer elapsed = 0; elapsed < days; elapsed++){
                //Add 1 day
                startDate = startDate.addDays(1);
                //Check if new date is within working days
                if (!BusinessHours.isWithin(bHours[1].Id, startDate)){ 
                    //If new date is not within working days, get new working day
                    startDate = BusinessHours.nextStartDate(bHours[1].Id, startDate);
                }
            }
        }else{
            startDate = BusinessHours.nextStartDate(bHours[0].Id, startDate);
            for (Integer elapsed = 0; elapsed < days; elapsed++){
                //Add 1 day
                startDate = startDate.addDays(1);
                //Check if new date is within working days
                if (!BusinessHours.isWithin(bHours[0].Id, startDate)){ 
                    //If new date is not within working days, get new working day
                    startDate = BusinessHours.nextStartDate(bHours[0].Id, startDate);
                }
            }
        }
        return startDate;
    }
    
}