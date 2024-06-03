@RestResource(urlMapping='/CrossSellDetails/*')
global class Payout_CrossSellDetailService {
    @httpGet
    global static Response getCrossSelldata(){
        
        RestRequest req = RestContext.request;
        String PayoutMerchantId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);//req.params.get('payoutId');
        Response response = new Response();
        try{
            
            if(String.isBlank(PayoutMerchantId)){
                response.isSuccess = true;
                response.message = 'Please send the Payout Id';
            }else{
                System.debug('>>>>>PayoutMerchantId>>>>>'+PayoutMerchantId);
                
                List<Cross_Sell__c> csData = [SELECT Id,Name,Response__c,Payoutmerchantid__c,Onboarding_Date__c,Last_3_Month_Gmv_Payout__c,Ytd_Gmv_Payout__c,First_Transaction_Date_Payout__c,
                Last_Transaction_Date_Payout__c,First_Prefunded_Date__c,Last_Prefunded_Date__c
                FROM Cross_Sell__c 
                WHERE Payoutmerchantid__c = :Integer.valueOf(PayoutMerchantId)
                LIMIT 1];
                
                System.debug('>>>>>csData>>>>'+csData);
                if(csData.isEmpty()){
                    response.isSuccess = true;
                    response.message = 'Payout Id not found';
                }else{
                    response.isSuccess = true;
                    response.message = 'Data found successfully';

                    response.data = new CrossCellDetail();
                    response.data.payoutmerchantid = String.valueOf(csData[0].payoutmerchantid__c);
                    response.data.onboardingDate = String.valueOf(csData[0].Onboarding_Date__c);
                    response.data.last3monthsgmv = String.valueOf(csData[0].Last_3_Month_Gmv_Payout__c);
                    response.data.ytdgmv = String.valueOf(csData[0].Ytd_Gmv_Payout__c);
                    response.data.firstTransDatePayout = String.valueOf(csData[0].First_Transaction_Date_Payout__c);
                    response.data.lastTransDatePayout = String.valueOf(csData[0].Last_Transaction_Date_Payout__c);
                    response.data.firstPrefundedDate = String.valueOf(csData[0].First_Prefunded_Date__c);
                    response.data.lastPrefundedDate = String.valueOf(csData[0].Last_Prefunded_Date__c);
                }
                
            }
            
        }catch(Exception e){
            throw new MyCustomException(e.getMessage());
        }
        return response;
    }
    
    private class MyCustomException extends Exception{}
    
    global class Response{
        global Boolean isSuccess;
        global String message;
        global CrossCellDetail data;
        
        global Response(){
            this.isSuccess = true;
            this.message = '';
            //this.data = new CrossCellDetail();
        }
    }
    
    global class CrossCellDetail{
        
        global String payoutmerchantid;
        global String onboardingDate;
        global String last3monthsgmv;
        global String ytdgmv;
        global String firstTransDatePayout;
        global String lastTransDatePayout;
        global String firstPrefundedDate;
        global String lastPrefundedDate;
        global String message;


    }
}