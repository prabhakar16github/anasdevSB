@isTest
global class CustomRateHttpMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('success');
        
        JSONGenerator resultJSON = JSON.createGenerator(true);
        resultJSON.writeStartArray();
        resultJSON.writeStartObject();
        resultJSON.writeStringField('percentageFee', '0.07');
        resultJSON.writeStringField('merchantId', '8006911');
        resultJSON.writeStringField('clientId', '1');
        resultJSON.writeStringField('paymentMode', 'netbanking');
        resultJSON.writeEndObject();
        resultJSON.writeStartObject();
        resultJSON.writeStringField('percentageFee', '1');
        resultJSON.writeStringField('merchantId', '8006911');
        resultJSON.writeStringField('clientId', '1');
        resultJSON.writeStringField('paymentMode', 'upi');
        resultJSON.writeEndObject();
        resultJSON.writeEndArray();
        String result = resultJSON.getAsString();
        System.debug('result json is: ' +result);
        
        
        /*CustomizedRatesJSONParser.Result cusRateResObj = new CustomizedRatesJSONParser.Result();
        cusRateResObj.merchantId = '8006911';
        cusRateResObj.clientId = '1';
        cusRateResObj.paymentMode = 'netbanking';
        cusRateResObj.percentageFee = 0.07;
        
        String resObjJSON = JSON.serialize(cusRateResObj);*/
        
        //JSONGenerator resultJSON = JSON.createGenerator(true);
        
        
        /*List<CustomizedRatesJSONParser.Result> results = new List<CustomizedRatesJSONParser.Result>();
        results.add(cusRateResObj);*/
        //results.add(resultJSON);
        
        /*List<String> results = new List<String>();
        results.add(result);
        
        String allResultsString = String.join(results,',');*/
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('code', '2000');
        gen.writeStringField('status', '0');
        gen.writeStringField('message', 'Testing');
        gen.writeStringField('result', result);
        gen.writeEndObject();
        String body = gen.getAsString();  
        
        //res.setBody(gen.getAsString());
        
        /*String body = '{'+
    '"code": "2000",'+
    '"message": "Success",'+
    '"status": 0,'+
    '"result": '+
         '['+
        '{'+
            '"clientId": "1",'+
            '"merchantId": "8006911",'+
            '"paymentMode": "netbanking",'+
            '"percentageFee": 0.07'+
        '},'+
        '{'+
            '"clientId": "1",'+
            '"merchantId": "8006911",'+
            '"paymentMode": "upi",'+
            '"percentageFee": 0.01'+
        '},'+
    ']'+
'}';
        */
        res.setBody(body);
        
        return res;
    }
    
    /*public class dummyResult{
        public String clientId;
		public String merchantId;
        public String paymentMode;
        public Double percentageFee;
        
        public dummyResult(String cid, String mid, String payMode, Double percentageFee){
            this.clientId = cid;
            this.merchantId = mid;
            this.paymentMode = payMode;
            this.percentageFee = percentageFee;
        }
    }*/

}