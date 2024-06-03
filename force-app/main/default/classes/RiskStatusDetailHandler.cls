public with sharing class RiskStatusDetailHandler {
   	public static Id postTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
    public static Id obTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Ob Risk').getRecordTypeId();
    public static Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();
    
    public Static void beforeUpdatePopulateUserAndDate(List<Risk_status_Detail__c> newList, Map<Id,Risk_status_Detail__c> oldMap){
        for (Risk_status_Detail__c rsd : newList) {
             // Set the Unique_Identifier__c
               rsd.Unique_Identifier__c = rsd.Hold_Type__c + '@@' + rsd.Opportunity__c;//added by rahul (SFI-871)
    
            if(rsd.Current_Status__c != oldMap.get(rsd.Id).Current_Status__c){
                
                
                if (rsd.Current_Status__c == 'On Hold') {
                    if(!System.isBatch()){
                        rsd.Enforced_By__c = System.UserInfo.getUserId();
                    }
                   // rsd.Enforced_By__c = System.UserInfo.getUserId();//remove due to SFI-871 to update enforced by from Risk_statusDetailsBatch
                    rsd.Enforced_Date__c = System.now();
                    
                     // Set Release fields to null
                    rsd.Released_By__c = null;
                    rsd.Release_Date__c = null;
                    rsd.Release_Comment__c = null; 
                }
                else if (rsd.Current_Status__c == 'Not On Hold') {
                    rsd.Released_By__c = System.UserInfo.getUserId();
                    rsd.Release_Date__c = System.now();
                    
                    // Set Enforce fields to null
                    rsd.Enforced_By__c = null;
                    rsd.Enforced_Date__c = null;
                    rsd.Comments_By_Enforcer__c = null;
                    rsd.Risk_Hold_Reason__c = null;
                    rsd.Risk_Hold_Reason_Email_Content__c = null;
                }
            }
           
        }
    }
    
      public Static void beforeInsertHandler(List<Risk_status_Detail__c> newList){
        for (Risk_status_Detail__c rsd : newList) {
             // Set the Unique_Identifier__c
               rsd.Unique_Identifier__c = rsd.Hold_Type__c + '@@' + rsd.Opportunity__c;//added by rahul (SFI-871)
        }
      }
    public Static void afterInsertUpdateSettlementStatus( List<Risk_status_Detail__c> newList){
        
      	 updateRiskHoldFieldsInOpp(newList);
        
    }
	
    
    
    public Static void updateRiskHoldFieldsInOpp(List<Risk_status_Detail__c> newList){
		List<Id> lstOppId = new List<Id>();
        List<Opportunity> updateSettlementStatus = new List<Opportunity>();
        Map<Id,List<Risk_status_Detail__c>>  mapOppIdVSRiskRecord = new Map<Id,List<Risk_status_Detail__c>>();
       
        
        for (Risk_status_Detail__c rsd : newList) {
            lstOppId.add(rsd.Opportunity__c);
        }
        
            List<Risk_status_Detail__c> resultList = [SELECT Id, RecordTypeId, Current_Status__c,Opportunity__c,Opportunity__r.Settlement_Status__c,
                                                      Risk_Hold_Reason__c,Enforced_By__c,Enforced_Date__c,Released_By__c,
                                                        Release_Date__c,Risk_Hold_Reason_Email_Content__c,Investigation_findings__c 
                                                        FROM Risk_status_Detail__c
                                                        WHERE Opportunity__c IN : lstOppId ORDER By Opportunity__c] ;   // LIMIT 3
            if (resultList.size()>0) {
                for (Risk_status_Detail__c rs : resultList) {
                    if (!mapOppIdVSRiskRecord.containsKey(rs.Opportunity__c)) {
                        List<Risk_status_Detail__c> lstrs = new List<Risk_status_Detail__c>();
                        lstrs.add(rs);
                        mapOppIdVSRiskRecord.put(rs.Opportunity__c, lstrs);
                    }else {
                        mapOppIdVSRiskRecord.get(rs.Opportunity__c).add(rs);
                    }
                }
                
            } 
        if (mapOppIdVSRiskRecord.size()>0) {
            for (Id oppId : mapOppIdVSRiskRecord.keySet()) {
               
                Opportunity opp = new Opportunity();
               
                for (Risk_status_Detail__c rs : mapOppIdVSRiskRecord.get(oppId)) {
                    if (postTypeId == rs.RecordTypeId) {
                        opp.Id = rs.Opportunity__c;
                        if (rs.Current_Status__c == 'On Hold') {
                            opp.On_Post_Risk_Hold__c = 'Y';
                            opp.Risk_Hold_Reasons__c =rs.Risk_Hold_Reason__c;
                           	opp.Risk_Hold_Reason_Email_Content__c = rs.Risk_Hold_Reason_Email_Content__c;
                            opp.Investigation_findings__c  = rs.Investigation_findings__c;//added by rahul, SFI-1300

                            
                        }else {
                            opp.On_Post_Risk_Hold__c = 'N';
                            opp.Risk_Hold_Reasons__c = null;
                            opp.Settlement_Amount_on_Hold__c = 0;// added by rohit
                            opp.Risk_Hold_Reason_Email_Content__c = null;//added by saksham (SFI-800)
                            
                        }
                         
                    }
                    if (obTypeId == rs.RecordTypeId) {
                        opp.Id = rs.Opportunity__c;
                        if (rs.Current_Status__c == 'On Hold') {
                            opp.On_OB_Hold__c = 'Y';
                            opp.OB_Hold_Reasons__c =rs.Risk_Hold_Reason__c;
                            opp.OB_Hold_Reason_Email_Content__c = rs.Risk_Hold_Reason_Email_Content__c;// added by saksham (SFI-800)
                        }else {
                            opp.On_OB_Hold__c = 'N';
                            opp.OB_Hold_Reasons__c = null;
                            opp.Settlement_Amount_on_Hold__c = 0;// added by rohit
                            opp.OB_Hold_Reason_Email_Content__c = null; // added by saksham (SFI-800)
                            
                        }
                         
                    }
                    if (preTypeId == rs.RecordTypeId) {
                        opp.Id = rs.Opportunity__c;
                        if (rs.Current_Status__c == 'On Hold') {
                            opp.On_Pre_Risk_Hold__c = 'Y';
                            opp.Pre_Risk_Hold_Reason__c =rs.Risk_Hold_Reason__c;
                            opp.Pre_Risk_Hold_Reason_Email_Content__c = rs.Risk_Hold_Reason_Email_Content__c;// added by saksham (SFI-800)
                        }else {
                            opp.On_Pre_Risk_Hold__c = 'N';
                            opp.Pre_Risk_Hold_Reason__c = null;
                            opp.Settlement_Amount_on_Hold__c = 0;// added by rohit
                            opp.Pre_Risk_Hold_Reason_Email_Content__c = null;// added by saksham (SFI-800)
                            
                        }
                    }
                  
                }
                  
                   // Added by Pooja//
                   If(opp?.Id != null){
                    updateSettlementStatus.add(opp);
                   }
                  // Added by Pooja//
                
                 System.debug('updateSettlementStatus'+updateSettlementStatus);
            }  
        }    
        
        if (updateSettlementStatus.size()>0) {
            update updateSettlementStatus;
         }        
    }

}