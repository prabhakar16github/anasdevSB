public class UpdateVariousHoldsToRiskHoldBatch implements Database.Batchable<sObject>{
	public static Id postTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
    public static Id obTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Ob Risk').getRecordTypeId();
    public static Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();
    public static String postRiskHold = 'Risk Hold';
    public static String obRiskHold = 'OB Hold';
    public static String preRiskHold = 'Pre-Risk Hold';
    public static String riskandThirdPartyHold = 'Risk & Thirdparty hold';
    
    private String status;
    
    public UpdateVariousHoldsToRiskHoldBatch(String statusName){
			this.status = statusName;        
    }
     public Database.QueryLocator start(Database.BatchableContext bc) {
        
         String query = 'SELECT Id,Name,Settlement_Status__c,Risk_Hold_Reasons__c ,Pre_Risk_Hold_Reason__c,OB_Hold_Reasons__c,On_Post_Risk_Hold__c, On_Pre_Risk_Hold__c,On_OB_Hold__c FROM opportunity WHERE Settlement_Status__c =:status';
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext bc, List<opportunity> oppList){
      //updateRSDAndOPP(oppList);
        
       
    }
    public void finish(Database.BatchableContext bc){
       
    }
    
    private void updateRSDAndOPP(List<Opportunity> lstOpp){
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<Risk_status_Detail__c> insertRSDList = new List<Risk_status_Detail__c>();
        for(Opportunity opp : lstOpp){
         Risk_status_Detail__c rsdPost = new Risk_status_Detail__c();
         Risk_status_Detail__c rsdOb = new Risk_status_Detail__c();
         Risk_status_Detail__c rsdPre = new Risk_status_Detail__c();
            if(opp.Settlement_Status__c == postRiskHold || opp.Settlement_Status__c == riskandThirdPartyHold){
                rsdPost.Opportunity__c = opp.Id;
                rsdPost.RecordTypeId = postTypeId;
                rsdPost.Current_Status__c = 'On Hold';
                rsdPost.Risk_Hold_Reason__c = (opp.Risk_Hold_Reasons__c != null) ? opp.Risk_Hold_Reasons__c : 'Legacy Hold';
                insertRSDList.add(rsdPost);
                
                rsdOb.Opportunity__c = opp.Id;
                rsdOb.RecordTypeId = obTypeId;
                rsdOb.Current_Status__c ='Not On Hold';
                insertRSDList.add(rsdOb);
                
                rsdPre.Opportunity__c = opp.Id;
                rsdPre.RecordTypeId = preTypeId;
                rsdPre.Current_Status__c = 'Not On Hold';
                insertRSDList.add(rsdPre);
                
                opp.On_Post_Risk_Hold__c = 'Y';
                opp.On_OB_Hold__c = 'N';
                opp.On_Pre_Risk_Hold__c = 'N';
                opp.Settlement_Status__c = 'Risk Hold';
                
                updateOppList.add(opp);
              }else if(opp.Settlement_Status__c == obRiskHold){
                rsdPost.Opportunity__c = opp.Id;
                rsdPost.RecordTypeId = postTypeId;
                rsdPost.Current_Status__c = 'Not On Hold';
                insertRSDList.add(rsdPost);
               
                rsdOb.Opportunity__c = opp.Id;
                rsdOb.RecordTypeId = obTypeId;
                rsdOb.Current_Status__c ='On Hold';
                rsdOb.Risk_Hold_Reason__c = (opp.OB_Hold_Reasons__c != null) ? opp.OB_Hold_Reasons__c : 'Legacy Hold';
                insertRSDList.add(rsdOb);
                  
                rsdPre.Opportunity__c = opp.Id;  
                rsdPre.RecordTypeId = preTypeId;
                rsdPre.Current_Status__c = 'Not On Hold';
                insertRSDList.add(rsdPre);
                  
                opp.On_Post_Risk_Hold__c = 'N';
                opp.On_OB_Hold__c = 'Y';
                opp.On_Pre_Risk_Hold__c = 'N';
                opp.Settlement_Status__c = 'Risk Hold';
                updateOppList.add(opp);
              }else if(opp.Settlement_Status__c == preRiskHold){
                rsdPost.Opportunity__c = opp.Id;
                rsdPost.RecordTypeId = postTypeId;
                rsdPost.Current_Status__c = 'Not On Hold';
                insertRSDList.add(rsdPost);
                  
                rsdOb.Opportunity__c = opp.Id;  
                rsdOb.RecordTypeId = obTypeId;
                rsdOb.Current_Status__c ='Not On Hold';
                insertRSDList.add(rsdOb);
                  
                rsdPre.Opportunity__c = opp.Id;  
                rsdPre.RecordTypeId = preTypeId;
                rsdPre.Current_Status__c = 'On Hold';
                rsdPre.Risk_Hold_Reason__c = (opp.Pre_Risk_Hold_Reason__c != null) ? opp.Pre_Risk_Hold_Reason__c : 'Legacy Hold';
                insertRSDList.add(rsdPre);
                  
                opp.On_Post_Risk_Hold__c = 'N';
                opp.On_OB_Hold__c = 'N';
                opp.On_Pre_Risk_Hold__c = 'Y';
                opp.Settlement_Status__c = 'Risk Hold';
                updateOppList.add(opp);
              }
            
        }
        
        if(insertRSDList.size()>0){
            
            insert insertRSDList;
        }
        if(updateOppList.size()>0){
            update updateOppList;
        }

            
    }
}