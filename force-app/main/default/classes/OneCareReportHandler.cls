/**
@company:       PayU
@description:   This class is used in one care. it will update the Status sla fields based on case status and sub status 
@Created By:    Akash Pandey
@history:       <Date>                             
23-Sep-19
**/
public class OneCareReportHandler {
    
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
    
    public static Map<string,List<Status_SLA__c>> getStatusSLAMap(List<Case> triggerNew){
        Map<string,list<Status_SLA__c>> lobWithSLAMap = New Map<string,list<Status_SLA__c>>();
        //list<Status_SLA__c> statusSlaList = new list<Status_SLA__c>();
        for(Status_SLA__c existingSLA : [Select Id,Active__c,OneCare_LOB_Name__c,Case__c,Case__r.LOB_Name__c,
                                         Case__r.OwnerId,P2P_Transferred__c, First_Resolution_Time__c,OneCare_Resolved_Time__c,OneCare_Resolved_Reopen_Time__c,
                                         Open_Resolved_Reopen_BH__c,Open_Pending_BH__c,OneCare_Open_Res__c,OneCare_New_Open_Time__c,
                                         Response_Received_Time__c,Reopen_Count__c,OneCare_First_Resolution__c,Reopen_Pending_BH__c,
                                         Reopen_Response_Received_Time__c,OneCare_New_Time_New__c,Transferred_from_Other_Teams_Time__c,Parent_RecordtypeId__c,Open_Pending_Merchant_Buyer_Count__c from Status_SLA__c Where Case__c IN: triggerNew]){
                                             if(string.isNotBlank(existingSLA.OneCare_LOB_Name__c)){
                                                 if(lobWithSLAMap.containsKey(existingSLA.OneCare_LOB_Name__c)){
                                                     list<status_sla__c> statusSla = lobWithSLAMap.get(existingSLA.OneCare_LOB_Name__c);
                                                     statusSla.add(existingSLA);
                                                     lobWithSLAMap.put(existingSLA.OneCare_LOB_Name__c,statusSla);
                                                 }
                                                 else{
                                                     lobWithSLAMap.put(existingSLA.OneCare_LOB_Name__c,new list<Status_SLA__c>{existingSLA});
                                                 }
                                                 
                                             }
                                         }
        //system.debug('lobWithSLAMap=='+lobWithSLAMap);
        return lobWithSLAMap;
    }
    
    public static Status_SLA__c createSLArecords(Case newCase, Case oldCase){
        Status_SLA__c  sla = new Status_SLA__c();
        sla.Case__c = newCase.Id;
        sla.Active__c = true;
        sla.OneCare_LOB_Name__c = newCase.LOB_Name__c;
        if(newCase.recordtypeId != NULL)
        	sla.Parent_RecordtypeId__c = newCase.recordtypeId;
        
        if(newCase.status == 'New'){
            if(sla.OneCare_New_Time__c==null)
                sla.OneCare_New_Time__c = System.now();
            if(string.valueOf(newCase.OwnerId).startsWith('005')){
                sla.First_assigned_user__c = newCase.Owner__c;
                sla.OneCare_Owner__c = newCase.OwnerId;
            }
        }else if(newCase.status == 'Open'){
            if(sla.OneCare_New_Time__c==null)
                sla.OneCare_New_Time__c = System.now();
            if(string.valueOf(newCase.OwnerId).startsWith('005')){
                sla.First_assigned_user__c = newCase.Owner__c;
                sla.OneCare_Owner__c = newCase.OwnerId;
            }
            if(sla.OneCare_New_Open_Time__c == null){
                sla.OneCare_New_Open_Time__c = system.now();
                sla.OneCare_New_Open_BH__c = 0;
            }
            
            if(sla.OneCare_New_Open_Count__c == null)
                sla.OneCare_New_Open_Count__c = 1;
        }
        else if(newCase.status == 'Transferred from other teams'){
            sla.Transferred_from_Other_Teams_Time__c = System.now();
            if(sla.Transferred_from_Other_Teams_Count__c ==null){
                sla.Transferred_from_Other_Teams_Count__c = 1;
                sla.onecare_status__c = 'Transferred from other teams';
            }
            if(sla.OneCare_New_Open_Time__c == null)
                sla.OneCare_New_Open_Time__c = system.now();
            if(string.valueOf(newCase.OwnerId).startsWith('005')){
                sla.First_assigned_user__c = newCase.Owner__c;
                sla.OneCare_Owner__c = newCase.OwnerId;
            }            
        }
        return sla;
    }
    //Prashant
    
    public static list<Status_SLA__c> updateOldSLA(Case oldCase,Map<string,List<Status_SLA__c>> lobWithSLAMap){
        try{
        list<Status_SLA__c> ListSla = new list<Status_SLA__c>();
        Map<string,string> businessHourNameIdmap = (map<string,string>)JSON.deserialize(System.Label.BusinessHourNameIdMap,map<string,string>.class);
        String onecareBHId = businessHourNameIdmap.get('OneCare Business Hour'); //(Monday-Saturday)
        String payuOnecareChildBHId = businessHourNameIdmap.get('PayU OneCare Child'); //(Monday-Friday)
        system.debug('OLD Case id'+oldCase.id);
        list<string> responseReceivedStatuses = new list<string>{'Response received','Response received from buyer','Response received from merchant','No Resolution From Other Teams','Response Received from Other Teams'};
        list<string> onecareLobList = new list<string>{'PayU Money','PayU_Care','Key_Support','Biz_Airtel_Support','citrus_wallet','Bank_Support'};
            
            
        list<Status_SLA__c> slaids= [Select id,Active__c,First_Resolution_Time__c,OneCare_Resolved_Time__c,
                                     OneCare_Owner__c,P2P_Transferred__c,Reopen_Pending_BH__c,Open_Pending_BH__c,
                                     Response_Received_Time__c,Reopen_Response_Received_Time__c,OneCare_Resolved_Reopen_Time__c,
                                     OneCare_Open_Res__c,OneCare_New_Open_Time__c,Parent_RecordtypeId__c from Status_SLA__c where Case__c=:oldCase.id];
        
        system.debug('SLA IDS LIST VALUE ####'+slaids);
        if(oldCase != null){  
           for(Status_SLA__c wrongSla : slaids){      
                Status_SLA__c woldSLA = New Status_SLA__c(Id=wrongSla.Id);
                system.debug('wrongSla.Active__c'+wrongSla.Active__c);  
                if(wrongSla.Active__c){
                    woldSLA.Active__c = false;
                    if(oldCase.recordtypeId != NULL)
                        woldSLA.Parent_RecordtypeId__c = oldCase.recordtypeId;
                    if(wrongSla.First_Resolution_Time__c == null){
                        if(onecareLobList.contains(oldCase.LOB_Name__c)){
                        woldSLA.First_Resolution_Time__c = system.now();
                    	woldSLA.OneCare_First_Resolution__c = wrongSla.OneCare_New_Open_Time__c != NULL ? getDurationbetween(woldSLA.First_Resolution_Time__c, wrongSla.OneCare_New_Open_Time__c, onecareBHId) : woldSLA.OneCare_First_Resolution__c ;
                        }
                        else{
                            woldSLA.First_Resolution_Time__c = system.now();
                            woldSLA.OneCare_First_Resolution__c = wrongSla.OneCare_New_Open_Time__c != NULL ? getDurationbetween(woldSLA.First_Resolution_Time__c, wrongSla.OneCare_New_Open_Time__c, payuOnecareChildBHId) : woldSLA.OneCare_First_Resolution__c ;
                        }
                    }
                    if(woldSLA.OneCare_Resolved_Time__c == null){
                        woldSLA.OneCare_Resolved_Time__c = System.now();
                        system.debug('oldCase.Status::'+oldCase.Status+'---');
                        if(responseReceivedStatuses.contains((oldCase.Status).trim())){
                            if(wrongSla.OneCare_Resolved_Reopen_Time__c != null){
                                if(wrongSla.OneCare_Open_Res__c != null && wrongSla.Reopen_Pending_BH__c != null 
                                   && wrongSla.Reopen_Response_Received_Time__c != null){
                                       if(onecareLobList.contains(oldCase.LOB_Name__c)){
                                       woldSLA.Reopen_Resolved_BH__c = wrongSla.Reopen_Pending_BH__c + getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.Reopen_Response_Received_Time__c, onecareBHId); 
                                       woldSLA.OneCare_Open_Res__c = wrongSla.OneCare_Open_Res__c + wrongSla.Reopen_Pending_BH__c + getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.Reopen_Response_Received_Time__c, onecareBHId); 
                                       }
                                       else{
                                           woldSLA.Reopen_Resolved_BH__c = wrongSla.Reopen_Pending_BH__c + getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.Reopen_Response_Received_Time__c, payuOnecareChildBHId); 
                                           woldSLA.OneCare_Open_Res__c = wrongSla.OneCare_Open_Res__c + wrongSla.Reopen_Pending_BH__c + getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.Reopen_Response_Received_Time__c, payuOnecareChildBHId); 
                                       }
                                   }
                            }
                            
                            else if(wrongSla.OneCare_New_Open_Time__c != null){
                                if(wrongSla.Open_Pending_BH__c != null && wrongSla.Response_Received_Time__c != null){
                                    if(onecareLobList.contains(oldCase.LOB_Name__c))
                                       woldSLA.OneCare_Open_Res__c = wrongSla.Open_Pending_BH__c + getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.Response_Received_Time__c, onecareBHId); 
                                    else
                                        woldSLA.OneCare_Open_Res__c = wrongSla.Open_Pending_BH__c + getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.Response_Received_Time__c, payuOnecareChildBHId); 
                                   }
                            }
                        }
                        
                        else if(oldCase.Status == 'Open'){
                            if(wrongSla.OneCare_New_Open_Time__c != null){
                                woldSLA.OneCare_Open_Res__c = onecareLobList.contains(oldCase.LOB_Name__c) ? getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_New_Open_Time__c, onecareBHId) 
                                    : getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_New_Open_Time__c, payuOnecareChildBHId) ;
                            }
                        }
                        else if(oldCase.Status == 'Re-Open'){
                            if(wrongSla.OneCare_Resolved_Reopen_Time__c != null){
                                woldSLA.Reopen_Resolved_BH__c = onecareLobList.contains(oldCase.LOB_Name__c) ? getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_Resolved_Reopen_Time__c, onecareBHId) 
                                    : getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_Resolved_Reopen_Time__c, payuOnecareChildBHId);
                                woldSLA.OneCare_Open_Res__c = wrongSla.OneCare_Open_Res__c + (onecareLobList.contains(oldCase.LOB_Name__c) ? getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_Resolved_Reopen_Time__c, onecareBHId)
                                                                                              : getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_Resolved_Reopen_Time__c, payuOnecareChildBHId));
                            }
                        }
                        
                        else if(oldCase.Status == 'Transferred from other teams'){
                            if(wrongSla.OneCare_New_Open_Time__c != null){
                                woldSLA.OneCare_Open_Res__c = onecareLobList.contains(oldCase.LOB_Name__c) ? getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_New_Open_Time__c, onecareBHId) 
                                    : getDurationbetween(woldSLA.OneCare_Resolved_Time__c, wrongSla.OneCare_New_Open_Time__c, payuOnecareChildBHId) ;
                            }
                        }
                    }
                    
                    if(String.ValueOf(oldCase.OwnerId).startsWith('005')){
                        woldSLA.OneCare_Owner__c = oldCase.OwnerId;
                    }
                    woldSLA.P2P_Transferred__c = true;
                    woldSLA.onecare_status__c = 'Transferred to Other Teams';
                }
                ListSla.add(woldSLA);
                
            }  
            return ListSla;          
        } 
        }catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'update old SLA');
            insert erDetail;
            
        }
        return null;
    } 
    
    //Prashant
    
    public static Status_SLA__c updateNewSLA(Case newCase,Map<string,List<Status_SLA__c>> lobWithSLAMap,string status){
        try{
            system.debug('lobWithSLAMap::'+lobWithSLAMap);
            system.debug('newCase.LOB_Name__c::'+newCase.LOB_Name__c);
           Integer emailList=[Select count() from CaseComment Where ParentId=:newCase.Id]; //Animesh
            System.debug('emailList:::::::'+emailList);
        if(newCase != null && !lobWithSLAMap.isEmpty() && lobWithSLAMap.containsKey(newCase.LOB_Name__c)){
            
            Map<string,string> businessHourNameIdmap = (map<string,string>)JSON.deserialize(System.Label.BusinessHourNameIdMap,map<string,string>.class);
            String onecareBHId = businessHourNameIdmap.get('OneCare Business Hour'); //(Monday-Saturday)
            String payuOnecareChildBHId = businessHourNameIdmap.get('PayU OneCare Child'); //(Monday-Friday)
            list<string> onecareLobList = new list<string>{'PayU Money','PayU_Care','Key_Support','Biz_Airtel_Support','citrus_wallet','Bank_Support'};
            list<String> waitingonMerchantBuyerSubStatuses = new list<string>{'Waiting On Merchant','Waiting On Buyer','Waiting On Bank(Bank Support)','Raised with Merchant'};
			Id McareChildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('MerchantChildCase').getRecordTypeId();
            Id ETCchildRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email to Case Child').getRecordTypeId();
            list<string> childRecordtypeIdlist = new list<string>();
            childRecordtypeIdlist.add(McareChildRecordTypeId);
            childRecordtypeIdlist.add(ETCchildRecordTypeId);

            for(Status_SLA__c eachStatusSla : lobWithSLAMap.get(newCase.LOB_Name__c)){
                if(eachStatusSla.Active__c == true && newCase.Id==eachStatusSla.Case__c){
                    Status_SLA__c newSLA = New Status_SLA__c(Id=eachStatusSla.Id);  
                    //Update ticket Owner
                    if(String.ValueOf(newCase.OwnerId).startsWith('005') && string.valueOf(newCase.OwnerId) != Label.IntegrationUserId){
                        newSLA.OneCare_Owner__c = newCase.OwnerId;
                        newSLA.Number_Of_Comments__c = emailList; //Animesh
                        System.debug('newSLA.Number_Of_Comments__c:::::'+newSLA.Number_Of_Comments__c);
                    }
                    
                    if(newCase.recordtypeId != NULL && eachStatusSla.Parent_RecordtypeId__c == null)
                        newSLA.Parent_RecordtypeId__c = newCase.recordtypeId;
                    
                    if(status == 'Open'){
                        if(newSLA.OneCare_New_Open_Time__c == null){
                            newSLA.OneCare_New_Open_Time__c = system.now();
                            newSLA.onecare_status__c = 'Open';
                            if(onecareLobList.contains(newCase.LOB_Name__c)){
                                newSLA.OneCare_New_Open_BH__c  = eachStatusSla.Transferred_from_Other_Teams_Time__c != null ?
                                    getDurationbetween(newSLA.OneCare_New_Open_Time__c, eachStatusSla.Transferred_from_Other_Teams_Time__c , onecareBHId):
                                getDurationbetween(newSLA.OneCare_New_Open_Time__c,eachStatusSla.OneCare_New_Time_New__c , onecareBHId);
                            }
                            else{
                                newSLA.OneCare_New_Open_BH__c  = eachStatusSla.Transferred_from_Other_Teams_Time__c != null ? getDurationbetween(newSLA.OneCare_New_Open_Time__c, eachStatusSla.Transferred_from_Other_Teams_Time__c , payuOnecareChildBHId):
                                getDurationbetween(newSLA.OneCare_New_Open_Time__c,eachStatusSla.OneCare_New_Time_New__c , payuOnecareChildBHId);
                            }
                        }
                        if(newCase.New_Open_Time__c == null){
                            newCase.New_Open_Time__c = system.now();
                            newCase.New_Open_BH__c  = onecareLobList.contains(newCase.LOB_Name__c) ? getDurationbetween(newCase.New_Open_Time__c,newCase.createdDate , onecareBHId)
                                : getDurationbetween(newCase.New_Open_Time__c,newCase.createdDate , payuOnecareChildBHId);
                        }
                    }
                    
                    else if(status == 'Resolved'){
                        if(eachStatusSla.First_Resolution_Time__c == null){
                            newSLA.First_Resolution_Time__c = System.now();                        
                        }
                        //update resolve time(last)
                        newSLA.OneCare_Resolved_Time__c = System.now();
                        newSLA.onecare_status__c = 'Resolved';
                        
                        newCase.Resolved_Time__c = system.now();
                        
                        if(eachStatusSla.Reopen_Count__c != null && eachStatusSla.Reopen_Count__c > 0){
                            if(onecareLobList.contains(newCase.LOB_Name__c)){
                                //When ticket was directly resolved
                                if(eachStatusSla.Reopen_Pending_BH__c == null ){
                                    newSLA.Reopen_Resolved_BH__c  = eachStatusSla.OneCare_Resolved_Reopen_Time__c != null ? getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.OneCare_Resolved_Reopen_Time__c, onecareBHId) : newSLA.Reopen_Resolved_BH__c  ;
                                }
                                //When Ticket was pending on merchant/buyer/other Team
                                else{
                                    newSLA.RR_Resolved_BH__c = eachStatusSla.Reopen_Response_Received_Time__c != null ? 
                                        getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.Reopen_Response_Received_Time__c, onecareBHId) : newSLA.RR_Resolved_BH__c;
                                    
                                    newSLA.Reopen_Resolved_BH__c  = (eachStatusSla.Reopen_Pending_BH__c != null && newSLA.RR_Resolved_BH__c != null) ? 
                                        (eachStatusSla.Reopen_Pending_BH__c + newSLA.RR_Resolved_BH__c) : newSLA.Reopen_Resolved_BH__c ;
                                }
                                
                                newSLA.OneCare_Open_Res__c =  (eachStatusSla.OneCare_Open_Res__c != null && newSLA.Reopen_Resolved_BH__c != null) ? 
                                    (eachStatusSla.OneCare_Open_Res__c + newSLA.Reopen_Resolved_BH__c) : newSLA.OneCare_Open_Res__c  ; 
                                
                                newSLA.Reopen_Pending_BH__c = null;
                                //newSLA.Reopen_Resolved_BH__c = null;
                            }
                            else{
                                //When ticket was directly resolved
                                if(eachStatusSla.Reopen_Pending_BH__c == null ){
                                    newSLA.Reopen_Resolved_BH__c  = eachStatusSla.OneCare_Resolved_Reopen_Time__c != null ? getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.OneCare_Resolved_Reopen_Time__c, payuOnecareChildBHId) : newSLA.Reopen_Resolved_BH__c  ;
                                }
                                //When Ticket was pending on merchant/buyer/other Team
                                else{
                                    newSLA.RR_Resolved_BH__c = eachStatusSla.Reopen_Response_Received_Time__c != null ? 
                                        getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.Reopen_Response_Received_Time__c, payuOnecareChildBHId) : newSLA.RR_Resolved_BH__c;
                                    
                                    newSLA.Reopen_Resolved_BH__c  = (eachStatusSla.Reopen_Pending_BH__c != null && newSLA.RR_Resolved_BH__c != null) ? 
                                        (eachStatusSla.Reopen_Pending_BH__c + newSLA.RR_Resolved_BH__c) : newSLA.Reopen_Resolved_BH__c ;
                                }
                                
                                newSLA.OneCare_Open_Res__c =  (eachStatusSla.OneCare_Open_Res__c != null && newSLA.Reopen_Resolved_BH__c != null) ? 
                                    (eachStatusSla.OneCare_Open_Res__c + newSLA.Reopen_Resolved_BH__c) : newSLA.OneCare_Open_Res__c  ; 
                                
                                newSLA.Reopen_Pending_BH__c = null;
                                //newSLA.Reopen_Resolved_BH__c = null;
                            }
                        }
                        else{
                            if(onecareLobList.contains(newCase.LOB_Name__c)){
                                //When ticket was directly resolved
                                if(eachStatusSla.Open_Pending_BH__c == null ){
                                    newSLA.OneCare_Open_Res__c  = eachStatusSla.OneCare_New_Open_Time__c != null ? getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.OneCare_New_Open_Time__c, onecareBHId) : newSLA.OneCare_Open_Res__c  ;
                                }
                                //When Ticket was pending on merchant/buyer/other Team
                                else{
                                    newSLA.RR_Resolved_BH__c = eachStatusSla.Response_Received_Time__c != null ? 
                                        getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.Response_Received_Time__c, onecareBHId) : newSLA.RR_Resolved_BH__c;
                                    
                                    newSLA.OneCare_Open_Res__c =  newSLA.RR_Resolved_BH__c != null ? 
                                        (newSLA.RR_Resolved_BH__c + eachStatusSla.Open_Pending_BH__c) : newSLA.OneCare_Open_Res__c  ; 
                                    
                                }
                                //Update first resolution time
                                if(eachStatusSla.OneCare_First_Resolution__c == null){
                                    newSLA.OneCare_First_Resolution__c = newSLA.OneCare_Open_Res__c != null ? newSLA.OneCare_Open_Res__c : newSLA.OneCare_First_Resolution__c; 
                                }
                            }
                            else{                               
                                //When ticket was directly resolved
                                if(eachStatusSla.Open_Pending_BH__c == null ){
                                    newSLA.OneCare_Open_Res__c  = eachStatusSla.OneCare_New_Open_Time__c != null ? getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.OneCare_New_Open_Time__c, payuOnecareChildBHId) : newSLA.OneCare_Open_Res__c  ;
                                }
                                //When Ticket was pending on merchant/buyer/other Team
                                else{
                                    newSLA.RR_Resolved_BH__c = eachStatusSla.Response_Received_Time__c != null ? 
                                        getDurationbetween(newSLA.OneCare_Resolved_Time__c, eachStatusSla.Response_Received_Time__c, payuOnecareChildBHId) : newSLA.RR_Resolved_BH__c;
                                    
                                    newSLA.OneCare_Open_Res__c =  newSLA.RR_Resolved_BH__c != null ? 
                                        (newSLA.RR_Resolved_BH__c + eachStatusSla.Open_Pending_BH__c) : newSLA.OneCare_Open_Res__c  ; 
                                    
                                }
                                //Update first resolution time
                                if(eachStatusSla.OneCare_First_Resolution__c == null){
                                    newSLA.OneCare_First_Resolution__c = newSLA.OneCare_Open_Res__c != null ? newSLA.OneCare_Open_Res__c : newSLA.OneCare_First_Resolution__c; 
                                }    
                            }
                        }
                        
                        if(newCase.Reopen_Count__c != null && newCase.Reopen_Count__c > 0){
                            if(onecareLobList.contains(newCase.LOB_Name__c)){
                                //When ticket was directly resolved
                                if(newCase.Reopen_Pending_BH__c == null ){
                                    newCase.Reopen_Resolved_BH__c  = newCase.Reopen_Time__c != null ? getDurationbetween(newCase.Resolved_Time__c, newCase.Reopen_Time__c, onecareBHId) : newCase.Reopen_Resolved_BH__c  ;
                                }
                                //When Ticket was pending on merchant/buyer/other Team
                                else{
                                    newCase.RR_Resolved_BH__c = newCase.Reopen_Response_Received_Time__c != null ? 
                                        getDurationbetween(newCase.Resolved_Time__c, newCase.Reopen_Response_Received_Time__c, onecareBHId) : newCase.RR_Resolved_BH__c;
                                    
                                    newCase.Reopen_Resolved_BH__c  = (newCase.Reopen_Pending_BH__c != null && newCase.RR_Resolved_BH__c != null) ? 
                                        (newCase.Reopen_Pending_BH__c + newCase.RR_Resolved_BH__c) : newCase.Reopen_Resolved_BH__c ;
                                }
                                
                                newCase.Open_Resolved_BH__c =  (newCase.Open_Resolved_BH__c != null && newCase.Reopen_Resolved_BH__c != null) ? 
                                    (newCase.Open_Resolved_BH__c + newCase.Reopen_Resolved_BH__c) : newCase.Open_Resolved_BH__c  ; 
                                
                                newCase.Reopen_Pending_BH__c = null;
                                newCase.Reopen_Resolved_BH__c = null;
                            }
                            else{
                                //When ticket was directly resolved
                                if(newCase.Reopen_Pending_BH__c == null ){
                                    newCase.Reopen_Resolved_BH__c  = newCase.Reopen_Time__c != null ? getDurationbetween(newCase.Resolved_Time__c, newCase.Reopen_Time__c, payuOnecareChildBHId) : newCase.Reopen_Resolved_BH__c  ;
                                }
                                //When Ticket was pending on merchant/buyer/other Team
                                else{
                                    newCase.RR_Resolved_BH__c = newCase.Reopen_Response_Received_Time__c != null ? 
                                        getDurationbetween(newCase.Resolved_Time__c, newCase.Reopen_Response_Received_Time__c, payuOnecareChildBHId) : newCase.RR_Resolved_BH__c;
                                    
                                    newCase.Reopen_Resolved_BH__c  = newCase.Reopen_Pending_BH__c != null ? 
                                        (newCase.Reopen_Pending_BH__c + newCase.RR_Resolved_BH__c) : newCase.Reopen_Resolved_BH__c ;
                                }
                                
                                newCase.Open_Resolved_BH__c =  (newCase.Open_Resolved_BH__c != null && newCase.Reopen_Resolved_BH__c != null) ? 
                                    (newCase.Open_Resolved_BH__c + newCase.Reopen_Resolved_BH__c) : newCase.Open_Resolved_BH__c  ; 
                                
                                newCase.Reopen_Pending_BH__c = null;
                                newCase.Reopen_Resolved_BH__c = null;
                            }
                        }
                        else{
                            if(onecareLobList.contains(newCase.LOB_Name__c)){
                                //When ticket was directly resolved
                                if(newCase.Open_Pending_BH__c == null ){
                                    newCase.Open_Resolved_BH__c  = newCase.New_Open_Time__c != null ? getDurationbetween(newCase.Resolved_Time__c, newCase.New_Open_Time__c, onecareBHId) : newCase.Open_Resolved_BH__c  ;
                                }
                                //When Ticket was pending on merchant/buyer
                                else{
                                    newCase.RR_Resolved_BH__c = newCase.Response_Received_Time__c != null ? 
                                        getDurationbetween(newCase.Resolved_Time__c, newCase.Response_Received_Time__c, onecareBHId) : newCase.RR_Resolved_BH__c;
                                    
                                    newCase.Open_Resolved_BH__c =  newCase.RR_Resolved_BH__c != null ? 
                                        (newCase.RR_Resolved_BH__c + newCase.Open_Pending_BH__c) : newCase.Open_Resolved_BH__c  ; 
                                    
                                }
                            }
                            else{                               
                                //When ticket was directly resolved
                                if(newCase.Open_Pending_BH__c == null ){
                                    newCase.Open_Resolved_BH__c  = newCase.New_Open_Time__c != null ? getDurationbetween(newCase.Resolved_Time__c, newCase.New_Open_Time__c, payuOnecareChildBHId) : newCase.Open_Resolved_BH__c  ;
                                }
                                //When Ticket was pending on merchant/buyer/other Team
                                else{
                                    newCase.RR_Resolved_BH__c = newCase.Response_Received_Time__c != null ? 
                                        getDurationbetween(newCase.Resolved_Time__c, newCase.Response_Received_Time__c, payuOnecareChildBHId) : newCase.RR_Resolved_BH__c;
                                    
                                    newCase.Open_Resolved_BH__c =  newCase.RR_Resolved_BH__c != null ? 
                                        (newCase.RR_Resolved_BH__c + newCase.Open_Pending_BH__c) : newCase.Open_Resolved_BH__c  ; 
                                    
                                }
                            }
                        }
                        
                    }
                    
                    else if(status == 'Re-Open'){
                        if(newSLA.OneCare_Resolved_Reopen_Time__c == null){
                            newSLA.OneCare_Resolved_Reopen_Time__c = System.now();
                            newSLA.onecare_status__c = 'Re-Open';
                            newSLA.Reopen_Count__c = eachStatusSla.Reopen_Count__c != null ? eachStatusSla.Reopen_Count__c + 1 : 1;
                        }
                        
                        newCase.Reopen_Time__c = System.now();
                        newCase.Reopen_Count__c = newCase.Reopen_Count__c != null ? newCase.Reopen_Count__c + 1 : 1;
                    }
                    
                    else if(status == 'Closed'){
                        if(newSLA.OneCare_Closed_Time__c == null){
                            newSLA.OneCare_Closed_Time__c = System.now();
                            newSLA.onecare_status__c = 'Closed';
                            system.debug('update close time');
                            if(eachStatusSla.OneCare_New_Open_Time__c != null)
                           		newSLA.OneCare_Closed_BH__c = getDurationbetween(newSLA.OneCare_Closed_Time__c, eachStatusSla.OneCare_New_Open_Time__c ,payuOnecareChildBHId);
                        }
                    }
                    
                    else if(status == 'Comment'){
                        if(newSLA.OneCare_First_Comment_Time__c == null){
                            newSLA.OneCare_First_Comment_Time__c = system.now();
                        }
                    }
                    
                    else if(status == 'Pending'){
                        if(eachStatusSla.Reopen_Count__c != null && eachStatusSla.Reopen_Count__c > 0 ){
                            if(newSLA.Reopen_Pending_Time__c  == Null){
                                newSLA.Reopen_Pending_Time__c  = system.now();
                                newSLA.onecare_status__c  = 'Pending';
                                system.debug('newCase.LP_Sub_Status__c::'+newCase.LP_Sub_Status__c);
                                if(newCase.LP_Sub_Status__c != null){
                                    newSLA.onecare_sub_status__c =  newCase.LP_Sub_Status__c;
                                    if(newCase.LP_Sub_Status__c == 'Waiting On Merchant' || newCase.LP_Sub_Status__c  == 'Waiting On Buyer' || newCase.LP_Sub_Status__c  == 'Waiting On Bank(Bank Support)'){
                                        newSLA.Open_Pending_Merchant_Buyer_Count__c = eachStatusSla.Open_Pending_Merchant_Buyer_Count__c != null ? 
                                            (eachStatusSla.Open_Pending_Merchant_Buyer_Count__c + 1) : 1;
                                    }
                                }
                                
                                
                                //first reopen-pending BH
                                if(eachStatusSla.Reopen_Pending_BH__c == null){
                                    if(onecareLobList.contains(newCase.LOB_Name__c))
                                        newSLA.Reopen_Pending_BH__c = eachStatusSla.OneCare_Resolved_Reopen_Time__c != null ? getDurationbetween(newSLA.Reopen_Pending_Time__c, eachStatusSla.OneCare_Resolved_Reopen_Time__c,onecareBHId) : newSLA.Reopen_Pending_BH__c;
                                    else
                                        newSLA.Reopen_Pending_BH__c = eachStatusSla.OneCare_Resolved_Reopen_Time__c != null ? getDurationbetween(newSLA.Reopen_Pending_Time__c, eachStatusSla.OneCare_Resolved_Reopen_Time__c,payuOnecareChildBHId) : newSLA.Reopen_Pending_BH__c;
                                }
                                //Cumulative reopen-pending BH
                                else{
                                    if(onecareLobList.contains(newCase.LOB_Name__c)){
                                        if(eachStatusSla.Reopen_Response_Received_Time__c != null)
                                        	newSLA.Reopen_Pending_BH__c = eachStatusSla.Reopen_Pending_BH__c + getDurationbetween(newSLA.Reopen_Pending_Time__c,eachStatusSla.Reopen_Response_Received_Time__c,onecareBHId);
                                    }else{
                                        if(eachStatusSla.Reopen_Response_Received_Time__c != null)
                                        	newSLA.Reopen_Pending_BH__c = eachStatusSla.Reopen_Pending_BH__c + getDurationbetween(newSLA.Reopen_Pending_Time__c,eachStatusSla.Reopen_Response_Received_Time__c,payuOnecareChildBHId);
                                    }
                                }
                            }
                        }
                        else{
                            if(newSLA.Pending_Time__c  == null){
                                newSLA.Pending_Time__c  = system.now();
                                newSLA.onecare_status__c  = 'Pending';
                                system.debug('newCase.LP_Sub_Status__c::'+newCase.LP_Sub_Status__c);
                                if(newCase.LP_Sub_Status__c != null){
                                    newSLA.onecare_sub_status__c =  newCase.LP_Sub_Status__c;
                                    if(newCase.LP_Sub_Status__c == 'Waiting On Merchant' || newCase.LP_Sub_Status__c  == 'Waiting On Buyer' || newCase.LP_Sub_Status__c  == 'Waiting On Bank(Bank Support)'){
                                        newSLA.Open_Pending_Merchant_Buyer_Count__c = eachStatusSla.Open_Pending_Merchant_Buyer_Count__c != null ? 
                                            (eachStatusSla.Open_Pending_Merchant_Buyer_Count__c + 1) : 1;
                                    }
                                }
                                //first open-pending BH
                                if(eachStatusSla.Open_Pending_BH__c == null){
                                    if(onecareLobList.contains(newCase.LOB_Name__c))
                                        newSLA.Open_Pending_BH__c = eachStatusSla.OneCare_New_Open_Time__c != null ? getDurationbetween(newSLA.Pending_Time__c, eachStatusSla.OneCare_New_Open_Time__c,onecareBHId) : newSLA.Open_Pending_BH__c;
                                    else
                                        newSLA.Open_Pending_BH__c = eachStatusSla.OneCare_New_Open_Time__c != null ? getDurationbetween(newSLA.Pending_Time__c, eachStatusSla.OneCare_New_Open_Time__c,payuOnecareChildBHId) : newSLA.Open_Pending_BH__c;
                                }
                                //Cumulative open-pending BH
                                else{
                                    if(onecareLobList.contains(newCase.LOB_Name__c)){
                                        if(eachStatusSla.Response_Received_Time__c != null) 
                                            newSLA.Open_Pending_BH__c = eachStatusSla.Open_Pending_BH__c + getDurationbetween(newSLA.Pending_Time__c,eachStatusSla.Response_Received_Time__c,onecareBHId);
                                    }
                                        
                                    else{
                                        if(eachStatusSla.Response_Received_Time__c != null) 
                                            newSLA.Open_Pending_BH__c = eachStatusSla.Open_Pending_BH__c + getDurationbetween(newSLA.Pending_Time__c,eachStatusSla.Response_Received_Time__c,payuOnecareChildBHId);                                               
                                    }
                                        
                                }
                            }
                            
                        }
                        if(waitingonMerchantBuyerSubStatuses.contains(newCase.LP_Sub_Status__c) ){
                            if(newCase.Reopen_Count__c != null && newCase.Reopen_Count__c > 0 ){
                                newCase.Reopen_Pending_Time__c  = system.now();
                                //first reopen-pending BH
                                if(newCase.Reopen_Pending_BH__c == null){
                                    if(onecareLobList.contains(newCase.LOB_Name__c))
                                        newCase.Reopen_Pending_BH__c = newCase.Reopen_Time__c != null ? getDurationbetween(newCase.Reopen_Pending_Time__c, newCase.Reopen_Time__c,onecareBHId) : newCase.Reopen_Pending_BH__c;
                                    else
                                        newCase.Reopen_Pending_BH__c = newCase.Reopen_Time__c != null ? getDurationbetween(newCase.Reopen_Pending_Time__c, newCase.Reopen_Time__c,payuOnecareChildBHId) : newCase.Reopen_Pending_BH__c;
                                }
                                //Cumulative reopen-pending BH
                                else{
                                    if(onecareLobList.contains(newCase.LOB_Name__c)){
                                        if(newCase.Reopen_Response_Received_Time__c != null)
                                        newCase.Reopen_Pending_BH__c = newCase.Reopen_Pending_BH__c +  getDurationbetween(newCase.Reopen_Pending_Time__c,newCase.Reopen_Response_Received_Time__c,onecareBHId);
                                    }else{
                                        if(newCase.Reopen_Response_Received_Time__c != null)
                                        newCase.Reopen_Pending_BH__c = newCase.Reopen_Pending_BH__c + getDurationbetween(newCase.Reopen_Pending_Time__c,newCase.Reopen_Response_Received_Time__c,payuOnecareChildBHId);
                                    }
                                }
                            }
                            else{
                                //if(newCase.Pending_Time__c  == null){
                                newCase.Pending_Time__c  = system.now();
                                
                                //first open-pending BH
                                if(newCase.Open_Pending_BH__c == null){
                                    if(onecareLobList.contains(newCase.LOB_Name__c))
                                        newCase.Open_Pending_BH__c = newCase.New_Open_Time__c != null ? getDurationbetween(newCase.Pending_Time__c, newCase.New_Open_Time__c,onecareBHId) : newCase.Open_Pending_BH__c;
                                    else
                                        newCase.Open_Pending_BH__c = newCase.New_Open_Time__c != null ? getDurationbetween(newCase.Pending_Time__c, newCase.New_Open_Time__c,payuOnecareChildBHId) : newCase.Open_Pending_BH__c;
                                }
                                //Cumulative open-pending BH
                                else{
                                    if(onecareLobList.contains(newCase.LOB_Name__c)){
                                        if(newCase.Response_Received_Time__c != null)
                                        	newCase.Open_Pending_BH__c = newCase.Open_Pending_BH__c + getDurationbetween(newCase.Pending_Time__c,newCase.Response_Received_Time__c,onecareBHId);
                                    }else{
                                        if(newCase.Response_Received_Time__c != null )
                                        	newCase.Open_Pending_BH__c = newCase.Open_Pending_BH__c + getDurationbetween(newCase.Pending_Time__c,newCase.Response_Received_Time__c,payuOnecareChildBHId);
                                    }
                                }
                                //}
                                
                            }
                        }
                    }
                    
                    else if(status == 'Response received' || status == 'Response received from buyer' || status == 'Response received from merchant' || status == 'No Resolution From Other Teams' || status == 'Response Received from Other Teams'){
                        if(newSLA.Reopen_Response_Received_Time__c == null && eachStatusSla.Reopen_Count__c != null && eachStatusSla.Reopen_Count__c > 0){
                            newSLA.Reopen_Response_Received_Time__c = system.now();
                            newSLA.onecare_status__c  = status;
                            system.debug('newCase.LP_Sub_Status__c::'+newCase.LP_Sub_Status__c);
                            newSLA.onecare_sub_status__c = '';
                        }
                        else{
                            if(newSLA.Response_Received_Time__c  == null){
                                newSLA.Response_Received_Time__c  = system.now();
                                newSLA.onecare_status__c  = status;
                                system.debug('newCase.LP_Sub_Status__c::'+newCase.LP_Sub_Status__c);
                                newSLA.onecare_sub_status__c = '';
                            }
                        }
                        
                        if(status == 'Response received' || status == 'Response received from buyer' || status == 'Response received from merchant'){
                            //newCase.Reopen_Response_Received_Time__c == null
                            if( newCase.Reopen_Count__c != null && newCase.Reopen_Count__c > 0){
                                newCase.Reopen_Response_Received_Time__c = system.now();
                            }
                            else{
                                newCase.Response_Received_Time__c  = system.now();
                            } 
                        }
                        
                    }
                    
                    return newSLA;
                }
            }
        }
            
        }
        catch(Exception ex){
            Error_Details__c erDetail = oneCareProcessHandler.getExceptions(ex,'update new SLA');
            insert erDetail;
        }
        return null;
    }
    
}