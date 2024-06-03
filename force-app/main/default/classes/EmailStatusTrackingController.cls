public class EmailStatusTrackingController {
    
    public EmailStatusTrackingController(){
    }
    
    public pageReference messageDoInit(){
        string emailTrackId = apexpages.currentpage().getparameters().get('emailTrackingId');
        string onboardingUrl = apexpages.currentpage().getparameters().get('onboardingUrl');
        
        List<Email_Status_Tracking__c> estrackList = New List<Email_Status_Tracking__c>();
        
        if(String.isNotBlank(emailTrackId) && String.isBlank(onboardingUrl)){
            estrackList = [Select Id,First_Opened_Timestamp__c,Last_Opened_Timestamp__c,
                           No_of_Times_Opened__c,First_Clicked_on_CTA_Timestamp__c,No_of_times_clicked_the_CTA__c from Email_Status_Tracking__c Where Id=:emailTrackId];
            
            if(estrackList[0].First_Opened_Timestamp__c == null) estrackList[0].First_Opened_Timestamp__c = System.now();
            
            estrackList[0].Last_Opened_Timestamp__c = System.Now();
            
            if(estrackList[0].No_of_Times_Opened__c == null) estrackList[0].No_of_Times_Opened__c = 1;
            else estrackList[0].No_of_Times_Opened__c = estrackList[0].No_of_Times_Opened__c + 1;
            
            if(!estrackList.isEmpty()) update estrackList;
        }
        
        
        if(String.isNotBlank(onboardingUrl)){
            if(String.isNotBlank(emailTrackId)){
                estrackList = [Select Id,First_Opened_Timestamp__c,Last_Opened_Timestamp__c,
                           No_of_Times_Opened__c,First_Clicked_on_CTA_Timestamp__c,No_of_times_clicked_the_CTA__c from Email_Status_Tracking__c Where Id=:emailTrackId];
            
                if(estrackList[0].First_Clicked_on_CTA_Timestamp__c == null) 
                    estrackList[0].First_Clicked_on_CTA_Timestamp__c  = System.now();
                
                if(estrackList[0].No_of_times_clicked_the_CTA__c ==null) estrackList[0].No_of_times_clicked_the_CTA__c = 1;
                else estrackList[0].No_of_times_clicked_the_CTA__c = estrackList[0].No_of_times_clicked_the_CTA__c + 1;
                
                if(!estrackList.isEmpty()) update estrackList;
            }
            pageReference pR = new pageReference(onboardingUrl);
            pR.setRedirect(true);
            return pR;
        }
        
        return null;
    }
}