public class TestKunal {

    public static void testMain(){
        
        HttpResponse res = new HttpResponse();
        
        res.setStatusCode(200);
        
        String resBody = '{';
        resBody += '"code": "2000",';
        resBody += '"message": "Success",';
        resBody += '"status": 0,';
        resBody += '"result": [';
        resBody += '{';
        resBody += ' "clientId":"1",';
        resBody += '"merchantId": "8006911",';
        resBody += '"ruleId": "7119599",';
        resBody += '"paymentMode": "netbanking",';
        resBody += '"type": "instantSettlementTdr",';
        resBody += '"debitModel": "Net",';
        resBody += '"subPaymentMode": null,';
        resBody += '"paymentScheme": null,';
        resBody += '"paymentEntity": null,';
        resBody += '"moreThanAmount": 0.0,';
        resBody += '"isOnus": 0,';
        resBody += '"refundMode": null,';
        resBody += '"cardType": "international",';
        resBody += '"validFrom": "2022-09-28 12:00:00",';
        resBody += '"validTill": null,';
        resBody += '"gmvLimit": null,';
        resBody += '"gmvLimtMode": null,';
        resBody += '"flatFee": 0.0,';
        resBody += '"percentageFee": 0.07,';
        resBody += '"tdrType": "512"';
        resBody += '},';
        resBody += '{';
        resBody += ' "clientId": "1",';
        resBody += '"merchantId": "8006911",';
        resBody += '"ruleId": "7119599",';
        resBody += '"paymentMode": "debitcard",';
        resBody += '"type": "TDR",';
        resBody += '"debitModel": "Net",';
        resBody += '"subPaymentMode": "DC",';
        resBody += '"paymentScheme": null,';
        resBody += '"paymentEntity": null,';
        resBody += '"moreThanAmount": 0.0,';
        resBody += '"isOnus": 0,';
        resBody += '"refundMode": null,';
        resBody += '"cardType": "domestic",';
        resBody += '"validFrom": "2022-10-04 12:00:00",';
        resBody += '"validTill": null,';
        resBody += '"gmvLimit": null,';
        resBody += '"gmvLimtMode": null,';
        resBody += '"flatFee": 0.0,';
        resBody += '"percentageFee": 1.5,';
        resBody += '"tdrType": "0"';
        resBody += '}';        
        resBody += ']';
        resBody += '}';
        
        res.setBody(resBody);
        
        ServiceAgreementController.pricingResponseHandler(res);
        
    }
    
}