public class LP_CallLazypayPayUbiz {
    
       @future (callout=true)
    public static void GetJsonResponse(string mobile, string myloanid, Id myid){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(label.LP_ForClosure_GetJsonResponse);
        request.setMethod('GET');
        request.setHeader('data','LoanAccountId='+myloanid);
        request.setHeader('key',mobile);
        HttpResponse response = new HttpResponse();
        if(!test.isRunningTest()){
           response = http.send(request); 
        } 
        string resp = response.getBody();
        Http http2 = new Http();
        HttpRequest request2 = new HttpRequest();
        request2.setEndpoint(label.LP_ForClosure_GetJsonResponse2 + myloanid);
        request2.setMethod('GET');
        request2.setHeader('signature',resp);
        request2.setHeader('accessKey',mobile);
        HttpResponse response2 = new HttpResponse();
        if(!Test.isRunningTest()){
           response2 = http.send(request2); 
        }else{
            response2.setBody('{"loanForeCloseAmount":"20.0"}') ; 
        }        
        string resp2 =response2.getBody(); 	
        
        if(response2.getStatusCode() <> 200)
        {        
            LP_Collection_foreclosure__c jsonupdate= [select Status__c,Foreclosure_Enquiry_Response__c,Amount__c,Foreclosure_Enquiry__c from LP_Collection_foreclosure__c where id=:myid];     
            jsonupdate.Foreclosure_Enquiry_Response__c = resp2.right(255) ;
            jsonupdate.Foreclosure_Enquiry__c =false;
            update jsonupdate;    
        }
        else{        
            Map<String,Object> rawObj =  (Map<String, Object>) JSON.deserializeUntyped(resp2);        
            LP_Collection_foreclosure__c jsonupdate= [select Status__c,Foreclosure_Enquiry_Response__c,Amount__c,Foreclosure_Enquiry__c from LP_Collection_foreclosure__c where id=:myid]; 
            jsonupdate.Foreclosure_Enquiry_Response__c =resp2 ;
            jsonupdate.Amount__c= String.valueOf(rawObj.get('loanForeCloseAmount'));
            jsonupdate.Foreclosure_Enquiry__c =false;
            jsonupdate.Status__c='Foreclosure Enquiry';
            // Make the update call.
            update jsonupdate;
            
        }
        
    }
    
    @future (callout=true)
    public static void GetJsonResponse2(string mobile, string myloanid, Id myid, string amount,string payuid,String bankref){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(label.LP_ForClosure_GetJsonResponse3);
        request.setMethod('GET');
        
        request.setHeader('data','LoanAccountId='+myloanid +'&&Mobile='+ mobile );
        request.setHeader('key',mobile);
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()){
           response = http.send(request); 
        }
              
        string resp = response.getBody();
        Http http2 = new Http();
        HttpRequest request2 = new HttpRequest();
        request2.setEndpoint(label.LP_ForClosure_GetJsonResponse4);
        request2.setMethod('POST');
        request2.setHeader('signature',resp);
        request2.setHeader('Content-Type','application/json');
        request2.setBody('{"ctx": "PBIZ - '+payuid+'","loanAccountId": '+ myloanid +',"mobile": "'+mobile+'","overrideForeCloseAmount": '+amount+',"repayTransactionRefNumber": "'+payuid+'"}');
        // system.debug('{"ctx": "PBIZ-'+payuid+'","loanAccountId": '+ myloanid +',"mobile": "'+mobile+'","overrideForeCloseAmount": '+amount+',"repayTransactionRefNumber": "'+bankref+'"}');
        HttpResponse response2  = new HttpResponse();
        if(!Test.isRunningTest()){
           response2 = http.send(request2);  
        }else{
            response2.setBody('{"foreCloseTransactionId":"12345"}');  
        }
                 
        string resp2 =response2.getBody();
        
        Map<String,Object> rawObjt =  (Map<String, Object>) JSON.deserializeUntyped(resp2);        
        
        
        LP_Collection_foreclosure__c jsonupdate= [select Lazypay_Posting_Response__c,Status__c,Submit_for_Posting__c from LP_Collection_foreclosure__c where id=:myid]; 
        jsonupdate.Lazypay_Posting_Response__c =resp2 ;
        
        jsonupdate.Lazypay_TrxID__c = String.valueOf(rawObjt.get('foreCloseTransactionId'));
        
        jsonupdate.Submit_for_Posting__c =false;
        jsonupdate.Status__c='Foreclosure Posting Complete';
        // Make the update call.
        update jsonupdate;
    }
    
    
    @future (callout=true)
    public static void GetPaymentLink(id myid,string amount, string txnid, string productinfo,string firstname,string email,string phone,string address1,string city,string state,string country,string zipcode,string template_id,string sms_template_id,string validation_period,string time_unit){
        
        String my_var1='{\"amount\":\"'+amount+'\",\"txnid\":\"'+txnid+'\",\"productinfo\":\"'+productinfo+'\",\"firstname\":\"'+firstname+'\",\"email\":\"'+email+'\",\"phone\":\"'+phone+'\",\"address1\":\"'+address1+'\",\"city\":\"'+city+'\",\"state\":\"'+state+'\",\"country\":\"'+country+'\",\"zipcode\":\"'+zipcode+'\",\"template_id\":\"1\",\"sms_template_id\":\"1\",\"validation_period\":'+validation_period+',\"time_unit\":\"'+time_unit+'\",\"send_email_now\":\"0\",\"send_sms\":\"0\"}';      
     //   String my_key='mmlMHB';
         String my_key='FOFsze';
       
        String my_command='create_invoice';
        //String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+'BeWLpmpz';
        String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+'WkU3CHey';       
        BLOb newhash3 = Crypto.generateDigest('sha512', Blob.valueof(newHash));
        String boundry = '------WebKitFormBoundary7MA4YWxkTrZu0gW--';
        String newhash2=EncodingUtil.convertToHex(newhash3);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(label.LP_ForClosure_GetPaymentLink);
        request.setMethod('POST');
        
        String body = '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="var1"\r\n\n';
        body += my_var1+'\r\n';
        body += '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="key"\r\n\n';
        body += my_key+'\r\n';
        body += '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="hash"\r\n\n';
        body += newhash2+'\r\n';
        body += '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="command"\r\n\n';
        body += 'create_invoice\r\n';
        body += '--' + boundry + '--';
        request.setBody(body);
        request.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundry);
        request.setHeader('Content-Length', String.valueof(body.length()));
        HttpResponse response2 =  new HttpResponse();
        if(!Test.isRunningTest()){
           response2 = http.send(request); 
        }else{
            response2.setBody('{"URL":"www.google.com"}');
        }        
        string resp2 =response2.getBody();    
        
        system.debug(resp2);
        try{ 
            
            if(resp2=='"Invoice for this transaction id already exists."')
            {
                LP_Collection_foreclosure__c jsonupdate= [select Regenerate_Payment_Url__c,Payment_URL__c from LP_Collection_foreclosure__c where id=:myid]; 
                jsonupdate.Payment_URL__c ='Error: Duplicate transaction id.Retry using LazypayLoanid_(count)' ;     
                jsonupdate.Regenerate_Payment_Url__c =false;
                // Make the update call.
                update jsonupdate;
            }
            else{
                Map<String,Object> rawObj =  (Map<String, Object>) JSON.deserializeUntyped(resp2);   
                LP_Collection_foreclosure__c jsonupdate= [select Regenerate_Payment_Url__c,Payment_URL__c,Status__c from LP_Collection_foreclosure__c where id=:myid]; 
                jsonupdate.Payment_URL__c =String.valueOf(rawobj.get('URL')) ;     
                jsonupdate.Regenerate_Payment_Url__c =false;  
                jsonupdate.Status__c ='Payment Link Generated';
                // Make the update call.
                update jsonupdate;
            }
            
        }catch(Exception ex)
        {
            LP_Collection_foreclosure__c jsonupdate= [select Regenerate_Payment_Url__c,Payment_URL__c from LP_Collection_foreclosure__c where id=:myid]; 
            jsonupdate.Payment_URL__c ='Some Error occured' ;     
            jsonupdate.Regenerate_Payment_Url__c =false;
            // Make the update call.
            update jsonupdate;
            
        }
        
        
    }
    
    @future (callout=true)
    public static void CheckPaymentLink(id myid, string txnid){
        
        String my_var1=txnid;
        
       // String my_key='mmlMHB';
        String my_key='FOFsze';
        String my_command='verify_payment';
        //String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+'BeWLpmpz';
        String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+'WkU3CHey';
        BLOb newhash3 = Crypto.generateDigest('sha512', Blob.valueof(newHash));
        
        
        String boundry = '------WebKitFormBoundary7MA4YWxkTrZu0gW--';
        
        String newhash2=EncodingUtil.convertToHex(newhash3);
        system.debug(newhash2);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(label.LP_ForClosure_CheckPaymentLink);
        request.setMethod('POST');
        
        String body = '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="var1"\r\n\n';
        body += my_var1+'\r\n';
        body += '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="key"\r\n\n';
        body += my_key+'\r\n';
        body += '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="hash"\r\n\n';
        body += newhash2 +'\r\n';
        body += '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="command"\r\n\n';
        body += 'verify_payment\r\n';
        body += '--' + boundry + '--';
        request.setBody(body);
        request.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundry);
        request.setHeader('Content-Length', String.valueof(body.length()));
        HttpResponse response2 = new HttpResponse();
        if(!Test.isRunningTest()){
           response2 = http.send(request); 
        }else{
          response2.setBody('{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"9673654514PRT-30771":{"mihpayid":"9645468519","request_id":"","bank_ref_num":"000919533761","amt":"10.00","transaction_amount":"10.00","txnid":"9673654514PRT-30771","additional_charges":"0.00","productinfo":"Part payment","firstname":"firstname","bankcode":"UPI","udf1":null,"udf3":null,"udf4":null,"udf5":null,"field2":"11207187229","field9":"SUCCESS&#124;Completed Using Callback","error_code":"E000","addedon":"2020-01-09 19:09:48","payment_source":"invoice","card_type":null,"error_Message":"NO ERROR","net_amount_debit":10,"disc":"0.00","mode":"UPI","PG_TYPE":"HDFCU","card_no":"","udf2":null,"status":"success","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}') ; 
 
        }
        
        string resp2 =response2.getBody();      
        Map<String,Object> rawObj1 =  (Map<String, Object>) JSON.deserializeUntyped(resp2);   
        
        Map<String,Object> rawObj2 =  (Map<String, Object>) rawObj1.get('transaction_details');  
        
        Map<String,Object> rawObj3 =  (Map<String, Object>) rawObj2.get(txnid);   
        
        LP_Collection_foreclosure__c jsonupdate= [select Transaction_Status__c,Check_Transaction_status__c,Transaction_Status_Response__c,Bank_Reference_Number__c from LP_Collection_foreclosure__c where id=:myid]; 
        jsonupdate.Transaction_Status_Response__c =resp2 ;     
       // jsonupdate.Bank_Reference_Number__c=String.valueOf(rawObj3.get('bank_ref_num')) ;
        jsonupdate.Payment_Link_PAYU_ID__c =String.valueOf(rawObj3.get('mihpayid')) ;       
        jsonupdate.Transaction_Addedon__c =String.valueOf(rawObj3.get('addedon')) ;     
        jsonupdate.Check_Transaction_status__c =false;
        jsonupdate.Transaction_Status__c=String.valueOf(rawObj3.get('status'));
        // Make the update call.
        update jsonupdate;   
    }
}