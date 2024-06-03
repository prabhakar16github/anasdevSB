@isTest
public class MCareRiskEngineAPIControllerTracker {

    public static testMethod void testData_1(){
        string payload = '{"issue": {"project_id": "36", "tracker_id": "31", "subject": "test 123456", "start_date": "2021-09-03", "from_email": "riskemailsender@payu.in", "name": "Test-3", "priority": "High", "estimated_hours": "24", "description": "Test 2 post onboarding merchant risk monitoring - SMB", "assigned_to_email": "merchantsettlement@payu.in", "due_date": "2021-06-05", "custom_fields": [{"id": "2", "value": "Ashish Kumar"}, {"id": "58", "value": "payu.in"}, {"id": "144", "value": "SMB-ENT"}, {"id": 148, "value": "ashish.kumar@payu.in"}, {"id": "21", "value": "123456"}, {"id": "99", "value": ""}, {"id": "110", "value": 3}, {"id": "112", "value": 41}, {"id": "117", "value": ""}, {"id": "128", "value": 464}, {"id": "122", "value": 0.0}, {"id": "123", "value": 0.0}, {"id": "115", "value": ""}, {"id": "121", "value": ""}, {"id": "150", "value": "PayUbiz"}]}}}';
    	RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/MCareRiskEngineAPI';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(payload);
		
        RestContext.request = request;
        RestContext.response = response;
		MCareRiskEngineAPIController.getRiskEngineTickets();
    }
    
    public static testMethod void testData_2(){
        string payload = '{"issue": "project_id": "36", "tracker_id": "31", "subject": "test 123456", "start_date": "2021-09-03", "from_email": "riskemailsender@payu.in", "name": "Test-3", "priority": "High", "estimated_hours": "24", "description": "Test 2 post onboarding merchant risk monitoring - SMB", "assigned_to_email": "merchantsettlement@payu.in", "due_date": "2021-06-05", "custom_fields": [{"id": "2", "value": "Ashish Kumar"}, {"id": "58", "value": "payu.in"}, {"id": "144", "value": "SMB-ENT"}, {"id": 148, "value": "ashish.kumar@payu.in"}, {"id": "21", "value": "123456"}, {"id": "99", "value": ""}, {"id": "110", "value": 3}, {"id": "112", "value": 41}, {"id": "117", "value": ""}, {"id": "128", "value": 464}, {"id": "122", "value": 0.0}, {"id": "123", "value":""}, {"id": "115", "value": ""}, {"id": "121", "value": ""}, {"id": "150", "value": "PayUbiz"}]}}}';
    	RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/MCareRiskEngineAPI';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(payload);
		
        RestContext.request = request;
        RestContext.response = response;
		MCareRiskEngineAPIController.getRiskEngineTickets();
    }
}