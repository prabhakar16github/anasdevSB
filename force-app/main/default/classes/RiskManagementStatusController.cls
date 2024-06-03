global class RiskManagementStatusController {
	public static String pendingAmountValue = '';
	public static Id postTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Post Risk').getRecordTypeId();
    public static Id obTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Ob Risk').getRecordTypeId();
    public static Id preTypeId = Schema.SObjectType.Risk_status_Detail__c.getRecordTypeInfosByName().get('Pre Risk').getRecordTypeId();

    @AuraEnabled
    public static Map<Id,Risk_status_Detail__c> getRecordTypeIdAndStatus(Id oppId){
                Map<Id,Risk_status_Detail__c> listOfMerchantRec;

                List<Risk_status_Detail__c> listRiskStatusDetails = [SELECT Id, Hold_Type__c, Current_Status__c
                                                                            FROM Risk_status_Detail__c
                                                                            WHERE Opportunity__c = :oppId
                                                                            LIMIT 3];
                if (listRiskStatusDetails.size()>0) {
                    listOfMerchantRec = new Map<Id,Risk_status_Detail__c>(listRiskStatusDetails);
                    return listOfMerchantRec;
                }else {
                    List<Risk_status_Detail__c> lstNewObj = new List<Risk_status_Detail__c>();
                    lstNewObj.add(new Risk_status_Detail__c(Opportunity__c =oppId, RecordTypeId = postTypeId, Current_Status__c ='Not On Hold'));
                    lstNewObj.add(new Risk_status_Detail__c(Opportunity__c = oppId, RecordTypeId = obTypeId, Current_Status__c ='Not On Hold'));
                    lstNewObj.add(new Risk_status_Detail__c(Opportunity__c = oppId, RecordTypeId = preTypeId, Current_Status__c ='Not On Hold'));
                    insert lstNewObj;
                    List<Risk_status_Detail__c> afterInsert = [SELECT Id, Current_Status__c,Hold_Type__c
                                                                    FROM Risk_status_Detail__c
                                                                    WHERE Opportunity__c = :oppId
                                                                    LIMIT 3];
                   if (afterInsert.size()>0) {
                    listOfMerchantRec=new Map<Id,Risk_status_Detail__c>(afterInsert);
                    System.debug('mapof'+listOfMerchantRec);
                    return listOfMerchantRec;
                   }
                   return null;
                 }

    }
// to get the mcc code by rohit
    @AuraEnabled
    public static string getMccCodeMetaData(string mccCode,Id partner){
        string strmccCode='';
        try{
            List<MCC_code_Base_MID_Mapping__mdt> mccCodeRec=[select id,MCC_Code__c,Base_MID__c 
                                                             from MCC_code_Base_MID_Mapping__mdt where MCC_Code__c=:mccCode];
            //MCC code given and Partner not given in oppty
            if(string.isNotBlank(mccCode)&&partner==null){
                //when meta data exist based id related to given mcc code
                if(mccCodeRec.size()>0){
                    strmccCode=mccCodeRec[0].Base_MID__c;
                }
                else{//when meta data not having realted mcc code  poupulate base mid
                    strmccCode='8597556';
                }
            }
            else{
                
                //Mcc code given and partner also given in opty
                
                strmccCode='';
            }
            return strmcccode;    
        }catch(exception ex)
        {
            system.debug('check meta data values');
            return strmcccode;           
        }
        
    }
    // Ended by Rohit 
    /*@AuraEnabled
    public static Map<String,String> statusOfHoldType(Id oppId){
        GetPendingAmountForSettelement batch = new GetPendingAmountForSettelement(oppId, 50);// added bvy rohit
        Database.executeBatch(batch); // Added by rohit
        //PendingSettlementAount_Controller.updatePendingAmount(oppId);// Added by rohit
        Map<String,String> holdTypeStatus = new Map<String,String>();
        List<Risk_status_Detail__c> result= [SELECT  Hold_Type__c,Current_Status__c
                                                        FROM Risk_status_Detail__c
                                                        WHERE Opportunity__c = :oppId
                                                        LIMIT 3];
            if (result.size()>0) {
                for (Risk_status_Detail__c rsk : result) {
                    holdTypeStatus.put(rsk.Hold_Type__c,rsk.Current_Status__c);
                }
            }

        return holdTypeStatus;
    }*/
    
    @AuraEnabled
    public static Map<String,String> statusOfHoldType(Id oppId){
        Map<String,String> holdTypeStatus = new Map<String,String>();
        List<Risk_status_Detail__c> result= [SELECT  Hold_Type__c,Current_Status__c
                                                        FROM Risk_status_Detail__c
                                                        WHERE Opportunity__c = :oppId
                                                        LIMIT 3];
            if (result.size()>0) {
                for (Risk_status_Detail__c rsk : result) {
                    holdTypeStatus.put(rsk.Hold_Type__c,rsk.Current_Status__c);
                } 
            }
                                                        
        return holdTypeStatus;
    }
    @AuraEnabled(cacheable=true)
    public static User currentUserId(){
       return [SELECT Id FROM User where Id= :UserInfo.getUserId()];
    }
    @AuraEnabled(cacheable=true)
    public static List<Risk_status_Detail__History> postRiskHistory(Id oppId){
       return [SELECT Id, CreatedDate, Field, OldValue, NewValue FROM Risk_status_Detail__History where parent.RecordTypeId = :postTypeId  AND parent.Opportunity__c =:oppId AND Field NOT IN ('created')  order by createdDate desc];
    }
    @AuraEnabled(cacheable=true)
    public static List<Risk_status_Detail__History> obRiskHistory(Id oppId){
       return [SELECT Id, CreatedDate, Field, OldValue, NewValue FROM Risk_status_Detail__History where parent.RecordTypeId = :obTypeId AND parent.Opportunity__c =:oppId AND Field NOT IN ('created') order by createdDate desc];
    }
    @AuraEnabled(cacheable=true)
    public static List<Risk_status_Detail__History> preRiskHistory(Id oppId){
       return [SELECT Id, CreatedDate, Field, OldValue, NewValue FROM Risk_status_Detail__History where parent.RecordTypeId = :preTypeId AND parent.Opportunity__c =:oppId AND Field NOT IN ('created') order by createdDate desc];
    }
    @AuraEnabled
    public static list<Opportunity> websitePages(Id oppId){
            return [SELECT ID,MCC_Code__c,Base_Merchant_Id__c,BusinessEntityName__c,LOB_Rejection_Reason__c,
                    LOB_Approver_Risk_Team__c,LOB_Status__c	,LOB_Status_PreRisk__c,Max_Same_Day_Settlement_Amount__c,
                    Business_Category__c,SubCategory__c,Website__c,Pre_approved_for_EMI__c,Website_Status__c,
                    Pre_Approved_for_priority_settlement__c,Pre_approved_for_MCP__c,
                    (SELECT Id,Name,Group__c,Availability__c,Opportunity__c,Approval_Type__c,Pick_Risk_Remark__c,URL__c
                     FROM Website_Pages__r WHERE Active__c=True ) FROM Opportunity where Id =:oppId ];
        // Active__c=Trueadded by rohit
    }
    @AuraEnabled
    public static Map<String,String> getPicklistValues(){
        list<String> fieldApiNames = new list<String>{'Availability__c','Approval_Type__c','Pick_Risk_Remark__c'};
        Map<String,String> result = new Map<String,String>();
        for(String apiName:fieldApiNames){
            result.put(apiName,PicklistGenerator.getPicklistValues('Website_Page__c',apiName,'',false));
        }
        return result;
    }

    @AuraEnabled
    public static Map<String,String> getPicklistValuesOpp(){
        list<String> fieldApiNames = new list<String>{'Pre_approved_for_EMI__c','Pre_approved_for_MCP__c'};
        Map<String,String> result = new Map<String,String>();
        for(String apiName:fieldApiNames){
            result.put(apiName,PicklistGenerator.getPicklistValues('Opportunity',apiName,'',false));
        }
        return result;
    }

    @AuraEnabled
    public static Boolean saveWebpageRecords(String records){
        try {
            list<Website_Page__c> result = (list<Website_Page__c>)JSON.deserialize(records,list<Website_Page__c>.class);
            Database.update(result);
            Boolean isCallingFromWebsitePage = False;
            Integer varApproval = 0;
            Integer varPending = 0;
            Integer varRejection = 0;
            Set<Id> oppId = new Set<Id>();
            Set<Id> webPageId = new Set<Id>();
            for(Website_Page__c web : result){
                webPageId.add(web.Id);
                if(web.Approval_Type__c=='Approved'){
                    varApproval += 1;
                }
                else if(web.Approval_Type__c=='Rejection'){
                     varRejection += 1;
                }
                else{
                     varPending += 1;
                }
            }
            if(webPageId !=NULL){
                List<Website_Page__c> webPageList = [SELECT Id,Opportunity__c FROM Website_Page__c WHERE Id=:webPageId];
                List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id=:webPageList[0].Opportunity__c]; 
                if(varApproval == 10){
                    oppList[0].Website_Status__c  = 'Website OK';
                    isCallingFromWebsitePage = True;
                    update oppList;
                }
                else if(varRejection !=NULL && varRejection>0 ){  
                     oppList[0].Website_Status__c  = 'Website Error';
                     isCallingFromWebsitePage = True;
                     update oppList;
                }
                else{
                    oppList[0].Website_Status__c  = 'Verification in Process';
                    isCallingFromWebsitePage = True;
                    update oppList;
                }
                if(oppList.size()>0){// added by rohit for Ridsk Revamp
                    List<Website_Details__c> websiteDetailsUpdate = [SELECT Id,Website_Status__c FROM Website_Details__c WHERE Active__c=True AND Opportunity__c=:oppList[0].Id];
                    if(websiteDetailsUpdate.size()>0 ){
                        websiteDetailsUpdate[0].Website_Status__c = oppList[0].Website_Status__c;
                        update websiteDetailsUpdate;
                    }
                }
                return isCallingFromWebsitePage;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static list<opportunity> saveOppRecords(String records){
        try {
            /** Added for SFI-802 */
            List<Comments__c> listComment = new List<Comments__c>();
            /** */
            list<Opportunity> result = (list<Opportunity>)JSON.deserialize(records,list<Opportunity>.class);
            system.debug('result:::::::'+result);
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            // below for loop code written by rohit gupta
            for(Opportunity opp : result){

                /** Added for SFI-802 */
                Comments__c cm = new Comments__c();
                cm.Comment__c = opp.LOB_Comments_Last__c;
                cm.Opportunity__c = opp.Id;
                cm.Comment_By__c = 'Salesforce';
                cm.Commentable_Type__c = 'LOB_Conversation';
                cm.Active__c = true;
                listComment.add(cm);
                /** */
				System.debug('LOB_Status_PreRisk__c:::::::'+opp.LOB_Status_PreRisk__c);
                if(opp.LOB_Status_PreRisk__c == 'LOB Approved') {
                    opp.Website_Status__c = 'Website OK';
                } else if(opp.LOB_Status_PreRisk__c == 'LOB Rejected' || opp.LOB_Status_PreRisk__c == 'LOB Error' ) {
                    opp.Website_Status__c = 'Website Error';
                }else if(opp.LOB_Status_PreRisk__c == '') {
                    opp.Website_Status__c = 'Verification in Process';
                }
                oppListToUpdate.add(opp);
            }
            Database.update(oppListToUpdate);
            if(oppListToUpdate.size()>0){// added by rohit for Ridsk Revamp
                List<Website_Details__c> websiteDetailsUpdate = [SELECT Id,Website_Status__c FROM Website_Details__c WHERE Active__c=True AND Opportunity__c=:oppListToUpdate[0].Id];
                if(websiteDetailsUpdate.size()>0 ){
                    websiteDetailsUpdate[0].Website_Status__c = oppListToUpdate[0].Website_Status__c;
                    update websiteDetailsUpdate;
                }
            }
            SYstem.debug('oppListToUpdate::193::'+oppListToUpdate);
            /** Added for SFI-802 */
            if(!listComment.isEmpty()){
                insert listComment;
            }
            /** */
            //Database.update(result);
            return [SELECT ID,MCC_Code__c,Base_Merchant_Id__c,LOB_Status_PreRisk__c,Website_Status__c,BusinessEntityName__c,Max_Same_Day_Settlement_Amount__c,Business_Category__c,SubCategory__c,Website__c,Pre_approved_for_EMI__c,Pre_Approved_for_priority_settlement__c,Pre_approved_for_MCP__c,(SELECT Id,Name,Group__c,Availability__c,Approval_Type__c,Pick_Risk_Remark__c,URL__c FROM Website_Pages__r ) FROM Opportunity where Id =:oppListToUpdate[0].Id];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static list<Website_Page__c> websitepagegroup(Id oppId){
        try {
           // return [SELECT ID,MCC_Code__c,Base_Merchant_Id__c,BusinessEntityName__c,Max_Same_Day_Settlement_Amount__c,Business_Category__c,SubCategory__c,Website__c,Pre_approved_for_EMI__c,Pre_Approved_for_priority_settlement__c,Pre_approved_for_MCP__c,(SELECT Id,Name,Group__c,Sales_Remarks__c, Risk_Remarks__c	 FROM Website_Pages__r where Group__c!=null ) FROM Opportunity where Id =:oppId];
            return [SELECT ID,Name,Group__c,Pick_Risk_Remark__c,Risk_Comment__c,Sales_Comment__c,Sales_Remarks__c, Risk_Remarks__c FROM Website_Page__c where Group__c!=null AND Opportunity__c =:oppId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled // added byt rohit
    public static String currentWebsitepage(Id webPageId){
        try {
            System.debug('webPageId:::::'+webPageId);
            Website_Page__c web = [SELECT ID,Name,Group__c,Pick_Risk_Remark__c,Risk_Comment__c,Sales_Comment__c,Sales_Remarks__c, Risk_Remarks__c FROM Website_Page__c where Id=:webPageId];
           // return [SELECT ID,MCC_Code__c,Base_Merchant_Id__c,BusinessEntityName__c,Max_Same_Day_Settlement_Amount__c,Business_Category__c,SubCategory__c,Website__c,Pre_approved_for_EMI__c,Pre_Approved_for_priority_settlement__c,Pre_approved_for_MCP__c,(SELECT Id,Name,Group__c,Sales_Remarks__c, Risk_Remarks__c	 FROM Website_Pages__r where Group__c!=null ) FROM Opportunity where Id =:oppId];
            return web.Pick_Risk_Remark__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string updatewebsitepage(Object data){
        // List <Website_Page__c> accsForUpdate = ( List <Website_Page__c> ) JSON.deserialize(JSON.serialize( data ),List <Website_Page__c>.class);
        // try {
        //     update accsForUpdate;
        //     return 'Success: Account(s) updated successfully';
        // }
        // catch (Exception e) {
        //     return 'The following exception has occurred: ' + e.getMessage();
        // }
        System.debug('data'+data);
        List<Website_Page__c> contactsForUpdate = (List<Website_Page__c>) JSON.deserialize(
            (String)data,
            List<Website_Page__c>.class
       );
       try {
        system.debug(contactsForUpdate);
           update contactsForUpdate;  
           return 'Success: contacts updated successfully'; 
       }
       catch (Exception e) {
           return 'The following exception has occurred: ' + e.getMessage();
       }

    }
    @AuraEnabled
    public static string savewebsitepagerecord(Id oppId,string webgroup,string webname, string approvetype,string avaltype){
       string pagedetail='{" ":" "}';
       List<Website_Details__c> websitedetails = [SELECT Id,Active__c FROM Website_Details__c WHERE Opportunity__c=:oppId AND Active__c=True];
       //added by rohit Status__c=(approvetype!='Rejection')?approvetype:'Rejected' this condtion only
        Website_Page__c	web = new Website_Page__c(Name=webname,Opportunity__c=oppId,Group__c=webgroup ,Website_Details__c=websitedetails[0].Id,
                                                  Page_Details__c=pagedetail,Approval_Type__c=approvetype,Active__c=True,
                                                  Status__c=(approvetype!='Rejection')?approvetype:'Rejected',
                                                  Availability__c=avaltype);
        insert web;
        System.debug('web::::::::::'+web);
        if(web.id!=null){
            return 'success';
        }
        else{
            return 'error';
        }
    }
    @AuraEnabled
    public static void  savewebsitepagedata(list<Sobject> objrecord){
        system.debug('162:::::'+objrecord);
        update objrecord;
       // system.debug(createParser(objrecord));
    }
}