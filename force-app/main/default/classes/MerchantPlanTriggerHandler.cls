public class MerchantPlanTriggerHandler {
    
    public static Map<String,List<GroupMember>> groupIdVsMembersMap = New Map<String,List<GroupMember>>();
    
    public Static void beforeInsertHandler(list<Merchant_Plan__c> triggerNew){
        
        list<Merchant_Plan__c> planList = new List<Merchant_Plan__c>();
        Map<string,Merchant_Plan__c> parentIdPlanMap = new Map<string,Merchant_Plan__c>();
        Map<string,Merchant_Plan__c> parentIdPlanfailedMap = new Map<string,Merchant_Plan__c>();
        Integer IntrandomPreNumber = Integer.valueof((Math.random() * 1000));
        Integer userIndex ;
        
        if(groupIdVsMembersMap.isEmpty()){
            List<String> queueDeveloperNames = New List<String>{'KAM_for_CS'};
                groupIdVsMembersMap = SystemUtility.getQueuesNameMembers(queueDeveloperNames);
        }
        
        try{
            for(Merchant_Plan__c each : triggerNew){
                if(each.Status__c == 'payment_completed'){
                    planList.add(each);
                    String parentOpp = each.Opportunity__c != null ? each.Opportunity__c : each.Lead__c;
                    parentIdPlanMap.put(parentOpp,each);
                    each.KAM_update_Time__c = system.now().addMinutes(-59);
                    if(groupIdVsMembersMap.containsKey('KAM_for_CS') && groupIdVsMembersMap.get('KAM_for_CS') != null){
                        userIndex = Math.mod(IntrandomPreNumber, groupIdVsMembersMap.get('KAM_for_CS').Size());
                        each.KAM__c = groupIdVsMembersMap.get('KAM_for_CS').get(userIndex).UserOrGroupId;
                    }
                    /*if(premiumGrp != null && premiumGrp.GroupMembers != null && !premiumGrp.GroupMembers.isEmpty()){
Integer userIndex = Math.mod(IntrandomPreNumber, premiumGrp.GroupMembers.Size());
each.KAM__c = premiumGrp.GroupMembers.get(userIndex).UserOrGroupId;
}*/
                }
                else if(each.Status__c == 'payment_failed'){
                    String parentOpp = each.Opportunity__c != null ? each.Opportunity__c : each.Lead__c;
                    parentIdPlanfailedMap.put(parentOpp,each);
                }
            }
            
            if(!parentIdPlanMap.isEmpty() && parentIdPlanMap != null ) createTasksForKAM(parentIdPlanMap,'');
            if(!parentIdPlanfailedMap.isEmpty() && parentIdPlanfailedMap != null ) {
                createTasksForKAM(parentIdPlanfailedMap,'Please connect with merchant to retry payment');
            }
            
        }catch(exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Merchant Plan before update failed');
            insert erDetail;
        }
    }
    
    
    public static void beforeUpdateHandler(list<Merchant_Plan__c> triggerNew, Map<id,Merchant_plan__c> triggerOldMap){
        
        list<Merchant_Plan__c> planList = new List<Merchant_Plan__c>();
        Map<string,Merchant_Plan__c> parentIdPlanMap = new Map<string,Merchant_Plan__c>();
        Map<string,Merchant_Plan__c> parentIdPlanfailedMap = new Map<string,Merchant_Plan__c>();
        Integer IntrandomPreNumber = Integer.valueof((Math.random() * 1000));
        Integer userIndex ;
        
        if(groupIdVsMembersMap.isEmpty()){
            List<String> queueDeveloperNames = New List<String>{'KAM_for_CS'};
                groupIdVsMembersMap = SystemUtility.getQueuesNameMembers(queueDeveloperNames);
        }
        /*Group premiumGrp = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) 
FROM Group WHERE DeveloperName ='KAM_for_CS' AND Type =: 'Queue' LIMIT 1];
*/
        try{
            for(Merchant_Plan__c each : triggerNew){
                Merchant_Plan__c oldData = triggerOldMap.get(each.id);
                if(each.Status__c != oldData.Status__c && each.Status__c == 'payment_completed'){
                    planList.add(each);
                    String parentOpp = each.Opportunity__c != null ? each.Opportunity__c : each.Lead__c;
                    parentIdPlanMap.put(parentOpp,each);
                    each.KAM_update_Time__c = system.now().addMinutes(-59);
                    if(groupIdVsMembersMap.containsKey('KAM_for_CS') && groupIdVsMembersMap.get('KAM_for_CS') != null){
                        userIndex = Math.mod(IntrandomPreNumber, groupIdVsMembersMap.get('KAM_for_CS').Size());
                        each.KAM__c = groupIdVsMembersMap.get('KAM_for_CS').get(userIndex).UserOrGroupId;
                    }
                    /*if(premiumGrp != null && premiumGrp.GroupMembers != null && !premiumGrp.GroupMembers.isEmpty()){
Integer userIndex = Math.mod(IntrandomPreNumber, premiumGrp.GroupMembers.Size());
each.KAM__c = premiumGrp.GroupMembers.get(userIndex).UserOrGroupId;
}*/
                }
                
                else if(each.Status__c != oldData.Status__c && each.Status__c == 'payment_failed'){
                    String parentOpp = each.Opportunity__c != null ? each.Opportunity__c : each.Lead__c;
                    parentIdPlanfailedMap.put(parentOpp,each);
                }
            }
            
            if(!parentIdPlanMap.isEmpty() && parentIdPlanMap != null ) createTasksForKAM(parentIdPlanMap,'');
            if(!parentIdPlanfailedMap.isEmpty() && parentIdPlanfailedMap != null ) {
                createTasksForKAM(parentIdPlanfailedMap,'Please connect with merchant to retry payment');
            }
            
        }catch(exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Merchant Plan before update failed');
            insert erDetail;
        }
    }
    
    public static void afterInsertHandler(list<Merchant_Plan__c> triggerNew){
        for(Merchant_Plan__c each : triggerNew){
            if(!system.isBatch() && each.Data_need_to_be_publish__c){
                IntegrationUtility.checkMaintenance(each, null, 'Merchant_Plan__c', 'Merchant_Plan__c'); 
            }
        }
    }
    
    public static void afterUpdateHandler(list<Merchant_Plan__c> triggerNew, Map<id,Merchant_plan__c> triggerOldMap){
        
        Map<String,Merchant_Plan__c> updateoppList = new Map<String,Merchant_Plan__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String,Merchant_Plan__c> updateLeadList = new Map<String,Merchant_Plan__c>();
        List<Lead> leadList = new List<Lead>();
        
        try{
            for(Merchant_Plan__c each : triggerNew){
                Merchant_Plan__c oldData = triggerOldMap.get(each.id);
                if(!system.isBatch() && each.Data_need_to_be_publish__c){
                    IntegrationUtility.checkMaintenance(each, oldData, 'Merchant_Plan__c', 'Merchant_Plan__c'); 
                }
                if(each.Status__c == 'kam_assigned' && each.KAM_Email__c != null){
                    if(each.Opportunity__c != null) updateoppList.put(each.Opportunity__c,each);
                    else if(each.Lead__c != null) updateLeadList.put(each.Lead__c,each);
                }
            }
            if(updateoppList != null && updateoppList.size() > 0){
                for(Opportunity opp : [select isPremiumCustomer__c,Premium_KAM_Email__c,Premium_KAM_Name__c from opportunity where id in:updateoppList.keySet()]){
                    opp.isPremiumCustomer__c = true;
                    opp.Premium_KAM_Email__c = updateoppList.get(opp.Id).KAM_Email__c;
                    opp.Premium_KAM_Name__c = updateoppList.get(opp.Id).KAM_Name__c;
                    oppList.add(opp);
                }
                if(oppList != null && oppList.size() > 0) update oppList;
            }
            else if(updateLeadList != null && updateLeadList.size() > 0){
                for(Lead ld : [select isPremiumCustomer__c,Premium_KAM_Email__c,Premium_KAM_Name__c from Lead where id in:updateLeadList.keySet()]){
                    ld.isPremiumCustomer__c = true;
                    ld.Premium_KAM_Email__c = updateLeadList.get(ld.Id).KAM_Email__c;
                    ld.Premium_KAM_Name__c = updateLeadList.get(ld.Id).KAM_Name__c;
                    leadList.add(ld);
                }
                if(leadList != null && leadList.size() > 0) update leadList;
            }
        }catch(exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'Merchant Plan failed');
            insert erDetail;
        }
        
    }
    
    public static void createTasksForKAM(Map<String,Merchant_Plan__c> taskForKAM , string Subject)
    {
        List<task> tasks = new List<task>();
        Map<string,string> BusinessHourIdMap = (Map<string,string>)json.deserialize(System.label.BusinessHourNameIdMap, Map<string,string>.class);
        String BusinessHourId = BusinessHourIdMap.get('PayU OneCare Child');
        Integer IntrandomPreNumber = Integer.valueof((Math.random() * 1000));
        Integer userIndex ;
        
        if(groupIdVsMembersMap.isEmpty()){
            List<String> queueDeveloperNames = New List<String>{'KAM_for_CS'};
                groupIdVsMembersMap = SystemUtility.getQueuesNameMembers(queueDeveloperNames);
        }
        /*Group premiumGrp = [SELECT Id, Name, Type, (SELECT Id, UserOrGroupId, GroupId FROM GroupMembers) 
FROM Group WHERE DeveloperName ='KAM_for_CS' AND Type =: 'Queue' LIMIT 1];
*/
        
        for(String recId : taskForKAM.keySet()){ 
            if(subject == ''){
                if(String.valueOf(recId).startsWith('006')){
                    DateTime timeNow = System.now();
                    Task objTask = New Task(whatId = recId,Status='Open',Type='Other', ActivityDate = date.today()+1,
                                            Subject = 'Task for Purchased Plan',
                                            IsReminderSet = True, ReminderDateTime = addBusinessHours(BusinessHourId,timeNow,10800000),
                                            Merchant_plan__c = taskForKAM.get(recId).id, OwnerId = taskForKAM.get(recId).Kam__c);
                    
                    tasks.add(objTask);
                }
                else if(String.valueOf(recId).startsWith('00Q')){
                    DateTime timeNow = System.now();
                    Task objTask = New Task(whoId = recId,Status='Open',Type='Other', ActivityDate = date.today()+1,
                                            Subject = 'Task for Purchased Plan',
                                            IsReminderSet = True, ReminderDateTime = addBusinessHours(BusinessHourId,timeNow,10800000),
                                            Merchant_plan__c = taskForKAM.get(recId).id, OwnerId = taskForKAM.get(recId).Kam__c);
                    tasks.add(objTask);
                }
            }
            else{
                if(String.valueOf(recId).startsWith('006')){
                    DateTime timeNow = System.now();
                    Task objTask = New Task(whatId = recId,Status='Open',Type='Other', ActivityDate = date.today()+1,
                                            Subject = Subject,
                                            IsReminderSet = True, ReminderDateTime = addBusinessHours(BusinessHourId,timeNow,10800000),
                                            Merchant_plan__c = taskForKAM.get(recId).id);
                    if(groupIdVsMembersMap.containsKey('KAM_for_CS') && groupIdVsMembersMap.get('KAM_for_CS') != null){
                        userIndex = Math.mod(IntrandomPreNumber, groupIdVsMembersMap.get('KAM_for_CS').Size());
                        objTask.OwnerId = groupIdVsMembersMap.get('KAM_for_CS').get(userIndex).UserOrGroupId;
                    }
                    /*if(premiumGrp != null && premiumGrp.GroupMembers != null && !premiumGrp.GroupMembers.isEmpty()){
Integer userIndex = Math.mod(IntrandomPreNumber, premiumGrp.GroupMembers.Size());
objTask.OwnerId = premiumGrp.GroupMembers.get(userIndex).UserOrGroupId;
}*/
                    tasks.add(objTask);
                }
                else if(String.valueOf(recId).startsWith('00Q')){
                    DateTime timeNow = System.now();
                    Task objTask = New Task(whoId = recId,Status='Open',Type='Other', ActivityDate = date.today()+1,
                                            Subject = Subject,
                                            IsReminderSet = True, ReminderDateTime = addBusinessHours(BusinessHourId,timeNow,10800000),
                                            Merchant_plan__c = taskForKAM.get(recId).id);
                    if(groupIdVsMembersMap.containsKey('KAM_for_CS') && groupIdVsMembersMap.get('KAM_for_CS') != null){
                        userIndex = Math.mod(IntrandomPreNumber, groupIdVsMembersMap.get('KAM_for_CS').Size());
                        objTask.OwnerId = groupIdVsMembersMap.get('KAM_for_CS').get(userIndex).UserOrGroupId;
                    }
                    /*if(premiumGrp != null && premiumGrp.GroupMembers != null && !premiumGrp.GroupMembers.isEmpty()){
Integer userIndex = Math.mod(IntrandomPreNumber, premiumGrp.GroupMembers.Size());
objTask.OwnerId = premiumGrp.GroupMembers.get(userIndex).UserOrGroupId;
}*/
                    tasks.add(objTask);
                }
            }
        }
        if(!tasks.isEmpty())    insert tasks;
    }
    
    
    public static DateTime addBusinessHours(String busnHrs,Datetime date1, long TimeInMiliseconds ){
        if(TimeInMiliseconds != null && date1 != null){
            DateTime reqDateTime = BusinessHours.add(busnHrs, date1, TimeInMiliseconds);   
            //Long resultInMinutes = timeDiff/60000;
            return reqDateTime;
        }
        else{
            return null;
        }
    }
    
}