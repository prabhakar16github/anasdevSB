public class CalculateTimeInBusinessHours {
	/**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to take the time difference between two timestamps according to business hours  
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    25-FEB-19              Eitika Verma               created
    **/
    public static void calculateMinInBH(datetime startTime, datetime endTime, string fieldAPIName,Status_SLA__c objSLA,Id bhId){
        System.debug('startTime========'+startTime);
        System.debug('endTime========'+endTime);
        System.debug('fieldAPIName========'+fieldAPIName);
        System.debug('objSLA========'+objSLA);
        System.debug('bhId========'+bhId);
        if(startTime != NULL && endTime != NULL && String.isNotBlank(fieldAPIName) && objSLA != NULL && bhId != NULL){
            datetime dtStartTime = Datetime.ValueOf(startTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'').replace('T',' ').replace('Z',' '));
            datetime dtEndTime = Datetime.ValueOf(endTime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'').replace('T',' ').replace('Z',' '));
            Integer diffValue = (Integer)(BusinessHours.diff(bhId,dtStartTime,dtEndTime))/60000;
            objSLA.put(fieldAPIName,diffValue);
        }
    }
    
}