public without sharing class MaintenanceRequestController {
    
    @AuraEnabled
    public static RequestDataWrapper getRequestData(string parentId, Id recordId, string requestType, string merchantResponse){
        RequestDataWrapper dataWrapper = New RequestDataWrapper();
        
        Email_Status_Tracking__c emailTracker = getEmailTracking(recordId, requestType, merchantResponse);
        try{
        String payUResponsemessageAgain = System.label.MerchantChangeRequestAgain;
        String payUResponsemessageAccepted = System.label.MerchantChangeRequestAccepted;
        String payUResponsemessageRejected = System.label.MerchantChangeRequestRejected;
        
        if(requestType == 'BankDetail'){
            
            Bank_Account_Detail__c bankObj = [Select Id,Verification_Status__c,Account_Holder_Name__c,Account_Number__c,
                                              IFSC_Code__c,Bank_Name__c,Merchant_Name__c,Opportunity__c,Opportunity__r.Parent_Opportunity__c
                                              from Bank_Account_Detail__c Where Id=:recordId LIMIT 1];
            dataWrapper.bankAccountObj = bankObj;
            system.debug('###### bankObj '+bankObj.Opportunity__r.Parent_Opportunity__c);
            Opportunity updateOppObj = [Select Id,Active__c,First_Name__c,Last_Name__c From Opportunity Where Id=: bankObj.Opportunity__c];
            dataWrapper.merchantName = string.isNotBlank(updateOppObj.First_Name__c) && String.isNotBlank(updateOppObj.Last_Name__c) ? updateOppObj.First_Name__c +' '+updateOppObj.Last_Name__c : updateOppObj.Last_Name__c;
            Bank_Account_Detail__c updatedBankObj ;
            
            if(emailTracker != null && emailTracker.Merchant_Response__c == 'Pending'){
                if(String.isNotBlank(merchantResponse) && merchantResponse == 'accepted'){
                    if(bankObj !=null && bankObj.Verification_Status__c != 'Success'){
                        bankObj.Verification_Status__c = 'Success';
                        update bankObj;
                        updatedBankObj = [Select Id,Verification_Status__c,Account_Holder_Name__c,Account_Number__c,
                                              IFSC_Code__c,Bank_Name__c,Merchant_Name__c,Opportunity__c From Bank_Account_Detail__c Where Active__c = True AND Opportunity__c =:bankObj.Opportunity__r.Parent_Opportunity__c];
                        dataWrapper.bankAccountObj = updatedBankObj;
                        dataWrapper.response = payUResponsemessageAccepted;
                    }else if(bankObj !=null && bankObj.Verification_Status__c == 'Success'){
                        dataWrapper.response = payUResponsemessageAgain;
                        updatedBankObj = [Select Id,Verification_Status__c,Account_Holder_Name__c,Account_Number__c,
                                              IFSC_Code__c,Bank_Name__c,Merchant_Name__c,Opportunity__c From Bank_Account_Detail__c Where Active__c = True AND Opportunity__c =:bankObj.Opportunity__r.Parent_Opportunity__c];
                        dataWrapper.bankAccountObj = updatedBankObj;
                    }
                }else{
                    dataWrapper.response = payUResponsemessageRejected;
                    updatedBankObj = [Select Id,Verification_Status__c,Account_Holder_Name__c,Account_Number__c,
                                              IFSC_Code__c,Bank_Name__c,Merchant_Name__c,Opportunity__c From Bank_Account_Detail__c Where Active__c = True AND Opportunity__c =:bankObj.Opportunity__r.Parent_Opportunity__c];
                        dataWrapper.bankAccountObj = updatedBankObj;
                }
            }else{
                dataWrapper.response = payUResponsemessageAgain;
                updatedBankObj = [Select Id,Verification_Status__c,Account_Holder_Name__c,Account_Number__c,
                                              IFSC_Code__c,Bank_Name__c,Merchant_Name__c,Opportunity__c From Bank_Account_Detail__c Where Active__c = True AND Opportunity__c =:bankObj.Opportunity__r.Parent_Opportunity__c];
                        dataWrapper.bankAccountObj = updatedBankObj;
            }
            
            if(updateOppObj.Active__c){
                updateOppObj.Active__c = False;
                update updateOppObj;
            }
        }
        
        if(requestType == 'PANDetail'){
            Account accObj = [Select Id,PAN_Number__c,PAN_Holder_Name__c,New_PAN_Holder_Name__c,New_PAN_Number__c,ParentId from Account Where Id=:recordId LIMIT 1];
            Account updateAccObj = [Select Id,PAN_Number__c,PAN_Holder_Name__c,New_PAN_Holder_Name__c,New_PAN_Number__c from Account Where Id=:accObj.ParentId LIMIT 1];
            Opportunity updateOppObj = [Select Id,Active__c,First_Name__c,Last_Name__c from Opportunity Where AccountId =: accObj.Id];
            dataWrapper.merchantName = string.isNotBlank(updateOppObj.First_Name__c) && String.isNotBlank(updateOppObj.Last_Name__c) ? updateOppObj.First_Name__c +' '+updateOppObj.Last_Name__c : updateOppObj.Last_Name__c;
            
            if(emailTracker != null && emailTracker.Merchant_Response__c == 'Pending'){
                if(String.isNotBlank(merchantResponse) && merchantResponse == 'accepted'){
                    if(accObj.New_PAN_Number__c != updateAccObj.PAN_Number__c || accObj.New_PAN_Holder_Name__c != updateAccObj.PAN_Holder_Name__c){
                        updateAccObj.PAN_Number__c = accObj.New_PAN_Number__c;
                        updateAccObj.PAN_Holder_Name__c = accObj.New_PAN_Holder_Name__c;
                        update updateAccObj;
                        dataWrapper.response = payUResponsemessageAccepted;
                        dataWrapper.accObj = updateAccObj;
                    }else{
                        dataWrapper.response = payUResponsemessageAgain;
                        dataWrapper.accObj = updateAccObj;
                    } 
                }else{
                    dataWrapper.response = payUResponsemessageRejected;
                    dataWrapper.accObj = updateAccObj;
                }
            }else{
                dataWrapper.response = payUResponsemessageAgain;
                dataWrapper.accObj = updateAccObj;
            }
            if(updateOppObj.Active__c){
                updateOppObj.Active__c = False;
                update updateOppObj;
            }
        }
        
        if(requestType == 'LegalDetail'){
            Account accObj = [Select Id,Legal_Name__c,New_Legal_Name__c,ParentId,PAN_Holder_Name__c  from Account Where Id=:recordId LIMIT 1];
            Account updateAccObj = [Select Id,Legal_Name__c,New_Legal_Name__c,PAN_Holder_Name__c from Account Where Id=:accObj.ParentId LIMIT 1];
            Opportunity updateOppObj = [Select Id,Active__c,First_Name__c,Last_Name__c from Opportunity Where AccountId =: accObj.Id];
            dataWrapper.merchantName = string.isNotBlank(updateOppObj.First_Name__c) && String.isNotBlank(updateOppObj.Last_Name__c) ? updateOppObj.First_Name__c +' '+updateOppObj.Last_Name__c : updateOppObj.Last_Name__c;
            
            if(emailTracker != null && emailTracker.Merchant_Response__c == 'Pending'){
                if(String.isNotBlank(merchantResponse) && merchantResponse == 'accepted'){
                    if(accObj.New_Legal_Name__c != updateAccObj.Legal_Name__c){
                        updateAccObj.Legal_Name__c = accObj.New_Legal_Name__c;
                        update updateAccObj;
                        dataWrapper.response = payUResponsemessageAccepted;
                        dataWrapper.accObj = updateAccObj;
                    }else{
                        dataWrapper.response = payUResponsemessageAgain;
                        dataWrapper.accObj = updateAccObj;
                    } 
                }else{
                    dataWrapper.response = payUResponsemessageRejected;
                    dataWrapper.accObj = updateAccObj;
                }
            }else{
                dataWrapper.response = payUResponsemessageAgain;
                dataWrapper.accObj = updateAccObj;
            }
            if(updateOppObj.Active__c){
                updateOppObj.Active__c = False;
                update updateOppObj;
            }
        }
        
        if(requestType == 'EmailDetail'){
            Opportunity oppObj = [Select Id,Email__c,New_Email__c,Parent_Opportunity__c,First_Name__c,Last_Name__c,Active__c from Opportunity Where Id=:recordId LIMIT 1];
            Opportunity updateOppObj = [Select Id,Email__c,New_Email__c,First_Name__c,Last_Name__c,Active__c from Opportunity Where Id=:oppObj.Parent_Opportunity__c LIMIT 1];
            dataWrapper.merchantName = string.isNotBlank(updateOppObj.First_Name__c) && String.isNotBlank(updateOppObj.Last_Name__c) ? updateOppObj.First_Name__c +' '+updateOppObj.Last_Name__c : updateOppObj.Last_Name__c;
            
            if(emailTracker != null && emailTracker.Merchant_Response__c == 'Pending'){
                if(String.isNotBlank(merchantResponse) && merchantResponse == 'accepted'){
                    if(oppObj.New_Email__c != updateOppObj.Email__c){
                        updateOppObj.Email__c = oppObj.New_Email__c;
                        update updateOppObj;
                        dataWrapper.response = payUResponsemessageAccepted;
                        dataWrapper.oppObj = updateOppObj;
                    }else{
                        dataWrapper.response = payUResponsemessageAgain;
                        dataWrapper.oppObj = updateOppObj;
                    } 
                }else{
                    dataWrapper.response = payUResponsemessageRejected;
                    dataWrapper.oppObj = updateOppObj;
                }
            }else{
                dataWrapper.response = payUResponsemessageAgain;
                dataWrapper.oppObj = updateOppObj;
            }
            if(oppObj.Active__c){
                oppObj.Active__c = False;
                update oppObj;
            }
        }
        
        if(requestType == 'MobileDetail'){
            Opportunity oppObj = [Select Id,Mobile__c,New_Mobile__c,Parent_Opportunity__c,First_Name__c,Last_Name__c,Active__c  from Opportunity Where Id=:recordId LIMIT 1];
            Opportunity updateOppObj = [Select Id,Mobile__c,New_Mobile__c,First_Name__c,Last_Name__c,Active__c from Opportunity Where Id=:oppObj.Parent_Opportunity__c LIMIT 1];
            dataWrapper.merchantName = string.isNotBlank(updateOppObj.First_Name__c) && String.isNotBlank(updateOppObj.Last_Name__c) ? updateOppObj.First_Name__c +' '+updateOppObj.Last_Name__c : updateOppObj.Last_Name__c;
            
            if(emailTracker != null && emailTracker.Merchant_Response__c == 'Pending'){
                if(String.isNotBlank(merchantResponse) && merchantResponse == 'accepted'){
                    if(oppObj.New_Mobile__c != updateOppObj.Mobile__c){
                        updateOppObj.Mobile__c = oppObj.New_Mobile__c;
                        update updateOppObj;
                        dataWrapper.response = payUResponsemessageAccepted;
                        dataWrapper.oppObj = updateOppObj;
                    }else{
                        dataWrapper.response = payUResponsemessageAgain;
                        dataWrapper.oppObj = updateOppObj;
                    } 
                }else{
                    dataWrapper.response = payUResponsemessageRejected;
                    dataWrapper.oppObj = updateOppObj; 
                }
            }else{
                dataWrapper.response = payUResponsemessageAgain;
                dataWrapper.oppObj = updateOppObj;
            }
            if(oppObj.Active__c){
                oppObj.Active__c = False;
                update oppObj;
            }
        }
        
        if(requestType == 'EntityDetail'){
            Opportunity oppObj = [Select Id,Business_Entity__c,Business_Entity__r.Name,New_Business_Entity__c,Parent_Opportunity__c,First_Name__c,Last_Name__c,Active__c  from Opportunity Where Id=:recordId LIMIT 1];
            Opportunity updateOppObj = [Select Id,Business_Entity__c,Business_Entity__r.Name,New_Business_Entity__c,First_Name__c,Last_Name__c,Active__c from Opportunity Where Id=:oppObj.Parent_Opportunity__c LIMIT 1];
            dataWrapper.merchantName = string.isNotBlank(updateOppObj.First_Name__c) && String.isNotBlank(updateOppObj.Last_Name__c) ? updateOppObj.First_Name__c +' '+updateOppObj.Last_Name__c : updateOppObj.Last_Name__c;
            
            if(emailTracker != null && emailTracker.Merchant_Response__c == 'Pending'){
                if(String.isNotBlank(merchantResponse) && merchantResponse == 'accepted'){
                    if(oppObj.New_Business_Entity__c != updateOppObj.Business_Entity__r.Name){
                        updateOppObj.Business_Entity__c = [Select Id from Entity__c Where Name=: oppObj.New_Business_Entity__c LIMIT 1].Id;
                        update updateOppObj;
                        dataWrapper.response = payUResponsemessageAccepted;
                        dataWrapper.oppObj = updateOppObj;
                    }else{
                        dataWrapper.response = payUResponsemessageAgain;
                        dataWrapper.oppObj = updateOppObj;
                    }
                }else{
                    dataWrapper.response = payUResponsemessageRejected;
                    dataWrapper.oppObj = updateOppObj;
                }
            }else{
                dataWrapper.response = payUResponsemessageAgain;
                dataWrapper.oppObj = updateOppObj;
            }
            if(oppObj.Active__c){
                oppObj.Active__c = False;
                update oppObj;
            }
        }
        
        if(requestType == 'AddressDetail'){
            Address_Details__c addressObj = [Select Id,Type__c,New_Type__c,City__c,New_City__c,State__c,New_State__c,
                                             Country__c,New_Country__c,Pincode__c,New_Pincode__c,Address_Line__c,Account__r.Legal_Name__c,
                                             New_Address_Line__c,Opportunity__c,Opportunity__r.Parent_Opportunity__c,
                                             Opportunity__r.First_Name__c,Opportunity__r.Last_Name__c,Opportunity__r.AccountId,
                                             Opportunity__r.Parent_Opportunity__r.AccountId from Address_Details__c 
                                             Where Id=:recordId LIMIT 1];
            Address_Details__c existingAddressObj = [Select Id,Type__c,New_Type__c,City__c,New_City__c,State__c,New_State__c,Account__r.Legal_Name__c,
                                                     Country__c,New_Country__c,Pincode__c,New_Pincode__c,Address_Line__c,
                                                     New_Address_Line__c,Opportunity__c,Opportunity__r.Parent_Opportunity__c,
                                                     Merchant_Email__c,Opportunity__r.First_Name__c,Opportunity__r.Last_Name__c 
                                                     from Address_Details__c 
                                                     Where Type__c =: addressObj.New_Type__c AND Active__c = True
                                                     AND (Opportunity__c =: addressObj.Opportunity__r.Parent_Opportunity__c 
                                                     OR Account__c =: addressObj.Opportunity__r.Parent_Opportunity__r.AccountId) ORDER BY LastModifiedDate Desc
                                                     LIMIT 1];
            
            if(emailTracker != null && emailTracker.Merchant_Response__c == 'Pending'){
                if(String.isNotBlank(merchantResponse) && merchantResponse == 'accepted'){
                    if(existingAddressObj != null && (addressObj.New_City__c != existingAddressObj.City__c || addressObj.New_State__c != existingAddressObj.State__c
                                                      || addressObj.New_Country__c != existingAddressObj.Country__c || addressObj.New_Pincode__c != existingAddressObj.Pincode__c
                                                      || addressObj.New_Address_Line__c != existingAddressObj.Address_Line__c)){
                                                          existingAddressObj.Active__c = False;
                                                          update existingAddressObj;
                                                          Address_Details__c newAddressObj = existingAddressObj.clone();
                                                          newAddressObj.City__c = addressObj.New_City__c;
                                                          newAddressObj.State__c = addressObj.New_State__c;
                                                          newAddressObj.Country__c = addressObj.New_Country__c;
                                                          newAddressObj.Pincode__c = addressObj.New_Pincode__c;
                                                          newAddressObj.Address_Line__c = addressObj.New_Address_Line__c;
                                                          newAddressObj.Identifier__c = null;
                                                          newAddressObj.Active__c = True;
                                                          insert newAddressObj;
                                                          dataWrapper.response = payUResponsemessageAccepted;
                                                          dataWrapper.addressObj = existingAddressObj;
                                                          dataWrapper.merchantName = string.isNotBlank(existingAddressObj.Opportunity__r.Last_Name__c) ? existingAddressObj.Opportunity__r.First_Name__c +' '+existingAddressObj.Opportunity__r.Last_Name__c : existingAddressObj.Account__r.Legal_Name__c;
                                                      }else{
                                                          dataWrapper.response = payUResponsemessageAgain;
                                                          dataWrapper.addressObj = existingAddressObj;
                                                          dataWrapper.merchantName = string.isNotBlank(existingAddressObj.Opportunity__r.Last_Name__c) ? existingAddressObj.Opportunity__r.First_Name__c +' '+existingAddressObj.Opportunity__r.Last_Name__c : existingAddressObj.Account__r.Legal_Name__c;
                                                      } 
                }else{
                    dataWrapper.response = payUResponsemessageRejected;
                    dataWrapper.addressObj = existingAddressObj;
                    dataWrapper.merchantName = dataWrapper.merchantName = string.isNotBlank(existingAddressObj.Opportunity__r.Last_Name__c) ? existingAddressObj.Opportunity__r.First_Name__c +' '+existingAddressObj.Opportunity__r.Last_Name__c : existingAddressObj.Account__r.Legal_Name__c;
                }
            }else{
                dataWrapper.response = payUResponsemessageAgain;
                dataWrapper.addressObj = existingAddressObj;
                dataWrapper.merchantName = string.isNotBlank(existingAddressObj.Opportunity__r.Last_Name__c) ? existingAddressObj.Opportunity__r.First_Name__c +' '+existingAddressObj.Opportunity__r.Last_Name__c : existingAddressObj.Account__r.Legal_Name__c;
            }
        }
        
        emailTracker.Merchant_Response__c = merchantResponse == 'accepted' ? 'Accepted' : merchantResponse == 'rejected' ? 'Rejected' : merchantResponse;
        update emailTracker;
        }catch(Exception ex){
            system.debug('#### error '+ex+' line '+ex.getLineNumber());
            update emailTracker;
        }
        system.debug('####### dataWrapper ');
        return dataWrapper;
    }
    
    public static Email_Status_Tracking__c getEmailTracking(Id recordId, String requestType, String response){
        Email_Status_Tracking__c emailTracker = New Email_Status_Tracking__c();
        if(requestType == 'AddressDetail') 
            emailTracker = [Select Id,Merchant_Response__c,First_Clicked_on_CTA_Timestamp__c,First_Opened_Timestamp__c,
                            Last_Opened_Timestamp__c,No_of_times_clicked_the_CTA__c,No_of_Times_Opened__c 
                            from Email_Status_Tracking__c Where Address_Details__c =: recordId 
                            ORDER BY LastModifiedDate DESC LIMIT 1];
        else if(requestType == 'BankDetail') 
            emailTracker = [Select Id,Merchant_Response__c,First_Clicked_on_CTA_Timestamp__c,First_Opened_Timestamp__c,
                            Last_Opened_Timestamp__c,No_of_times_clicked_the_CTA__c,No_of_Times_Opened__c 
                            from Email_Status_Tracking__c Where Bank_Account_Detail__c =: recordId 
                            ORDER BY LastModifiedDate DESC LIMIT 1];
        else if(requestType == 'EmailDetail' || requestType == 'MobileDetail' || requestType == 'EntityDetail') 
            emailTracker = [Select Id,Merchant_Response__c,First_Clicked_on_CTA_Timestamp__c,First_Opened_Timestamp__c,
                            Last_Opened_Timestamp__c,No_of_times_clicked_the_CTA__c,No_of_Times_Opened__c 
                            from Email_Status_Tracking__c Where Opportunity__c =: recordId 
                            ORDER BY LastModifiedDate DESC LIMIT 1];
        else if(requestType == 'PANDetail' || requestType == 'LegalDetail') 
            emailTracker = [Select Id,Merchant_Response__c,First_Clicked_on_CTA_Timestamp__c,First_Opened_Timestamp__c,
                            Last_Opened_Timestamp__c,No_of_times_clicked_the_CTA__c,No_of_Times_Opened__c 
                            from Email_Status_Tracking__c Where Account__c =: recordId 
                            ORDER BY LastModifiedDate DESC LIMIT 1];
        
        emailTracker.First_Clicked_on_CTA_Timestamp__c = System.now();
        emailTracker.No_of_times_clicked_the_CTA__c = emailTracker.No_of_times_clicked_the_CTA__c == null ? 0 : emailTracker.No_of_times_clicked_the_CTA__c +1;
        
        return emailTracker;
    }
    
    public class RequestDataWrapper{
        @AuraEnabled
        public Opportunity oppObj {get;set;}
        @AuraEnabled
        public Account accObj {get;set;}
        @AuraEnabled
        public Bank_Account_Detail__c bankAccountObj {get;set;}
        @AuraEnabled
        public Address_Details__c addressObj {get;set;}
        @AuraEnabled
        public string response {get;set;}
        @AuraEnabled
        public string merchantName {get;set;}
    }
}