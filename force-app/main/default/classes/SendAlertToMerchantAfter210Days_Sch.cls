/**
* @Name         SendAlertToMerchantAfter210Days_Sch 
* @Author       Prabhakar Joshi
* @Group        Risk
* @Description  This is a Schedulable class to schedule the Alerts to Merchant contact on 210th day from last transaction date.
*/
public class SendAlertToMerchantAfter210Days_Sch Implements Schedulable {
    public void execute(SchedulableContext sc){
        Database.executeBatch(new SendAlertToMerchantAfter210DaysBatch(new Set<String>()));
    }
}