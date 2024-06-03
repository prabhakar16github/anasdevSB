public class TaskTriggerHandler {
    public static void beforeInsertHandler(list<Task> triggerNew){}
    public static void afterInsertHandler(list<Task> triggerNew){} 
    public static void beforeUpdateHandler(list<Task> triggerNew, map<Id,Task> TriggeroldMap){
        updateReminderOnTask(triggerNew,TriggeroldMap);
        updatetimefield(triggerNew);
        updateReminderInBHOnTask(triggerNew,TriggeroldMap);
        
    }
    public static void afterUpdateHandler(list<Task> triggerNew, map<Id,Task> TriggeroldMap){
        updateManualCallDetailsOnCase(triggerNew,TriggeroldMap);
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to update the reminder date time on task if task contains next scheduled value
@history
<Date>                <Authors Name>              <Brief Description of Change>
24-Apr-19              Eitika Verma               created
**/ 
    public static void updateReminderOnTask(list<Task> triggerNew, map<Id,Task> TriggeroldMap){
        for(Task eachTask : triggerNew){
            Task oldTask = TriggeroldMap.get(eachTask.Id);
            if(eachTask.WhatId != NULL && String.valueOf(eachTask.WhatId).startswith('500') 
               && eachTask.LP_Next_Scheduled_Call__c != oldTask.LP_Next_Scheduled_Call__c 
               && eachTask.LP_Next_Scheduled_Call__c != NULL){
                   eachTask.IsReminderSet = true;
                   eachTask.ReminderDateTime = eachTask.LP_Next_Scheduled_Call__c;
                   eachTask.ActivityDate = date.newinstance(eachTask.LP_Next_Scheduled_Call__c.year(), eachTask.LP_Next_Scheduled_Call__c.month(), eachTask.LP_Next_Scheduled_Call__c.day());
               }
        }
    }
    
    /**
@author:            Eitika Verma
@company:           SaaSFocus
@description:       this method is used to update the manual call status and sub status on case
@history
<Date>                <Authors Name>              <Brief Description of Change>
24-Apr-19              Eitika Verma               created
**/ 
    public static void updateManualCallDetailsOnCase(list<Task> triggerNew, map<Id,Task> TriggeroldMap){
        list<Case> lstCase = new list<Case>();
        for(Task eachTask : triggerNew){
            Task oldTask = TriggeroldMap.get(eachTask.Id);
            if(eachTask.WhatId != NULL && String.valueOf(eachTask.WhatId).startswith('500') 
               && ((eachTask.LP_Manual_Call_Status__c != oldTask.LP_Manual_Call_Status__c 
                    && eachTask.LP_Manual_Call_Status__c != NULL) || 
                   (eachTask.LP_Next_Scheduled_Call__c != oldTask.LP_Next_Scheduled_Call__c &&
                    eachTask.LP_Next_Scheduled_Call__c != NULL) ||
                   (eachTask.LP_Manual_Call_Sub_Status__c != oldTask.LP_Manual_Call_Sub_Status__c &&
                    eachTask.LP_Manual_Call_Sub_Status__c != NULL))){
                        Case objCase = new Case(); 
                        objCase.id = eachTask.WhatId;
                        objCase.LP_Next_Scheduled_Call__c = eachTask.LP_Next_Scheduled_Call__c;
                        objCase.LP_Manual_Call_Status__c = eachTask.LP_Manual_Call_Status__c;
                        objCase.LP_Manual_Call_Sub_Status__c = eachTask.LP_Manual_Call_Sub_Status__c;
                        ObjCase.LP_manual_call_sub_detail__c = eachTask.Manual_Call_Sub_Detail__c;     
                        objCase.comments = eachTask.Description;
                        objCase.LP_Sub_Status__c = eachTask.LP_Sub_Status__c;
                        objCase.Reason_for_Product_intervention__c = eachTask.Reason_for_Product_intervention__c;
                        objCase.Primary_use_of_LazyPay_Credit_Limit__c = eachTask.Primary_use_of_LazyPay_Credit_Limit__c;
                        objCase.LP_Audit_Status__c = eachTask.Audit_Status__c;
                        objCase.Current_KYC_Address_proof__c = eachTask.Current_KYC_Address_proof__c;
                        objCase.Consumer_drop_off_reason__c = eachTask.Consumer_drop_off_reason__c;
                        lstCase.add(objCase);
                    }
        }
        
        if(lstCase != NULL && lstCase.size()>0)
            update lstCase;
    }
    
    
    
    /**
@description:   This class will update the tsk closure time fields based on task created and task closed/completed.
@Created By:    Shivani Mishra
@history:       
<Date>                <Authors Name>              <Brief Description of Change>
01-Sep-20				Shivani Mishra				Created(JIRA-SFPI-780)
**/
    
    public static Decimal getDurationbetween(Datetime date1, Datetime date2, String busnHrs){
        if(date2 != null && date1 != null){
            Long timeDiff = BusinessHours.diff(busnHrs, date2, date1);   
            Long resultInMinutes = timeDiff/60000;
            return resultInMinutes;
        }
        else{
            return 0;
        }
    }
    public static void updatetimefield(list<Task> triggerNew){
        Map<string,string> businessHourNameIdmap = (map<string,string>)JSON.deserialize(System.Label.BusinessHourNameIdMap,map<string,string>.class);
        system.debug('businessHourNameIdmap@@@' +businessHourNameIdmap);
        String payuOnecareChildBHId = businessHourNameIdmap.get('PayU OneCare Child'); 
        system.debug('@@@@' +triggernew.size());
        for(Task eachTask : triggerNew){
            if( eachTask.Status=='Closed' || eachTask.Status=='Completed' ){
                datetime closedate= system.now();
                system.debug('CreatedDate call????' +eachTask.CreatedDate);
                eachTask.Task_clousure_time__c=getDurationbetween(closedate,eachTask.CreatedDate,payuOnecareChildBHId)/60;
            }
        }
    }
    
    /**
    @author:            Sneha Sahi
    @company:           PayU
    @description:       this method is used to update Reminder Time to send SLA Breach Notifications
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    21-Dec-20              Sneha Sahi             created
    **/
    public static void updateReminderInBHOnTask(List<Task> triggerNew, Map<id,Task> triggerOldMap){
        
        Map<string,string> BusinessHourIdMap = (Map<string,string>)json.deserialize(System.label.BusinessHourNameIdMap, Map<string,string>.class);
        String BusinessHourId = BusinessHourIdMap.get('PayU OneCare Child');
        List<String> OwnerChangeSubj = Label.OwnerChangeTaskSubject.Split(','); 
        
        Map<String,String> updateOwnerMap = new Map<String,String>();
        for(Task each : triggerNew){
            Task oldTask = triggerOldMap.get(each.id);
            if(each.L1_Escalated__c != oldTask.L1_Escalated__c  && each.L1_Escalated__c){
                DateTime timeNow = System.now();
                each.L2_Reminder_DateTime__c = addBusinessHours(BusinessHourId,timeNow,10800000);
            }
            if(each.OwnerId != oldTask.OwnerId && each.OwnerId != Label.IntegrationUserId 
               && String.valueof(each.OwnerId).startswith('005') && each.Merchant_Plan__c != null
               && OwnerChangeSubj.contains(each.Subject)){
                updateOwnerMap.put(each.Merchant_Plan__c,each.OwnerId);
            }
        }
        
        if(!updateOwnerMap.isEmpty()){
            list<Merchant_Plan__c> MerchantPlanList = [select id,Kam__c from Merchant_Plan__c where id IN :updateOwnerMap.keySet()];
            list<Merchant_Plan__c> updMerchantPlanOwnList = new List<Merchant_Plan__c>();
            for(Merchant_Plan__c updMPlan : MerchantPlanList ){
                updMPlan.kam__c = updateOwnerMap.get(updMPlan.id);
                updMerchantPlanOwnList.add(updMPlan);
            }
            if(!updMerchantPlanOwnList.isEmpty()) update updMerchantPlanOwnList;
        }
    }
    
    public static DateTime addBusinessHours(String busnHrs,Datetime date1, long TimeInMiliseconds ){
        if(TimeInMiliseconds != null && date1 != null){
            DateTime reqDateTime = BusinessHours.add(busnHrs, date1, TimeInMiliseconds);   
            //Long resultInMinutes = timeDiff/60000;
            return reqDateTime;
        }else{
            return null;
        }
        
    }
        

    
}