public class UpdateWebsiteDetailsController {
    
    @AuraEnabled
    public static string updateWebsiteDetails(string objectName, string recordId){
        try{
            if(String.isNotBlank(recordId)){
                Opportunity opportunityObj = [Select Id,Integration_Type__c,Android_URL__c,Website__c,iOS_URL__c,Website_Status__c from Opportunity Where Id =: recordId];
                List<Website_Details__c> websiteDetailList = New List<Website_Details__c>();
                
                if(String.isBlank(opportunityObj.Integration_Type__c) || opportunityObj.Integration_type__c == 'Tools'){
                    return 'Please change Integration Type to Thirdparty.';
                }else if(String.isNotBlank(opportunityObj.Integration_Type__c) && opportunityObj.Integration_type__c == 'Thirdparty'){
                    websiteDetailList = [Select Id,Website_Status__c,Is_Website_Live__c from Website_Details__c Where Opportunity__c =: recordId AND Active__c = True];
                    if(!websiteDetailList.isEmpty()){
                        if(String.isNotBlank(websiteDetailList[0].Website_Status__c) && websiteDetailList[0].Website_Status__c == 'Website Error'){
                            if(websiteDetailList[0].Is_Website_Live__c == 'active'){
                                websiteDetailList[0].Website_Status__c = 'Pending';
                            }else{
                                websiteDetailList[0].Website_Status__c = 'Verification in Process';
                            }
                        }
                        update websiteDetailList;
                    }else if(websiteDetailList.isEmpty()){
                        websiteDetailList.add(WebsiteStatusMaintanenceController_Onb.createWebsiteDetails(opportunityObj));
                        websiteDetailList[0].Website_Status__c = 'Verification in Process';
                        insert websiteDetailList;
                    }
                    return 'Record updated successfully.';
                }
            }
        }catch(Exception ex){
            return 'Line No.-'+ex.getLineNumber() + ' Message-'+ex.getMessage();
        }
        return null;
    }
}