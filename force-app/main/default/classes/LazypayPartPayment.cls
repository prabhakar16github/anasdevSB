public class LazypayPartPayment {
    
    @future (callout=true)
    public static void PostPartPayment(Id myid,string mobile,Decimal amount,string issuingbank,string paymentmode,string repaymentpartnerid,string vpa,string useragent,string payuid,string bankref){
        LP_Collection_PartPayment__mdt postPartPayment1 = [Select MasterLabel, Access_Key__c, EndPoint__c FRom LP_Collection_PartPayment__mdt where MasterLabel =: 'PostPartPayment1']; 
        LP_Collection_PartPayment__mdt postPartPayment2 = [Select MasterLabel, Access_Key__c, EndPoint__c FRom LP_Collection_PartPayment__mdt where MasterLabel =: 'PostPartPayment2']; 

		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(postPartPayment1.EndPoint__c); //##METADATA
        request.setMethod('GET');
        
        String accesskey=    postPartPayment1.Access_Key__c;//##METADATA
        String Repayrequestid;
        if(payuid != null){
            Repayrequestid = 'PAYUID ' + payuid;
        }else{
            Repayrequestid =  'UNQREF '+bankref;
        }
        
        request.setHeader('accessKey',accesskey);
        request.setHeader('data','repaymentMerchantAccessKey='+accesskey+'&repayRequestId='+Repayrequestid+'&mobile='+mobile+'&amount='+amount );
        HttpResponse response = new HttpResponse() ;
        if(!Test.isRunningTest()){
           response = http.send(request); 
        }        
        string resp = response.getBody();
        system.debug('Signature :'+resp);
        
        Http http2 = new Http();
        HttpRequest request2 = new HttpRequest();
        request2.setEndpoint(postPartPayment2.EndPoint__c);
        request2.setMethod('POST');
        request2.setHeader('accessKey',accesskey);
        request2.setHeader('signature',resp);
        request2.setHeader('Content-Type','application/json');
        
        request2.setBody('{ "amount": '+amount+', "issuingBank": "'+issuingbank+'", "mobile": "'+mobile+'","paymentMode": "'+paymentmode+'", "repaymentPartnerId": "'+Repayrequestid+'","status": "SUCCESS", "userAgent": '+useragent+', "vpa": '+vpa+' }');
        //  request2.setBody('{ "amount": '+amount+', "issuingBank": "'+issuingbank+'", "mobile": "'+mobile+'","paymentMode": "'+paymentmode+'", "repaymentPartnerId": "'+Repayrequestid+'","status": "SUCCESS", "userAgent": '+useragent+', "vpa": '+vpa+' }');
        
        system.debug('{ "amount": '+amount+', "issuingBank": "'+issuingbank+'", "mobile": "'+mobile+'","paymentMode": "'+paymentmode+'", "repaymentPartnerId": "'+Repayrequestid+'","status": "SUCCESS", "userAgent": '+useragent+', "vpa": '+vpa+' }');
        
        request2.setTimeout(120000);
        HttpResponse response2 = new HttpResponse();
        if(!Test.isRunningTest()){
            response2 = http.send(request2); 
        }else{
            response2.setBody('{"transactionStatus":"Status","transactionId":"1234","remarks":"Test"}'); 
        }
               
        string resp2 =response2.getBody();
        
        system.debug('Response :'+resp2);
        
        Map<String,Object> rawObj =  (Map<String, Object>) JSON.deserializeUntyped(resp2);        
        
        LP_Collection_PL_PartPayment__c jsonupdate= [select Post_Payment__c,Remarks__c,Json_Response__c,IsPost_Requested__c,posting_Date_Time__c ,Status__c ,Tranaction_Posting_Status__c ,OPS_transaction_Id__c from LP_Collection_PL_PartPayment__c where id=:myid]; 
        jsonupdate.Json_Response__c =resp2 ;
        jsonupdate.Tranaction_Posting_Status__c= String.valueOf(rawObj.get('transactionStatus'));
        jsonupdate.Post_Payment__c =false;
        jsonupdate.Status__c='Posting Complete';
        jsonupdate.OPS_transaction_Id__c= String.valueOf(rawObj.get('transactionId'));
        jsonupdate.Remarks__c= String.valueOf(rawObj.get('remarks'));
        jsonupdate.IsPost_Requested__c = true;
        jsonupdate.posting_Date_Time__c	= System.now();
        // Make the update call.
        update jsonupdate;
        
        
    }
    
    @future (callout=true)
    public static void GetPaymentLink(id myid,Decimal amount2, string txnid, string productinfo,string firstname,string email,string phone,string address1,string city,string state,string country,string zipcode,string template_id,string sms_template_id,string validation_period,string time_unit){
        LP_Collection_PartPayment__mdt GetPaymentLink = [Select MasterLabel, Access_Key__c, EndPoint__c FRom LP_Collection_PartPayment__mdt where MasterLabel =: 'GetPaymentLink']; 

        String amount = amount2.toPlainString();
        
        String my_var1='{\"amount\":\"'+amount+'\",\"txnid\":\"'+txnid+'\",\"productinfo\":\"'+productinfo+'\",\"firstname\":\"'+firstname+'\",\"email\":\"'+email+'\",\"phone\":\"'+phone+'\",\"address1\":\"'+address1+'\",\"city\":\"'+city+'\",\"state\":\"'+state+'\",\"country\":\"'+country+'\",\"zipcode\":\"'+zipcode+'\",\"template_id\":\"1\",\"sms_template_id\":\"1\",\"validation_period\":'+validation_period+',\"time_unit\":\"'+time_unit+'\",\"send_email_now\":\"0\",\"send_sms\":\"0\"}';
        
        
        String my_key= label.LP_PartPayment_FOFsze;//##METADATA
       // String my_key='mmlMHB';
        String my_command='create_invoice';
      //  String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+'BeWLpmpz';
      //  
      //  
     	 String ssalt= label.LP_PartPayment_WkU3CHey; //##METADATA
        String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+ssalt;
        BLOb newhash3 = Crypto.generateDigest('sha512', Blob.valueof(newHash));
        
        
        String boundry = '------WebKitFormBoundary7MA4YWxkTrZu0gW--';
        
        String newhash2=EncodingUtil.convertToHex(newhash3);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GetPaymentLink.EndPoint__c);
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
        HttpResponse response2 = new HttpResponse();
        if(!Test.isRunningTest()){
           response2 = http.send(request);  
        }        
        string resp2 =response2.getBody();    
        
        system.debug(resp2);
        try{ 
            
            if(resp2=='"Invoice for this transaction id already exists."')
            {
                LP_Collection_PL_PartPayment__c jsonupdate= [select Generate_Payment_URL__c,PayLinkCounter__c,Payment_URL__c from LP_Collection_PL_PartPayment__c where id=:myid]; 
                jsonupdate.Payment_URL__c ='Error: Duplicate transaction id.' ;     
                jsonupdate.Generate_Payment_URL__c =false;
                // Make the update call.
                update jsonupdate;
            }
            else{
                Map<String,Object> rawObj =  (Map<String, Object>) JSON.deserializeUntyped(resp2);   
                LP_Collection_PL_PartPayment__c jsonupdate= [select Generate_Payment_URL__c,Payment_URL__c,PayLinkCounter__c,Status__c from LP_Collection_PL_PartPayment__c where id=:myid]; 
                jsonupdate.Payment_Url__c =String.valueOf(rawobj.get('URL')) ;     
                jsonupdate.Generate_Payment_URL__c =false;  
                jsonupdate.Status__c ='Payment Link Generated';
                jsonupdate.PayLinkCounter__c= jsonupdate.PayLinkCounter__c +1;
                // Make the update call.
                update jsonupdate;
            }
            
        }catch(Exception ex)
        {
            LP_Collection_PL_PartPayment__c jsonupdate= [select Generate_Payment_URL__c,Payment_URL__c,PayLinkCounter__c from LP_Collection_PL_PartPayment__c where id=:myid]; 
            jsonupdate.Payment_URL__c ='Some Error occured' ;     
            jsonupdate.Generate_Payment_URL__c =false;
            
            jsonupdate.PayLinkCounter__c= jsonupdate.PayLinkCounter__c +1;
            // Make the update call.
            update jsonupdate;
            
        }
        
        
    }
    
      @future (callout=true)
    public static void CheckPaymentLink(id myid, string txnid){
        LP_Collection_PartPayment__mdt CheckPaymentLink = [Select MasterLabel, Access_Key__c, EndPoint__c FRom LP_Collection_PartPayment__mdt where MasterLabel =: 'GetPaymentLink']; 

        String my_var1=txnid;
        
       // String my_key='mmlMHB';
        String my_key= label.LP_PartPayment_FOFsze;
        
        
        String my_command='verify_payment';
        
      //  String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+'BeWLpmpz';
      String ssalt = label.LP_PartPayment_WkU3CHey; //##METADATA
      String newHash= my_key+'|'+ my_command + '|'+ my_var1 +'|'+ssalt;
      
        
        
        BLOb newhash3 = Crypto.generateDigest('sha512', Blob.valueof(newHash));
        
        
        String boundry = '------WebKitFormBoundary7MA4YWxkTrZu0gW--';
        
        String newhash2=EncodingUtil.convertToHex(newhash3);
        system.debug(newhash2);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CheckPaymentLink.EndPoint__c);
        request.setMethod('POST');
        
        String body = '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="var1"\r\n\n';
        body += my_var1+'\r\n';
        body += '--' + boundry + '\r\n';
        body += 'Content-Disposition: form-data; name="key"\r\n\n';
       // body += 'mmlMHB\r\n';
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
        HttpResponse response2  = new HttpResponse();
        if(!Test.isRunningTest()){
           response2 = http.send(request); 
        }else{
            response2.setBody('{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"9673654514PRT-30771":{"mihpayid":"9645468519","request_id":"","bank_ref_num":"000919533761","amt":"10.00","transaction_amount":"10.00","txnid":"9673654514PRT-30771","additional_charges":"0.00","productinfo":"Part payment","firstname":"firstname","bankcode":"UPI","udf1":null,"udf3":null,"udf4":null,"udf5":null,"field2":"11207187229","field9":"SUCCESS&#124;Completed Using Callback","error_code":"E000","addedon":"2020-01-09 19:09:48","payment_source":"invoice","card_type":null,"error_Message":"NO ERROR","net_amount_debit":10,"disc":"0.00","mode":"UPI","PG_TYPE":"HDFCU","card_no":"","udf2":null,"status":"success","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}') ; 
        }
         
        string resp2 =response2.getBody();   
        System.debug('resp2>>> '+ resp2);
        Map<String,Object> rawObj1 =  (Map<String, Object>) JSON.deserializeUntyped(resp2);   
        
        Map<String,Object> rawObj2 =  (Map<String, Object>) rawObj1.get('transaction_details');  
        
        Map<String,Object> rawObj3 =  (Map<String, Object>) rawObj2.get(txnid);   
        
         LP_Collection_PL_PartPayment__c jsonupdate= [select Transaction_Status__c,Check_Transaction_Status__c,PayU_ID__c,Bank_Reference_Number__c from LP_Collection_PL_PartPayment__c where id=:myid]; 
       // jsonupdate.Transaction_Status_Response__c =resp2 ; 
        if(!Test.isRunningTest()){
       //   jsonupdate.Bank_Reference_Number__c=String.valueOf(rawObj3.get('bank_ref_num')) ;
          jsonupdate.PayU_ID__c =String.valueOf(rawObj3.get('mihpayid')) ;
        
      //  jsonupdate.Transaction_Addedon__c =String.valueOf(rawObj3.get('addedon')) ;
        
          jsonupdate.Check_Transaction_Status__c =false;
          jsonupdate.Transaction_Status__c=String.valueOf(rawObj3.get('status'));  
        }     

        // Make the update call.
        update jsonupdate;
        
        
    }
  
    
	@future (callout=true)    
	public static void SendPaymentDetails(id myid,string mobile,string amount,string paylink,string ftemobile)
    {
       
     LP_Collection_PartPayment__mdt SendPaymentDetails1 = [Select MasterLabel, Access_Key__c, EndPoint__c , EndPoint_Part_1__c ,EndPoint_Part_2__c,EndPoint_Part_3__c FRom LP_Collection_PartPayment__mdt where MasterLabel =: 'SendPaymentDetails1']; 
   
          // Send SMS to FTE
       // String SMSContent2='Lazypay Collection,%0aCustomer Mobile - '+mobile+'%0a%0a Payment Link- '+paylink;
        String SMSContent2= label.LP_PartPayment_SMSContent2_Part1 + ' ' + mobile + label.LP_PartPayment_SMSContent2_Part2 + ' '+ paylink;
        Http http2 = new Http();
        HttpRequest request3 = new HttpRequest();
        
       
        
       // request3.setEndpoint('https://api-alerts.kaleyra.com/v4/?api_key=Aaf56e63ebabeebc5558a2c07c79ee61e&method=sms&message=' + SMSContent2 +'&to='+ftemobile+'&sender=LZYPAY&format=JSON&unicode=1'); //##METADATA
        request3.setEndpoint(SendPaymentDetails1.EndPoint_Part_1__c + SMSContent2 + SendPaymentDetails1.EndPoint_Part_2__c + ftemobile + SendPaymentDetails1.EndPoint_Part_3__c); 
        request3.setMethod('GET');
        HttpResponse response3 = new HttpResponse();
        if(!Test.isRunningTest()){
           response3 = http2.send(request3); 
        }
        
       // string resp3 =response3.getBody();     
        
        
       LP_Collection_PartPayment__mdt SendPaymentDetails2 = [Select MasterLabel, Access_Key__c, EndPoint__c , EndPoint_Part_1__c ,EndPoint_Part_2__c,EndPoint_Part_3__c FRom LP_Collection_PartPayment__mdt where MasterLabel =: 'SendPaymentDetails2'];  
       // String SMSContent='Dear Customer,%0aWe recieved your request for part-payment of Rs. '+ amount +'. Kindly pay, using any of the below method.%0a%0a1. Pay Online - UPI,DC,NB (Fast):%0a'+paylink+'%0a%0a2. Funds Transfer - NEFT/IMPS:%0aTransfer funds to below A/C%0aA/C: 2313558865%0aIFSC: KKBK0000651%0a%0aKindly share the UTR number of succesful transaction with the Agent to have your PL A/C updated.'; 
        String SMSContent = label.LP_PartPayment_SMSContent1_Part1 + ' ' + amount  + label.LP_PartPayment_SMSContent1_Part2 + paylink + label.LP_PartPayment_SMSContent1_Part3;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
       // request.setEndpoint('https://api-alerts.kaleyra.com/v4/?api_key=Aaf56e63ebabeebc5558a2c07c79ee61e&method=sms&message='+ SMSContent +'&to='+mobile+'&sender=LZYPAY&format=JSON&unicode=1');//##METADATA
        request.setEndpoint(SendPaymentDetails2.EndPoint_Part_1__c + SMSContent + SendPaymentDetails2.EndPoint_Part_2__c + mobile + SendPaymentDetails2.EndPoint_Part_3__c);
        request.setMethod('GET');
        HttpResponse response2 = new HttpResponse();
        if(!Test.isRunningTest()){
           response2 = http.send(request); 
        }      
        string resp2 =response2.getBody();      
 		         
  		LP_Collection_PL_PartPayment__c jsonupdate= [select Send_Payment_Details_to_Customer__c from LP_Collection_PL_PartPayment__c where id=:myid]; 
        jsonupdate.Send_Payment_Details_to_Customer__c =false;
       	jsonupdate.Status__c = 'Payment Pending By Customer';
        // Make the update call.
        update jsonupdate;
   
    }


}