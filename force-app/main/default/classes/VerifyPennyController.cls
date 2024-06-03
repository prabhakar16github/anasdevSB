public without sharing class VerifyPennyController {
    
    @AuraEnabled
    public static WrapperBankAccountDetail pennyVerificationDetails(Id recordId){        
        WrapperBankAccountDetail clsWrapperBankAccountDetail = new WrapperBankAccountDetail();
        
        list<String> lstError = new List<String>();
        lstError.add('Please correct the below error messages : ');
        
        if(String.isNotBlank(recordId)){
            // Added for SFPI-568 for avoiding validation
            Boolean passleadvalidation = True;
            List<String> lstStringofProfileskip = Label.Onboarding_profile_validation.split(';'); 
            Set<String> setofProfiletoUpdate = new Set<String>();
            for(String objstr: lstStringofProfileskip){
                setofProfiletoUpdate.add(objstr);
            }
            
            List<User> lstUser = [SELECT Id, Profile.Name FROM User WHERE Id=:Userinfo.getUserId()];
            
            if(setofProfiletoUpdate != null && setofProfiletoUpdate.size() > 0 && String.isNotBlank(lstUser[0].Profile.Name) && 
               setofProfiletoUpdate.contains(lstUser[0].Profile.Name)){
                   passleadvalidation = false;
               }
            system.debug('####### recordId '+recordId);
            system.debug('####### recordId '+[Select Id FROM Bank_Account_Detail__c WHERE Id =: recordId]);
            Bank_Account_Detail__c bankDetails = [Select Id, Name, Penny_Deposit_Status__c, Verification_Status__c, RawResponse__c, Lead__c, Penny_Amount__c,
                                                  Lead__r.OwnerId, Lead__r.Bank_Verification_Status__c, Lead__r.Business_Entity__c, Lead__r.BusinessCategory__c, 
                                                  Lead__r.Lead_Type__c, Lead__r.Delivery_Duration__c, Lead__r.Monthly_Expected_Sale__c, Lead__r.GST_Number__c, 
                                                  Lead__r.ProductLabel__c, Lead__r.Legal_Name__c, Lead__r.Merchant_Id__c, Lead__r.PAN_Holder_Name__c, 
                                                  Lead__r.PAN_Number__c, Lead__r.Prod_Merchant_Id__c, Lead__r.Product__c, Lead__r.Sub_Category__c, Lead__r.Website__c,
                                                  Opportunity__c, Lead__r.Integration_Type__c,
                                                  Opportunity__r.OwnerId, Opportunity__r.Bank_Verification_Status__c, Opportunity__r.Business_Entity_Identifier__c, Opportunity__r.Business_Category_Identifier__c, 
                                                  Opportunity__r.Lead_Type__c, Opportunity__r.Delivery_Duration_Account__c, Opportunity__r.Monthly_Expected_Sale_Account__c, Opportunity__r.GST_Number__c, 
                                                  Opportunity__r.ProductLabel__c, Opportunity__r.Legal_Name_Account__c, Opportunity__r.Merchant_Id__c, Opportunity__r.PAN_Holder_Name_Account__c, Opportunity__r.Integration_Type__c,
                                                  Opportunity__r.PAN_Number_Account__c, Opportunity__r.Prod_Merchant_Id__c, Opportunity__r.Product__c, Opportunity__r.Sub_Category_Identifier__c, Opportunity__r.Website__c
                                                  FROM Bank_Account_Detail__c WHERE Id =: recordId];
            
            if(bankDetails.Opportunity__c != null || bankDetails.Lead__c != null){
                if(bankDetails.Penny_Deposit_Status__c != 'Success') lstError.add('\nPlease initiate penny test.');        
                if(bankDetails.Opportunity__c != null && passleadvalidation) oppValidation(bankDetails, lstError);
                else if(bankDetails.Lead__c != null ) leadConversionValidation(bankDetails, lstError, passleadvalidation);
                
                if(bankDetails.Verification_Status__c == 'Success'){
                    clsWrapperBankAccountDetail.isBankVerificationStatus =  true;
                }else if(lstError.size() > 1){
                    clsWrapperBankAccountDetail.lstError = lstError;            
                }else{
                    clsWrapperBankAccountDetail.bankDetails = bankDetails;
                } 
            }else{
                clsWrapperBankAccountDetail.isLeadNotExist = true;
            }
        }else{
            lstError.add('\n Bank Id not found.');
        }
        return clsWrapperBankAccountDetail;
    }
    
    @AuraEnabled
    public static List<String> penyVerificationStatus(Bank_Account_Detail__c bankDetailsObj){
        String msg = '';
        try{
            bankDetailsObj.Verification_Status__c = 'Success';
            update bankDetailsObj;
            return new List<String> { 'Verification_Success' }; 
                }catch(DmlException ex){
                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                        msg =+ ex.getDmlMessage(i) +  '\n' ;
                    }
                    throw new AuraHandledException(msg);
                }catch(Exception ex){
                    throw new AuraHandledException(ex.getMessage());
                }
    }
    
    public static void oppValidation(Bank_Account_Detail__c theBA, list<String> lstError){                                
        
        if(theBA.Opportunity__r.Product__c == null && theBA.Opportunity__r.Lead_Type__c == 'Merchant' && (theBA.Opportunity__r.Merchant_Business_Type__c == 'LongTail' || theBA.Opportunity__r.Merchant_Business_Type__c == 'Compulsive')) lstError.add('\nPlease select Product for the Opportunity.');        
        
        if(String.isBlank(theBA.Opportunity__r.Legal_Name_Account__c) ) lstError.add('\nPlease enter Legal Name of the merchant.');
        
        if(String.isBlank(theBA.Opportunity__r.Business_Entity_Identifier__c)) lstError.add('\nPlease enter Business Entity of the merchant.');        
        
        if(String.isBlank(theBA.Opportunity__r.PAN_Holder_Name_Account__c)) lstError.add('\nPlease enter PAN Card holder name.');        
        
        if(String.isBlank(theBA.Opportunity__r.PAN_Number_Account__c)) lstError.add('\nPlease enter PAN Card Number.');        
        /*
        if(String.isBlank(theBA.Opportunity__r.GST_Number__c) 
           && (theBA.Opportunity__r.ProductLabel__c == 'PayUbiz' || theBA.Opportunity__r.ProductLabel__c == 'Citrus')) 
            lstError.add('\nPlease enter GSTIN of the merchant.');
        */
        if(String.isBlank(theBA.Opportunity__r.Business_Category_Identifier__c) && theBA.Opportunity__r.Product__c != null && !(theBA.Opportunity__r.ProductLabel__c == 'PayUnow' ||
                                                                                                                                (theBA.Opportunity__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(theBA.Opportunity__r.Integration_Type__c) || theBA.Opportunity__r.Integration_Type__c == 'Tools')))) 
            lstError.add('\nPlease enter Business Category of the merchant.');
        
        if(String.isBlank(theBA.Opportunity__r.Sub_Category_Identifier__c) && theBA.Opportunity__r.Lead_Type__c == 'Merchant' && theBA.Opportunity__r.Product__c != null && !(theBA.Opportunity__r.ProductLabel__c == 'PayUnow' ||
                                                                                                                                                                              (theBA.Opportunity__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(theBA.Opportunity__r.Integration_Type__c) || theBA.Opportunity__r.Integration_Type__c == 'Tools')))) 
            lstError.add('\nPlease enter Sub Category of the merchant.');        
        
        if(theBA.Opportunity__r.Website__c == null && theBA.Opportunity__r.Lead_Type__c == 'Merchant'  
           && theBA.Opportunity__r.Product__c != null && !(theBA.Opportunity__r.ProductLabel__c == 'PayUnow' || (theBA.Opportunity__r.ProductLabel__c == 'PayUmoney'  && (String.isBlank(theBA.Opportunity__r.Integration_Type__c) || theBA.Opportunity__r.Integration_Type__c == 'Tools')))) 
            lstError.add('\nPlease enter website url of the merchant.');   
        
        if(theBA.Opportunity__r.Lead_Type__c == 'Merchant' && (theBA.Opportunity__r.Delivery_Duration_Account__c == null || theBA.Opportunity__r.Monthly_Expected_Sale_Account__c == null)  
           && theBA.Opportunity__r.Product__c != null && !(theBA.Opportunity__r.ProductLabel__c == 'PayUnow' ||
                                                           (theBA.Opportunity__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(theBA.Opportunity__r.Integration_Type__c) || theBA.Opportunity__r.Integration_Type__c == 'Tools')))){
                                                               lstError.add('\nPlease enter Delivery Duration and Monthly Expected Sale of the merchant. ');
                                                           }
        
        if(theBA.Opportunity__r.Prod_Merchant_Id__c == null && theBA.Opportunity__r.Lead_Type__c == 'Merchant' 
           && (theBA.Opportunity__r.ProductLabel__c == 'PayUMoney' || theBA.Opportunity__r.ProductLabel__c == 'PayUnow')
          )       // As per discussed with Nilesh, added payu now condition at Mar.07, 2019
            lstError.add('\nMID is not captured against the Opportunity.');
        
        /*
        // As per discussed with Nilesh, commented it at Mar.07, 2019
        if(theBA.Opportunity__r.Merchant_Id__c == null && theBA.Opportunity__r.Lead_Type__c == 'Merchant' 
           && (theBA.Opportunity__r.ProductLabel__c == 'PayUbiz' || theBA.Opportunity__r.ProductLabel__c == 'Citrus')
          ){
               lstError.add('\nTEST MID is not captured against the Opportunity.');
           }
        */
    }
    
    public static void leadConversionValidation(Bank_Account_Detail__c theBA, list<String> lstError,Boolean avoidvalidation){                
        
        /* Commented as per discussion with Nilesh 
if(String.valueof(theBA.Lead__r.OwnerId).startsWith('00G') && !(theBA.Lead__r.ProductLabel__c == 'PayUnow' ||
(theBA.Lead__r.ProductLabel__c == 'PayUmoney' && theBA.Lead__r.Integration_Type__c == 'Tools'))) lstError.add('\nPlease assign the lead to a user from the queue.');        
*/
        if(theBA.Lead__r.Business_Entity__c == null) lstError.add('\nPlease enter Business Entity of the merchant.');        
        
        if(theBA.Lead__r.BusinessCategory__c == null  && theBA.Lead__r.Product__c != null && !(theBA.Lead__r.ProductLabel__c == 'PayUnow' ||
                                                                                               (theBA.Lead__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(theBA.Lead__r.Integration_Type__c) || theBA.Lead__r.Integration_Type__c == 'Tools')))) lstError.add('\nPlease enter Business Category of the merchant.');
        
        
        if(theBA.Lead__r.Lead_Type__c == 'Merchant' && (theBA.Lead__r.Delivery_Duration__c == null || theBA.Lead__r.Monthly_Expected_Sale__c == null) && theBA.Lead__r.Product__c != null && !(theBA.Lead__r.ProductLabel__c == 'PayUnow' ||
                                                                                                                                                                                               (theBA.Lead__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(theBA.Lead__r.Integration_Type__c) || theBA.Lead__r.Integration_Type__c == 'Tools')))){
                                                                                                                                                                                                   lstError.add('\nPlease enter Delivery Duration and Monthly Expected Sale of the merchant. ');
                                                                                                                                                                                               }
        /*
        if(String.isBlank(theBA.Lead__r.GST_Number__c) && (theBA.Lead__r.ProductLabel__c == 'PayUbiz' || theBA.Lead__r.ProductLabel__c == 'Citrus')){
            lstError.add('\nPlease enter GSTIN of the merchant.');
        }
        *
        if(String.isBlank(theBA.Lead__r.Legal_Name__c) && theBA.Lead__r.Product__c != null && theBA.Lead__r.ProductLabel__c != 'PayUnow' && theBA.Lead__r.ProductLabel__c != 'PayUmoney')
            lstError.add('\nPlease enter Legal Name of the merchant.');
        
        /*
        if(theBA.Lead__r.Merchant_Id__c == null && theBA.Lead__r.Lead_Type__c == 'Merchant' 
           && (theBA.Lead__r.ProductLabel__c == 'PayUbiz' || theBA.Lead__r.ProductLabel__c == 'Citrus')){
               lstError.add('\nTEST MID is not captured against the lead.');
           }
        */
        if(String.isBlank(theBA.Lead__r.PAN_Holder_Name__c)) lstError.add('\nPlease enter PAN Card holder name.');        
        
        if(String.isBlank(theBA.Lead__r.PAN_Number__c)) lstError.add('\nPlease enter PAN Card Number.');        
        
        if(theBA.Lead__r.Prod_Merchant_Id__c == null && theBA.Lead__r.Lead_Type__c == 'Merchant' 
           && theBA.Lead__r.ProductLabel__c == 'PayUMoney'){
               lstError.add('\nMID is not captured against the lead.');
           }
        
        if(theBA.Lead__r.Product__c == null && theBA.Lead__r.Lead_Type__c == 'Merchant') lstError.add('\nPlease select Product for the lead.');        
        
        if(theBA.Lead__r.Sub_Category__c == null && theBA.Lead__r.Lead_Type__c == 'Merchant' && theBA.Lead__r.Product__c != null && !(theBA.Lead__r.ProductLabel__c == 'PayUnow' ||
                                                                                                                                      (theBA.Lead__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(theBA.Lead__r.Integration_Type__c) || theBA.Lead__r.Integration_Type__c == 'Tools')))) lstError.add('\nPlease enter Sub Category of the merchant.');        
        /*
        if(avoidvalidation && theBA.Lead__r.Website__c == null && theBA.Lead__r.Lead_Type__c == 'Merchant' && theBA.Lead__r.Product__c != null && !(theBA.Lead__r.ProductLabel__c == 'PayUnow' ||
                                                                                                                                                    (theBA.Lead__r.ProductLabel__c == 'PayUmoney' && (String.isBlank(theBA.Lead__r.Integration_Type__c) || theBA.Lead__r.Integration_Type__c == 'Tools')))) lstError.add('\nPlease enter website url of the merchant.');        
        */
    }
}