public class DocumentWebsiteTrackerTriggerHandler {

    public static void createUpdateDocWebTrackerRecord(Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromNull, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromPending, 
                                                          Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenApprovedFromRec, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenErrorFromRec, 
                                                          Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenPendingFromError, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenRecFromError,  
                                                          Boolean boolDocWebMapWhenPendingFromNull, Boolean boolDocWebMapWhenRecFromPending, Boolean boolDocWebMapWhenApprovedFromRec, Boolean boolDocWebMapWhenErrorFromRec, 
                                                          Boolean boolDocWebMapWhenPendingFromError, Boolean boolDocWebMapWhenRecFromError, Map<Id, List<Document_Website_Tracker__c>> DocWebMap, List<Account> triggerNew,
                                                          BusinessHours busnHrs, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastApproved, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastError, 
                                                          Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastPending, Map<Id, List<Document_Website_Tracker__c>> DocWebMapWhenLastRecieved, 
                                                          Boolean boolDocWebMapWhenLastApproved, Boolean boolDocWebMapWhenLastError, Boolean boolDocWebMapWhenLastPending, Boolean boolDocWebMapWhenLastRecieved){
        
        List<Document_Website_Tracker__c> docWebTrackerobjs = new List<Document_Website_Tracker__c>();
		List<Document_Website_Tracker__c> docWebTrackerobjs1 = new List<Document_Website_Tracker__c>();
        Document_Website_Tracker__c docWebTrackerobj;
                                                              
		Boolean isInFlowPending = false;
		Boolean isInFlowRecieved = false;
        Boolean isInFlowApproved = false;
		Boolean isInFlowError = false;
		Boolean isInFlowPendingFromError = false;
		Boolean isInFlowRecievedFromError = false;
        
        for(Account account : triggerNew){
        if(!DocWebMapWhenPendingFromNull.isEmpty() && !boolDocWebMapWhenPendingFromNull){
            isInFlowPending = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenPendingFromNull.get(account.Id)[0];
            docWebTrackerobj.Pending_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Pending__c = account.LastModifiedDate;
            docWebTrackerobjs.add(docWebTrackerobj);   
        }else if(DocWebMapWhenPendingFromNull.isEmpty() && boolDocWebMapWhenPendingFromNull){
            isInFlowPending = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Pending_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Pending__c = account.LastModifiedDate;
            docWebTrackerobjs.add(docWebTrackerobj);   
        }if(!DocWebMapWhenRecFromPending.isEmpty() && !boolDocWebMapWhenRecFromPending){
            isInFlowRecieved = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenRecFromPending.get(account.Id)[0];
            docWebTrackerobj.Recieved_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Recieved__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Pending_and_Recieved__c = getDurationbetween(docWebTrackerobj.Recieved_state__c, docWebTrackerobj.Pending_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }else if(DocWebMapWhenRecFromPending.isEmpty() && boolDocWebMapWhenRecFromPending){
            isInFlowRecieved = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Recieved_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Recieved__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Pending_and_Recieved__c = getDurationbetween(docWebTrackerobj.Recieved_state__c, docWebTrackerobj.Pending_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }if(!DocWebMapWhenApprovedFromRec.isEmpty() && !boolDocWebMapWhenApprovedFromRec){
            isInFlowApproved = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenApprovedFromRec.get(account.Id)[0];
            docWebTrackerobj.Approved_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Approved__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Recieved_and_Approved__c = getDurationbetween(docWebTrackerobj.Approved_state__c, docWebTrackerobj.Recieved_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }else if(DocWebMapWhenApprovedFromRec.isEmpty() && boolDocWebMapWhenApprovedFromRec){
            isInFlowApproved = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Approved_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Approved__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Recieved_and_Approved__c = getDurationbetween(docWebTrackerobj.Approved_state__c, docWebTrackerobj.Recieved_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }if(!DocWebMapWhenErrorFromRec.isEmpty() && !boolDocWebMapWhenErrorFromRec){
            isInFlowError = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenErrorFromRec.get(account.Id)[0];
            docWebTrackerobj.Error_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Error__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Recieved_and_Error__c = getDurationbetween(docWebTrackerobj.Error_state__c, docWebTrackerobj.Recieved_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }else if(DocWebMapWhenErrorFromRec.isEmpty() && boolDocWebMapWhenErrorFromRec){
            isInFlowError = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Error_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Error__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Recieved_and_Error__c = getDurationbetween(docWebTrackerobj.Error_state__c, docWebTrackerobj.Recieved_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }if(!DocWebMapWhenPendingFromError.isEmpty() && !boolDocWebMapWhenPendingFromError){
            isInFlowPendingFromError = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenPendingFromError.get(account.Id)[0];
            docWebTrackerobj.Count_for_recheck__c += 1;
            docWebTrackerobj.Pending_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Pending__c = account.LastModifiedDate;
            docWebTrackerobjs.add(docWebTrackerobj);
        }else if(DocWebMapWhenPendingFromError.isEmpty() && boolDocWebMapWhenPendingFromError){
            isInFlowPendingFromError = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Pending_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Pending__c = account.LastModifiedDate;
            docWebTrackerobj.Count_for_recheck__c = 1;
            docWebTrackerobjs.add(docWebTrackerobj);
        }if(!DocWebMapWhenRecFromError.isEmpty() && !boolDocWebMapWhenRecFromError){
            isInFlowRecievedFromError = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenRecFromError.get(account.Id)[0];
            docWebTrackerobj.Count_for_Recieved_after_Error__c += 1;
            docWebTrackerobj.Recieved_after_Error_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Recieved__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Docs_Error_and_Recieved_min__c = getDurationbetween(docWebTrackerobj.Recieved_after_Error_state__c, docWebTrackerobj.Error_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }else if(DocWebMapWhenRecFromError.isEmpty() && boolDocWebMapWhenRecFromError){
            isInFlowRecievedFromError = true;
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Recieved_after_Error_state__c = account.LastModifiedDate;
            docWebTrackerobj.When_Last_Recieved__c = account.LastModifiedDate;
            docWebTrackerobj.Count_for_Recieved_after_Error__c = 1;
            docWebTrackerobj.Time_b_w_Docs_Error_and_Recieved_min__c = getDurationbetween(docWebTrackerobj.Recieved_after_Error_state__c, docWebTrackerobj.Error_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }
        if(!DocWebMapWhenLastApproved.isEmpty() && !boolDocWebMapWhenLastApproved && !isInFlowApproved){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenLastApproved.get(account.Id)[0];
            docWebTrackerobj.When_Last_Approved__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj); 
        }else if(DocWebMapWhenLastApproved.isEmpty() && boolDocWebMapWhenLastApproved && !isInFlowApproved){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.When_Last_Approved__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj);
        }if(!DocWebMapWhenLastError.isEmpty() && !boolDocWebMapWhenLastError && !isInFlowError){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenLastError.get(account.Id)[0];
            docWebTrackerobj.When_Last_Error__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj);
        }else if(DocWebMapWhenLastError.isEmpty() && boolDocWebMapWhenLastError && !isInFlowError){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.When_Last_Error__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj);
        }if(!DocWebMapWhenLastPending.isEmpty() && !boolDocWebMapWhenLastPending && !isInFlowPending && !isInFlowPendingFromError){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenLastPending.get(account.Id)[0];
            docWebTrackerobj.When_Last_Pending__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj);
        }else if(DocWebMapWhenLastPending.isEmpty() && boolDocWebMapWhenLastPending && !isInFlowPending && !isInFlowPendingFromError){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.When_Last_Pending__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj);
        }if(!DocWebMapWhenLastRecieved.isEmpty() && !boolDocWebMapWhenLastRecieved && !isInFlowRecieved && !isInFlowRecievedFromError){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj = DocWebMapWhenLastRecieved.get(account.Id)[0];
            docWebTrackerobj.When_Last_Recieved__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj);
        }else if(DocWebMapWhenLastRecieved.isEmpty() && boolDocWebMapWhenLastRecieved && !isInFlowRecieved && !isInFlowRecievedFromError){
            docWebTrackerobj = new Document_Website_Tracker__c();
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.When_Last_Recieved__c = account.LastModifiedDate;
            docWebTrackerobjs1.add(docWebTrackerobj);
        }
        }
        
        if(!docWebTrackerobjs.isEmpty())	upsert docWebTrackerobjs;
		if(!docWebTrackerobjs1.isEmpty())	upsert docWebTrackerobjs1;
		
    }
    
    public static Decimal getDurationbetween(Datetime date1, Datetime date2, BusinessHours busnHrs){
        if(date2 != null && date1 != null){
            Long timeDiff = BusinessHours.diff(busnHrs.Id, date2, date1);   
            Long resultInMinutes = timeDiff/60000;
            return resultInMinutes;
        }
        else{
            return 0;
        }
    }    
    /*public static void createUpdateDocWebTrackerRecord(Account account, String oldStatusVal, String newStatusVal, List<Document_Website_Tracker__c> relatedRecords, BusinessHours busnHrs){
        System.debug(' -->> oldStatusVal '+oldStatusVal+' -- '+newStatusVal);
        
        List<Document_Website_Tracker__c> docWebTrackerobjs = new List<Document_Website_Tracker__c>();
        Document_Website_Tracker__c docWebTrackerobj;
        
        if(newStatusVal == 'Pending' && (oldStatusVal == null || String.isEmpty(oldStatusVal))){
            docWebTrackerobj = new Document_Website_Tracker__c();
            if(relatedRecords != null && !relatedRecords.isEmpty() && relatedRecords.size() > 0){
                docWebTrackerobj = relatedRecords[0];
            }
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Pending_state__c = account.LastModifiedDate;
            docWebTrackerobjs.add(docWebTrackerobj);
            //insert docWebTrackerobj;
        }
        else if(newStatusVal == 'Docs Received' && oldStatusVal == 'Pending'){
            docWebTrackerobj = new Document_Website_Tracker__c();
            if(relatedRecords != null && !relatedRecords.isEmpty()){
                docWebTrackerobj = relatedRecords[0];
            }
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Recieved_state__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Pending_and_Recieved__c = getDurationbetween(docWebTrackerobj.Recieved_state__c, docWebTrackerobj.Pending_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }
        else if(newStatusVal == 'Docs Approved' && oldStatusVal == 'Docs Received'){
            docWebTrackerobj = new Document_Website_Tracker__c();
            if(relatedRecords != null && !relatedRecords.isEmpty()){
                docWebTrackerobj = relatedRecords[0];
            }
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Approved_state__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Recieved_and_Approved__c = getDurationbetween(docWebTrackerobj.Approved_state__c, docWebTrackerobj.Recieved_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }
        else if(newStatusVal == 'Docs Error' && oldStatusVal == 'Docs Received'){
            docWebTrackerobj = new Document_Website_Tracker__c();
            if(relatedRecords != null && !relatedRecords.isEmpty()){
                docWebTrackerobj = relatedRecords[0];
            }
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Error_state__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Recieved_and_Error__c = getDurationbetween(docWebTrackerobj.Error_state__c, docWebTrackerobj.Recieved_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }
        else if(newStatusVal == 'Pending' && oldStatusVal == 'Docs Error'){
            docWebTrackerobj = new Document_Website_Tracker__c();
            if(relatedRecords != null && !relatedRecords.isEmpty()){
                docWebTrackerobj = relatedRecords[0];
            }
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Pending_state__c = account.LastModifiedDate;
            docWebTrackerobj.Count_for_recheck__c += 1;
            docWebTrackerobjs.add(docWebTrackerobj);
        }
        else if(newStatusVal == 'Docs Received' && oldStatusVal == 'Docs Error'){
            docWebTrackerobj = new Document_Website_Tracker__c();
            if(relatedRecords != null && !relatedRecords.isEmpty()){
                docWebTrackerobj = relatedRecords[0];
            }
            docWebTrackerobj.Account__c = account.Id;
            docWebTrackerobj.Count_for_Recieved_after_Error__c = Integer.valueOf(docWebTrackerobj.Count_for_Recieved_after_Error__c)+1;
            docWebTrackerobj.Recieved_after_Error_state__c = account.LastModifiedDate;
            docWebTrackerobj.Time_b_w_Docs_Error_and_Recieved_min__c = getDurationbetween(docWebTrackerobj.Recieved_after_Error_state__c, docWebTrackerobj.Error_state__c, busnHrs);
            docWebTrackerobjs.add(docWebTrackerobj);
        }
        
        if(!docWebTrackerobjs.isEmpty()){
            try{
                upsert docWebTrackerobjs;
            }catch(Exception exc){
                system.debug('-->> exception occured '+exc.getLineNumber()+' '+exc.getMessage());
            }
        }
    }
    
    public static Decimal getDurationbetween(Datetime date1, Datetime date2, BusinessHours busnHrs){
        if(date2 != null && date1 != null){
            Long timeDiff = BusinessHours.diff(busnHrs.Id, date2, date1);   
            Long resultInMinutes = timeDiff/60000;
            return resultInMinutes;
        }
        else{
            return 0;
        }
    }*/
}