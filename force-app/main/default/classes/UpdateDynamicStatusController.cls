public class UpdateDynamicStatusController {
    /*Method to update status*/
    @AuraEnabled
    public static string updateSelectedStatus(string preRiskHoldReason, string riskHoldReasonEmailContent,
                                              string preRiskReasonEmailContent, string objectName, string recordId, 
                                              string field, string value, string riskHoldReason){
                                                  
                                                  try{
                                                      system.debug('recordID=='+recordId);            
                                                      User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c,Is_Doc_Status_Update_Allow__c From 
                                                                      User where Id =: UserInfo.getUserId() LIMIT 1];
                                                      sObject sObjectToUpsert = Database.query('SELECT Id, '+field+' from '+objectName+ ' Where Id=:recordId LIMIT 1');
                                                      system.debug('sObjectToUpsert==='+sObjectToUpsert);
                                                      if(sObjectToUpsert != null){
                                                          sObjectToUpsert.put(field,value);  
                                                          //sObjectToUpsert.put('Settlement_Status__c',value);
                                                          if(value == 'Risk Hold') {
                                                              sObjectToUpsert.put('Risk_Hold_Reasons__c',riskHoldReason); 
                                                              sObjectToUpsert.put('Risk_Hold_Reason_Email_Content__c',riskHoldReasonEmailContent); 	
                                                          } else if(value == 'Pre-Risk Hold') {
                                                              sObjectToUpsert.put('Pre_Risk_Hold_Reason__c',preRiskHoldReason);//SFI-404- Added by Pooja
                                                              sObjectToUpsert.put('Pre_Risk_Hold_Reason_Email_Content__c',preRiskReasonEmailContent);//SFI-404
                                                          } else if(value == 'OB Hold') {
                                                              sObjectToUpsert.put('OB_Hold_Reasons__c',riskHoldReason);//SFI-404- Added by Pooja
                                                              sObjectToUpsert.put('OB_Hold_Reason_Email_Content__c',riskHoldReasonEmailContent);//SFI-404
                                                          }
                                                          //sObjectToUpsert.put('Pre_Risk_Sub_Codes__c',preRiskSubCodes);
                                                          system.debug('sObjectToUpsert==='+sObjectToUpsert);
                                                          update sObjectToUpsert;
                                                          return 'Status updated successfully.';
                                                          
                                                      }
                                                      else{
                                                          return 'Status not updated.';
                                                      }   
                                                  }catch(Exception ex){
                                                      return 'Line No.-'+ex.getLineNumber() + ' Message-'+ex.getMessage();
                                                  }      
                                              }
    /*method to get RiskHoldReason field options*/
    @AuraEnabled
    public static Map<String,string> getRiskHoldReason(){
        Map<String,string> options = new Map<String,string>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Risk_Hold_Reasons__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        system.debug('fieldResult=='+fieldResult);
        for (Schema.PicklistEntry f: ple) {            
            options.put(f.getValue(),f.getLabel());
        }       
        return options;
    }
    //SFI-404--Added by Pooja Method to get PreRiskHoldReason field options
    @AuraEnabled
    public static Map<String,string> getPreRiskHoldReason(){
        Map<String,string> options = new Map<String,string>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Pre_Risk_Hold_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        system.debug('fieldResult=='+fieldResult);
        for (Schema.PicklistEntry f: ple) {            
            options.put(f.getValue(),f.getLabel());
        }       
        return options;
    }
    
    // Yash Lokwani-changes for rename to Post-Risk
    @AuraEnabled
    public static Map<String,string> getOBHoldReason(){
        Map<String,string> options = new Map<String,string>();
        Schema.DescribeFieldResult fieldResult = Opportunity.OB_Hold_Reasons__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        system.debug('fieldResult=='+fieldResult);
        for (Schema.PicklistEntry f: ple) {            
            options.put(f.getValue(),f.getLabel());
        }       
        return options;
    }
    
    //Ended By Pooja
    
    //Comeneted code for Pre-risk Sub Codes
    /* @AuraEnabled
public static Map<String,string> getPreRiskSubCodes(){
Map<String,string> options = new Map<String,string>();
Schema.DescribeFieldResult fieldResult = Opportunity.Pre_Risk_Sub_Codes__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
system.debug('fieldResult=='+fieldResult);
for (Schema.PicklistEntry f: ple) {            
options.put(f.getValue(),f.getLabel());
}       
return options;
}*/
    //Ended | Comeneted code for Pre-risk Sub Codes
    
    /*Method to check logged in user is Risk Operations user or not*/
    @AuraEnabled
    public static boolean getRiskHoldAccess()
    {	
        boolean isRiskHoldEditable=false;
        User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c,Is_Doc_Status_Update_Allow__c From User 
                        where Id =: UserInfo.getUserId() LIMIT 1];		
        //isRiskHoldEditable=Schema.sObjectType.Opportunity.fields.Risk_Hold_Reasons__c.isUpdateable() ? true : false;
        if(userObj.Profile.Name=='Risk Operations User'|| userObj.Profile.Name=='System Administrator'){  
            isRiskHoldEditable=true;             
        }
        else{
            isRiskHoldEditable=false;
        }
        system.debug('isRiskHoldEditable===='+isRiskHoldEditable);
        return isRiskHoldEditable; 
        
    } 
    
    @AuraEnabled
    public static List<String> getSettlementStatusPicklist(Id recordId){
        List<String> values = new List<String>();
        User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c,Is_Doc_Status_Update_Allow__c From User 
                        where Id =: UserInfo.getUserId() LIMIT 1];
        if(Label.SuperUser_Access_for_Holds.contains(UserInfo.getUserId()) && !Test.isRunningTest()){  
            return new List<String>{'Active', 'OB Hold', 'Risk Hold', 'Pre-Risk Hold'};                
                }
        Opportunity opp = [Select Id, Settlement_Status__c From Opportunity Where Id = :recordId LIMIT 1];
        if(opp.Settlement_Status__c == 'Active') {
            if(Label.Hold_Users_For_OB.contains(UserInfo.getUserId())) {
                values.add('OB Hold');
            }
            if(Label.Hold_Users_For_Post_risk.contains(UserInfo.getUserId())) {
                values.add('Risk Hold');
            }
            if(Label.Hold_Users_For_Pre_risk.contains(UserInfo.getUserId())) {
                values.add('Pre-Risk Hold');
            }
        } else if(opp.Settlement_Status__c == 'Thirdparty Hold') {
            if(Label.Hold_Users_TP_to_Post_risk.contains(UserInfo.getUserId())) {
                values.add('Risk Hold');
            }
            if(Label.Hold_Users_TP_to_Pre_risk.contains(UserInfo.getUserId())) {
                values.add('Pre-Risk Hold');
            }
        } else if(opp == null || String.IsBlank(opp.Settlement_Status__c)) {
            if(Label.Hold_Users_For_OB.contains(UserInfo.getUserId())) {
                values.add('OB Hold');
            }
            if(Label.Hold_Users_For_Post_risk.contains(UserInfo.getUserId())) {
                values.add('Risk Hold');
            }
            if(Label.Hold_Users_For_Pre_risk.contains(UserInfo.getUserId())) {
                values.add('Pre-Risk Hold');
            }
        } else if(opp.Settlement_Status__c == 'OB Hold' && Label.Hold_Users_From_OB.contains(UserInfo.getUserId())) {
            values.add('Active');
            // Integer index = values.indexOf('OB Hold');
            // if (index > -1) { 
            //     values.remove(index); 
            // }
        } else if(opp.Settlement_Status__c == 'Pre-Risk Hold' && Label.Hold_Users_From_Pre_risk.contains(UserInfo.getUserId())) {
            values.add('Active');
            // Integer index = values.indexOf('Pre-risk Hold');
            // if (index > -1) { 
            //     values.remove(index); 
            // }
        } else if(opp.Settlement_Status__c == 'Risk Hold' && Label.Hold_Users_From_Post_risk.contains(UserInfo.getUserId())) {
            values.add('Active');
            // Integer index = values.indexOf('Risk Hold');
            // if (index > -1) { 
            //     values.remove(index); 
            // }
        }
        
        return values;
    }
    
    //This method to fetch risk hold related Email content
    @AuraEnabled
    public static string getRiskHoldContent(string riskHoldReason)
    {
        Map<string,string> riskHoldReasonEmailContentMap=new Map<string,string>();
        for(Risk_Hold_Reason_Email_Content__mdt obj:[SELECT Id,	Risk_Hold_Reason__c,Risk_Hold_Reason_Communication__c 
                                                     FROM Risk_Hold_Reason_Email_Content__mdt where Risk_Hold_Reason__c=:riskHoldReason])
        {
            riskHoldReasonEmailContentMap.put(obj.Risk_Hold_Reason__c,obj.Risk_Hold_Reason_Communication__c);
        }
        if(riskHoldReasonEmailContentMap.containsKey(riskHoldReason))
        {
            return riskHoldReasonEmailContentMap.get(riskHoldReason);
        }
        else
        {
            
            return null;
        }
    }
    
    //End
    
    //SFI-404--Added By Pooja This method to fetch Pre Risk Hold Reason Email content
    @AuraEnabled
    public static string getPreRiskHoldEmailContent(string preRiskHoldReason)
    {
        Map<string,string> preRiskHoldReasonEmailContentMap=new Map<string,string>();
        for(Pre_Risk_Hold_Reason_Email_Content__mdt obj:[SELECT Id,	Pre_Risk_Hold_Reason__c,Pre_Risk_Hold_Reason_Communication__c 
                                                         FROM Pre_Risk_Hold_Reason_Email_Content__mdt where Pre_Risk_Hold_Reason__c=:preRiskHoldReason])
        {
            preRiskHoldReasonEmailContentMap.put(obj.Pre_Risk_Hold_Reason__c,obj.Pre_Risk_Hold_Reason_Communication__c);
        }
        if(preRiskHoldReasonEmailContentMap.containsKey(preRiskHoldReason))
        {
            return preRiskHoldReasonEmailContentMap.get(preRiskHoldReason);
        }
        else
        {
            
            return null;
        }
    }
    
    //Ended by Pooja
    
    /** Added by Rahul for SFI-873 */
    @AuraEnabled
    public static PostHoldWrapper getRiskStatusDetail(String mcareCaseId){
        PostHoldWrapper wrp = new PostHoldWrapper();
        try {
            
            List<MCare_Dashboard_Case__c> mcareList = [SELECT Id,Opportunity__c FROM MCare_Dashboard_Case__c 
                                                       WHERE Id = :mcareCaseId AND Opportunity__c !=null LIMIT 1];
            
            if(!mcareList.isEmpty()){
                
                List<Risk_status_Detail__c> riskStatusList = [SELECT Id,Opportunity__c,Current_Status__c,Enforced_By__c,Investigation_findings__c  FROM Risk_status_Detail__c 
                                                              WHERE Opportunity__c = :mcareList[0].Opportunity__c AND RecordType.Name = 'Post Risk'];
                
                if(!riskStatusList.isEmpty()){
                    wrp.currStatus = riskStatusList[0].Current_Status__c;
                    wrp.oppId = riskStatusList[0].Opportunity__c;
                    wrp.postRiskId = riskStatusList[0].Id;
                    wrp.mcareCaseId = mcareList[0].Id;
                    
                }else{
                    
                    wrp.oppId = mcareList[0].Opportunity__c;
                    
                     // Use Describe API to get RecordTypeIds
            Schema.DescribeSObjectResult dsr = Risk_status_Detail__c.SObjectType.getDescribe();
            Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = dsr.getRecordTypeInfosByName();

           
            // Create 'Post Risk', 'Ob Risk', and 'Pre Risk' records using obtained RecordTypeIds
            Risk_status_Detail__c postRiskRecord = new Risk_status_Detail__c(
                Opportunity__c = wrp.oppId,
                RecordTypeId = recordTypeInfoMap.get('Post Risk').getRecordTypeId(),
                Hold_Type__c = 'Post Hold', 
                Current_Status__c = 'Not on Hold'
            );
            
            Risk_status_Detail__c obRiskRecord = new Risk_status_Detail__c(
                Opportunity__c = wrp.oppId,
                RecordTypeId = recordTypeInfoMap.get('Ob Risk').getRecordTypeId(),
                Hold_Type__c = 'OB Hold', 
                Current_Status__c = 'Not on Hold'
            );
            
            Risk_status_Detail__c preRiskRecord = new Risk_status_Detail__c(
                Opportunity__c = wrp.oppId,
                RecordTypeId =  recordTypeInfoMap.get('Pre Risk').getRecordTypeId(),
                Hold_Type__c = 'Pre Hold', 
                Current_Status__c = 'Not on Hold'
            );

            // Insert records
            insert new List<Risk_status_Detail__c> { postRiskRecord, obRiskRecord, preRiskRecord };
                        
            // Assigning IDs to wrapper
            wrp.obRiskId = obRiskRecord.Id;
            wrp.preRiskId = preRiskRecord.Id;
            wrp.postRiskId = postRiskRecord.Id;
        }
                wrp.enforcedBy = System.UserInfo.getUserId();
            }else{
                wrp.msg = 'Mcare Case is not linked with any MID.';
            }
        } catch (Exception e) {
            wrp.msg = e.getMessage();
            
        }
        return wrp;
    }
    /***** Added by Rahul for SFI-873***/
    
    /********* Method to update on mcare dashboard ********/
    @AuraEnabled
    public static void mcareCaseUpdate(String mcareCaseId,String reason,String comment,String investigation){
        
        MCare_Dashboard_Case__c mCareObj =new MCare_Dashboard_Case__c();
        mCareObj.Risk_Hold_Reason__c = reason;
        mCareObj.Comments_By_Enforcer__c = comment;
        mCareObj.Investigation_findings__c = investigation;
        mCareObj.Status__c = 'Risk Hold';
        mCareObj.Id = mcareCaseId;
        update mCareObj;
        
    }
    /** Added by Rahul for SFI-873 */
    public class PostHoldWrapper{
        @AuraEnabled 
        public String oppId = '';
        @AuraEnabled 
        public String postRiskId = '';
        @AuraEnabled 
        public String obRiskId = '';
        @AuraEnabled 
        public String preRiskId = ''; 
        @AuraEnabled 
        public String currStatus = '';
        @AuraEnabled 
        public String mcareCaseId = '';
        @AuraEnabled 
        public String msg = 'Success';
        @AuraEnabled 
        public String enforcedBy = '';
    }
    
}