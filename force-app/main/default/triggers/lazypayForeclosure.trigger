trigger lazypayForeclosure on LP_Collection_foreclosure__c (after insert,after update) {

 try{
   
    for(LP_Collection_foreclosure__c l:Trigger.New){
        if (l.Foreclosure_Enquiry__c == true)  
        {
            LP_CallLazypayPayUbiz.GetJsonResponse(l.CustomerMobile__c,l.Lazypay_Loan_ID__c,l.id); // Foreclosure enquiry
        }   
        
        if (l.Submit_for_Posting__c  == true)  
        {
            if ( l.Is_Reliance_Collected__c == true)
            {
                LP_CallLazypayPayUbiz.GetJsonResponse2(l.CustomerMobile__c,l.Lazypay_Loan_ID__c,l.id,l.Amount__c,'RCF - '+l.Reliance_Cheque_ID__c,l.Reliance_Cheque_ID__c); // Foreclosure enquiry
                
            }
            else{
                LP_CallLazypayPayUbiz.GetJsonResponse2(l.CustomerMobile__c,l.Lazypay_Loan_ID__c,l.id,l.Amount__c,l.Payment_Link_PAYU_ID__c,l.Bank_Reference_Number__c); // Foreclosure enquiry
            }
        }  
        
        if(l.Regenerate_Payment_Url__c == true)   
        {
            LP_CallLazypayPayUbiz.GetPaymentLink(l.id,l.Amount__c,l.Transaction_Id__c,l.Product_Description__c,l.CustomerName__c,l.CustomerEmail__c,l.CustomerMobile__c,l.CustomerAddress1__c,l.CustomerCity__c,l.CustomerState__c,l.CustomerCountry__c,l.CustomerZipCode__c,'1','1',l.ValidationPeriod__c,l.TimeUnit__c);
            
        }
        if(l.Check_Transaction_status__c == true)
        {
            LP_CallLazypayPayUbiz.CheckPaymentLink(l.id,l.Transaction_Id__c);            
        }
    }
        
    }Catch(Exception ex){
        system.debug(ex.getMessage());
        
    }
   
}