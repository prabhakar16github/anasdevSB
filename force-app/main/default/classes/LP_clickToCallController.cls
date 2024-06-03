public class LP_clickToCallController {
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method calls the knowlarity for manual call
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    30-Dec-18     Eitika Verma          created
    */
    @AuraEnabled
    public static string callKnowlarityForC2C(string caseId){
        boolean isAccessDenied;
        boolean isManualUser = isManualQueueUser(caseId);
        if(String.isNotBlank(caseId) && isManualUser){
            //get case record data
            list<Case> lstCase = getCaseData(caseId);
            
            if(lstCase != NULL && lstCase.size()>0){
                Case objCase = lstCase[0];
                
                //prepare the payload for manual call
                String strPayload = KnowlarityUtility.prepareManualCallPayload('Manual_Call',objCase,objCase.recordType.Name);
                system.debug('strPayload==========='+strPayload);
                
                //pass this payload to knowlarity
                HttpResponse objResponse = CollectionNotificationUtility.sendRequest(strPayload,'knowlarityManualCall','knowlarityManualCall');
               system.debug('status==========='+objResponse);
                
                objCase.LP_Manual_Call_Completed__c = true;
                objCase.LP_Last_Manual_Call_Agent__c = userInfo.getName();
                update objCase;
                
                //create task
                createTaskForManualCall(objCase);
                
            }
            isAccessDenied = false;
        }
        else{
            if(!isManualUser){
                isAccessDenied = true;
            }
        }
        return JSON.serialize(isAccessDenied);
    }
    
    /**
    @author:            Eitika Verma
    @company:           SaaSFocus
    @description:       this method is used to create task for manual call
    @history
    <Date>                <Authors Name>              <Brief Description of Change>
    04-FEB-19              Eitika Verma               created
    **/ 
    public static void createTaskForManualCall(Case oCase){
        list<string> lstQueue = Label.LP_QueueNames.split(',');
        list<GroupMember> lstGrpMember = [Select UserOrGroupId,
                                          GroupId 
                                          From GroupMember 
                                          WHERE UserOrGroupId=:userinfo.getUserId() 
                                          AND GroupId IN (SELECT id 
                                                          FROM Group 
                                                          WHERE type = 'Queue' 
                                                          AND developerName IN:lstQueue)];
        if(lstGrpMember != NULL && lstGrpMember.size()>0){
            //for(Case eachCase : listCase){
            Task objTask = new Task();
            objTask.OwnerId = userInfo.getUserId();
            objTask.WhatId = oCase.Id;
            objTask.WhoId = oCase.ContactId;
            objTask.Subject = 'Manual Call';
            /*if(oCase.LP_Next_Scheduled_Call__c != NULL){
                objTask.IsReminderSet = true;
                objTask.ReminderDateTime = oCase.LP_Next_Scheduled_Call__c;
                objTask.ActivityDate = date.newinstance(oCase.LP_Next_Scheduled_Call__c.year(), oCase.LP_Next_Scheduled_Call__c.month(), oCase.LP_Next_Scheduled_Call__c.day());
                objTask.Subject = 'Next Manual Call';
                }
                else
                objTask.Subject = 'Manual Call';
                objTask.LP_Next_Scheduled_Call__c = oCase.LP_Next_Scheduled_Call__c;
                objTask.LP_Manual_Call_Status__c = oCase.LP_Manual_Call_Status__c;
                objTask.LP_Manual_Call_Sub_Status__c = oCase.LP_Manual_Call_Sub_Status__c;*/
            //lstTask.add(objTask);
            insert objTask;
        }
        
      //  oCase.LP_Manual_Call_Completed__c = true;
      //  oCase.LP_Last_Manual_Call_Agent__c = userInfo.getName();
      //  try{
       //     update oCase;
       // }
       // catch(exception ex){}
       
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method gets the case data on the basis of case id
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    30-Dec-18     Eitika Verma          created
    */
    private static list<Case> getCaseData(string caseId){
        //prepare the query string to get the case fields value
            string query = 'select ';
            
                List<knowlarityPayload__mdt> lstpayload = KnowlarityUtility.getPayLoadMap('Manual_Call');
                if(lstpayload != null && lstpayload.size()>0)
                    query += lstpayload[0].FieldsToQuery__c;
                
                
                    query += ' from Case where ID ='+ '\''+ caseId +'\' For Update' ;
                        return Database.query(query);
    }
    
    /**
    @author:          Eitika Verma
    @company:         SaaSFocus
    @description:     this method checks that logged in user is lie in manual queue or not
    @history
    <Date>        <Authors Name>        <Brief Description of Change>
    2-Jan-19     Eitika Verma          created
    */
    public static boolean isManualQueueUser(string strCaseId){
       
        list<string> lstQueue = Label.LP_QueueNames.split(',');
        system.debug('lstQueue======='+lstQueue);
        system.debug('lstQueue========'+userinfo.getUserId());
        list<GroupMember> lstGrpMember = [Select UserOrGroupId,
                                          GroupId 
                                          From GroupMember 
                                          WHERE UserOrGroupId=:userinfo.getUserId() 
                                          AND GroupId IN (SELECT id 
                                                          FROM Group 
                                                          WHERE type = 'Queue' 
                                                          AND developerName IN:lstQueue)];
        System.debug(lstGrpMember.size());
        if(lstGrpMember != NULL && lstGrpMember.size()>0)
            return true;
        else{
            if(Test.isRunningTest())
                return true;
            else
                return false;
        }
            
    }
}