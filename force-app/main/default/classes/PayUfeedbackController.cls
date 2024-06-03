public with sharing class PayUfeedbackController {

    @AuraEnabled
    public static feedbackWrapper getWrapperData(Id recordId){
        feedbackWrapper wrapperObj = New feedbackWrapper();
        try{
        	wrapperObj.caseObj = getCaseObj(recordId);
            wrapperObj.emailStatusTrackerObj = New Email_Status_Tracking__c();
            if(String.isNotBlank(wrapperObj.caseObj.LP_Customer_Feedback__c)){
                wrapperObj.message = 'Feedback submitted.';
            }else
                wrapperObj.message = '';
            
            wrapperObj.emailStatusTrackerObj = [Select Id,First_Opened_Timestamp__c,First_Clicked_on_CTA_Timestamp__c,
                                                Last_Opened_Timestamp__c,Merchant_Response__c,No_of_Times_Opened__c  
                                                from Email_Status_Tracking__c Where Case__c =: recordId];
            if(wrapperObj.emailStatusTrackerObj.First_Opened_Timestamp__c == null) wrapperObj.emailStatusTrackerObj.First_Opened_Timestamp__c = System.now();
            wrapperObj.emailStatusTrackerObj.No_of_Times_Opened__c = wrapperObj.emailStatusTrackerObj.No_of_Times_Opened__c == null ? 1 : wrapperObj.emailStatusTrackerObj.No_of_Times_Opened__c + 1;
            wrapperObj.emailStatusTrackerObj.Last_Opened_Timestamp__c = System.now();
            GuestUserUtilityHelper.updateObject(wrapperObj.emailStatusTrackerObj);
        }catch(Exception ex){
            wrapperObj.message = 'Error - Something went wrong. '+ex.getMessage();
        }
        return wrapperObj;
    }
    
    public static Case getCaseObj(Id recordId){
        return[Select Id, LP_Customer_Feedback__c,LP_Customer_Sub_Feedback__c,LP_Customer_Comments__c,Contact_Name__c,Status from Case Where Id =: recordId];
    }
    
    @AuraEnabled
    public static feedbackWrapper submitMerchantFeedback(string wrapperstr, List<string> selectedboxesMsg, string selectedEmojisMsg, string rating){
        feedbackWrapper wrapperObj = New feedbackWrapper();
        try{
            wrapperObj = (feedbackWrapper) system.JSON.deserialize(wrapperstr, feedbackWrapper.class);
            wrapperObj.caseObj.LP_Customer_Feedback__c = selectedEmojisMsg;
            wrapperObj.caseObj.LP_Customer_Sub_Feedback__c = String.join(selectedboxesMsg,';');
            wrapperObj.caseObj.LP_Rating__c = Integer.valueOf(rating);
            wrapperObj.message = 'Feedback submitted.';
            GuestUserUtilityHelper.updateObject(wrapperObj.caseObj);
            
            wrapperObj.emailStatusTrackerObj.First_Clicked_on_CTA_Timestamp__c = System.now();
            wrapperObj.emailStatusTrackerObj.Merchant_Response__c = 'Accepted';
            wrapperObj.emailStatusTrackerObj.No_of_Times_Opened__c = wrapperObj.emailStatusTrackerObj.No_of_Times_Opened__c == null ? 1 : wrapperObj.emailStatusTrackerObj.No_of_Times_Opened__c + 1;
            GuestUserUtilityHelper.updateObject(wrapperObj.emailStatusTrackerObj);
        }catch(Exception ex){
            wrapperObj.message = 'Error-'+ex.getMessage()+' something went wrong.';
        }
        return wrapperObj;
    }
    
    public class feedbackWrapper{
        @AuraEnabled
        public Case caseObj {get; set;}
        
        @AuraEnabled
        public Email_Status_Tracking__c emailStatusTrackerObj {get; set;}
        
        @AuraEnabled
        public String message {get; set;}
    }
}