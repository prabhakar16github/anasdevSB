trigger triggerPartPaymentLP on LP_Collection_PL_PartPayment__c (after insert,after update) {
     
    
    for(LP_Collection_PL_PartPayment__c l:Trigger.New){
        
        if (l.Post_Payment__c == true)  
        {
        
            if(l.IsNEFT__c == false){
            //this will post the payment as per PayU UTR
            LazypayPartPayment.PostPartPayment(l.id,l.mobile__c,l.amount__c,l.Issuing_Bank__c,l.Payment_Mode__c,l.Bank_Reference_Number__c,l.vpa__c,l.userAgent__c,l.PayU_ID__c,l.Bank_Reference_Number__c);
            }
            else{
            LazypayPartPayment.PostPartPayment(l.id,l.mobile__c,l.amount__c,l.Issuing_Bank__c,l.Payment_Mode__c,l.NEFT_UTR__c,l.vpa__c,l.userAgent__c,l.PayU_ID__c,l.NEFT_UTR__c);
                
            }
        
        }
        
        if(l.Generate_Payment_URL__c == true)
        {
           
         LazypayPartPayment.GetPaymentLink(l.id,l.Amount__c,l.PayU_Link_Invoice__c,'Part payment','firstname','email@email.com',l.mobile__c,'address1','Gurgaon','','','111111','1','1','7','D');
            
        }
        
         if(l.Check_Transaction_Status__c == true)
         {
           
                LazypayPartPayment.CheckPaymentLink(l.id,l.mobile__c + l.Name + String.valueOf(l.PayLinkCounter__c-1));
             
         }
        if(l.Send_Payment_Details_to_Customer__c == true)
        {

                LazypayPartPayment.SendPaymentDetails(l.id,l.mobile__c,String.valueOf(l.Amount__c),l.Payment_Url__c,l.FTE_Mobile__c);    
            
        }
        
    }
}