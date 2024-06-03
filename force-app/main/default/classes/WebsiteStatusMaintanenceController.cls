// =================== Used for "CmpWebsiteStatusMaintanence" Component=====================
public class WebsiteStatusMaintanenceController {
    /*------------------------------------------------------------
        Description:    method to get the list of website pages records 
        Inputs:         Opportunity Id
        Outputs:        List<WrapperWebsitePage>
        History
        <Date>      <Authors Name>      <Brief Description of Change>
        04-June-18   Uma Shankar             Created
    ------------------------------------------------------------*/
    @AuraEnabled
    public static list<WrapperWebsitePage> getWebsitePageRecords(id opportunityId){
        List<WrapperWebsitePage> lstWrapperWebsitePage = new List<WrapperWebsitePage>();
        
        List<String> lstWebsitePageStatus = SystemUtility.getPicklistValue('Website_Page__c', 'Status__c');
        
        User userObj = [SELECt Id, Name, ProfileId, Profile.Name, Super_User__c From User where Id =: UserInfo.getUserId() LIMIT 1];
        
        List<ProcessInstance> approvalList = new List<ProcessInstance>();
        
        if(opportunityId != null){
            for(Website_Page__c websitePageObj : [SELECT id, Name, Opportunity__c, Opportunity__r.AccountId, Risk_Remarks__c, 
                                                  Sales_Remarks__c, Status__c, Opportunity__r.Name, Opportunity__r.Website_Status__c 
                                                  FROM Website_Page__c 
                                                  WHERE Opportunity__c =: opportunityId
                                                  ORDER BY Name ASC])
            {
                WrapperWebsitePage wrapperWebsitePageObj = new WrapperWebsitePage();
                wrapperWebsitePageObj.isObjectEditable = Schema.sObjectType.Website_Page__c.isUpdateable();
                wrapperWebsitePageObj.WebsitePageObj = websitePageObj;
                wrapperWebsitePageObj.lstWebsitePageStatus = lstWebsitePageStatus;
                wrapperWebsitePageObj.userObj = userObj;
                
                if(userObj.Profile.Name == 'System Administrator' || userObj.Super_User__c){
                    wrapperWebsitePageObj.isEditAllow = true;
                }else if(websitePageObj.Status__c != 'Found - OK'){
                    wrapperWebsitePageObj.isEditAllow = true;
                }   
                wrapperWebsitePageObj.isSalesRemark = Schema.sObjectType.Website_Page__c.fields.Sales_Remarks__c.isUpdateable() ? true : false;
                wrapperWebsitePageObj.isRiskRemark = Schema.sObjectType.Website_Page__c.fields.Risk_Remarks__c.isUpdateable() ? true : false;
                wrapperWebsitePageObj.isStatus = Schema.sObjectType.Website_Page__c.fields.Status__c.isUpdateable() ? true : false;

                lstWrapperWebsitePage.add(wrapperWebsitePageObj);
            }
            if(!lstWrapperWebsitePage.isEmpty()){
                getProcessInstance(lstWrapperWebsitePage[0].WebsitePageObj.Opportunity__r.AccountId, approvalList);
                
                if(!approvalList.isEmpty() && approvalList[0].Status == 'Pending'){
                    lstWrapperWebsitePage[0].isInApprovalProcess = true;
                }                
                return lstWrapperWebsitePage;
            }
        }
        return null;
    }
    
    
    /*------------------------------------------------------------
        Description:    method to save the website pages records 
        Inputs:         String
        Outputs:        String
        History
        <Date>      <Authors Name>      <Brief Description of Change>
        04-June-18   Uma Shankar        Created
    ------------------------------------------------------------*/
    @AuraEnabled
    public static String saveWebsitePageRecords(String strWrapperWebsitePage){
        system.debug('strWrapperWebsitePage ========== '+strWrapperWebsitePage);
        List<WrapperWebsitePage> lstWrapperWebsitePage = new List<WrapperWebsitePage>();
        
        if(String.isNotBlank(strWrapperWebsitePage)){
            lstWrapperWebsitePage = (List<WrapperWebsitePage>) Json.deserialize(strWrapperWebsitePage, list<WrapperWebsitePage>.class);
            system.debug('lstWrapperWebsitePage ========== '+lstWrapperWebsitePage);            
            
            if(!lstWrapperWebsitePage.isEmpty()){
                List<Website_Page__c> lstWebsitePage = new List<Website_Page__c>();
                
                for(WrapperWebsitePage WrapperWebsitePageObj : lstWrapperWebsitePage){
                    lstWebsitePage.add(WrapperWebsitePageObj.WebsitePageObj);
                }
                
                if(!lstWebsitePage.isEmpty()){
                    try{
                        update lstWebsitePage;
                        return Label.Website_Page_Update;
                    }catch(Exception ex){
                        return 'Error: '+ ex.getMessage() +' at line '+ex.getLineNumber();
                    }
                }                
            }
        }
        return null;
    }
    
    public static void getProcessInstance(Id strAccId, List<ProcessInstance> approvalList){
        if(String.isNotBlank(strAccId)){
            approvalList.addAll([SELECT TargetObjectId, Status, CreatedDate, 
                                 (SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                                  FROM Steps ORDER BY CreatedDate DESC) FROM ProcessInstance WHERE TargetObjectId =: strAccId
                                 ORDER BY CreatedDate DESC]);
        }
    }
}