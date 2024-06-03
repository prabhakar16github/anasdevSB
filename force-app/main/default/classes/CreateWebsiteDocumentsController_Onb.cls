public class CreateWebsiteDocumentsController_Onb {

    @AuraEnabled
    public static Opportunity getMerchantDocumentRecords(String strOpportDetail){
        List<Opportunity> lstOpp ;
        Opportunity objOpp ;
        List<User> lstUser = [SELECT id, Profile.Name  FROM User WHERE Id=:Userinfo.getUserId() ];
        if(String.isNotBlank(strOpportDetail)){
            lstOpp = [SELECT id, Product__c, Product__r.Name, Owner.Profile.Name, (SELECT id FROM Website_Pages__r) 
                      FROM Opportunity WHERE Id =:strOpportDetail ];
            if(lstOpp != null && lstOpp.Size() > 0){
                lstOpp[0].Owner.Profile.Name = lstUser[0].Profile.Name;
                objOpp = lstOpp[0];
            }                
        }           
        return objOpp;
    }
    
    @AuraEnabled
    public static String createMerchantDocumentRecords(String strOpportDetail){
        String returnstatement ;
        List<Website_Page__c> lstWebPage = new List<Website_Page__c>();
        if(String.isNotBlank(strOpportDetail)){
            for(String objStr:Label.Website_Name.split(';')){
                Website_Page__c objWebpages = new Website_Page__c();
                objWebpages.Name = objStr;
                objWebpages.Opportunity__c = strOpportDetail;
                lstWebPage.add(objWebpages);
            }
            try{
                if(lstWebPage.size() > 0)
                    insert lstWebPage;    
                returnstatement = 'Sucessfully created website pages';
            }
            catch(Exception E){
               returnstatement =  E.getdmlMessage(0);
            }
        }
        return returnstatement;
    }
    
    @AuraEnabled
    public static TheInitData getWPM(String wpmId){
        TheInitData dataToReturn = new TheInitData();
        dataToReturn.theWPM = [SELECT Id, Name, Page_Details__c, Product__c, Integration_Type__c FROM Website_Page_Master__c 
                               WHERE Id =: wpmId];
        dataToReturn.statusValues = PicklistGenerator.getPicklistValues('Website_Page__c', 'Status__c', '', false);
        return dataToReturn;
    }
    
    @AuraEnabled
    public static String getPicklist(){
        String result = PicklistGenerator.getPicklistValues('Website_Page__c', 'Status__c', '', false);
        return result;
    }
    
    @AuraEnabled
    public static void updateWPM(Sobject theWpmToUpdate){
        update theWpmToUpdate;
    }

    @AuraEnabled
    public static List<Website_Error_Meta__mdt> getWebsite_Error_Meta(){
        //return [SELECT MasterLabel, Website_Page_Name__c, Linked_Error__c FROM Website_Error_Meta__mdt WHERE Website_Page_Name__c =:name];
        return [SELECT MasterLabel, Website_Page_Name__c, Linked_Error__c FROM Website_Error_Meta__mdt];
    }
    
    @AuraEnabled
    public static String getWebsiteError(String WebsitePagename){
         Website_Error_Meta__mdt websiteErrorMetadata = [SELECT MasterLabel, Website_Page_Name__c, Linked_Error__c FROM Website_Error_Meta__mdt WHERE Website_Page_Name__c =:WebsitePagename];
        system.debug('-->>>>> mdt -- '+websiteErrorMetadata);
        return websiteErrorMetadata.Linked_Error__c;
    }
    
    @AuraEnabled
    public static void createTaskForSalesTeam(){
        
    }
    
    public class TheInitData{
        @auraEnabled
        public Website_Page_Master__c theWPM;
        @auraEnabled
        public String statusValues;
    }
}